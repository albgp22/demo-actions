"""Tabla de puntos por QSO vista desde Madrid (EA4, zona 14, Europa).

Para cada prefijo de ejemplo busca entidad, continente y zona CQ en el CTY y
aplica la regla de puntos del CQ WW: 0 mismo país, 1 mismo continente y otro
país, 3 otro continente. Salida: data/calc/puntos_desde_madrid.csv
"""
from __future__ import annotations

import csv
from pathlib import Path

from ctylib import Cty, qso_points

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "data" / "calc" / "puntos_desde_madrid.csv"

# (prefijo de búsqueda, prefijo mostrado, nombre en español, nota para el lector)
SAMPLES = [
    ("EA4", "EA1–EA5, EA7 (y EB…EH)", "España peninsular", "0 puntos, pero da país y zona 14"),
    ("EA6", "EA6", "Baleares", "País distinto de EA"),
    ("EA8", "EA8", "Canarias", "Es África"),
    ("EA9", "EA9", "Ceuta y Melilla", "Es África"),
    ("CT1", "CT", "Portugal", ""),
    ("CT3", "CT3", "Madeira", "Es África"),
    ("CU2", "CU", "Azores", "Es Europa"),
    ("F5", "F", "Francia", ""),
    ("G4", "G", "Inglaterra", "GM, GW, GI, GD, GJ y GU son países distintos"),
    ("DL1", "DL", "Alemania", ""),
    ("I2", "I", "Italia", ""),
    ("IT9", "IT9", "Sicilia", "País WAE, aparte de I"),
    ("IG9", "IG9, IH9", "África italiana", "País aparte; es África"),
    ("SP5", "SP", "Polonia", ""),
    ("UA3", "UA1–UA7", "Rusia europea", ""),
    ("UA9A", "UA9, UA0", "Rusia asiática", "Es Asia; zonas 17, 18, 19 y 23"),
    ("SV1", "SV", "Grecia", ""),
    ("TA1", "TA1", "Turquía europea", "País WAE; es Europa"),
    ("TA2", "TA2–TA9", "Turquía asiática", "Es Asia"),
    ("5B4", "5B", "Chipre", "Es Asia"),
    ("4X1", "4X, 4Z", "Israel", "Es Asia"),
    ("CN8", "CN", "Marruecos", ""),
    ("ZS6", "ZS", "Sudáfrica", ""),
    ("TF3", "TF", "Islandia", ""),
    ("OX3", "OX", "Groenlandia", "Es Norteamérica"),
    ("K1", "K, N, W, AA–AK", "EE. UU.", "Zonas 3, 4 y 5 según el estado"),
    ("VE3", "VE, VA…", "Canadá", "Zonas 1 a 5"),
    ("KP4", "KP4", "Puerto Rico", ""),
    ("XE1", "XE", "México", ""),
    ("PY2", "PY…", "Brasil", ""),
    ("LU1", "LU…", "Argentina", ""),
    ("JA1", "JA…", "Japón", ""),
    ("BY1", "BY…", "China", "Zonas 23 y 24"),
    ("VK2", "VK", "Australia", "Zonas 29 y 30"),
    ("ZL1", "ZL", "Nueva Zelanda", ""),
    ("KH6", "KH6", "Hawái", "Es Oceanía"),
]


def main() -> None:
    cty = Cty()
    me = cty.lookup_prefix("EA4")
    rows = []
    for lookup_pfx, pfx, name, note in SAMPLES:
        info = cty.lookup_prefix(lookup_pfx)
        rows.append({
            "prefijo": pfx, "entidad": name, "entidad_cty": info["entity"],
            "continente": info["continent"], "zona_cq_tipica": info["cq"],
            "puntos": qso_points(me, info), "nota": note,
        })
    OUT.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)
    print("CTY", cty.version)
    for r in rows:
        print(f"{r['prefijo']:28s} {r['entidad_cty']:30s} {r['continente']} z{r['zona_cq_tipica']:<3} {r['puntos']}")


if __name__ == "__main__":
    main()
