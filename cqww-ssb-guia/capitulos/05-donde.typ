#import "../plantilla.typ": *
#import "fonetica.typ": deletrear

#let plan = csv("../data/calc/plan_bandas.csv", row-type: dictionary)
#let noche = csv("../data/calc/ventanas_noche.csv", row-type: dictionary)
#let muf = csv("../data/knowledge/muf_ventanas.csv", row-type: dictionary)
#let ventana(dest, banda, f107: "120", texto: false) = {
  let r = muf.filter(r => r.destino == dest and r.banda == banda and r.f107 == f107 and r.fecha == "2026-10-25" and r.trayecto == "SP")
  let v = if r.len() == 0 { "-" } else { r.first().ventanas_utc_muf_sobre_umbral }
  if v == "-" { if texto { "no abre" } else { "—" } } else { v.replace("-", "–") + if texto { " UTC" } else { "" } }
}

#let capitulo(cfg) = [
= Dónde y cuándo buscar contactos <cap-donde>

== Segmentos de SSB por banda <sec-segmentos>

Dentro de lo que permite la licencia española (capítulo @cap-legal), el plan de bandas de la IARU Región 1, de uso obligado «como norma general», reserva estos tramos a la fonía. Los valores del plan IARU están #pv en el documento vigente de la IARU R1; los límites españoles sí están verificados en el BOE.

#figure(
  caption: [Dónde operar SSB en el CQ WW desde España. Columna IARU R1: segmentos «preferentes para concursos» en 80, 40 y 20 m; en 160, 15 y 10 m, el tramo de fonía.],
  tabla(
    columns: (auto, 1.25fr, 1fr, 2.3fr),
    table.header([Banda], [Límites en España (kHz)], [SSB según IARU R1 (kHz) #pv], [Ojo]),
    [160 m (LSB)], [1810–1850 (1850–2000 solo con resolución temporal #pv)], [1843–2000], [En España la fonía permanente se reduce a 1843–1850 kHz. Nunca por debajo de 1810 (bases).],
    [80 m (LSB)], [3500–3800], [3600–3650 y 3700–3800], [Deja libre 3760 (emergencias en R1). Evita 3650–3700. Norteamérica transmite también por encima de 3800: escúchalos ahí y llámalos desde tu segmento.],
    [40 m (LSB)], [7000–7200], [7060–7100 y 7130–7200], [*Nunca por encima de 7200* (bases y licencia). Deja libre 7110 (emergencias). Es habitual que los norteamericanos transmitan en 7200–7300 y escuchen por debajo de 7200.],
    [20 m (USB)], [14000–14350], [14125–14300], [Evita 14190–14200 (prioridad DXpediciones) y 14300–14350 (14300: emergencias).],
    [15 m (USB)], [21000–21450], [21151–21450], [Deja libre 21360 (emergencias).],
    [10 m (USB)], [28000–29700], [28320–29000], [No uses la zona de balizas (28190–28225) ni la de FM y satélites (> 29000).],
  ),
) <tab-segmentos>

#importante[Por debajo de 10 MHz se usa *LSB* y por encima *USB*. Si oyes «patos», cambia de banda lateral. En LSB tu señal ocupa los 3 kHz *por debajo* de la frecuencia del dial: no te acerques a los bordes.]

== Plan horario: qué banda y hacia dónde

La tabla siguiente es un plan *orientativo* para el fin de semana desde #cfg.qth. Cada recomendación está comprobada con dos cálculos (`scripts/calc_plan_bandas.py`):

- *10, 15 y 20 m*: ventanas en que la MUF básica del trayecto supera la banda, con el modelo de ionosfera IRI y un flujo solar F10.7 = 120 (`scripts/know_muf.py`, apartado @sec-ciclo para el estado real del Sol).
- *40, 80 y 160 m*: horas en que todo el trayecto está de noche (`scripts/calc_ventanas.py`).

El modelo no incluye la absorción, la esporádica E ni la variabilidad de cada día (la MUF real puede apartarse ±15–20 % de la mediana). *Lo que oigas en la radio manda sobre la tabla.*

#figure(
  caption: [Plan de bandas por franjas UTC. Hora de Madrid: el sábado es UTC+2 (CEST); el domingo, desde las 01:00 UTC, UTC+1 (CET).],
  tabla(
    columns: (auto, auto, auto, 1fr),
    table.header([UTC], [Madrid sáb], [Madrid dom], [Prioridad]),
    ..plan.map(r => (strong(r.utc), r.madrid_sabado_cest, r.madrid_domingo_cet, r.recomendacion)).flatten(),
  ),
) <tab-plan>

=== Ventanas calculadas por destino

#figure(
  caption: [Ventanas (UTC) por destino. En 10/15/20 m, MUF básica por encima de la banda (F10.7 = 120, 25 oct 2026, trayecto corto). En 40/80/160 m, todo el trayecto de noche (24 oct 2026).],
  tabla(
    columns: (auto, auto, auto, auto, auto),
    table.header([Destino], [10 m], [15 m], [20 m], [40/80/160 m]),
    ..noche.map(r => (
      [#r.destino #text(fill: c.tinta2, size: 0.9em)[(#r.etiqueta)]],
      ventana(r.destino, "10 m"), ventana(r.destino, "15 m"), ventana(r.destino, "20 m"),
      r.noche_en_todo_el_trayecto_utc.replace("-", "–"),
    )).flatten(),
  ),
) <tab-ventanas>

El flujo solar cambia mucho las bandas altas. Con F10.7 = 100, la ventana de 10 m hacia Nueva York se acorta a #ventana("Nueva York", "10 m", f107: "100", texto: true) y hacia Chicago #ventana("Chicago", "10 m", f107: "100", texto: true); con F10.7 = 140, 10 m hacia Chicago abre de #ventana("Chicago", "10 m", f107: "140", texto: true). Consulta el flujo del día (capítulo @cap-herramientas) y ajusta. Para 2027 (previsión F10.7 ≈ 98), el apartado «Qué cambia en 2027» del capítulo @cap-supuestos lista las recomendaciones que el modelo deja sin respaldo: sobre todo, 10 m hacia Norteamérica.

== Dónde y cuándo aparecen los multiplicadores

- *Europa da los países*: hay decenas de entidades europeas a 1 punto, y casi todas están activas. Por la mañana y por la tarde, en 40 m; a mediodía, en 20 m; de noche, en 80 m. Muchas valen multiplicador en *cada* banda.
- *Las zonas difíciles* desde aquí son las del Pacífico y el norte de Asia: 1 (Alaska y el noroeste de Canadá), 2 (el norte de Quebec y Labrador), 19 (Rusia oriental), 23 (Mongolia, oeste de China y sur de Siberia), 31 (Hawái) y 32 (Nueva Zelanda y el Pacífico sur). Aparecen en ventanas cortas: la línea gris (apartado @sec-propagacion), las aperturas de 20 m por la mañana hacia Asia y las de 15/20 m por la tarde hacia el Pacífico.
- *Las bandas altas abiertas* (10 y 15 m) dan Sudamérica, el Caribe y África, con muchos países en pocas horas.
- *Las DXpediciones de concurso* (estaciones que viajan a un país raro para el fin de semana) suelen trabajar en varias bandas: si una no te oye en 20 m, búscala en 15 o 40 m.

== Cuándo cambiar de banda

+ *Cuando abre una banda más alta*, sube: por la mañana, de 40 a 20 y luego a 15 y 10 m. Los primeros minutos de una apertura son los de menos competencia.
+ *Cuando una banda se apaga*, baja: al ocaso, de 10/15 a 20 y luego a 40 m.
+ *Si llevas 10–15 minutos sin un QSO nuevo*, cambia. En S&P, una banda «agotada» no da más.
+ *En las horas de la línea gris* (orto y ocaso en Madrid), pasa por 40 y 80 m aunque te vaya bien arriba.
+ *De noche*, 40 m es la banda de los multiplicadores; asómate a 80 y 160 m cada hora.

#fuentes("legal-orden-iet-1311-2013", "legal-iaru-r1-hf-bandplan", "rules-cqww-2026", "own-astral")
]
