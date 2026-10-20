"""Plan orientativo de bandas por franjas UTC para el CQ WW SSB desde Madrid.

Cada recomendación (banda → destino) se comprueba contra dos cálculos:
  * bandas altas (10/15/20 m): ventanas en que la MUF básica supera la banda
    (modelo IRI de scripts/know_muf.py, data/knowledge/muf_ventanas.csv),
  * bandas bajas (40/80/160 m): horas con todo el trayecto de noche
    (scripts/calc_ventanas.py, data/calc/ventanas_noche.csv).
Una recomendación se acepta si la ventana calculada cubre al menos 60 min de
la franja (o la franja entera si es más corta). Si alguna falla, el script
termina con error.

Uso: python scripts/calc_plan_bandas.py [F10.7] [fecha_muf]
     (por defecto 120 y 2026-10-25; para 2027: 100 2027-10-31)
Salida: data/calc/plan_bandas.csv (o plan_bandas_<año>.csv si se da la fecha)
"""
from __future__ import annotations

import csv
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
F107 = sys.argv[1] if len(sys.argv) > 1 else "120"
FECHA_MUF = sys.argv[2] if len(sys.argv) > 2 else "2026-10-25"
SUFIJO = "" if len(sys.argv) <= 2 else "_" + FECHA_MUF[:4]

# (inicio UTC, fin UTC, recomendación larga, texto corto para la chuleta, comprobaciones)
# comprobación: (banda, destino) con banda en {"10 m","15 m","20 m","bajas"}
PLAN = [
    (0, 4, "40, 80 y 160 m hacia Norteamérica (zonas 3–5), el Caribe y Sudamérica; 20 m hacia Sudamérica y África del Sur.",
     "40/80/160 m → NA, Caribe y SA · 20 m → SA, ZS",
     [("bajas", "Nueva York"), ("bajas", "Chicago"), ("bajas", "San Juan (Puerto Rico)"), ("bajas", "São Paulo"),
      ("20 m", "São Paulo"), ("20 m", "Johannesburgo")]),
    (4, 7, "40 y 80 m hacia la costa oeste de EE. UU. (zona 3) y Hawái (zona 31) antes de amanecer; 20 m abre hacia Asia y Australia. Orto en Madrid hacia las 06:35: línea gris hacia ZL en 40 m.",
     "40/80 m → W6/W7 (z3), KH6 · 20 m abre a Asia y VK · 06:35 orto: línea gris",
     [("bajas", "Los Ángeles"), ("bajas", "Honolulu"), ("20 m", "Nueva Delhi"), ("20 m", "Sídney")]),
    (7, 10, "20 m hacia Japón, Asia y Australia; 15 m hacia Japón, Asia y África; 10 m hacia África y el sur de Asia; 40 m para Europa.",
     "20 m → JA, Asia, VK · 15 m → JA, Asia, AF · 10 m → AF, VU · 40 m → EU",
     [("20 m", "Tokio"), ("20 m", "Sídney"), ("15 m", "Tokio"), ("15 m", "Novosibirsk"), ("10 m", "Johannesburgo"),
      ("10 m", "Nueva Delhi")]),
    (10, 13, "10 y 15 m hacia África, Sudamérica y el sur de Asia; 15 m abre hacia la costa este de Norteamérica y, después, 10 m; 20 m hacia Norteamérica.",
     "10/15 m → AF, SA, VU · 15 m (luego 10 m) → NA este · 20 m → NA",
     [("10 m", "Johannesburgo"), ("10 m", "São Paulo"), ("10 m", "Nueva Delhi"), ("15 m", "Nueva York"),
      ("10 m", "Nueva York"), ("20 m", "Nueva York")]),
    (13, 17, "La franja de 10 y 15 m hacia Norteamérica (costa este y centro), el Caribe y Sudamérica; 15 m también hacia la costa oeste desde las 14 aprox.; 20 m hacia Norteamérica.",
     "10/15 m → NA este y centro, Caribe, SA · 15 m → W6 desde ~14 · 20 m → NA",
     [("10 m", "Nueva York"), ("10 m", "Chicago"), ("10 m", "San Juan (Puerto Rico)"), ("10 m", "São Paulo"),
      ("15 m", "Chicago"), ("15 m", "Los Ángeles"), ("20 m", "Chicago")]),
    (17, 20, "Ocaso en Madrid hacia las 17:21: línea gris hacia ZL y KL7 en 40 m. 10 m aún hacia la costa oeste de EE. UU. (hasta las 18 aprox.) y Sudamérica; 15 y 20 m hacia la costa oeste y Hawái; 40 y 80 m abren hacia Asia, África del Sur y Australia.",
     "17:21 ocaso: 40 m → ZL, KL7 · 10 m → W6 (~18), SA · 15/20 m → W6, KH6 · 40/80 m → Asia, ZS, VK",
     [("10 m", "Los Ángeles"), ("10 m", "São Paulo"), ("15 m", "Los Ángeles"), ("20 m", "Honolulu"),
      ("bajas", "Tokio"), ("bajas", "Nueva Delhi"), ("bajas", "Johannesburgo"), ("bajas", "Sídney")]),
    (20, 22, "40 y 80 m hacia Japón (hasta las 21 aprox.), Indonesia, la India y África; 20 m hacia Norteamérica y Sudamérica; 15 m hacia Sudamérica.",
     "40/80 m → JA (hasta ~21), YB, VU, AF · 20 m → NA, SA · 15 m → SA",
     [("bajas", "Tokio"), ("bajas", "Yakarta"), ("bajas", "Nueva Delhi"), ("bajas", "Johannesburgo"),
      ("20 m", "Nueva York"), ("20 m", "São Paulo"), ("15 m", "São Paulo")]),
    (22, 24, "40, 80 y 160 m hacia la costa este de Norteamérica, el Caribe y Sudamérica; 20 m hacia Norteamérica y Sudamérica.",
     "40/80/160 m → NA este, Caribe, SA · 20 m → NA, SA",
     [("bajas", "Nueva York"), ("bajas", "San Juan (Puerto Rico)"), ("bajas", "São Paulo"),
      ("20 m", "Nueva York"), ("20 m", "São Paulo")]),
]


def parse(windows: str) -> list[tuple[float, float]]:
    """'11:45-18:45, 20:00-21:00' → [(11.75, 18.75), (20.0, 21.0)] (cruza medianoche si fin < inicio)."""
    if windows.strip() in ("-", ""):
        return []
    if windows.strip() == "todo el día":
        return [(0.0, 24.0)]
    out = []
    for part in windows.split(","):
        a, b = part.strip().split("-")
        ha = int(a[:2]) + int(a[3:]) / 60
        hb = int(b[:2]) + int(b[3:]) / 60
        if hb <= ha:
            out += [(ha, 24.0), (0.0, hb)]
        else:
            out.append((ha, hb))
    return out


def overlap(wins, start, end) -> float:
    return sum(max(0.0, min(b, end) - max(a, start)) for a, b in wins)


def main() -> None:
    muf = {}
    for r in csv.DictReader(open(ROOT / "data/knowledge/muf_ventanas.csv", encoding="utf-8")):
        if r["f107"] == F107 and r["fecha"] == FECHA_MUF and r["trayecto"] == "SP":
            muf[(r["banda"], r["destino"])] = parse(r["ventanas_utc_muf_sobre_umbral"])
    night = {r["destino"]: parse(r["noche_en_todo_el_trayecto_utc"])
             for r in csv.DictReader(open(ROOT / "data/calc/ventanas_noche.csv", encoding="utf-8"))}
    rows, fails = [], []
    for a, b, largo, corto, checks in PLAN:
        need = min(1.0, b - a)
        notes = []
        for band, dest in checks:
            wins = night[dest] if band == "bajas" else muf[(band, dest)]
            ov = overlap(wins, a, b)
            ok = ov >= need - 1e-9
            notes.append(f"{band} {dest}: {ov:.2f} h {'OK' if ok else 'FALLA'}")
            if not ok:
                fails.append({"franja_utc": f"{a:02d}–{b:02d}", "banda": band, "destino": dest,
                              "horas_ventana": f"{ov:.2f}"})
        sab = f"{(a + 2) % 24:02d}–{(b + 2) % 24:02d}"
        dom = f"{(a + 1) % 24:02d}–{(b + 1) % 24:02d}" if a >= 1 else f"{(a + 2) % 24:02d}–{(b + 1) % 24:02d}"
        rows.append({"utc": f"{a:02d}–{b:02d}", "madrid_sabado_cest": sab, "madrid_domingo_cet": dom,
                     "recomendacion": largo, "chuleta": corto, "comprobacion": "; ".join(notes)})
    out = ROOT / f"data/calc/plan_bandas{SUFIJO}.csv"
    with open(out, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)
    for r in rows:
        print(r["utc"], r["madrid_sabado_cest"], r["madrid_domingo_cet"], "|", r["comprobacion"])
    with open(ROOT / f"data/calc/plan_bandas{SUFIJO}_fallos.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["franja_utc", "banda", "destino", "horas_ventana"])
        w.writeheader()
        w.writerows(fails)
    if fails:
        print("Recomendaciones sin respaldo en el cálculo:\n  " + "\n  ".join(
            f"{x['franja_utc']} {x['banda']} {x['destino']} ({x['horas_ventana']} h)" for x in fails))
        if not SUFIJO:
            sys.exit(1)
    else:
        print(f"Todas las recomendaciones respaldadas (F10.7 = {F107}, {FECHA_MUF}).")


if __name__ == "__main__":
    main()
