#import "../plantilla.typ": *
#import "fonetica.typ": deletrear

#let caja-lista(titulo, cuerpo) = block(
  width: 100%,
  stroke: 0.6pt + c.linea,
  radius: 3pt,
  inset: (x: 8pt, y: 6pt),
  breakable: false,
)[#set par(justify: false); #text(weight: "bold", fill: c.azul-osc)[#titulo] #v(-0.2em) #cuerpo]

#let capitulo(cfg) = [
= Listas de comprobación y solución de problemas <cap-checklists>

Marca cada casilla. Están pensadas para el CQ WW SSB 2027, pero sirven para cualquier concurso de fonía.

#set list(marker: [☐])
#grid(
  columns: (1fr, 1fr),
  column-gutter: 10pt,
  row-gutter: 8pt,
  caja-lista[Semanas antes][
    - Licencia e indicativo en vigor; #cfg.indicativo sustituido en `main.typ` y en el logger.
    - Leer las bases del año (salen en septiembre) y la entrada de cambios del blog de cqww.com.
    - Estación probada a 100 W en las seis bandas: ROE, acoplador, ausencia de RF en el cuarto y de interferencias a los vecinos (capítulo @cap-equipo).
    - Logger instalado, con la plantilla CQ-WW-SSB, tu zona (#cfg.zona-cq), categoría y overlay ROOKIE.
    - CAT funcionando: el logger lee la frecuencia y el modo.
    - Mensajes del voice keyer grabados y probados (CQ, indicativo, intercambio, #dice("again?"), #dice("thank you")).
    - Practicar con un simulador o en un concurso pequeño con el mismo montaje.
    - Imprimir la chuleta y el plan de bandas.
  ],
  caja-lista[El día antes][
    - Actualizar el fichero CTY y el Super Check Partial a la última versión.
    - Reloj del ordenador sincronizado (UTC en el logger).
    - Potencia medida ≤ 100 W en todas las bandas (con la ALC sin disparar).
    - Filtro de RX de SSB (≈ 2,4–2,7 kHz), AGC, NB/NR, procesador y ganancia de micro ajustados.
    - Copia de seguridad del log configurada (o guardado automático).
    - Previsión: índices solares y del campo geomagnético (capítulo @cap-herramientas).
    - Plan de descansos y comida; aviso en casa del horario.
  ],
  caja-lista[Durante el concurso][
    - Empieza a las 00:00 UTC del sábado (02:00 en Madrid).
    - Cada hora: ¿la banda en la que estoy es la mejor ahora? (capítulo @cap-donde).
    - Cada QSO: indicativo *completo* y zona copiados; si dudas, pregunta.
    - El domingo a las 01:00 UTC cambia la hora local: el log sigue en UTC.
    - Nada de cluster ni webs de spots (categoría no asistida).
    - Bebe agua, levántate cada 2–3 horas.
    - El domingo por la tarde, S&P a todo lo que oigas: cada QSO cuenta.
    - Anota incidencias para el SOAPBOX (equipo, propagación, anécdotas).
  ],
  caja-lista[Después (48 horas)][
    - Exportar el Cabrillo y revisar la cabecera: `CONTEST: CQ-WW-SSB`, `CATEGORY-OPERATOR: SINGLE-OP`, `CATEGORY-ASSISTED: NON-ASSISTED`, `CATEGORY-BAND: ALL`, `CATEGORY-POWER: LOW`, `CATEGORY-OVERLAY: ROOKIE`, `LOCATION: DX`, `EMAIL:`.
    - En `SOAPBOX:`, la fecha de tu primera licencia (obligatoria para ROOKIE).
    - QSO dudosos o fuera de licencia: márcalos como `X-QSO:`, no los borres.
    - Subirlo en #url("https://cqww.com/logcheck/") antes de las 23:59 UTC del martes (48 h tras el final).
    - Comprobar que llega el correo con número de seguimiento.
    - Opcional: publicar la puntuación reclamada y tu soapbox en 3830scores.com.
    - Apuntar lo aprendido para el año siguiente (capítulo @cap-escucha-2026).
  ],
)

#set list(marker: [•])
== Solución de problemas típicos

#tabla(
  columns: (1fr, 1.5fr),
  table.header([Síntoma], [Qué comprobar]),
  [El logger no lee la frecuencia (sin CAT)], [Cable USB (no todos llevan datos), driver del puerto serie en macOS, puerto y velocidad (baudios) iguales en radio y logger, que ningún otro programa tenga abierto el puerto.],
  [El voice keyer no sale al aire], [Salida de audio del Mac hacia el códec USB de la radio, nivel de entrada en la radio (menú de USB MOD/DATA), PTT por CAT o VOX, y modo de la radio (USB/LSB, no DATA).],
  [Al transmitir se cuelga el USB, salta el ratón o se oye audio raro], [RF en el cuarto: chokes de modo común en el coaxial (en la antena y a la entrada de casa), ferritas en USB y alimentación, toma de tierra; baja potencia para confirmar (capítulo @cap-equipo).],
  [ROE alta en una banda], [Memoria del acoplador para esa banda, conectores, coaxial; en una EFHW, la longitud y el contrapeso. Nunca transmitas a plena potencia con ROE alta.],
  [Nadie te contesta], [¿Potencia real a la salida? ¿Antena conectada (conmutador)? ¿Estás en *split* sin querer (VFO B, RIT/XIT activados)? ¿Te oyes en un receptor web? (capítulo @cap-escucha-2026).],
  [Mucho ruido de recepción], [Prueba a quitar alimentadores de casa (cargadores, LED, routers); NB/NR con moderación; una antena de RX alejada; escucha en otra banda.],
  [El log tiene horas raras], [Zona horaria del ordenador y del logger; la hora del log debe ser UTC. No corrijas horas a mano después.],
  [El robot de cqww.com rechaza el log], [Que empiece por `START-OF-LOG:`, que el concurso sea `CQ-WW-SSB` (sin año), categorías válidas y fecha de licencia en el SOAPBOX.],
)

#fuentes("rules-cqww-2026", "rules-cqww-logcheck", "rules-cqww-cabrillo", "rules-cqww-faq")
]
