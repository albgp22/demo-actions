#!/usr/bin/env python3
"""Genera audio/transcripcion.md a partir de los guiones y de audio/capitulos.json
(tiempos de cada sección en el episodio completo)."""
import json, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from synth import parse_chapter, chapter_files, SPEAKERS  # noqa: E402


def ts(sec):
    sec = int(sec)
    h, r = divmod(sec, 3600)
    m, s = divmod(r, 60)
    return f"{h}:{m:02d}:{s:02d}" if h else f"{m:02d}:{s:02d}"


def main():
    meta = json.load(open(os.path.join(ROOT, "audio", "capitulos.json"), encoding="utf-8"))
    marks = iter(meta["marks"])  # (segundo, título, nivel) en el orden de aparición
    out = ["# CQ Examen — transcripción completa",
           "",
           f"Duración total: {ts(meta['total_s'])}. Locutoras/es sintéticos: **Lucía** (profesora) y **Pablo** (aspirante).",
           "Las marcas de tiempo corresponden al archivo `CQ_Examen_completo.mp3`.",
           ""]
    for f in chapter_files():
        for it in parse_chapter(f):
            k = it["kind"]
            if k in ("chapter", "section"):
                t, title, lvl = next(marks)
                out += ["", ("## " if lvl == 1 else "### ") + f"{title}  `[{ts(t)}]`", ""]
            elif k == "say":
                out.append(f"**{SPEAKERS[it['spk']]['name']}:** {it['text']}")
                out.append("")
            elif k == "pause" and it["secs"] >= 3:
                out += [f"*(pausa de {int(it['secs'])} s para pensar la respuesta)*", ""]
    open(os.path.join(ROOT, "audio", "transcripcion.md"), "w", encoding="utf-8").write("\n".join(out))
    print("transcripcion.md escrita")


if __name__ == "__main__":
    main()
