"""Mapa de las 40 zonas CQ (proyección Equal Earth) con la zona 14 resaltada.

Datos: polígonos de zonas CQ de HB9HIL/hamradio-zones-geojson (licencia MIT,
copia en data/geo/LICENSE-hamradio-zones-geojson.txt) y tierras emergidas de
Natural Earth 1:110m (dominio público). Salida: assets/mapa_zonas_cq.{pdf,png}
"""
from __future__ import annotations

import json

import matplotlib.patheffects as pe
import numpy as np
from matplotlib.patches import PathPatch, Polygon

from figlib import (BLUE_RAMP, GRID, INK, INK2, ROOT, SURFACE, densify, equal_earth,
                    outline_path, plt, rings_of, save, setup)

GEO = ROOT / "data" / "geo"
OCEAN = "#eef3f9"
LAND = "#dcdad3"


def simplify(ring, tol=0.08):
    """Reduce vértices (Douglas–Peucker) para que el PDF pese poco."""
    from shapely.geometry import LinearRing
    return list(LinearRing(ring).simplify(tol, preserve_topology=False).coords)


def project_ring(ring, dx=0.0, step=None):
    pts = densify(ring, step) if step else ring
    arr = np.asarray(pts, dtype=float)
    x, y = equal_earth(arr[:, 0] + dx, arr[:, 1])
    return np.column_stack([x, y])


def main() -> None:
    setup()
    zones = json.loads((GEO / "cqzones.geojson").read_text())
    land = json.loads((GEO / "ne_110m_land.geojson").read_text())
    fig, ax = plt.subplots(figsize=(7.0, 3.75))
    ax.set_aspect("equal")
    ax.axis("off")
    clip = PathPatch(outline_path(), transform=ax.transData, facecolor=OCEAN, edgecolor=INK2, lw=0.6, zorder=0)
    ax.add_patch(clip)

    # Retícula cada 30°
    for lon in range(-180, 181, 30):
        lats = np.linspace(-90, 90, 91)
        x, y = equal_earth(np.full_like(lats, lon), lats)
        ax.plot(x, y, color=GRID, lw=0.4, zorder=1).__getitem__(0).set_clip_path(clip)
    for lat in range(-60, 61, 30):
        lons = np.linspace(-180, 180, 181)
        x, y = equal_earth(lons, np.full_like(lons, lat))
        ax.plot(x, y, color=GRID, lw=0.4, zorder=1)

    for feat in land["features"]:
        for poly in rings_of(feat["geometry"]):
            p = Polygon(project_ring(poly[0]), closed=True, facecolor=LAND, edgecolor="none", zorder=2)
            ax.add_patch(p)
            p.set_clip_path(clip)

    for feat in zones["features"]:
        z = feat["properties"]["cq_zone_number"]
        ring = simplify(feat["geometry"]["coordinates"][0])
        lons = [c[0] for c in ring]
        shifts = [0.0]
        if min(lons) < -180:
            shifts.append(360.0)
        if max(lons) > 180:
            shifts.append(-360.0)
        for dx in shifts:
            xy = project_ring(ring, dx, step=1.0)
            face = BLUE_RAMP[300] if z == 14 else "none"
            p = Polygon(xy, closed=True, facecolor=face, alpha=0.55 if z == 14 else 1,
                        edgecolor="none", zorder=3)
            ax.add_patch(p)
            p.set_clip_path(clip)
            e = Polygon(xy, closed=True, facecolor="none", edgecolor=INK2, lw=0.45, zorder=4)
            ax.add_patch(e)
            e.set_clip_path(clip)
        lat, lon = feat["properties"]["cq_zone_name_loc"]
        x, y = equal_earth(lon, lat)
        ax.text(x, y, str(z), ha="center", va="center", fontsize=7.5 if z != 14 else 9,
                fontweight="bold", color=INK, zorder=6,
                path_effects=[pe.withStroke(linewidth=2.2, foreground=SURFACE)])

    mx, my = equal_earth(-3.7038, 40.4168)
    ax.plot(mx, my, marker="*", ms=7, color=INK, mec=SURFACE, mew=0.8, zorder=7)
    ax.annotate("Madrid", (mx, my), xytext=(-31, 4), textcoords="offset points", fontsize=7,
                color=INK, zorder=7, path_effects=[pe.withStroke(linewidth=2, foreground=SURFACE)])
    ax.set_xlim(-2.75, 2.75)
    ax.set_ylim(-1.34, 1.34)
    save(fig, "mapa_zonas_cq")


if __name__ == "__main__":
    main()
