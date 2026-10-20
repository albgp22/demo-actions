"""Qué longitud de hilo vertical conviene con un acoplador remoto en la base
(capítulo 9, apartado de la antena).

- Bandas bajas (160/80/40 m): eficiencia con el modelo de vertical corta de
  scripts/equip_eficiencia.py (hilo de 1 mm de radio, Q = 150 para la red de
  adaptación y 5 o 15 Ω de pérdidas de tierra).
- Bandas altas (20/15/10 m): directividad a 10° de elevación de un monopolo
  ideal sobre tierra perfecta con corriente sinusoidal,
  F(θ) = [cos(kh·cos θ) − cos kh] / sin θ, y elevación del lóbulo principal.

No modela el tejado, la barandilla ni el hormigón: sirve para comparar
longitudes, no como valor absoluto.

Salida: data/antenas/longitud_hilo.csv
"""
from __future__ import annotations

import csv
import math
from pathlib import Path

import numpy as np

from equip_eficiencia import C0, vertical

ROOT = Path(__file__).resolve().parent.parent
HILOS_M = (7, 8, 10, 12)
BAJAS = {"160 m": 1.85, "80 m": 3.7, "40 m": 7.1}
ALTAS = {"20 m": 14.2, "15 m": 21.3, "10 m": 28.5}
TIERRAS_OHM = (5, 15)
ELEV_DEG = 10.0


def monopolo(h_m: float, f_mhz: float) -> tuple[float, float, float]:
    """Longitud en λ, directividad (dBi) a ELEV_DEG y elevación del lóbulo principal (°)."""
    kh = 2 * math.pi * f_mhz * 1e6 / C0 * h_m
    th = np.linspace(1e-5, math.pi / 2, 40001)  # ángulo desde el cenit
    f2 = ((np.cos(kh * np.cos(th)) - math.cos(kh)) / np.sin(th)) ** 2
    integral = getattr(np, "trapezoid", None) or np.trapz
    potencia = 2 * math.pi * integral(f2 * np.sin(th), th)  # solo el semiespacio superior
    th0 = math.radians(90 - ELEV_DEG)
    f0 = ((math.cos(kh * math.cos(th0)) - math.cos(kh)) / math.sin(th0)) ** 2
    d_dbi = 10 * math.log10(4 * math.pi * f0 / potencia) if f0 > 0 else float("-inf")
    lobulo = 90 - math.degrees(th[int(np.argmax(f2))])
    return kh / (2 * math.pi), d_dbi, lobulo


def main() -> None:
    filas = []
    for h in HILOS_M:
        for banda, f in BAJAS.items():
            for rt in TIERRAS_OHM:
                r = vertical(h, 1.0, f, 150.0, rt)
                filas.append({
                    "hilo_m": h, "banda": banda, "tierra_ohm": rt,
                    "longitud_lambda": round(h / (C0 / (f * 1e6)), 3),
                    "eficiencia_pct": "" if r["eficiencia_pct"] == "" else round(r["eficiencia_pct"], 1),
                    "perdida_db": "" if r["perdida_db"] == "" else round(r["perdida_db"], 1),
                    "directividad_10deg_dbi": "", "lobulo_deg": "",
                    "nota": "" if r["eficiencia_pct"] != "" else "≥ λ/4: el modelo de vertical corta no aplica",
                })
        for banda, f in ALTAS.items():
            lam, d, lob = monopolo(h, f)
            filas.append({
                "hilo_m": h, "banda": banda, "tierra_ohm": "", "longitud_lambda": round(lam, 2),
                "eficiencia_pct": "", "perdida_db": "",
                "directividad_10deg_dbi": round(d, 1), "lobulo_deg": round(lob),
                "nota": "monopolo ideal sobre tierra perfecta",
            })
    out = ROOT / "data/antenas/longitud_hilo.csv"
    with open(out, "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=list(filas[0]))
        w.writeheader()
        w.writerows(filas)
    for r in filas:
        print(r)
    print(f"→ {out.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
