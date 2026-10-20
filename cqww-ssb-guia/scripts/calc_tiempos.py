"""Horarios del CQ WW SSB en UTC y hora de Madrid, orto y ocaso.

Salidas (data/calc/):
  horarios.json        inicio/fin de cada edición en UTC y en hora de Madrid,
                       e instante del cambio CEST→CET dentro del concurso
  utc_madrid_2026.csv  correspondencia hora a hora UTC ↔ Madrid (fin de semana 2026)
  utc_madrid_2027.csv  ídem 2027
  orto_ocaso.csv       orto/ocaso (UTC) en Madrid y en zonas objetivo, días de concurso

Regla de fechas (bases): SSB el último fin de semana completo de octubre,
CW el último fin de semana completo de noviembre; empieza el sábado 00:00 UTC
y acaba el domingo 23:59:59 UTC.
"""
from __future__ import annotations

import csv
import json
from datetime import date, datetime, time, timedelta, timezone
from pathlib import Path
from zoneinfo import ZoneInfo

from astral import LocationInfo
from astral.sun import sun

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "data" / "calc"
OUT.mkdir(parents=True, exist_ok=True)
MAD = ZoneInfo("Europe/Madrid")
UTC = timezone.utc


def last_full_weekend(year: int, month: int) -> date:
    """Sábado del último fin de semana completo (sábado y domingo) del mes."""
    first_next = date(year + (month == 12), month % 12 + 1, 1)
    d = first_next - timedelta(days=1)  # último día del mes
    while d.weekday() != 6:  # domingo
        d -= timedelta(days=1)
    return d - timedelta(days=1)


def dst_change(year: int) -> datetime:
    """Instante (UTC) del paso de CEST a CET en Madrid: último domingo de octubre."""
    d = date(year, 10, 31)
    while d.weekday() != 6:
        d -= timedelta(days=1)
    return datetime.combine(d, time(1, 0), tzinfo=UTC)


def fmt(dt: datetime) -> str:
    return dt.strftime("%Y-%m-%d %H:%M:%S %Z")


DIAS = ["lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"]


def edition(year: int, month: int) -> dict:
    sat = last_full_weekend(year, month)
    start = datetime.combine(sat, time(0, 0), tzinfo=UTC)
    end = start + timedelta(days=2) - timedelta(seconds=1)
    out = {
        "modo": "SSB" if month == 10 else "CW",
        "sabado": sat.isoformat(),
        "inicio_utc": fmt(start),
        "fin_utc": fmt(end),
        "inicio_madrid": f"{DIAS[start.astimezone(MAD).weekday()]} {fmt(start.astimezone(MAD))}",
        "fin_madrid": f"{DIAS[end.astimezone(MAD).weekday()]} {fmt(end.astimezone(MAD))}",
        "duracion_h": (end - start + timedelta(seconds=1)).total_seconds() / 3600,
    }
    if month == 10:
        ch = dst_change(year)
        out["cambio_hora_utc"] = fmt(ch)
        out["cambio_hora_madrid"] = (
            f"{fmt((ch - timedelta(seconds=1)).astimezone(MAD))} → {fmt(ch.astimezone(MAD))}"
        )
        out["cambio_dentro_del_concurso"] = start <= ch <= end
    return out


def hour_table(year: int) -> list[dict]:
    sat = last_full_weekend(year, 10)
    start = datetime.combine(sat, time(0, 0), tzinfo=UTC)
    rows = []
    for h in range(48):
        t = start + timedelta(hours=h)
        loc = t.astimezone(MAD)
        rows.append({
            "utc": f"{DIAS[t.weekday()][:3]} {t:%H:%M}",
            "madrid": f"{DIAS[loc.weekday()][:3]} {loc:%H:%M} {loc.tzname()}",
            "offset_h": int(loc.utcoffset().total_seconds() // 3600),
        })
    return rows


# Coordenadas aproximadas de ciudades representativas (lat, lon) y su zona CQ
SITES = [
    ("Madrid (EA4, zona 14)", 40.4168, -3.7038),
    ("Las Palmas (EA8, zona 33)", 28.1235, -15.4363),
    ("Moscú (UA3, zona 16)", 55.7558, 37.6173),
    ("Nueva York (W2, zona 5)", 40.7128, -74.0060),
    ("Chicago (W9, zona 4)", 41.8781, -87.6298),
    ("Los Ángeles (W6, zona 3)", 34.0522, -118.2437),
    ("Anchorage (KL7, zona 1)", 61.2181, -149.9003),
    ("Honolulu (KH6, zona 31)", 21.3069, -157.8583),
    ("Ciudad de México (XE1, zona 6)", 19.4326, -99.1332),
    ("Caracas (YV, zona 9)", 10.4806, -66.9036),
    ("São Paulo (PY2, zona 11)", -23.5505, -46.6333),
    ("Buenos Aires (LU, zona 13)", -34.6037, -58.3816),
    ("Santiago (CE, zona 12)", -33.4489, -70.6693),
    ("Dakar (6W, zona 35)", 14.7167, -17.4677),
    ("Nairobi (5Z, zona 37)", -1.2921, 36.8219),
    ("Johannesburgo (ZS, zona 38)", -26.2041, 28.0473),
    ("Tel Aviv (4X, zona 20)", 32.0853, 34.7818),
    ("Nueva Delhi (VU, zona 22)", 28.6139, 77.2090),
    ("Novosibirsk (UA9, zona 18)", 55.0084, 82.9357),
    ("Pekín (BY1, zona 24)", 39.9042, 116.4074),
    ("Tokio (JA1, zona 25)", 35.6762, 139.6503),
    ("Yakarta (YB, zona 28)", -6.2088, 106.8456),
    ("Perth (VK6, zona 29)", -31.9505, 115.8605),
    ("Sídney (VK2, zona 30)", -33.8688, 151.2093),
    ("Auckland (ZL, zona 32)", -36.8485, 174.7633),
]


def sun_rows(days: list[date]) -> list[dict]:
    rows = []
    for name, lat, lon in SITES:
        loc = LocationInfo(name=name, region="", timezone="UTC", latitude=lat, longitude=lon)
        for d in days:
            s = sun(loc.observer, date=d, tzinfo=UTC)
            rows.append({
                "lugar": name, "lat": lat, "lon": lon, "fecha": d.isoformat(),
                "orto_utc": s["sunrise"].strftime("%H:%M"),
                "ocaso_utc": s["sunset"].strftime("%H:%M"),
                "mediodia_utc": s["noon"].strftime("%H:%M"),
            })
    return rows


def main() -> None:
    eds = {}
    for y in (2026, 2027, 2028):
        eds[f"{y}-SSB"] = edition(y, 10)
        eds[f"{y}-CW"] = edition(y, 11)
    (OUT / "horarios.json").write_text(json.dumps(eds, ensure_ascii=False, indent=2), encoding="utf-8")
    for y in (2026, 2027):
        with open(OUT / f"utc_madrid_{y}.csv", "w", newline="", encoding="utf-8") as f:
            w = csv.DictWriter(f, fieldnames=["utc", "madrid", "offset_h"])
            w.writeheader()
            w.writerows(hour_table(y))
    days = [last_full_weekend(2026, 10), last_full_weekend(2026, 10) + timedelta(days=1),
            last_full_weekend(2027, 10), last_full_weekend(2027, 10) + timedelta(days=1)]
    rows = sun_rows(days)
    with open(OUT / "orto_ocaso.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)
    print(json.dumps(eds, ensure_ascii=False, indent=2))
    for r in rows:
        if r["fecha"] in ("2026-10-24",):
            print(f"{r['lugar']:34s} orto {r['orto_utc']}  ocaso {r['ocaso_utc']} UTC")


if __name__ == "__main__":
    main()
