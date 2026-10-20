"""Luz y oscuridad (UTC) en Madrid y destinos típicos, y mapas de la línea gris
al orto y al ocaso de Madrid. Fecha: sábado 24 oct 2026 (el domingo es casi
igual: el Sol se desplaza ~1 min/día).

Salidas: assets/luz_oscuridad_2026.{pdf,png}, assets/linea_gris_2026.{pdf,png},
         data/calc/linea_gris_2026.json (destinos dentro de la línea gris)
"""
from __future__ import annotations

import json
from datetime import datetime, timedelta, timezone

import matplotlib.patheffects as pe
import numpy as np
from matplotlib.patches import PathPatch, Patch, Polygon

from figlib import (BLUE_RAMP, GRID, INK, INK2, MUTED, ROOT, SURFACE, equal_earth, outline_path,
                    plt, rings_of, save, setup, solar_elevation)

UTC = timezone.utc
DAY = datetime(2026, 10, 24, tzinfo=UTC)
GEO = ROOT / "data" / "geo"

ROWS = [  # (etiqueta, lat, lon)
    ("Madrid (EA4)", 40.4168, -3.7038),
    ("Nueva York (W2, z5)", 40.7128, -74.0060),
    ("Chicago (W9, z4)", 41.8781, -87.6298),
    ("Los Ángeles (W6, z3)", 34.0522, -118.2437),
    ("Anchorage (KL7, z1)", 61.2181, -149.9003),
    ("Caracas (YV, z9)", 10.4806, -66.9036),
    ("São Paulo (PY, z11)", -23.5505, -46.6333),
    ("Buenos Aires (LU, z13)", -34.6037, -58.3816),
    ("Las Palmas (EA8, z33)", 28.1235, -15.4363),
    ("Johannesburgo (ZS, z38)", -26.2041, 28.0473),
    ("Novosibirsk (UA9, z18)", 55.0084, 82.9357),
    ("Nueva Delhi (VU, z22)", 28.6139, 77.2090),
    ("Tokio (JA, z25)", 35.6762, 139.6503),
    ("Sídney (VK2, z30)", -33.8688, 151.2093),
    ("Auckland (ZL, z32)", -36.8485, 174.7633),
]
DAY_C, TWI_C, NIGHT_C = BLUE_RAMP[100], BLUE_RAMP[300], BLUE_RAMP[500]
H0 = -0.833  # orto/ocaso estándar: borde superior del Sol con refracción


def light_class(el):
    return np.where(el > H0, 0, np.where(el > -6, 1, 2))


def fig_luz() -> None:
    minutes = np.arange(0, 24 * 60 + 1)
    times = [DAY + timedelta(minutes=int(m)) for m in minutes]
    fig, ax = plt.subplots(figsize=(7.0, 4.1))
    for i, (name, lat, lon) in enumerate(ROWS):
        el = np.array([solar_elevation(lat, lon, t) for t in times])
        cls = light_class(el)
        start = 0
        for k in range(1, len(minutes) + 1):
            if k == len(minutes) or cls[k] != cls[start]:
                color = (DAY_C, TWI_C, NIGHT_C)[cls[start]]
                ax.barh(i, (minutes[k - 1] - minutes[start] + 1) / 60, left=minutes[start] / 60,
                        height=0.56, color=color, edgecolor="none")
                start = k
    from astral import Observer
    from astral.sun import sunrise, sunset
    obs = Observer(latitude=40.4168, longitude=-3.7038)
    sr = sunrise(obs, date=DAY.date(), tzinfo=UTC)  # mismas horas que data/calc/orto_ocaso.csv
    ss = sunset(obs, date=DAY.date(), tzinfo=UTC)
    for ev, lab in ((sr, "orto Madrid"), (ss, "ocaso Madrid")):
        m = ev.hour * 60 + ev.minute
        ax.axvline(m / 60, color=INK, lw=0.8, zorder=5)
        ax.text(m / 60, -0.9, f"{lab}\n{m // 60:02d}:{m % 60:02d} UTC", ha="center", va="bottom",
                fontsize=6.5, color=INK, path_effects=[pe.withStroke(linewidth=2, foreground=SURFACE)])
    ax.set_yticks(range(len(ROWS)), [r[0] for r in ROWS], fontsize=7)
    ax.invert_yaxis()
    ax.set_ylim(len(ROWS) - 0.4, -1.0)
    ticks = list(range(0, 25, 2))
    ax.set_xticks(ticks, [f"{h:02d}\n{(h + 2) % 24:02d}" for h in ticks], fontsize=7)
    ax.set_xlim(0, 24)
    ax.set_xlabel("hora UTC (arriba) y hora de Madrid el sábado, CEST = UTC+2 (abajo)", fontsize=7, color=INK2)
    for s in ("top", "right", "left"):
        ax.spines[s].set_visible(False)
    ax.tick_params(axis="y", length=0)
    ax.legend(handles=[Patch(color=DAY_C, label="día"),
                       Patch(color=TWI_C, label="crepúsculo civil (Sol entre 0° y −6°)"),
                       Patch(color=NIGHT_C, label="noche (Sol < −6°)")],
              loc="upper center", bbox_to_anchor=(0.5, -0.16), ncol=3, fontsize=7, handlelength=1.2)
    save(fig, "luz_oscuridad_2026")


def near_terminator(lat, lon, t: datetime, window_min: int = 40) -> str | None:
    """'orto …' u 'ocaso …' si el lugar tiene su orto u ocaso a ±window_min de t."""
    from astral import Observer
    from astral.sun import sunrise, sunset
    obs = Observer(latitude=lat, longitude=lon)
    for fn, lab in ((sunrise, "orto"), (sunset, "ocaso")):
        for d in (t.date() - timedelta(days=1), t.date(), t.date() + timedelta(days=1)):
            ev = fn(obs, date=d, tzinfo=UTC)
            if abs((ev - t).total_seconds()) <= window_min * 60:
                return f"{lab} {ev:%H:%M} UTC"
    return None


def draw_map(ax, t: datetime, title: str, land) -> list[str]:
    ax.set_aspect("equal")
    ax.axis("off")
    clip = PathPatch(outline_path(), transform=ax.transData, facecolor="#eef3f9", edgecolor=INK2, lw=0.5, zorder=0)
    ax.add_patch(clip)
    for feat in land["features"]:
        for poly in rings_of(feat["geometry"]):
            arr = np.asarray(poly[0])
            x, y = equal_earth(arr[:, 0], arr[:, 1])
            p = Polygon(np.column_stack([x, y]), closed=True, facecolor="#dcdad3", edgecolor="none", zorder=1)
            ax.add_patch(p)
            p.set_clip_path(clip)
    lons = np.linspace(-180, 180, 361)
    lats = np.linspace(-90, 90, 181)
    LON, LAT = np.meshgrid(lons, lats)
    el = solar_elevation(LAT, LON, t)
    X, Y = equal_earth(LON, LAT)
    cs = ax.contourf(X, Y, el, levels=[-90, -6, H0], colors=[BLUE_RAMP[600], BLUE_RAMP[300]],
                     alpha=0.38, zorder=2)
    cs.set_clip_path(clip)
    hits = []
    for name, lat, lon in ROWS[1:]:
        x, y = equal_earth(lon, lat)
        ev = near_terminator(lat, lon, t)
        ax.plot(x, y, "o", ms=3.2, color=INK if ev else INK2, mec=SURFACE, mew=0.6, zorder=4)
        if ev:
            hits.append(f"{name}: {ev}")
            # cerca del borde derecho (o de la estrella de Madrid): etiqueta a la izquierda
            derecha = x > 1.6 or name.startswith("Las Palmas")
            ax.annotate(f"{name.split(' (')[0]} ({ev.split(' ')[0]})", (x, y),
                        xytext=(-5, -3) if derecha else (4, 2), ha="right" if derecha else "left",
                        textcoords="offset points", fontsize=6.5, color=INK, zorder=5,
                        path_effects=[pe.withStroke(linewidth=2, foreground=SURFACE)])
    mx, my = equal_earth(-3.7038, 40.4168)
    ax.plot(mx, my, marker="*", ms=7, color=INK, mec=SURFACE, mew=0.8, zorder=6)
    ax.set_title(title, fontsize=8, loc="left")
    ax.set_xlim(-2.75, 2.75)
    ax.set_ylim(-1.34, 1.34)
    return hits


def fig_greyline() -> dict:
    land = json.loads((GEO / "ne_110m_land.geojson").read_text())
    t_sr = DAY + timedelta(hours=6, minutes=35)
    t_ss = DAY + timedelta(hours=17, minutes=21)
    fig, axes = plt.subplots(1, 2, figsize=(7.2, 2.35))
    out = {
        "orto_madrid_06:35_UTC": draw_map(axes[0], t_sr, "Orto en Madrid · 06:35 UTC (08:35 CEST)", land),
        "ocaso_madrid_17:21_UTC": draw_map(axes[1], t_ss, "Ocaso en Madrid · 17:21 UTC (19:21 CEST)", land),
    }
    fig.legend(handles=[Patch(color=BLUE_RAMP[300], alpha=0.5, label="crepúsculo civil (Sol entre 0° y −6°)"),
                            Patch(color=BLUE_RAMP[600], alpha=0.45, label="noche"),
                            plt.Line2D([], [], marker="o", ls="", ms=3.5, color=INK,
                                       label="orto u ocaso a ±40 min")],
                   loc="lower center", bbox_to_anchor=(0.5, 0.04), ncol=3, fontsize=7)
    fig.subplots_adjust(wspace=0.04, bottom=0.16)
    save(fig, "linea_gris_2026")
    return out


def main() -> None:
    setup()
    fig_luz()
    hits = fig_greyline()
    (ROOT / "data" / "calc" / "linea_gris_2026.json").write_text(
        json.dumps(hits, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(hits, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
