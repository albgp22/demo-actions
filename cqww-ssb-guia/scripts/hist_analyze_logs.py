#!/usr/bin/env python3
"""
hist_analyze_logs.py - Analisis de logs Cabrillo publicos del CQ World Wide DX
Contest (pensado para SSB; tambien vale para CW con --mode cw).

Que hace
--------
1. Obtiene logs Cabrillo:
   * de un directorio local (--logs-dir), o
   * descargandolos de las paginas de logs publicos de cqww.com (--download),
     por indicativo (--calls / --calls-file) o recorriendo el indice del ano
     (--from-index) filtrado por prefijos o por entidad CTY.
2. Lee la cabecera (CATEGORY-OPERATOR, -ASSISTED, -BAND, -POWER, -OVERLAY,
   CLAIMED-SCORE...) y las lineas QSO:, y filtra por categoria (por defecto
   monooperador baja potencia todas las bandas, asistido o no).
3. Para cada log calcula, con las reglas de puntuacion del CQ WW y un fichero
   CTY (data/cty/cty_not1mm.json; coincidencia exacta de indicativo y despues
   prefijo mas largo; maneja /P /M /QRP, prefijos tipo EA8/ y CT3/, sufijos de
   ubicacion tipo /EA8, cambios de distrito /4 y /MM):
     - QSO por hora UTC (desde el inicio del concurso) y banda,
     - reparto por continente,
     - puntos por QSO y multiplicadores (zonas + paises por banda) con la
       hora del primer QSO que dio cada multiplicador,
     - puntuacion bruta recalculada (antes de la comprobacion de logs),
       tiempo de operacion (pausas >= 60 min, regla CQ WW) y mejor tasa 60 min.
4. Genera graficos PNG+SVG por log (tasa por hora apilada por banda, reparto
   por continente, multiplicadores acumulados), sus tablas CSV gemelas, un
   resumen por log (resumen_logs.csv) y estadisticas del conjunto
   (mediana y cuartiles de las puntuaciones calculadas y declaradas).
5. Opcional (--fetch-final-scores): consulta la API REST publica de cqww.com
   (https://cqww.com/api_reference.htm; ejemplo documentado
   https://cqww.com/api/get/score/ph/2020/k5zd) para guardar la puntuacion
   FINAL tras la comprobacion, junto a la bruta calculada y la declarada.

Limitaciones conocidas
----------------------
* La puntuacion calculada es BRUTA: no aplica las penalizaciones del
  comprobador (NIL, indicativos erroneos, etc.). La final solo la da cqww.com.
* La entidad se deduce con el CTY indicado (version actual, no la del ano del
  concurso); algun prefijo especial puede caer en otra entidad.
* Los QSO con estaciones /MM cuentan solo como multiplicador de zona; sus
  puntos se estiman por el continente aproximado de la zona recibida.
* El patron de URL de los logs publicos (por defecto
  https://cqww.com/publiclogs/{year}{mode}/{name}.log) no se ha podido
  comprobar desde el entorno donde se escribio el script: es configurable
  (--base-url, --name-style) y, con --from-index, se usan los enlaces reales.

Ejemplos
--------
  # logs ya descargados en una carpeta
  .venv/bin/python scripts/hist_analyze_logs.py --logs-dir logs/2024ph --year 2024 \
      --category so-low-any --out out/2024

  # descargar unos indicativos concretos (necesita Internet)
  .venv/bin/python scripts/hist_analyze_logs.py --download --year 2024 \
      --calls EA4XXX EA8YYY --out out/2024 --fetch-final-scores

  # recorrer el indice de logs publicos y quedarse con las entidades EA
  .venv/bin/python scripts/hist_analyze_logs.py --download --from-index --year 2024 \
      --index-entities "Spain,Balearic Islands,Canary Islands,Ceuta & Melilla" \
      --category so-low --out out/2024_ea_lp --delay 1.5

Requisitos: Python >= 3.9 y matplotlib (solo para los graficos).
"""
from __future__ import annotations

import argparse
import csv
import datetime as dt
import json
import re
import statistics
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from pathlib import Path

UTC = dt.timezone.utc
BANDS = [160, 80, 40, 20, 15, 10]
BAND_KHZ = {160: (1800, 2000), 80: (3500, 4000), 40: (7000, 7300),
            20: (14000, 14350), 15: (21000, 21450), 10: (28000, 29700)}
BAND_MHZ_DESIGNATOR = {1.8: 160, 3.5: 80, 7.0: 40, 14.0: 20, 21.0: 15, 28.0: 10}
CONTINENTS = ["EU", "NA", "AS", "AF", "SA", "OC"]
CONT_ES = {"EU": "Europa", "NA": "Norteamérica", "AS": "Asia", "AF": "África",
           "SA": "Sudamérica", "OC": "Oceanía", "MM": "Marítimo móvil", "??": "Desconocido"}
# Continente aproximado por zona CQ (solo para estimar puntos de estaciones /MM).
ZONE_CONT = {**{z: "NA" for z in range(1, 9)}, **{z: "SA" for z in range(9, 14)},
             **{z: "EU" for z in (14, 15, 16, 40)}, **{z: "AS" for z in range(17, 28)},
             **{z: "OC" for z in range(28, 33)}, **{z: "AF" for z in range(33, 40)}}

DEFAULT_BASE_URL = "https://cqww.com/publiclogs/{year}{mode}/"
API_SCORE_URL = "https://cqww.com/api/get/score/{mode}/{year}/{call}"
UA = {"User-Agent": "cqww-ssb-guia-hist/1.0 (analisis educativo de logs publicos; python urllib)"}

# Paleta categorica validada (skill dataviz, modo claro): el color sigue a la banda.
BAND_COLORS = {160: "#2a78d6", 80: "#eb6834", 40: "#1baf7a", 20: "#eda100",
               15: "#e87ba4", 10: "#008300"}
INK, INK2, MUTED, GRID, AXIS, SURF = "#0b0b0b", "#52514e", "#898781", "#e1e0d9", "#c3c2b7", "#fcfcfb"
SERIES = ["#2a78d6", "#eb6834", "#1baf7a"]


# --------------------------------------------------------------------------- CTY
@dataclass
class Entity:
    entity: str
    cq: int | None
    continent: str
    primary_pfx: str = ""
    mm: bool = False

    @property
    def key(self) -> str:
        return self.entity


MM_ENTITY = Entity("Maritime Mobile", None, "MM", "MM", mm=True)

# Sufijos que no indican ubicacion: se ignoran.
NONLOC_SUFFIXES = {"P", "M", "A", "B", "J", "QRP", "QRPP", "LH", "PM", "LGT"}
US_CALL = re.compile(r"^(?:[KNW][A-Z]?|A[A-L])\d")
CALL_RE = re.compile(r"^(?=.*[A-Z])(?=.*\d)[A-Z0-9/]{3,}$")


class Cty:
    """Resolucion indicativo -> entidad con un CTY en JSON (formato Not1MM).

    Claves con exact_match=true (o que empiezan por '=') son indicativos
    exactos; el resto son prefijos. Las claves con minusculas (p. ej. 'GM/s',
    'JW/b') son etiquetas internas de subentidades y no se usan como prefijo.
    """

    def __init__(self, path: str | Path):
        raw = json.loads(Path(path).read_text(encoding="utf-8"))
        self.version = raw.get("version", "?") if isinstance(raw, dict) else "?"
        self.exact: dict[str, dict] = {}
        self.prefix: dict[str, dict] = {}
        for k, v in raw.items():
            if not isinstance(v, dict):
                continue
            key = k.strip()
            if key.startswith("="):
                self.exact[key[1:].upper()] = v
            elif v.get("exact_match"):
                self.exact[key.upper()] = v
            elif key != key.upper():
                continue
            else:
                self.prefix[key] = v
        self.maxlen = max(len(k) for k in self.prefix)
        self._cache: dict[str, Entity | None] = {}

    @staticmethod
    def _ent(v: dict) -> Entity:
        return Entity(v["entity"], v.get("cq"), v.get("continent", "??"), v.get("primary_pfx", ""))

    def longest_prefix(self, s: str) -> Entity | None:
        for n in range(min(len(s), self.maxlen), 0, -1):
            v = self.prefix.get(s[:n])
            if v:
                return self._ent(v)
        return None

    def _base(self, call: str) -> Entity | None:
        if call in self.exact:
            return self._ent(self.exact[call])
        # Guantanamo: KG4 + 2 letras; KG4 + 3 letras es EE. UU.
        if re.fullmatch(r"KG4[A-Z]{3}", call):
            return self.longest_prefix("K")
        return self.longest_prefix(call)

    def _digit_suffix(self, base: str, digit: str) -> Entity | None:
        # W1ABC/4 sigue siendo EE. UU. (tambien KH6ABC/4, KL7ABC/4...)
        if US_CALL.match(base):
            return self.longest_prefix("K")
        m = re.match(r"^(\d?[A-Z]+)(\d+)([A-Z].*)$", base)
        if not m:
            return self._base(base)
        return self._base(m.group(1) + digit + m.group(3))

    def resolve(self, call: str) -> Entity | None:
        c = re.sub(r"[^A-Z0-9/]", "", (call or "").upper())
        if not c:
            return None
        if c in self._cache:
            return self._cache[c]
        ent = self._resolve(c)
        self._cache[c] = ent
        return ent

    def _resolve(self, c: str) -> Entity | None:
        if c in self.exact:
            return self._ent(self.exact[c])
        parts = [p for p in c.split("/") if p]
        if not parts:
            return None
        if len(parts) == 1:
            return self._base(parts[0])
        tail = parts[1:]
        if "MM" in tail:
            return MM_ENTITY
        if "AM" in tail:  # aeronautico: no cuenta como pais
            return None
        loc = [parts[0]] + [p for p in tail if p not in NONLOC_SUFFIXES]
        if len(loc) == 1:
            return self._base(loc[0])
        a, b = loc[0], loc[1]
        if b.isdigit() and len(b) == 1:
            return self._digit_suffix(a, b)
        # El trozo mas corto es el prefijo de ubicacion: EA8/DL1ABC, DL1ABC/EA8, CT3/EA4XXX.
        pfx, other = (a, b) if len(a) <= len(b) else (b, a)
        return self.longest_prefix(pfx) or self._base(other)


# ---------------------------------------------------------------- Cabrillo
@dataclass
class Qso:
    t: dt.datetime
    freq: float | None
    band: int | None
    mode: str
    mycall: str
    call: str
    sent: list
    rcvd: list
    zone: int | None
    tx: str | None
    line_no: int


@dataclass
class Log:
    path: Path
    header: dict = field(default_factory=dict)
    qsos: list = field(default_factory=list)
    bad_lines: list = field(default_factory=list)
    xqso: int = 0
    source_url: str = ""

    def h(self, tag: str, default: str = "") -> str:
        vals = self.header.get(tag.upper())
        return vals[0].strip() if vals else default

    @property
    def callsign(self) -> str:
        c = self.h("CALLSIGN")
        if not c and self.qsos:
            c = self.qsos[0].mycall
        return c.upper()


def freq_to_band(tok: str) -> tuple[float | None, int | None]:
    try:
        f = float(tok)
    except ValueError:
        return None, None
    if f < 1000:  # designador en MHz (1.8, 3.5, 7, 14, 21, 28)
        for mhz, band in BAND_MHZ_DESIGNATOR.items():
            if abs(f - mhz) < 0.6 or (band == 160 and 1.8 <= f <= 2.0):
                return f * 1000, band
        return f * 1000, None
    for band, (lo, hi) in BAND_KHZ.items():
        if lo <= f <= hi:
            return f, band
    return f, None


def parse_cabrillo(path: Path) -> Log:
    log = Log(path=path)
    text = path.read_bytes().decode("utf-8", "replace")
    for n, line in enumerate(text.splitlines(), 1):
        line = line.strip()
        if not line or ":" not in line:
            continue
        tag, _, val = line.partition(":")
        tag = tag.strip().upper()
        if tag == "QSO":
            q = _parse_qso(val.split(), n)
            if q:
                log.qsos.append(q)
            else:
                log.bad_lines.append(n)
        elif tag == "X-QSO":
            log.xqso += 1
        else:
            log.header.setdefault(tag, []).append(val.strip())
    return log


def _parse_qso(tok: list, n: int) -> Qso | None:
    if len(tok) < 7:
        return None
    freq, band = freq_to_band(tok[0])
    mode = tok[1].upper()
    date = tok[2].replace("/", "-")
    hhmm = tok[3].zfill(4)
    try:
        t = dt.datetime.strptime(f"{date} {hhmm}", "%Y-%m-%d %H%M").replace(tzinfo=UTC)
    except ValueError:
        return None
    rest = [x.upper() for x in tok[4:]]
    mycall = rest[0]
    j = next((i for i in range(1, len(rest)) if CALL_RE.match(rest[i]) and rest[i] != mycall), None)
    if j is None:
        j = next((i for i in range(1, len(rest)) if CALL_RE.match(rest[i])), None)
    if j is None:
        return None
    sent, call, rcvd = rest[1:j], rest[j], rest[j + 1:]
    tx = None
    if len(rcvd) >= 3 and rcvd[-1] in ("0", "1"):
        tx, rcvd = rcvd[-1], rcvd[:-1]
    ztok = rcvd[1] if len(rcvd) >= 2 else (rcvd[0] if rcvd else "")
    zone = int(ztok) if ztok.isdigit() and 1 <= int(ztok) <= 40 else None
    return Qso(t, freq, band, mode, mycall, call, sent, rcvd, zone, tx, n)


def category_of(log: Log) -> dict:
    cat = {"operator": log.h("CATEGORY-OPERATOR").upper(),
           "assisted": log.h("CATEGORY-ASSISTED").upper(),
           "band": log.h("CATEGORY-BAND").upper(),
           "power": log.h("CATEGORY-POWER").upper(),
           "overlay": log.h("CATEGORY-OVERLAY").upper(),
           "transmitter": log.h("CATEGORY-TRANSMITTER").upper(),
           "mode": log.h("CATEGORY-MODE").upper()}
    v2 = log.h("CATEGORY").upper().split()  # Cabrillo 2.0: "SINGLE-OP-ASSISTED ALL LOW"
    if v2 and not cat["operator"]:
        op = v2[0]
        cat["operator"] = ("SINGLE-OP" if op.startswith("SINGLE-OP") else
                           "MULTI-OP" if op.startswith("MULTI") else op)
        if "ASSISTED" in op and not cat["assisted"]:
            cat["assisted"] = "ASSISTED"
        for x in v2[1:]:
            if x in ("ALL", "160M", "80M", "40M", "20M", "15M", "10M") and not cat["band"]:
                cat["band"] = x
            if x in ("HIGH", "LOW", "QRP") and not cat["power"]:
                cat["power"] = x
    if not cat["assisted"] and cat["operator"] == "SINGLE-OP":
        cat["assisted"] = "NON-ASSISTED"
    return cat


def category_label(cat: dict) -> str:
    if cat["operator"] != "SINGLE-OP":
        return cat["operator"] or "?"
    a = "SOA" if cat["assisted"] == "ASSISTED" else "SO"
    return f"{a} {cat['power'] or '?'} {cat['band'] or '?'}" + (f" +{cat['overlay']}" if cat["overlay"] else "")


def matches_filter(cat: dict, which: str, band: str, overlay: str | None) -> bool:
    if overlay and cat["overlay"] != overlay.upper():
        return False
    if which == "any":
        return True
    if cat["operator"] != "SINGLE-OP" or cat["power"] != "LOW":
        return False
    if band.lower() != "any" and (cat["band"] or "ALL") != band.upper():
        return False
    if which == "so-low":
        return cat["assisted"] != "ASSISTED"
    if which == "so-low-assisted":
        return cat["assisted"] == "ASSISTED"
    return True  # so-low-any


# ---------------------------------------------------------------- analisis
def contest_start(year: int, mode: str) -> dt.datetime:
    month = 10 if mode == "ph" else 11
    nxt = dt.date(year + (month == 12), month % 12 + 1, 1)
    last = nxt - dt.timedelta(days=1)
    last_sunday = last - dt.timedelta(days=(last.weekday() - 6) % 7)
    sat = last_sunday - dt.timedelta(days=1)
    return dt.datetime(sat.year, sat.month, sat.day, tzinfo=UTC)


def qso_points(me: Entity | None, them: Entity | None, zone: int | None) -> int:
    """Reglas CQ WW: otro continente 3; mismo continente y otro pais 1 (2 entre
    estaciones de Norteamerica); mismo pais 0."""
    if me is None or them is None:
        return 0
    if them.mm:
        cont = ZONE_CONT.get(zone or 0)
        if cont is None:
            return 0
        return 3 if cont != me.continent else (2 if cont == "NA" else 1)
    if them.entity == me.entity:
        return 0
    if them.continent != me.continent:
        return 3
    return 2 if me.continent == "NA" else 1


def analyze(log: Log, cty: Cty, mode: str, year: int | None = None) -> dict:
    qsos = sorted(log.qsos, key=lambda q: q.t)
    if not qsos:
        return {"call": log.callsign, "error": "sin QSO"}
    year = year or qsos[0].t.year
    start = contest_start(year, mode)
    me = cty.resolve(log.callsign)
    seen = set()
    zones = {b: {} for b in BANDS}
    ctrys = {b: {} for b in BANDS}
    rows, unknown, outside = [], Counter(), 0
    rate = Counter()
    cont_total, cont_band = Counter(), defaultdict(Counter)
    pts_band, qso_band, dup_band = Counter(), Counter(), Counter()
    cum = []  # (minutos, zonas, paises)
    nz = nc = 0
    for q in qsos:
        ent = cty.resolve(q.call)
        if ent is None:
            unknown[q.call] += 1
        key = (q.call, q.band)
        dupe = key in seen
        seen.add(key)
        zone = q.zone if q.zone else (ent.cq if ent else None)
        hour = int((q.t - start).total_seconds() // 3600)
        if not 0 <= hour < 48:
            outside += 1
        pts = 0 if (dupe or q.band is None) else qso_points(me, ent, zone)
        new_z = new_c = False
        if q.band in BANDS and not dupe:
            qso_band[q.band] += 1
            pts_band[q.band] += pts
            if zone and zone not in zones[q.band]:
                zones[q.band][zone] = (q.t, q.call)
                new_z = True
                nz += 1
            if ent is not None and not ent.mm and ent.entity not in ctrys[q.band]:
                ctrys[q.band][ent.entity] = (q.t, q.call)
                new_c = True
                nc += 1
            cont = ent.continent if ent else "??"
            cont_total[cont] += 1
            cont_band[q.band][cont] += 1
            if 0 <= hour < 48:
                rate[(hour, q.band)] += 1
            if new_z or new_c:
                cum.append(((q.t - start).total_seconds() / 60.0, nz, nc))
        elif q.band in BANDS:
            dup_band[q.band] += 1
        rows.append({"fecha_utc": q.t.strftime("%Y-%m-%d %H:%M"), "hora_concurso": hour,
                     "banda": q.band or "", "frecuencia_khz": q.freq or "", "modo": q.mode,
                     "indicativo": q.call, "zona": zone or "", "entidad": ent.entity if ent else "",
                     "continente": ent.continent if ent else "??", "puntos": pts,
                     "duplicado": int(dupe), "nuevo_mult_zona": int(new_z), "nuevo_mult_pais": int(new_c)})
    total_pts = sum(pts_band.values())
    zsum = sum(len(v) for v in zones.values())
    csum = sum(len(v) for v in ctrys.values())
    valid = sum(qso_band.values())
    times = [q.t for q in qsos if q.band in BANDS]
    op_sec = sum(g for g in ((b - a).total_seconds() for a, b in zip(times, times[1:])) if g < 3600)
    best60, i = 0, 0
    for jdx in range(len(times)):
        while (times[jdx] - times[i]).total_seconds() >= 3600:
            i += 1
        best60 = max(best60, jdx - i + 1)
    cat = category_of(log)
    claimed = re.sub(r"[^\d]", "", log.h("CLAIMED-SCORE"))
    res = {
        "call": log.callsign, "file": str(log.path), "source_url": log.source_url,
        "year": year, "mode": mode, "contest_start_utc": start.isoformat(),
        "my_entity": me.entity if me else "?", "my_continent": me.continent if me else "?",
        "category": cat, "category_label": category_label(cat),
        "operators": log.h("OPERATORS"), "created_by": log.h("CREATED-BY"),
        "claimed_score": int(claimed) if claimed else None,
        "qso_lines": len(qsos), "qsos_valid": valid, "dupes": sum(dup_band.values()),
        "x_qso_lines": log.xqso, "bad_lines": len(log.bad_lines), "outside_window": outside,
        "qso_points": total_pts, "zones": zsum, "countries": csum, "mults": zsum + csum,
        "score_computed_raw": total_pts * (zsum + csum),
        "op_hours": round(op_sec / 3600.0, 1), "best_60min": best60,
        "per_band": {b: {"qsos": qso_band[b], "dupes": dup_band[b], "points": pts_band[b],
                         "zones": len(zones[b]), "countries": len(ctrys[b])} for b in BANDS},
        "continents": {c: cont_total[c] for c in CONTINENTS + ["MM", "??"] if cont_total[c]},
        "continents_by_band": {b: dict(cont_band[b]) for b in BANDS if cont_band[b]},
        "unknown_calls": dict(unknown.most_common(50)),
        "cty_version": cty.version,
        "synthetic": bool(log.header.get("X-SYNTHETIC")) or any("SYNTHETIC" in v.upper() for v in log.header.get("SOAPBOX", [])),
        "_rows": rows, "_rate": rate, "_cum": cum, "_zones": zones, "_ctrys": ctrys,
    }
    return res


# ---------------------------------------------------------------- salidas
def fmt_int(n: int) -> str:
    return f"{n:,}".replace(",", ".")


def write_csv(path: Path, rows: list, cols: list):
    with path.open("w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=cols, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)


def safe_name(call: str) -> str:
    return re.sub(r"[^A-Za-z0-9]+", "-", call).strip("-") or "SIN-INDICATIVO"


def write_tables(res: dict, d: Path):
    write_csv(d / "qsos_enriquecidos.csv", res["_rows"], list(res["_rows"][0].keys()) if res["_rows"] else ["vacío"])
    start = dt.datetime.fromisoformat(res["contest_start_utc"])
    rate_rows = []
    for h in range(48):
        t = start + dt.timedelta(hours=h)
        r = {"hora_concurso": h, "inicio_utc": t.strftime("%Y-%m-%d %H:%M")}
        for b in BANDS:
            r[f"{b}m"] = res["_rate"].get((h, b), 0)
        r["total"] = sum(r[f"{b}m"] for b in BANDS)
        rate_rows.append(r)
    write_csv(d / "tasa_por_hora_banda.csv", rate_rows, list(rate_rows[0].keys()))
    tot = sum(res["continents"].values()) or 1
    write_csv(d / "continentes.csv",
              [{"continente": c, "nombre": CONT_ES.get(c, c), "qsos": n, "porcentaje": round(100 * n / tot, 1)}
               for c, n in sorted(res["continents"].items(), key=lambda kv: -kv[1])],
              ["continente", "nombre", "qsos", "porcentaje"])
    cb = [{"banda": b, **{c: res["continents_by_band"].get(b, {}).get(c, 0) for c in CONTINENTS + ["MM", "??"]}}
          for b in BANDS]
    write_csv(d / "continentes_por_banda.csv", cb, ["banda"] + CONTINENTS + ["MM", "??"])
    mrows = []
    for b in BANDS:
        for z, (t, c) in sorted(res["_zones"][b].items(), key=lambda kv: kv[1][0]):
            mrows.append({"banda": b, "tipo": "zona", "multiplicador": z,
                          "primer_qso_utc": t.strftime("%Y-%m-%d %H:%M"), "indicativo": c})
        for e, (t, c) in sorted(res["_ctrys"][b].items(), key=lambda kv: kv[1][0]):
            mrows.append({"banda": b, "tipo": "pais", "multiplicador": e,
                          "primer_qso_utc": t.strftime("%Y-%m-%d %H:%M"), "indicativo": c})
    write_csv(d / "multiplicadores.csv", mrows, ["banda", "tipo", "multiplicador", "primer_qso_utc", "indicativo"])
    write_csv(d / "multiplicadores_acumulados.csv",
              [{"minuto_concurso": round(m, 1), "zonas": z, "paises": c, "total": z + c} for m, z, c in res["_cum"]],
              ["minuto_concurso", "zonas", "paises", "total"])
    clean = {k: v for k, v in res.items() if not k.startswith("_")}
    (d / "resumen.json").write_text(json.dumps(clean, ensure_ascii=False, indent=2, default=str), encoding="utf-8")


def _style(ax):
    ax.set_facecolor(SURF)
    for s in ("top", "right", "left"):
        ax.spines[s].set_visible(False)
    ax.spines["bottom"].set_color(AXIS)
    ax.tick_params(colors=MUTED, labelcolor=INK2, length=0)
    ax.grid(axis="y", color=GRID, linewidth=0.8)
    ax.set_axisbelow(True)


def _hour_axis(ax, start: dt.datetime, binned: bool = True):
    """Eje X de 48 h. binned=True: barras centradas en cada hora; False: tiempo continuo."""
    ticks = list(range(0, 46 if binned else 49, 3))
    ax.set_xticks(ticks, [f"{(start + dt.timedelta(hours=h)).hour:02d}" for h in ticks])
    ax.set_xlim(-0.6, 47.6) if binned else ax.set_xlim(0, 48)
    off = -0.5 if binned else 0.0
    ax.axvline(24 + off, color=AXIS, linewidth=1)
    for x, lab in ((12 + off, "sábado"), (36 + off, "domingo")):
        ax.text(x, -0.13, lab, transform=ax.get_xaxis_transform(), ha="center", va="top", fontsize=9, color=INK2)
    ax.set_xlabel("hora UTC", color=INK2, labelpad=18)


def _save(fig, stem: Path, formats):
    for ext in formats:
        fig.savefig(f"{stem}.{ext}", dpi=200 if ext == "png" else None, facecolor=SURF)


def make_charts(res: dict, d: Path, formats=("png", "svg")):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    start = dt.datetime.fromisoformat(res["contest_start_utc"])
    modo = "SSB" if res["mode"] == "ph" else "CW"
    call = res["call"]
    synth = " · LOG SINTÉTICO DE PRUEBA" if res.get("synthetic") else ""

    # 1) tasa por hora apilada por banda
    fig, ax = plt.subplots(figsize=(10, 4.4), dpi=100)
    fig.patch.set_facecolor(SURF)
    _style(ax)
    bottom = [0] * 48
    for b in BANDS:
        vals = [res["_rate"].get((h, b), 0) for h in range(48)]
        if not any(vals):
            continue
        ax.bar(range(48), vals, bottom=bottom, width=0.78, color=BAND_COLORS[b],
               edgecolor=SURF, linewidth=0.8, label=f"{b} m")
        bottom = [x + y for x, y in zip(bottom, vals)]
    ax.set_ylabel("QSO por hora", color=INK2)
    _hour_axis(ax, start)
    ax.legend(frameon=False, ncol=6, loc="upper left", bbox_to_anchor=(0, 1.02), fontsize=9, labelcolor=INK2,
              handlelength=1.0, columnspacing=1.2)
    ax.set_ylim(0, max(bottom + [1]) * 1.18)
    fig.suptitle(f"{call}: QSO por hora y banda, CQ WW {modo} {res['year']}", x=0.01, ha="left",
                 color=INK, fontsize=12)
    fig.text(0.01, 0.905, f"{fmt_int(res['qsos_valid'])} QSO válidos · mejor tasa {res['best_60min']} QSO en 60 min · "
             f"tiempo de operación ≈ {str(res['op_hours']).replace('.', ',')} h · {res['category_label']}{synth}",
             fontsize=8.5, color=INK2)
    fig.subplots_adjust(left=0.07, right=0.99, top=0.84, bottom=0.2)
    _save(fig, d / "tasa_por_hora", formats)
    plt.close(fig)

    # 2) reparto por continente (una sola serie: un solo color)
    items = sorted(res["continents"].items(), key=lambda kv: kv[1])
    tot = sum(n for _, n in items) or 1
    fig, ax = plt.subplots(figsize=(7, 0.45 * max(len(items), 3) + 1.3), dpi=100)
    fig.patch.set_facecolor(SURF)
    _style(ax)
    ax.grid(axis="y", visible=False)
    ax.grid(axis="x", color=GRID, linewidth=0.8)
    ys = range(len(items))
    ax.barh(list(ys), [n for _, n in items], height=0.55, color=SERIES[0], edgecolor=SURF, linewidth=0.8)
    ax.set_yticks(list(ys), [CONT_ES.get(c, c) for c, _ in items])
    xmax = max([n for _, n in items] + [1])
    for y, (_, n) in zip(ys, items):
        ax.text(n + xmax * 0.01, y, f"{fmt_int(n)} ({str(round(100 * n / tot, 1)).replace('.', ',')} %)",
                va="center", fontsize=8.5, color=INK2)
    ax.set_xlim(0, xmax * 1.25)
    ax.set_xlabel("QSO válidos (sin duplicados)", color=INK2)
    fig.suptitle(f"{call}: QSO por continente, CQ WW {modo} {res['year']}", x=0.01, ha="left", color=INK, fontsize=12)
    fig.text(0.01, 0.885, f"{fmt_int(tot)} QSO válidos · {res['category_label']}{synth}", fontsize=8.5, color=INK2)
    fig.subplots_adjust(left=0.2, right=0.98, top=0.84, bottom=0.18)
    _save(fig, d / "continentes", formats)
    plt.close(fig)

    # 3) multiplicadores acumulados
    fig, ax = plt.subplots(figsize=(10, 4.2), dpi=100)
    fig.patch.set_facecolor(SURF)
    _style(ax)
    cum = res["_cum"]
    if cum:
        xs = [0.0] + [m / 60.0 for m, _, _ in cum] + [48.0]
        series = (("Zonas", [0] + [z for _, z, _ in cum]), ("Países", [0] + [c for _, _, c in cum]),
                  ("Total", [0] + [z + c for _, z, c in cum]))
        for (lab, ys_), col in zip(series, SERIES):
            ys_ = ys_ + [ys_[-1]]
            ax.step(xs, ys_, where="post", color=col, linewidth=2, label=lab, solid_joinstyle="round")
            ax.text(48.3, ys_[-1], f"{lab} {ys_[-1]}", va="center", fontsize=8.5, color=INK2)
    ax.set_ylabel("multiplicadores acumulados", color=INK2)
    _hour_axis(ax, start, binned=False)
    ax.set_xlim(0, 52.5)
    ax.legend(frameon=False, ncol=3, loc="upper left", fontsize=9, labelcolor=INK2)
    fig.suptitle(f"{call}: multiplicadores (zonas + países por banda), CQ WW {modo} {res['year']}",
                 x=0.01, ha="left", color=INK, fontsize=12)
    fig.text(0.01, 0.9, f"puntuación bruta recalculada {fmt_int(res['score_computed_raw'])} = "
             f"{fmt_int(res['qso_points'])} puntos × {res['mults']} multiplicadores{synth}", fontsize=8.5, color=INK2)
    fig.subplots_adjust(left=0.07, right=0.99, top=0.84, bottom=0.2)
    _save(fig, d / "multiplicadores_acumulados", formats)
    plt.close(fig)


# ---------------------------------------------------------------- red
def http_get(url: str, timeout: float = 60, retries: int = 2) -> bytes | None:
    for attempt in range(retries + 1):
        try:
            req = urllib.request.Request(url, headers=UA)
            with urllib.request.urlopen(req, timeout=timeout) as r:
                return r.read()
        except urllib.error.HTTPError as e:
            if e.code in (404, 410):
                return None
            if e.code in (401, 403, 407) or attempt == retries:
                print(f"[aviso] {url}: HTTP {e.code}", file=sys.stderr)
                return None
        except Exception as e:  # red no disponible, timeout...
            if attempt == retries:
                print(f"[aviso] {url}: {e}", file=sys.stderr)
                return None
        time.sleep(2 * (attempt + 1))
    return None


def name_variants(call: str, style: str) -> list:
    lc = call.lower()
    variants = {"dash": lc.replace("/", "-"), "underscore": lc.replace("/", "_"), "plain": lc.replace("/", "")}
    order = [style] + [k for k in ("dash", "underscore", "plain") if k != style]
    out = []
    for k in order:
        if variants[k] not in out:
            out.append(variants[k])
    return out


def read_index(base: str) -> dict:
    """Devuelve {nombre_fichero: url_absoluta} de los enlaces *.log del indice."""
    blob = http_get(base)
    if not blob:
        return {}
    html = blob.decode("utf-8", "replace")
    links = {}
    for href in re.findall(r"""href\s*=\s*["']([^"']+?\.(?:log|cbr|txt))["']""", html, flags=re.I):
        url = urllib.parse.urljoin(base, href)
        links[Path(urllib.parse.urlparse(url).path).name] = url
    return links


def download_logs(args, cty: Cty) -> list:
    base = args.base_url.format(year=args.year, mode=args.mode)
    cache = Path(args.cache_dir or (Path(args.out) / "logs_cache" / f"{args.year}{args.mode}"))
    cache.mkdir(parents=True, exist_ok=True)
    targets = []  # (indicativo_o_nombre, [urls])
    if args.from_index:
        links = read_index(base)
        print(f"Índice {base}: {len(links)} enlaces a logs")
        prefixes = [p.strip().upper() for p in (args.index_prefixes or "").split(",") if p.strip()]
        ents = {e.strip() for e in (args.index_entities or "").split(",") if e.strip()}
        for name, url in sorted(links.items()):
            call = Path(name).stem.upper().replace("-", "/")
            if prefixes and not any(call.startswith(p) for p in prefixes):
                continue
            if ents:
                e = cty.resolve(call)
                if not e or e.entity not in ents:
                    continue
            targets.append((call, [url]))
            if args.max_logs and len(targets) >= args.max_logs:
                break
    for call in calls_from_args(args):
        targets.append((call, [base + v + ".log" for v in name_variants(call, args.name_style)]))
    paths = []
    for call, urls in targets:
        dest = cache / (safe_name(call).lower() + ".log")
        if dest.exists() and dest.stat().st_size > 0:
            paths.append((dest, urls[0]))
            continue
        for url in urls:
            blob = http_get(url)
            time.sleep(args.delay)
            if blob and b"QSO:" in blob.upper():
                dest.write_bytes(blob)
                paths.append((dest, url))
                print(f"descargado {call} <- {url}")
                break
        else:
            print(f"[aviso] no encontrado el log público de {call} (probadas: {', '.join(urls)})", file=sys.stderr)
    return paths


def fetch_final_score(call: str, year: int, mode: str, template: str = API_SCORE_URL) -> dict:
    url = template.format(mode=mode, year=year, call=urllib.parse.quote(call.lower(), safe=""))
    blob = http_get(url, timeout=30, retries=1)
    if not blob:
        return {"api_url": url, "error": "sin respuesta"}
    try:
        data = json.loads(blob.decode("utf-8", "replace"))
    except ValueError:
        return {"api_url": url, "error": "respuesta no JSON", "raw": blob[:300].decode("utf-8", "replace")}
    found = {}

    def walk(o):
        if isinstance(o, dict):
            for k, v in o.items():
                kl = k.lower()
                if isinstance(v, (int, float, str)) and any(s in kl for s in ("score", "qso", "zone", "countr", "categ", "mult")):
                    found.setdefault(kl, v)
                walk(v)
        elif isinstance(o, list):
            for v in o:
                walk(v)
    walk(data)
    return {"api_url": url, "fields": found, "raw": data}


# ---------------------------------------------------------------- principal
def calls_from_args(args) -> list:
    calls = [c.upper() for c in (args.calls or [])]
    if args.calls_file:
        for line in Path(args.calls_file).read_text(encoding="utf-8").splitlines():
            line = line.split("#")[0].strip()
            if line:
                calls.append(line.split()[0].upper())
    return calls


def local_logs(args) -> list:
    d = Path(args.logs_dir)
    files = sorted(p for p in d.iterdir() if p.is_file() and p.suffix.lower() in (".log", ".cbr", ".txt", ".cabrillo"))
    wanted = {safe_name(c).lower() for c in calls_from_args(args)}
    if wanted:
        files = [p for p in files if p.stem.lower() in wanted or safe_name(p.stem).lower() in wanted]
    return [(p, "") for p in files]


def stats(values: list) -> dict:
    v = sorted(x for x in values if x is not None)
    if not v:
        return {"n": 0}
    q = statistics.quantiles(v, n=4) if len(v) >= 2 else [v[0], v[0], v[0]]
    return {"n": len(v), "min": v[0], "p25": q[0], "mediana": statistics.median(v), "p75": q[2], "max": v[-1]}


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--year", type=int, help="año del concurso (si no, se deduce del primer QSO)")
    ap.add_argument("--mode", choices=["ph", "cw"], default="ph", help="ph = SSB (por defecto), cw = CW")
    ap.add_argument("--calls", nargs="*", help="indicativos a analizar/descargar")
    ap.add_argument("--calls-file", help="fichero con un indicativo por línea (# comentarios)")
    ap.add_argument("--logs-dir", help="directorio con logs Cabrillo ya descargados")
    ap.add_argument("--download", action="store_true", help="descargar logs públicos de cqww.com")
    ap.add_argument("--from-index", action="store_true", help="recorrer el índice de logs públicos del año")
    ap.add_argument("--index-prefixes", help="con --from-index: prefijos separados por comas (p. ej. EA,EB,EC,ED)")
    ap.add_argument("--index-entities", help="con --from-index: entidades CTY separadas por comas")
    ap.add_argument("--max-logs", type=int, default=0, help="límite de logs a descargar desde el índice")
    ap.add_argument("--base-url", default=DEFAULT_BASE_URL, help="plantilla del directorio de logs públicos")
    ap.add_argument("--name-style", choices=["dash", "underscore", "plain"], default="dash",
                    help="cómo se convierte '/' en el nombre del fichero (se prueban los tres)")
    ap.add_argument("--cache-dir", help="carpeta donde guardar los logs descargados")
    ap.add_argument("--delay", type=float, default=1.0, help="segundos de espera entre descargas")
    ap.add_argument("--cty", default=str(Path(__file__).resolve().parent.parent / "data" / "cty" / "cty_not1mm.json"))
    ap.add_argument("--category", choices=["so-low", "so-low-assisted", "so-low-any", "any"], default="so-low-any")
    ap.add_argument("--band", default="ALL", help="CATEGORY-BAND exigida (ALL por defecto; 'any' = todas)")
    ap.add_argument("--overlay", help="exigir CATEGORY-OVERLAY (p. ej. ROOKIE)")
    ap.add_argument("--fetch-final-scores", action="store_true", help="consultar la API de cqww.com")
    ap.add_argument("--api-url", default=API_SCORE_URL, help="plantilla de la API de puntuaciones finales")
    ap.add_argument("--formats", default="png,svg", help="formatos de gráfico separados por comas")
    ap.add_argument("--no-charts", action="store_true")
    ap.add_argument("--out", default="out_hist_logs", help="carpeta de salida")
    args = ap.parse_args(argv)

    if not args.logs_dir and not args.download:
        ap.error("indica --logs-dir o --download")
    if args.download and not args.year:
        ap.error("--download necesita --year")
    cty = Cty(args.cty)
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    sources = local_logs(args) if args.logs_dir else []
    if args.download:
        sources += download_logs(args, cty)
    if not sources:
        sys.exit("No hay logs que analizar.")

    summary, skipped = [], []
    formats = [f.strip() for f in args.formats.split(",") if f.strip()]
    for path, url in sources:
        log = parse_cabrillo(path)
        log.source_url = url
        cat = category_of(log)
        if not matches_filter(cat, args.category, args.band, args.overlay):
            skipped.append((log.callsign, category_label(cat)))
            continue
        res = analyze(log, cty, args.mode, args.year)
        if "error" in res:
            skipped.append((log.callsign, res["error"]))
            continue
        if args.fetch_final_scores:
            res["final_api"] = fetch_final_score(res["call"], res["year"], args.mode, args.api_url)
            time.sleep(args.delay)
        d = out / safe_name(res["call"])
        d.mkdir(parents=True, exist_ok=True)
        write_tables(res, d)
        if not args.no_charts:
            make_charts(res, d, formats)
        row = {k: res[k] for k in ("call", "category_label", "my_entity", "operators", "claimed_score",
                                   "qsos_valid", "dupes", "qso_points", "zones", "countries", "mults",
                                   "score_computed_raw", "op_hours", "best_60min", "outside_window",
                                   "source_url", "file")}
        row["overlay"] = res["category"]["overlay"]
        row["synthetic"] = int(res["synthetic"])
        tot = sum(res["continents"].values()) or 1
        for c in CONTINENTS:
            row[f"pct_{c}"] = round(100 * res["continents"].get(c, 0) / tot, 1)
        for b in BANDS:
            pb = res["per_band"][b]
            row[f"q{b}"], row[f"z{b}"], row[f"c{b}"] = pb["qsos"], pb["zones"], pb["countries"]
        fa = res.get("final_api", {}).get("fields", {})
        row["final_score_api"] = next((v for k, v in fa.items() if k in ("score", "final_score", "finalscore")), "")
        row["unknown_calls"] = len(res["unknown_calls"])
        summary.append(row)
        print(f"{res['call']:<12} {res['category_label']:<22} QSO {res['qsos_valid']:>5}  pts {res['qso_points']:>6}  "
              f"mult {res['mults']:>4}  bruta {fmt_int(res['score_computed_raw']):>11}  "
              f"declarada {fmt_int(res['claimed_score']) if res['claimed_score'] else '-':>11}")
    if summary:
        cols = list(summary[0].keys())
        write_csv(out / "resumen_logs.csv", summary, cols)
        groups = defaultdict(list)
        for r in summary:
            groups[r["category_label"]].append(r)
        st = {"todas": {"calculada_bruta": stats([r["score_computed_raw"] for r in summary]),
                        "declarada": stats([r["claimed_score"] for r in summary]),
                        "qsos": stats([r["qsos_valid"] for r in summary])}}
        for g, rs in groups.items():
            st[g] = {"calculada_bruta": stats([r["score_computed_raw"] for r in rs]),
                     "declarada": stats([r["claimed_score"] for r in rs]),
                     "qsos": stats([r["qsos_valid"] for r in rs])}
        (out / "estadisticas.json").write_text(json.dumps(st, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"\n{len(summary)} logs analizados -> {out}/resumen_logs.csv, {out}/estadisticas.json")
        print("Mediana puntuación bruta calculada:", st["todas"]["calculada_bruta"].get("mediana"))
    if skipped:
        print(f"{len(skipped)} logs descartados por el filtro de categoría: " +
              ", ".join(f"{c} ({why})" for c, why in skipped[:20]))


if __name__ == "__main__":
    main()
