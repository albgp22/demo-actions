"""Bocetos de las tres antenas de terraza del capítulo 9 (EFHW, vertical corta
con acoplador remoto y lazo magnético) sobre la misma silueta de terraza.

Ilustración propia, a escala aproximada (un solo sistema de ejes en metros con
aspecto 1:1); el hilo de la EFHW lleva un corte porque no cabe a escala.
Rótulos coherentes con capitulos/09-equipo.typ y data/equipment/eficiencia_antenas.csv.

Salida: assets/antenas_terraza.{pdf,png}
"""
from __future__ import annotations

import numpy as np
from matplotlib.patches import Arc, Circle, FancyBboxPatch, Polygon, Rectangle

from figlib import AXIS, INK, INK2, MUTED, SERIES, plt, save, setup

RAD = SERIES[0]        # radiadores
FEED = SERIES[1]       # alimentación: coaxial, transformador, choke, acoplador
FEED_FILL = "#fbe3d4"
FACADE = "#f2f1ed"
WALL = "#ebeae4"
SLAB = "#d8d6ce"
GLASS = "#e7eef7"
POLE = "#efe7d2"
LEAD = MUTED           # líneas de referencia de los rótulos
BARS = "#d0cfc7"       # barrotes de la barandilla

FS = 6.5               # rótulos
TW = 6.8               # ancho de la terraza (m)
WALL_W = 3.4           # ancho del cuerpo de la vivienda (m)
FLOOR_Y = 0.07         # altura a la que corre el coaxial por el suelo

# Paneles: origen x y ancho (m)
P1, P2, P3 = (0.0, 12.4), (12.9, 7.9), (21.3, 7.9)
X_MIN, X_MAX = -0.3, 29.35
Y_MIN, Y_MAX = -2.45, 7.3


# ---------------------------------------------------------------- utilidades
def line(ax, xs, ys, color=INK2, lw=0.6, z=4, **kw):
    ax.plot(xs, ys, color=color, lw=lw, zorder=z, solid_capstyle="round",
            solid_joinstyle="round", **kw)


def rect(ax, x, y, w, h, fc, ec=INK2, lw=0.6, z=2):
    ax.add_patch(Rectangle((x, y), w, h, facecolor=fc, edgecolor=ec, linewidth=lw, zorder=z))


LEADERS = []  # (texto, punto de destino): las líneas se trazan al final


def label(ax, x, y, s, ha="left", va="center", to=None, size=FS, color=INK2,
          weight="normal", z=12):
    t = ax.text(x, y, s, ha=ha, va=va, fontsize=size, color=color, weight=weight,
                zorder=z, linespacing=1.15)
    if to is not None:
        LEADERS.append((t, to))
        ax.add_patch(Circle(to, 0.045, facecolor=LEAD, edgecolor="none", zorder=z - 1))
    return t


def draw_leaders(fig, ax, pad=0.12):
    """Línea de referencia desde el borde del rótulo (no desde su centro)."""
    fig.canvas.draw()
    inv = ax.transData.inverted()
    for t, to in LEADERS:
        bb = t.get_window_extent()
        (x0, y0), (x1, y1) = inv.transform([(bb.x0, bb.y0), (bb.x1, bb.y1)])
        x0, y0, x1, y1 = x0 - pad, y0 - pad * 0.5, x1 + pad, y1 + pad * 0.5
        cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
        dx, dy = to[0] - cx, to[1] - cy
        # salida por el lado del rectángulo que corta la recta centro → destino
        ks = []
        if dx:
            ks += [((x1 if dx > 0 else x0) - cx) / dx]
        if dy:
            ks += [((y1 if dy > 0 else y0) - cy) / dy]
        k = min(k for k in ks if k > 0)
        if k >= 1:
            continue
        line(ax, [cx + dx * k, to[0]], [cy + dy * k, to[1]], color=LEAD, lw=0.4, z=11)


def dim_line(ax, p0, p1, z=9):
    """Cota con flechas en los dos extremos."""
    ax.annotate("", xy=p1, xytext=p0, zorder=z,
                arrowprops=dict(arrowstyle="<|-|>", color=INK2, lw=0.5,
                                mutation_scale=4.5, shrinkA=0, shrinkB=0))


def warning_icon(ax, x, y, s=0.2, z=12):
    """Triángulo de aviso centrado en (x, y)."""
    tri = Polygon([(x - s * 0.6, y - s * 0.48), (x + s * 0.6, y - s * 0.48), (x, y + s * 0.55)],
                  closed=True, facecolor=FEED, edgecolor="none", zorder=z)
    ax.add_patch(tri)
    ax.text(x, y - s * 0.1, "!", ha="center", va="center", fontsize=4.0, color="white",
            weight="bold", zorder=z + 1)


def choke(ax, x, y, vertical=True, n=3, z=8):
    """Choke de modo común: pila de ferritas sobre el coaxial."""
    for i in range(n):
        if vertical:
            cx, cy, w, h = x - 0.11, y + i * 0.15 - 0.2, 0.22, 0.12
        else:
            cx, cy, w, h = x + i * 0.15 - 0.2, y - 0.11, 0.12, 0.22
        ax.add_patch(FancyBboxPatch((cx, cy), w, h, boxstyle="round,pad=0,rounding_size=0.035",
                                    facecolor=FEED, edgecolor="none", zorder=z))


# ---------------------------------------------------------------- terraza
def terraza(ax, x0):
    """Alzado de una terraza: fachada, forjado, cuerpo de la vivienda con
    puerta y ventana, y barandilla de barrotes. Los rótulos de lo que va por
    el suelo se colocan sobre la fachada, debajo del forjado."""
    # fachada de la planta de abajo (sin borde inferior: el dibujo se corta)
    rect(ax, x0, Y_MIN, TW, -0.25 - Y_MIN, FACADE, ec="none", z=1)
    line(ax, [x0, x0], [Y_MIN, -0.25], lw=0.6, z=2)
    line(ax, [x0 + TW, x0 + TW], [Y_MIN, -0.25], lw=0.6, z=2)
    # forjado
    rect(ax, x0 - 0.15, -0.25, TW + 0.3, 0.25, SLAB, lw=0.6, z=3)
    # cuerpo de la vivienda (a la izquierda) y alero
    rect(ax, x0, 0, WALL_W, 2.85, WALL, lw=0.6, z=2)
    rect(ax, x0 - 0.15, 2.85, WALL_W + 0.3, 0.22, SLAB, lw=0.6, z=3)
    # puerta de la terraza
    rect(ax, x0 + 0.5, 0, 0.95, 2.0, GLASS, lw=0.6, z=3)
    rect(ax, x0 + 0.6, 0.1, 0.75, 1.8, "none", ec=AXIS, lw=0.4, z=3)
    line(ax, [x0 + 1.27, x0 + 1.27], [0.92, 1.1], lw=0.8, z=3)
    # ventana
    rect(ax, x0 + 2.05, 0.85, 0.95, 1.15, GLASS, lw=0.6, z=3)
    line(ax, [x0 + 2.525] * 2, [0.85, 2.0], color=AXIS, lw=0.4, z=3)
    line(ax, [x0 + 1.97, x0 + 3.08], [0.83, 0.83], lw=0.7, z=3)
    # barandilla: barrotes, pasamanos y postes
    for xb in np.arange(x0 + 0.17, x0 + TW - 0.05, 0.17):
        line(ax, [xb, xb], [0.0, 1.0], color=BARS, lw=0.35, z=5)
    line(ax, [x0, x0 + TW], [1.0, 1.0], lw=1.0, z=6)
    for xp in np.linspace(x0, x0 + TW, 4):
        line(ax, [xp, xp], [0.0, 1.0], lw=0.9, z=6)


def coax_to_house(ax, x0, pts, z=7):
    """Coaxial desde la antena hasta el pasamuros de la vivienda."""
    xs, ys = zip(*pts)
    line(ax, xs, ys, color=FEED, lw=0.9, z=z)
    ax.add_patch(Circle((x0 + WALL_W, 0.38), 0.07, facecolor=INK2, edgecolor="none", zorder=z + 1))


def floor_run(x0, xa):
    """Tramo por el suelo desde x=xa hasta el pasamuros."""
    return [(xa, FLOOR_Y), (x0 + WALL_W + 0.2, FLOOR_Y), (x0 + WALL_W + 0.2, 0.38), (x0 + WALL_W, 0.38)]


# ---------------------------------------------------------------- 1 · EFHW
def efhw(ax):
    x0 = P1[0]
    terraza(ax, x0)
    # edificio cercano (punto alto), cortado por el borde del panel
    bx = x0 + 11.1
    bw = P1[0] + P1[1] - bx
    rect(ax, bx, Y_MIN, bw, 6.95 - Y_MIN, WALL, ec="none", z=1)
    line(ax, [bx, bx, bx + bw], [Y_MIN, 6.95, 6.95], lw=0.6, z=2)
    for wy in np.arange(-1.9, 6.4, 1.55):
        rect(ax, bx + 0.3, wy, 0.7, 0.85, GLASS, lw=0.45, z=2)
    # transformador 49:1 en el poste de la esquina
    tx, ty, tw, th = x0 + TW + 0.12, 1.1, 0.4, 0.32
    line(ax, [x0 + TW, tx], [ty + th / 2] * 2, lw=0.9, z=7)
    rect(ax, tx, ty, tw, th, FEED_FILL, ec=FEED, lw=0.8, z=8)
    # hilo radiante hasta el aislador del edificio (con corte: no está a escala)
    p0 = np.array([tx + tw, ty + th])
    p1 = np.array([bx - 0.55, 4.3])
    d = p1 - p0
    u = d / np.linalg.norm(d)
    n = np.array([-u[1], u[0]])
    m = p0 + d * 0.52
    g = 0.16
    line(ax, [p0[0], (m - u * g)[0]], [p0[1], (m - u * g)[1]], color=RAD, lw=1.3, z=8)
    line(ax, [(m + u * g)[0], p1[0]], [(m + u * g)[1], p1[1]], color=RAD, lw=1.3, z=8)
    for s in (-1, 1):  # marca de corte «//»
        c = m + u * g * 0.55 * s
        a, b = c - n * 0.22 + u * 0.08, c + n * 0.22 - u * 0.08
        line(ax, [a[0], b[0]], [a[1], b[1]], color=INK2, lw=0.6, z=9)
    # aislador y cuerda hasta la esquina
    line(ax, [p1[0], p1[0] + 0.16], [p1[1], p1[1] + 0.03], color=INK, lw=2.0, z=9)
    line(ax, [p1[0] + 0.16, bx], [p1[1] + 0.03, p1[1] + 0.12], color=MUTED, lw=0.5, z=8,
         linestyle=(0, (2, 1.4)))
    # longitud del hilo, junto al tramo superior
    q = m + u * 0.55
    label(ax, q[0] - 0.45, q[1] + 0.55, "≈ 20 m (40–10 m)\n≈ 40 m (80–10 m)", ha="right",
          va="bottom", size=6.8, color=INK)
    # contrapeso corto colgando por fuera de la fachada
    line(ax, [tx + 0.2, tx + 0.42], [ty, -1.05], color=MUTED, lw=0.9, z=8)
    ax.add_patch(Circle((tx + 0.42, -1.05), 0.05, facecolor=MUTED, edgecolor="none", zorder=8))
    # coaxial: choke junto al transformador, baja por el poste y va por el suelo
    cx = x0 + TW - 0.13
    coax_to_house(ax, x0, [(tx, ty + 0.1), (cx, ty + 0.1)] + floor_run(x0, cx))
    choke(ax, cx, 0.62)
    # rótulos
    xl = tx + 0.75   # columna de rótulos entre la esquina y el edificio
    label(ax, x0 + 6.45, 1.85, "transformador\n49:1", ha="right", to=(tx + 0.05, ty + th))
    label(ax, xl, 0.5, "choke de\nmodo común", to=(cx + 0.11, 0.55))
    label(ax, xl, -0.9, "contrapeso\ncorto", to=(tx + 0.37, -0.9))
    label(ax, bx - 0.25, 5.75, "punto alto: esquina de un\nedificio o caña de fibra", ha="right",
          to=(p1[0] + 0.1, p1[1] + 0.06))
    label(ax, x0 + 4.4, -0.95, "coaxial\na casa", ha="center", to=(x0 + 4.4, FLOOR_Y))


# ---------------------------------------------------------------- 2 · vertical
def vertical(ax):
    x0 = P2[0]
    terraza(ax, x0)
    px, h = x0 + 6.52, 7.0
    # caña telescópica de fibra (tramos cada vez más finos)
    secs = [(0.0, 1.85, 0.12), (1.85, 3.6, 0.095), (3.6, 5.3, 0.072), (5.3, h, 0.05)]
    for y0, y1, w in secs:
        rect(ax, px - w / 2, y0, w, y1 - y0, POLE, lw=0.5, z=6)
    rect(ax, px - 0.2, 0.0, 0.4, 0.06, INK2, ec="none", z=7)          # pie
    for yb in (0.45, 0.92):                                           # abrazaderas al poste
        line(ax, [px + 0.06, x0 + TW], [yb, yb], lw=0.9, z=7)
    # acoplador remoto en la base y radiador a lo largo de la caña
    ax0, ay0, aw, ah = x0 + 5.72, 0.22, 0.46, 0.5
    rect(ax, ax0, ay0, aw, ah, FEED_FILL, ec=FEED, lw=0.8, z=8)
    line(ax, [ax0 + aw * 0.7, ax0 + aw * 0.7, px - 0.075, px - 0.03],
         [ay0 + ah, ay0 + ah + 0.22, ay0 + ah + 0.32, h - 0.02], color=RAD, lw=1.3, z=9)
    # radiales en el suelo (en abanico) desde el borne de tierra
    gx, gy = ax0 + 0.06, ay0 + 0.06
    for ex, ey in ((x0 + 1.6, 0.16), (x0 + 2.55, 0.3), (x0 + 3.5, 0.43), (x0 + 4.45, 0.55)):
        line(ax, [gx, ex], [gy, ey], color=MUTED, lw=0.8, z=7)
        ax.add_patch(Circle((ex, ey), 0.045, facecolor=MUTED, edgecolor="none", zorder=7))
    # coaxial con choke hasta la vivienda (por el suelo, debajo de los radiales)
    xa = ax0 + 0.12
    coax_to_house(ax, x0, [(xa, ay0), (xa, FLOOR_Y)] + floor_run(x0, xa))
    choke(ax, x0 + 5.25, FLOOR_Y, vertical=False)
    # cota de altura a la derecha de la caña
    cxd = x0 + TW + 0.33
    dim_line(ax, (cxd, 0.0), (cxd, h))
    for yy in (0.0, h):
        line(ax, [px + 0.08, cxd + 0.1], [yy, yy], color=INK2, lw=0.35, z=8)
    ax.text(cxd + 0.14, h / 2, "≈ 7 m", rotation=90, ha="left", va="center", fontsize=6.8,
            color=INK, zorder=12)
    # rótulos
    label(ax, x0 + 5.7, 5.9, "hilo radiante", ha="right", to=(px - 0.05, 5.9))
    label(ax, x0 + 5.7, 4.65, "caña de fibra\ntelescópica", ha="right", to=(px - 0.04, 4.65))
    label(ax, x0 + 5.5, 1.75, "acoplador\nremoto", ha="right", to=(ax0 + 0.12, ay0 + ah))
    label(ax, x0 + 2.3, -0.95, "radiales por el\nsuelo (o elevados)", ha="center",
          to=(x0 + 2.55, 0.3))
    label(ax, x0 + 5.25, -0.8, "choke", ha="center", to=(x0 + 5.25, FLOOR_Y - 0.12))


# ---------------------------------------------------------------- 3 · lazo
def lazo(ax):
    x0 = P3[0]
    terraza(ax, x0)
    mx, mh = x0 + 4.75, 2.25
    # mástil corto con trípode
    rect(ax, mx - 0.035, 0.0, 0.07, mh, MUTED, ec=INK2, lw=0.4, z=6)
    for dx in (-0.42, 0.42):
        line(ax, [mx, mx + dx], [0.42, 0.0], lw=0.7, z=6)
    # caja del condensador
    bw, bh = 0.46, 0.3
    rect(ax, mx - bw / 2, mh, bw, bh, FEED_FILL, ec=FEED, lw=0.8, z=8)
    # aro principal (Ø 1,2 m) apoyado en la caja
    r = 0.6
    cy = mh + bh + r - 0.02
    gap = 16
    ax.add_patch(Arc((mx, cy), 2 * r, 2 * r, theta1=-90 + gap, theta2=270 - gap,
                     color=RAD, lw=2.2, zorder=9))
    for s in (-1, 1):
        a = np.radians(-90 + gap * s)
        line(ax, [mx + r * np.cos(a), mx + s * 0.1], [cy + r * np.sin(a), mh + bh],
             color=RAD, lw=2.2, z=9)
    # lazo de acoplamiento arriba y coaxial por el centro y el mástil
    rc = 0.13
    ccy = cy + r - rc - 0.04
    ax.add_patch(Circle((mx, ccy), rc, facecolor="none", edgecolor=FEED, lw=0.9, zorder=10))
    xa = mx + 0.07
    coax_to_house(ax, x0, [(mx, ccy - rc), (mx, mh + bh), (xa, mh), (xa, FLOOR_Y)]
                  + floor_run(x0, xa))
    # cable de control del motor del condensador (discontinuo)
    xc = mx - 0.12
    line(ax, [xc, xc, x0 + WALL_W + 0.42, x0 + WALL_W + 0.42, x0 + WALL_W],
         [mh, 0.28, 0.28, 0.62, 0.62], color=FEED, lw=0.7, z=7, linestyle=(0, (2.2, 1.4)))
    ax.add_patch(Circle((x0 + WALL_W, 0.62), 0.06, facecolor=INK2, edgecolor="none", zorder=8))
    # cota del diámetro
    ytop = cy + r + 0.3
    dim_line(ax, (mx - r, ytop), (mx + r, ytop))
    for xx in (mx - r, mx + r):
        line(ax, [xx, xx], [cy, ytop + 0.1], color=INK2, lw=0.35, z=8)
    ax.text(mx, ytop + 0.16, "Ø 1–1,5 m", ha="center", va="bottom", fontsize=6.8, color=INK,
            zorder=12)
    # rótulos a la derecha (cielo libre) y a la izquierda
    xr = mx + r + 0.4
    label(ax, xr, ccy + 0.1, "lazo de\nacoplamiento", to=(mx + rc, ccy))
    label(ax, xr, mh + 0.05, "caja del\ncondensador", to=(mx + bw / 2, mh + bh / 2))
    warning_icon(ax, xr + 0.12, mh - 0.62)
    label(ax, xr + 0.34, mh - 0.62, "soporta kV", color=INK, weight="semibold")
    label(ax, x0 + 4.3, 1.45, "mástil", ha="right", to=(mx - 0.04, 1.45))
    label(ax, x0 + 4.6, -0.95, "coaxial y cable\nde control", ha="center",
          to=(x0 + 4.6, FLOOR_Y))


# ---------------------------------------------------------------- rótulos
CAPTIONS = [
    (P1, "EFHW multibanda",
     "40–10 m con ≈ 20 m de hilo; también 80 m con ≈ 40 m",
     "+ La que más rinde por euro  ·  − Pide sitio y choke"),
    (P2, "Vertical corta + acoplador",
     "40–10 m bien; 80/160 m: −6 a −15 dB",
     "+ Poco suelo  ·  − Pide buenos radiales"),
    (P3, "Lazo magnético",
     "20–10 m bien; 40 m justo; 80/160 m mal",
     "+ Cabe en todas partes  ·  − Muy estrecho"),
]


def main() -> None:
    setup()
    fig_w, cap_h = 6.7, 0.52
    sk_h = fig_w * (Y_MAX - Y_MIN) / (X_MAX - X_MIN)
    fig = plt.figure(figsize=(fig_w, sk_h + cap_h))
    ax = fig.add_axes([0, cap_h / (sk_h + cap_h), 1, sk_h / (sk_h + cap_h)])
    ax.set_xlim(X_MIN, X_MAX)
    ax.set_ylim(Y_MIN, Y_MAX)
    ax.set_aspect("equal")
    ax.axis("off")
    efhw(ax)
    vertical(ax)
    lazo(ax)
    draw_leaders(fig, ax)

    cap = fig.add_axes([0, 0, 1, cap_h / (sk_h + cap_h)])
    cap.set_xlim(X_MIN, X_MAX)
    cap.set_ylim(0, 1)
    cap.axis("off")
    for (x0, w), name, l2, l3 in CAPTIONS:
        xc = x0 + w / 2
        cap.text(xc, 0.84, name, ha="center", va="center", fontsize=8, weight="semibold", color=INK)
        cap.text(xc, 0.5, l2, ha="center", va="center", fontsize=6.6, color=INK2)
        cap.text(xc, 0.18, l3, ha="center", va="center", fontsize=6.6, color=INK2)
    print(f"tamaño: {fig_w:.2f} × {sk_h + cap_h:.2f} in")
    save(fig, "antenas_terraza")


if __name__ == "__main__":
    main()
