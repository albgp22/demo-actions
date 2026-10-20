"""Búsqueda prefijo → entidad / zona CQ / continente con un fichero CTY.

Usa el CTY en JSON que publica el proyecto Not1MM (derivado del cty.dat de
country-files.com). Por defecto: data/cty/cty_not1mm.json (VER20260603).

    from ctylib import Cty
    cty = Cty()
    cty.lookup("EA8/EA4XXX")  # -> dict con entity, cq, itu, continent...
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_CTY = ROOT / "data" / "cty" / "cty_not1mm.json"

# Sufijos que no cambian la entidad
_IGNORED_SUFFIXES = {"P", "M", "MM", "AM", "QRP", "A", "B", "LH", "J", "R"}


class Cty:
    def __init__(self, path: Path | str = DEFAULT_CTY):
        raw = json.loads(Path(path).read_text(encoding="utf-8"))
        self.db: dict = {k: v for k, v in raw.items() if isinstance(v, dict)}
        self.version = next((k for k in self.db if re.fullmatch(r"=?VER\d{8}", k)), None)
        self.maxlen = max(len(k) for k in self.db)

    def _longest_prefix(self, call: str) -> dict | None:
        for n in range(min(len(call), self.maxlen), 0, -1):
            hit = self.db.get(call[:n])
            if hit is not None and not hit.get("exact_match"):
                return hit
        return None

    def lookup_prefix(self, prefix: str) -> dict | None:
        """Entidad de un prefijo (sin excepciones de indicativos concretos)."""
        return self._longest_prefix(prefix.strip().upper())

    def lookup(self, call: str) -> dict | None:
        call = call.strip().upper()
        if not call:
            return None
        # Coincidencia exacta (entradas "=CALL" del cty.dat)
        exact = self.db.get(call) or self.db.get("=" + call)
        if exact is not None and exact.get("exact_match"):
            return exact
        parts = [p for p in call.split("/") if p]
        if len(parts) == 1:
            return self._longest_prefix(parts[0])
        # Quitar sufijos que no cambian la entidad (/P, /M, /QRP...)
        parts = [p for p in parts if p not in _IGNORED_SUFFIXES] or parts[:1]
        if len(parts) == 1:
            return self._longest_prefix(parts[0])
        # PREFIJO/CALL o CALL/PREFIJO: el trozo más corto suele ser el prefijo
        a, b = parts[0], parts[-1]
        if re.fullmatch(r"\d", b):  # EA4XXX/8 -> cambia el dígito del indicativo
            m = re.match(r"([A-Z0-9]*?[A-Z])\d", a)
            if m:
                return self._longest_prefix(m.group(1) + b)
        pfx = a if len(a) <= len(b) else b
        return self._longest_prefix(pfx)


def qso_points(my: dict, other: dict) -> int:
    """Puntos por QSO según las bases del CQ WW 2026 (apartado «QSO Points»):
    3 entre continentes, 1 mismo continente y distinto país (2 si ambos están
    en Norteamérica), 0 mismo país (pero cuenta para multiplicadores)."""
    if other["entity"] == my["entity"]:
        return 0
    if other["continent"] != my["continent"]:
        return 3
    return 2 if my["continent"] == "NA" else 1


if __name__ == "__main__":
    cty = Cty()
    print("CTY:", cty.version)
    for c in ["EA4XXX", "EA6XX", "EA8XX", "EA9XX", "EA8/EA4XXX", "K1AR", "JA1XXX",
              "IG9X", "IT9XXX", "TA1XX", "4U1V", "GM/s", "CT3XX", "UA9XX", "R1FJ"]:
        print(c, cty.lookup(c))
