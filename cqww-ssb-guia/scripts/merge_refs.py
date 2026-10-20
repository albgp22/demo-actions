"""Une bib/propias.yml y data/*/refs.yml en bib/referencias.yml (Hayagriva).

Avisa de claves duplicadas o entradas sin 'type'/'title'."""
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
VALID = {"article", "chapter", "entry", "anthology", "report", "thesis", "web", "scene",
         "artwork", "patent", "case", "newspaper", "legislation", "manuscript", "post",
         "misc", "performance", "periodical", "proceedings", "book", "blog", "reference",
         "conference", "anthos", "repository", "thread", "video", "audio", "exhibition"}


def main() -> None:
    merged, origin = {}, {}
    files = [ROOT / "bib" / "propias.yml"] + sorted((ROOT / "data").glob("*/refs.yml"))
    for f in files:
        data = yaml.safe_load(f.read_text(encoding="utf-8")) or {}
        for k, v in data.items():
            if k in merged:
                print(f"DUPLICADA {k}: {origin[k]} y {f}")
                continue
            if not isinstance(v, dict) or "title" not in v:
                print(f"SIN TÍTULO {k} en {f}")
                continue
            t = str(v.get("type", "web")).lower()
            if t not in VALID:
                print(f"TIPO NO VÁLIDO {k}: {t} → web")
                t = "web"
            v["type"] = t
            merged[k], origin[k] = v, f
    out = ROOT / "bib" / "referencias.yml"
    out.write_text(yaml.safe_dump(merged, allow_unicode=True, sort_keys=False, width=1000), encoding="utf-8")
    print(f"{len(merged)} referencias → {out.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
