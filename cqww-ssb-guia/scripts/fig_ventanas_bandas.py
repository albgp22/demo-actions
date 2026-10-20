"""Ventanas de apertura por banda y destino desde Madrid el día del concurso:
10, 15 y 20 m con la MUF del trayecto corto (modelo IRI vía PyIRI,
scripts/know_muf.py; 25-oct-2026, F10.7 = 120) y 40/80/160 m con la noche común
en todo el trayecto (scripts/calc_ventanas.py). En 10 y 15 m se añade la
previsión de 2027 (31-oct-2027, F10.7 = 100).

Datos: data/knowledge/muf_ventanas.csv, data/calc/ventanas_noche.csv,
data/calc/orto_ocaso.csv
Salida: assets/ventanas_bandas.{pdf,png}
"""
from __future__ import annotations

import csv

import matplotlib.colors as mcolors
from matplotlib.lines import Line2D
from matplotlib.patches import FancyBboxPatch, Patch, Rectangle

from figlib import BAND_COLORS, GRID, INK, INK2, MUTED, ROOT, SURFACE, plt, save, setup

NOCHE_SUAVE = "#f1f4f8"
GRIS_SUAVE = "#e3e8ef"
PIZARRA = "#44546a"       # noche en todo el trayecto (40/80/160 m)
VIEJO = INK2              # previsión 2027


def hm(s: str) -> float:
    h, m = s.strip().split(":")
    return int(h) + int(m) / 60


def tramos(texto: str) -> list[tuple[float, float]]:
    texto = texto.strip()
    if texto in ("", "-"):
        return []
    out = []
    for parte in texto.split(","):
        a, b = (hm(x) for x in parte.split("-"))
        out += [(a, b)] if b > a else [(a, 24.0), (0.0, b)]
    return out


def tinte(color: str, k: float) -> tuple:
    c, s = mcolors.to_rgb(color), mcolors.to_rgb(SURFACE)
    return tuple(k * ci + (1 - k) * si for ci, si in zip(c, s))


def rotulo_destino(destino: str, etiqueta: str) -> str:
    pref, zona = etiqueta.split(" / zona ")
    nombre = {"San Juan (Puerto Rico)": "San Juan"}.get(destino, destino)
    return f"{nombre} ({pref}, z{zona})"


def leer():
    filas = list(csv.DictReader(open(ROOT / "data/knowledge/muf_ventanas.csv", encoding="utf-8")))
    destinos, etiquetas = [], {}
    muf, muf27 = {}, {}
    for r in filas:
        if r["trayecto"] != "SP":
            continue
        banda = int(r["banda"].split()[0])
        if r["fecha"] == "2026-10-25" and r["f107"] == "120":
            if r["destino"] not in destinos:
                destinos.append(r["destino"])
                etiquetas[r["destino"]] = r["etiqueta"]
            muf[(banda, r["destino"])] = tramos(r["ventanas_utc_muf_sobre_umbral"])
            muf[("umbral", banda)] = float(r["umbral_mhz"])
        if r["fecha"] == "2027-10-31" and r["f107"] == "100":
            muf27[(banda, r["destino"])] = tramos(r["ventanas_utc_muf_sobre_umbral"])
    noche = {r["destino"]: tramos(r["noche_en_todo_el_trayecto_utc"])
             for r in csv.DictReader(open(ROOT / "data/calc/ventanas_noche.csv", encoding="utf-8"))}
    sol = [(hm(r["orto_utc"]), hm(r["ocaso_utc"]))
           for r in csv.DictReader(open(ROOT / "data/calc/orto_ocaso.csv", encoding="utf-8"))
           if r["lugar"].startswith("Madrid") and r["fecha"] == "2026-10-25"][0]
    return destinos, etiquetas, muf, muf27, noche, sol


def coma(x: float) -> str:
    return f"{x:g}".replace(".", ",")


def main() -> None:
    setup()
    destinos, etiquetas, muf, muf27, noche, (orto, ocaso) = leer()
    n = len(destinos)
    fig = plt.figure(figsize=(6.7, 5.7))
    ejes = [fig.add_axes([0.158, 0.135, 0.33, 0.80]), fig.add_axes([0.657, 0.135, 0.33, 0.80])]
    grupos = [[10, 15], [20, "bajas"]]
    sep = 1.9  # hueco entre grupos (en filas)
    ylim = (2 * n + sep + 0.75, -1.15)

    for ax, par in zip(ejes, grupos):
        ax.set_xlim(0, 24)
        ax.set_ylim(*ylim)
        for s in ("top", "right", "left"):
            ax.spines[s].set_visible(False)
        ax.spines["bottom"].set_color(MUTED)
        ax.spines["bottom"].set_linewidth(0.6)
        pos = ax.get_position()
        asp = ((ylim[0] - ylim[1]) / (pos.height * fig.get_figheight())) / (24 / (pos.width * fig.get_figwidth()))
        ytop, ybot = -0.6, 2 * n + sep + 0.55
        # Fondo: noche y línea gris en Madrid, rejilla horaria
        for a, b in ((0, orto), (ocaso, 24)):
            ax.add_patch(Rectangle((a, ytop), b - a, ybot - ytop, color=NOCHE_SUAVE, lw=0, zorder=0))
        for t in (orto, ocaso):
            ax.add_patch(Rectangle((t - 0.5, ytop), 1, ybot - ytop, color=GRIS_SUAVE, lw=0, zorder=0.1))
            ax.plot([t, t], [ytop - 0.15, ybot], color=MUTED, lw=0.6, ls=(0, (2.5, 1.5)), zorder=0.3)
        ax.text(orto, ytop - 0.25, f"orto {hhmm(orto)}", ha="center", va="bottom", fontsize=6, color=INK2)
        ax.text(ocaso, ytop - 0.25, f"ocaso {hhmm(ocaso)}", ha="center", va="bottom", fontsize=6, color=INK2)
        for h in range(25):
            ax.plot([h, h], [ytop, ybot], color=GRID, lw=0.5 if h % 3 == 0 else 0.25, zorder=0.2)

        etiquetas_y, posiciones_y = [], []
        for g, grupo in enumerate(par):
            base = g * (n + sep)
            yh = base  # fila de cabecera
            if grupo == "bajas":
                titulo, detalle, colores = "40 · 80 · 160 m", "noche en todo el trayecto", [BAND_COLORS[b] for b in (40, 80, 160)]
            else:
                titulo = f"{grupo} m"
                detalle = f"MUF del trayecto corto > {coma(muf[('umbral', grupo)])} MHz"
                colores = [BAND_COLORS[grupo]]
            xsw = -0.55 - 0.45 * (len(colores) - 1)
            for k, col in enumerate(colores):
                ax.add_patch(Rectangle((xsw + 0.45 * k - 9.3, yh - 0.3), 0.32, 0.6, color=col, lw=0, clip_on=False))
            ax.text(-9.3 + xsw + 0.45 * len(colores) + 0.1, yh, titulo, ha="left", va="center", fontsize=7.6,
                    color=INK, fontweight="semibold", clip_on=False)
            ax.text(0.15, yh, detalle, ha="left", va="center", fontsize=6.3, color=INK2, zorder=5)
            for i, d in enumerate(destinos):
                y = base + 1 + i
                posiciones_y.append(y)
                etiquetas_y.append(rotulo_destino(d, etiquetas[d]))
                if i:
                    ax.plot([0, 24], [y - 0.5, y - 0.5], color=GRID, lw=0.3, zorder=0.25)
                if grupo == "bajas":
                    for a, b in noche.get(d, []):
                        barra(ax, a, b, y, 0.56, tinte(PIZARRA, 0.38), PIZARRA, asp)
                elif grupo == 20:
                    for a, b in muf[(20, d)]:
                        barra(ax, a, b, y, 0.56, tinte(BAND_COLORS[20], 0.45), BAND_COLORS[20], asp)
                else:
                    col = BAND_COLORS[grupo]
                    for a, b in muf[(grupo, d)]:
                        barra(ax, a, b, y - 0.1, 0.44, tinte(col, 0.45), col, asp)
                    for a, b in muf27.get((grupo, d), []):
                        ax.add_patch(Rectangle((a, y + 0.2), b - a, 0.13, color=VIEJO, lw=0, zorder=3.5))
                    if not muf[(grupo, d)]:
                        ax.text(0.15, y, "cerrada", ha="left", va="center", fontsize=5.8, color=MUTED, zorder=5)
        ax.set_yticks(posiciones_y, etiquetas_y)
        ax.tick_params(axis="y", length=0, labelsize=6.4, labelcolor=INK, pad=3)

        ticks = list(range(0, 25, 3))
        ax.set_xticks(ticks, [f"{t:02d}" for t in ticks])
        ax.set_xticks(range(25), minor=True)
        ax.tick_params(axis="x", which="major", length=3, width=0.6, color=MUTED, labelsize=6.4, pad=2)
        ax.tick_params(axis="x", which="minor", length=1.5, width=0.4, color=MUTED)
        tr = ax.get_xaxis_transform()
        for t in ticks:
            ax.text(t, -0.034, f"{(t + 2) % 24:02d}", transform=tr, ha="center", va="top", fontsize=6.4, color=INK2)
        ax.text(-0.9, -0.008, "UTC", transform=tr, ha="right", va="top", fontsize=6.6, color=INK, fontweight="semibold")
        ax.text(-0.9, -0.034, "Madrid (CEST)", transform=tr, ha="right", va="top", fontsize=6.6, color=INK,
                fontweight="semibold")

    manejadores = [
        Patch(fc=tinte(INK2, 0.3), ec=INK2, lw=0.7, label="banda abierta: 25-oct-2026, F10.7 = 120"),
        Patch(fc=VIEJO, ec="none", label="10 y 15 m con F10.7 = 100 (31-oct-2027)"),
        Patch(fc=tinte(PIZARRA, 0.38), ec=PIZARRA, lw=0.7, label="noche en todo el trayecto (40/80/160 m)"),
        Patch(fc=NOCHE_SUAVE, ec=GRID, lw=0.5, label="noche en Madrid"),
        Line2D([], [], color=MUTED, lw=0.8, ls=(0, (2.5, 1.5)), label="orto y ocaso en Madrid"),
    ]
    fig.legend(handles=manejadores, loc="lower center", bbox_to_anchor=(0.54, 0.0), ncol=3, fontsize=6.4,
               handlelength=1.8, handleheight=0.8, columnspacing=1.4, labelcolor=INK2)
    save(fig, "ventanas_bandas")


def hhmm(v: float) -> str:
    h = int(v)
    return f"{h:02d}:{round((v - h) * 60):02d}"


def barra(ax, a, b, y, h, fc, ec, asp):
    ax.add_patch(FancyBboxPatch((a, y - h / 2), b - a, h, boxstyle="round,pad=0,rounding_size=0.16",
                                mutation_aspect=1 / asp, fc=fc, ec=ec, lw=0.6, zorder=3))


if __name__ == "__main__":
    main()
