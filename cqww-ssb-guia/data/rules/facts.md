# Bases del CQ World-Wide DX Contest (edición 2026): hechos verificados

Tema: bases oficiales 2026, FAQ, envío del log y formato Cabrillo.
Contexto del lector: operador novel en Madrid (IN80, zona CQ 14, zona ITU 37,
indicativo de ejemplo **EA4XXX**). Plan: escuchar el CQ WW SSB del 24–25 oct 2026
y operar el CQ WW SSB 2027 como Single-Op, Low Power (≤100 W), All Band,
con overlay ROOKIE.

Fecha de la investigación: **2026-10-20**. Claves bibliográficas en
`data/rules/refs.yml` (prefijo `rules-`).

## Cómo se verificó (leer primero)

El contenedor **no puede abrir** cqww.com ni wwrof.org (DNS bloqueado). Todo el
contenido de esas webs se comprobó **indirectamente** con WebSearch (búsqueda en
servidor), que devuelve resúmenes y fragmentos citados de las páginas, PDF
incluidos. El presupuesto de búsquedas se agotó al final de la sesión, así que
algunos puntos quedaron sin cita literal. Los resúmenes pueden contener
paráfrasis o errores, así que **antes de publicar conviene un repaso humano
contra el PDF** (`rules-cqww-2026`).

Leyenda de cada dato:

- **[L]**: cita literal en inglés devuelta por WebSearch desde la fuente indicada.
- **[R]**: confirmado por el resumen de WebSearch, pero en paráfrasis. El sentido
  está verificado; la redacción exacta, no.
- **[C]**: calculado o comprobado con un script de este repositorio.
- **[S]**: contrastado con una fuente secundaria de código abierto (PyPI o
  raw.githubusercontent.com) descargada y leída en esta sesión.
- **POR VERIFICAR**: sin confirmar en fuente primaria. Se dice qué se encontró.

## Documentos y versiones

| Documento | Versión / fecha | URL | Clave |
|---|---|---|---|
| Bases 2026 (PDF) | "2026 CQ WW DX Contest Rules - 1 - September 5, 2026" → **5-sep-2026** [L, título del PDF en WebSearch] | https://cqww.com/rules/2026_rules_cqww.pdf | `rules-cqww-2026` |
| Página HTML de bases | Encabezado 2026; según varios resúmenes es una copia **anterior o abreviada**: omite *QRP Assisted* y trunca la lista de conducta antideportiva [R]. **Si discrepan, manda el PDF.** | https://cqww.com/rules/ | `rules-cqww-rules-page` |
| Entrada «2026 Rule Changes» | Hacia el **7-oct-2026** (un resumen dice "October 7, 2026"; otro, "13 days ago") [R] | https://cqww.com/blog/2026-rule-changes/ | `rules-cqww-2026-changes` |
| Bases 2025 (PDF), para comparar | 9-sep-2025 [L, título] | https://cqww.com/rules/2025_rules_cqww.pdf | `rules-cqww-2025` |
| FAQ de las bases | Sin fecha; algunas respuestas son anteriores a 2026 (ver §8 y §10) | https://cqww.com/rules_faq.htm | `rules-cqww-faq` |
| Instrucciones Cabrillo CQ WW | Sin fecha | https://cqww.com/cabrillo.htm | `rules-cqww-cabrillo` |
| Subida del log | "CQ WW - Cabrillo Log Upload" | https://cqww.com/logcheck/ | `rules-cqww-logcheck` |
| Especificación Cabrillo v3 (WWROF) | **No leída directamente**; valores contrastados con [S] | https://wwrof.org/cabrillo/ | `rules-wwrof-cabrillo` |

Notas:

- La URL antigua https://cqww.com/rules.htm devolvió en un resumen las fechas de
  2025 [R]. Hay que usar `/rules/` o el PDF.
- Existen traducciones oficiales (FR, DE, NL, PT, NO, ID…) en
  `cqww.com/rules/rules_xx_AAAA.pdf` [R]. **POR VERIFICAR**: si hay traducción
  al español de las bases 2026 (no apareció en los resultados).

## Correcciones y matices a lo que se daba por supuesto

| Afirmación inicial | Resultado |
|---|---|
| SSB 24 oct 00:00 – 25 oct 23:59:59 UTC; CW 28–29 nov 2026 | **Correcto** [L][C] |
| Plazo del log 48 h → 27 oct 2026 23:59 UTC | **Correcto.** Es **nuevo en 2026**: antes eran 5 días [L] |
| Región 1: «no SSB por encima de 7200 kHz, nada por debajo de 1810 kHz» | **Correcto en esencia.** La regla prohíbe **transmitir** en 40 m por encima de 7200 kHz durante el concurso **SSB**, y transmitir por debajo de 1810 kHz **durante el concurso** (ambos fines de semana) [R]. Ver §2 |
| Mismo continente: 1 punto; caso especial en Norteamérica | **Confirmado:** 2 puntos entre países distintos dentro de Norteamérica [L]. Nunca afecta a EA |
| Categorías multi «single / two / multi-transmitter» | En 2026 se llaman **Multi-Single, Multi-Two, Multi-Multi y Multi-Distributed** [R] |
| ¿Existe la categoría Explorer? | **No.** Se eliminó en 2025 y la sustituye Multi-op Distributed [L] |
| Overlays | En 2026 son **CLASSIC, ROOKIE y YOUTH** [R]. TB-WIRES existe en la especificación Cabrillo, pero no es un overlay del CQ WW |
| Rookie: «3 años o menos» | La regla dice **"less than three (3) years before the date of the contest"** [L] |
| Bust/NIL: ¿se quita el QSO y se penaliza 2×? | **Sí, 2×** según las bases 2026 [L]. La FAQ todavía dice 3× (desactualizada) |
| Término «assistance» | En 2026 es **"QSO finding assistance"** (antes "QSO alerting assistance") [R] |
| (no se mencionaba) | **Novedades 2026:** prohibición de la operación robótica autónoma ("a human operator must always initiate…") [L]. La grabación de audio es obligatoria para quien compita por el top 5 [L] |
| (no se mencionaba) | El intercambio usa la zona de la **"transmitter location"** (2026); en 2025 decía "station location" [L] |

---

## 1. Fechas y horarios

- **2026:** SSB del **24 al 25 de octubre**; CW del **28 al 29 de noviembre**.
  Portada de cqww.com: "CQ WW Contest Dates SSB: October 24 - 25, 2026 CW:
  November 28 - 29, 2026" [L, `rules-cqww-home`].
- **Horario** (bases 2026): "Starts 00:00:00 UTC Saturday Ends 23:59:59 UTC Sunday"
  [L, `rules-cqww-2026`]. Son 48 horas. La portada usa la notación "0000"/"2359" [R].
- **Regla que fija el fin de semana** (portada): "SSB is always the last full
  weekend of October." / "CW is always the last full weekend of November."
  [L, `rules-cqww-home`].
  - «Último fin de semana completo» = el último sábado del mes cuyo domingo
    también cae en ese mes. En 2026, el 31 de octubre es sábado pero el 1 de
    noviembre ya no es octubre, así que el fin de semana es el 24–25 [C].
- **Fechas futuras publicadas** (portada): "2027: October 30 - 31 2028: October
  28 - 29 2029: October 27 - 28" y CW "2027: November 27 - 28 2028: November
  25 - 26 2029: November 24 - 25" [L, `rules-cqww-home`].
- **Cálculo** con `scripts/rules_fechas.py` [C]. La fórmula reproduce **todas**
  las fechas publicadas que se encontraron: 1999, 2019 y 2022–2029 (títulos de
  los PDF y la portada). Resultado en `data/rules/dates.json`:

| Año | SSB (UTC) | Plazo log SSB | CW (UTC) | Plazo log CW |
|---|---|---|---|---|
| 2026 | 24 oct 00:00:00 – 25 oct 23:59:59 | 27 oct 23:59 (publicado) | 28 nov – 29 nov | 1 dic 23:59 (publicado) |
| 2027 | 30 oct – 31 oct | 2 nov 23:59 (**proyección**) | 27 nov – 28 nov | 30 nov 23:59 (**proyección**) |
| 2028 | 28 oct – 29 oct | 31 oct 23:59 (**proyección**) | 25 nov – 26 nov | 28 nov 23:59 (**proyección**) |

- Los plazos de 2027 y 2028 aplican la regla de 48 h de 2026. **POR VERIFICAR**
  cuando salgan las bases de cada año (las de 2025 y 2026 se fecharon en septiembre).
- **Hora de Madrid** [C, con zoneinfo `Europe/Madrid`]:
  - 2026: empieza el sábado 24 a las **02:00 CEST** y acaba el **lunes 26 a las
    00:59:59 CET**. El plazo del log vence el miércoles 28 a las 00:59 CET.
  - **El fin de semana SSB siempre incluye el cambio de hora europeo**: su domingo
    es siempre el último domingo de octubre (comprobado de 1990 a 2100) [C].
    En 2026 ocurre el domingo 25 a las 01:00 UTC (las 03:00 CEST pasan a ser
    las 02:00 CET). El log va siempre en UTC, así que no afecta a las horas
    registradas. Esto supone que la UE mantiene el régimen actual de cambio de hora.

## 2. Objetivo, bandas y restricciones de la Región 1

- **Objetivo** (sección I). El texto empieza "For amateurs around the world to
  contact as many other…" [L, título del PDF 2017 en WebSearch]. El resumen de
  2026 lo describe como contactar con el mayor número posible de radioaficionados
  en el mayor número posible de zonas CQ y países [R]. **POR VERIFICAR** la frase
  literal completa de 2026, que se espera que sea "…amateurs in as many CQ zones
  and countries as possible".
- **Bandas** (sección II): "Six bands only: 1.8, 3.5, 7, 14, 21 and 28 MHz.
  Observance of established band plans is strongly encouraged." [L,
  `rules-cqww-2026`].
  - No hay bandas WARC (30/17/12 m) ni 6 m.
  - El plan de bandas (IARU R1) es una **recomendación** de las bases, no una
    obligación. Lo obligatorio son los límites de la licencia: transmitir fuera
    de ellos es conducta antideportiva (§8) [L].
- **Restricciones para la Región 1 de la UIT** (EA está en la Región 1):
  - "For ITU Region 1 stations, transmitting on the 40m band, above 7200 kHz
    during the SSB (phone) contest is not permitted." [L según el resumen, que
    atribuye la frase a las bases 2026; la misma frase aparece en 2017, 2019,
    2022 y 2025].
  - "…transmitting below 1810 kHz during the contest is not permitted." [L
    parcial, bases 2026]. Antes decía "during the contest weekends" [R].
  - Se introdujeron en 2017 "to remove the option for debate by defining two
    important frequency limits as part of the rules" [L, `rules-cqww-2017-announce`].
  - **POR VERIFICAR**: el número exacto de cada apartado. Un resumen sitúa la de
    40 m como regla 10 de las reglas generales (sección IX).
  - **Matiz práctico** (inferencia de la redacción): se prohíbe *transmitir*.
    Escuchar por encima de 7200 kHz no lo está, así que el *split* con estaciones
    de la Región 2 que transmiten en 7200–7300 kHz es compatible si EA4XXX
    transmite por debajo de 7200 kHz.
  - Nota técnica (no es texto de las bases): en LSB la emisión queda por debajo
    de la frecuencia de la portadora suprimida. Lo prudente es que toda la emisión
    quede por debajo de 7200 kHz.
  - Las atribuciones nacionales españolas (CNAF) no forman parte de este tema:
    **POR VERIFICAR** con el responsable de planes de banda.

## 3. Intercambio

- "SSB: RS report plus CQ Zone number of the transmitter location (e.g., 59 05).
  CW: RST report plus CQ Zone number of the transmitter location (e.g., 599 05)."
  [L, `rules-cqww-2026`].
- Las bases 2025 decían "station location" en lugar de "transmitter location"
  [L, `rules-cqww-rules-page`/2025]. Las ediciones antiguas escribían "5905" sin
  espacio [R].
- Para EA4XXX en Madrid: **"59 14"** (España = zona CQ 14 en
  `data/cty/cty_tlf.dat`) [C].
- Lo que envían otras estaciones españolas: EA6 (Baleares) 14, EA8 (Canarias) 33
  y EA9 (Ceuta y Melilla) 33 [C, mismo fichero cty].

## 4. Puntos por QSO

- Texto 2026 [L, `rules-cqww-2026` y `rules-cqww-rules-page`]:
  - "Contacts between stations on different continents count three (3) points."
  - "Contacts between stations on the same continent but in different countries
    count one (1) point. Exception: Contacts between stations in different
    countries within the North American boundaries count two (2) points."
  - "Contacts between stations in the same country have zero (0) QSO point value,
    but count for zone and country multiplier credit."
- **"Stations may be contacted once on each band"** (sección IV.B) [R].
- La excepción de Norteamérica existe desde hace años; aparece ya en las bases de
  2000 y 2017 [R].
- **Aplicado a EA4XXX** (EU, España) [C, cty del proyecto]:

| Corresponsal | Entidad / continente | Puntos |
|---|---|---|
| Otro EA peninsular (EA1…EA7) | España / EU | **0**, pero zona y país cuentan como multiplicador |
| EA6 | Baleares / EU (entidad DXCC distinta) | 1 |
| EA8, EA9 | Canarias, Ceuta y Melilla / **AF** | **3** |
| DL, F, I… | otro país / EU | 1 |
| K, VE, JA, PY… | otro continente | 3 |

- La excepción NA (2 puntos) **nunca** se aplica a EA4XXX.
- Aviso para el resto del proyecto: `scripts/ctylib.py::qso_points` no implementa
  la excepción norteamericana. Para un EA da igual, pero el código está incompleto
  respecto a la regla. No se ha tocado (es de otro módulo).

## 5. Multiplicadores y puntuación final

- **Zonas** [R, `rules-cqww-2026`]: un multiplicador por cada zona CQ distinta
  trabajada **en cada banda**; el estándar son las reglas del diploma *CQ Worked
  All Zones*.
  - Hay **40 zonas CQ** (WAZ; dato general, véase https://cqww.com/cq_waz_list.htm).
  - **POR VERIFICAR**: la redacción literal de 2026.
- **Países** [R]: un multiplicador por cada país distinto trabajado en cada banda.
  Lo definen "The DXCC entity list, Worked All Europe (WAE) multiplier list plus
  IG9/IH9, and continental boundaries".
- "Maritime mobile stations count only for a zone multiplier." [L].
- **Puntuación** [L]: "The final score is the result of the total QSO points
  multiplied by the sum of zone and country multipliers."
  - Ejemplo de las bases: 1000 puntos × (30 zonas + 70 países) = 100 000 [R; la
    tipografía exacta del ejemplo está **POR VERIFICAR**].
- La lista de entidades (DXCC + WAE + IG9/IH9) la resuelve el fichero cty
  (`data/cty/`), que es de otro tema.

## 6. Categorías

Fuente principal: `rules-cqww-2026`, sección V ("see V.A." aparece en la regla de
audio) [R].

### 6.1 Single Operator (definición común)

- "One person (the operator) performs all operating and logging functions. There
  is no limit on operating time or band changes. Only one transmitted signal is
  permitted at any time." [L].
- **Single Operator (no asistido)**: "QSO finding assistance of any kind is
  prohibited." [L].
  - Todas las bandas o monobanda.
  - "High Power (All Band or Single Band): Total output power must not exceed
    1500 watts." [L].
  - Low Power: 100 W; QRP: 5 W [L en la misma estructura].
- **Single Operator Assisted**: "Entrants in this category may use QSO finding
  assistance." [L].
  - HP 1500 W, LP 100 W y QRP 5 W. *QRP Assisted* figura en el PDF; la página
    HTML lo omite [R].
- **Definición de asistencia** [R, `rules-cqww-2026`]: "QSO finding assistance" es
  "the use of any technology or other source that provides call sign or
  multiplier identification of a signal to the operator". Ejemplos de las bases:
  - decodificador de CW;
  - DX cluster y webs de *spotting*;
  - tecnologías locales o remotas de decodificación de indicativos (p. ej. CW
    Skimmer o Reverse Beacon Network);
  - acuerdos de operación con otras personas.
- **FAQ** [L, `rules-cqww-faq`]:
  - "You are Single Operator IF you (and only you) locate AND identify every
    callsign that you put in your log. Locate means to tune in each signal.
    Identify means to determine the callsign of the station you are working."
  - "Do not use any outside tools such as the DX Cluster or RBN network to locate
    new contacts."
  - Sobre la cascada o el *band scope*: "No, provided there is no callsign and/or
    exchange information made available when used."
  - "Any single operator that uses a code reader must enter the Assisted category."
    (cambio de 2015).
  - Un software que decodifica e indica dónde transmiten indicativos cuenta como
    asistencia. Una pantalla alimentada por RBN sigue siendo asistencia aunque no
    muestre indicativos [R].
- **Para un LP no asistido en SSB**: nada de cluster, RBN ni ninguna aplicación
  que muestre indicativos. El panorámico o la cascada sin indicativos sí se
  permiten. **POR VERIFICAR**: no se encontró mención expresa a decodificadores de
  voz a texto, pero entrarían en la definición general ("any technology … that
  provides call sign … identification").

### 6.2 Overlays de Single Operator

Solo se admite **un** overlay por log [R].

- **CLASSIC** [R]: una sola radio, sin asistencia, máximo **24 de las 48 horas**,
  con descansos de al menos 60 minutos sin QSO. *Single Operator Assisted* no
  puede entrar.
  - FAQ: es el único caso con límite de tiempo, y ese límite afecta al cálculo de
    la puntuación [R].
  - **POR VERIFICAR**: cómo se cuentan las 24 horas.
- **ROOKIE** [L, `rules-cqww-2026`]:
  - Operador "first licensed as a radio amateur less than three (3) years before
    the date of the contest".
  - "Entrants must indicate the date first licensed in the SOAPBOX field."
  - "Previous Rookie winners are not eligible for plaques in this category."
  - FAQ [L/R]: el periodo cuenta desde la **primera** licencia de operador ("The
    3 year period applies from the time you obtained your first amateur radio
    license"). Si una licencia antigua caducó y se ha vuelto a obtener, **no** se
    es Rookie. En países que permiten operar en estaciones de club sin licencia
    completa, "the 3 year period begins when you obtained permission to get on
    the air".
  - Para el CQ WW SSB 2027 (30 oct 2027), la primera licencia tendría que ser
    posterior al **30 oct 2024** [C, por la regla "less than three years"].
    **POR VERIFICAR**: cómo trata el comité el día exacto del tercer aniversario.
- **YOUTH** [R]: 25 años o menos al empezar el concurso; el año de nacimiento se
  indica en SOAPBOX. Creado en 2021. **POR VERIFICAR**: la redacción literal.
- Cómo se clasifican [L]: "scored as All Bands; and grouped by High Power and Low
  Power (includes QRP)". Límites del overlay: HP 1500 W, LP 100 W [R].
- Cabrillo [L, `rules-cqww-rules-page`/`rules-cqww-cabrillo`]: "For ROOKIE, enter:
  CATEGORY-OVERLAY: ROOKIE".
  - Si aparecen varios overlays, "the last one found in the log will be used" [L].
  - FAQ: si se cumplen Rookie y Youth, elegir uno es responsabilidad del
    concursante [R].
- **Ya no existen o no son del CQ WW**:
  - **Explorer**: "The Explorer category has been eliminated and replaced with the
    Multi-op Distributed category, with the same rules as the CQ WPX contest." [L,
    `rules-cqww-2025-changes`]. La página `explorer.htm` ("Explorer Category Rules
    2024") es histórica.
  - **Xtreme**: la página `rules/rules_xtreme.htm` sigue publicada, pero no
    apareció entre las categorías 2026. **POR VERIFICAR**; se supone histórica.
  - **TB-WIRES**: valor válido de la especificación Cabrillo [S], pero no es
    overlay del CQ WW 2026.

### 6.3 Multi-Operator

En multioperador se permite la asistencia [R].

- **Multi-Single** (HP 1500 W / LP 100 W "on any band at any time") [L]:
  - "Only one transmitted signal on one band permitted during any 10-minute period
    (run station/signal). Exception: One — and only one — other transmitted
    signal (multiplier station/signal) may be used during any 10-minute period…",
    siempre en otra banda y solo para trabajar un multiplicador nuevo.
  - "The MULTIPLIER SIGNAL may not request or attract any QSO by calling CQ, QRZ,
    TEST, etc."
  - En Cabrillo, el *run* lleva "0" y el multiplicador "1" en la columna de
    transmisor.
  - FAQ: el reloj de 10 minutos empieza con un QSO en la banda nueva; los QSO que
    incumplen la regla "will be removed without penalty" [L].
- **Multi-Two** [L]: "A maximum of two transmitted signals may be used at any
  time, and they must be on two different bands." "Each station/signal may make a
  maximum of 8 band changes in any clock hour." Máximo 1500 W.
- **Multi-Multi** [R]: las seis bandas a la vez, "Only one transmitted signal per
  band is permitted at any time". Máximo 1500 W.
- **Multi-Distributed** [L]: "A maximum of six transmitted signals, one per band
  at any one time, from stations in different locations. All equipment
  (transmitters, receivers, amplifiers, antennas, etc.) must be in the same DXCC
  entity and CQ Zone, including remotely controlled equipment."
  - Cabrillo: "CATEGORY-OPERATOR: MULTI-OP" + "CATEGORY-STATION: DISTRIBUTED".
  - 1500 W por señal [R].

### 6.4 Checklog

- Log enviado solo para ayudar a la verificación: "The entry will not have a
  score in the results, and the log will not be made public" [L/R].
- No cuenta para clubes.
- "A log without all required information may be reclassified to Checklog." [L].
- Cabrillo: `CATEGORY-OPERATOR: CHECKLOG` [S].

### 6.5 Reglas generales que afectan a un Single-Op

Sección IX según los resúmenes [R]; la numeración está **POR VERIFICAR**.

- IX.1: "Entrants must operate within the limits of their chosen category when
  performing any activity that could impact their submitted score." [L].
- Indicativo: "A different call sign must be used for each entry. Only the
  entrant's call sign may be used to aid the entrant's score." [L].
  - "The call sign used must be one issued or permitted by the Regulatory
    Authority of the station location." [L].
  - La frase "use of only one call sign" **no** aparece [R].
- Potencia: "Total output power on any band at any time is measured at the
  output of the active amplifier(s)." [L].
- IX.4: "Self-spotting or asking to be spotted is not permitted." [L].
  - En el SSB 2025 hubo descalificaciones por *self-spotting* [R,
    `rules-cqww-results-2025-ssb`].
- **Ubicación de la estación** [L/R]: todos los transmisores, receptores y
  amplificadores dentro de **un círculo de 500 m de diámetro**. "Antennas must be
  physically connected by RF transmission lines to the transmitters and
  receivers." [L].
- **Operación remota** [L]: "Remote operation is permitted if the physical
  location of all transmitters, receivers, and antennas are at one station
  location. A remotely operated station must obey all station license, operator
  license, and category limitations." "Remote receivers outside of the station
  location are not permitted."
- Dos transmisores en la misma banda [L]: "When two or more transmitters are
  present on the same band, a hardware device MUST be used to prevent more than
  one signal at any one time."
- IX.8 [R]: las peticiones de contacto, las respuestas y la copia de indicativos e
  intercambios deben hacerse durante el concurso y en su modo y frecuencias.
  **POR VERIFICAR** la redacción literal.
- IX.9: "Correction of logged call signs and exchanges after the contest, by use
  of any database, recordings, email or other methods, is not allowed." [L].
- **Novedad 2026, sin robots** [L, `rules-cqww-2026` y `rules-cqww-2026-changes`]:
  - Bases: "A human operator must always initiate the following actions"; el
    blog dice "…at all times". Las acciones son cambiar de frecuencia, llamar a
    una estación y registrar el QSO.
  - Quedan prohibidos los sistemas o robots que emulen esas acciones [R].
  - Blog: "We have formally made the use of autonomous robot operation illegal."
    [L]. El blog añade que así se alinea con WPX y WW Digi [R].
- **Grabación de audio** [L, `rules-cqww-2026`]:
  - "Any single operator or single operator assisted entrant (see V.A.) competing
    for a top five finish at the (a) World, (b) Continent, or (c) USA levels,
    including Classic Overlay" debe grabar el audio transmitido y recibido.
  - "The recording must be in a common format (e.g., mp3) and should include the
    audio to each ear as a separate channel."
  - "The recording must be a continuous recording (not a recording of individual
    QSOs). Time "off the air" … does not have to be recorded."
  - "The recording may be requested by the Committee within 90 days after the
    log deadline … The recording files must be provided by the entrant within 5
    days of the request."
  - "Failure to submit a requested audio recording may result in the
    reclassification of a log entry or disqualification."
  - FAQ: grabar es buena práctica para cualquiera, y si no se sabe dónde se va a
    quedar, "it is prudent to make a recording" [R].

## 7. Envío del log

- "Electronic submission of logs is **required** for all entrants." y "Web upload
  is the only method of log submission." [L, `rules-cqww-2026`, sección "LOG
  INSTRUCTIONS"].
  - **No se acepta el correo electrónico.** La entrada antigua del blog que pedía
    enviar a ssb@cqww.com está desfasada [R].
- **Página de subida**: https://cqww.com/logcheck/ ("CQ WW - Cabrillo Log Upload")
  [L, título].
  - `logs.htm`: "Logs in Cabrillo format can be uploaded, checked and submitted
    using the Log Check page." [L].
- Formato: Cabrillo es el estándar; las instrucciones de cabecera están en
  https://cqww.com/cabrillo.htm [R].
  - Si no se puede generar Cabrillo: "please contact the Contest Director for
    assistance with submitting another format." [L].
- **Plazo**: "All entries must be sent WITHIN 48 HOURS after the end of the
  contest: no later than 2359 UTC October 27, 2026 for SSB and 2359 UTC December
  1, 2026 for CW." [L, `rules-cqww-2026`].
  - Blog: "The log deadline is 48 hours, moved from 5 days." [L].
  - Reenviar un log fuera de plazo convierte la entrada en *late log* [R: "Re-
    submitting an entry after the deadline will result in it being considered
    as a late log"].
- **Logs tardíos** [R]: pueden aparecer en los resultados, pero **no optan a
  premios**. Una entrada antigua del blog añade que, si se envía un segundo log
  fuera de plazo, "the new log will be used and will be marked as being late"
  [L, entrada con el plazo de 5 días ya desfasado].
- **Confirmación**: las bases dicen que todos los logs se confirman por correo [R].
  `logs.htm` [L]: "When your log has been submitted correctly, you will receive an
  e-mail containing a tracking (confirmation) number. Once you receive the
  tracking number, your log has been accepted."
  - Hay listas públicas "SSB Logs Received" / "CW Logs Received" [L].
- **La cabecera manda** [L, `logs.htm`]: "whatever is recorded in the header of
  your Cabrillo file is how we will process your entry". Errores típicos:
  - que el fichero no empiece por `START-OF-LOG`;
  - que el nombre del concurso no sea CQ-WW-SSB o CQ-WW-CW [R].
- **LOCATION** [L]: "U.S. stations must indicate the station location in the
  CABRILLO header (e.g., LOCATION: OH). All other stations indicate DX." Por
  tanto, EA4XXX pone `LOCATION: DX`.
- `logs.htm` es una página antigua (≈14 años según el buscador). Para plazos,
  manda el PDF 2026 [R].
- En 2026 el plan es solo escuchar, así que no hay que enviar nada. **POR
  VERIFICAR**: no se encontró ninguna categoría SWL en el CQ WW 2026 (el valor
  `SWL` existe en la especificación Cabrillo [S]).

## 8. Penalizaciones y verificación de logs

- **Verificación** [L, `rules-cqww-2026`]:
  - "Duplicate contacts are removed with no additional penalty."
  - "Contacts with an incorrectly received exchange are removed with no
    additional penalty."
  - "Call sign errors (bust) or call signs not in the other log (NIL) are removed
    and receive a penalty of two times the QSO point value for that contact."
- **Conflicto**: la FAQ todavía dice "The penalty for a NIL is three times the QSO
  point value for that contact" [L, `rules-cqww-faq`]. Prevalecen las bases 2026
  (2×).
- Ventana de tiempo para cruzar logs: "+/- 15 minutes" [L, `rules-cqww-logging-time`].
  Conviene sincronizar el reloj del PC con UTC.
- **Únicos** (*uniques*): no se encontró regla de penalización específica en 2026.
  **POR VERIFICAR**. Relacionado: "Taking credit for excessive unverifiable QSOs
  or unverifiable multipliers" es conducta antideportiva (ver abajo).
- **Informes UBN** (Unique/Bust/NIL): **POR VERIFICAR**; no aparecieron en las
  búsquedas de esta sesión.
- **Horas de descanso**: no hay mínimo para Single-Op. Solo Classic (24 h,
  descansos ≥60 min), además de la regla de 10 minutos de Multi-Single y los 8
  cambios por hora de Multi-Two.
- **Conducta antideportiva**: lista de 2026 [L/R, extended search sobre
  `rules-cqww-2026`]:
  1. "Arranging or confirming any contacts during or after the contest by use of
     ANY non-amateur radio means such as telephones, Internet, instant messaging,
     chat rooms, VoIP, email, social media or websites." [L].
  2. "Transmissions by the entrant on frequencies outside of license limitations." [L].
  3. "Changing times in the log to meet band change or off time rules." [L].
  4. "Taking credit for excessive unverifiable QSOs or unverifiable multipliers." [L].
  5. "Signals with excessive bandwidth (e.g., splatter, clicks) or harmonics on
     other bands." [L].
  6. "Running stations making more than three consecutive contacts without
     sending their callsign." [L].
  - Sobre el punto 6, un resumen lo daba como nuevo en 2026 y otro lo cita en las
    bases 2025 y en traducciones de 2022 y 2023. En 2014 y 2017 la regla era "1
    minute". **POR VERIFICAR** desde cuándo está; está vigente en 2026.
- **Sanciones** [R]:
  - "the entrant is subject to disqualification at the discretion of the
    Committee"; el comité también puede reclasificar.
  - "Disqualified entries will be listed at the end of the published results and
    are not eligible for an award."
  - Aviso por correo; "the entrant has five days to appeal the decision to the
    Contest Director. After that time, the decision is final." [L].
  - No se encontraron las "tarjetas roja/amarilla" de ediciones antiguas en el
    texto 2026. **POR VERIFICAR** (es una ausencia, no una cita).
- Blog sobre planes de banda (antiguo, sobre RTTY): "Contest entries must follow
  this rule and all other amateur service rules of their country. Not doing so is
  grounds for disqualification in this contest." [L]. Es contexto, no texto 2026.

## 9. Premios y competición de clubes

- **Certificados** [L, `rules-cqww-2026`]: "Electronic certificates will be made
  available for download for everyone that submits an entry provided the log is
  submitted before the deadline."
  - FAQ [L]: "On-line certificates are available after the final results are
    published for all entrants in the CQWW contest. The exception is when your
    log is submitted AFTER the deadline."
- **Placas** [R, `rules-cqww-2026` y `rules-cqww-plaques`]: "only one plaque will
  be awarded per entry". Si el ganador de un área obtiene una placa superior, "the
  plaque will be awarded to the runner-up in that area".
  - La lista de placas y patrocinadores está en https://cqww.com/plaques/.
  - **POR VERIFICAR**: si hay placa Rookie o Europa LP que afecte a EA.
  - No se encontró un mínimo de QSO para premios en las bases 2026 [R].
- **Clubes** [L/R, `rules-cqww-2026`]:
  - EE. UU.: socios que residan en un círculo de **250 millas** de radio.
  - Clubes DX: "Participation is limited to club members residing within EITHER
    the DXCC country where the club is located OR within a 400 km radius circle
    from center of club." [L]. Antes de 2014 eran 275 km [R].
  - Las asociaciones nacionales ("e.g., JARL, REF or DARC") **no** pueden
    participar [R]. Por analogía, URE tampoco (inferencia, **POR VERIFICAR**).
  - Un Single-Op aporta a un solo club; las multi reparten por porcentaje de
    socios. El club debe constar en el log (`CLUB:`).
  - Los checklogs no cuentan. Mínimo de logs para que figure un club: "at least
    four" [R]. **POR VERIFICAR** la cifra.

## 10. FAQ de cqww.com: temas principales

Temas encontrados en https://cqww.com/rules_faq.htm [R salvo indicación]:

- **Qué es Single Operator**: localizar e identificar uno mismo cada indicativo;
  cascada o *band scope* sí, *code reader* no (§6.1) [L].
- **Rookie**: inicio del periodo de 3 años, estaciones de club, licencias
  caducadas (§6.2). Elegir un solo overlay (Rookie o Youth).
- **Tiempo de operación**: "no limit on operating time" en las categorías
  tradicionales; solo CLASSIC tiene límite.
- **Multi-Single**: el reloj de 10 minutos empieza con un QSO en la banda nueva
  ("The clock starts only when you make a QSO on the new band") [L].
  - No se puede transmitir en más de dos bandas a la vez ni usar una tercera para
    buscar multiplicadores.
  - Hace falta bloqueo por hardware con dos radios en la misma banda.
- **Correcciones tras el concurso** [L]: "So you may not use a recording to
  listen to a contact and make corrections. You may not look up callsigns on the
  DX Cluster, RBN or DX newsletters after the contest."
  - Sí se pueden usar las notas o la memoria propias si reflejan lo que de verdad
    se transmitió [R; **POR VERIFICAR** la frase].
- **X-QSO**: para un QSO erróneo, no se borra; se marca con el prefijo `X-QSO:`.
  Así no cuenta para uno mismo pero sí para el corresponsal (borrarlo le quitaría
  el crédito) [R]. También se usa para los QSO hechos por error fuera de la
  licencia. Abusar de X-QSO para esquivar la regla de 10 minutos puede acabar en
  reclasificación [L].
- **Clubes**: definición del área del club. Los socios en DXpedición cuentan si
  residen en el área y nombran al club.
- **Grabaciones**: recomendadas aunque no sean obligatorias.
- **Certificados y logs tardíos**: ver §7 y §9.
- **NIL ×3**: respuesta desactualizada (§8).
- **EA8/EA9**: la FAQ no trata expresamente el continente de EA8/EA9 (**POR
  VERIFICAR**; no apareció). Las bases remiten a "continental boundaries" y a la
  zona de la "transmitter location".
  - Según el cty del proyecto (VER20260603): EA8 = Canarias, AF, zona 33;
    EA9 = Ceuta y Melilla, AF, zona 33; EA6 = Baleares, EU, zona 14 [C].
  - Un EA4 que trabaja EA8/EA9 suma 3 puntos.
- **Qué importa para EA4XXX LP Rookie**:
  - nada de cluster ni RBN;
  - 100 W medidos a la salida del amplificador activo (sin amplificador lineal,
    interpretamos que es la salida del transceptor);
  - poner la fecha de la primera licencia en SOAPBOX;
  - un solo overlay;
  - subir el log en 48 h por la web;
  - en 40 m, transmitir por debajo de 7200 kHz.

## 11. Cabrillo para CQ-WW-SSB

### 11.1 Reglas específicas del CQ WW

Fuente: https://cqww.com/cabrillo.htm [L salvo indicación].

- "contest-name must be one of the following: CQ-WW-CW or CQ-WW-SSB. Be sure to
  use hyphens as shown. DO NOT PUT THE YEAR OR USE PH INSTEAD OF SSB." Es decir,
  `CONTEST: CQ-WW-SSB`.
- Versión: se aceptan v2 y v3; se pide v3 ("use of Cabrillo v2 is deprecated, but
  still accepted by the log submission robot").
- Línea QSO: frecuencia, modo, fecha (yyyy-mm-dd), hora UTC, indicativo
  enviado, RST e intercambio enviados, indicativo recibido, RST e intercambio
  recibidos y, al final, el transmisor [R].
  - El modo de las líneas QSO en fonía es **`PH`**, no SSB. La cabecera usa
    `CATEGORY-MODE: SSB` [R, y la lista de modos `CW PH FM RY DG` de [S]].
  - "for the MULTI-ONE and MULTI-TWO categories, the last column in the log
    indicates which transmitter made the QSO. It must be a 0 or a 1. This column
    is not required for other categories." Un Single-Op **no** la pone.
- `LOCATION: DX` para cualquier estación no estadounidense (§7) [L].
- Overlay: `CATEGORY-OVERLAY: ROOKIE` + fecha de la primera licencia en `SOAPBOX:` [L].

### 11.2 Plantilla de columnas

Anchos según la plantilla CQ WW / WWROF. Están contrastados con Tlf
`share/cabrillo.fmt` sección `[CQWW]`
(`FREQ,5;MODE,2;DATE,10;TIME,4;MYCALL,13;RST_S,3;EXC_S,6;HISCALL,13;RST_R,3;EXCH,6;TX,1`)
y con el exportador de not1mm `plugins/cq_ww_ssb.py` [S].

```
                              --------info sent------- -------info rcvd--------
QSO: freq  mo date       time call          rst exch   call          rst exch   t
QSO: ***** ** yyyy-mm-dd nnnn ************* nnn ****** ************* nnn ****** n
QSO: 14250 PH 2027-10-30 0830 EA4XXX        59  14     EA8XXX        59  33
```

- `freq`: kHz (p. ej. 3750, 7150, 14250). Los separadores son espacios.
- **POR VERIFICAR**: la reproducción gráfica exacta de la plantilla de cqww.com
  (la página no se pudo leer entera). El orden de los campos sí está confirmado
  [R] y los anchos coinciden en dos implementaciones independientes [S].

### 11.3 Etiquetas de cabecera y valores permitidos (Cabrillo v3, WWROF)

La especificación de WWROF no se pudo leer directamente. Los valores siguientes
proceden de `cabrillo` 0.3.0 (PyPI, thxo/cabrillo), `cabrillo/data.py`, que dice
"Based on the Cabrillo specification available at: https://wwrof.org/cabrillo/"
[S]. La columna «CQ WW 2026» indica qué valores tienen sentido según las bases [R].

| Etiqueta | Valores en la especificación [S] | Uso en CQ WW SSB |
|---|---|---|
| `START-OF-LOG:` | versión (`3.0`) | Primera línea obligatoria [L, logs.htm] |
| `CONTEST:` | lista de concursos (incluye `CQ-WW-SSB`, `CQ-WW-CW`) | `CQ-WW-SSB` [L] |
| `CALLSIGN:` | indicativo usado | `EA4XXX` |
| `CATEGORY-OPERATOR:` | `SINGLE-OP`, `MULTI-OP`, `CHECKLOG` | Los tres |
| `CATEGORY-ASSISTED:` | `ASSISTED`, `NON-ASSISTED` | Distingue SO de SOA |
| `CATEGORY-BAND:` | `ALL`, `160M`, `80M`, `40M`, `20M`, `15M`, `10M` (+ VHF/UHF) | Solo ALL y las 6 bandas HF |
| `CATEGORY-MODE:` | `SSB`, `CW`, `RTTY`, `FM`, `MIXED`, `DIGI` | `SSB` |
| `CATEGORY-POWER:` | `HIGH`, `LOW`, `QRP` | HP 1500 W / LP 100 W / QRP 5 W |
| `CATEGORY-STATION:` | `FIXED`, `MOBILE`, `PORTABLE`, `ROVER`, `ROVER-LIMITED`, `ROVER-UNLIMITED`, `EXPEDITION`, `HQ`, `SCHOOL`, `EXPLORER`, `DISTRIBUTED` | `DISTRIBUTED` para Multi-Distributed [L]; `FIXED` para una estación en casa |
| `CATEGORY-TRANSMITTER:` | `ONE`, `TWO`, `LIMITED`, `UNLIMITED`, `SWL` | `ONE` en SO; para multi, **POR VERIFICAR** la equivalencia exacta (M/S, M/2, M/M) en cabrillo.htm |
| `CATEGORY-OVERLAY:` | `CLASSIC`, `ROOKIE`, `TB-WIRES`, `YOUTH`, `NOVICE-TECH`, `YL` (`OVER-50` se retiró de la especificación el 10-abr-2023) | Solo `CLASSIC`, `ROOKIE` y `YOUTH` |
| `CATEGORY-TIME:` | `6-HOURS`, `8-HOURS`, `12-HOURS`, `24-HOURS` | No aplica |
| `CERTIFICATE:` | `YES` / `NO` | Opcional; el CQ WW da certificados electrónicos a todos (§9). **POR VERIFICAR** el significado exacto en la especificación |
| `CLAIMED-SCORE:` | entero sin formato ("like 12345678", según el analizador [S]) | Puntuación reclamada |
| `CLUB:` | texto | Opcional; club que cumpla §9 |
| `CREATED-BY:` | texto | Programa de log |
| `EMAIL:` | texto | Necesario en la práctica: la confirmación llega por correo (§7) |
| `GRID-LOCATOR:` | 4, 6, 8 o 10 caracteres Maidenhead [S] | `IN80` |
| `LOCATION:` | texto | `DX` fuera de EE. UU. [L] |
| `NAME:`, `ADDRESS:` (varias líneas), `ADDRESS-CITY:`, `ADDRESS-STATE-PROVINCE:`, `ADDRESS-POSTALCODE:`, `ADDRESS-COUNTRY:` | texto | Datos postales |
| `OPERATORS:` | lista de indicativos | `EA4XXX` |
| `OFFTIME:` | inicio y fin (fecha hora) | No necesario en SO |
| `SOAPBOX:` | texto libre, varias líneas | Fecha de primera licencia (ROOKIE) o año de nacimiento (YOUTH) |
| `QSO:` / `X-QSO:` | línea de contacto / contacto que no cuenta | §10 (X-QSO) |
| `X-…:` | etiquetas de usuario | Opcionales |
| `END-OF-LOG:` | (vacío) | Última línea |

**POR VERIFICAR**: qué etiquetas son obligatorias u opcionales según el texto de
WWROF (no se pudo leer) y si el robot del CQ WW exige `CATEGORY-TRANSMITTER` o
`CATEGORY-STATION` para SO. La plantilla los incluye con valores estándar.

### 11.4 Ejemplo de log (SO, ALL, LOW, NON-ASSISTED, ROOKIE)

- Fichero: `data/rules/cabrillo_template.log`, generado por
  `scripts/rules_cabrillo.py`.
- Todos los datos son **ficticios**: EA4XXX, K1XXX, DL1XXX, EA8XXX, la dirección,
  el correo de `example.com` y la fecha de licencia **2026-03-15**, que solo es un
  ejemplo y hay que cambiar por la real.
- Comprobaciones [C][S]:
  - anchos de columna;
  - el analizador independiente `cabrillo` 0.3.0 acepta el fichero (categorías
    válidas según WWROF, QSO en orden cronológico, fecha y hora bien formadas);
  - `CLAIMED-SCORE` recalculado con las reglas 2026:
    - K1XXX (NA, zona 5) en 40 m: 3 puntos;
    - DL1XXX (EU, zona 14) en 80 m: 1 punto;
    - EA8XXX (AF, zona 33) en 20 m: 3 puntos;
    - total **7 puntos × 6 multiplicadores** (zona + país en cada una de las tres
      bandas) = **42**.
- El log lo genera el programa de concursos. La plantilla es ilustrativa.
- El fichero se guarda en ASCII con saltos LF. **POR VERIFICAR** si el robot de
  cqww.com tiene preferencias de fin de línea; not1mm escribe CRLF [S].
