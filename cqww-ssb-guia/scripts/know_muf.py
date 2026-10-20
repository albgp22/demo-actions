#!/usr/bin/env python3
"""MUF orientativa Madrid -> zonas DX (CQ WW SSB 2026/2027; también ARRL 10 m 2026 y ARRL DX SSB 2027).

Método (simplificado, de tipo CCIR/UIT-R P.533):
  * Ionosfera: PyIRI (Forsythe et al., 2023, Space Weather; implementación en
    Python del IRI con coeficientes CCIR) -> foF2 y M(3000)F2 medianos
    mensuales interpolados al día y al flujo solar F10.7 indicado.
  * MUF(3000)F2 = foF2 * M(3000)F2 en cada punto de control.
  * Trayectos > 4000 km: puntos de control a 2000 km de cada extremo sobre el
    círculo máximo; MUF(4000) ~= 1,1 * MUF(3000); la MUF básica del trayecto es
    la MENOR de las dos (criterio clásico CCIR / UIT-R P.533).
  * Trayectos <= 4000 km: un punto de control en el punto medio, MUF ~= MUF(3000).
  * No modela absorción (LUF), esporádica E, dispersión ni variabilidad diaria
    (la MUF real de un día concreto puede diferir ±15-20 % de la mediana).
  Es una ESTIMACIÓN ORIENTATIVA, no una predicción oficial.

Requisitos: numpy y PyIRI 0.1.7 (incluido en requirements.txt; alternativamente,
una carpeta con PyIRI indicada con --pyiri-path).

Salidas (data/knowledge/): muf_rumbos.csv, muf_ventanas.csv, muf_horaria.csv
Uso: .venv/bin/python scripts/know_muf.py --root .
"""
import argparse
import csv
import math
import pathlib
import sys

R_EARTH = 6371.0
CIRC = 2 * math.pi * R_EARTH

ORIGIN = ("Madrid (IN80)", 40.4168, -3.7038)

# destino, etiqueta (prefijo/zona CQ), lat, lon (E positiva)
TARGETS = [
    ("Nueva York", "W2 / zona 5", 40.71, -74.01),
    ("Chicago", "W9 / zona 4", 41.88, -87.63),
    ("Los Ángeles", "W6 / zona 3", 34.05, -118.24),
    ("San Juan (Puerto Rico)", "KP4 / zona 8", 18.47, -66.11),
    ("São Paulo", "PY / zona 11", -23.55, -46.63),
    ("Buenos Aires", "LU / zona 13", -34.60, -58.38),
    ("Dakar", "6W / zona 35", 14.69, -17.45),
    ("Nairobi", "5Z / zona 37", -1.29, 36.82),
    ("Johannesburgo", "ZS / zona 38", -26.20, 28.05),
    ("Nueva Delhi", "VU / zona 22", 28.61, 77.21),
    ("Novosibirsk", "UA9 / zona 18", 55.03, 82.92),
    ("Tokio", "JA / zona 25", 35.68, 139.69),
    ("Yakarta", "YB / zona 28", -6.21, 106.85),
    ("Sídney", "VK2 / zona 30", -33.87, 151.21),
    ("Honolulu", "KH6 / zona 31", 21.31, -157.86),
]
LONG_PATH = {"Sídney"}  # se calcula también el trayecto largo

BANDS = [("10 m", 28.4), ("15 m", 21.2), ("20 m", 14.15)]
DATES = [(2026, 10, 25), (2027, 10, 31), (2026, 12, 12), (2027, 3, 6)]  # CQ WW SSB 2026/2027, ARRL 10 m 2026, ARRL DX SSB 2027
F107_SCENARIOS = [80, 100, 120, 140]
STEP_H = 0.25


def inverse(lat1, lon1, lat2, lon2):
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dl = math.radians(lon2 - lon1)
    a = math.sin((p2 - p1) / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) ** 2
    d = 2 * R_EARTH * math.asin(math.sqrt(a))
    y = math.sin(dl) * math.cos(p2)
    x = math.cos(p1) * math.sin(p2) - math.sin(p1) * math.cos(p2) * math.cos(dl)
    brg = (math.degrees(math.atan2(y, x)) + 360) % 360
    return d, brg


def destination(lat, lon, brg, dist):
    p1, l1, th, dl = math.radians(lat), math.radians(lon), math.radians(brg), dist / R_EARTH
    p2 = math.asin(math.sin(p1) * math.cos(dl) + math.cos(p1) * math.sin(dl) * math.cos(th))
    l2 = l1 + math.atan2(math.sin(th) * math.sin(dl) * math.cos(p1), math.cos(dl) - math.sin(p1) * math.sin(p2))
    lon2 = (math.degrees(l2) + 540) % 360 - 180
    return math.degrees(p2), lon2


def control_points(brg, dist):
    lat0, lon0 = ORIGIN[1], ORIGIN[2]
    if dist <= 4000:
        return [destination(lat0, lon0, brg, dist / 2)], 1.0
    return [destination(lat0, lon0, brg, 2000.0), destination(lat0, lon0, brg, dist - 2000.0)], 1.1


def hhmm(x):
    m = int(round(x * 60)) % (24 * 60)
    return f"{m // 60:02d}:{m % 60:02d}"


def windows(ut, ok):
    """Intervalos contiguos (admite paso por 00 UTC) en los que ok es True."""
    ok = [bool(v) for v in ok]
    ut = [float(v) for v in ut]
    n = len(ok)
    if all(ok):
        return "todo el día", 24.0
    if not any(ok):
        return "-", 0.0
    i0 = ok.index(False)  # empezar en un instante sin apertura
    segs, i = [], 0
    while i < n:
        if ok[(i0 + i) % n]:
            j = i
            while j < n and ok[(i0 + j) % n]:
                j += 1
            segs.append((ut[(i0 + i) % n], ut[(i0 + j - 1) % n] + STEP_H))
            i = j
        else:
            i += 1
    segs.sort()
    return ", ".join(f"{hhmm(a)}-{hhmm(b)}" for a, b in segs), sum(ok) * STEP_H


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=str(pathlib.Path(__file__).resolve().parents[1]))
    ap.add_argument("--pyiri-path", default=None,
                    help="carpeta con PyIRI si no está instalado en el entorno")
    args = ap.parse_args()
    if args.pyiri_path:
        sys.path.insert(0, args.pyiri_path)
    import numpy as np
    import PyIRI
    import PyIRI.main_library as ml

    out = pathlib.Path(args.root) / "data" / "knowledge"
    out.mkdir(parents=True, exist_ok=True)

    paths = []  # (destino, etiqueta, tipo, rumbo, dist, [cp], factor)
    with open(out / "muf_rumbos.csv", "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(["destino", "etiqueta", "lat", "lon", "rumbo_sp_grados", "distancia_sp_km",
                    "rumbo_lp_grados", "distancia_lp_km"])
        for name, tag, lat, lon in TARGETS:
            d, b = inverse(ORIGIN[1], ORIGIN[2], lat, lon)
            w.writerow([name, tag, lat, lon, round(b), round(d), round((b + 180) % 360), round(CIRC - d)])
            cps, fac = control_points(b, d)
            paths.append((name, tag, "SP", b, d, cps, fac))
            if name in LONG_PATH:
                cps, fac = control_points((b + 180) % 360, CIRC - d)
                paths.append((name, tag, "LP", (b + 180) % 360, CIRC - d, cps, fac))

    lats = np.array([cp[0] for p in paths for cp in p[5]])
    lons = np.array([cp[1] for p in paths for cp in p[5]])
    ut = np.arange(0, 24, STEP_H)
    aalt = np.array([300.0])

    rows_w, rows_h = [], []
    for (y, m, dd) in DATES:
        for f107 in F107_SCENARIOS:
            F2, F1, E, Es, sun, mag, EDP = ml.IRI_density_1day(y, m, dd, ut, lons, lats, aalt, float(f107),
                                                               PyIRI.coeff_dir, ccir_or_ursi=0)
            muf3000 = np.asarray(F2["fo"]) * np.asarray(F2["M3000"])  # [N_T, N_G]
            k = 0
            for name, tag, typ, b, d, cps, fac in paths:
                cols = list(range(k, k + len(cps)))
                k += len(cps)
                muf = (muf3000[:, cols] * fac).min(axis=1)
                for h in range(24):
                    rows_h.append([name, typ, f"{y}-{m:02d}-{dd:02d}", f107, f"{h:02d}:00",
                                   round(float(muf[int(h / STEP_H)]), 1)])
                imax = int(np.argmax(muf))
                for band, thr in BANDS:
                    txt, hours = windows(ut, muf >= thr)
                    rows_w.append([name, tag, typ, f"{y}-{m:02d}-{dd:02d}", f107, band, thr, txt, hours,
                                   round(float(muf.max()), 1), hhmm(float(ut[imax]))])

    with open(out / "muf_ventanas.csv", "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(["destino", "etiqueta", "trayecto", "fecha", "f107", "banda", "umbral_mhz",
                    "ventanas_utc_muf_sobre_umbral", "horas", "muf_max_mhz", "utc_muf_max"])
        w.writerows(rows_w)
    with open(out / "muf_horaria.csv", "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(["destino", "trayecto", "fecha", "f107", "utc", "muf_basica_mhz"])
        w.writerows(rows_h)
    print(f"PyIRI {PyIRI.__version__}; trayectos: {len(paths)}; filas ventanas: {len(rows_w)}")


if __name__ == "__main__":
    main()
