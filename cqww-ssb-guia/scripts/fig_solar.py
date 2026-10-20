"""Condiciones solares en los fines de semana del CQ WW SSB 2022–2025 y
previsión mensual de octubre de 2026 y 2027 (fichero CelesTrak leído por
scripts/hist_solar_extract.py → data/history/solar.csv).

Salida: assets/solar_ediciones.{pdf,png}
"""
from __future__ import annotations

import csv

import numpy as np

from figlib import AXIS, GRID, INK, INK2, MUTED, ROOT, SERIES, plt, save, setup

PREV = "#c3c2b7"


def main() -> None:
    setup()
    rows = list(csv.DictReader(open(ROOT / "data/history/solar.csv", encoding="utf-8")))
    years = ["2022", "2023", "2024", "2025"]
    sat = {r["anio"]: r for r in rows if r["anio"] in years and "sábado" in r["nota"]}
    sun = {r["anio"]: r for r in rows if r["anio"] in years and "domingo" in r["nota"]}
    prev = {r["anio"]: r for r in rows if r["anio"] in ("2026", "2027")}

    fig, (a1, a2) = plt.subplots(2, 1, figsize=(6.6, 4.4), height_ratios=[1.6, 1], sharex=False)
    x = np.arange(len(years))
    w = 0.32
    f_sat = [float(sat[y]["f107"]) for y in years]
    f_sun = [float(sun[y]["f107"]) for y in years]
    a1.bar(x - w / 2 - 0.01, f_sat, w, color=SERIES[0], label="sábado")
    a1.bar(x + w / 2 + 0.01, f_sun, w, color=SERIES[1], label="domingo")
    xp = np.array([len(years), len(years) + 1])
    fp = [float(prev[y]["f107"]) for y in ("2026", "2027")]
    a1.bar(xp, fp, w, color=PREV, label="previsión media de octubre")
    for xi, v in list(zip(x - w / 2, f_sat)) + list(zip(x + w / 2, f_sun)) + list(zip(xp, fp)):
        a1.text(xi, v + 4, f"{v:.0f}", ha="center", va="bottom", fontsize=6.5, color=INK2)
    a1.set_xticks(list(x) + list(xp), years + ["2026\n(prev.)", "2027\n(prev.)"])
    a1.set_ylabel("F10.7 (sfu)")
    a1.set_ylim(0, 300)
    a1.yaxis.grid(True)
    a1.set_axisbelow(True)
    a1.legend(loc="upper left", fontsize=7, ncol=1)
    a1.set_title("Flujo solar (F10.7) en el fin de semana del concurso", loc="left")

    k_sat = [float(sat[y]["k_max"]) for y in years]
    k_sun = [float(sun[y]["k_max"]) for y in years]
    a2.bar(x - w / 2 - 0.01, k_sat, w, color=SERIES[0])
    a2.bar(x + w / 2 + 0.01, k_sun, w, color=SERIES[1])
    a2.axhline(5, color=AXIS, lw=0.8)
    a2.text(len(years) - 0.45, 5.1, "Kp 5 = tormenta G1", fontsize=6.5, color=MUTED, ha="right", va="bottom")
    a2.set_xticks(x, years)
    a2.set_xlim(a1.get_xlim())
    a2.set_ylim(0, 6.2)
    a2.set_ylabel("Kp máximo")
    a2.yaxis.grid(True)
    a2.set_axisbelow(True)
    a2.set_title("Actividad geomagnética (Kp máximo del día)", loc="left")
    for ax in (a1, a2):
        for s in ("top", "right"):
            ax.spines[s].set_visible(False)
        ax.tick_params(axis="x", length=0)
    fig.tight_layout(h_pad=1.2)
    save(fig, "solar_ediciones")


if __name__ == "__main__":
    main()
