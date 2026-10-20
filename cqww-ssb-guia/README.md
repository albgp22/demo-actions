# Guía del CQ WW DX SSB (Typst)

Manual de referencia en español para escuchar, preparar y participar en el
CQ World Wide DX Contest SSB desde Madrid (EA4XXX, IN80, zona CQ 14).

- `cqww-ssb-guia.pdf`: la guía completa (40 páginas A4).
- `chuleta.pdf`: la chuleta de una página para imprimir.

## Estructura

| Ruta | Contenido |
|---|---|
| `main.typ` | Documento principal. **Al principio, tus datos** (indicativo, locator, categoría, fecha de licencia…) |
| `chuleta.typ` | Chuleta independiente (toma los datos de `main.typ`) |
| `plantilla.typ` | Estilos, cajas «Importante / Error típico / Truco», tablas y diagrama |
| `capitulos/` | Un fichero por capítulo (`01-resumen.typ` … `17-supuestos.typ`, `anexo-chuleta.typ`) |
| `assets/` | Figuras generadas (PDF vectorial + PNG) |
| `data/` | Datos y notas de investigación con sus fuentes (`*/facts.md`, `*/refs.yml`, CSV) y resultados de cálculo (`data/calc/`) |
| `scripts/` | Python: cálculos (`calc_*`), figuras (`fig_*`), investigación (`rules_*`, `legal_*`, `equip_*`, `soft_*`, `hist_*`, `know_*`) |
| `bib/` | Bibliografía Hayagriva (`referencias.yml` se genera con `scripts/merge_refs.py`) |
| `fonts/` | Inter y JetBrains Mono (licencia OFL), para compilar igual en cualquier equipo |

## Compilar

Typst 0.15.1 (en macOS: `brew install typst`):

```
typst compile --font-path fonts main.typ cqww-ssb-guia.pdf
typst compile --font-path fonts chuleta.typ chuleta.pdf
```

## Regenerar datos y figuras

```
uv venv .venv && uv pip install --python .venv/bin/python -r requirements.txt
.venv/bin/python scripts/calc_tiempos.py
.venv/bin/python scripts/calc_puntos.py
.venv/bin/python scripts/calc_puntuacion.py
.venv/bin/python scripts/calc_ventanas.py
.venv/bin/python scripts/know_muf.py --root .
.venv/bin/python scripts/calc_plan_bandas.py 120
.venv/bin/python scripts/calc_plan_bandas.py 100 2027-10-31
.venv/bin/python scripts/fig_mapa_zonas.py
.venv/bin/python scripts/fig_luz_greyline.py
.venv/bin/python scripts/fig_solar.py
.venv/bin/python scripts/merge_refs.py
```

Analizar logs públicos de cqww.com (necesita internet): ver
`scripts/hist_analyze_logs.py --help` y el capítulo 11.

Los datos se verificaron el 20 de octubre de 2026; lo no confirmado en fuente
primaria aparece marcado como «POR VERIFICAR» (lista en el capítulo 17).
