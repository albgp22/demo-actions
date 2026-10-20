"""Ventanas de bandas bajas (40/80/160 m): horas UTC en que todo el trayecto
Madrid → destino está de noche (Sol < 0° en cinco puntos del círculo máximo:
extremos, punto medio y cuartos). Fecha: sábado 24 oct 2026.

Las bandas altas (10/15/20 m) salen del modelo de MUF de
scripts/know_muf.py (data/knowledge/muf_ventanas.csv).

Salida: data/calc/ventanas_noche.csv
"""
from __future__ import annotations

import csv
import math
from datetime import datetime, timedelta, timezone
from pathlib import Path

from figlib import solar_elevation

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "data" / "calc" / "ventanas_noche.csv"
MAD = (40.4168, -3.7038)
DAY = datetime(2026, 10, 24, tzinfo=timezone.utc)

TARGETS = [  # mismos destinos que el modelo de MUF
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


def gc_point(lat1, lon1, lat2, lon2, f):
    """Punto a la fracción f del círculo máximo (interpolación esférica)."""
    p1, l1, p2, l2 = map(math.radians, (lat1, lon1, lat2, lon2))
    d = 2 * math.asin(math.sqrt(math.sin((p2 - p1) / 2) ** 2
                                + math.cos(p1) * math.cos(p2) * math.sin((l2 - l1) / 2) ** 2))
    a = math.sin((1 - f) * d) / math.sin(d)
    b = math.sin(f * d) / math.sin(d)
    x = a * math.cos(p1) * math.cos(l1) + b * math.cos(p2) * math.cos(l2)
    y = a * math.cos(p1) * math.sin(l1) + b * math.cos(p2) * math.sin(l2)
    z = a * math.sin(p1) + b * math.sin(p2)
    return math.degrees(math.atan2(z, math.hypot(x, y))), math.degrees(math.atan2(y, x))


def windows(flags, step_min):
    """Convierte una lista de booleanos (cada step_min) en tramos 'HH:MM-HH:MM'."""
    out, start = [], None
    n = len(flags)
    for i in range(n + 1):
        on = flags[i % n] if i < n else False
        if on and start is None:
            start = i
        if not on and start is not None:
            out.append((start, i))
            start = None
    # unir el tramo que cruza medianoche
    if len(out) > 1 and out[0][0] == 0 and out[-1][1] == n:
        out = [(out[-1][0], out[0][1] + n)] + out[1:-1]
    fmt = lambda k: f"{(k * step_min // 60) % 24:02d}:{k * step_min % 60:02d}"
    return ", ".join(f"{fmt(a)}-{fmt(b)}" for a, b in out) or "-"


def main() -> None:
    step = 15
    rows = []
    for name, tag, lat, lon in TARGETS:
        pts = [gc_point(*MAD, lat, lon, f) for f in (0, 0.25, 0.5, 0.75, 1)]
        flags = []
        for k in range(24 * 60 // step):
            t = DAY + timedelta(minutes=k * step)
            flags.append(all(solar_elevation(p[0], p[1], t) < 0 for p in pts))
        rows.append({"destino": name, "etiqueta": tag, "noche_en_todo_el_trayecto_utc": windows(flags, step),
                     "horas": sum(flags) * step / 60})
    OUT.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)
    for r in rows:
        print(f"{r['destino']:24s} {r['noche_en_todo_el_trayecto_utc']:30s} {r['horas']:.2f} h")


if __name__ == "__main__":
    main()
