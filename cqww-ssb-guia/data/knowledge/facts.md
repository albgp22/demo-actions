# Propagación, ciclo solar, conocimientos de concurso, formación, calendario, comunidad y operación sin estación propia

Fecha de corte: **2026-10-20**. Destinatario: autor principal del manual CQ WW DX SSB (radioaficionado
novel en Madrid, IN80, zona CQ 14, zona ITU 37; escucha el 24-25 oct 2026, calentamiento en concursos
pequeños desde el ARRL 10 m del 12-13 dic 2026, objetivo CQ WW SSB 30-31 oct 2027 como SO AB Low Power
ROOKIE). Claves bibliográficas: `data/knowledge/refs.yml` (prefijo `know-`).

## 0. Método, leyenda y limitaciones

- **[V-web]**: confirmado con el resumen de un buscador web sobre la página citada, en esta sesión
  (2026-10-20). No se leyó el documento completo: las cifras deben copiarse de la fuente al citar.
- **[V-web·2ª]**: igual que [V-web] pero la página es una **fuente secundaria** (recopilación de
  terceros); conviene contrastar con la fuente primaria (SILSO, SWPC, DRAO).
- **[V-local]**: leído en un fichero del proyecto (p. ej. el CTY `data/cty/cty_not1mm.json`,
  versión 20260603, o `data/geo/cqzones.geojson`).
- **[V-pkg]**: leído en un paquete descargado de PyPI. Sobre todo **Not1MM 26.10.18** (publicado en
  PyPI el 2026-10-19), cuyas cabeceras de plugins resumen las bases de cada concurso y dan la URL
  oficial ("Find rules at"). Es una **fuente secundaria**: sirve para localizar la página oficial,
  no sustituye a las bases.
- **[BOE]**: texto consolidado del BOE leído en la réplica `legalize-es` (raw.githubusercontent.com),
  con el mismo método que `data/legal/facts.md`. Citar siempre la URL oficial del BOE.
- **[CALC]**: cálculo propio reproducible (scripts `scripts/know_*.py`).
- **[MEM]**: conocimiento previo **no comprobado en esta sesión**. Todo lo marcado [MEM] es
  **POR VERIFICAR** antes de publicarlo como hecho.
- **Limitación importante.** El cupo de búsquedas web (compartido por todos los agentes de la sesión)
  se agotó justo después del bloque de ciclo solar. Los apartados 2-7 se apoyan en datos locales,
  paquetes de PyPI, el texto del BOE, cálculos propios y conocimiento previo marcado. Ningún dato se ha
  inventado; lo no verificable va marcado **POR VERIFICAR** y se recoge en el §8.

---

## 1. Ciclo solar 25 (estado a 2026-10-20)

**K1.1 Anuncio del máximo.** El 15-10-2024, en una rueda de prensa, NASA, NOAA y el panel
internacional de predicción del ciclo 25 anunciaron que el Sol había entrado en su **periodo de máximo
solar**, que podría durar aproximadamente otro año; advirtieron de que el mes exacto del pico sólo se
podría fijar meses después, cuando la actividad hubiera bajado claramente. NOAA publicó la nota
conjunta al día siguiente. [V-web] `know-nasa-solarmax-2024`, `know-swpc-solarmax-2024`
- Contexto citado en esas páginas: la fulguración X9.0 del 03-10-2024 fue la más intensa del ciclo
  hasta esa fecha. [V-web]

**K1.2 Máximo suavizado oficial (SILSO).** Según el STCE/SIDC (Observatorio Real de Bélgica, que
alberga el WDC-SILSO), el número de manchas **suavizado (13 meses)** del ciclo 25 alcanzó su máximo en
**octubre de 2024 con 160,9** (161 redondeado; sep. 2024: 159; nov. 2024: 157). La confirmación de
SILSO llegó en 2025. [V-web] `know-stce-sc25-tracking`, `know-sidc-sc25-max`

**K1.3 Máximo mensual.** El número de manchas **mensual** llegó a **216,0 en agosto de 2024**, el
valor más alto desde septiembre de 2001 (238,2). [V-web] `know-stce-sc25-tracking`

**K1.4 Previsión frente a realidad.** El panel de 2019 (NOAA/NASA/ISES) preveía un máximo suavizado de
**115** (horquilla 105-125) hacia **julio de 2025 (±8 meses, es decir, nov. 2024 - mar. 2026)**; antes del pico, SILSO estimaba 138-161 (may.-oct. 2024) y
NOAA 137-164. El ciclo 25 quedó muy por encima del panel pero por debajo del ciclo 23 (180,3).
[V-web] `know-stce-sc25-tracking`, `know-swpc-progression`
- Un trabajo de 2025 sitúa la fase de máxima actividad entre agosto de 2024 y enero de 2025 a partir
  del F10.7 ajustado. [V-web] `know-arxiv-2511-16788`

**K1.5 Situación reciente (DATOS PERECEDEROS; fuentes secundarias).**

| Mes | Nº manchas mensual (ISN) | F10.7 medio (sfu) | SSN suavizado | Fuente |
|---|---|---|---|---|
| ene. 2026 | — | — | 104,1 | solen.info [V-web·2ª] |
| mar. 2026 | — | — | 94,4 | solen.info [V-web·2ª] |
| may. 2026 | 101,4 (previsto 101,1) | 125,7 (previsto 138,3) | — | SolarHam [V-web·2ª] |
| jun. 2026 | 93,3 | 137,9 (142,2 a 1 UA) | 84,1 (proyectado) | solen.info [V-web·2ª] |
| **sep. 2026** | **60,3** | **105,0** (106,1 a 1 UA) | **76,0 (proyectado)** | solen.info [V-web·2ª] |
| oct. 2026 (hasta el 18) | — | 115,5 | 74,0 (proyectado) | solen.info [V-web·2ª] |

- El valor diario de F10.7 el **19-10-2026** era **137 sfu**; ese día AR4551 produjo una fulguración
  M1.7 y se esperaba posible tormenta geomagnética G1 hacia el 20-10. [V-web·2ª]
  `know-spaceweather-com`, `know-earthsky-sun-news`
- solen.info considera que la actividad **salió de la fase de máximo en febrero de 2026**; su media de
  81 días de F10.7 era 114,2 (28,6 % del rango del ciclo; pico de esa media: 227,3 el 04-09-2024).
  [V-web·2ª] `know-solen-star`
- La tabla del Bureau of Meteorology australiano emitida el 01-10-2026 muestra el SSN suavizado
  bajando desde algo más de 100 en enero de 2026 hasta valores en torno a 70 o algo menos ("high 60s")
  en diciembre de 2026, con los últimos meses como estimación. El resumen del buscador salió
  desordenado: **cifras exactas POR VERIFICAR**. [V-web, parcial] `know-bom-ssn`
- **POR VERIFICAR**: todos los valores de esta tabla contra el fichero mensual de SILSO
  (`know-silso-data`) y el flujo de Penticton/SWPC antes de publicarlos.

**K1.6 Previsión oficial SWPC para oct.-nov. 2026 y oct.-nov. 2027: NO OBTENIDA → POR VERIFICAR.**
SWPC publica cada mes la tabla "Predicted Sunspot Number And Radio Flux" (SSN y F10.7 suavizados con
percentiles 25/50/75) y el JSON
`https://services.swpc.noaa.gov/json/solar-cycle/predicted-solar-cycle.json`; la metodología
actual se describe en Miesch (2025), *Space Weather*. No fue posible leer los valores (host bloqueado
y búsquedas agotadas). [V-web: existencia] `know-swpc-predicted`, `know-miesch-2025`
- Indicio no oficial: un boletín del BoM de julio de 2026 apuntaría a un SSN suavizado en torno a 50
  a comienzos de 2027 y decreciente (lectura aproximada del resumen) → POR VERIFICAR. [V-web, parcial]

**K1.7 Equivalencia SSN ↔ F10.7 (para trabajar con escenarios).** La relación del IRI-2020 que usa
PyIRI es F10.7 = 63,75 + 0,728·R + 0,00089·R² [V-pkg, código de PyIRI 0.1.7]: R = 76 → 124;
R = 60 → 111; R = 50 → 102; R = 40 → 94 [CALC]. Comprobación con sep. 2026: ISN 60,3 → 110,9
calculado frente a 105,0 observado (≈5 % menos) [CALC].
- **Estimación propia (NO oficial):** a finales de octubre de 2026 cabe esperar F10.7 entre ~100 y
  ~140 (media de octubre hasta el 18: 115,5; diario 137 el 19-10). Si a finales de 2027 el SSN
  suavizado estuviera en 40-55, el F10.7 típico rondaría **85-105**. **Sustituir por la previsión
  SWPC cuando se pueda consultar.**

**K1.8 Consecuencia práctica para 10 y 15 m** (detalle en §2.2): con F10.7 ≈ 120 (otoño 2026), 10 m
abre por la tarde hacia Norteamérica Este y casi todo el día hacia Sudamérica y África; con F10.7 ≈ 80-100
(probable en otoño de 2027) 10 m hacia EE. UU. queda limitado a unas pocas horas o cerrado, y
**15 m pasa a ser la banda alta principal** para Norteamérica y Japón. 10 m hacia Sudamérica y África
sigue abierto incluso con F10.7 = 80. [CALC]

---

## 2. Propagación en HF a finales de octubre desde Madrid

### 2.1 Reglas generales por banda [MEM → POR VERIFICAR la cita bibliográfica]

Las reglas siguientes son conocimiento estándar de propagación ionosférica; no se pudo contrastar en
esta sesión con un artículo concreto (CQ, ARRL, RSGB). El §2.2 las respalda con un cálculo propio
para 10/15/20 m.

- **10 m (28 MHz).** Banda diurna: sólo abre por F2 si la MUF del trayecto supera ~28 MHz. En la fase
  descendente las aperturas se acortan y se concentran en los trayectos **norte-sur** (EA → Sudamérica,
  África), que cruzan la zona ecuatorial de ionización alta; los trayectos **este-oeste** y de **latitud
  alta** (EA → W6/KH6 por Canadá o Groenlandia, EA → JA por Siberia) son los primeros en cerrarse.
- **15 m (21 MHz).** En años de flujo medio-bajo es la banda alta más productiva: Japón y Asia por la
  mañana europea, Norteamérica desde media mañana hasta la puesta de sol en EA, Sudamérica y África casi
  todo el día y parte de la noche.
- **20 m (14 MHz).** La banda más fiable: abierta en algún sentido casi las 24 horas; por la noche
  aguanta hacia el sur y el oeste mientras el trayecto esté iluminado o la MUF siga por encima de 14 MHz;
  por la mañana es típico el **trayecto largo** a VK/ZL.
- **40 m (7 MHz).** Banda nocturna para DX: necesita oscuridad en todo (o casi todo) el trayecto;
  Norteamérica desde la puesta del sol en EA hasta el amanecer en EA, Japón/Asia alrededor del
  atardecer europeo (mientras sigue de noche en Asia), VK alrededor del amanecer y del atardecer.
- **80 m y 160 m.** Absorción de la capa D muy fuerte de día (crece con 1/f²): sólo DX con el trayecto a
  oscuras; picos cerca de la salida y la puesta del sol en cualquiera de los extremos.
- **Línea gris (terminador).** Al amanecer y al anochecer la capa D es débil en el lado oscuro y la F2
  sigue ionizada: refuerza los trayectos que siguen el terminador, sobre todo en 160/80/40 m. Los
  horarios concretos los calculará el autor principal con sus tablas de orto y ocaso.
- **Otoño (finales de octubre).** En el hemisferio norte la foF2 diurna es alta (anomalía de invierno)
  y las noches largas favorecen las bandas bajas, con menos ruido de tormentas que en verano.
- **Fase descendente del ciclo.** Disminuye la MUF media, pero siguen apareciendo días de flujo alto y
  fulguraciones (desvanecimientos repentinos en los trayectos iluminados). Las corrientes rápidas de
  viento solar de agujeros coronales provocan **perturbaciones geomagnéticas recurrentes (~27 días)** que
  hunden la MUF y añaden absorción auroral en los trayectos de latitud alta (EA-JA, EA-W6, EA-KH6).
- **Cambio de hora durante el concurso [MEM, alta confianza].** En la UE el horario de verano termina
  el último domingo de octubre a la **01:00 UTC** (Directiva 2000/84/CE): el **25-10-2026** y el
  **31-10-2027** caen **dentro** del CQ WW SSB. El concurso y el log van en UTC; los horarios locales de la
  península pasan de UTC+2 a UTC+1 esa madrugada. `know-eu-dst` (POR VERIFICAR la cita).

### 2.2 MUF orientativa calculada desde Madrid [CALC]

- **Método.** `scripts/know_muf.py` con PyIRI 0.1.7 (IRI con coeficientes CCIR; Forsythe et al.
  2023, *Space Weather*; cita del software: `know-pyiri-zenodo`). En cada punto de control:
  MUF(3000)F2 = foF2·M(3000)F2. Para trayectos > 4000 km, dos puntos de control a 2000 km de cada extremo
  sobre el círculo máximo, MUF(4000) ≈ 1,1·MUF(3000) y la MUF del trayecto es la menor (criterio clásico
  de tipo CCIR/UIT-R P.533). Escenarios de F10.7 = 80, 100, 120 y 140 sfu porque la previsión SWPC
  está POR VERIFICAR.
- **Limitaciones.** Valores **medianos mensuales** interpolados al día: un día concreto puede variar
  ±15-20 %; no modela absorción (LUF), esporádica E, dispersión ni tormentas. Las aperturas reales
  suelen empezar un poco antes y terminar un poco después que la MUF básica mediana: tomar las
  ventanas como orientación (±1 h).
- **Comprobación de cordura.** Sobre Madrid el 25-10-2026 a las 12 UTC con F10.7 = 120: foF2 = 9,8 MHz,
  M(3000) = 3,15, MUF(3000) ≈ 31 MHz; de noche (00 UTC) foF2 ≈ 4,7 MHz. Valores coherentes con la
  climatología de latitudes medias en otoño.
- **Ficheros.** `muf_ventanas.csv` (ventanas UTC por destino, banda y escenario; fechas 2026-10-25,
  2027-10-31, 2026-12-12 y 2027-03-06), `muf_horaria.csv` (MUF hora a hora), `muf_rumbos.csv`.

**10 m** (25-10-2026; MUF básica mediana ≥ 28,4 MHz; horas UTC). Con la misma F10.7, el 31-10-2027
da ventanas casi iguales (diferencia máxima 2,5 h en todo el conjunto, por la fecha); **lo que cambia
entre 2026 y 2027 es el nivel de flujo**.

| Destino | F10.7 = 80 | F10.7 = 100 | F10.7 = 120 | F10.7 = 140 |
|---|---|---|---|---|
| Nueva York (W2 / zona 5) | cerrado | 13:00-17:30 | 11:45-18:45 | 11:15-19:15 |
| Chicago (W9 / zona 4) | cerrado | cerrado | 13:00-18:30 | 12:30-19:00 |
| Los Ángeles (W6 / zona 3) | cerrado | cerrado | 16:30-18:00 | 15:30-18:45 |
| San Juan (KP4 / zona 8) | 15:30-17:30 | 11:00-19:00 | 10:30-19:45 | 10:15-20:15 |
| São Paulo (PY / zona 11) | 09:30-11:30; 13:30-19:45 | 09:15-21:15 | 09:00-00:30 | 08:45-02:30 |
| Buenos Aires (LU / zona 13) | 14:00-19:45 | 10:00-21:00 | 09:30-00:00 | 09:15-02:15 |
| Dakar (6W / zona 35) | 09:15-18:30 | 08:30-19:30 | 08:15-20:30 | 08:00-22:30 |
| Nairobi (5Z / zona 37) | 07:15-08:00; 10:15-17:15 | 06:45-18:30 | 06:15-20:00 | 06:15-22:00 |
| Johannesburgo (ZS / zona 38) | 11:30-18:30 | 09:45-21:15 | 06:30-22:15 | 06:15-22:45 |
| Nueva Delhi (VU / zona 22) | cerrado | 07:15-13:00 | 06:45-14:00 | 06:30-14:30 |
| Novosibirsk (UA9 / zona 18) | cerrado | 09:15-10:45 | 07:45-13:00 | 07:30-13:45 |
| Tokio (JA / zona 25) | cerrado | cerrado | cerrado | 08:15-08:45 |
| Yakarta (YB / zona 28) | cerrado | 09:15-10:30 | 08:15-11:00; 16:00-16:30 | 07:45-11:15; 15:30-17:00 |
| Sídney (VK2 / zona 30), SP | cerrado | 07:00-07:30 | 06:30-09:00 | 06:15-09:45 |
| Sídney (VK2 / zona 30), LP | cerrado | cerrado | cerrado | cerrado |
| Honolulu (KH6 / zona 31) | cerrado | cerrado | cerrado | 17:30-17:45 |

**15 m** (25-10-2026; MUF básica mediana ≥ 21,2 MHz; horas UTC)

| Destino | F10.7 = 80 | F10.7 = 100 | F10.7 = 120 | F10.7 = 140 |
|---|---|---|---|---|
| Nueva York (W2 / zona 5) | 11:45-19:00 | 11:00-20:00 | 10:30-20:45 | 10:15-21:15 |
| Chicago (W9 / zona 4) | 13:15-18:45 | 12:00-19:45 | 11:45-20:30 | 11:30-21:00 |
| Los Ángeles (W6 / zona 3) | 16:15-18:00 | 14:45-19:30 | 14:15-20:00 | 14:00-20:30 |
| San Juan (KP4 / zona 8) | 10:15-20:00 | 09:45-21:00 | 09:30-21:45 | 09:15-22:45 |
| São Paulo (PY / zona 11) | 08:45-22:30 | 08:15-03:00 | 07:15-03:30 | 07:15-04:00 |
| Buenos Aires (LU / zona 13) | 09:15-22:00 | 08:30-02:45 | 07:15-03:30 | 07:15-03:45 |
| Dakar (6W / zona 35) | 07:45-20:15 | 07:30-22:30 | 07:15-02:00 | 07:00-03:00 |
| Nairobi (5Z / zona 37) | 06:15-18:45 | 05:45-21:30 | 05:30-00:30 | 05:30-01:45 |
| Johannesburgo (ZS / zona 38) | 06:15-22:00 | 06:00-23:00 | 05:45-23:45 | 05:45-01:15 |
| Nueva Delhi (VU / zona 22) | 06:30-14:00 | 06:00-14:45 | 05:45-15:30 | 05:30-15:45 |
| Novosibirsk (UA9 / zona 18) | 07:45-12:00 | 07:00-14:00 | 06:30-15:00 | 06:15-15:30 |
| Tokio (JA / zona 25) | cerrado | 07:30-09:15 | 07:15-10:00 | 07:00-10:15 |
| Yakarta (YB / zona 28) | 06:15-16:15 | 05:45-17:30 | 05:30-18:15 | 05:15-18:45 |
| Sídney (VK2 / zona 30), SP | 06:15-10:45 | 05:45-13:15 | 05:30-15:30 | 05:15-16:30 |
| Sídney (VK2 / zona 30), LP | cerrado | 08:15-08:30; 20:15-21:00 | 08:00-10:00; 19:15-22:15 | 07:45-12:00; 18:45-23:15 |
| Honolulu (KH6 / zona 31) | cerrado | 17:15-18:15 | 16:45-19:00 | 16:30-19:30 |

Lecturas clave [CALC]:
- **Norteamérica en 10 m necesita F10.7 ≳ 100** (W2: 13-17:30 UTC con 100; 11:45-18:45 con 120);
  la costa oeste (W6) necesita ≳ 120 y sólo da 1,5-3 h al final de la tarde europea.
- **Japón en 10 m prácticamente cerrado** con cualquier flujo plausible en 2026-2027; en 15 m sólo
  una ventana matinal corta (~07:15-10:00 UTC) con F10.7 ≥ 100.
- **Sudamérica y África en 10 m abren incluso con F10.7 = 80** (5-9 h): son los multiplicadores de
  10 m más seguros desde EA en 2027.
- **15 m hacia Norteamérica** sigue abierta 7-11 h con cualquier escenario: banda alta principal para
  W/VE en 2027.
- **20 m** (en `muf_ventanas.csv`): hacia W2 abre ~10:00-21:30 UTC con F10.7 = 80 y ~09:00-23:30 con
  120; hacia Sudamérica y África, 17-24 h según el destino y el escenario.
- **ARRL 10 m (12-12-2026)**: con F10.7 = 100, W2 13:15-16:00 UTC y W9 14:30-15:45; con 120, W2
  12:30-17:30; PY/ZS abiertos por la tarde incluso con 80; JA cerrado. **ARRL DX SSB (06-03-2027)**:
  10 m hacia W2 sólo con F10.7 ≥ 120 (13-19 UTC); 15 m hacia W2 con 80 (14:00-19:15) y con 100
  (11:30-20:30). [CALC]

### 2.3 Rumbos y distancias desde Madrid [CALC] (`muf_rumbos.csv`; círculo máximo, Tierra esférica)

| Destino | Rumbo SP | Distancia SP | Rumbo LP |
|---|---|---|---|
| Nueva York (W2) | 295° | 5768 km | 115° |
| Chicago (W9) | 302° | 6725 km | 122° |
| Los Ángeles (W6) | 311° | 9363 km | 131° |
| San Juan (KP4) | 267° | 6374 km | 87° |
| São Paulo (PY) | 220° | 8385 km | 40° |
| Buenos Aires (LU) | 222° | 10045 km | 42° |
| Dakar (6W) | 209° | 3156 km | 29° |
| Nairobi (5Z) | 128° | 6190 km | 308° |
| Johannesburgo (ZS) | 150° | 8102 km | 330° |
| Nueva Delhi (VU) | 72° | 7274 km | 252° |
| Novosibirsk (UA9) | 44° | 6244 km | 224° |
| Tokio (JA) | 29° | 10763 km | 209° |
| Yakarta (YB) | 81° | 12190 km | 261° |
| Sídney (VK2) | 80° | 17685 km | 260° (22345 km) |
| Honolulu (KH6) | 334° | 12648 km | 154° |

---

## 3. Conocimientos de concurso

### 3.1 Zonas CQ (`cq_zones.csv`, `cq_zones_entidades.csv`)

- **Madrid y toda la península: zona CQ 14, zona ITU 37, continente EU** (entidad EA). [V-local] CTY
  VER20260603.
- Los **nombres en inglés** de las 40 zonas (de memoria, según la lista CQ WAZ) **coinciden 40/40** con
  `data/geo/cqzones.geojson` (HB9HIL, propiedad `cq_zone_name`). [V-local] La lista oficial CQ WAZ no
  se pudo consultar: POR VERIFICAR la cita final (`know-cq-waz`). Los nombres en español son traducción
  propia.
- La lista de **entidades por zona** sale del CTY: las de una sola zona se listan como "Entidades"; las
  repartidas entre varias (K, VE, VK, BY, UA, UA9, CE9) como "Parcialmente", con prefijos de ejemplo.
  [V-local, CALC] `scripts/know_cty_tables.py`
- Zonas con matices útiles desde Madrid [V-local]: en el CTY, EE. UU. asigna los distritos de
  indicativo 6-7 a la zona 3, los 0, 5, 8 y 9 a la 4 y el resto a la 5 (aproximación por distrito: la
  zona real depende del estado desde el que se opera); Canadá ocupa las zonas 1-5; Rusia asiática las
  16-19 y 23; China las 23 y 24; Australia las 29 y 30. Detalle de Rusia en `rusia_zonas.csv`:
  p. ej. **R9S/R8T/R9W… (Rusia asiática) son zona 16** y **R9X/R8F/R9G… (Rusia europea) son zona 17**.

### 3.2 Entidades DXCC

- **El CTY VER20260603 contiene 346 entidades: 340 DXCC + 6 que sólo cuentan como país en CQ WW**
  (marcadas "not DXCC"). Reparto de las 340 DXCC por continente: AF 76, AS 55, EU 68, NA 50, OC 59,
  SA 32. [V-local, CALC] `cty_resumen.txt`
- Que la lista oficial ARRL tenga **340 entidades vigentes** en 2026 es coherente con el CTY y con el
  conocimiento previo (sin altas ni bajas recientes conocidas), pero **no se comprobó en arrl.org**:
  POR VERIFICAR (`know-arrl-dxcc`).

### 3.3 Entidades WAE que cuentan como país en CQ WW (`wae.csv`) [V-local]

| Prefijo | Entidad | Cont. | Zona CQ | En DXCC cuenta como [MEM] | Identificación en el CTY |
|---|---|---|---|---|---|
| IT9 (IB9…IY9) | Sicilia | EU | 15 | Italia | por prefijo |
| IG9, IH9 | Italia africana (Lampedusa, Pantelleria) | **AF** | 33 | Italia | por prefijo |
| GM/s | Islas Shetland | EU | 14 | Escocia | sólo por indicativo exacto (170 en el CTY) |
| JW/b | Isla del Oso | EU | 40 | Svalbard | sólo por indicativo exacto |
| 4U1V | Centro Internacional de Viena | EU | 15 | Austria | por prefijo |
| TA1 (TB1, TC1, YM1) | Turquía europea | EU | 20 | Turquía | por prefijo |

- Las bases de CQ WW definen los multiplicadores de país con la lista DXCC, la lista WAE y las fronteras
  WAC [MEM: POR VERIFICAR el texto literal en `know-cqww-rules`]. Por eso el log debe usar **siempre el
  CTY más reciente** (AD1C publica versiones antes de los grandes concursos [MEM]).

### 3.4 Continentes y zonas "trampa" desde Madrid (`continentes_trampa.csv`) [V-local]

- **ÁFRICA aunque parezca España/Portugal/Italia:** EA8 Canarias (AF, z33), EA9 Ceuta y Melilla (AF,
  z33), CT3 Madeira (AF, z33), IG9/IH9 (AF, z33).
- **EUROPA aunque estén lejos:** CU Azores (EU, z14), TF Islandia (EU, z40), JW Svalbard (EU, z40),
  JX Jan Mayen (EU, z40), R1FJ Tierra de Francisco José (EU, z40). **Groenlandia OX es NA** (zona 40).
- **ASIA en el Mediterráneo:** 4X Israel, 5B Chipre, ZC4, TA Turquía asiática, E4, OD, YK, JY (todos AS,
  zona 20). TA1 (Turquía europea) es EU, también zona 20. 4L Georgia, EK Armenia, 4J Azerbaiyán: AS,
  zona 21.
- **Otras:** 4U1I (UIT, Ginebra) es entidad propia, EU, z14; 4U1U (ONU, Nueva York) es entidad propia,
  **NA**, z5; 1A (Orden de Malta) EU, z15; UA2 Kaliningrado EU, z15.
- **Puntuación CQ WW resultante para EA** (regla de puntos según los comentarios del código de Not1MM,
  que citan las bases: 3 puntos con otro continente; 1 con otro país del mismo continente; 2 entre
  países distintos de Norteamérica; 0 dentro del propio país, que sí cuenta como multiplicador)
  [V-pkg + V-local]: EA-EA8, EA-EA9, EA-CT3, EA-4X, EA-TA, EA-UA9 u OX = **3 puntos**; EA-CU, EA-EA6,
  EA-CT, EA-TA1, EA-UA o TF = **1 punto**; EA-EA = **0 puntos** (pero suma zona 14 y país EA como
  multiplicadores). La regla oficial está en `know-cqww-rules` (POR VERIFICAR literal).
- **Intercambio CQ WW SSB:** RS + zona CQ (cabecera de Not1MM) [V-pkg] → desde Madrid "59 14".

### 3.5 Alfabeto fonético y código de cifras

**UIT, Reglamento de Radiocomunicaciones, apéndice 14** [MEM: contenido estándar; POR VERIFICAR
edición y URL `know-itu-rr`]:

| Letra | Palabra | Letra | Palabra | Letra | Palabra |
|---|---|---|---|---|---|
| A | Alfa | J | Juliett | S | Sierra |
| B | Bravo | K | Kilo | T | Tango |
| C | Charlie | L | Lima | U | Uniform |
| D | Delta | M | Mike | V | Victor |
| E | Echo | N | November | W | Whiskey |
| F | Foxtrot | O | Oscar | X | X-ray |
| G | Golf | P | Papa | Y | Yankee |
| H | Hotel | Q | Quebec | Z | Zulu |
| I | India | R | Romeo | | |

- Código de cifras del mismo apéndice: 0 Nadazero, 1 Unaone, 2 Bissotwo, 3 Terrathree, 4 Kartefour,
  5 Pantafive, 6 Soxisix, 7 Setteseven, 8 Oktoeight, 9 Novenine; coma decimal "Decimal", punto final
  "Stop". En radioafición casi nunca se usa: las cifras se dicen sin más en inglés ("five nine one
  four"). [MEM]
- Ortografía oficial: **Alfa** y **Juliett** (no "Alpha"/"Juliet"). [MEM]
- **Alternativas habituales en DX y concursos (NO normalizadas)** [MEM, uso observado; sin fuente
  verificada]: America (A), Boston/Brazil (B), Canada (C), Denmark (D), England/Ecuador (E), Florida
  (F), Germany/Guatemala (G), Honolulu (H), Italy (I), **Japan** (J), **Kilowatt**/King (K),
  London (L), **Mexico** (M), Norway/Nicaragua (N), Ontario/Ocean (O), **Portugal**/Peru (P),
  Queen (Q), Radio (R), Santiago/Sugar (S), Tokyo/Texas (T), United/Uruguay (U), Victoria/Venezuela (V),
  Washington (W), Yokohama (Y), Zanzibar (Z).
  - Evidencia indirecta [V-pkg]: el fichero de fonética del manipulador de voz de Not1MM 26.10.18
    (`data/alpha bravo charlie delta.txt`) usa "alpha, … juliet, **kilowatt**, …, xray": hasta un
    programa de concursos prefiere "kilowatt" a "kilo".
  - Consejo didáctico (propio): usar primero la fonética UIT; si el corresponsal no copia, repetir con
    una alternativa geográfica y mantenerla durante el resto del QSO.

---

## 4. Formación

### 4.1 Simuladores y entrenadores

- **Morse Runner** (VE3NEA) y **Morse Runner Community Edition**: simuladores de concurso/pile-up
  **sólo de CW** (Windows). [MEM] `know-morserunner`, `know-morserunner-ce` → POR VERIFICAR.
- **RufzXP**: entrenador de copia de indicativos, **sólo CW**. [MEM] POR VERIFICAR.
- **Simulador de pile-ups en SSB**: no se ha podido verificar ninguno de uso extendido (ni un modo
  simulador en N1MM Logger+). **POR VERIFICAR** con una búsqueda específica ("SSB pileup trainer").
- **Entrenamiento práctico verificable sin simulador** [propuesta propia]:
  1. Grabar el audio del CQ WW SSB del 24-25 oct 2026 (receptor propio o SDR web: WebSDR de la
     Universidad de Twente, red pública KiwiSDR [MEM: `know-websdr-twente`, `know-kiwisdr-list`,
     POR VERIFICAR URL]) y reproducirlo después "anotando a la sombra" (shadow logging) en el
     programa de log, en una base de datos de prueba.
  2. Practicar el manipulador de voz: Not1MM trae macros SSB F1-F12 (CQ, indicativo propio,
     intercambio, "thank you QRZ", "again", "your call", "my number") y WAV de fonética a-z y 0-9
     [V-pkg]; N1MM Logger+ tiene una función equivalente [MEM].
  3. Usar Super Check Partial: Not1MM incluye `MASTER.SCP` [V-pkg].

### 4.2 Cursos, vídeos, revistas y foros técnicos

- **Contest University (CTU)**, `contestuniversity.com`: jornada anual de formación en concursos
  vinculada a Dayton Hamvention (mayo), con presentaciones publicadas en línea. [MEM] POR VERIFICAR.
- **WWROF** (World Wide Radio Operators Foundation): seminarios web sobre concursos. [MEM] POR VERIFICAR.
- **NCJ – National Contest Journal** (`ncjweb.com`; dominio citado en Not1MM para el NAQP) [V-pkg].
- **3830scores.com**: publicación de puntuaciones declaradas y comentarios tras cada concurso (URL
  citada en Not1MM) [V-pkg]. Útil para comparar con estaciones EA de categoría parecida.
- **Bases y formato de log**: `know-cqww-rules`, `know-cqww-logcheck`, `know-cabrillo` [V-pkg]. FAQ
  de cqww.com: URL supuesta `https://www.cqww.com/faq.htm` → POR VERIFICAR (`know-cqww-faq`).

### 4.3 Libros y guías

- No se pudo verificar ningún título concreto (guías de iniciación de NCCC, K3LR, CQ, RSGB o ARRL).
  **POR VERIFICAR** antes de recomendar uno. [MEM]

### 4.4 Plan de preparación mes a mes (propuesta propia, sin fuente; fechas del §5)

| Periodo | Objetivo | Actividad |
|---|---|---|
| 24-25 oct 2026 | Escuchar | CQ WW SSB 2026: grabar, anotar ritmo, fonética y aperturas por banda; comparar con §2.2 |
| nov 2026 | Software y escucha CW | Instalar y configurar el log (CQ WW SSB, mensajes de voz); escuchar el CQ WW CW (28-29 nov) |
| 12-13 dic 2026 | Primer concurso | ARRL 10 m: pocas horas, sólo 10 m, intercambio RS + nº de serie |
| ene-feb 2027 | Ritmo en búsqueda (S&P) | HA DX, UBA DX SSB, EUDXC, PACC, REF SSB (fechas POR VERIFICAR) |
| mar 2027 | Pile-ups transatlánticos | ARRL DX SSB (6-7 mar), RDXC (20-21), CQ WPX SSB (27-28): primeras horas "llamando CQ" |
| abr-jun 2027 | Consolidar | SP DX, Helvetia, ARI DX, S.M. El Rey de España SSB; mejorar antenas |
| jul 2027 | Concurso mundial de 24 h | IARU HF (10-11 jul): práctica de 12-24 h con descansos |
| ago-sep 2027 | Ensayo general | EUHFC, WAE SSB (11-12 sep; QTC opcional), All Asian SSB |
| oct 2027 | Puesta a punto | Oceania SSB, WAG; revisar CTY, Cabrillo y estación; **CQ WW SSB 30-31 oct** |

---

## 5. Calendario de calentamiento nov 2026 - oct 2027 (`contests_calendar.csv`)

- 30 filas, de la escucha del CQ WW SSB 2026 al CQ WW SSB 2027. **Las fechas están CALCULADAS** con
  la regla habitual de cada concurso (p. ej. "último fin de semana completo de octubre") por
  `scripts/know_calendar.py`. Las reglas son conocimiento previo (**POR VERIFICAR en las bases de
  cada año**), salvo las URL marcadas "Not1MM", que se leyeron en el paquete. [CALC + MEM + V-pkg]
- Coherencia comprobada: el cálculo reproduce las fechas del plan del autor (CQ WW SSB 24-25 oct 2026
  y 30-31 oct 2027; ARRL 10 m 12-13 dic 2026). [CALC]
- **Hitos:** CQ WW CW 28-29 nov 2026 (escucha) · ARRL 10 m 12-13 dic 2026 (36 h máx. de operación;
  DX envía RS + nº de serie; 2 puntos por QSO en fonía [V-pkg]) · ARRL DX SSB 6-7 mar 2027 · RDXC
  20-21 mar · CQ WPX SSB 27-28 mar · IARU HF 10-11 jul (1200-1200 UTC) · WAE SSB 11-12 sep · CQ WW SSB
  30-31 oct 2027.
- **Muy dudosas:** Stew Perry (sólo CW; fecha supuesta 26-27 dic 2026); EUHFC (Not1MM dice "primer
  sábado de agosto, 12-24 UTC" → 7 ago 2027; de memoria podría ser el segundo sábado); fechas de los
  concursos S.M. El Rey de España SSB y CW (URE): **sin fecha**, sólo URL.
- Concursos URE: las bases y el envío de listas están en `https://concursos.ure.es/` (URL de Not1MM)
  [V-pkg]. El S.M. El Rey de España SSB (160-10 m) se intercambia así: EA da RS + provincia y no EA
  da RS + nº de serie; multiplicadores: provincias EA, entidades EADX100 y estación especial (EA0) por
  banda [V-pkg]. Fecha 2027: POR VERIFICAR. "Concurso EA DX" y otros concursos nacionales: POR
  VERIFICAR en el portal de URE.

---

## 6. Comunidad

- **URE** (Unión de Radioaficionados de España), `https://www.ure.es/`: asociación nacional y
  sociedad miembro de la IARU por España; bureau QSL para socios, revista, diplomas y concursos. [MEM]
  POR VERIFICAR servicios, sede y secciones de Madrid. Lo verificado: su portal de concursos
  `concursos.ure.es` y la estación **EA4URE**, multiplicador especial del EA RTTY según Not1MM.
  [V-pkg]
- **Radioclubes de la Comunidad de Madrid: ninguno verificado** (búsquedas agotadas). `clubs.csv`
  incluye URE (verificación parcial) y candidatos marcados `verificado = no` que **no deben publicarse
  sin comprobar**. Dato legal útil para reconocerlos [BOE]: los sufijos que empiezan por **UR** se
  reservan a estaciones colectivas de asociaciones y los que empiezan por **RC o RK** a las de **radio
  clubs** (Orden IET/1311/2013, art. 27); [INTERPRETACIÓN] en el distrito 4 un radioclub tendría, por
  ejemplo, un indicativo del tipo EA4RC* o EA4RK*.
- **Grupos de concurso en España**: no verificados → POR VERIFICAR.
- **Foros y listas** [MEM, POR VERIFICAR]: reflector CQ-Contest (`lists.contesting.com`, podría haber
  migrado de plataforma), r/amateurradio en Reddit, foros de QRZ.com. Verificado [V-pkg]:
  `3830scores.com` para puntuaciones. No se verificó ningún foro hispano específico de concursos.

---

## 7. Operar sin estación propia

### 7.1 Categorías de CQ WW SSB

- Según la cabecera del plugin CQ WW SSB de Not1MM 26.10.18 [V-pkg]: Single Op All Band y Single Band
  (QRP/Low/High); Single Op Assisted All Band y Single Band (QRP/Low/High); superposiciones
  **Classic/Rookie/Youth**; **Multi-Single (Low/High)**; **Multi-Two**; **Multi-Multi**; **Explorer**.
  Potencias: HP 1500 W, LP 100 W, QRP 5 W.
- Definiciones resumidas [MEM, POR VERIFICAR con las bases del año]: Multi-Single, una señal emitida
  a la vez con limitación de cambios de banda ("regla de los 10 minutos") y, como excepción, una
  segunda estación sólo para multiplicadores nuevos; Multi-Two, hasta dos señales en bandas distintas
  con límite de cambios por hora; Multi-Multi, una señal por banda; Explorer, categoría para
  experimentar con técnicas no permitidas en las demás; Rookie, operador con licencia desde hace
  3 años o menos.

### 7.2 Cómo suelen participar los radioclubes [MEM, POR VERIFICAR]

- Un club monta una estación **multioperador** (normalmente Multi-Single, Low o High) con un indicativo
  de la estación colectiva o un indicativo especial de concurso, y reparte turnos. Para un novel es
  la mejor escuela: se aprende con operadores veteranos, se ve una estación seria y el concurso se
  cubre sin estación propia.
- Marco legal español [BOE, ver también `data/legal/facts.md` §2]: los prefijos especiales ED, EE y EF
  (concursos y eventos de ámbito nacional o inferior) y EG/EH, AM/AN y AO requieren autorización
  temporal previa de la Jefatura Provincial (art. 27.1); la solicitud es por evento e indica si la
  estación es "propia o colectiva formando una estación única" (art. 28).

### 7.3 Normativa española aplicable [BOE: Orden IET/1311/2013, texto consolidado; `know-boe-iet1311`]

- Art. 18.4: «Las estaciones fijas de radioaficionado se clasifican en individuales y colectivas.»
- Art. 18.5: «Cualquier radioaficionado podrá instalar una o más estaciones fijas individuales para su
  uso y explotación…».
- Art. 18.6: «Únicamente las asociaciones de radioaficionados reconocidas podrán ser autorizadas a
  instalar estaciones colectivas de radioaficionado, de cuya utilización será responsable la Junta
  Directiva de la asociación.»
- Art. 18.8: las estaciones colectivas necesitan, además de la licencia de estación, «una autorización
  de radioaficionado individualizada a la que se considerará asociada dicha licencia», con su propio
  distintivo; art. 27: «Las estaciones colectivas también llevarán asociado un distintivo específico de
  llamada para cada una de ellas».
- Art. 5.4: la autorización de radioaficionado es «personal y no transferible».
- Art. 30.6: las estaciones colectivas pueden usarse esporádicamente «con fines de divulgación y
  fomento de la radioafición, por personas noveles» (demostraciones y cursos de la asociación, bajo
  supervisión directa y presencial de un radioaficionado con al menos tres años de antigüedad,
  identificándose con el distintivo de la estación colectiva seguido de dos o tres letras y como máximo
  el 40 % de la potencia de la banda, con tope de 100 W p.i.r.e.). **No es la vía para un concurso**,
  pero muestra el papel formativo de los radioclubes.
- Anexo I, ap. 1 (definiciones): «Estación fija remota de radioaficionado: Estación fija de
  radioaficionado que puede ser accionada a distancia.» Es la **única** aparición de "remota" en el texto.
- Art. 31 (último párrafo): los titulares de licencias de estaciones fijas deben garantizar su uso
  conforme a la legislación «tanto en emisiones directas como a través de su interconexión con otras
  redes o servicios».
- **[INTERPRETACIÓN, POR VERIFICAR con la Jefatura o URE]:** la Orden reconoce la estación fija remota y
  la interconexión con otras redes, pero no regula expresamente cómo puede un radioaficionado operar
  por Internet la estación de otro titular, ni la de un club, ni con qué indicativo. Lo prudente es
  operar estaciones colectivas de un radioclub conforme a sus normas internas (responsable: su Junta
  Directiva) o pedir criterio a la Jefatura Provincial antes de operar a distancia la estación
  individual de otra persona.

### 7.4 Operación remota según las bases de CQ WW [MEM: texto aproximado, POR VERIFICAR literal en `know-cqww-rules`]

- Se permite la operación remota si todos los transmisores, receptores y antenas están físicamente en
  **una sola ubicación**. La estación remota debe cumplir la licencia de estación, la de operador y las
  limitaciones de la categoría, y el indicativo debe ser uno expedido o permitido por la autoridad del
  país donde está la estación.
- Receptores remotos fuera de la ubicación de la estación: no permitidos (salvo lo que se admita en la
  categoría Explorer).
- Ubicación: todos los equipos dentro de un círculo de 500 m de diámetro o de los límites de la
  propiedad del titular, lo que sea mayor, con las antenas conectadas por cable a los equipos.
- Consecuencia práctica [INTERPRETACIÓN]: una estación remota en España operada por un EA desde Madrid
  cuenta como estación española (zona y país de la ubicación de la estación); una estación remota en
  otro país exige un indicativo válido allí y cuenta como estación de ese país.

### 7.5 Opciones para el autor del manual (resumen)

1. **Operador invitado en un multioperador de radioclub** (CQ WW SSB 2026 o 2027): la vía más formativa.
2. **Estación portable o móvil propia** mientras no exista licencia de estación fija: según
   `data/legal/facts.md` L2.17-L2.20, la autorización ampara estaciones móviles y portátiles sin
   licencia de estación, con aviso para estación *portable* salvo usos de hasta 15 días. [BOE vía
   legal/facts.md]
3. **Estación remota** (de un club o de un colega, o un servicio comercial [MEM]) respetando §7.3 y §7.4.

### 7.6 Etiqueta del operador invitado (recomendaciones propias)

- Pedir y aceptar las normas de la estación (turnos, categoría, potencia, bandas asignadas, uso del
  cluster) y no cambiar configuraciones sin permiso.
- Conocer de antemano el software de log, los mensajes de voz y el intercambio; practicar con el
  equipo antes del concurso.
- Identificar siempre con el indicativo de la estación; anotar cada QSO tal cual; avisar enseguida de
  errores o averías.
- Dejar el puesto como se encontró, ayudar a montar y desmontar y compartir gastos si es costumbre.
- No publicar puntuaciones ni comentarios en nombre de la estación sin autorización del responsable.

---

## 8. Lista POR VERIFICAR (resumen)

1. Previsión SWPC de SSN y F10.7 suavizados para oct.-nov. 2026 y oct.-nov. 2027 (JSON
   `predicted-solar-cycle.json`).
2. Valores mensuales de 2026 (ISN y F10.7) contra SILSO y DRAO/SWPC; tabla del BoM del 01-10-2026.
3. Fuente bibliográfica concreta (CQ/ARRL/RSGB) para las reglas generales de propagación del §2.1.
4. Directiva 2000/84/CE (fin del horario de verano a las 01:00 UTC del último domingo de octubre).
5. Lista oficial CQ WAZ de zonas (nombres coinciden con el GeoJSON de HB9HIL, no con la fuente oficial).
6. Recuento oficial ARRL de entidades DXCC vigentes (340 según el CTY).
7. Texto literal de las bases CQ WW: multiplicadores DXCC/WAE/WAC, categorías, Rookie (≤ 3 años),
   operación remota, círculo de 500 m.
8. Apéndice 14 del RR de la UIT (edición vigente y URL) y fuente para las alternativas fonéticas.
9. Simuladores SSB de pile-up; Morse Runner, Morse Runner CE y RufzXP; Contest University, WWROF,
   WebSDR y KiwiSDR (URL); libros y guías de iniciación.
10. Fechas de todos los concursos del calendario en sus bases de 2026/2027, en especial S.M. El Rey de
    España SSB/CW, EUHFC, Stew Perry, UBA, PACC, SP DX y las URL marcadas "de memoria".
11. URE: servicios, sede, secciones o delegaciones en Madrid; radioclubes de la Comunidad de Madrid
    (nombre, indicativo, localidad, web); grupos de concurso españoles; foros hispanos; FAQ de cqww.com;
    estado actual del reflector CQ-Contest.
12. Criterio de la Administración sobre la operación remota de estaciones ajenas (§7.3).

## 9. Ficheros y scripts

| Fichero | Contenido | Generado por |
|---|---|---|
| `data/knowledge/facts.md` | Este documento | a mano |
| `data/knowledge/refs.yml` | 65 referencias Hayagriva `know-*` (compila con Typst) | a mano |
| `data/knowledge/cq_zones.csv` | zona, descripcion, fuente (40 filas) | `scripts/know_cty_tables.py` |
| `data/knowledge/cq_zones_entidades.csv` | detalle: nombre EN/ES, entidades completas y parciales | idem |
| `data/knowledge/wae.csv` | 6 entidades WAE que no son DXCC | idem |
| `data/knowledge/continentes_trampa.csv` | 43 entidades con continente o zona poco intuitivos | idem |
| `data/knowledge/rusia_zonas.csv` | prefijos rusos por zona CQ | idem |
| `data/knowledge/cty_resumen.txt` | recuento DXCC/WAE y reparto por continente | idem |
| `data/knowledge/contests_calendar.csv` | 30 concursos nov 2026 - oct 2027 | `scripts/know_calendar.py` |
| `data/knowledge/clubs.csv` | URE y candidatos sin verificar | a mano |
| `data/knowledge/muf_ventanas.csv`, `muf_horaria.csv`, `muf_rumbos.csv` | MUF orientativa, rumbos y distancias | `scripts/know_muf.py` (necesita PyIRI 0.1.7 en `--pyiri-path`) |

Reproducción: `python3 -I scripts/know_cty_tables.py .` · `python3 -I scripts/know_calendar.py .` ·
`pip install --target <dir> PyIRI==0.1.7` y después
`python3 -I scripts/know_muf.py --root . --pyiri-path <dir>`.
