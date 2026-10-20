"""Ejemplos de cálculo de la puntuación del CQ WW desde EA4 (Madrid).

Puntuación = (suma de puntos por QSO) × (zonas + países), contando zonas y
países una vez por banda. Duplicados (misma estación y banda) no suman.
Penalización de las bases 2026 para un QSO erróneo (bust/NIL): se elimina y
se restan además 2 veces sus puntos (ver data/rules/facts.md).

Salida: data/calc/ejemplo_puntuacion.json
"""
from __future__ import annotations

import json
from pathlib import Path

from ctylib import Cty, qso_points

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "data" / "calc" / "ejemplo_puntuacion.json"

MINI_LOG = [  # (banda, indicativo, zona recibida) — indicativos ficticios
    (20, "EA7ZZZ", 14), (20, "DL1ZZZ", 14), (20, "K1ZZZ", 5), (20, "W9ZZZ", 4),
    (20, "EA8ZZZ", 33), (20, "JA1ZZZ", 25), (15, "K1ZZZ", 5), (15, "PY2ZZZ", 11),
    (15, "EA6ZZZ", 14), (20, "DL1ZZZ", 14), (40, "CT1ZZZ", 14), (40, "CN8ZZZ", 33),
]


def score(log, cty: Cty, me: dict, penalties=()) -> dict:
    seen, zones, countries = set(), set(), set()
    rows, pts = [], 0
    for band, call, zone in log:
        info = cty.lookup_prefix(call[:3]) or cty.lookup_prefix(call[:2])
        key = (band, call)
        if key in seen:
            rows.append({"banda": band, "indicativo": call, "zona": zone, "entidad": info["entity"],
                         "puntos": 0, "nuevo": "duplicado (no cuenta)"})
            continue
        seen.add(key)
        p = qso_points(me, info)
        new = []
        if (band, zone) not in zones:
            zones.add((band, zone)); new.append(f"zona {zone}")
        if (band, info["entity"]) not in countries:
            countries.add((band, info["entity"])); new.append("país")
        pts += p
        rows.append({"banda": band, "indicativo": call, "zona": zone, "entidad": info["entity"],
                     "continente": info["continent"], "puntos": p, "nuevo": ", ".join(new)})
    pen = sum(2 * p for p in penalties)  # el QSO ya no está en el log; se restan 2p más
    mults = len(zones) + len(countries)
    return {"qsos_validos": len(seen), "puntos_qso": pts, "zonas": len(zones),
            "paises": len(countries), "multiplicadores": mults, "total": pts * mults,
            "filas": rows, "penalizacion_puntos": pen,
            "total_con_penalizacion": (pts - pen) * mults if penalties else None}


def main() -> None:
    cty = Cty()
    me = cty.lookup_prefix("EA4")
    a = score(MINI_LOG, cty, me)
    # Mismo log, pero el QSO con JA1ZZZ resulta ser un bust (3 puntos):
    # pierde esos 3 puntos y la zona 25 y el país JA en 20 m, y se restan 6 más.
    log_b = [q for q in MINI_LOG if q[1] != "JA1ZZZ"]
    b = score(log_b, cty, me, penalties=(3,))
    # Objetivos hipotéticos para un primer CQ WW desde Madrid (cifras redondas;
    # referencia real: EA5JAX 2023, 135 QSO y 21.945 puntos; EA8AQV 2024, 312 QSO
    # y 134.384 puntos; data/history/results_ea.csv)
    hip = []
    for nombre, qsos, media, zonas, paises in (
        ("prudente (unas 12 h)", 300, 2.0, 45, 100),
        ("ambicioso (unas 30 h)", 700, 2.1, 70, 160),
    ):
        pts = round(qsos * media)
        hip.append({"escenario": nombre, "qsos": qsos, "puntos_medios": media, "puntos_qso": pts,
                    "zonas": zonas, "paises": paises, "total": pts * (zonas + paises)})
    out = {"cty": cty.version, "mini_log": a, "mini_log_con_bust": b, "hipoteticos": hip}
    OUT.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    for r in a["filas"]:
        print(r)
    print({k: v for k, v in a.items() if k != "filas"})
    print({k: v for k, v in b.items() if k != "filas"})
    print(hip)


if __name__ == "__main__":
    main()
