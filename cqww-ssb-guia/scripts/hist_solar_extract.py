#!/usr/bin/env python3
"""
hist_solar_extract.py - Indices solares y geomagneticos de los fines de semana
del CQ World Wide DX Contest SSB (ultimo fin de semana completo de octubre).

Lee el fichero de "space weather" de CelesTrak (formato CssiSpaceWeather 1.2,
https://celestrak.org/SpaceData/SpaceWx-format.php) y escribe un CSV con, para
cada edicion pedida, el viernes previo, el sabado y el domingo del concurso:

  f107      flujo solar 10,7 cm OBSERVADO (Penticton, 20 UT), en sfu
  ssn       numero internacional de manchas solares diario (SILSO, ISN)
  a_index   Ap planetario diario (media de los 8 ap trihorarios, GFZ)
  k_max     Kp maximo de los 8 intervalos trihorarios del dia (en tercios)

Ademas anade, si se piden, las medias MENSUALES PREVISTAS que trae el propio
fichero (seccion MONTHLY_PREDICTED) para octubre de anos futuros.

Origen de los datos (por orden, segun --source):
  local    : --sw-file / --sw-all (ficheros ya descargados)
  celestrak: https://celestrak.org/SpaceData/SW-Last5Years.txt y SW-All.txt
  github   : copia incluida en el paquete pyspaceweather (st-bender) en
             raw.githubusercontent.com/st-bender/pyspaceweather/master/...
  pypi     : la misma copia dentro de la rueda del paquete PyPI "spaceweather"
  auto     : celestrak -> github -> pypi (por defecto)

Uso tipico:
  .venv/bin/python scripts/hist_solar_extract.py --out data/history/solar.csv
  .venv/bin/python scripts/hist_solar_extract.py --source github \
      --years 1999 2000 2022 2023 2024 2025 --forecast 2026 2027 \
      --out data/history/solar.csv --chart data/history/fig_solar_cqww_ssb

Solo usa la biblioteca estandar (matplotlib solo para --chart).
"""
from __future__ import annotations

import argparse
import csv
import datetime as dt
import io
import json
import sys
import urllib.request
import zipfile
from pathlib import Path

CELESTRAK = {
    "5y": "https://celestrak.org/SpaceData/SW-Last5Years.txt",
    "all": "https://celestrak.org/SpaceData/SW-All.txt",
}
GITHUB = {
    "5y": "https://raw.githubusercontent.com/st-bender/pyspaceweather/master/"
          "src/spaceweather/data/SW-Last5Years.txt",
    "all": "https://raw.githubusercontent.com/st-bender/pyspaceweather/master/"
           "src/spaceweather/data/SW-All.txt",
}
PYPI_JSON = "https://pypi.org/pypi/spaceweather/json"
UA = {"User-Agent": "cqww-ssb-guia-hist/1.0 (educational; python urllib)"}

# FORMAT(I4,I3,I3,I5,I3,8I3,I4,8I4,I4,F4.1,I2,I4,F6.1,I2,5F6.1)
WIDTHS = [4, 3, 3, 5, 3] + [3] * 8 + [4] + [4] * 8 + [4, 4, 2, 4, 6, 2, 6, 6, 6, 6, 6]
NAMES = (["year", "month", "day", "bsrn", "nd"]
         + [f"kp{h:02d}" for h in range(0, 24, 3)] + ["kpsum"]
         + [f"ap{h:02d}" for h in range(0, 24, 3)] + ["ap"]
         + ["cp", "c9", "isn", "f107_adj", "q", "ctr81_adj", "lst81_adj",
            "f107_obs", "ctr81_obs", "lst81_obs"])


def _get(url: str, timeout: float = 30.0) -> bytes:
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.read()


def _from_pypi() -> dict[str, tuple[str, str]]:
    meta = json.loads(_get(PYPI_JSON))
    whl = [u for u in meta["urls"] if u["filename"].endswith(".whl")][0]
    blob = _get(whl["url"], timeout=120)
    z = zipfile.ZipFile(io.BytesIO(blob))
    out = {}
    for key, name in (("5y", "spaceweather/data/SW-Last5Years.txt"),
                      ("all", "spaceweather/data/SW-All.txt")):
        out[key] = (z.read(name).decode("ascii", "replace"),
                    f"{whl['url']}#{name}")
    return out


def load_texts(source: str, sw_file: str | None, sw_all: str | None) -> dict[str, tuple[str, str]]:
    """Devuelve {'5y': (texto, url_origen), 'all': (texto, url_origen)}."""
    if source == "local" or sw_file or sw_all:
        out = {}
        if sw_file:
            out["5y"] = (Path(sw_file).read_text("ascii", "replace"), str(sw_file))
        if sw_all:
            out["all"] = (Path(sw_all).read_text("ascii", "replace"), str(sw_all))
        if not out:
            sys.exit("--source local requiere --sw-file y/o --sw-all")
        return out
    order = {"auto": ["celestrak", "github", "pypi"], "celestrak": ["celestrak"],
             "github": ["github"], "pypi": ["pypi"]}[source]
    last_err = None
    for src in order:
        try:
            if src == "pypi":
                return _from_pypi()
            urls = CELESTRAK if src == "celestrak" else GITHUB
            return {k: (_get(u, timeout=60).decode("ascii", "replace"), u) for k, u in urls.items()}
        except Exception as exc:  # red bloqueada, 403, etc.
            print(f"[aviso] origen {src} no disponible: {exc}", file=sys.stderr)
            last_err = exc
    sys.exit(f"No se pudo obtener el fichero de CelesTrak: {last_err}")


def _parse_fixed(line: str) -> dict:
    vals, pos = {}, 0
    for name, w in zip(NAMES, WIDTHS):
        field = line[pos:pos + w].strip()
        pos += w
        if field == "":
            vals[name] = None
        elif name in ("cp", "f107_adj", "ctr81_adj", "lst81_adj", "f107_obs",
                      "ctr81_obs", "lst81_obs"):
            vals[name] = float(field)
        else:
            vals[name] = int(field)
    return vals


def parse_sw(text: str) -> tuple[str, dict, dict]:
    """Devuelve (UPDATED, {fecha: fila observada}, {(anio, mes): fila mensual prevista})."""
    updated, section = "", None
    observed, monthly = {}, {}
    for line in text.splitlines():
        if line.startswith("UPDATED"):
            updated = line[len("UPDATED"):].strip()
        if line.startswith("BEGIN "):
            section = line.split()[1]
            continue
        if line.startswith("END "):
            section = None
            continue
        if section not in ("OBSERVED", "MONTHLY_PREDICTED") or not line[:4].strip().isdigit():
            continue
        row = _parse_fixed(line)
        if section == "OBSERVED":
            observed[dt.date(row["year"], row["month"], row["day"])] = row
        else:
            monthly[(row["year"], row["month"])] = row
    return updated, observed, monthly


def contest_saturday(year: int, month: int = 10) -> dt.date:
    """Sabado del ultimo fin de semana COMPLETO del mes (SSB: octubre; CW: noviembre)."""
    nxt = dt.date(year + (month == 12), month % 12 + 1, 1)
    last = nxt - dt.timedelta(days=1)
    last_sunday = last - dt.timedelta(days=(last.weekday() - 6) % 7)
    return last_sunday - dt.timedelta(days=1)


def kp_label(v10: int) -> tuple[float, str]:
    """CelesTrak guarda Kp x10 en tercios (0,3,7,10,13,...). 47 -> 4,67 ('5-')."""
    base, rem = divmod(v10, 10)
    if rem == 0:
        return float(base), f"{base}o"
    if rem == 3:
        return base + 1 / 3, f"{base}+"
    return base + 2 / 3, f"{base + 1}-"


def ap_class(ap: int) -> str:
    # Descriptores clasicos del indice A (NOAA/ARRL): 0-7 tranquilo, 8-15 inestable,
    # 16-29 activo, 30-49 tormenta menor, 50-99 tormenta mayor, >=100 tormenta severa.
    for lim, name in ((7, "tranquilo"), (15, "inestable"), (29, "activo"),
                      (49, "tormenta menor"), (99, "tormenta mayor")):
        if ap <= lim:
            return name
    return "tormenta severa"


DAYNAME = {4: "viernes previo", 5: "sábado (concurso)", 6: "domingo (concurso)"}


def build_rows(years, forecast, texts):
    rows, summary = [], {}
    parsed = {k: parse_sw(t) + (u,) for k, (t, u) in texts.items()}
    for year in years:
        sat = contest_saturday(year)
        for day in (sat - dt.timedelta(days=1), sat, sat + dt.timedelta(days=1)):
            hit = None
            for key in ("5y", "all"):
                if key in parsed and day in parsed[key][1]:
                    upd, obs, _, url = parsed[key]
                    hit = (obs[day], upd, url)
                    break
            if not hit:
                rows.append({"anio": year, "fecha": day.isoformat(), "f107": "", "ssn": "",
                             "a_index": "", "k_max": "", "nota": f"{DAYNAME[day.weekday()]}: sin dato observado en el fichero",
                             "fuente_url": "", "verificado": "POR VERIFICAR"})
                continue
            r, upd, url = hit
            kps = [r[f"kp{h:02d}"] for h in range(0, 24, 3)]
            kmax10 = max(kps)
            kmax, ksym = kp_label(kmax10)
            blocks = [f"{h:02d}-{h + 3:02d}" for h, v in zip(range(0, 24, 3), kps) if v == kmax10]
            nota = (f"{DAYNAME[day.weekday()]}; Kp máx. {ksym} ({'/'.join(blocks)} UTC); "
                    f"Ap {r['ap']} = {ap_class(r['ap'])}; F10.7 ajustado a 1 UA {r['f107_adj']:.1f}; "
                    f"media de 81 días centrada (obs.) {r['ctr81_obs']:.1f}")
            rows.append({"anio": year, "fecha": day.isoformat(), "f107": f"{r['f107_obs']:.1f}",
                         "ssn": r["isn"], "a_index": r["ap"], "k_max": f"{kmax:.2f}", "nota": nota,
                         "fuente_url": url,
                         "verificado": (f"Leído del fichero CelesTrak SW (UPDATED {upd}) con "
                                        f"scripts/hist_solar_extract.py; Kp/Ap de GFZ, ISN de SILSO, "
                                        f"F10.7 de Penticton (DRAO) según el formato CelesTrak")})
            summary.setdefault(year, []).append((day, r))
    for year in forecast:
        hit = None
        for key in ("5y", "all"):
            if key in parsed and (year, 10) in parsed[key][2]:
                upd, _, mon, url = parsed[key]
                hit = (mon[(year, 10)], upd, url)
                break
        if not hit:
            continue
        r, upd, url = hit
        sat = contest_saturday(year)
        rows.append({"anio": year, "fecha": f"{year}-10 (media mensual prevista)",
                     "f107": f"{r['f107_obs']:.1f}", "ssn": r["isn"], "a_index": "", "k_max": "",
                     "nota": (f"PREVISIÓN mensual (no es observación) para octubre de {year}; concurso previsto "
                              f"{sat.isoformat()}/{(sat + dt.timedelta(days=1)).isoformat()} (último fin de "
                              f"semana completo de octubre); F10.7 ajustado {r['f107_adj']:.1f}; el Kp no se "
                              f"puede prever con meses de antelación"),
                     "fuente_url": url,
                     "verificado": (f"Sección MONTHLY_PREDICTED del fichero CelesTrak (UPDATED {upd}); "
                                    f"origen exacto de la predicción POR VERIFICAR en "
                                    f"https://celestrak.org/SpaceData/SpaceWx-format.php")})
    return rows, summary, parsed


def monthly_means(parsed, year, months):
    out = []
    for key in ("5y", "all"):
        if key not in parsed:
            continue
        obs = parsed[key][1]
        for m in months:
            vals = [r for d, r in obs.items() if d.year == year and d.month == m]
            if vals:
                out.append((year, m, len(vals),
                            sum(v["f107_obs"] for v in vals) / len(vals),
                            sum(v["isn"] for v in vals) / len(vals),
                            sum(v["ap"] for v in vals) / len(vals)))
        if out:
            break
    return out


def make_chart(rows, stem: Path):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    INK, INK2, MUTED, GRID, AXIS, SURF = "#0b0b0b", "#52514e", "#898781", "#e1e0d9", "#c3c2b7", "#fcfcfb"
    SAT, SUN = "#2a78d6", "#eb6834"  # ranuras categoricas 1 y 2 (paleta validada)
    obs = [r for r in rows if r["k_max"] != "" and not r["nota"].startswith("viernes")]
    years = sorted({r["anio"] for r in obs})
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(8, 6.2), dpi=100, sharex=True,
                                   gridspec_kw={"height_ratios": [3, 2], "hspace": 0.18})
    fig.patch.set_facecolor(SURF)
    w = 0.34
    for ax in (ax1, ax2):
        ax.set_facecolor(SURF)
        for s in ("top", "right", "left"):
            ax.spines[s].set_visible(False)
        ax.spines["bottom"].set_color(AXIS)
        ax.tick_params(colors=MUTED, labelcolor=INK2, length=0)
        ax.grid(axis="y", color=GRID, linewidth=0.8)
        ax.set_axisbelow(True)
    for i, y in enumerate(years):
        for j, (lab, col) in enumerate((("sábado", SAT), ("domingo", SUN))):
            rr = [r for r in obs if r["anio"] == y and lab in r["nota"]]
            if not rr:
                continue
            x = i + (j - 0.5) * w
            f = float(rr[0]["f107"])
            k = float(rr[0]["k_max"])
            ax1.bar(x, f, width=w * 0.92, color=col, edgecolor=SURF, linewidth=1.2,
                    label=("Sábado" if j == 0 else "Domingo") if i == 0 else None)
            ax1.text(x, f + 4, f"{f:.0f}", ha="center", va="bottom", fontsize=8, color=INK2,
                     bbox=dict(facecolor=SURF, edgecolor="none", pad=0.6))
            ax2.bar(x, k, width=w * 0.92, color=col, edgecolor=SURF, linewidth=1.2)
            ksym = rr[0]["nota"].split("Kp máx. ")[1].split(" ")[0]
            ax2.text(x, k + 0.12, ksym, ha="center", va="bottom", fontsize=8, color=INK2, zorder=5,
                     bbox=dict(facecolor=SURF, edgecolor="none", pad=0.6))
    ax1.set_ylabel("F10.7 observado (sfu)", color=INK2)
    ax1.set_title("CQ WW SSB: condiciones solares en el fin de semana del concurso",
                  loc="left", color=INK, fontsize=12, pad=26)
    ax1.text(0, 1.04, "Flujo solar de 10,7 cm diario (arriba) y Kp máximo diario (abajo). "
             "Fuente: CelesTrak SW (GFZ, SILSO, DRAO).", transform=ax1.transAxes,
             fontsize=8.5, color=INK2)
    # separador entre bloques de anos no consecutivos (p. ej. ciclo 23 frente a ciclo 25)
    for i in range(1, len(years)):
        if years[i] - years[i - 1] > 1:
            for ax in (ax1, ax2):
                ax.axvline(i - 0.5, color=GRID, linewidth=1)
            ax1.text(i - 0.5, ax1.get_ylim()[1] * 0.97, f"  salto {years[i - 1]}–{years[i]}",
                     ha="left", va="top", fontsize=7.5, color=MUTED)
    ax1.legend(frameon=False, loc="upper left", fontsize=9, labelcolor=INK2)
    ax2.axhline(5, color=AXIS, linewidth=1)
    ax2.text(len(years) - 0.5, 5.08, "Kp 5 = tormenta G1", ha="right", va="bottom", fontsize=8, color=MUTED)
    ax2.set_ylim(0, 6)
    ax2.set_ylabel("Kp máximo", color=INK2)
    ax2.set_xticks(range(len(years)), [str(y) for y in years])
    fig.subplots_adjust(left=0.1, right=0.98, top=0.86, bottom=0.08)
    stem.parent.mkdir(parents=True, exist_ok=True)
    for ext in ("png", "svg"):
        fig.savefig(f"{stem}.{ext}", dpi=200 if ext == "png" else None, facecolor=SURF)
    plt.close(fig)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--years", type=int, nargs="+", default=[2022, 2023, 2024, 2025])
    ap.add_argument("--forecast", type=int, nargs="*", default=[2026, 2027],
                    help="anos para los que anadir la media mensual PREVISTA de octubre")
    ap.add_argument("--source", choices=["auto", "celestrak", "github", "pypi", "local"], default="auto")
    ap.add_argument("--sw-file", help="SW-Last5Years.txt local")
    ap.add_argument("--sw-all", help="SW-All.txt local (necesario para anos de mas de 5 anos atras)")
    ap.add_argument("--out", default="data/history/solar.csv")
    ap.add_argument("--chart", help="prefijo de ruta para guardar grafico PNG+SVG (opcional)")
    args = ap.parse_args(argv)

    texts = load_texts(args.source, args.sw_file, args.sw_all)
    rows, summary, parsed = build_rows(args.years, args.forecast, texts)
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    cols = ["anio", "fecha", "f107", "ssn", "a_index", "k_max", "nota", "fuente_url", "verificado"]
    with out.open("w", newline="", encoding="utf-8") as fh:
        wr = csv.DictWriter(fh, fieldnames=cols)
        wr.writeheader()
        wr.writerows(rows)
    print(f"Escrito {out} ({len(rows)} filas)")
    for k, (upd, obs, mon, url) in parsed.items():
        print(f"  fichero {k}: UPDATED {upd}; observados hasta {max(obs) if obs else '-'}; {url}")
    for year, days in summary.items():
        f = [d[1]["f107_obs"] for d in days if d[0].weekday() in (5, 6)]
        k = [kp_label(max(d[1][f'kp{h:02d}'] for h in range(0, 24, 3)))[1] for d in days if d[0].weekday() in (5, 6)]
        print(f"  {year}: F10.7 sab/dom {f}; Kp max sab/dom {k}")
    last_obs_year = max(max(v[1]) for v in parsed.values() if v[1]).year
    for y, m, n, f, s, a in monthly_means(parsed, last_obs_year, range(1, 13)):
        print(f"  media mensual observada {y}-{m:02d} (n={n}): F10.7 {f:.1f}  ISN {s:.1f}  Ap {a:.1f}")
    if args.chart:
        make_chart(rows, Path(args.chart))
        print(f"Grafico: {args.chart}.png / .svg")


if __name__ == "__main__":
    main()
