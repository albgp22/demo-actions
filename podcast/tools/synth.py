#!/usr/bin/env python3
"""Sintetiza y monta el podcast a partir de los guiones de ../guion/*.txt

Sintaxis del guion (una intervención por línea):
    # Título del capítulo        -> inicia un capítulo (marcador)
    ## Título de sección         -> marcador de sección (no se pronuncia)
    L: texto                     -> habla Lucía (voz femenina)
    P: texto                     -> habla Pablo (voz masculina)
    [PAUSA 6]                    -> silencio de 6 s (con un "tic" suave al inicio si >= 3 s)
    [MORSE CQ]                   -> señal en código Morse (sin voz)
    // comentario                -> se ignora

Uso:
    synth.py stats                      # palabras y duración estimada/real
    synth.py synth [--workers 4] [--only 01]
    synth.py assemble [--only 01]       # monta WAV/MP3 por capítulo y el episodio completo
"""
import argparse, glob, hashlib, json, os, random, re, subprocess, sys, time
from multiprocessing import Pool

import numpy as np
import soundfile as sf

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from normalize import normalize  # noqa: E402

ROOT = os.path.dirname(HERE)
GUION = os.environ.get("PODCAST_GUION", os.path.join(ROOT, "guion"))
SCRATCH = os.environ.get("PODCAST_SCRATCH", "/tmp/claude-0/-home-user-demo-actions/e4789523-6e54-5941-92c6-92ad0d7541e4/scratchpad/tts")
CACHE = os.path.join(SCRATCH, "cache")
BUILD = os.path.join(SCRATCH, "build")
MODEL = os.path.join(SCRATCH, "models/kokoro-v1.0.onnx")
VOICES = os.path.join(SCRATCH, "models/voices-v1.0.bin")
OUT = os.path.join(ROOT, "audio")
SR = 24000

SPEAKERS = {
    "L": {"name": "Lucía", "voice": "ef_dora", "speed": 0.95},
    "P": {"name": "Pablo", "voice": "em_santa", "speed": 0.97},
}


# ---------------------------------------------------------------- parseo
def parse_chapter(path):
    items = []  # dicts: kind=chapter|section|say|pause|morse
    for ln, raw in enumerate(open(path, encoding="utf-8"), 1):
        line = raw.strip()
        if not line or line.startswith("//"):
            continue
        if line.startswith("## "):
            items.append({"kind": "section", "title": line[3:].strip()})
        elif line.startswith("# "):
            items.append({"kind": "chapter", "title": line[2:].strip()})
        elif re.match(r"^[LP]:\s", line):
            items.append({"kind": "say", "spk": line[0], "text": line[2:].strip(), "src": f"{os.path.basename(path)}:{ln}"})
        elif m := re.match(r"^\[PAUSA\s+([\d.]+)\]$", line):
            items.append({"kind": "pause", "secs": float(m.group(1))})
        elif m := re.match(r"^\[MORSE\s+(.+)\]$", line):
            items.append({"kind": "morse", "text": m.group(1)})
        else:
            raise SystemExit(f"Línea no reconocida en {path}:{ln}: {line[:80]}")
    return items


def chapter_files(only=None):
    files = sorted(glob.glob(os.path.join(GUION, "*.txt")))
    if only:
        files = [f for f in files if os.path.basename(f).startswith(only)]
    return files


def cache_key(spk, text):
    cfg = SPEAKERS[spk]
    spoken = normalize(text)
    h = hashlib.sha1(f"{cfg['voice']}|{cfg['speed']}|{spoken}".encode()).hexdigest()[:16]
    return h, spoken


# -------------------------------------------------------------- síntesis
_K = None


def _init_worker():
    global _K
    import onnxruntime as ort
    from kokoro_onnx import Kokoro
    so = ort.SessionOptions()
    so.intra_op_num_threads = 1
    so.inter_op_num_threads = 1
    sess = ort.InferenceSession(MODEL, sess_options=so, providers=["CPUExecutionProvider"])
    _K = Kokoro.from_session(sess, VOICES)


def _synth_job(job):
    h, spk, spoken = job
    path = os.path.join(CACHE, f"{h}.wav")
    if os.path.exists(path):
        return h, 0.0
    cfg = SPEAKERS[spk]
    t = time.time()
    a, sr = _K.create(spoken, voice=cfg["voice"], speed=cfg["speed"], lang="es",
                      sentence_pause=0.28, clause_pause=0.12)
    assert sr == SR
    tmp = path + ".tmp.wav"
    sf.write(tmp, a, sr)
    os.replace(tmp, path)
    return h, time.time() - t


def cmd_synth(args):
    os.makedirs(CACHE, exist_ok=True)
    jobs, seen = [], set()
    for f in chapter_files(args.only):
        for it in parse_chapter(f):
            if it["kind"] == "say":
                h, spoken = cache_key(it["spk"], it["text"])
                if h not in seen and not os.path.exists(os.path.join(CACHE, f"{h}.wav")):
                    seen.add(h)
                    jobs.append((h, it["spk"], spoken))
    print(f"{len(jobs)} intervenciones por sintetizar con {args.workers} procesos", flush=True)
    if not jobs:
        return
    # las más largas primero para equilibrar la carga
    jobs.sort(key=lambda j: -len(j[2]))
    t0, done = time.time(), 0
    with Pool(args.workers, initializer=_init_worker) as pool:
        for h, dt in pool.imap_unordered(_synth_job, jobs, chunksize=1):
            done += 1
            if done % 20 == 0 or done == len(jobs):
                print(f"  {done}/{len(jobs)}  ({time.time()-t0:.0f}s)", flush=True)


# ---------------------------------------------------------------- audio
def trim(a, thr=0.004, keep=0.04):
    idx = np.where(np.abs(a) > thr)[0]
    if len(idx) == 0:
        return a
    s = max(0, idx[0] - int(keep * SR))
    e = min(len(a), idx[-1] + int(keep * SR))
    return a[s:e]


def fade(a, ms=8):
    n = int(SR * ms / 1000)
    if len(a) > 2 * n:
        a = a.copy()
        a[:n] *= np.linspace(0, 1, n)
        a[-n:] *= np.linspace(1, 0, n)
    return a


MORSE = {"A": ".-", "B": "-...", "C": "-.-.", "D": "-..", "E": ".", "F": "..-.", "G": "--.", "H": "....",
         "I": "..", "J": ".---", "K": "-.-", "L": ".-..", "M": "--", "N": "-.", "O": "---", "P": ".--.",
         "Q": "--.-", "R": ".-.", "S": "...", "T": "-", "U": "..-", "V": "...-", "W": ".--", "X": "-..-",
         "Y": "-.--", "Z": "--..", "0": "-----", "1": ".----", "2": "..---", "3": "...--", "4": "....-",
         "5": ".....", "6": "-....", "7": "--...", "8": "---..", "9": "----."}


def morse_audio(text, wpm=16, freq=640, level=0.18):
    unit = 1.2 / wpm
    parts = []

    def tone(d):
        n = int(SR * d)
        t = np.arange(n) / SR
        env = np.minimum(1, np.minimum(t, d - t) / 0.006)
        return (np.sin(2 * np.pi * freq * t) * env * level).astype(np.float32)

    def sil(d):
        return np.zeros(int(SR * d), dtype=np.float32)

    for word in text.upper().split():
        for ch in word:
            for sym in MORSE.get(ch, ""):
                parts += [tone(unit if sym == "." else 3 * unit), sil(unit)]
            parts.append(sil(2 * unit))
        parts.append(sil(4 * unit))
    return np.concatenate(parts + [sil(0.4)])


def tick():
    d = 0.12
    t = np.arange(int(SR * d)) / SR
    env = np.exp(-t * 28)
    return (np.sin(2 * np.pi * 880 * t) * env * 0.12).astype(np.float32)


def build_chapter(path):
    """Devuelve (audio, marcadores[(seg, título, nivel)], título)."""
    rng = random.Random(os.path.basename(path))
    chunks, marks, title = [], [], os.path.basename(path)
    pos, prev = 0, None

    def add(a):
        nonlocal pos
        chunks.append(a)
        pos += len(a)

    for it in parse_chapter(path):
        k = it["kind"]
        if k == "chapter":
            title = it["title"]
            marks.append((pos / SR, title, 1))
        elif k == "section":
            marks.append((pos / SR, it["title"], 2))
        elif k == "morse":
            add(morse_audio(it["text"]))
            prev = None
        elif k == "pause":
            if it["secs"] >= 3:
                add(tick())
                add(np.zeros(int(SR * (it["secs"] - 0.12)), dtype=np.float32))
            else:
                add(np.zeros(int(SR * it["secs"]), dtype=np.float32))
            prev = None
        else:
            h, _ = cache_key(it["spk"], it["text"])
            w = os.path.join(CACHE, f"{h}.wav")
            if not os.path.exists(w):
                raise SystemExit(f"Falta audio de {it['src']} (ejecuta synth)")
            a, _ = sf.read(w, dtype="float32")
            a = fade(trim(a))
            if prev is not None:
                gap = 0.42 if prev != it["spk"] else 0.34
                add(np.zeros(int(SR * (gap + rng.uniform(-0.08, 0.10))), dtype=np.float32))
            add(a)
            prev = it["spk"]
    return np.concatenate(chunks), marks, title


def ff(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode:
        raise SystemExit(r.stderr[-2000:])
    return r


def loudnorm_to_wav(src, dst):
    ff(["ffmpeg", "-y", "-loglevel", "error", "-i", src, "-af",
        "highpass=f=70,loudnorm=I=-16:TP=-1.5:LRA=9", "-ar", str(SR), "-ac", "1", dst])


def cmd_assemble(args):
    os.makedirs(BUILD, exist_ok=True)
    os.makedirs(OUT, exist_ok=True)
    all_marks, offset, wavs, report = [], 0.0, [], []
    for i, f in enumerate(chapter_files(args.only)):
        base = os.path.splitext(os.path.basename(f))[0]
        a, marks, title = build_chapter(f)
        raw = os.path.join(BUILD, base + "_raw.wav")
        sf.write(raw, a, SR)
        norm = os.path.join(BUILD, base + ".wav")
        loudnorm_to_wav(raw, norm)
        dur = sf.info(norm).duration
        mp3 = os.path.join(OUT, base + ".mp3")
        ff(["ffmpeg", "-y", "-loglevel", "error", "-i", norm, "-c:a", "libmp3lame", "-b:a", "56k",
            "-ac", "1", "-metadata", f"title={title}", "-metadata", "artist=CQ Examen",
            "-metadata", "album=CQ Examen: preparación del examen de radioaficionado", mp3])
        wavs.append(norm)
        for (s, t, lvl) in marks:
            all_marks.append((offset + s, t, lvl))
        report.append((base, title, dur))
        offset += dur
        print(f"{base}: {dur/60:5.1f} min  {title}", flush=True)
    if args.only:
        return
    # episodio completo con capítulos
    lst = os.path.join(BUILD, "concat.txt")
    open(lst, "w").write("".join(f"file '{w}'\n" for w in wavs))
    full_wav = os.path.join(BUILD, "completo.wav")
    ff(["ffmpeg", "-y", "-loglevel", "error", "-f", "concat", "-safe", "0", "-i", lst, "-c", "copy", full_wav])
    total = sf.info(full_wav).duration
    meta = [";FFMETADATA1", "title=CQ Examen: curso completo para el examen de radioaficionado",
            "artist=CQ Examen", "album=CQ Examen"]
    chap = [(s, t) for (s, t, l) in all_marks if l == 1]
    for j, (s, t) in enumerate(chap):
        e = chap[j + 1][0] if j + 1 < len(chap) else total
        meta += ["[CHAPTER]", "TIMEBASE=1/1000", f"START={int(s*1000)}", f"END={int(e*1000)}", f"title={t}"]
    mf = os.path.join(BUILD, "meta.txt")
    open(mf, "w", encoding="utf-8").write("\n".join(meta) + "\n")
    full = os.path.join(OUT, "CQ_Examen_completo.mp3")
    ff(["ffmpeg", "-y", "-loglevel", "error", "-i", full_wav, "-i", mf, "-map_metadata", "1",
        "-c:a", "libmp3lame", "-b:a", "56k", "-ac", "1", "-id3v2_version", "3", full])
    print(f"TOTAL: {total/60:.1f} min -> {full} ({os.path.getsize(full)/1e6:.1f} MB)")
    json.dump({"total_s": total, "chapters": [(b, t, d) for b, t, d in report],
               "marks": all_marks}, open(os.path.join(OUT, "capitulos.json"), "w"), ensure_ascii=False, indent=1)


def cmd_stats(args):
    tot_w, tot_s, have = 0, 0.0, True
    for f in chapter_files(args.only):
        words = secs = 0
        miss = 0
        for it in parse_chapter(f):
            if it["kind"] == "say":
                words += len(it["text"].split())
                h, _ = cache_key(it["spk"], it["text"])
                w = os.path.join(CACHE, f"{h}.wav")
                if os.path.exists(w):
                    secs += sf.info(w).duration + 0.4
                else:
                    miss += 1
            elif it["kind"] == "pause":
                secs += it["secs"]
        est = words / 165 * 60
        print(f"{os.path.basename(f):32s} {words:6d} palabras  est {est/60:5.1f} min  real {secs/60:5.1f} min  (sin sintetizar: {miss})")
        tot_w += words
        tot_s += secs
    print(f"TOTAL {tot_w} palabras; audio sintetizado {tot_s/60:.1f} min")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["stats", "synth", "assemble"])
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--only", default=None)
    a = ap.parse_args()
    {"stats": cmd_stats, "synth": cmd_synth, "assemble": cmd_assemble}[a.cmd](a)
