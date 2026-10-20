# Verificación de los datos «POR VERIFICAR» de historial, comunidad y entrenamiento

Consulta del 20 de octubre de 2026 para los capítulos 11 (`11-historico.typ`), 12 (`12-entrenamiento.typ`) y 15 (`15-comunidad.typ`), y para `data/history/` y `data/knowledge/`. No se ha modificado ningún fichero existente.

Ficheros de esta carpeta:

| Fichero | Contenido |
|---|---|
| `verificacion.csv` | 27 afirmaciones de la guía: 10 confirmadas, 11 corregidas, 6 sin confirmar |
| `resultados_ea.csv` | 22 filas: estaciones EA, CR2B (operador español en Azores) y ganadores de referencia en baja potencia |
| `calendario.csv` | 14 concursos de nov 2026 a oct 2027: 8 con fecha publicada y 6 solo con regla |
| `clubes.csv` | 10 entradas: URE Madrid, radioclubes de la región y grupos de concurso |
| `refs.yml` | 51 referencias Hayagriva `verh-…`, comprobadas con `typst compile` |

## Cómo se ha verificado

- **Cupo**: se usaron las **40 búsquedas** (WebSearch). Una devolvió error 400 porque el buscador no puede acceder a reddit.com. WebFetch no llega a cqww.com (`ENOTFOUND`).
- **Criterio**: un dato es «confirmado» si aparece en el resumen de un resultado cuya URL es la fuente primaria (cqww.com, el organizador o la web del club).
  - Si el resumen reproduce texto de la fuente, va entre comillas en `cita_literal`.
  - Si solo parafrasea, se marca «[paráfrasis del resumen]».
  - Un resumen puede equivocarse: cuando haya acceso, conviene cotejar las cifras con el PDF.
- **Excepción**: Morse Runner Community Edition se comprobó leyendo directamente su repositorio git público. No consumió búsquedas.

## 1. Mejores estaciones EA, EA6, EA8 y EA9 en baja potencia, y rookies (2022–2025)

**Sigue sin poder darse la mejor estación de cada entidad y año.** El buscador no devuelve los listados de cqww.com filtrados por entidad y categoría, y 3830scores.com no dio ninguna página útil. Solo hay hallazgos sueltos (`resultados_ea.csv`):

- **2025, ED8W (op. EA1BP), Canarias**, en baja potencia. Pie de foto del PDF: «Low Power Operating from the Canary Islands – ED8W (EA1BP op.)». La puntuación no se obtuvo [`verh-cqww-2025-ssb-results`].
- **2024, ED5D (op. Serhiy Rebrov, UT5UDX)**: monooperador asistido, todas las bandas, **11.435.580** puntos. Fue **1.º mundial asistido**, con la placa «World – Assisted ED5D (Opr. Serhiy Rebrov, UT5UDX) Donor: Chick Allen, NW3Y» [`verh-cqww-2024-ssb-results`, `verh-cqww-2024-ssb-plaques`].
- **2024, EA2W (op. Jon Zumalabe)**: asistido, todas las bandas, **11.059.711** puntos.
  - Placa «Europe – Assisted Jon Zumalabe, EA2W*». El asterisco significa «Awarded to second place finisher»: ED5D, primero de Europa, se lleva la placa mundial.
- **2024, EA8RM**: 4.605.340 en una tabla de todas las bandas. La potencia es ambigua en el resumen, así que el dato queda sin confirmar.
- **2023, EA1FRY**: SO LOW ALL, **48.918** puntos. Fila citada: «2444 · EA1FRY · EA · 2023 · SO LOW ALL · 48,918» [`verh-cqww-scores-ea-s-p25`]. No consta que sea la mejor EA.
- **2022, EA5DFV**: 2.543.590 en la sección monooperador de los line scores, con la potencia no visible [`verh-cqww-2022-ssb-line-scores`].
- **EA6 y EA9**: no apareció ninguna fila.
- **Rookies EA en SSB**: no encontrados. El listado EA de rookies que indexa el buscador es de **CW** (`mode=cw`), así que no sirve. Lo que sí consta en cqww.com es que el **EA Contest Club patrocina la placa europea Rookie SSB** [`verh-cqww-plaques`].

Sigue haciendo falta ejecutar `scripts/hist_fetch_scores.py` con acceso a internet.

## 2. Comprobaciones concretas

| Dato de la guía | Resultado | Fuente |
|---|---|---|
| PC0A 2025 SOAB LP «≈ 2,8 M» | **Confirmado: 2.834.758** (2.º mundial). Cita: «PC0A .................. 2,834,758». Declarados antes de la comprobación: 2.935.471 | [`verh-cqww-2025-ssb-results`], [`verh-cqww-raw-ssb`] |
| N1UR 2025 «≈ 4,9 M (≈ 5,2 M declarada)» | **Confirmado: 4.985.102** final (récord de la zona 5). Declarados: 5.199.480 | [`verh-cqww-records-zone`], [`verh-cqww-raw-ssb`] |
| UW5Y (US2YW) 2024 SOAB LP «≈ 3,9 M» | **Confirmado: 3.894.098** y placa Europa LP. Cita: «UW5Y (US2YW) .......... 3,894,098» | [`verh-cqww-2024-ssb-results`], [`verh-cqww-2024-ssb-plaques`] |
| EA4Z 2022, 47.100, categoría exacta | **Categoría sin confirmar.** Datos nuevos: 224 QSO, 41 zonas, 116 países (300 × 157 = 47.100), fila con asterisco | [`verh-cqww-2022-ssb-line-scores`] |
| CR2B (EA1BP), 1.º de Europa LP en 2022 | **Confirmado** por la placa: «CR2B (Opr.: Miguel Angel Devora Jimenez, EA1BP)», donante K3LR | [`verh-cqww-2022-ssb-results`] |
| CR2B, puntuación de 2022 | Line scores: «CR2B A 2,178,800 2636 95 324 (OP: EA1BP)» (5.200 × 419). El encabezado de potencia no se ve en el resumen | [`verh-cqww-2022-ssb-line-scores`] |
| CR2B 2023, 2.572.485 | **Confirmado.** Quedó justo detrás de LY4L (2.685.798), que se llevó la placa Europa LP: 2.º de Europa (deducción) | [`verh-cqww-2023-ssb-results`], [`verh-cqww-2023-ssb-plaques`] |
| ED1R, ED5D y EA2W 2024 «alta potencia / multi ≈ 11–12 M» | **Corregido**: ED5D y EA2W son monooperador asistido (ver § 1); ninguno es multi. **ED1R** no aparece en los resúmenes de 2024: sin confirmar | [`verh-cqww-2024-ssb-plaques`] |

Datos nuevos que rellenan huecos de `data/history/facts.md` § 2:

- **2022**: el ganador mundial de baja potencia fue **WP3C (Alfredo)**, con ≈ 4,5 M. El artículo lo describe como «4.5M world-high» (paráfrasis del resumen) [`verh-cqww-2022-ssb-results`].
- **2023, placa «World – Low Power»**: **PZ5CO (op. Dimitri Kryukov, RA3CO)**. Su puntuación en SSB no se obtuvo.
- **2023, placa «Europe – Low Power»**: **LY4L (Mindaugas Jukna)**, con 2.685.798 puntos [`verh-cqww-2023-ssb-plaques`].

## 3. Clubes del CQ WW 2025

- **Confirmado.** El **EA Contest Club** fue **3.º entre los clubes DX** en 2025, con **162 logs** y **242.380.834 puntos**, por detrás del Bavarian Contest Club y del Italian Contest Club (paráfrasis del resumen de la página de clubes) [`verh-cqww-clubscores-2025`].
  - El resumen no indica si la cifra suma SSB y CW.
- En el CQ 160 de 2025 el mismo club fue 10.º, con 15 logs y 2.779.821 puntos [`verh-cq160-clubscores-2025`].

## 4. Radioclubes de Madrid y grupos de concurso

La guía dice que no pudo verificar ningún radioclub de Madrid; ahora hay varios (`clubes.csv`):

- **URE, Sección Local Madrid**: tiene página en el foro de ure.es y el contacto seccion.madrid@ure.es [`verh-ure-seccion-madrid`].
  - Según una página de hace unos siete años, repartía las QSL en su local (Avenida Monte Igueldo 102) los días laborables, y anunciaba un local nuevo. Hay que comprobarlo antes de ir.
- **Organización de URE**: un Consejo Territorial por comunidad autónoma (Las Palmas y Santa Cruz de Tenerife son provinciales), con secciones locales, comarcales o provinciales [`verh-ure-que-es`].
  - El resumen da como presidente del Consejo de Madrid a Joaquín Robles Megías, EA4HF, sin precisar en qué página de ure.es aparece.
  - Hay revista en PDF (número de junio de 2026) [`verh-ure-revista-2026-06`].
- **Nombre de URE**: la web usa «**Unión de Radioaficionados Españoles**», no «de España» como dice el capítulo 15.
- **Radio Club EIT (ETSIT-UPM), EA4RCT**: colabora con la Sección URE Madrid en el repetidor R2. Listado de repetidores: «ED4YAC · 145.650 MHz -600 kHz FM (RV52 - R2) - IN80DK - Sección URE Madrid / Colaboradores Radio Club EIT EA4RCT» [`verh-ure-repetidores`]. Web no encontrada.
- **Grupo Canal 21 Sierra de Madrid, EA4RKR** (Las Rozas): socio de FEDI-EA desde 1989, sin web en el listado [`verh-fediea-asociaciones`].
- **Radio Club Henares, EA4RCH**: web activa en https://www.radioclubhenares.org/ (diploma DVGE, actividad EH4WRD, archivo histórico EA4DO) [`verh-radioclubhenares`]. **La localidad no aparece en los resúmenes.**
- **ARAC (Alcobendas)**: solo se menciona en una página personal [`verh-ea4azj`]. Sin confirmar.
- **Grupos de concurso**:
  - **EA Contest Club**: existe y compite (§ 3), pero su web no apareció.
  - **Ceuta Contest Club (EA9EA)**: https://www.qsl.net/ea9ea/indice.htm. Su objetivo declarado es participar en los grandes concursos, sobre todo el CQ WW SSB y CW [`verh-ceuta-contest-club`].
  - **Equipo EA2CK / ED2JJ**: siete operadores, concursos de HF y DX [`verh-ea2ck-team`].

## 5. Reflector CQ-Contest y r/amateurradio

- **CQ-Contest, confirmado**: sigue en contesting.com con Mailman, en **https://lists.contesting.com/mailman/listinfo/cq-contest**. El alta se confirma por correo y el archivo tiene mensajes de marzo de 2026 [`verh-cq-contest-listinfo`, `verh-cq-contest-archive-2026-03`].
  - No apareció ninguna migración a groups.io.
  - El índice de listas indica que la lista «3830» de contesting.com está inactiva desde el 31-12-2023 [`verh-contesting-lists`]. La web 3830scores.com es otra cosa.
- **r/amateurradio, sin confirmar**: el buscador no puede acceder a reddit.com. La dirección habitual, de memoria, es https://www.reddit.com/r/amateurradio/.

## 6. Calendario de noviembre de 2026 a octubre de 2027

| Concurso | Fechas (UTC) | Tipo | Fuente |
|---|---|---|---|
| ARRL 10 m 2026 | 12-dic 0000Z – 13-dic 2359Z | publicada | [`verh-arrl-contest-calendar`] |
| HA DX 2027 | 16-ene 1200Z – 17-ene 1200Z | regla: 3.er fin de semana completo de enero | [`verh-hadx-rules`] |
| UBA DX SSB 2027 | 30-ene 1300Z – 31-ene 1300Z | publicada (calendario UBA) | [`verh-uba-calendar`] |
| EU DX 2027 | 6-feb 1200Z – 7-feb 1200Z | regla: 1.er fin de semana completo de febrero | [`verh-eudx-rules`] |
| PACC 2027 | 13-feb 1200Z – 14-feb 1200Z | publicada: «2027: Februari 13 -14 (CW/SSB)» | [`verh-veron-pacc`] |
| CQ 160 SSB 2027 | 26-feb 2200Z – 28-feb 2200Z | publicada | [`verh-cq160-home`] |
| REF SSB 2027 | 27-feb 0600Z – 28-feb 1800Z | regla: «SSB: Last full weekend in February» | [`verh-ref-rules`] |
| ARRL DX SSB 2027 | 6-mar 0000Z – 7-mar 2359Z | publicada: «2027: 0000Z, Mar 6 - 2359Z, Mar 7» | [`verh-arrl-dxph`] |
| RDXC 2027 | 20-mar 1200Z – 21-mar 1159Z | publicada | [`verh-rdxc-rules`] |
| CQ WPX SSB 2027 | 27-mar 0000Z – 28-mar 2359Z | publicada | [`verh-cqwpx-home`] |
| S.M. El Rey SSB 2027 | 26-jun 1200Z – 27-jun 1159Z | regla: 4.º fin de semana completo de junio | [`verh-ure-rey-ssb-bases`] |
| IARU HF 2027 | 10-jul 1200Z – 11-jul 1159Z | publicada (calendario ARRL) | [`verh-arrl-contest-calendar`] |
| All Asian SSB 2027 | 4-sep 0000Z – 5-sep 2359Z | regla: primer sábado de septiembre, 48 h | [`verh-jarl-aa-rules`] |
| WAE SSB 2027 | 11-sep 0000Z – 12-sep 2359Z | regla: 2.º fin de semana de septiembre | [`verh-darc-wae-rules`] |

- **Fechas de 2027 «por regla»**: se calcularon con la regla del organizador. Cada regla reproduce las fechas publicadas de 2026: El Rey 27–28 jun, WAE 12–13 sep, HA DX 17–18 ene, EU DX 7–8 feb y All Asian 5–6 sep.
- **Correcciones a `data/knowledge/contests_calendar.csv`**:
  - **S.M. El Rey SSB 2027**: la fecha queda en 26–27 de junio. Bases: «4rd full weekend of June, from 1200 UTC Saturday till 1159 UTC Sunday».
  - **IARU HF**: termina a las **1159Z**, no a las 1200Z.
  - **EU DX**: termina a las **1200Z** del domingo, no a las 1159Z.
- Las demás fechas calculadas coinciden con las publicadas o con la regla.
- **Avisos**:
  - La web del WPX da para 2028–2029 unas fechas SSB en mayo que parecen copiadas de las de CW.
  - La portada de rdxc.org pone el final a las 12:00 y sus bases, a las 11:59.
  - Las versiones inglesa y alemana de las bases del HA DX difieren en un minuto (12:00 / 11:59).

## 7. Entrenamiento

- **Morse Runner Community Edition, confirmado y activo**: repositorio https://github.com/w7sst/MorseRunner, leído directamente [`verh-mrce-github`].
  - Última etiqueta: **v1.86**. Corresponde al commit del **25-sep-2026** «Roll version number for final 1.86 build», que es también la cabeza de `main`.
  - Es **solo CW**. Simula CQ WW, CQ WPX, ARRL DX, IARU HF, ARRL Field Day y Sweepstakes, NAQP, CWT, SST, HST y dos concursos JARL.
  - Grupo de usuarios: groups.io/g/MorseRunnerCE.
- **RufzXP, sin confirmar**: solo hay fuentes secundarias [`verh-rufzxp-k0pir`, `verh-rufzxp-crossover`].
  - Un blog lo describe como freeware para Windows 98–8.1, «no contest simulator». CrossOver cita una versión 1.1.2.
  - La autoría aparece como DL8MM o DL4MM según la fuente.
  - No se encontró la web oficial.
- **Simulador de pileups de SSB**: no se encontró ninguno. La búsqueda solo devolvió apps de CW (RST 599xp, CW Runner QT). La frase de la guía puede mantenerse.
- **Contest University, confirmado**: https://www.contestuniversity.com/.
  - La CTU 2026 se celebró el **14-may-2026** en el Hope Hotel de Wright-Patterson AFB (Ohio).
  - Vídeos en `/videos/`, con enlace al directo de YouTube; transparencias de 2026 en `/files/` [`verh-ctu-videos`, `verh-ctu-files`].
- **WWROF, confirmado**: https://wwrof.org/, con blog en `/wwrof-blog/` y archivo de webinarios en `/webinar-archive/…` [`verh-wwrof-blog`, `verh-wwrof-webinar-k9la`].
  - No se encontró un listado de webinarios de 2026.

## 8. Sigue sin confirmar

1. Mejor estación EA, EA6, EA8 y EA9 en SOAB LP y SOA LP de cada año, y rookies EA en SSB.
2. Categoría exacta de EA4Z (2022).
3. ED1R en 2024.
4. Puntuación de ED8W (2025) y categoría de EA8RM (2024) y EA5DFV (2022).
5. Dirección actual de r/amateurradio.
6. Web del EA Contest Club, localidad de Radio Club Henares, web de EA4RCT y de ARAC.
7. Estado y web oficial de RufzXP.
8. Si la puntuación de clubes del CQ WW 2025 suma SSB y CW.

## 9. Cambios propuestos para la guía (no aplicados)

**Capítulo 11, tabla de referencia:**
- PC0A: 2.834.758.
- UW5Y: 3.894.098.
- N1UR: 4.985.102 (declarada 5.199.480).

**Capítulo 11, tabla EA:**
- EA4Z: añadir 224 QSO y 41/116; mantener la categoría marcada #pv.
- CR2B: 1.º de Europa LP en 2022 con 2.178.800 (2.636 QSO, 95/324), y 2.572.485 en 2023 (2.º de Europa).
- Sustituir la fila «ED1R, ED5D, EA2W» por:
  - ED5D (UT5UDX), SOA, 11.435.580, 1.º mundial asistido.
  - EA2W, SOA, 11.059.711, placa Europa asistido.
  - ED1R: retirarlo de la fila o dejarlo marcado #pv.

**Capítulo 15:**
- Escribir «Unión de Radioaficionados Españoles».
- Quitar el #pv del EA Contest Club y añadir 162 logs y 242,4 M.
- Citar URE Sección Local Madrid, EA4RCT y EA4RKR, y Radio Club Henares con su localidad #pv.
- Reflector: https://lists.contesting.com/mailman/listinfo/cq-contest. r/amateurradio sigue #pv.

**Capítulo 12:**
- Morse Runner CE: v1.86, del 25-sep-2026.
- Mantener el #pv solo para RufzXP.
- Contest University: https://www.contestuniversity.com/. WWROF: https://wwrof.org/.
- Leyenda del calendario: distinguir publicada y regla según `calendario.csv`, y corregir El Rey, IARU HF y EU DX.
