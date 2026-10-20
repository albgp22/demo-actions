"""El fin de semana del CQ WW SSB 2026 de un vistazo: las 48 horas en UTC y en
hora de Madrid (con el cambio de hora), día y noche en Madrid con la línea gris
y, por banda, las horas en que el modelo da la banda abierta.

Datos:
  data/calc/orto_ocaso.csv        orto y ocaso en Madrid (calc_tiempos.py)
  data/knowledge/muf_ventanas.csv ventanas MUF (IRI, F10.7 = 120, 25-oct-2026, trayecto corto)
  data/calc/ventanas_noche.csv    noche en todo el trayecto (bandas bajas)
Los rótulos de destino siguen data/calc/plan_bandas.csv; el script comprueba que
cada rótulo está respaldado por el modelo en su franja.

Salida: assets/fin_de_semana_2026.{pdf,png}
"""
from __future__ import annotations

import csv

import matplotlib.colors as mcolors
from matplotlib.patches import FancyBboxPatch, Rectangle

from figlib import BAND_COLORS, GRID, INK, INK2, MUTED, ROOT, SURFACE, plt, save, setup

FECHA_MUF, F107 = "2026-10-25", "120"
NOCHE = "#d3dbe7"        # noche en Madrid (franja superior)
NOCHE_SUAVE = "#f1f4f8"  # noche en Madrid (fondo de los carriles)
GRIS = "#8f9bb0"         # línea gris (franja superior)
GRIS_SUAVE = "#e3e8ef"   # línea gris (fondo de los carriles)
DIA = "#fbf6e9"

# Rótulos por banda y franja UTC, tomados de la columna «chuleta» de
# data/calc/plan_bandas.csv (se comprueban contra el modelo más abajo).
ROTULOS = {
    10: [(7, 10, "AF·VU"), (10, 13, "AF·SA"), (13, 17, "NA·KP4·SA"), (17, 20, "W6·SA"), (20, 24.5, "SA")],
    15: [(7, 10, "JA·AF"), (10, 13, "NA·AF"), (13, 17, "NA·W6·SA"), (17, 20, "W6·KH6"), (20, 27.5, "SA")],
    20: [(0, 4, "SA·ZS"), (4, 7, "Asia·VK"), (7, 10, "JA·VK"), (10, 17, "NA"), (17, 20, "W6·KH6"),
         (20, 24, "NA·SA")],
    40: [(4, 6.75, "W6·KH6"), (17.5, 22, "Asia·AF"), (22, 28, "NA·SA")],
    80: [(4, 6.75, "W6·KH6"), (17.5, 22, "Asia·AF"), (22, 28, "NA·SA")],
    160: [(22, 28, "NA·SA")],
}
# (inicio, fin, rótulo) en horas UTC; un fin > 24 sigue en el día siguiente.
# Qué destinos del modelo respaldan cada rótulo
RESPALDO = {
    "NA": ["Nueva York", "Chicago"], "W6": ["Los Ángeles"], "KP4": ["San Juan (Puerto Rico)"],
    "SA": ["São Paulo", "Buenos Aires"], "AF": ["Dakar", "Nairobi", "Johannesburgo"],
    "ZS": ["Johannesburgo"], "VU": ["Nueva Delhi"], "JA": ["Tokio"], "VK": ["Sídney"],
    "KH6": ["Honolulu"], "Asia": ["Nueva Delhi", "Novosibirsk", "Tokio", "Yakarta"],
}
# 160 m: el plan solo lo propone hacia Norteamérica, el Caribe y Sudamérica
DESTINOS_160 = ["Nueva York", "Chicago", "Los Ángeles", "San Juan (Puerto Rico)", "São Paulo", "Buenos Aires"]


def hm(s: str) -> float:
    h, m = s.strip().split(":")
    return int(h) + int(m) / 60


def tramos(texto: str) -> list[tuple[float, float]]:
    """'08:15-05:15, 06:45-07:15' → [(8.25, 24), (0, 5.25), (6.75, 7.25)] (cruza medianoche)."""
    texto = texto.strip()
    if texto in ("", "-"):
        return []
    out = []
    for parte in texto.split(","):
        a, b = (hm(x) for x in parte.split("-"))
        out += [(a, b)] if b > a else [(a, 24.0), (0.0, b)]
    return out


def union(iv):
    out = []
    for a, b in sorted(iv):
        if out and a <= out[-1][1] + 1e-9:
            out[-1] = (out[-1][0], max(out[-1][1], b))
        else:
            out.append((a, b))
    return out


def solape(iv, a, b) -> float:
    """Horas de la lista iv (dominio 0–24) dentro de [a, b], que puede pasar de 24."""
    partes = [(a, min(b, 24.0))] + ([(0.0, b - 24.0)] if b > 24 else [])
    return sum(max(0.0, min(q, y) - max(p, x)) for p, q in partes for x, y in iv)


def tinte(color: str, k: float) -> tuple:
    """Mezcla el color con la superficie: k = 1 color puro, k = 0 superficie."""
    c, s = mcolors.to_rgb(color), mcolors.to_rgb(SURFACE)
    return tuple(k * ci + (1 - k) * si for ci, si in zip(c, s))


def leer():
    muf = [r for r in csv.DictReader(open(ROOT / "data/knowledge/muf_ventanas.csv", encoding="utf-8"))
           if r["fecha"] == FECHA_MUF and r["f107"] == F107 and r["trayecto"] == "SP"]
    noche = {r["destino"]: tramos(r["noche_en_todo_el_trayecto_utc"])
             for r in csv.DictReader(open(ROOT / "data/calc/ventanas_noche.csv", encoding="utf-8"))}
    sol = {r["fecha"]: (hm(r["orto_utc"]), hm(r["ocaso_utc"]))
           for r in csv.DictReader(open(ROOT / "data/calc/orto_ocaso.csv", encoding="utf-8"))
           if r["lugar"].startswith("Madrid")}
    por_banda: dict[int, dict[str, list]] = {10: {}, 15: {}, 20: {}}
    for r in muf:
        por_banda[int(r["banda"].split()[0])][r["destino"]] = tramos(r["ventanas_utc_muf_sobre_umbral"])
    for b in (40, 80):
        por_banda[b] = dict(noche)
    por_banda[160] = {d: noche[d] for d in DESTINOS_160}
    return por_banda, sol


def comprobar(por_banda) -> None:
    for banda, lista in ROTULOS.items():
        for a, b, txt in lista:
            for token in txt.split("·"):
                horas = max(solape(por_banda[banda].get(d, []), a, b) for d in RESPALDO[token])
                if horas < min(1.0, (b - a) / 2):
                    print(f"AVISO {banda} m {a}-{b} UTC: «{token}» sin respaldo en el modelo ({horas:.2f} h)")


def main() -> None:
    setup()
    por_banda, sol = leer()
    comprobar(por_banda)
    (orto1, ocaso1), (orto2, ocaso2) = sol["2026-10-24"], sol["2026-10-25"]
    CAMBIO = 25.0  # domingo 01:00 UTC

    fig = plt.figure(figsize=(6.7, 3.0))
    ax = fig.add_axes([0.075, 0.185, 0.915, 0.80])
    ylim = (-0.62, 8.85)
    ax.set_xlim(0, 48)
    ax.set_ylim(*ylim)
    for s in ("top", "right", "left"):
        ax.spines[s].set_visible(False)
    ax.spines["bottom"].set_color(MUTED)
    ax.spines["bottom"].set_linewidth(0.6)
    ax.set_yticks([])

    # Relación de aspecto (para redondear las barras sin deformarlas)
    pos = ax.get_position()
    asp = ((ylim[1] - ylim[0]) / (pos.height * fig.get_figheight())) / (48 / (pos.width * fig.get_figwidth()))

    carril = {b: 5 - i for i, b in enumerate((10, 15, 20, 40, 80, 160))}
    y0, y1 = -0.5, 5.5

    # Fondo: noche y línea gris en Madrid, a lo largo de los carriles
    noches = [(0, orto1), (ocaso1, 24 + orto2), (24 + ocaso2, 48)]
    grises = [(t - 0.5, t + 0.5) for t in (orto1, ocaso1, 24 + orto2, 24 + ocaso2)]
    for a, b in noches:
        ax.add_patch(Rectangle((a, y0), b - a, y1 - y0, color=NOCHE_SUAVE, lw=0, zorder=0))
    for a, b in grises:
        ax.add_patch(Rectangle((a, y0), b - a, y1 - y0, color=GRIS_SUAVE, lw=0, zorder=0.1))
    for h in range(49):
        ax.plot([h, h], [y0, y1], color=GRID, lw=0.5 if h % 3 == 0 else 0.25, zorder=0.2)
    for y in (4.5, 3.5, 2.5, 1.5, 0.5):
        ax.plot([0, 48], [y, y], color=GRID, lw=0.4, zorder=0.2)

    # Franja superior: día, noche y línea gris
    fy, fh = 5.85, 0.55
    ax.add_patch(Rectangle((0, fy), 48, fh, color=DIA, lw=0, zorder=1))
    for a, b in noches:
        ax.add_patch(Rectangle((a, fy), b - a, fh, color=NOCHE, lw=0, zorder=1.1))
    for a, b in grises:
        ax.add_patch(Rectangle((a, fy), b - a, fh, color=GRIS, lw=0, zorder=1.2))
    ym = fy + fh / 2
    ax.text(-0.35, ym, "Madrid", ha="right", va="center", fontsize=7, color=INK2)
    for x in (3.2, 28.0):
        ax.text(x, ym, "noche", ha="center", va="center", fontsize=6.2, color=INK2, zorder=2)
    for a, b in ((orto1, ocaso1), (24 + orto2, 24 + ocaso2)):
        ax.text((a + b) / 2 + 0.9, ym, "día", ha="center", va="center", fontsize=6.2, color=INK2, zorder=2)
    for dia, fecha in ((0, "2026-10-24"), (24, "2026-10-25")):
        o, c = sol[fecha]
        ax.text(dia + o + 0.62, ym, f"orto {hhmm(o)}", ha="left", va="center", fontsize=5.8, color=INK2, zorder=2)
        ax.text(dia + c + 0.62, ym, f"ocaso {hhmm(c)}", ha="left", va="center", fontsize=5.8, color=INK2, zorder=2)

    # Carriles por banda
    for banda, y in carril.items():
        col = BAND_COLORS[banda]
        ax.add_patch(Rectangle((-0.75, y - 0.3), 0.3, 0.6, color=col, lw=0, clip_on=False))
        ax.text(-1.0, y, f"{banda} m", ha="right", va="center", fontsize=7.4, color=INK, fontweight="semibold")
        abiertas = union([iv for lista in por_banda[banda].values() for iv in lista])
        barras = union([(dia + a, dia + b) for dia in (0, 24) for a, b in abiertas])
        if banda == 40:  # 40 m de día: Europa
            for o, c in ((orto1, ocaso1), (24 + orto2, 24 + ocaso2)):
                barra(ax, o + 0.06, c - 0.06, y, tinte(col, 0.16), col, asp, ls=(0, (2, 1.4)))
                ax.text((o + c) / 2, y, "EU (día)", ha="center", va="center", fontsize=6.1, color=INK2, zorder=4)
        for a, b in barras:
            barra(ax, a, b, y, tinte(col, 0.42), col, asp)
        for a, b, txt in ROTULOS[banda]:
            for dia in (-24, 0, 24):
                ra, rb = max(0.0, dia + a), min(48.0, dia + b)
                trozos = [(max(ra, x), min(rb, z)) for x, z in barras if min(rb, z) > max(ra, x)]
                if trozos:
                    rotulo(fig, ax, max(trozos, key=lambda t: t[1] - t[0]), y, txt, CAMBIO)

    # Línea de tiempo: inicio, cambio de hora, fin
    for x in (0, 48):
        ax.plot([x, x], [y0, 7.5], color=INK2, lw=0.9, zorder=5, clip_on=False, solid_capstyle="butt")
    ax.plot([CAMBIO, CAMBIO], [y0, 7.5], color=INK2, lw=0.8, ls=(0, (3, 2)), zorder=5)
    kw = dict(fontsize=6.6, color=INK, linespacing=1.25, va="center")
    ax.text(0.3, 8.15, "Inicio: sábado 00:00 UTC\n(02:00 en Madrid)", ha="left", **kw)
    ax.text(CAMBIO, 8.15, "cambio de hora\n03:00 CEST → 02:00 CET (01:00 UTC)", ha="center", **kw)
    ax.text(47.7, 8.15, "Fin: domingo 23:59 UTC\n(00:59 del lunes en Madrid)", ha="right", **kw)
    # Domingo por la tarde
    bx0, bx1, by = 38, 47.75, 6.8
    ax.plot([bx0, bx0, bx1, bx1], [by - 0.14, by, by, by - 0.14], color=INK2, lw=0.7, zorder=5)
    ax.text(bx1, by + 0.07, "domingo por la tarde: todos buscan QSO", ha="right", va="bottom",
            fontsize=6.2, color=INK2)

    # Eje: UTC y hora de Madrid (CEST hasta el domingo 01:00 UTC, después CET)
    ticks = list(range(0, 49, 3))
    ax.set_xticks(ticks, [utc_rotulo(t) for t in ticks])
    ax.set_xticks(range(49), minor=True)
    ax.tick_params(axis="x", which="major", length=3, width=0.6, color=MUTED, labelsize=6.6, pad=2)
    ax.tick_params(axis="x", which="minor", length=1.5, width=0.4, color=MUTED)
    etiquetas = ax.get_xticklabels()
    etiquetas[0].set_ha("left")
    etiquetas[-1].set_ha("right")
    tr = ax.get_xaxis_transform()
    yl = -0.072
    for t in ticks:
        ha = "left" if t == 0 else "right" if t == 48 else "center"
        ax.text(t, yl, madrid_rotulo(t), transform=tr, ha=ha, va="top", fontsize=6.6, color=INK2)
    ax.text(-1.0, -0.017, "UTC", transform=tr, ha="right", va="top", fontsize=6.8, color=INK, fontweight="semibold")
    ax.text(-1.0, yl, "Madrid", transform=tr, ha="right", va="top", fontsize=6.8, color=INK, fontweight="semibold")
    # Días (UTC)
    yd = -0.15
    for a, b, txt in ((0, 24, "sábado 24 de octubre de 2026"), (24, 48, "domingo 25")):
        ax.plot([a + 0.15, a + 0.15, b - 0.15, b - 0.15], [yd + 0.022, yd, yd, yd + 0.022], transform=tr,
                color=MUTED, lw=0.6, clip_on=False)
        ax.text((a + b) / 2, yd - 0.012, txt, transform=tr, ha="center", va="top", fontsize=6.8, color=INK,
                fontweight="semibold", bbox=dict(boxstyle="square,pad=0.2", fc=SURFACE, ec="none"))
    save(fig, "fin_de_semana_2026")


def hhmm(v: float) -> str:
    h = int(v)
    return f"{h:02d}:{round((v - h) * 60):02d}"


def utc_rotulo(t: int) -> str:
    return "24" if t == 48 else f"{t % 24:02d}"


def madrid_rotulo(t: int) -> str:
    local = t + (2 if t < 25 else 1)
    dia = ("sáb", "dom", "lun")[local // 24]
    return f"{dia} {local % 24:02d}" if t == 48 else f"{local % 24:02d}"


def barra(ax, a, b, y, fc, ec, asp, ls="solid", h=0.6):
    ax.add_patch(FancyBboxPatch((a, y - h / 2), b - a, h, boxstyle="round,pad=0,rounding_size=0.18",
                                mutation_aspect=1 / asp, fc=fc, ec=ec, lw=0.7, ls=ls, zorder=3))


def ancho_texto(fig, ax, txt) -> float:
    t = ax.text(0, 0, txt, fontsize=6.1)
    bb = t.get_window_extent(renderer=fig.canvas.get_renderer())
    t.remove()
    inv = ax.transData.inverted()
    (x0, _), (x1, _) = inv.transform([(bb.x0, bb.y0), (bb.x1, bb.y0)])
    return x1 - x0


def rotulo(fig, ax, trozo, y, txt, cambio):
    """Escribe el rótulo centrado en el trozo de barra si cabe, sin pisar la línea del cambio de hora."""
    a, b = trozo
    w = ancho_texto(fig, ax, txt) + 0.3
    huecos = [(a, b)]
    if a < cambio < b:
        huecos = [(a, cambio - 0.15), (cambio + 0.15, b)]
    huecos = [h for h in huecos if h[1] - h[0] >= w]
    if not huecos:
        return
    a, b = max(huecos, key=lambda h: h[1] - h[0])
    ax.text((a + b) / 2, y, txt, ha="center", va="center", fontsize=6.1, color=INK, zorder=4)


if __name__ == "__main__":
    main()
