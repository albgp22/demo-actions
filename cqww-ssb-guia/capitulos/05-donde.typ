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

Dentro de lo que permite la licencia española (capítulo @cap-legal), el plan de bandas de la IARU Región 1, de uso obligado «como norma general», reserva estos tramos a la fonía. Es el plan vigente, del 16 de octubre de 2020 y revisado en 2021 @verl-iaru-r1-hf-bandplan; como su tabla no se pudo leer, los segmentos se contrastaron con su texto de 2016 y con el historial de cambios, que no toca la fonía @verl-iaru-r1-hf-managers-handbook-v9. Los límites españoles están verificados en el BOE.

#figure(
  caption: [Dónde operar SSB en el CQ WW desde España. Columna IARU R1: segmentos «preferentes para concursos» en 80, 40 y 20 m; en 160, 15 y 10 m, el tramo de fonía.],
  tabla(
    columns: (auto, 1.25fr, 1fr, 2.3fr),
    table.header([Banda], [Límites en España (kHz)], [SSB según IARU R1 (kHz)], [Ojo]),
    [160 m (LSB)], [1810–1850 (1850–2000 solo con resolución temporal)], [1843–2000], [Fonía permanente en España: dial de 1843 (el mínimo del plan para LSB) a 1850 kHz. Nunca por debajo de 1810 (bases).],
    [80 m (LSB)], [3500–3800], [3600–3650 y 3700–3800], [Deja libre 3760 (emergencias en R1). Evita 3650–3700. 3775–3800 tiene prioridad para el DX intercontinental: para Europa, mejor 3700–3775. Norteamérica transmite también por encima de 3800: escúchalos ahí y llámalos desde tu segmento.],
    [40 m (LSB)], [7000–7200], [7060–7100 y 7130–7200], [*Nunca por encima de 7200* (bases y licencia). Deja libre 7110 (emergencias). Es habitual que los norteamericanos transmitan en 7200–7300 y escuchen por debajo de 7200.],
    [20 m (USB)], [14000–14350], [14125–14300], [14190–14200 tiene prioridad para DXpediciones (dejarlo libre es cortesía). 14300–14350 queda fuera del segmento preferente (14300: emergencias). El dial, como mucho, en 14347.],
    [15 m (USB)], [21000–21450], [21151–21450], [Deja libre 21360 (emergencias).],
    [10 m (USB)], [28000–29700], [28320–29000], [No uses la zona de balizas (28190–28225) ni la de FM y satélites (> 29000).],
  ),
) <tab-segmentos>

#figure(
  placement: auto,
  image("../assets/segmentos_bandas.pdf", width: 100%),
  caption: [Las seis bandas del CQ WW, cada una a su escala: usos del plan IARU Región 1, segmentos preferentes de concursos, centros de actividad que hay que dejar libres y la fonía que puedes usar desde España. Atribución: Orden IET/1311/2013, anexo I. Usos: plan de bandas HF de la IARU R1 de 2020, revisado en 2021 @verl-iaru-r1-hf-bandplan. Elaboración propia (`scripts/fig_segmentos.py`).],
) <fig-segmentos>

#importante[Por debajo de 10 MHz se usa *LSB* y por encima *USB*. Si oyes «patos», cambia de banda lateral. En LSB tu señal ocupa los 3 kHz *por debajo* de la frecuencia del dial: no te acerques a los bordes (@fig-banda-lateral).]

#figure(
  image("../assets/banda_lateral.pdf", width: 100%),
  caption: [El dial marca la portadora suprimida y la voz ocupa de 0,3 a 2,7 kHz por debajo (LSB) o por encima (USB). Junto a un borde, toda la señal tiene que quedar dentro: en 40 m, dial hasta 7200,0 kHz; en la fonía de 160 m en España, entre 1843,0 (el dial LSB mínimo del plan IARU) y 1850,0; en 20 m, hasta ≈ 14 347 (el plan pide quedarse 3 kHz por debajo del borde). Elaboración propia (`scripts/fig_banda_lateral.py`).],
) <fig-banda-lateral>

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
  placement: auto,
  image("../assets/ventanas_bandas.pdf", width: 100%),
  caption: [Horas UTC de apertura desde Madrid hacia cada destino el 25 de octubre de 2026: en 10, 15 y 20 m, cuando la MUF del trayecto corto supera la banda (modelo IRI vía PyIRI, F10.7 = 120); en 40, 80 y 160 m, cuando es de noche en todo el trayecto (24 de octubre). La barra oscura fina muestra 10 y 15 m con F10.7 = 100, la previsión para 2027. La fila de Madrid está en CEST (sábado); el domingo, réstale una hora. Cálculo propio (`scripts/fig_ventanas_bandas.py`).],
) <fig-ventanas>

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

#fuentes("legal-orden-iet-1311-2013", "verl-iaru-r1-hf-bandplan", "verl-iaru-r1-hf-managers-handbook-v9", "rules-cqww-2026", "own-astral")
]
