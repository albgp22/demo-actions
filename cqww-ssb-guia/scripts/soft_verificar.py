#!/usr/bin/env python3
"""Comprobaciones del capítulo de software (data/software/).

- refs.yml: claves soft-*, campos mínimos Hayagriva (type, title, url.value),
  entradas sin url.date (= no consultadas, POR VERIFICAR) y URL duplicadas
  respecto a los refs.yml de otros capítulos.
- facts.md: toda clave `soft-…`, `equip-…`, `rules-…` o `know-…` citada existe.
- tools.csv / receivers.csv: cabeceras y número de columnas.
- Versión de los ficheros CTY locales (data/cty/).
- --online: versión actual de not1mm en PyPI (único host consultable).

Uso:  python scripts/soft_verificar.py [--online]
"""

import csv
import glob
import json
import re
import sys
import urllib.request
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
SOFT = ROOT / "data" / "software"

TOOLS_HEADER = ["herramienta", "uso", "plataformas", "mac_nativo", "version",
                "fecha_version", "precio_licencia", "url", "verificado"]
RX_HEADER = ["nombre", "tipo", "ubicacion", "pais", "bandas", "url", "verificado", "nota"]


def load_refs(path: Path) -> dict:
    with path.open(encoding="utf-8") as fh:
        return yaml.safe_load(fh) or {}


def url_of(entry: dict):
    u = entry.get("url")
    return u.get("value") if isinstance(u, dict) else u


def norm(url) -> str:
    """URL normalizada para detectar duplicados (sin esquema, www. ni barra final)."""
    u = re.sub(r"^https?://(www\.)?", "", str(url or "")).rstrip("/")
    return u.lower()


def check_refs(errors: list) -> dict:
    refs = load_refs(SOFT / "refs.yml")
    sin_fecha = []
    for key, e in refs.items():
        if not key.startswith("soft-"):
            errors.append(f"refs.yml: clave sin prefijo soft-: {key}")
        for campo in ("type", "title", "url"):
            if campo not in e:
                errors.append(f"refs.yml: {key} sin '{campo}'")
        if not url_of(e):
            errors.append(f"refs.yml: {key} sin url.value")
        if not (isinstance(e.get("url"), dict) and e["url"].get("date")):
            sin_fecha.append(key)
    print(f"refs.yml: {len(refs)} entradas; {len(sin_fecha)} sin url.date (POR VERIFICAR):")
    print("  " + ", ".join(sin_fecha))
    # URL duplicadas frente a otros capítulos
    otros = {}
    for f in glob.glob(str(ROOT / "data" / "*" / "refs.yml")):
        if Path(f).parent.name == "software":
            continue
        for k, e in load_refs(Path(f)).items():
            otros[norm(url_of(e))] = k
    for k, e in refs.items():
        if norm(url_of(e)) in otros:
            errors.append(f"refs.yml: {k} repite la URL de {otros[norm(url_of(e))]}")
    return refs


def check_facts(refs: dict, errors: list) -> None:
    text = (SOFT / "facts.md").read_text(encoding="utf-8")
    citadas = set(re.findall(r"`((?:soft|equip|rules|know)-[a-z0-9-]+)`", text))
    externas = {}
    for f in glob.glob(str(ROOT / "data" / "*" / "refs.yml")):
        externas.update(load_refs(Path(f)))
    faltan = sorted(k for k in citadas if k not in refs and k not in externas)
    for k in faltan:
        errors.append(f"facts.md cita una clave inexistente: {k}")
    print(f"facts.md: {len(citadas)} claves citadas; {len(faltan)} sin definir")
    no_usadas = sorted(k for k in refs if k not in citadas)
    if no_usadas:
        print("  soft-* definidas pero no citadas en facts.md (se usan en los CSV o quedan para el capítulo):")
        print("  " + ", ".join(no_usadas))
    print(f"  'POR VERIFICAR' aparece {text.count('POR VERIFICAR')} veces")


def check_csv(name: str, header: list, errors: list) -> None:
    with (SOFT / name).open(encoding="utf-8", newline="") as fh:
        rows = list(csv.reader(fh))
    if rows[0] != header:
        errors.append(f"{name}: cabecera inesperada {rows[0]}")
    for i, r in enumerate(rows[1:], start=2):
        if len(r) != len(header):
            errors.append(f"{name}: línea {i} con {len(r)} columnas")
    if name == "tools.csv":
        bad = [r[0] for r in rows[1:] if r[3] not in ("si", "no", "vm", "POR VERIFICAR")]
        if bad:
            errors.append(f"tools.csv: mac_nativo no válido en {bad}")
    print(f"{name}: {len(rows) - 1} filas")


def cty_versions() -> None:
    j = ROOT / "data" / "cty" / "cty_not1mm.json"
    if j.exists():
        d = json.loads(j.read_text(encoding="utf-8"))
        ver = sorted(k for k in d if re.fullmatch(r"VER\d{8}", k))
        print(f"cty_not1mm.json: {ver}; VERSION -> {d.get('VERSION', {}).get('entity')}")
    t = ROOT / "data" / "cty" / "cty_tlf.dat"
    if t.exists():
        print(f"cty_tlf.dat: {sorted(set(re.findall(r'=VER\d{8}', t.read_text(encoding='latin-1'))))}")


def pypi_not1mm() -> None:
    with urllib.request.urlopen("https://pypi.org/pypi/not1mm/json", timeout=20) as r:
        d = json.load(r)
    files = d["urls"]
    print(f"PyPI not1mm: {d['info']['version']} subido {files[0]['upload_time_iso_8601'] if files else '?'}")


if __name__ == "__main__":
    errors: list = []
    refs = check_refs(errors)
    check_facts(refs, errors)
    check_csv("tools.csv", TOOLS_HEADER, errors)
    check_csv("receivers.csv", RX_HEADER, errors)
    cty_versions()
    if "--online" in sys.argv:
        pypi_not1mm()
    if errors:
        print("\nERRORES:")
        for e in errors:
            print("  - " + e)
        sys.exit(1)
    print("\nOK")
