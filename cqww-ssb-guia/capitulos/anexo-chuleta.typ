#import "../plantilla.typ": *
#import "fonetica.typ": deletrear, letras, cifras

#let plan = csv("../data/calc/plan_bandas.csv", row-type: dictionary)

#let bloque(titulo, cuerpo) = block(
  width: 100%,
  stroke: 0.5pt + c.linea,
  radius: 2.5pt,
  inset: (x: 5pt, y: 4pt),
  above: 0pt,
  below: 0pt,
)[
  #text(weight: "bold", fill: c.azul-osc, size: 8.2pt)[#upper(titulo)]
  #v(-0.3em)
  #cuerpo
]

#let mini(..args) = {
  set text(size: 7.3pt)
  set par(justify: false, leading: 0.42em)
  table(
    stroke: (x, y) => (top: if y <= 1 { 0.5pt + c.tinta2 } else { 0.3pt + c.linea }, bottom: 0.5pt + c.tinta2),
    fill: (x, y) => if y == 0 { c.cab },
    inset: (x: 2.8pt, y: 2pt),
    align: left + horizon,
    ..args,
  )
}

#let chuleta(cfg) = {
  set text(size: 7.8pt)
  set par(justify: false, leading: 0.46em, spacing: 0.55em)
  set list(indent: 0.2em, body-indent: 0.35em, spacing: 0.32em)
  block(width: 100%, fill: c.azul-osc, inset: (x: 7pt, y: 5pt), radius: 2.5pt)[
    #set text(fill: white)
    #grid(
      columns: (1fr, auto),
      text(size: 11pt, weight: "bold")[CQ WW DX SSB · chuleta],
      align(right + horizon)[*#cfg.indicativo* · #cfg.locator · zona CQ *#cfg.zona-cq* · SO AB LOW (≤ 100 W) · no asistido · #cfg.overlay],
    )
  ]
  v(4pt)
  grid(
    columns: (1fr, 1fr),
    column-gutter: 5pt,
    row-gutter: 5pt,
    bloque[Horario (UTC manda)][
      #mini(
        columns: (auto, 1fr, 1fr),
        table.header([], [2026 (escucha)], [2027 (participas)]),
        [Inicio], [sáb 24 oct 00:00 UTC = 02:00 CEST], [sáb 30 oct 00:00 UTC = 02:00 CEST],
        [Cambio hora], [dom 25 oct 01:00 UTC], [dom 31 oct 01:00 UTC],
        [Fin], [dom 25 oct 23:59 UTC = lun 00:59 CET], [dom 31 oct 23:59 UTC = lun 00:59 CET],
        [Log (48 h)], [mar 27 oct 23:59 UTC], [mar 2 nov 23:59 UTC (si no cambia)],
      )
      Madrid: UTC + 2 (CEST) hasta el domingo 01:00 UTC; después UTC + 1 (CET).
    ],
    bloque[Lo que dices][
      Indicativo: #dice(deletrear(cfg.indicativo)) \
      Intercambio: #dice("five nine one four") (59 + zona #cfg.zona-cq) \
      Copia siempre *su zona*: EE. UU. 3/4/5 · VE 1–5 · UA9/UA0 17/18/19/23 · EA8/EA9/CT3 33 · JA 25 · PY 11 · LU 13 · VK 29/30.
      #v(1pt)
      *Puntos* desde EA: *0* España (sí da multiplicador) · *1* resto de Europa (EA6, CT, CU, TA1, UA1–7…) · *3* otros continentes (EA8, EA9, CT3, IG9, 4X, 5B, TA2–9, UA9…). \
      *Multiplicadores*: zona y país nuevos *en cada banda*. *Total = puntos × (zonas + países)*.
    ],
    bloque[Segmentos de SSB (España, Región 1)][
      #mini(
        columns: (auto, auto, 1fr),
        table.header([Banda], [Dónde llamar/buscar], [Ojo]),
        [160 m · LSB], [1843–1850 kHz], [1850–2000 solo con resolución temporal #text(fill: c.ambar)[(por verificar)]; nunca < 1810],
        [80 m · LSB], [3600–3650, 3700–3800], [deja libre 3760; Norteamérica transmite > 3800 (escucha en split)],
        [40 m · LSB], [7060–7100, 7130–7200], [*nunca > 7200*; deja libre 7110],
        [20 m · USB], [14125–14300], [evita 14190–14200 (DXpediciones) y 14300],
        [15 m · USB], [21151–21450], [deja libre 21360],
        [10 m · USB], [28320–29000], [la actividad se concentra en la parte baja],
      )
      Segmentos «preferentes para concursos» del plan IARU R1 #text(fill: c.ambar)[(por verificar)] dentro de las atribuciones españolas.
    ],
    bloque[Plan de bandas (UTC, orientativo)][
      #mini(
        columns: (auto, 1fr),
        table.header([UTC], [Prioridad]),
        ..plan.map(r => (r.utc, r.chuleta)).flatten(),
      )
    ],
    bloque[S&P (casi todo tu concurso)][
      + Escucha: indicativo completo; ¿duplicado? ¿multiplicador?
      + Espera a su #dice("thank you / QRZ").
      + Llama *una vez*: #dice(deletrear(cfg.indicativo)).
      + Él: #dice("…five nine zero five") → tú: #dice("thank you, five nine one four").
      + Registra al oír su #dice("thank you"). Si no te oye tras 3–4 llamadas, sigue y vuelve más tarde.
      *Frases*: #dice("call again?") · #dice("zone again?") · #dice("correction, …") (si copió mal tu indicativo).
    ],
    bloque[Run (cuando te contestan)][
      #dice("CQ contest, " + deletrear(cfg.indicativo) + ", contest") \
      Él: #dice("Delta Lima…") → tú: #dice("Delta Lima…, five nine one four") → él: #dice("thank you, five nine one four") → tú: #dice("thank you, " + cfg.indicativo).
      #v(1pt)
      Antes: escucha 10–20 s y #dice("is this frequency in use?"). Indicativo cada QSO (máx. 3 seguidos sin él). Si tras 8–10 CQ nadie contesta, vuelve a S&P.
    ],
    bloque[Hazte oír con 100 W][
      - Llama justo cuando acaba su QSO; una vez, completo. Deja huecos.
      - 3–4 intentos y sigue; vuelve en 10–15 min o en otra banda.
      - Desplázate 100–200 Hz si hay muchos llamando en su frecuencia.
      - Domingo por la tarde: todos buscan QSO nuevos. Es tu momento.
      - Procesador moderado, ALC sin disparar, micro cerca de la boca.
    ],
    bloque[Cuándo cambiar de banda][
      - Al abrir una banda alta (mañana) o al cerrar (ocaso): muévete con ella.
      - Si llevas 10–15 min sin un QSO nuevo, prueba otra banda.
      - Cada banda tiene sus propios multiplicadores: un K o un JA nuevos en 15 m valen tanto como en 20 m.
      - De noche, 40 m es la banda de multiplicadores; visita 80/160 m cada hora.
    ],
    bloque[Prohibido / penaliza][
      - Cluster o cualquier ayuda que dé indicativos (→ asistido). Autoanunciarse.
      - Concertar QSO por teléfono/internet; corregir el log después.
      - Transmitir > 7200 kHz (40 m) o < 1810 kHz.
      - *Bust/NIL*: QSO eliminado y *−2 × sus puntos*. Duplicado o zona errónea: eliminado sin penalización.
      - Señal ancha (procesador/ALC excesivos). Más de 100 W.
    ],
    bloque[Después: el log][
      - Cabrillo con `CONTEST: CQ-WW-SSB`, `SINGLE-OP`, `ALL`, `LOW`, `NON-ASSISTED`, `CATEGORY-OVERLAY: ROOKIE`, `LOCATION: DX`.
      - #raw("SOAPBOX: ROOKIE - date first licensed: " + cfg.fecha-licencia)
      - Subir en *cqww.com/logcheck* en 48 h. Esperar el correo de confirmación.
      - QSO dudoso o fuera de licencia: `X-QSO:` (no borrarlo).
    ],
  )
  v(5pt)
  bloque[Notas (aperturas, zonas, ruido)][
    #mini(
      columns: (auto, auto, 1fr, auto, 1fr),
      table.header([UTC], [Banda], [Qué oigo / trabajo (zonas, continentes)], [Señal], [Notas]),
      ..range(0, 7).map(_ => ([#h(2.2em)#v(1.05em)], [#h(2.4em)], [], [#h(2.4em)], [])).flatten(),
    )
  ]
  v(5pt)
  bloque[Alfabeto fonético UIT][
    #set text(size: 7.4pt)
    #grid(
      columns: (1fr,) * 9,
      row-gutter: 2.5pt,
      ..letras.pairs().map(((k, v)) => [*#k* #v]),
      ..range(0, 10).map(i => [*#i* #cifras.at(str(i))]),
    )
  ]
}
