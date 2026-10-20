#import "../plantilla.typ": *
#import "fonetica.typ": deletrear

#let fallos27 = csv("../data/calc/plan_bandas_2027_fallos.csv", row-type: dictionary)
#let verif = ("legal", "equipo", "historia").map(d => csv("../data/verif_" + d + "/verificacion.csv", row-type: dictionary)).flatten()
#let cuenta(e) = verif.filter(r => r.estado == e).len()

#let capitulo(cfg) = [
= Supuestos y datos pendientes <cap-supuestos>

== Cómo se ha verificado esta guía

La guía se preparó el 20 de octubre de 2026 en un entorno con la red restringida: no se podían abrir directamente cqww.com, boe.es, iaru-r1.org ni las webs de fabricantes, tiendas o programas, y el cupo de búsquedas web se agotó durante la investigación. Por eso:

- Las *bases del CQ WW*, los *resultados* y la mayoría de *precios y especificaciones* se comprobaron con resúmenes de buscador de esas páginas y PDF (con cita literal cuando la había).
- La *normativa española* se leyó en los textos consolidados completos del BOE, a través de una réplica pública generada desde la API del BOE (legalize-es); se citan las URL oficiales.
- El *software* (Not1MM, Hamlib, wfview, SDR++, OpenWebRX+, rtl-sdr) se comprobó leyendo su código y su documentación en GitHub y PyPI.
- Los *datos solares* se leyeron del fichero de CelesTrak que distribuye el paquete `spaceweather` de PyPI.
- *Horarios, orto y ocaso, puntos, puntuaciones, ventanas de propagación, eficiencias de antena y distancias de exposición* se calcularon con los scripts de `scripts/` (Python en `.venv`).

El mismo día, con el cupo de búsquedas renovado, cinco agentes repasaron todo lo pendiente (marco legal y plan de bandas, equipo y software, historia y comunidad, y antenas con precio). De #verif.len() afirmaciones revisadas, *#cuenta("confirmado") se confirmaron*, *#cuenta("corregido") se corrigieron* y #cuenta("sin_confirmar") siguen sin confirmar; además se documentaron 84 antenas y accesorios con su precio y su tienda. El detalle está en `data/verif_*/verificacion.csv` y en `data/antenas/`.

Todo lo que sigue sin confirmar en una fuente primaria está marcado como #pv en el texto. Para comprobarlo en el original hay dos caminos: abrir desde tu Mac los enlaces de la bibliografía, o permitir esos dominios (cqww.com, boe.es, iaru-r1.org, ure.es, digital.gob.es…) en la red del entorno donde se generó la guía y repetir la verificación con los scripts de `scripts/`.

== Supuestos

+ *Indicativo y licencia*: EA4XXX es un marcador; la fecha de primera licencia (`AAAA-MM-DD`) también. Cámbialos en `main.typ`. Se supone que obtendrás la licencia después del 30 de octubre de 2024, así que en 2027 cumples el requisito ROOKIE.
+ *Tu Mac*: no se pudo comprobar su versión ni su arquitectura; la guía cubre Apple silicon e Intel.
+ *Coordenadas*: Madrid en 40,4168° N, 3,7038° O (Puerta del Sol); los destinos, en ciudades representativas de cada zona.
+ *Flujo solar del plan de bandas*: F10.7 = 120 para 2026 (previsión mensual ≈ 119 y media de octubre hasta el día 18 de 115,5, esta última de fuentes secundarias). Para 2027 se ha comprobado el mismo plan con F10.7 = 100 (previsión ≈ 98).
+ *Modelo de propagación*: valores medianos del modelo IRI, sin absorción, esporádica E ni variabilidad diaria; noches calculadas con el Sol bajo el horizonte en cinco puntos del trayecto.
+ *Bases de 2027*: se supone que serán como las de 2026 (incluido el plazo de 48 horas). Revísalas en septiembre de 2027.
+ *Cambio de hora*: se supone que la UE mantiene el régimen actual (último domingo de octubre a las 01:00 UTC).
+ *Puntos medios por QSO* (objetivos hipotéticos del capítulo @cap-historico): 2,0–2,1 desde Madrid.
+ *Precios*: los vistos el 20 de octubre de 2026 en las fichas de las tiendas, con IVA. WiMo y Spiderbeam muestran el IVA alemán (19 %) y no está claro si a un cliente en España le aplican el español; en Passion Radio no siempre consta si incluyen IVA. Las conversiones de dólares usan el cambio del BCE del 19 de octubre de 2026, sin envío ni impuestos de importación.
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
  [Bandas], [Nueve tramos menores del plan IARU R1, fuera de la fonía que recomienda la guía; la resolución de 1850–2000 kHz en fuente oficial y la de 2027; el estatus de cada banda en las tablas (imagen) del CNAF 2026.],
  [Trámites], [Si la sede pide planos o el permiso del propietario para la licencia de estación; si el Ayuntamiento de Madrid puede pedir una declaración responsable.],
  [Bases], [Si el Super Check Partial cuenta como asistencia: ni las bases ni la FAQ lo mencionan.],
  [Equipo], [Duración de las memorias de voz del IC-7300MK2; USB del MK2 y del FT-710 en macOS sin driver propio; radiales del AH-730 en una terraza y longitud mínima de hilo del LDG RT-100; impedancia de los chokes comerciales; IVA de WiMo para España.],
  [Software], [SkookumLogger con el CQ WW SSB y el IC-7300MK2; N1MM en Windows 11 para Arm (solo hay foros); un CTY posterior al CTY-3631.],
  [Escucha], [KiwiSDR en Japón y Sudáfrica con dirección; la disponibilidad diaria de los de la tabla.],
  [Historia], [Mejores EA, EA6, EA8 y EA9 en baja potencia y rookies EA de cada año; categoría de EA4Z en 2022.],
  [Comunidad], [Localidad de Radio Club Henares, web del EA Contest Club y dirección de r/amateurradio.],
  [Calendario], [Fechas de los concursos sin fecha publicada ni regla en sus bases (JIDX, LZ DX, SP DX, Helvetia, ARI, IOTA, EUHFC, Field Day R1, Oceania y WAG).],
)

== Créditos y licencias

- *Zonas CQ* del mapa: GeoJSON © 2024 HB9HIL, licencia MIT (texto completo en `data/geo/LICENSE-hamradio-zones-geojson.txt`) @own-hb9hil-zones. *Costas*: Natural Earth, dominio público @own-natural-earth.
- *Fichero CTY*: country-files.com (AD1C), copia VER20260603 distribuida con Not1MM @own-cty-not1mm.
- *Fuentes tipográficas*: Inter y JetBrains Mono, licencia SIL Open Font License (en `fonts/`).
- Todas las figuras y tablas calculadas son de elaboración propia con los scripts de `scripts/`.

== Cómo regenerar todo

Los pasos están en `README.md`: crea el entorno de Python (`uv venv .venv` e instala `requirements.txt`), ejecuta los scripts `calc_*`, `fig_*` y `merge_refs.py`, y compila `main.typ` y `chuleta.typ` con `typst compile --font-path fonts`.
]
