# Historial del CQ WW DX SSB: resultados EA y propagación (ediciones 2022–2025)

Recopilado el 2026-10-20 para la guía del CQ WW SSB (estación de Madrid, SOAB baja potencia + ROOKIE en 2027).

## Cómo leer este documento

- **FINAL**: puntuación publicada por cqww.com después de comprobar los logs.
  **DECLARADA** (*claimed*): la que envió el participante o un listado preliminar, antes de esa comprobación.
- **POR VERIFICAR**: el dato procede de una fuente que no se ha podido leer literalmente, o no se ha encontrado.
- **Cómo se ha verificado cada dato.** Desde el contenedor de trabajo no se puede abrir cqww.com, 3830scores.com, lists.contesting.com, qsl.net, celestrak.org, swpc.noaa.gov ni gfz-potsdam.de (bloqueo del proxy). Por eso:
  - Los **resultados** se han obtenido de **resúmenes del buscador (WebSearch)** de las páginas y PDF citados. A veces el resumen incluye una cita textual entre comillas. Cuando solo parafrasea, la cifra va marcada POR VERIFICAR.
  - Las **condiciones solares** se han leído **directamente** de los ficheros de CelesTrak que trae el paquete PyPI `spaceweather` (copia en raw.githubusercontent.com), con el script `scripts/hist_solar_extract.py`. Son datos verificados.
- Se agotó el **cupo de búsquedas** de la sesión (200 consultas compartidas). Quedan sin consultar los boletines de propagación de la ARRL, el *soapbox* de 3830 y los desgloses por banda de 3830 de 2022–2025 (ver § 8).

Ficheros asociados: `results_ea.csv`, `solar.csv`, `band_breakdowns.csv`, `refs.yml` (claves `hist-…`) y `fig_solar_cqww_ssb.{png,svg}`.

---

## 1. Ediciones con resultados finales publicados (a 2026-10-20)

| Edición | Fechas (sáb–dom, UTC) | Resultados finales | Notas |
|---|---|---|---|
| 2022 | 29–30 oct 2022 | Sí: PDF «Results of the 2022 CQWW DX SSB Contest» [`hist-cqww-2022-ssb-results`] | Fecha calculada con la regla del último fin de semana completo de octubre |
| 2023 | 28–29 oct 2023 | Sí: PDF «Results of the 2023 CQ WW DX SSB Contest» [`hist-cqww-2023-ssb-results`] | 9.638 participaciones SSB según la página de estadísticas [`hist-cqww-stats`] (resumen de búsqueda) |
| 2024 | 26–27 oct 2024 | Sí: PDF fechado en **febrero de 2025** [`hist-cqww-2024-ssb-results`]. Anuncio en CQ-Contest «Final 2024 CQ WW SSB Results Posted» [`hist-cqcontest-2024-final`] | Fechas confirmadas por las bases de 2024 («SSB: October 26-27») [`hist-cqww-rules-2024`] |
| 2025 | 25–26 oct 2025 | Sí: PDF fechado en **febrero de 2026**, firmado por K1AR [`hist-cqww-2025-ssb-results`] | La página de cq.sk describía antes resultados **preliminares** [`hist-cqsk-2025-ssb-prelim`] |
| 2026 | **24–25 oct 2026** (este fin de semana) | Todavía no se ha celebrado | Las bases de 2026 (PDF fechado el 5-sep-2026) existen [`hist-cqww-rules-2026`], pero la fecha no se pudo leer en ellas: **POR VERIFICAR** |
| 2027 | **30–31 oct 2027** (calculada) | — | Fecha deducida de la regla del último fin de semana completo de octubre: **POR VERIFICAR** cuando se publiquen las bases |

El concurso empieza a las 00:00:00 UTC del sábado y termina a las 23:59:59 UTC del domingo (bases de 2024, cita en resumen de búsqueda) [`hist-cqww-rules-2024`].

Participación (resúmenes de búsqueda de los PDF):

- **2024**: 10.098 logs y más de 5 millones de QSO. Fue la primera vez que se superaron los 10.000 logs [`hist-cqww-2024-ssb-results`].
- **2025**: récord de **10.576 logs**, unos dos tercios enviados en las 48 h siguientes al final. En total 5.148.149 QSO, 1.356 participaciones monobanda en 10 m y 324 récords batidos [`hist-cqww-2025-ssb-results`].
  - La tabla de participación del PDF trae la fila «SOAB LOW ASSISTED | 7 | 110 | 795 | 451 | 37 | 72 | 1472». Su suma cuadra con el total (1.472 entradas en monooperador asistido de baja potencia). Si el orden de columnas es AF, AS, EU, NA, OC, SA, **795 de ellas eran europeas**. Ese orden es una deducción: **POR VERIFICAR**.

---

## 2. Resultados por edición

> Entidades EA: **EA** (España peninsular, Europa, zona CQ 14), **EA6** (Baleares, Europa, zona 14), **EA8** (Canarias, **África**, zona 33) y **EA9** (Ceuta y Melilla, **África**, zona 33), según el CTY del proyecto (`data/cty/cty_not1mm.json`, VER20260603). Son entidades distintas, cada una con su clasificación en la base de datos de cqww.com (`dx=EA`, `dx=EA6`, `dx=EA8`, `dx=EA9`). Para una estación peninsular, un QSO con EA8 o EA9 es intercontinental (3 puntos); con EA6, 1 punto; con otra EA, 0 puntos, aunque sí cuenta para multiplicadores (reglas de puntuación del CQ WW [`hist-cqww-rules-2025`], no releídas literalmente en esta sesión; están aplicadas en `scripts/hist_analyze_logs.py`).

### 2025 (25–26 oct)

- **Mundial SOAB baja potencia, FINAL:** **N1UR** (Ed Sawyer), «a U.S. entry», con **≈4,9 millones**. El artículo dice que casi duplicó al segundo, **PC0A** (Dick), con **≈2,8 millones**.
  - Cita en el resumen de búsqueda: «The world low-power, single-operator category was won by a U.S. entry, Ed, N1UR, who churned out a 4.9 million point result» [`hist-cqww-2025-ssb-results`].
  - Placa «World – Low Power: Ed Sawyer, N1UR» [`hist-cqww-2025-ssb-plaques`].
  - La cifra de PC0A es una paráfrasis del resumen: POR VERIFICAR.
- **DECLARADA o preliminar** para el mismo N1UR: «vyše 5,2 milióna bodov» (más de 5,2 millones) [`hist-cqsk-2025-ssb-prelim`]. Tras la comprobación quedó en ≈4,9 M, una reducción del orden del 6 % (las dos cifras están redondeadas). Ilustra la diferencia entre puntuación declarada y final.
- **ROOKIE:** el récord ROOKIE de baja potencia en SSB es de **9K2ES (2025) con 3.550.008** (cita «ROOKIE Low Power | 9K2ES | 2025 | 3,550,008») [`hist-cqww-records-overlay`].
- **Estaciones EA:** no se pudo obtener ninguna puntuación EA de 2025 en SOAB LP, SOA LP ni ROOKIE: **POR VERIFICAR**. Pistas no verificadas:
  - El PDF de 2025 menciona una puntuación monooperador de EA3CI, pero el texto extraído estaba fragmentado.
  - La página de clubes de 2025 situaría al **EA Contest Club en el 3.er puesto de los clubes DX** [`hist-cqww-clubscores`]. Es un resumen de búsqueda y la clasificación de clubes suele sumar SSB y CW: POR VERIFICAR.

### 2024 (26–27 oct)

- **Mundial SOAB baja potencia, FINAL:** **P40W (op. W2GD)**, **≈7,8 millones** con ≈5.000 QSO a 100 W. Segundo, **NP4Z** (Felipe), con **≈6,1 millones**.
  - Cita en el resumen de búsqueda: «John, W2GD, piloted his P40W station to another win, ringing in a final score of 7.8 million with 5,000 QSOs while running only 100 watts. Felipe, NP4Z, offered plenty of competitive heat for GD with a 6.1 million second-place effort» [`hist-cqww-2024-ssb-results`].
  - Otro resumen da para NP4Z el indicativo de estación KP2B: POR VERIFICAR.
- **Europa SOAB baja potencia:** placa para **UW5Y (op. Slava Zhuk, US2YW)** [`hist-cqww-2024-ssb-plaques`]. Un resumen del PDF le atribuye **3.894.098** puntos, sin cita literal: POR VERIFICAR.
- **Estación EA en SO LOW ALL (FINAL):** **EA8AQV** (Canarias), **134.384 puntos**, 312 QSO, 46 zonas, 102 países, 14,8 h de operación.
  - Puesto 2.937 del listado general de 2024 ordenado por puntos, que mezcla todas las categorías. Con 10.098 logs recibidos, queda más o menos en el 30 % superior; es una aproximación, porque el listado puede no coincidir con los logs recibidos.
  - Fila citada: «2937 · EA8AQV · EA8 · 2024 · SO LOW ALL · 134,384 · 312 · 46 · 102 · 14.8». Comprobación aritmética: 908 puntos × 148 multiplicadores = 134.384 [`hist-cqww-scores-2024-p30`].
  - **No consta que sea la mejor EA8 en baja potencia**: es la única fila EA en LP con cifras completas que se encontró.
- En esa misma página, con puntuaciones del orden de 130.000, el resumen menciona otras estaciones EA/EA8 en **SA LOW ALL** (asistido, baja potencia) sin dar sus cifras (indicativos citados: EC8AQQ, EA8DEE; posible confusión del resumen): **POR VERIFICAR**.
- **Contexto, alta potencia y multioperador (cifras aproximadas del resumen de la página del año [`hist-cqww-scores-2024`], todas POR VERIFICAR):**
  - **ED1R**, multi-single alta, ≈12,1 M (puesto 56 general).
  - **ED5D**, ≈11,4 M (puesto 59).
  - **EA2W**, ≈11,1 M (puesto 62). El PDF de placas asociaría a EA2W (Jon Zumalabe) con la placa «Europe Assisted».
- **ROOKIE:** récord ROOKIE de alta potencia en SSB, **KC1TNO (2024) con 6.134.297** [`hist-cqww-records-overlay`]. No se encontraron rookies EA en 2024: **POR VERIFICAR**.

### 2023 (28–29 oct)

- **Mundial SOAB baja potencia:** ganador y puntuación **no obtenidos: POR VERIFICAR** [`hist-cqww-2023-ssb-results`].
- **Operador español fuera de EA:** un resumen dice que la lista de baja potencia del PDF incluye **CR2B (EA1BP) con 2.572.485**. CR2B es un indicativo de Azores (Europa, zona 14), así que no es una entidad EA. **POR VERIFICAR**.
- **Estación EA en SO LOW ALL (FINAL):** **EA5JAX**, **21.945 puntos**, 135 QSO, 27 zonas, 78 países, 22,8 h.
  - Fila citada: «1391 · EA5JAX · EA · 2023 · SO LOW ALL · 21,945 · 135 · 27 · 78 · 22.8», en el puesto 1.391 del histórico EA SO LOW ALL de todos los años. Comprobación: 209 × 105 = 21.945 [`hist-cqww-scores-ea-sl-p14`].
  - Es un esfuerzo modesto, no el mejor EA del año.
- **Contexto:** un resumen menciona **EA5GS con 1.767.227** en un listado de alta potencia. Categoría no confirmada: **POR VERIFICAR**.

### 2022 (29–30 oct)

- **Mundial SOAB baja potencia:** **no obtenido: POR VERIFICAR** [`hist-cqww-2022-ssb-results`].
- **Europa SOAB baja potencia:** según un resumen del PDF, «The European low-power winner was CR2B, operated by EA1BP (Miguel Angel Devora Jimenez)». Es un operador español desde Azores, y la puntuación no aparece en el resumen: **POR VERIFICAR**.
- **Estación EA:** **EA4Z, 47.100 puntos**, en un listado EA de categorías monooperador (página 25, puestos 2408–2497) [`hist-cqww-scores-ea-s-p25`]. La categoría exacta (LP/HP, asistido o no) no aparece: **POR VERIFICAR**.

### Escala histórica

- **Récord mundial SOAB baja potencia SSB:** **D44TD (op. IV3TAN), 11.199.793 puntos (2002)** [`hist-cqww-records`].

---

## 3. Overlay ROOKIE

- **Definición:** operador con licencia de radioaficionado obtenida **menos de tres años** antes del concurso. Cita de las bases de 2025 en el resumen de búsqueda: «Rookie (ROOKIE): The operator was first licensed as a radio amateur less than three (3)…» [`hist-cqww-rules-2025`].
  - Para el concurso del 30–31 oct 2027 eso supone una licencia posterior a ≈30 oct 2024. Es un cálculo propio: compruébalo en las bases de 2027.
- **Récords ROOKIE SSB:** baja potencia, 9K2ES (2025) con 3.550.008; alta potencia, KC1TNO (2024) con 6.134.297 [`hist-cqww-records-overlay`].
- **Rookies EA en 2022–2025: no encontrados (POR VERIFICAR).** Para comprobarlo, en un navegador o con `scripts/hist_fetch_scores.py` (patrón deducido de URL indexadas):
  `https://cqww.com/overlayscores.htm?page=1&mode=ph&yr=2025&dx=EA&cat=L&over=ROOKIE`

---

## 4. ¿Qué puntuación hace una estación EA «típica» en baja potencia?

**No hay datos suficientes para dar una mediana. El rango típico queda POR VERIFICAR.** Puntos de referencia encontrados, todos FINALES:

| Año | Indicativo | Categoría | Puntos | QSO | Zonas | Países | Horas |
|---|---|---|---|---|---|---|---|
| 2024 | EA8AQV (Canarias) | SO LOW ALL | 134.384 | 312 | 46 | 102 | 14,8 |
| 2023 | EA5JAX | SO LOW ALL | 21.945 | 135 | 27 | 78 | 22,8 |
| 2022 | EA4Z | monooperador (POR VERIFICAR) | 47.100 | — | — | — | — |

- El listado histórico EA SO LOW ALL de todos los años tiene al menos ≈1.400 entradas: EA5JAX, con 21.945, está en el puesto 1.391.
- La página 25 del listado EA monooperador, puestos ≈2.400–2.500, ronda los 47.000–50.000 puntos (ejemplos citados: EA1NE 2007 con 50.112; EA1BT 2004 con 49.737; EA3CS 2016 con 47.360) [`hist-cqww-scores-ea-s-p25`].
- Cómo obtener la distribución real (mediana y cuartiles FINALES de EA, EA6, EA8 y EA9 en SO LOW ALL y SA LOW ALL) en un equipo con Internet:

```
.venv/bin/python scripts/hist_fetch_scores.py --years 2022 2023 2024 2025 \
    --dx EA EA6 EA8 EA9 --cats "SL ALL" "AL ALL" --out data/history/scores_ea_lp.csv
```

  Los códigos `SL ALL` (SO LOW ALL) y `AL ALL` (asistido LOW ALL) están deducidos de URL indexadas: POR VERIFICAR.

---

## 5. Condiciones solares y geomagnéticas de cada edición

Datos **verificados**, leídos del fichero CelesTrak SW-Last5Years.txt (UPDATED 2026-07-01) y SW-All.txt (UPDATED 2025-07-21) [`hist-celestrak-sw-5y`, `hist-celestrak-sw-all`, `hist-pyspaceweather`].

- F10.7 = flujo **observado** en Penticton a las 20 UT.
- SSN = número de manchas internacional diario (SILSO).
- Ap = índice planetario diario (GFZ).
- Kp máx. = máximo de los 8 valores trihorarios del día.
- Descriptores del Ap (convención clásica NOAA/ARRL; POR VERIFICAR en la fuente): 0–7 tranquilo, 8–15 inestable, 16–29 activo, ≥30 tormenta.
- Kp 5 equivale a tormenta G1 y Kp 6 a G2 [`hist-noaa-scales`, no consultada].

| Edición | Día | F10.7 obs. | SSN | Ap | Kp máx. | Lectura |
|---|---|---|---|---|---|---|
| 2022 | sáb 29 | 133,9 | 87 | 25 | 5- (06–12 UTC) | flujo moderado; geomagnético **activo** el sábado, rozando G1 sin alcanzarlo |
| 2022 | dom 30 | 130,5 | 75 | 10 | 3o | inestable |
| 2023 | sáb 28 | 128,0 | 49 | 17 | 4o (21–24 UTC) | flujo por debajo de la media de 81 días (≈151); activo |
| 2023 | dom 29 | 135,2 | 58 | 26 | 5- (00–03 UTC) | **activo** la noche del sábado al domingo |
| 2024 | sáb 26 | 238,4 | 217 | 12 | 4o (18–24 UTC) | **flujo muy alto**, el mayor de las cuatro ediciones (media de 81 días ≈203); inestable |
| 2024 | dom 27 | 246,2 | 241 | 10 | 3- | flujo muy alto; inestable |
| 2025 | sáb 25 | 127,0 | 102 | 8 | 4- (03–06 UTC) | flujo moderado, por debajo de la media de 81 días (≈149); inestable o casi tranquilo |
| 2025 | dom 26 | 123,4 | 103 | 3 | 1+ | **muy tranquilo** |

- Ninguna de las cuatro ediciones tuvo tormenta geomagnética según el Kp de GFZ que trae el fichero de CelesTrak (máximo 5-, es decir, 4,67).
- En el viernes previo, el Kp máximo fue 4+ en 2022, 4o en 2023, 1o en 2024 y 3o en 2025 (ver `solar.csv`).
- **Contexto (ciclo 23, en `solar.csv`):**
  - 1999 (30–31 oct): F10.7 169/160, tranquilo.
  - 2000 (28–29 oct): F10.7 182/187, con **tormenta**: Kp 5+ el sábado y **Kp 6o, Ap 34 el domingo** (G2).
- **Previsión.** Medias mensuales previstas en el mismo fichero (actualizado el 2026-07-01). El origen exacto de la predicción está POR VERIFICAR [`hist-celestrak-format`].
  - **Octubre de 2026:** SSN ≈ 84, F10.7 ≈ 119. Medias observadas de enero a junio de 2026: F10.7 151, 136, 131, 120, 126 y 139; SSN 113, 78, 86, 79, 102 y 94.
  - **Octubre de 2027** (la edición del usuario): SSN ≈ 57, F10.7 ≈ 98, en descenso.
  - Son medias mensuales: no predicen el Kp ni el flujo de un día concreto. Para el fin de semana del concurso hay que mirar el pronóstico de 27 días y el de 3 días de NOAA SWPC en las semanas previas.
- **Qué dijeron los participantes (*soapbox* de 3830, boletines ARRL, comentarios de los PDF): POR VERIFICAR.**
  - No hay citas verificadas sobre aperturas de 10 m ni sobre perturbaciones en 2022–2025.
  - El PDF de 2025 solo indica, según el resumen, mucha actividad monobanda en 10 m: 1.356 participaciones.
  - Interpretación propia, no es un informe de los participantes: 2024 combinó el flujo más alto del ciclo 25 en estas fechas con un campo geomagnético solo inestable, el escenario más favorable para las bandas altas de las cuatro ediciones; 2027 se espera con bastante menos flujo.
- Gráfico: `fig_solar_cqww_ssb.png` / `.svg` (F10.7 y Kp máx. de sábado y domingo, 1999, 2000 y 2022–2025).

---

## 6. Logs públicos de cqww.com

**Lo que se sabe (resúmenes de búsqueda)** [`hist-cqww-publiclogs`]:

- La página `https://cqww.com/publiclogs/` dice: «it is our policy to make the logs of all entries (except checklogs) public».
- Tiene una tabla por años con el enlace «View SSB logs».
- Los logs están en Cabrillo, sin los campos ADDRESS ni EMAIL.
- Hay además informes públicos de comprobación (LCR) de las estaciones con más puntos en `https://cqww.com/publiclcr/` [`hist-cqww-publiclcr`].

**Patrón de URL de cada log: POR VERIFICAR.** No se pudo confirmar.

- El script usa por defecto `https://cqww.com/publiclogs/{año}ph/{indicativo}.log`: minúsculas, con `/` → `-`, y prueba también `_` o quitar la barra.
- La base es configurable con `--base-url`.
- Con `--from-index` el script lee el índice del año y usa los enlaces reales, así que no depende del patrón.

**API REST pública** [`hist-cqww-api`, `hist-cqww-api-blog`]:

- Peticiones GET, sin autenticación, que devuelven JSON.
- Puntuación final por modo, año e indicativo, por ejemplo `https://cqww.com/api/get/score/ph/2020/k5zd`.
- Récords: `/api/get/record/<modo>/<categoría>/<región>`.
- Listas auxiliares: `geolist`, `catlist` y `clublist`.
- Puntuaciones brutas: `/raw/<modo>/category/<nombre>` y `/raw/<modo>/callsign/<indicativo>/`.

### Cómo ejecutar el análisis de logs (`scripts/hist_analyze_logs.py`)

Requisitos: el `.venv` del proyecto (Python 3 + matplotlib) y el CTY `data/cty/cty_not1mm.json`.

```
# A) Logs ya descargados (p. ej. guardados a mano desde cqww.com/publiclogs/)
.venv/bin/python scripts/hist_analyze_logs.py --logs-dir ruta/logs_2024 --year 2024 \
    --category so-low --out salida/2024

# B) Descargar unos indicativos (necesita Internet) y pedir su puntuación FINAL a la API
.venv/bin/python scripts/hist_analyze_logs.py --download --year 2024 --calls EA8AQV EA5JAX \
    --category so-low-any --fetch-final-scores --out salida/2024

# C) Recorrer el índice del año y quedarse con las entidades EA en SOAB LP no asistido
.venv/bin/python scripts/hist_analyze_logs.py --download --from-index --year 2024 \
    --index-entities "Spain,Balearic Islands,Canary Islands,Ceuta & Melilla" \
    --category so-low --delay 1.5 --out salida/2024_ea_lp

# Rookies: añadir  --overlay ROOKIE ; asistido: --category so-low-assisted
```

**Salidas.** Por cada log, en `salida/<INDICATIVO>/`:

| Fichero | Contenido |
|---|---|
| `tasa_por_hora.{png,svg}` + `tasa_por_hora_banda.csv` | QSO por hora UTC, apilados por banda |
| `continentes.{png,svg}` + `continentes.csv`, `continentes_por_banda.csv` | Reparto de los QSO por continente |
| `multiplicadores_acumulados.{png,svg}` + `.csv` | Zonas, países y total a lo largo del concurso |
| `multiplicadores.csv` | Cada multiplicador por banda, con hora e indicativo del primer QSO |
| `qsos_enriquecidos.csv` | Cada QSO con entidad, continente, puntos, duplicados y multiplicadores nuevos |
| `resumen.json` | Resumen del log |

Para el conjunto de logs:

- `salida/resumen_logs.csv`: una fila por log, con categoría, QSO, puntos, multiplicadores y puntuación **bruta** recalculada. Incluye también la declarada (CLAIMED-SCORE), la final de la API si se pidió, las horas de operación (pausas de 60 min o más), la mejor tasa en 60 minutos, el porcentaje por continente y el desglose por banda.
- `salida/estadisticas.json`: mediana y cuartiles por categoría.

**Limitaciones:**

- La puntuación recalculada es bruta: no aplica las penalizaciones de la comprobación. La final solo sale de cqww.com o de la API.
- La entidad se resuelve con el CTY actual, no con el del año del concurso.
- Los QSO con estaciones /MM cuentan solo como zona.

**Prueba realizada.** El script se probó con **logs Cabrillo SINTÉTICOS** (inventados y marcados así en la cabecera) en el *scratchpad* de la sesión, no en `data/`.

- Generador y comprobaciones: `test_hist/test_hist_synth.py`.
  - Resolución CTY de 29 casos difíciles: EA8/…, …/EA8, /P, /QRP, /4, /9, KG4 2×2 frente a 2×3, IT9, IG9, TA1, CR2, F/…, /MM.
  - Filtros de categoría, duplicados, QSO fuera de horario, líneas X-QSO y malformadas, y puntos (EA–EA = 0, EA–EA8 = 3, EA–EA6 = 1).
  - Coherencia: puntos × multiplicadores = puntuación; suma de la tasa por hora = QSO válidos.
- La descarga (por indicativo y por índice) y la consulta a la API se probaron contra un servidor HTTP local con esos mismos logs sintéticos y una respuesta JSON falsa. No se pudo probar contra cqww.com.

### Otros scripts

- `scripts/hist_solar_extract.py`: genera `solar.csv` y el gráfico. Ejemplo: `--source github --years 1999 2000 2022 2023 2024 2025 --forecast 2026 2027 --out data/history/solar.csv --chart data/history/fig_solar_cqww_ssb`. Con `--source auto` prueba primero celestrak.org (datos más recientes).
- `scripts/hist_fetch_scores.py`: descarga listados FINALES de la base de datos de cqww.com (por año, entidad y categoría, u *overlay* ROOKIE) y calcula la mediana y los cuartiles. Se probó solo contra páginas HTML falsas locales; los patrones de URL están POR VERIFICAR.

---

## 7. Desgloses por banda (`band_breakdowns.csv`)

**No se obtuvieron desgloses por banda de 3830 para estaciones EA en 2022–2025 (POR VERIFICAR):** las búsquedas en 3830scores.com y lists.contesting.com no devolvieron ninguna entrada EA de baja potencia de esos años antes de agotarse el cupo.

Como ejemplo histórico, cifras declaradas en la página personal del operador:

- **EA5FWW, 1999**, Single Operator Low Power (la cita no confirma que sea SSB: POR VERIFICAR): 588 QSO, de ellos 10 m 297, 15 m 134, 20 m 146, 40 m 6, 80 m 5 y 160 m 0 [`hist-ea5fww-1999`].
- **EA5FWW, 2000**: 175 QSO, de ellos 10 m 96, 15 m 41, 20 m 38 [`hist-ea5fww-2000`].
- En ambos casos la suma por bandas cuadra con el total.
- Sirven para ilustrar el peso de 10 m cerca del máximo del ciclo 23 (F10.7 ≈160–187 esos fines de semana). No sirven como referencia de puntuación actual.

---

## 8. Lo que no se pudo verificar

1. Ganador mundial SOAB LP de **2022 y 2023** (nombre y puntos).
2. Mejores estaciones **EA, EA6, EA8 y EA9** en SOAB LP, SOA LP y **ROOKIE** de cada año. Solo hay ejemplos sueltos (EA8AQV 2024, EA5JAX 2023, EA4Z 2022).
3. Cifras exactas de PC0A (2025), NP4Z o KP2B (2024) y UW5Y (2024), y la categoría o cifras de EA2W, ED5D y ED1R (2024) y EA5GS (2023).
4. CR2B y EA1BP (2022 y 2023): operador y puntuación.
5. Patrón de URL de los logs públicos individuales y códigos de categoría de la base de datos (`SL ALL`, `AL ALL`, `cat=L`).
6. Informes de propagación de los participantes y boletines ARRL de cada fin de semana.
7. Fecha oficial de 2026 (calculada: 24–25 oct) y de 2027 (calculada: 30–31 oct).
8. Origen exacto de las predicciones mensuales de CelesTrak.

---

## 9. Ficheros generados

- `data/history/facts.md`: este documento.
- `data/history/results_ea.csv`: 18 filas, con tipo (final o claimed), URL y nota de verificación.
- `data/history/solar.csv`: 20 filas (viernes, sábado y domingo de 1999, 2000 y 2022–2025, más las previsiones de octubre de 2026 y 2027).
- `data/history/band_breakdowns.csv`: 12 filas, solo EA5FWW 1999 y 2000.
- `data/history/refs.yml`: 33 referencias Hayagriva (`hist-…`), comprobadas con `typst compile`.
- `data/history/fig_solar_cqww_ssb.png` / `.svg`.
- `scripts/hist_analyze_logs.py`, `scripts/hist_fetch_scores.py` y `scripts/hist_solar_extract.py`.
