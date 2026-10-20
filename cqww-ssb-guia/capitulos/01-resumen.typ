#import "../plantilla.typ": *
#import "fonetica.typ": deletrear

#let capitulo(cfg) = [
= Resumen: lo esencial en una página <cap-resumen>

#set par(spacing: 0.7em)
#let punto(t, cuerpo) = block(below: 0.62em)[#text(fill: c.azul-osc, weight: "bold")[#t] #h(0.3em) #cuerpo]

#punto[Qué es.][48 horas para contactar con el mayor número posible de estaciones, *zonas CQ y países* de todo el mundo, en 160, 80, 40, 20, 15 y 10 m, en fonía (SSB). Un QSO es solo *indicativo + 59 + zona*: dura segundos.]

#punto[Cuándo.][*2026* (solo escuchas): del *sábado 24 de octubre a las 00:00 UTC* (02:00 en Madrid) al *domingo 25 a las 23:59 UTC* (lunes 26 a las 00:59 en Madrid). El domingo a las 01:00 UTC se pasa de CEST a CET: piensa siempre en UTC. *2027* (participas): 30–31 de octubre.]

#punto[Qué dices.][Tu indicativo con fonética: #dice(deletrear(cfg.indicativo)). Tu intercambio: #dice("five nine one four") (59 + zona #cfg.zona-cq). Ellos te darán 59 y su zona: *copia la zona*.]

#punto[Cómo puntúa.][Cada QSO vale *3 puntos* si es con otro continente, *1* si es con otro país de Europa y *0* si es con España (pero da multiplicador). *Ojo*: EA8, EA9, CT3 e IG9 son África (3 puntos); EA6, CU y TA1 son Europa (1 punto). Multiplicadores: cada *zona* y cada *país* nuevo *en cada banda*. *Total = puntos × (zonas + países)*.]

#punto[Tu categoría.][*Single Operator, All Band, Low Power* (≤ 100 W), *no asistido*, con overlay *ROOKIE*: primera licencia hace menos de 3 años; pon la fecha en el `SOAPBOX` del log.]

#punto[Prohibido.][Usar el DX cluster o cualquier cosa que te dé indicativos (si no, pasas a asistido); autoanunciarte; concertar QSO por teléfono o internet; transmitir en 40 m por encima de 7200 kHz o por debajo de 1810 kHz; corregir el log después con bases de datos o grabaciones.]

#punto[El log.][Formato *Cabrillo*, subido en #url("https://cqww.com/logcheck/") *en 48 horas* (en 2026, hasta el 27 de octubre a las 23:59 UTC). Un indicativo mal copiado o un QSO que no está en el log del otro se elimina y *te resta el doble de sus puntos*. Los duplicados no penalizan.]

#punto[Dónde y cuándo.][*10 y 15 m* de día (hacia América, de 11 a 17 UTC aprox.); *20 m*, casi todo el día; *40 m* de día para Europa y de noche para el DX; *80 y 160 m* de noche. Al amanecer y al anochecer, línea gris en las bandas bajas. Detalle por horas en el capítulo @cap-donde.]

#punto[Cómo.][Casi todo en *search & pounce*: escucha, espera tu turno, di tu indicativo *una vez y completo*, copia la zona, contesta #dice("thank you, five nine one four") y registra. Con 100 W, el *timing* vale más que la insistencia. El domingo por la tarde todo el mundo quiere tu QSO.]

#punto[Este fin de semana.][Escucha en receptores web cercanos y lejanos y con tu RTL-SDR V4; practica el copiado de indicativo + zona y anota bandas, horas y zonas que oyes (capítulo @cap-escucha-2026).]

#punto[Para 2027.][Licencia e indicativo (capítulo @cap-legal); estación de 100 W con antena de terraza y cascos con micro (@cap-equipo); logger en el Mac con voice keyer, CTY y Super Check Partial (@cap-herramientas); práctica en concursos pequeños, empezando por el ARRL 10 m del 12–13 de diciembre de 2026 (@cap-entrenamiento); y las listas del capítulo @cap-checklists.]

#let cifra(valor, etiqueta) = block(
  width: 100%, inset: (x: 7pt, y: 6pt), radius: 3pt, fill: c.cab,
)[#set par(justify: false); #text(size: 15pt, weight: "semibold", fill: c.azul-osc)[#valor] \ #text(size: 7.6pt, fill: c.tinta2)[#etiqueta]]
#v(0.4em)
#grid(
  columns: (1fr,) * 4,
  column-gutter: 6pt,
  row-gutter: 6pt,
  cifra[48 h][de 00:00 UTC del sábado a 23:59 UTC del domingo],
  cifra[6 bandas][160, 80, 40, 20, 15 y 10 m; nada de WARC],
  cifra[40 + 346][zonas CQ y países (340 DXCC + 6 extra)],
  cifra[59 #cfg.zona-cq][tu intercambio desde #cfg.qth],
  cifra[≤ 100 W][baja potencia (Low Power)],
  cifra[0 · 1 · 3][puntos: España · Europa · otros continentes],
  cifra[48 h][para subir el log Cabrillo],
  cifra[−2×][puntos del QSO por bust o NIL],
)
#v(0.3em)
#importante[Si solo vas a imprimir una página, imprime la chuleta del anexo (también está en `chuleta.pdf`).]
]
