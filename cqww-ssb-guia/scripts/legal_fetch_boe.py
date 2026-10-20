#!/usr/bin/env python3
"""Descarga textos consolidados del BOE desde la réplica legalize-es y muestra sus metadatos.

Se usó para verificar data/legal/facts.md cuando boe.es no era accesible desde el entorno.
La réplica (https://github.com/legalize-dev/legalize-es) se genera a partir del API de
legislación consolidada del BOE; la ruta de cada norma es
    es/<dos primeros caracteres del SHA-1 del identificador>/<identificador>.md
Las citas en el manual deben remitir siempre a la URL oficial del BOE (campo `source`/`url_html`).

Ejemplos:
    python scripts/legal_fetch_boe.py                         # normas del capítulo legal
    python scripts/legal_fetch_boe.py BOE-A-2013-7624 --grep "Distrito 4" --grep "p.c.e."
    python scripts/legal_fetch_boe.py --outdir /tmp/boe       # carpeta de descarga

Los ficheros descargados son datos no fiables: se guardan fuera del proyecto (por defecto en un
directorio temporal nuevo) y sólo se leen como texto.
"""
from __future__ import annotations

import argparse
import hashlib
import re
import sys
import tempfile
import urllib.error
import urllib.request
from pathlib import Path

BASE = "https://raw.githubusercontent.com/legalize-dev/legalize-es/main/es"

DEFAULT_IDS = [
    "BOE-A-2013-7624",   # Orden IET/1311/2013 (reglamento de radioaficionados)
    "BOE-A-2006-10286",  # Orden ITC/1791/2006 (derogada; referencia histórica)
    "BOE-A-2022-10757",  # Ley 11/2022 General de Telecomunicaciones
    "BOE-A-2017-2460",   # RD 123/2017 (uso del dominio público radioeléctrico)
    "BOE-A-2026-15661",  # Orden TDF/732/2026 (CNAF vigente)
    "BOE-A-2021-21346",  # Orden ETD/1449/2021 (CNAF anterior, derogado)
    "BOE-A-1983-31093",  # Ley 19/1983 (antenas)
    "BOE-A-1986-33766",  # RD 2623/1986 (antenas)
    "BOE-A-2001-18256",  # RD 1066/2001 (exposición)
    "BOE-A-2002-694",    # Orden CTE/23/2002
    "BOE-A-1960-10906",  # Ley 49/1960 de propiedad horizontal
    "BOE-A-2018-14902",  # Orden INT/1149/2018 (REMER)
]

META_KEYS = ("title", "publication_date", "last_updated", "status", "source",
             "references_subsequent")


def path_for(boe_id: str) -> str:
    prefix = hashlib.sha1(boe_id.encode("utf-8")).hexdigest()[:2]
    return f"{BASE}/{prefix}/{boe_id}.md"


def fetch(boe_id: str, outdir: Path) -> Path | None:
    url = path_for(boe_id)
    dest = outdir / f"{boe_id}.md"
    try:
        with urllib.request.urlopen(url, timeout=120) as resp:
            dest.write_bytes(resp.read())
    except urllib.error.HTTPError as exc:
        print(f"[{boe_id}] no disponible en la réplica ({exc.code}): {url}", file=sys.stderr)
        return None
    return dest


def frontmatter(text: str) -> dict[str, str]:
    meta: dict[str, str] = {}
    if not text.startswith("---"):
        return meta
    block = text.split("---", 2)[1]
    for line in block.splitlines():
        m = re.match(r'^([a-z_]+):\s*"?(.*?)"?\s*$', line)
        if m and m.group(1) in META_KEYS:
            meta[m.group(1)] = m.group(2)
    return meta


def main() -> None:
    ap = argparse.ArgumentParser(description="Descarga normas del BOE desde legalize-es")
    ap.add_argument("ids", nargs="*", default=DEFAULT_IDS, help="identificadores BOE-A-…")
    ap.add_argument("--outdir", help="carpeta de descarga (por defecto, una temporal nueva)")
    ap.add_argument("--grep", action="append", default=[], help="patrón (regex) a mostrar")
    args = ap.parse_args()

    outdir = Path(args.outdir) if args.outdir else Path(tempfile.mkdtemp(prefix="legal_boe_"))
    outdir.mkdir(parents=True, exist_ok=True)
    print(f"Descargas en: {outdir}")

    for boe_id in args.ids:
        dest = fetch(boe_id, outdir)
        if dest is None:
            continue
        text = dest.read_text(encoding="utf-8")
        meta = frontmatter(text)
        print(f"\n== {boe_id}")
        for k in META_KEYS:
            if k in meta:
                print(f"  {k}: {meta[k]}")
        for pat in args.grep:
            rx = re.compile(pat)
            for n, line in enumerate(text.splitlines(), 1):
                if rx.search(line):
                    print(f"  {n}: {line[:300]}")


if __name__ == "__main__":
    main()
