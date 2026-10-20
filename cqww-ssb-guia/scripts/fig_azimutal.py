"""Mapa acimutal equidistante centrado en Madrid: en esta proyección el camino
corto (círculo máximo) es una recta desde el centro, el ángulo es el rumbo y la
distancia al centro es la distancia real. Destinos de data/knowledge/muf_rumbos.csv.

La antípoda de Madrid cae en tierra (Nueva Zelanda), así que la tierra se
dibuja en raster: cada píxel del plano se proyecta al revés a lat/lon y se
comprueba contra las costas de Natural Earth (1:110m), con supermuestreo para
suavizar el borde. Lo demás (anillos, rumbos, destinos) es vectorial.

Salidas: assets/mapa_azimutal.{pdf,png} (figura del capítulo de conocimientos)
         assets/portada_azimutal.{pdf,png} (decorativa, fondo transparente)
"""
from __future__ import annotations

import csv
import json

import matplotlib.patheffects as pe
import numpy as np
import shapely
from matplotlib.colors import to_rgb
from matplotlib.patches import Circle
from shapely.geometry import shape

from figlib import ASSETS, AXIS, GRID, INK, INK2, MUTED, ROOT, SERIES, SURFACE, plt, save, setup

R = 6371.0                       # radio terrestre medio (km)
LAT0, LON0 = 40.4168, -3.7038    # Madrid (Puerta del Sol)
RMAX = np.pi * R                 # borde del disco: la antípoda (≈ 20.015 km)
LAND = "#e6e4dc"
OCEAN = "#ffffff"
ORANGE = "#f2a65a"


# --------------------------------------------------------------- proyección
def forward(lat, lon):
    """lat/lon (grados) → x, y (km) en la acimutal equidistante de Madrid."""
    p0, l0 = np.radians(LAT0), np.radians(LON0)
    p, lam = np.radians(np.asarray(lat, float)), np.radians(np.asarray(lon, float))
    cosc = np.sin(p0) * np.sin(p) + np.cos(p0) * np.cos(p) * np.cos(lam - l0)
    c = np.arccos(np.clip(cosc, -1, 1))
    k = np.where(c > 1e-12, c / np.sin(np.where(c > 1e-12, c, 1)), 1.0)
    x = R * k * np.cos(p) * np.sin(lam - l0)
    y = R * k * (np.cos(p0) * np.sin(p) - np.sin(p0) * np.cos(p) * np.cos(lam - l0))
    return x, y


def inverse(x, y):
    """x, y (km) → lat/lon (grados)."""
    p0, l0 = np.radians(LAT0), np.radians(LON0)
    rho = np.hypot(x, y)
    c = rho / R
    safe = np.where(rho > 0, rho, 1.0)
    lat = np.arcsin(np.clip(np.cos(c) * np.sin(p0) + y * np.sin(c) * np.cos(p0) / safe, -1, 1))
    lon = l0 + np.arctan2(x * np.sin(c), rho * np.cos(p0) * np.cos(c) - y * np.sin(p0) * np.sin(c))
    return np.degrees(lat), (np.degrees(lon) + 180) % 360 - 180


def polar(az_deg, d_km):
    a = np.radians(az_deg)
    return d_km * np.sin(a), d_km * np.cos(a)


# --------------------------------------------------------------- tierra
def land_coverage(n: int = 1700, ss: int = 2):
    """Fracción de tierra y de disco en cada píxel (n × n, supermuestreo ss × ss)."""
    feats = json.load(open(ROOT / "data/geo/ne_110m_land.geojson", encoding="utf-8"))["features"]
    polys = []
    for f in feats:
        g = shapely.make_valid(shape(f["geometry"]))
        polys += [p for p in getattr(g, "geoms", [g]) if p.geom_type == "Polygon"]
    land = shapely.MultiPolygon(polys)
    shapely.prepare(land)
    m = n * ss
    t = (np.arange(m) + 0.5) / m * 2 * RMAX - RMAX
    X, Y = np.meshgrid(t, t)          # fila 0 = abajo (origin="lower")
    inside = np.hypot(X, Y) <= RMAX
    lat, lon = inverse(X[inside], Y[inside])
    hit = np.zeros(X.shape, bool)
    hit[inside] = shapely.contains_xy(land, lon, lat)
    cov = hit.reshape(n, ss, n, ss).mean(axis=(1, 3))
    disk = inside.reshape(n, ss, n, ss).mean(axis=(1, 3))
    return cov, disk


def land_image(cov, disk, land_rgba, ocean_rgba):
    """Imagen RGBA: mezcla tierra/océano dentro del disco, transparente fuera."""
    lr, la = np.array(land_rgba[:3]), land_rgba[3]
    orr, oa = np.array(ocean_rgba[:3]), ocean_rgba[3]
    sea = np.clip(disk - cov, 0, 1)
    a = cov * la + sea * oa
    rgb = (cov[..., None] * la * lr + sea[..., None] * oa * orr) / np.where(a > 0, a, 1)[..., None]
    return np.dstack([rgb, a])


# --------------------------------------------------------------- datos
def destinos():
    rows = list(csv.DictReader(open(ROOT / "data/knowledge/muf_rumbos.csv", encoding="utf-8")))
    out = []
    for r in rows:
        lat, lon = float(r["lat"]), float(r["lon"])
        x, y = forward(lat, lon)
        # comprobación: la posición proyectada coincide con rumbo y distancia del CSV
        az = np.degrees(np.arctan2(x, y)) % 360
        d = np.hypot(x, y)
        assert abs((az - float(r["rumbo_sp_grados"]) + 180) % 360 - 180) < 1.0, r["destino"]
        assert abs(d - float(r["distancia_sp_km"])) < 15, (r["destino"], d)
        out.append(dict(nombre=r["destino"], x=float(x), y=float(y),
                        rumbo=int(r["rumbo_sp_grados"]), km=int(r["distancia_sp_km"])))
    return out


def miles(n: int) -> str:
    return f"{n:,}".replace(",", ".")


# Posición del rótulo de cada destino respecto a su punto: (dx, dy) en puntos
# tipográficos y alineación horizontal; «arriba»/«abajo» indican si el bloque
# de dos líneas queda por encima o por debajo de (dx, dy).
ROTULOS = {
    "Nueva York": (-6, -3, "right", "centro"),
    "Chicago": (-5, 4, "right", "arriba"),
    "Los Ángeles": (-6, 1, "right", "centro"),
    "San Juan (Puerto Rico)": (-6, -1, "right", "centro"),
    "São Paulo": (6, -2, "left", "centro"),
    "Buenos Aires": (-6, -2, "right", "centro"),
    "Dakar": (-4, -5, "left", "abajo"),
    "Nairobi": (6, 0, "left", "centro"),
    "Johannesburgo": (6, -1, "left", "centro"),
    "Nueva Delhi": (5, 1, "left", "arriba"),
    "Novosibirsk": (6, 3, "left", "centro"),
    "Tokio": (6, 0, "left", "centro"),
    "Yakarta": (2, -5, "center", "abajo"),
    "Sídney": (-2, 5, "center", "arriba"),
    "Honolulu": (-6, 0, "right", "centro"),
}
NOMBRE_CORTO = {"San Juan (Puerto Rico)": "San Juan (Puerto Rico)"}


def rotulo(ax, x, y, nombre, sub, dx, dy, ha, donde, halo):
    kw = dict(xy=(x, y), xycoords="data", textcoords="offset points", ha=ha,
              path_effects=halo, zorder=8, annotation_clip=False)
    if donde == "centro":
        ax.annotate(nombre, xytext=(dx, dy + 0.6), va="bottom", fontsize=7, fontweight="semibold", color=INK, **kw)
        ax.annotate(sub, xytext=(dx, dy - 0.4), va="top", fontsize=6.5, color=INK2, **kw)
    elif donde == "arriba":
        ax.annotate(sub, xytext=(dx, dy), va="bottom", fontsize=6.5, color=INK2, **kw)
        ax.annotate(nombre, xytext=(dx, dy + 7.6), va="bottom", fontsize=7, fontweight="semibold", color=INK, **kw)
    else:  # abajo
        ax.annotate(nombre, xytext=(dx, dy), va="top", fontsize=7, fontweight="semibold", color=INK, **kw)
        ax.annotate(sub, xytext=(dx, dy - 8.6), va="top", fontsize=6.5, color=INK2, **kw)


# --------------------------------------------------------------- figuras
def mapa(cov, disk) -> None:
    setup()
    fig = plt.figure(figsize=(6.5, 6.5))
    ax = fig.add_axes([0.035, 0.035, 0.93, 0.93])
    lim = RMAX * 1.075
    ax.set_xlim(-lim, lim)
    ax.set_ylim(-lim, lim)
    ax.set_aspect("equal")
    ax.axis("off")
    img = land_image(cov, disk, (*to_rgb(LAND), 1.0), (*to_rgb(OCEAN), 1.0))
    ax.imshow(img, extent=(-RMAX, RMAX, -RMAX, RMAX), origin="lower", interpolation="none", zorder=1)
    halo = [pe.withStroke(linewidth=2.4, foreground=OCEAN)]

    # rumbos cada 30° y anillos de distancia
    for az in range(0, 360, 30):
        x, y = polar(az, RMAX)
        ax.plot([0, x], [0, y], color=GRID, lw=0.45, zorder=2, solid_capstyle="butt")
        tx, ty = polar(az, RMAX * 1.035)
        card = {0: " N", 90: " E", 180: " S", 270: " O"}.get(az, "")
        ha = "center" if az in (0, 180) else ("left" if az < 180 else "right")
        va = "bottom" if az in (0, 30, 330) else ("top" if az in (150, 180, 210) else "center")
        ax.text(tx, ty, f"{az}°{card}", fontsize=6.5, color=INK2, ha=ha, va=va, zorder=8)
    for d in (2500, 5000, 10000, 15000):
        ax.add_patch(Circle((0, 0), d, fill=False, ec=GRID if d == 2500 else AXIS,
                            lw=0.45 if d == 2500 else 0.55, zorder=2))
    for d in (5000, 10000, 15000):   # rótulos de los anillos, en el hueco del rumbo 255°
        x, y = polar(255, d)
        ax.text(x, y, f"{miles(d)} km", fontsize=6.5, color=MUTED, ha="center", va="center", zorder=7,
                path_effects=[pe.withStroke(linewidth=2.6, foreground=OCEAN)])
    ax.add_patch(Circle((0, 0), RMAX, fill=False, ec=AXIS, lw=0.6, zorder=3))

    # continentes (rótulo tenue, en mayúsculas espaciadas)
    # (rumbo, distancia) elegidos en huecos entre las rectas y sobre tierra
    for txt, az, d in (("EUROPA", 23, 2000), ("ÁFRICA", 115, 5400), ("SUDAMÉRICA", 240, 7700),
                       ("NORTE\nAMÉRICA", 324, 7150), ("ASIA", 58, 5500), ("OCEANÍA", 93, 15000),
                       ("ANTÁRTIDA", 172, 14200)):
        x, y = polar(az, d)
        ax.text(x, y, txt, fontsize=6.5, color=MUTED, ha="center", va="center", zorder=4, linespacing=1.05,
                fontweight="medium", path_effects=[pe.withStroke(linewidth=2, foreground=LAND)])

    # destinos: recta desde Madrid (camino corto), punto y rótulo
    for dst in destinos():
        ax.plot([0, dst["x"]], [0, dst["y"]], color=SERIES[0], lw=0.8, alpha=0.75, zorder=5,
                solid_capstyle="round")
    for dst in destinos():
        ax.plot(dst["x"], dst["y"], "o", ms=4.6, color=SERIES[0], mec=OCEAN, mew=0.9, zorder=6)
        dx, dy, ha, donde = ROTULOS[dst["nombre"]]
        sub = f"{dst['rumbo']}° · {miles(int(round(dst['km'], -1)))} km"
        rotulo(ax, dst["x"], dst["y"], NOMBRE_CORTO.get(dst["nombre"], dst["nombre"]), sub,
               dx, dy, ha, donde, halo)
    ax.plot(0, 0, "o", ms=6, color=SERIES[1], mec=OCEAN, mew=1.1, zorder=7)
    ax.annotate("Madrid", xy=(0, 0), xytext=(4, -5), textcoords="offset points", ha="left", va="top",
                fontsize=7.5, fontweight="bold", color=INK, path_effects=halo, zorder=8)
    save(fig, "mapa_azimutal")


def portada(cov, disk) -> None:
    setup()
    fig = plt.figure(figsize=(7, 7))
    ax = fig.add_axes([0, 0, 1, 1])
    lim = RMAX * 1.01
    ax.set_xlim(-lim, lim)
    ax.set_ylim(-lim, lim)
    ax.set_aspect("equal")
    ax.axis("off")
    fig.patch.set_alpha(0)
    ax.patch.set_alpha(0)
    img = land_image(cov, disk, (1, 1, 1, 0.16), (1, 1, 1, 0.0))
    ax.imshow(img, extent=(-RMAX, RMAX, -RMAX, RMAX), origin="lower", interpolation="none", zorder=1)
    for az in range(0, 360, 30):
        x, y = polar(az, RMAX)
        ax.plot([0, x], [0, y], color="white", alpha=0.15, lw=0.4, zorder=2)
    for d in (5000, 10000, 15000):
        ax.add_patch(Circle((0, 0), d, fill=False, ec="white", alpha=0.35, lw=0.4, zorder=2))
    ax.add_patch(Circle((0, 0), RMAX, fill=False, ec="white", alpha=0.35, lw=0.4, zorder=2))
    for dst in destinos():
        ax.plot([0, dst["x"]], [0, dst["y"]], color=ORANGE, alpha=0.9, lw=0.9, zorder=4,
                solid_capstyle="round")
        ax.plot(dst["x"], dst["y"], "o", ms=3.2, color=ORANGE, mec="none", zorder=5)
    ax.plot(0, 0, "o", ms=16, color=ORANGE, alpha=0.22, mec="none", zorder=5)
    ax.plot(0, 0, "o", ms=10, color=ORANGE, alpha=0.35, mec="none", zorder=5)
    ax.plot(0, 0, "o", ms=5.5, color=ORANGE, mec="white", mew=0.8, zorder=6)
    for ext in ("pdf", "png"):
        fig.savefig(ASSETS / f"portada_azimutal.{ext}", dpi=200, transparent=True)
    plt.close(fig)


def main() -> None:
    cov, disk = land_coverage()
    mapa(cov, disk)
    portada(cov, disk)
    print("assets/mapa_azimutal.{pdf,png} y assets/portada_azimutal.{pdf,png}")


if __name__ == "__main__":
    main()
