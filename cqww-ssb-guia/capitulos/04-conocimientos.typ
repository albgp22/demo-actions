#import "../plantilla.typ": *
#import "fonetica.typ": deletrear, letras, cifras

#let orto = csv("../data/calc/orto_ocaso.csv", row-type: dictionary)
#let rumbos = csv("../data/knowledge/muf_rumbos.csv", row-type: dictionary)
#let rb(d) = rumbos.find(r => r.destino == d)
#let sp(d) = [#rb(d).rumbo_sp_grados° y #miles(rb(d).distancia_sp_km) km]

#let capitulo(cfg) = [
= Conocimientos básicos <cap-conocimientos>

== UTC: la única hora que existe en un concurso

Las bases, el log y los demás operadores usan *UTC*. Pon un reloj en UTC delante de la radio y configura el logger para que registre en UTC (casi todos lo hacen a partir del reloj del ordenador; en macOS, deja activada la hora automática para que se sincronice por red).

En Madrid, UTC = hora local − 2 h en verano (CEST) y − 1 h en invierno (CET). El cambio de CEST a CET cae siempre *dentro* del CQ WW SSB: es el último domingo de octubre a las 01:00 UTC, y el concurso se celebra el último fin de semana completo de octubre (capítulo @cap-que-es). En UTC no pasa nada: el log sigue sin saltos ni horas repetidas.

== Zonas CQ <sec-zonas>

El mundo está dividido en 40 zonas CQ. Cada zona distinta que trabajas en cada banda es un multiplicador, y tu zona es la mitad de tu intercambio. Madrid está en la *zona 14* (Europa occidental); la zona ITU (37) no se usa en este concurso.

#figure(
  image("../assets/mapa_zonas_cq.pdf", width: 100%),
  caption: [Las 40 zonas CQ. Madrid (estrella) está en la zona 14 (sombreada). Polígonos de zonas: HB9HIL, licencia MIT @own-hb9hil-zones; costas: Natural Earth, dominio público @own-natural-earth; proyección Equal Earth @own-equal-earth. Elaboración propia (`scripts/fig_mapa_zonas.py`).],
) <fig-zonas>

#tabla(
  columns: (auto, 1fr),
  table.header([Zona], [Entidades (prefijo principal) según el fichero CTY]),
  [*14*], [EA, EA6, CT, CU, F, DL, G, GD, GI, GJ, GM, GM/s, GU, GW, EI, ON, PA, LX, HB, HB0, OZ, OY, LA, SM, C3, 3A, ZB, 4U1I],
  [15], [I, IS, IT9, 9H, 1A, HV, T7, OE, 4U1V, HA, OK, OM, SP, S5, 9A, E7, Z3, Z6, 4O, YU, ZA, OH, OH0, OJ0, ES, YL, LY, UA2],
  [16], [UA (Rusia europea), UR, EU, ER],
  [20], [SV, SV5, SV9, SV/a, LZ, YO, TA, TA1, 4X, 5B, ZC4, OD, YK, JY, E4],
  [33], [EA8, EA9, CT3, CN, 7X, 3V, IG9, S0],
  [40], [TF, OX, JW, JW/b, JX, R1FJ],
)
Tabla obtenida del fichero CTY (versión VER20260603) con `scripts/ctylib.py`: es la zona por defecto de cada entidad. Algunos países grandes tienen varias zonas (EE. UU. 3, 4 y 5; Canadá 1 a 5; Rusia asiática 17, 18, 19 y 23; China 23 y 24; Australia 29 y 30): en ellos, *copia siempre la zona que te dan*.

== Países: DXCC, WAE e IG9/IH9 <sec-paises>

Un «país» del CQ WW es una entidad de la lista *DXCC* de la ARRL, más las entidades de la lista *WAE* del DARC que no son DXCC, más IG9/IH9 (África italiana). En el fichero CTY usado aquí son 346 entidades: las 340 DXCC actuales más 6 extra: IT9 (Sicilia), GM/s (Shetland), JW/b (isla del Oso), 4U1V (Centro Internacional de Viena), TA1 (Turquía europea) e IG9/IH9 (África italiana).

Desde Madrid hay varios «países» a la vuelta de la esquina que conviene tener claros: *EA6* (Baleares), *EA8* (Canarias), *EA9* (Ceuta y Melilla), *CT3* (Madeira), *CU* (Azores), *C3* (Andorra), *ZB* (Gibraltar), *3A* (Mónaco), *IT9* (Sicilia) e *IS* (Cerdeña). En el Reino Unido, G, GM, GW, GI, GD (isla de Man), GJ (Jersey) y GU (Guernsey) son países distintos.

== Continentes: de qué dependen los puntos <sec-continentes>

Los puntos de cada QSO dependen del continente (apartado @sec-puntos). El continente es el que asigna el fichero CTY, que no siempre coincide con la geografía «escolar»:

- *África*: EA8, EA9, CT3 (Madeira), IG9/IH9, CN, 3V, 7X, S0. Desde Madrid valen 3 puntos.
- *Europa*: CU (Azores), TF, JW, TA1, UA1–UA7 (Rusia europea, incluido UA2). Valen 1 punto.
- *Asia*: TA (Turquía asiática), 4X, 5B (Chipre), OD, UA9/UA0 (Rusia asiática). Valen 3 puntos.
- *Norteamérica*: OX (Groenlandia), además de EE. UU., Canadá, México, Centroamérica y el Caribe.

== Propagación a finales de octubre desde Madrid <sec-propagacion>

=== Lo que hay que saber de cada banda

- *10 y 15 m* son bandas de *día*: abren cuando el trayecto está iluminado y cierran poco después del ocaso. Dependen mucho del ciclo solar (apartado @sec-ciclo).
- *20 m* es la banda «comodín»: abierta casi todo el día y parte de la noche. Es la más concurrida.
- *40 m* funciona de día con Europa y de noche con el resto del mundo. De noche es la banda que más multiplicadores da.
- *80 y 160 m* son bandas de *noche*: el trayecto tiene que estar a oscuras. Con una antena de terraza son las más difíciles; cada QSO lejano en ellas es un premio.

La *MUF* (frecuencia máxima utilizable) sube con el Sol: por la mañana suben las bandas altas, a mediodía están en su mejor momento hacia el sur, y al anochecer «bajan» hacia 40 y 80 m.

=== Rumbos y distancias desde Madrid

En un mapa acimutal centrado en Madrid (@fig-azimutal), cada recta que sale del centro es el *camino corto* (el arco de círculo máximo): su ángulo es el rumbo al que apuntaría una antena directiva y su longitud, la distancia real. Con una vertical o una EFHW no orientas nada, pero el mapa explica el concurso:

- *Europa está cerca*: casi toda a menos de 3.000 km, el alcance típico de 40 m de día. Dakar (6W) está a #miles(rb("Dakar").distancia_sp_km) km.
- *Cada apertura tiene su rumbo*: Nueva York a #sp("Nueva York"), Los Ángeles a #sp("Los Ángeles"), São Paulo a #sp("São Paulo"), Johannesburgo a #sp("Johannesburgo") y Tokio a #sp("Tokio"), por encima de Siberia.
- *El camino largo* sale en el rumbo opuesto. Hacia Sídney, el corto es de #sp("Sídney"); el largo, de #miles(rb("Sídney").distancia_lp_km) km a #rb("Sídney").rumbo_lp_grados°.

#figure(
  placement: auto,
  image("../assets/mapa_azimutal.pdf", width: 86%),
  caption: [Mapa acimutal equidistante centrado en Madrid: cada recta desde el centro es el camino corto; su ángulo es el rumbo y su longitud, la distancia. El borde del disco es la antípoda (Nueva Zelanda), por eso allí la tierra se estira. Costas: Natural Earth, dominio público @own-natural-earth; destinos de `data/knowledge/muf_rumbos.csv`. Elaboración propia (`scripts/fig_azimutal.py`).],
) <fig-azimutal>

=== Luz y oscuridad durante el concurso

#figure(
  placement: auto,
  image("../assets/luz_oscuridad_2026.pdf", width: 100%),
  caption: [Día, crepúsculo y noche (UTC) en Madrid y en destinos típicos el sábado 24 de octubre de 2026 (el domingo es prácticamente igual). Cálculo propio con el algoritmo solar de la NOAA (librería astral @own-astral), `scripts/fig_luz_greyline.py`.],
) <fig-luz>

Cómo leer la @fig-luz: las bandas altas funcionan con trayectos de día (zonas claras que coinciden con las de Madrid) y las bajas con trayectos de noche (zonas oscuras comunes). Por ejemplo, de 11 a 17 UTC es de día a la vez en Madrid, la costa este de EE. UU. y Sudamérica: es la ventana de 10 y 15 m hacia América. De 22 a 06 UTC es de noche entre Madrid y Norteamérica: la ventana de 40, 80 y 160 m.

#let dia = orto.filter(r => r.fecha == "2026-10-24")
#let mitad = calc.ceil(dia.len() / 2)
#let media-tabla(filas) = tabla(
  columns: (1fr, auto, auto),
  table.header([Lugar], [Orto], [Ocaso]),
  ..filas.map(r => (r.lugar, r.orto_utc, r.ocaso_utc)).flatten(),
)
#figure(
  caption: [Orto y ocaso (UTC) el sábado 24 de octubre de 2026 (`scripts/calc_tiempos.py`, librería astral).],
  block(breakable: false, grid(columns: (1fr, 1fr), column-gutter: 10pt, media-tabla(dia.slice(0, mitad)), media-tabla(dia.slice(mitad)))),
) <tab-orto>

=== La línea gris

La *línea gris* es la franja de crepúsculo que separa el día de la noche. Cuando los dos extremos de un trayecto están cerca del orto o del ocaso, la absorción en las bandas bajas es mínima y aparecen señales lejanas en 40, 80 y 160 m durante unos minutos. Desde Madrid, el 24 de octubre de 2026:

- *Al orto de Madrid (06:35 UTC)* anochece en Nueva Zelanda (ocaso en Auckland a las 06:45 UTC) y amanece en Canarias: ventana para ZL en 40/80 m por la línea gris.
- *Al ocaso de Madrid (17:21 UTC)* amanece en Nueva Zelanda (17:24 UTC) y en Alaska (17:06 UTC en Anchorage): ventana para ZL y KL7 en 40 m.

#figure(
  placement: auto,
  image("../assets/linea_gris_2026.pdf", width: 100%),
  caption: [Iluminación al orto y al ocaso de Madrid el 24 de octubre de 2026. Se marcan los destinos de la tabla anterior que tienen su orto u ocaso a menos de 40 minutos. Cálculo propio (`scripts/fig_luz_greyline.py`).],
) <fig-linea-gris>

=== El ciclo solar <sec-ciclo>

El 15 de octubre de 2024, NASA, NOAA y el panel internacional del ciclo 25 anunciaron que el Sol había entrado en su *periodo de máximo* @know-nasa-solarmax-2024. Según SILSO, el número de manchas *suavizado* tocó techo en *octubre de 2024 con 160,9*, y el mensual llegó a 216,0 en agosto de 2024, muy por encima de los 115 que preveía el panel en 2019 @know-stce-sc25-tracking. Desde entonces baja: en septiembre de 2026 el número mensual fue de 60,3 y el flujo F10.7 medio de 105; en octubre (hasta el día 18) el F10.7 medio iba por 115,5 #fecha[fuentes secundarias, #pv con SILSO]. La previsión mensual de CelesTrak da F10.7 ≈ 119 para octubre de 2026 y ≈ 98 para octubre de 2027 @hist-celestrak-sw-5y.

Qué significa para ti: *en 2026* las bandas altas aún funcionan (10 m abre hacia Norteamérica a mediodía y casi todo el día hacia Sudamérica y África); *en 2027*, con menos flujo, 10 m hacia Norteamérica quedará en unas pocas horas o cerrado y *15 m será la banda alta principal* (capítulo @cap-donde). Las tormentas geomagnéticas (Kp ≥ 5) empeoran sobre todo los trayectos polares (Japón, oeste de Norteamérica) y las bandas bajas; consulta el Kp del día en NOAA SWPC.

== Alfabeto fonético y cómo deletrear tu indicativo <sec-fonetica>

#tabla(
  columns: (auto, 1fr, auto, 1fr, auto, 1fr, auto, 1fr),
  table.header([], [Palabra], [], [Palabra], [], [Palabra], [], [Palabra]),
  ..letras.pairs().map(((k, v)) => (strong(k), v)).flatten(),
  ..range(0, 10).map(i => (strong(str(i)), cifras.at(str(i)))).flatten(),
)

Tu indicativo se dice siempre igual, letra a letra y sin inventar: *#cfg.indicativo* → #dice(deletrear(cfg.indicativo)). Las cifras se dicen en inglés. Algunos DXistas usan palabras alternativas («Kilowatt», «Japan», «Portugal»…), y oírlas no debe despistarte, pero tú usa el alfabeto de la UIT: es el que todo el mundo espera. Si te piden repetir, repite exactamente igual; cambiar de palabras a mitad de QSO confunde más.

#fuentes("own-cty-not1mm", "own-hb9hil-zones", "own-astral", "rules-cqww-2026")
]
