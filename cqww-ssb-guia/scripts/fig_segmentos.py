"""Segmentos de las seis bandas del CQ WW: atribución española
(data/legal/bands_power_es.csv) y usos del plan de bandas IARU R1
(data/legal/iaru_r1_ssb.csv). Los dos CSV se leen al ejecutar: si se corrigen,
basta con volver a lanzar el script.

Salida: assets/segmentos_bandas.{pdf,png}
"""
from __future__ import annotations

import csv
import itertools
import re

import matplotlib as mpl
import numpy as np
from matplotlib.patches import Rectangle

from figlib import AXIS, INK, INK2, MUTED, ROOT, SERIES, SURFACE, plt, save, setup

BANDAS = ["160 m", "80 m", "40 m", "20 m", "15 m", "10 m"]
LATERAL = {"160 m": "LSB", "80 m": "LSB", "40 m": "LSB", "20 m": "USB", "15 m": "USB", "10 m": "USB"}
PASO = {"160 m": 20, "80 m": 50, "40 m": 25, "20 m": 50, "15 m": 50, "10 m": 200}

# Categorías en orden fijo → colores de la paleta en ese mismo orden
CATS = ["ssb", "cw", "dig", "bal", "todos", "pref", "coa", "evitar"]
COLOR = {k: SERIES[i] for i, k in enumerate(CATS)}
CORTO = {"ssb": "SSB", "cw": "CW", "dig": "digitales", "bal": "balizas", "todos": "todos los modos"}
VELO = 0.62  # opacidad del velo blanco sobre lo que no tiene atribución permanente

# Geometría de cada tira, en pulgadas desde la línea base del eje
W, H = 6.7, 4.95
LEFT, RIGHT = 0.62, 0.10
AX_H = 0.50
Y_SUB = 0.045               # subrayado «fonía del CQ WW»
LANE = (0.085, 0.125)       # carril de concursos
BAR = (0.145, 0.27)         # barra de usos del plan IARU
NIVELES = [0.345, 0.445]    # centro vertical de los rótulos de centros de actividad
FS = 6.2                    # tamaño de los rótulos pequeños


def khz(v: float) -> str:
    """Frecuencia a la española: espacio fino de miles a partir de 5 cifras y coma decimal."""
    s = f"{v:.1f}".rstrip("0").rstrip(".")
    ent, _, dec = s.partition(".")
    if len(ent) > 4:
        ent = ent[:-3] + " " + ent[-3:]
    return ent + ("," + dec if dec else "")


def leer(nombre: str) -> list[dict]:
    with open(ROOT / "data/legal" / nombre, encoding="utf-8") as f:
        return list(csv.DictReader(f))


def uso_principal(uso: str) -> str | None:
    u = uso.lower()
    if u.startswith("balizas"):
        return "bal"
    if "banda ancha" in u or "am/fm" in u or u.startswith("todos los modos"):
        return "todos"
    if "modos de banda estrecha" in u or "modos estrechos" in u or u.startswith("digimodos"):
        return "dig"
    if u.startswith("cw"):
        return "cw"
    if "ssb" in u and "no ssb" not in u and "evitar ssb" not in u:
        return "ssb"
    return None


def uso_concurso(uso: str, principal: str | None) -> str | None:
    u = uso.lower()
    if "concursos preferente" in u and "ssb" in u and principal == "ssb":
        return "pref"
    if any(k in u for k in ("dxpedicion", "evitar en concursos", "fuera del segmento preferente",
                            "fuera de segmentos preferentes", "evitar ssb de concurso")):
        return "evitar"
    return None


def rotulo_coa(uso: str) -> tuple[str, bool]:
    u = uso.lower()
    if "emergencia" in u:
        return "emergencias: dejar libre", True
    if "sstv" in u or "imagen" in u:
        return "SSTV", False
    if "voz digital" in u:
        return "voz digital", False
    if "qrp" in u:
        return "QRP " + ("CW" if "cw" in u else "SSB"), False
    return re.sub(r"^centro de actividad\s*", "", uso), False


def union(intervalos):
    out = []
    for a, b in sorted(intervalos):
        if out and a <= out[-1][1]:
            out[-1][1] = max(out[-1][1], b)
        else:
            out.append([a, b])
    return out


def interseca(a, b):
    return [(max(x0, y0), min(x1, y1)) for x0, x1 in a for y0, y1 in b if min(x1, y1) > max(x0, y0)]


def ancho(ax, s: str, fs: float, peso="normal") -> float:
    """Anchura de un texto en kHz del eje."""
    t = ax.text(0, 0, s, fontsize=fs, fontweight=peso)
    bb = t.get_window_extent(renderer=ax.figure.canvas.get_renderer())
    t.remove()
    return bb.width / ax.bbox.width * (ax.get_xlim()[1] - ax.get_xlim()[0])


def tinta_sobre(color) -> str:
    r, g, b = mpl.colors.to_rgb(color)
    return INK if 0.2126 * r + 0.7152 * g + 0.0722 * b > 0.45 else "white"


def coloca_rotulos(items, lo, hi, gap, niveles):
    """Elige nivel y alineación de cada rótulo para que no se solapen ni los crucen
    las líneas de otras marcas. Búsqueda exhaustiva (son pocos por banda)."""
    opciones = []
    for it in items:
        x, w, pad = it["x"], it["w"], it["pad"]
        ops = []
        for n in range(len(niveles)):
            for al, x0, x1, coste in (("left", x - pad, x + pad + w, 0.0), ("center", x - w / 2, x + w / 2, 0.3),
                                       ("right", x - pad - w, x + pad, 0.2)):
                if x0 >= lo - gap and x1 <= hi + gap:
                    ops.append((n * 10 + coste, n, al, x0, x1))
        opciones.append(sorted(ops) or [(99, len(niveles) - 1, "left", x, x + w)])

    def valido(sel):
        for (i, a), (j, b) in itertools.combinations(enumerate(sel), 2):
            _, ni, _, a0, a1 = a
            _, nj, _, b0, b1 = b
            xi, xj = items[i]["x"], items[j]["x"]
            if ni == nj and a0 < b1 + gap and b0 < a1 + gap:
                return False
            if ni < nj and a0 - gap <= xj <= a1 + gap:
                return False
            if nj < ni and b0 - gap <= xi <= b1 + gap:
                return False
        return True

    mejor, mejor_coste = None, float("inf")

    def dfs(k, sel, coste):
        nonlocal mejor, mejor_coste
        if coste >= mejor_coste:
            return
        if k == len(items):
            mejor, mejor_coste = list(sel), coste
            return
        for op in opciones[k]:
            sel.append(op)
            if valido(sel):
                dfs(k + 1, sel, coste + op[0])
            sel.pop()

    dfs(0, [], 0.0)
    return mejor, mejor_coste


def dibuja_banda(ax, banda, es_rows, iaru_rows):
    lo = min(float(r["desde_khz"]) for r in es_rows)
    hi = max(float(r["hasta_khz"]) for r in es_rows)
    span = hi - lo
    ax.set_xlim(lo, hi)
    ax.set_ylim(0, AX_H)
    ax.set_yticks([])
    ax.set_facecolor("none")
    for s in ("left", "right", "top"):
        ax.spines[s].set_visible(False)
    ax.spines["bottom"].set_color(AXIS)
    ax.spines["bottom"].set_linewidth(0.6)

    paso = PASO[banda]
    medias = [v for v in np.arange(np.ceil(lo / paso) * paso, hi + 0.01, paso)]
    marcas = [lo] + [v for v in medias if v - lo > 0.45 * paso and hi - v > 0.45 * paso] + [hi]
    ax.set_xticks(marcas, [khz(v) for v in marcas])
    menores = [v for v in np.arange(np.ceil(lo / (paso / 2)) * (paso / 2), hi, paso / 2) if v not in marcas]
    ax.set_xticks(menores, minor=True)
    ax.tick_params(axis="x", length=2.5, width=0.5, pad=1.5, labelsize=6.3)
    ax.tick_params(axis="x", which="minor", length=1.5, width=0.4)
    ax.set_xlim(lo, hi)

    # Fondo neutro: tramos sin uso definido en el CSV
    ax.add_patch(Rectangle((lo, BAR[0]), span, BAR[1] - BAR[0], facecolor="#efeee9", edgecolor="none", zorder=1))

    segs, conc, coas, notas = [], [], [], []
    for r in iaru_rows:
        a, b, uso = float(r["desde_khz"]), float(r["hasta_khz"]), r["uso"]
        if a == b:
            coas.append((a, *rotulo_coa(uso)))
            continue
        p = uso_principal(uso)
        if p:
            segs.append((a, b, p))
        c = uso_concurso(uso, p)
        if c:
            conc.append((a, b, c))
        m = re.search(r"balizas IBP (\d{4,5})-(\d{4,5})", uso)
        if m and p != "bal":
            segs.append((float(m.group(1)), float(m.group(2)), "bal"))
        if "dxpedicion" in uso.lower():
            notas.append((a, b, "DXpediciones"))
        elif "prioridad tráfico intercontinental (dx)" in uso.lower():
            notas.append((a, b, "prioridad DX"))

    # Barra de usos: de más ancho a más estrecho, para que lo estrecho quede encima
    for a, b, p in sorted(segs, key=lambda s: -(s[1] - s[0])):
        a, b = max(a, lo), min(b, hi)
        if b > a:
            ax.add_patch(Rectangle((a, BAR[0]), b - a, BAR[1] - BAR[0], facecolor=COLOR[p],
                                   edgecolor=SURFACE, linewidth=0.7, zorder=2))

    # Carril de concursos
    for a, b, c in sorted(conc, key=lambda s: -(s[1] - s[0])):
        a, b = max(a, lo), min(b, hi)
        if b <= a:
            continue
        if c == "pref":
            ax.add_patch(Rectangle((a, LANE[0]), b - a, LANE[1] - LANE[0], facecolor=COLOR["pref"],
                                   edgecolor=SURFACE, linewidth=0.5, zorder=2))
        else:
            ax.add_patch(Rectangle((a, LANE[0]), b - a, LANE[1] - LANE[0], facecolor=SURFACE,
                                   edgecolor=COLOR["evitar"], hatch="//////", linewidth=0.5, zorder=3))

    # Tramos sin atribución permanente en España: velo blanco y rayado
    sin_atrib = [(float(r["desde_khz"]), float(r["hasta_khz"])) for r in es_rows if not (r["potencia_max_w"] or "").strip()]
    for a, b in sin_atrib:
        ax.add_patch(Rectangle((a, BAR[0]), b - a, BAR[1] - BAR[0], facecolor=(1, 1, 1, VELO),
                               edgecolor=MUTED, hatch="\\\\\\\\", linewidth=0, zorder=5))
        ax.text((a + b) / 2, (BAR[0] + BAR[1]) / 2, "sin atribución permanente en España (solo con resolución temporal)",
                fontsize=FS, ha="center", va="center", color=INK2, zorder=6,
                bbox=dict(boxstyle="round,pad=0.22", facecolor=SURFACE, edgecolor="none"))

    # Rótulos de centros de actividad y notas de rango
    pad = span * 0.025 / (W - LEFT - RIGHT)
    items = [dict(x=x, txt=f"{khz(x)} {t}", peso="semibold" if neg else "normal", tipo="coa", neg=neg)
             for x, t, neg in coas]
    items += [dict(x=(a + b) / 2, txt=t, peso="normal", tipo="nota", a=a, b=b, neg=False) for a, b, t in notas]
    items.sort(key=lambda it: it["x"])
    for it in items:
        it["w"], it["pad"] = ancho(ax, it["txt"], FS, it["peso"]), pad
    ancho_eje = W - LEFT - RIGHT
    # El hueco mayor posible entre las soluciones con menos niveles
    sel, mejor = None, float("inf")
    for niveles in (NIVELES, NIVELES + [NIVELES[-1] + 0.1]):   # un tercer nivel solo si hace falta
        for hueco in (0.07, 0.05, 0.035):
            cand, coste = coloca_rotulos(items, lo, hi, span * hueco / ancho_eje, niveles)
            if cand is not None and coste < mejor - 5:
                sel, mejor = cand, coste
        if sel is not None:
            break
    if sel is None:
        raise SystemExit(f"{banda}: no caben los rótulos de los centros de actividad; añade un nivel")
    for it, (_, n, al, x0, x1) in zip(items, sel):
        y = niveles[n]
        x = it["x"]
        if it["tipo"] == "coa":
            ax.plot([x, x], [BAR[0], y - 0.035], color=COLOR["coa"], lw=0.75, zorder=5, solid_capstyle="butt")
        else:
            yb = BAR[1] + 0.02
            ax.plot([it["a"], it["a"], it["b"], it["b"]], [yb - 0.015, yb, yb, yb - 0.015], color=INK2, lw=0.5, zorder=4)
            if y - 0.035 > yb:
                ax.plot([x, x], [yb, y - 0.035], color=INK2, lw=0.5, zorder=4)
        xt = {"left": x + pad, "center": x, "right": x - pad}[al]
        ax.text(xt, y, it["txt"], fontsize=FS, fontweight=it["peso"], ha=al, va="center",
                color=INK if it["neg"] else INK2, zorder=6)

    # Rótulos directos dentro de la barra, lejos de las marcas
    marcas_x = [x for x, _, _ in coas]
    visibles = []
    for a, b, p in segs:
        a, b = max(a, lo), min(b, hi)
        libres = [(a, b)]
        for x0, x1, q in segs:
            if (x1 - x0) >= (b - a) or x1 <= a or x0 >= b:
                continue
            nuevos = []
            for u0, u1 in libres:
                if x1 <= u0 or x0 >= u1:
                    nuevos.append((u0, u1))
                    continue
                if x0 > u0:
                    nuevos.append((u0, x0))
                if x1 < u1:
                    nuevos.append((x1, u1))
            libres = nuevos
        for x0, x1 in sin_atrib:
            libres = [(u0, min(u1, x0)) for u0, u1 in libres if u0 < x0] + [(max(u0, x1), u1) for u0, u1 in libres if u1 > x1]
        for u0, u1 in libres:
            cortes = [u0] + sorted(m for m in marcas_x if u0 < m < u1) + [u1]
            for c0, c1 in zip(cortes, cortes[1:]):
                visibles.append((c0, c1, p, b - a))
    hechos = set()
    for c0, c1, p, total in sorted(visibles, key=lambda s: -(s[1] - s[0])):
        if p in hechos:
            continue
        txt = "AM/FM · satélites · repetidores" if p == "todos" and total > 300 else CORTO[p]
        w = ancho(ax, txt, FS)
        if c1 - c0 > w + 2 * pad:
            ax.text((c0 + c1) / 2, (BAR[0] + BAR[1]) / 2, txt, fontsize=FS, ha="center", va="center",
                    color=tinta_sobre(COLOR[p]), zorder=4)
            hechos.add(p)

    # Fonía del CQ WW = SSB del plan IARU ∩ atribución permanente española
    perm = union([(float(r["desde_khz"]), float(r["hasta_khz"])) for r in es_rows if (r["potencia_max_w"] or "").strip()])
    ssb = union([(a, b) for a, b, p in segs if p == "ssb"])
    for a, b in interseca(ssb, perm):
        ax.plot([a, b], [Y_SUB, Y_SUB], color=INK, lw=1.5, solid_capstyle="butt", zorder=6)
        for x in (a, b):
            ax.plot([x, x], [Y_SUB - 0.022, Y_SUB + 0.022], color=INK, lw=0.8, zorder=6)
        txt = f"fonía del CQ WW: {khz(a)}–{khz(b)} kHz"
        w = ancho(ax, txt, FS, "semibold")
        if hi - b > w + 3 * pad:
            ax.text(b + 2 * pad, Y_SUB, txt, fontsize=FS, fontweight="semibold", ha="left", va="center", color=INK, zorder=6)
        elif a - lo > w + 3 * pad:
            ax.text(a - 2 * pad, Y_SUB, txt, fontsize=FS, fontweight="semibold", ha="right", va="center", color=INK, zorder=6)
        else:
            ax.text((a + b) / 2, Y_SUB + 0.004, txt, fontsize=FS, fontweight="semibold", ha="center", va="center",
                    color=INK, zorder=7, bbox=dict(boxstyle="square,pad=0.12", facecolor=SURFACE, edgecolor="none"))

    # Nombre de la banda y banda lateral
    ax.text(-0.012, (BAR[0] + BAR[1]) / 2 / AX_H, banda, transform=ax.transAxes, ha="right", va="center",
            fontsize=8.5, fontweight="semibold", color=INK)
    ax.text(-0.012, (LANE[0] + Y_SUB) / 2 / AX_H, LATERAL[banda], transform=ax.transAxes, ha="right", va="center",
            fontsize=6.5, color=MUTED)


def leyenda(fig, filas, y_top, dy):
    """Leyenda por grupos en filas, maquetada a mano (coordenadas de figura)."""
    r = fig.canvas.get_renderer()
    fw = fig.bbox.width
    hw, hh = 0.20 / W, 0.075 / H
    for i, (titulo, entradas) in enumerate(filas):
        y = y_top - i * dy
        t = fig.text(0.0, y, titulo, fontsize=6.6, fontweight="semibold", color=INK, va="center")
        x = 0.0 + t.get_window_extent(r).width / fw + 0.012
        for tipo, color, texto in entradas:
            if tipo == "rect":
                fig.add_artist(Rectangle((x, y - hh / 2), hw, hh, transform=fig.transFigure, facecolor=color, edgecolor="none"))
            elif tipo == "evitar":
                fig.add_artist(Rectangle((x, y - hh / 2), hw, hh, transform=fig.transFigure, facecolor=SURFACE,
                                         edgecolor=color, hatch="//////", linewidth=0.5))
            elif tipo == "velo":
                fondo = tuple(VELO + (1 - VELO) * c for c in mpl.colors.to_rgb(COLOR["ssb"]))
                fig.add_artist(Rectangle((x, y - hh / 2), hw, hh, transform=fig.transFigure, facecolor=fondo,
                                         edgecolor=MUTED, hatch="\\\\\\\\", linewidth=0))
            elif tipo == "vline":
                fig.add_artist(plt.Line2D([x + hw / 2] * 2, [y - hh * 0.9, y + hh * 0.9], transform=fig.transFigure,
                                          color=color, lw=0.9))
            elif tipo == "hline":
                fig.add_artist(plt.Line2D([x, x + hw], [y, y], transform=fig.transFigure, color=color, lw=1.5))
            x += hw + 0.006
            t = fig.text(x, y, texto, fontsize=6.6, color=INK2, va="center")
            x += t.get_window_extent(r).width / fw + 0.018


def main() -> None:
    setup()
    mpl.rcParams["hatch.linewidth"] = 0.5
    es = leer("bands_power_es.csv")
    iaru = leer("iaru_r1_ssb.csv")

    fig = plt.figure(figsize=(W, H))
    top_leyenda = 0.40   # pulgadas reservadas arriba para la leyenda
    bottom = 0.30
    paso_y = (H - top_leyenda - bottom) / len(BANDAS)
    for k, banda in enumerate(BANDAS):
        y0 = H - top_leyenda - (k + 1) * paso_y + (paso_y - AX_H) * 0.62
        ax = fig.add_axes([LEFT / W, y0 / H, 1 - (LEFT + RIGHT) / W, AX_H / H])
        dibuja_banda(ax, banda, [r for r in es if r["banda"] == banda], [r for r in iaru if r["banda"] == banda])

    leyenda(fig, [
        ("Plan IARU R1", [("rect", COLOR["ssb"], "SSB (fonía)"), ("rect", COLOR["cw"], "CW"),
                          ("rect", COLOR["dig"], "Modos estrechos y digitales"), ("rect", COLOR["bal"], "Balizas: no transmitir"),
                          ("rect", COLOR["todos"], "Todos los modos (AM/FM…)")]),
        ("Concursos", [("rect", COLOR["pref"], "SSB preferente"), ("evitar", COLOR["evitar"], "Evitar o fuera del segmento preferente"),
                       ("vline", COLOR["coa"], "Centro de actividad: no lo ocupes")]),
        ("España", [("velo", None, "Sin atribución permanente"), ("hline", INK, "Fonía que puedes usar en el CQ WW")]),
    ], y_top=1 - 0.075 / H, dy=0.13 / H)

    pendiente = [r for r in iaru if r["banda"] in BANDAS and (
        "POR VERIFICAR" in r.get("fuente", "")
        or (r.get("estado") or "confirmado").strip().lower() not in ("confirmado", "verificado", "si", "sí"))]
    if pendiente:
        fig.text(0.0, 0.004, "Segmentos IARU R1 pendientes de verificar (data/legal/iaru_r1_ssb.csv).",
                 fontsize=6.3, color=MUTED, ha="left", va="bottom")
    fig.text(1 - RIGHT / W, 0.004, "Frecuencias en kHz; cada banda con su propia escala.", fontsize=6.3, color=MUTED,
             ha="right", va="bottom")
    save(fig, "segmentos_bandas")


if __name__ == "__main__":
    main()
