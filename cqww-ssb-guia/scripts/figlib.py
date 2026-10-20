"""Estilo común de las figuras (paleta validada de la skill dataviz) y utilidades
cartográficas: proyección Equal Earth y posición del Sol."""
from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path

import matplotlib
import numpy as np

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "assets"
ASSETS.mkdir(exist_ok=True)

# Paleta categórica (orden fijo) y tinta
SERIES = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4", "#008300", "#6250d6", "#e34948"]
SURFACE = "#fcfcfb"
INK = "#0b0b0b"
INK2 = "#52514e"
MUTED = "#898781"
GRID = "#e1e0d9"
AXIS = "#c3c2b7"
BLUE_RAMP = {100: "#cde2fb", 200: "#9ec5f4", 300: "#6da7ec", 400: "#3987e5",
             500: "#256abf", 600: "#184f95", 700: "#0d366b"}
# Bandas del concurso → color fijo (no cambia entre figuras)
BAND_COLORS = {160: SERIES[0], 80: SERIES[1], 40: SERIES[2], 20: SERIES[3], 15: SERIES[4], 10: SERIES[5]}


def setup() -> None:
    plt.rcParams.update({
        "font.family": "Inter",
        "font.size": 8,
        "axes.edgecolor": AXIS,
        "axes.labelcolor": INK2,
        "axes.titlecolor": INK,
        "axes.titlesize": 9,
        "axes.titleweight": "semibold",
        "xtick.color": MUTED,
        "ytick.color": MUTED,
        "xtick.labelcolor": INK2,
        "ytick.labelcolor": INK2,
        "axes.grid": False,
        "grid.color": GRID,
        "grid.linewidth": 0.6,
        "figure.facecolor": SURFACE,
        "axes.facecolor": SURFACE,
        "savefig.facecolor": SURFACE,
        "legend.frameon": False,
        "pdf.fonttype": 42,
        "svg.fonttype": "path",
    })


def save(fig, name: str) -> None:
    for ext in ("pdf", "png"):
        fig.savefig(ASSETS / f"{name}.{ext}", dpi=200, bbox_inches="tight", pad_inches=0.03)
    plt.close(fig)


# --- Proyección Equal Earth (Šavrič, Patterson y Jenny, 2018) ----------------
_A1, _A2, _A3, _A4 = 1.340264, -0.081106, 0.000893, 0.003796


def equal_earth(lon, lat):
    lam = np.radians(np.asarray(lon, dtype=float))
    phi = np.radians(np.asarray(lat, dtype=float))
    th = np.arcsin(np.sqrt(3) / 2 * np.sin(phi))
    th2, th6 = th ** 2, th ** 6
    x = 2 * np.sqrt(3) * lam * np.cos(th) / (3 * (9 * _A4 * th6 * th2 + 7 * _A3 * th6 + 3 * _A2 * th2 + _A1))
    y = _A4 * th ** 9 + _A3 * th ** 7 + _A2 * th ** 3 + _A1 * th
    return x, y


def densify(ring, step=1.0):
    """Interpola los lados de un anillo lon/lat para que se curven al proyectar."""
    out = []
    ring = list(ring)
    for (x0, y0), (x1, y1) in zip(ring, ring[1:] + ring[:1]):
        n = max(1, int(max(abs(x1 - x0), abs(y1 - y0)) / step))
        for i in range(n):
            t = i / n
            out.append((x0 + (x1 - x0) * t, y0 + (y1 - y0) * t))
    return out


def outline_path():
    """Contorno del mapa (meridianos ±180°) proyectado, para recortar."""
    from matplotlib.path import Path as MPath
    lats = np.linspace(-90, 90, 181)
    xs1, ys1 = equal_earth(np.full_like(lats, 180.0), lats)
    xs2, ys2 = equal_earth(np.full_like(lats, -180.0), lats[::-1])
    verts = np.column_stack([np.concatenate([xs1, xs2]), np.concatenate([ys1, ys2])])
    return MPath(verts, closed=True)


def rings_of(geom):
    if geom["type"] == "Polygon":
        return [geom["coordinates"]]
    if geom["type"] == "MultiPolygon":
        return geom["coordinates"]
    return []


# --- Posición del Sol (algoritmo NOAA implementado por la librería astral) ---
def subsolar_point(t: datetime):
    """Latitud y longitud del punto subsolar (grados) en el instante t."""
    import astral.julian as aj
    import astral.sun as asun
    t = t.astimezone(timezone.utc)
    jc = aj.julianday_to_juliancentury(aj.julianday(t))
    decl = asun.sun_declination(jc)
    eqtime = asun.eq_of_time(jc)  # minutos
    hour = t.hour + t.minute / 60 + t.second / 3600
    lon = -15 * (hour - 12) - eqtime / 4
    return decl, (lon + 180) % 360 - 180


def solar_elevation(lat, lon, t: datetime):
    dec, slon = subsolar_point(t)
    la, lo, d = np.radians(lat), np.radians(lon), np.radians(dec)
    cosz = np.sin(la) * np.sin(d) + np.cos(la) * np.cos(d) * np.cos(lo - np.radians(slon))
    return np.degrees(np.arcsin(np.clip(cosz, -1, 1)))
