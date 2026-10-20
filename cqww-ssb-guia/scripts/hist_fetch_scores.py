#!/usr/bin/env python3
"""
hist_fetch_scores.py - Descarga puntuaciones FINALES de la base de datos de
cqww.com (paginas "CQ WW - Scores" y "Overlay Category Scores") filtradas por
ano, entidad (dx) y categoria, y calcula estadisticas (mediana, cuartiles).

Sirve para responder "que puntuacion hace una estacion EA tipica en baja
potencia", algo que no se puede sacar de los PDF de resultados.

Patrones de URL (deducidos de paginas de cqww.com indexadas por buscadores;
POR VERIFICAR en un navegador antes de confiar en ellos):
  https://cqww.com/scoresph.htm?page=1&yr=2024&dx=EA&cat=SL+ALL&order=score&size=100
  https://cqww.com/scorescw.htm?...                        (CW)
  https://cqww.com/overlayscores.htm?page=1&mode=ph&yr=2024&dx=EA&cat=L&over=ROOKIE
Codigos de categoria observados: "SL ALL" (SO LOW ALL), "AL ALL" (asistido
LOW ALL, deducido), "AQ 15M"...; en overlays, cat=L/H (potencia).
Las filas observadas tienen la forma:
  puesto | indicativo | dx | ano | categoria | puntos | QSO | zonas | paises | horas

Ejemplos:
  .venv/bin/python scripts/hist_fetch_scores.py --years 2022 2023 2024 2025 \
      --dx EA EA6 EA8 EA9 --cats "SL ALL" "AL ALL" --out out/scores_ea.csv
  .venv/bin/python scripts/hist_fetch_scores.py --years 2025 --dx EA --overlay ROOKIE \
      --overlay-cats L --out out/rookies_ea.csv
Solo biblioteca estandar.
"""
from __future__ import annotations

import argparse
import csv
import json
import re
import statistics
import sys
import time
import urllib.parse
import urllib.request
from html.parser import HTMLParser
from pathlib import Path

UA = {"User-Agent": "cqww-ssb-guia-hist/1.0 (consulta educativa de resultados; python urllib)"}
SCORES_URL = "https://cqww.com/scores{mode}.htm?page={page}&yr={year}&dx={dx}&cat={cat}&order=score&size=100"
OVERLAY_URL = ("https://cqww.com/overlayscores.htm?page={page}&mode={mode}&yr={year}&dx={dx}"
               "&cat={cat}&over={over}&order=score&size=100")


class TableParser(HTMLParser):
    """Extrae todas las filas <tr> como listas de texto de sus celdas."""

    def __init__(self):
        super().__init__()
        self.rows, self._row, self._cell = [], None, None

    def handle_starttag(self, tag, attrs):
        if tag == "tr":
            self._row = []
        elif tag in ("td", "th") and self._row is not None:
            self._cell = []

    def handle_endtag(self, tag):
        if tag in ("td", "th") and self._row is not None and self._cell is not None:
            self._row.append(" ".join("".join(self._cell).split()))
            self._cell = None
        elif tag == "tr" and self._row is not None:
            if self._row:
                self.rows.append(self._row)
            self._row = None

    def handle_data(self, data):
        if self._cell is not None:
            self._cell.append(data)


def to_int(s: str):
    s = re.sub(r"[^\d]", "", s or "")
    return int(s) if s else None


def parse_rows(html: str, year: int) -> list:
    p = TableParser()
    p.feed(html)
    header, out = None, []
    for cells in p.rows:
        low = [c.lower() for c in cells]
        if any(h in low for h in ("call", "callsign", "indicativo")) and any("score" in h for h in low):
            header = low
            continue
        if str(year) not in cells:
            continue
        if header and len(header) == len(cells):
            m = dict(zip(header, cells))

            def g(*keys):
                for key in keys:  # primero coincidencia exacta, luego subcadena
                    if key in m:
                        return m[key]
                for key in keys:
                    for k in m:
                        if key in k:
                            return m[k]
                return ""
            row = {"rango": g("rank", "#", "place", "pos"), "indicativo": g("call", "callsign"),
                   "entidad": g("dx", "country", "entity", "pfx"), "categoria": g("category", "cat"),
                   "puntuacion": g("score"), "qsos": g("qsos", "qso"), "zonas": g("zones", "zone"),
                   "paises": g("countries", "ctys", "ctry", "dxcc"), "horas": g("hours", "hour", "time")}
        else:  # disposicion posicional observada
            i = cells.index(str(year))
            if i < 2 or len(cells) < i + 6:
                continue
            row = {"rango": cells[i - 3] if i >= 3 else "", "indicativo": cells[i - 2], "entidad": cells[i - 1],
                   "categoria": cells[i + 1], "puntuacion": cells[i + 2], "qsos": cells[i + 3],
                   "zonas": cells[i + 4], "paises": cells[i + 5] if len(cells) > i + 5 else "",
                   "horas": cells[i + 6] if len(cells) > i + 6 else ""}
        row["anio"] = year
        for k in ("puntuacion", "qsos", "zonas", "paises"):
            row[k] = to_int(row[k])
        if row["indicativo"] and row["puntuacion"] is not None:
            out.append(row)
    return out


def get(url: str, timeout=60):
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.read().decode("utf-8", "replace")


def fetch(url_tpl: str, params: dict, year: int, max_pages: int, delay: float) -> list:
    rows, seen = [], set()
    for page in range(1, max_pages + 1):
        url = url_tpl.format(page=page, **{k: urllib.parse.quote_plus(str(v)) for k, v in params.items()})
        try:
            html = get(url)
        except Exception as e:
            print(f"[aviso] {url}: {e}", file=sys.stderr)
            break
        new = []
        for r in parse_rows(html, year):
            key = (r["indicativo"], r["categoria"], r["puntuacion"])
            if key not in seen:
                seen.add(key)
                r["fuente_url"] = url
                new.append(r)
        print(f"{url} -> {len(new)} filas nuevas")
        if not new:
            break
        rows += new
        time.sleep(delay)
    return rows


def describe(values: list) -> dict:
    v = sorted(x for x in values if x is not None)
    if not v:
        return {"n": 0}
    q = statistics.quantiles(v, n=4) if len(v) > 1 else [v[0]] * 3
    return {"n": len(v), "min": v[0], "p25": round(q[0]), "mediana": statistics.median(v),
            "p75": round(q[2]), "max": v[-1]}


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--mode", choices=["ph", "cw"], default="ph")
    ap.add_argument("--years", type=int, nargs="+", required=True)
    ap.add_argument("--dx", nargs="+", default=["EA"], help="códigos de entidad (EA, EA6, EA8, EA9...)")
    ap.add_argument("--cats", nargs="*", default=["SL ALL", "AL ALL"], help="categorías de la base de datos")
    ap.add_argument("--overlay", help="ROOKIE, CLASSIC, TB-WIRES, YOUTH... (usa la página de overlays)")
    ap.add_argument("--overlay-cats", nargs="*", default=["L"], help="potencia en overlays: L, H, Q")
    ap.add_argument("--scores-url", default=SCORES_URL)
    ap.add_argument("--overlay-url", default=OVERLAY_URL)
    ap.add_argument("--max-pages", type=int, default=20)
    ap.add_argument("--delay", type=float, default=1.0)
    ap.add_argument("--out", required=True, help="CSV de salida (se escribe también <out>.stats.json)")
    args = ap.parse_args(argv)

    allrows, stats = [], {}
    for year in args.years:
        for dx in args.dx:
            if args.overlay:
                combos = [(c, args.overlay_url, {"mode": args.mode, "year": year, "dx": dx, "cat": c,
                                                 "over": args.overlay}) for c in args.overlay_cats]
            else:
                combos = [(c, args.scores_url, {"mode": args.mode, "year": year, "dx": dx, "cat": c})
                          for c in args.cats]
            for cat, tpl, params in combos:
                rows = fetch(tpl, params, year, args.max_pages, args.delay)
                for r in rows:
                    r["filtro"] = f"{dx}|{cat}" + (f"|{args.overlay}" if args.overlay else "")
                allrows += rows
                stats[f"{year}|{dx}|{cat}" + (f"|{args.overlay}" if args.overlay else "")] = {
                    "puntuacion": describe([r["puntuacion"] for r in rows]),
                    "qsos": describe([r["qsos"] for r in rows])}
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    cols = ["anio", "filtro", "rango", "categoria", "indicativo", "entidad", "puntuacion", "qsos", "zonas",
            "paises", "horas", "fuente_url"]
    with out.open("w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=cols + ["tipo"], extrasaction="ignore")
        w.writeheader()
        for r in allrows:
            w.writerow({**r, "tipo": "final"})
    Path(str(out) + ".stats.json").write_text(json.dumps(stats, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"{len(allrows)} filas -> {out}; estadísticas -> {out}.stats.json")
    for k, v in stats.items():
        print(k, v["puntuacion"])


if __name__ == "__main__":
    main()
