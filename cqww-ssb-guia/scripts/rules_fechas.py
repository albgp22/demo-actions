#!/usr/bin/env python3
"""Calcula las fechas del CQ World-Wide DX Contest (SSB y CW) y las guarda en
data/rules/dates.json.

Regla (portada de cqww.com, verificada el 2026-10-20 mediante WebSearch):
  "SSB is always the last full weekend of October."
  "CW is always the last full weekend of November."
Horario (reglas 2026, PDF del 5-sep-2026):
  "Starts 00:00:00 UTC Saturday  Ends 23:59:59 UTC Sunday"
Plazo de envío del log (reglas 2026 y entrada del blog "2026 Rule Changes"):
  "All entries must be sent WITHIN 48 HOURS after the end of the contest:
   no later than 2359 UTC October 27, 2026 for SSB and 2359 UTC December 1,
   2026 for CW."

"Último fin de semana completo" = el último sábado del mes cuyo domingo
siguiente también cae en ese mes.

Uso:  python scripts/rules_fechas.py          (escribe data/rules/dates.json)
      python scripts/rules_fechas.py --check  (solo ejecuta las comprobaciones)
"""

from __future__ import annotations

import calendar
import datetime as dt
import json
import sys
from pathlib import Path
from zoneinfo import ZoneInfo

UTC = dt.timezone.utc
MADRID = ZoneInfo("Europe/Madrid")
ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "data" / "rules" / "dates.json"

# Fechas publicadas por el organizador, usadas como prueba de la fórmula.
# Fuente indicada en cada caso (títulos/textos devueltos por WebSearch).
PUBLISHED = {
    # año: (SSB sábado, SSB domingo, CW sábado, CW domingo, fuente)
    1999: ((10, 30), (10, 31), (11, 27), (11, 28), "cqww.com/rules/1999_rules_cqww.htm (título)"),
    2019: ((10, 26), (10, 27), (11, 23), (11, 24), "cqww.com/rules/2019_rules_cqww.pdf (título)"),
    2022: ((10, 29), (10, 30), (11, 26), (11, 27), "cqww.com/rules/2022_rules_cqww.pdf (título)"),
    2023: ((10, 28), (10, 29), (11, 25), (11, 26), "cqww.com/rules/rules_fr_2023.pdf (título)"),
    2024: ((10, 26), (10, 27), (11, 23), (11, 24), "cqww.com/rules/rules_de_2024.pdf (título)"),
    2025: ((10, 25), (10, 26), (11, 29), (11, 30), "cqww.com/rules/ (fechas 2025)"),
    2026: ((10, 24), (10, 25), (11, 28), (11, 29), "cqww.com/ y reglas 2026"),
    2027: ((10, 30), (10, 31), (11, 27), (11, 28), "cqww.com/ (fechas futuras)"),
    2028: ((10, 28), (10, 29), (11, 25), (11, 26), "cqww.com/ (fechas futuras)"),
    2029: ((10, 27), (10, 28), (11, 24), (11, 25), "cqww.com/ (fechas futuras)"),
}

# Plazos publicados (solo 2026 está publicado; el resto es proyección).
PUBLISHED_DEADLINES = {
    (2026, "SSB"): dt.datetime(2026, 10, 27, 23, 59, tzinfo=UTC),
    (2026, "CW"): dt.datetime(2026, 12, 1, 23, 59, tzinfo=UTC),
}


def last_full_weekend(year: int, month: int) -> tuple[dt.date, dt.date]:
    """Último sábado del mes cuyo domingo siguiente también está en el mes."""
    last_day = calendar.monthrange(year, month)[1]
    d = dt.date(year, month, last_day - 1)  # el domingo debe ser <= último día
    while d.weekday() != calendar.SATURDAY:
        d -= dt.timedelta(days=1)
    sunday = d + dt.timedelta(days=1)
    assert sunday.month == month and sunday.weekday() == calendar.SUNDAY
    return d, sunday


def last_sunday(year: int, month: int) -> dt.date:
    last_day = calendar.monthrange(year, month)[1]
    d = dt.date(year, month, last_day)
    while d.weekday() != calendar.SUNDAY:
        d -= dt.timedelta(days=1)
    return d


def iso(t: dt.datetime) -> str:
    if t.tzinfo is UTC:
        return t.strftime("%Y-%m-%dT%H:%M:%SZ")
    return t.isoformat()


def local(t: dt.datetime) -> dict:
    lt = t.astimezone(MADRID)
    return {
        "iso": lt.isoformat(),
        "tz": lt.tzname(),
        "dia_semana": ["lunes", "martes", "miércoles", "jueves", "viernes",
                       "sábado", "domingo"][lt.weekday()],
    }


def event(year: int, mode: str) -> dict:
    month = 10 if mode == "SSB" else 11
    sat, sun = last_full_weekend(year, month)
    start = dt.datetime(sat.year, sat.month, sat.day, 0, 0, 0, tzinfo=UTC)
    end = dt.datetime(sun.year, sun.month, sun.day, 23, 59, 59, tzinfo=UTC)
    # Regla 2026: 48 h tras el final -> "no later than 2359 UTC" del martes.
    deadline_day = sun + dt.timedelta(days=2)
    deadline = dt.datetime(deadline_day.year, deadline_day.month, deadline_day.day,
                           23, 59, tzinfo=UTC)
    published = (year, mode) in PUBLISHED_DEADLINES
    if published:
        assert deadline == PUBLISHED_DEADLINES[(year, mode)], (year, mode, deadline)
    ev = {
        "modo": mode,
        "concurso": f"CQ-WW-{mode}",
        "fin_de_semana": [sat.isoformat(), sun.isoformat()],
        "inicio_utc": iso(start),
        "fin_utc": iso(end),
        "duracion_horas": round((end - start).total_seconds() / 3600 + 1 / 3600, 3),
        "inicio_madrid": local(start),
        "fin_madrid": local(end),
        "plazo_log_utc": iso(deadline),
        "plazo_log_madrid": local(deadline),
        "plazo_log_estado": (
            "publicado en las reglas 2026" if published else
            "PROYECCIÓN (regla de 48 h de 2026; reglas de ese año aún no publicadas)"
        ),
    }
    if year in PUBLISHED:
        p = PUBLISHED[year]
        pub_sat, pub_sun = (p[0], p[1]) if mode == "SSB" else (p[2], p[3])
        ok = (sat.month, sat.day) == pub_sat and (sun.month, sun.day) == pub_sun
        ev["coincide_con_fecha_publicada"] = ok
        ev["fuente_fecha_publicada"] = p[4]
        assert ok, f"{year} {mode}: calculado {sat}/{sun} != publicado {pub_sat}/{pub_sun}"
    if mode == "SSB":
        # Cambio de hora UE: último domingo de octubre a las 01:00 UTC.
        dst = last_sunday(year, 10)
        dst_t = dt.datetime(dst.year, dst.month, dst.day, 1, 0, tzinfo=UTC)
        ev["cambio_hora_europa"] = {
            "instante_utc": iso(dst_t),
            "dentro_del_concurso": start <= dst_t <= end,
            "nota": "En la España peninsular, a las 03:00 CEST se vuelve a las 02:00 CET "
                    "(UTC+2 -> UTC+1). El log se lleva siempre en UTC.",
        }
    return ev


def check_formula() -> None:
    for year, p in PUBLISHED.items():
        for mode, (s, u) in (("SSB", (p[0], p[1])), ("CW", (p[2], p[3]))):
            sat, sun = last_full_weekend(year, 10 if mode == "SSB" else 11)
            assert (sat.month, sat.day) == s and (sun.month, sun.day) == u, (year, mode)
    # Propiedad: el domingo del fin de semana SSB es siempre el último domingo
    # de octubre (por eso siempre coincide con el cambio de hora europeo).
    for year in range(1990, 2101):
        assert last_full_weekend(year, 10)[1] == last_sunday(year, 10)


def main() -> None:
    check_formula()
    if "--check" in sys.argv:
        print("OK: la fórmula reproduce todas las fechas publicadas", sorted(PUBLISHED))
        return
    data = {
        "_descripcion": "Fechas del CQ WW DX Contest calculadas con scripts/rules_fechas.py",
        "_generado": dt.date.today().isoformat(),
        "_regla_fin_de_semana": {
            "SSB": "SSB is always the last full weekend of October.",
            "CW": "CW is always the last full weekend of November.",
            "fuente": "https://cqww.com/ (portada; verificado por WebSearch 2026-10-20)",
        },
        "_regla_horario": {
            "texto": "Starts 00:00:00 UTC Saturday  Ends 23:59:59 UTC Sunday",
            "fuente": "https://cqww.com/rules/2026_rules_cqww.pdf (5-sep-2026)",
        },
        "_regla_plazo_log": {
            "texto": "All entries must be sent WITHIN 48 HOURS after the end of the "
                     "contest: no later than 2359 UTC October 27, 2026 for SSB and "
                     "2359 UTC December 1, 2026 for CW.",
            "fuente": "https://cqww.com/rules/2026_rules_cqww.pdf; "
                      "https://cqww.com/blog/2026-rule-changes/",
            "nota": "Nuevo en 2026 (antes eran 5 días). Para 2027/2028 es una proyección.",
        },
        "comprobacion": {
            "fechas_publicadas_reproducidas": sorted(PUBLISHED),
            "resultado": "OK",
        },
        "eventos": {
            str(y): {m: event(y, m) for m in ("SSB", "CW")} for y in (2026, 2027, 2028)
        },
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Escrito {OUT}")
    for y, evs in data["eventos"].items():
        for m, ev in evs.items():
            print(y, m, ev["inicio_utc"], "->", ev["fin_utc"], "| plazo", ev["plazo_log_utc"],
                  "|", ev["plazo_log_estado"].split(" (")[0])


if __name__ == "__main__":
    main()
