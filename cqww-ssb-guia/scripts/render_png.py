"""Renderiza cada página de un PDF a PNG para revisarla.

Uso: python scripts/render_png.py fichero.pdf carpeta_salida [dpi]"""
import sys
from pathlib import Path

import pymupdf


def main() -> None:
    pdf, out = Path(sys.argv[1]), Path(sys.argv[2])
    dpi = int(sys.argv[3]) if len(sys.argv) > 3 else 100
    out.mkdir(parents=True, exist_ok=True)
    doc = pymupdf.open(pdf)
    for i, page in enumerate(doc, start=1):
        page.get_pixmap(dpi=dpi).save(out / f"{pdf.stem}-{i:02d}.png")
    print(f"{doc.page_count} páginas → {out}")


if __name__ == "__main__":
    main()
