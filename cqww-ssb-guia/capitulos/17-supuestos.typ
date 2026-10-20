#import "../plantilla.typ": *
#import "fonetica.typ": deletrear

#let fallos27 = csv("../data/calc/plan_bandas_2027_fallos.csv", row-type: dictionary)

#let capitulo(cfg) = [
= Supuestos y datos pendientes <cap-supuestos>

== Cómo se ha verificado esta guía

La guía se preparó el 20 de octubre de 2026 en un entorno con la red restringida: no se podían abrir directamente cqww.com, boe.es, iaru-r1.org ni las webs de fabricantes, tiendas o programas, y el cupo de búsquedas web se agotó durante la investigación. Por eso:

- Las *bases del CQ WW*, los *resultados* y la mayoría de *precios y especificaciones* se comprobaron con resúmenes de buscador de esas páginas y PDF (con cita literal cuando la había).
- La *normativa española* se leyó en los textos consolidados completos del BOE, a través de una réplica pública generada desde la API del BOE (legalize-es); se citan las URL oficiales.
- El *software* (Not1MM, Hamlib, wfview, SDR++, OpenWebRX+, rtl-sdr) se comprobó leyendo su código y su documentación en GitHub y PyPI.
- Los *datos solares* se leyeron del fichero de CelesTrak que distribuye el paquete `spaceweather` de PyPI.
- *Horarios, orto y ocaso, puntos, puntuaciones, ventanas de propagación, eficiencias de antena y distancias de exposición* se calcularon con los scripts de `scripts/` (Python en `.venv`).

Todo lo que no se pudo confirmar en una fuente primaria está marcado como #pv en el texto.

== Supuestos

+ *Indicativo y licencia*: EA4XXX es un marcador; la fecha de primera licencia (`AAAA-MM-DD`) también. Cámbialos en `main.typ`. Se supone que obtendrás la licencia después del 30 de octubre de 2024, así que en 2027 cumples el requisito ROOKIE.
+ *Tu Mac*: no se pudo comprobar su versión ni su arquitectura; la guía cubre Apple silicon e Intel.
+ *Coordenadas*: Madrid en 40,4168° N, 3,7038° O (Puerta del Sol); los destinos, en ciudades representativas de cada zona.
+ *Flujo solar del plan de bandas*: F10.7 = 120 para 2026 (previsión mensual ≈ 119 y media de octubre hasta el día 18 de 115,5, esta última de fuentes secundarias). Para 2027 se ha comprobado el mismo plan con F10.7 = 100 (previsión ≈ 98).
+ *Modelo de propagación*: valores medianos del modelo IRI, sin absorción, esporádica E ni variabilidad diaria; noches calculadas con el Sol bajo el horizonte en cinco puntos del trayecto.
+ *Bases de 2027*: se supone que serán como las de 2026 (incluido el plazo de 48 horas). Revísalas en septiembre de 2027.
+ *Cambio de hora*: se supone que la UE mantiene el régimen actual (último domingo de octubre a las 01:00 UTC).
+ *Puntos medios por QSO* (objetivos hipotéticos del capítulo @cap-historico): 2,0–2,1 desde Madrid.
+ *Precios*: los de los transceptores son los que verificaste tú o los vistos en buscador el 20 de octubre de 2026; en Passion Radio no está claro si incluyen IVA y WiMo aplica el IVA alemán.
+ *Exposición a RF*: factores de modo SSB (0,2–0,4) y de reflexión del suelo de la práctica técnica (FCC OET-65, UIT-T K.52), no de la norma española.

== Qué cambia en 2027 según el modelo

Con F10.7 = 100 (la previsión para octubre de 2027 es ≈ 98), estas recomendaciones del plan de 2026 dejan de tener respaldo en el cálculo (`scripts/calc_plan_bandas.py 100 2027-10-31`):

#tabla(
  columns: (auto, auto, 1fr, auto),
  table.header([Franja (UTC)], [Banda], [Destino], [Ventana en la franja]),
  ..fallos27.map(r => (r.franja_utc, r.banda, r.destino, [#r.horas_ventana.replace(".", ",") h])).flatten(),
)

En resumen: en 2027, *10 m hacia Norteamérica quedará reducido a unas horas a mediodía hacia la costa este* (o cerrado) y *15 m será la banda alta principal*; 10 m seguirá abriendo hacia Sudamérica y África.

== Lo más importante que queda por verificar

#tabla(
  columns: (auto, 1fr),
  table.header([Tema], [Pendiente]),
  [Bandas], [Plan de bandas IARU R1 vigente (todos los segmentos de SSB); resolución temporal 1850–2000 kHz y si cubre el CQ WW; estatus de cada banda en las tablas (imagen) del CNAF 2026.],
  [Trámites], [Formularios actuales de la autorización y de la licencia de estación fija en la sede electrónica; posibles cambios en las tasas.],
  [Bases], [Redacción literal del objetivo y del cómputo del overlay CLASSIC; tratamiento de los QSO únicos y existencia de informes UBN; si el SCP cuenta como asistencia (se usa habitualmente en no asistido).],
  [Equipo], [Duración de las memorias de voz y chip USB del IC-7300MK2; drivers del FT-710 en macOS; IVA de los precios de Passion Radio; modelos y precios de antenas, coaxial, cascos, pedal, fuente y medidores.],
  [Software], [Que SkookumLogger 6.0 tenga «CQ WW SSB» y soporte el IC-7300MK2; N1MM en Windows 11 para Arm; CTY posterior a CTY-3631 (mira el 23 de octubre).],
  [Escucha], [Receptores KiwiSDR concretos cerca de Madrid y lejos; URL del WebSDR de Twente.],
  [Historia], [Mejores EA, EA6, EA8, EA9 y rookies de cada año; crónicas de propagación de cada edición.],
  [Comunidad], [Radioclubes de la Comunidad de Madrid, secciones de URE, grupos de concurso españoles.],
  [Calendario], [Fechas de 2026–2027 de los concursos menores (calculadas con su regla habitual).],
)

== Créditos y licencias

- *Zonas CQ* del mapa: GeoJSON © 2024 HB9HIL, licencia MIT (texto completo en `data/geo/LICENSE-hamradio-zones-geojson.txt`) @own-hb9hil-zones. *Costas*: Natural Earth, dominio público @own-natural-earth.
- *Fichero CTY*: country-files.com (AD1C), copia VER20260603 distribuida con Not1MM @own-cty-not1mm.
- *Fuentes tipográficas*: Inter y JetBrains Mono, licencia SIL Open Font License (en `fonts/`).
- Todas las figuras y tablas calculadas son de elaboración propia con los scripts de `scripts/`.

== Cómo regenerar todo

Los pasos completos están en `README.md`. En resumen: crea el entorno (`uv venv .venv` e instala `requirements.txt`), ejecuta los scripts `calc_*` y `fig_*` y `merge_refs.py`, y compila:

```
typst compile --font-path fonts main.typ cqww-ssb-guia.pdf
typst compile --font-path fonts chuleta.typ chuleta.pdf
```
]
