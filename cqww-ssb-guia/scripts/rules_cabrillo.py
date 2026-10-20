#!/usr/bin/env python3
"""Genera data/rules/cabrillo_template.log (ejemplo de log Cabrillo 3.0 para
CQ-WW-SSB, categoría Single-Op, All Band, Low Power, Non-Assisted, con overlay
ROOKIE) y lo valida.

Datos ficticios: EA4XXX, K1XXX, DL1XXX, EA8XXX, dirección y correo inventados.

Formato de la línea QSO (plantilla CQ WW / WWROF; anchos de columna
contrastados con Tlf share/cabrillo.fmt [CQWW] y not1mm plugins/cq_ww_ssb.py):

                              --------info sent------- -------info rcvd--------
QSO: freq  mo date       time call          rst exch   call          rst exch   t
QSO: ***** ** yyyy-mm-dd nnnn ************* nnn ****** ************* nnn ****** n

La columna "t" (transmisor 0/1) solo se usa en MULTI-ONE / MULTI-TWO.

Validación:
  1. Anchos de columna exactos (comprobación propia).
  2. Analizador independiente: paquete PyPI `cabrillo` 0.3.0 (thxo/cabrillo),
     que comprueba que los valores CATEGORY-* existen en la especificación
     WWROF, el orden temporal de los QSO y el formato de fecha/hora.
  3. CLAIMED-SCORE recalculado con las reglas 2026 (puntos y multiplicadores)
     usando el CTY del proyecto (scripts/ctylib.py) solo para clasificar
     indicativos.

Uso: python scripts/rules_cabrillo.py
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "data" / "rules" / "cabrillo_template.log"

MYCALL = "EA4XXX"
MYZONE = "14"

# (frecuencia kHz, modo, fecha, hora UTC, indicativo, RS enviado, zona enviada,
#  RS recibido, zona recibida)
QSOS = [
    (7150, "PH", "2027-10-30", "0002", "K1XXX", "59", MYZONE, "59", "05"),
    (3750, "PH", "2027-10-30", "0010", "DL1XXX", "59", MYZONE, "59", "14"),
    (14250, "PH", "2027-10-30", "0830", "EA8XXX", "59", MYZONE, "59", "33"),
]


def band_of(khz: int) -> str:
    for lo, hi, name in ((1800, 2000, "160M"), (3500, 4000, "80M"), (7000, 7300, "40M"),
                         (14000, 14350, "20M"), (21000, 21450, "15M"), (28000, 29700, "10M")):
        if lo <= khz <= hi:
            return name
    raise ValueError(f"{khz} kHz no es una banda del CQ WW")


def qso_points_2026(my: dict, other: dict) -> int:
    """Reglas CQ WW 2026, «QSO Points», incluida la excepción de Norteamérica."""
    if other["entity"] == my["entity"]:
        return 0  # mismo país: 0 puntos, pero cuenta como multiplicador
    if other["continent"] != my["continent"]:
        return 3
    if my["continent"] == "NA":
        return 2  # países distintos dentro de Norteamérica
    return 1


def qso_line(q) -> str:
    freq, mo, date, time, call, rst_s, exch_s, rst_r, exch_r = q
    line = (f"QSO: {freq:>5} {mo:<2} {date} {time} {MYCALL:<13} {rst_s:<3} {exch_s:<6} "
            f"{call:<13} {rst_r:<3} {exch_r:<6}")
    return line.rstrip()


def claimed_score() -> tuple[int, int, int, list[str]]:
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    from ctylib import Cty  # noqa: E402  (fichero del proyecto, solo lectura)

    cty = Cty()
    me = cty.lookup(MYCALL)
    pts, mults, notes = 0, set(), []
    for q in QSOS:
        other = cty.lookup(q[4])
        p = qso_points_2026(me, other)
        b = band_of(q[0])
        pts += p
        mults.add((b, "zona", q[8]))
        mults.add((b, "pais", other["entity"]))
        notes.append(f"{q[4]}: {other['entity']} ({other['continent']}, zona CQ {other['cq']}) "
                     f"en {b} -> {p} puntos")
        assert int(other["cq"]) == int(q[8]), (q[4], other["cq"], q[8])
    return pts, len(mults), pts * len(mults), notes


def build() -> str:
    pts, nmult, score, _ = claimed_score()
    header = [
        "START-OF-LOG: 3.0",
        "CONTEST: CQ-WW-SSB",
        f"CALLSIGN: {MYCALL}",
        "LOCATION: DX",
        "CATEGORY-OPERATOR: SINGLE-OP",
        "CATEGORY-ASSISTED: NON-ASSISTED",
        "CATEGORY-BAND: ALL",
        "CATEGORY-MODE: SSB",
        "CATEGORY-POWER: LOW",
        "CATEGORY-STATION: FIXED",
        "CATEGORY-TRANSMITTER: ONE",
        "CATEGORY-OVERLAY: ROOKIE",
        "CERTIFICATE: YES",
        f"CLAIMED-SCORE: {score}",
        "CLUB: RADIO CLUB EJEMPLO",
        "CREATED-BY: PROGRAMA-DE-LOG 1.0 (EJEMPLO)",
        "EMAIL: ea4xxx@example.com",
        "GRID-LOCATOR: IN80",
        "NAME: Nombre Apellido",
        "ADDRESS: Calle Ejemplo 1",
        "ADDRESS-CITY: Madrid",
        "ADDRESS-STATE-PROVINCE: Madrid",
        "ADDRESS-POSTALCODE: 28000",
        "ADDRESS-COUNTRY: Spain",
        f"OPERATORS: {MYCALL}",
        "SOAPBOX: ROOKIE overlay - date first licensed: 2026-03-15",
        "SOAPBOX: Single operator, 100 W, wire antenna. Datos de ejemplo.",
    ]
    lines = header + [qso_line(q) for q in QSOS] + ["END-OF-LOG:"]
    return "\n".join(lines) + "\n"


def check_columns(text: str) -> None:
    # Posiciones (0-based) de inicio de cada campo según la plantilla.
    widths = [("freq", 5), ("mo", 2), ("date", 10), ("time", 4), ("call_s", 13),
              ("rst_s", 3), ("exch_s", 6), ("call_r", 13), ("rst_r", 3), ("exch_r", 6)]
    for line in text.splitlines():
        if not line.startswith("QSO:"):
            continue
        pos = 5
        fields = {}
        for name, w in widths:
            fields[name] = line[pos:pos + w].strip()
            pos += w + 1
        assert fields["mo"] == "PH" and len(fields["date"]) == 10, line
        assert fields["call_s"] == MYCALL and fields["exch_s"] == MYZONE, line
        assert line[4] == " " and line[5:10].strip().isdigit(), line


def validate_with_library(text: str) -> None:
    try:
        from cabrillo.parser import parse_log_text
    except ImportError:
        print("AVISO: paquete `cabrillo` no instalado; se omite la validación externa")
        return
    cab = parse_log_text(text)  # lanza excepción si algo no cumple la especificación
    assert cab.contest == "CQ-WW-SSB" and cab.callsign == MYCALL
    assert cab.category_overlay == "ROOKIE" and cab.category_power == "LOW"
    assert len(cab.qso) == len(QSOS) and all(q.valid for q in cab.qso)
    print("OK: el analizador `cabrillo` 0.3.0 acepta la plantilla "
          f"({len(cab.qso)} QSO, categorías válidas según WWROF)")


def main() -> None:
    text = build()
    check_columns(text)
    validate_with_library(text)
    pts, nmult, score, notes = claimed_score()
    for n in notes:
        print("  ", n)
    print(f"Puntos {pts} x multiplicadores {nmult} = {score}")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(text, encoding="ascii")
    print(f"Escrito {OUT}")


if __name__ == "__main__":
    main()
