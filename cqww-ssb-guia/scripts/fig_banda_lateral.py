"""Por qué importa la banda lateral en los bordes: el dial marca la portadora
suprimida y la voz ocupa de 0,3 a 2,7 kHz por debajo (LSB) o por encima (USB).

Los bordes se leen de data/legal/bands_power_es.csv (atribución española) y
data/legal/iaru_r1_ssb.csv (inicio del SSB en 160 m según el plan IARU R1).

Salida: assets/banda_lateral.{pdf,png}
"""
from __future__ import annotations

import csv
import math

import matplotlib as mpl
import numpy as np
from matplotlib.patches import Rectangle

from figlib import AXIS, INK, INK2, MUTED, ROOT, SERIES, SURFACE, plt, save, setup

A0, A1 = 0.3, 2.7          # banda de audio de la voz en SSB (kHz)
BIEN, MAL = SERIES[0], SERIES[1]
Y_OK, Y_KO = 1.45, 0.0     # líneas base de las dos filas de cada panel
ALTO = 0.72                # altura del espectro de voz


def khz(v: float, dec: int | None = None) -> str:
    s = f"{v:.{dec}f}" if dec is not None else f"{v:.1f}".rstrip("0").rstrip(".")
    ent, _, d = s.partition(".")
    if len(ent) > 4:
        ent = ent[:-3] + " " + ent[-3:]
    return ent + ("," + d if d else "")


def leer(nombre: str) -> list[dict]:
    with open(ROOT / "data/legal" / nombre, encoding="utf-8") as f:
        return list(csv.DictReader(f))


def suave(t):
    t = np.clip(t, 0, 1)
    return t * t * (3 - 2 * t)


def envolvente(a):
    """Forma orientativa del espectro de voz: sube en 0,3 kHz, baja hacia 2,7 kHz."""
    return suave((a - A0) / 0.25) * suave((A1 - a) / 0.3) * (1 - 0.35 * (a - A0) / (A1 - A0))


def voz(ax, dial, lateral, y0, color, borde=None, fuera_lado=None):
    a = np.linspace(A0, A1, 300)
    f = dial + a if lateral == "USB" else dial - a
    y = y0 + ALTO * envolvente(a)
    ax.fill_between(f, y0, y, color=color, lw=0, zorder=3)
    ax.plot([f.min() - 0.6, f.max() + 0.6], [y0, y0], color=AXIS, lw=0.6, zorder=2)
    if borde is not None:
        m = f > borde if fuera_lado == "arriba" else f < borde
        if m.any():
            ax.fill_between(f[m], y0, y[m], facecolor="none", edgecolor=INK, hatch="//////", lw=0, zorder=4)
    # Dial: la frecuencia que marca la radio
    ax.plot([dial, dial], [y0 - 0.06, y0 + ALTO + 0.18], color=INK, lw=0.9, zorder=5)
    ax.plot([dial], [y0 + ALTO + 0.18], marker="v", ms=4.2, color=INK, zorder=5, clip_on=False)


def fuera(ax, x0, x1, texto, y_texto):
    ax.add_patch(Rectangle((x0, -0.3), x1 - x0, 2.9, facecolor="#f4f3ef", edgecolor=MUTED, hatch="\\\\\\\\",
                           lw=0, zorder=1))
    ax.text((x0 + x1) / 2, y_texto, texto, fontsize=6.2, color=INK2, ha="center", va="center", zorder=6,
            bbox=dict(boxstyle="round,pad=0.2", facecolor=SURFACE, edgecolor="none"))


def rotulo(ax, dial, lateral, y0, linea1, linea2, color_ok=True):
    lado = 1 if lateral == "LSB" else -1     # el rótulo va del lado contrario a la voz
    x = dial + lado * 0.22
    ha = "left" if lado == 1 else "right"
    ax.text(x, y0 + 0.47, linea1, fontsize=6.6, color=INK, ha=ha, va="center", zorder=6, fontweight="semibold",
            bbox=dict(boxstyle="square,pad=0.08", facecolor=SURFACE, edgecolor="none"))
    ax.text(x, y0 + 0.2, linea2, fontsize=6.4, color=INK2, ha=ha, va="center", zorder=6,
            bbox=dict(boxstyle="square,pad=0.08", facecolor=SURFACE, edgecolor="none"))


def ejes(ax, x0, x1, paso, titulo, regla, clave=(), sep=1.6):
    ax.set_xlim(x0, x1)
    ax.set_ylim(-0.3, 2.6)
    ax.set_yticks([])
    for s in ("left", "right", "top"):
        ax.spines[s].set_visible(False)
    ax.spines["bottom"].set_color(AXIS)
    ax.spines["bottom"].set_linewidth(0.6)
    ini = math.ceil(x0 / paso) * paso
    marcas = [v for v in np.arange(ini, x1 + 0.01, paso) if all(abs(v - c) >= sep for c in clave)]
    marcas = sorted(set(marcas) | set(clave))
    ax.set_xticks(marcas, [khz(v) for v in marcas])
    ax.set_xticks(np.arange(math.ceil(x0), x1 + 0.01, 1.0), minor=True)
    ax.tick_params(axis="x", length=2.5, width=0.5, pad=1.5, labelsize=6.3)
    ax.tick_params(axis="x", which="minor", length=1.5, width=0.4)
    ax.set_title(titulo, loc="left", fontsize=7.8, pad=12)
    ax.text(0, 1.035, regla, transform=ax.transAxes, fontsize=6.6, color=INK2, ha="left", va="bottom")


def main() -> None:
    setup()
    mpl.rcParams["hatch.linewidth"] = 0.5
    es = leer("bands_power_es.csv")
    iaru = leer("iaru_r1_ssb.csv")
    b40 = max(float(r["hasta_khz"]) for r in es if r["banda"] == "40 m")
    b20 = max(float(r["hasta_khz"]) for r in es if r["banda"] == "20 m")
    perm160 = [r for r in es if r["banda"] == "160 m" and (r["potencia_max_w"] or "").strip()]
    sup160 = max(float(r["hasta_khz"]) for r in perm160)
    ssb160 = min(float(r["desde_khz"]) for r in iaru if r["banda"] == "160 m" and r["uso"].upper().startswith("SSB"))

    fig, axs = plt.subplots(1, 3, figsize=(6.7, 2.55), gridspec_kw=dict(wspace=0.16))
    fig.subplots_adjust(left=0.01, right=0.99, top=0.74, bottom=0.15)

    # 1) 40 m, LSB, borde superior
    ax = axs[0]
    ejes(ax, b40 - 7.5, b40 + 5.5, 2, "40 m · LSB · borde superior", f"Regla: dial hasta {khz(b40, 1)} kHz", clave=(b40,))
    fuera(ax, b40, b40 + 5.5, "fuera de\nla banda", 2.35)
    d_ok, d_ko = b40, b40 + 1.5
    voz(ax, d_ok, "LSB", Y_OK, BIEN)
    voz(ax, d_ko, "LSB", Y_KO, MAL, borde=b40, fuera_lado="arriba")
    rotulo(ax, d_ok, "LSB", Y_OK, f"dial {khz(d_ok, 1)}", "✓ dentro")
    rotulo(ax, d_ko, "LSB", Y_KO, f"dial {khz(d_ko, 1)}", f"✗ {khz(d_ko - A0 - b40, 1)} kHz fuera")
    ax.annotate("dial = portadora\nsuprimida", xy=(d_ok - 0.15, Y_OK + ALTO + 0.19), xytext=(b40 - 7.35, 2.33),
                fontsize=6.2, color=INK2, ha="left", va="center",
                arrowprops=dict(arrowstyle="-|>", color=INK2, lw=0.6, mutation_scale=6,
                                connectionstyle="arc3,rad=-0.25", shrinkA=1, shrinkB=1))

    # 2) 160 m, LSB, fonía permanente en España. El plan IARU R1 fija el dial LSB mínimo
    #    («Lowest dial setting for LSB Voice mode: 1843 kHz»): la voz cae en 1840–1843 (todos los modos)
    #    y no debe entrar en el tramo de banda estrecha, por debajo de 1840 kHz.
    ax = axs[1]
    estrecha = max(float(r["hasta_khz"]) for r in iaru if r["banda"] == "160 m" and "banda estrecha" in r["uso"].lower())
    d_min = ssb160
    ejes(ax, estrecha - 2.5, sup160 + 2.5, 2, "160 m · LSB · fonía en España",
         f"Regla: dial entre {khz(d_min, 1)} y {khz(sup160, 1)} kHz", clave=(estrecha, d_min, sup160))
    fuera(ax, estrecha - 2.5, estrecha, "banda\nestrecha", 2.35)
    fuera(ax, sup160, sup160 + 2.5, "sin\natribución", 2.35)
    d_ok, d_ko = d_min, d_min - 1.5
    voz(ax, d_ok, "LSB", Y_OK, BIEN)
    voz(ax, d_ko, "LSB", Y_KO, MAL, borde=estrecha, fuera_lado="abajo")
    rotulo(ax, d_ok, "LSB", Y_OK, f"dial {khz(d_ok, 1)}", "✓ dentro")
    rotulo(ax, d_ko, "LSB", Y_KO, f"dial {khz(d_ko, 1)}", f"✗ {khz(estrecha - (d_ko - A1), 1)} kHz fuera")

    # 3) 20 m, USB, borde superior
    ax = axs[2]
    d_max = b20 - A1
    ejes(ax, b20 - 9.0, b20 + 4.0, 3, "20 m · USB · borde superior", f"Regla: dial hasta ≈ {khz(math.floor(d_max))} kHz",
         clave=(math.floor(d_max), b20), sep=2.4)
    fuera(ax, b20, b20 + 4.0, "fuera de\nla banda", 2.35)
    d_ok, d_ko = math.floor(d_max), b20 - 1.0
    voz(ax, d_ok, "USB", Y_OK, BIEN)
    voz(ax, d_ko, "USB", Y_KO, MAL, borde=b20, fuera_lado="arriba")
    rotulo(ax, d_ok, "USB", Y_OK, f"dial {khz(d_ok, 1)}", "✓ dentro")
    rotulo(ax, d_ko, "USB", Y_KO, f"dial {khz(d_ko, 1)}", f"✗ {khz(d_ko + A1 - b20, 1)} kHz fuera")

    # Leyenda
    r = fig.canvas.get_renderer()
    y = 0.965
    x = 0.01
    for tipo, color, texto in (("rect", BIEN, "voz con el dial bien puesto"), ("rect", MAL, "voz que se sale"),
                               ("hatch", None, "fuera de la banda o del segmento"),
                               ("dial", INK, "dial: lo que marca la radio")):
        if tipo == "rect":
            fig.add_artist(Rectangle((x, y - 0.022), 0.028, 0.044, transform=fig.transFigure, facecolor=color, lw=0))
        elif tipo == "hatch":
            fig.add_artist(Rectangle((x, y - 0.022), 0.028, 0.044, transform=fig.transFigure, facecolor="#f4f3ef",
                                     edgecolor=MUTED, hatch="\\\\\\\\", lw=0))
        else:
            fig.add_artist(plt.Line2D([x + 0.014] * 2, [y - 0.03, y + 0.02], transform=fig.transFigure, color=color, lw=0.9))
            fig.add_artist(plt.Line2D([x + 0.014], [y + 0.02], transform=fig.transFigure, marker="v", ms=4, color=color))
        t = fig.text(x + 0.036, y, texto, fontsize=6.6, color=INK2, va="center")
        x += 0.036 + t.get_window_extent(r).width / fig.bbox.width + 0.03
    fig.text(0.99, 0.005, f"Ej. lejos de los bordes: dial {khz(14200, 1)} en USB → voz en {khz(14200 + A0, 1)}–{khz(14200 + A1, 1)} kHz.",
             fontsize=6.3, color=MUTED, ha="right", va="bottom")
    save(fig, "banda_lateral")


if __name__ == "__main__":
    main()
