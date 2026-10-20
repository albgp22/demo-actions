// =====================================================================
//  Guía del CQ World Wide DX Contest (SSB)
//  Compilar:  typst compile --font-path fonts main.typ cqww-ssb-guia.pdf
//  Chuleta:   typst compile --font-path fonts chuleta.typ chuleta.pdf
// =====================================================================

// ---- Tus datos: cámbialos aquí y se actualizan en todo el documento ----
#let cfg = (
  indicativo: "EA4XXX",          // marcador hasta que tengas indicativo
  locator: "IN80",
  qth: "Madrid",
  zona-cq: 14,
  zona-itu: 37,
  continente: "Europa",
  // Categoría prevista para el CQ WW SSB 2027
  categoria: "Monooperador, todas las bandas, baja potencia (≤ 100 W), no asistido",
  overlay: "ROOKIE",
  cab-operator: "SINGLE-OP",
  cab-band: "ALL",
  cab-power: "LOW",
  cab-assisted: "NON-ASSISTED",
  cab-overlay: "ROOKIE",
  fecha-licencia: "AAAA-MM-DD",    // fecha de tu primera licencia (va en el SOAPBOX)
  nombre: "Nombre Apellido",
  email: "tu@correo.es",
  version: "20 de octubre de 2026",
)
// -----------------------------------------------------------------------

#import "plantilla.typ": *
#import "capitulos/fonetica.typ": deletrear

#show: documento.with(cfg)

// ---------------------------------------------------------------- portada
#let pastilla(t) = box(
  inset: (x: 7pt, y: 3.6pt),
  radius: 8pt,
  stroke: 0.6pt + rgb("#6da7ec"),
  text(size: 8pt, weight: "semibold", fill: white, t),
)
#let tarjeta(titulo, filas) = block(width: 100%, inset: (x: 11pt, top: 10pt, bottom: 11pt), radius: 5pt, stroke: 0.6pt + c.linea)[
  #text(size: 7pt, weight: "bold", fill: c.azul-osc, tracking: 0.12em)[#upper(titulo)]
  #v(0.15em)
  #set text(size: 8.6pt)
  #set par(leading: 0.48em)
  #grid(
    columns: (auto, 1fr),
    column-gutter: 10pt,
    row-gutter: 7.5pt,
    ..filas.map(((k, v)) => (text(size: 7.6pt, fill: c.tenue, weight: "semibold")[#k], v)).flatten(),
  )
]

#page(margin: 0pt, header: none, footer: none, background: none)[
  #set par(justify: false)
  #set text(hyphenate: false)
  // Banda superior con el mapa acimutal centrado en Madrid
  #place(top + left, rect(width: 100%, height: 17.4cm, fill: c.azul-noche))
  #place(top + left, dx: 6.6cm, dy: -1.9cm, image("assets/portada_azimutal.pdf", width: 19.6cm))
  #place(top + left, dx: 16.4cm + 7pt, dy: 7.9cm - 5pt, text(size: 7.4pt, weight: "semibold", fill: rgb("#f2a65a"))[Madrid])
  #place(top + left, dx: 2cm, dy: 2.3cm, block(width: 12.4cm)[
    #text(size: 8.6pt, weight: "bold", fill: rgb("#9ec5f4"), tracking: 0.18em)[CQ WORLD WIDE DX CONTEST · SSB]
    #v(1.1em)
    #text(font: "Inter Display", size: 34pt, weight: "bold", fill: white)[Guía práctica para escucharlo, prepararlo y participar]
    #v(1em)
    #block(width: 10.2cm, text(size: 11pt, fill: c.azul-hielo)[Manual de referencia para una estación novel en #cfg.qth: reglas, marco legal, propagación, equipo, software, técnica operativa y listas de comprobación.])
  ])
  #place(top + left, dx: 2cm, dy: 15.2cm, stack(
    dir: ltr,
    spacing: 6pt,
    pastilla[#cfg.indicativo · #cfg.locator · zona CQ #cfg.zona-cq],
    pastilla[24–25 oct 2026 · escucha],
    pastilla[30–31 oct 2027 · participa],
  ))
  // Parte inferior: tu estación y cómo usar la guía
  #place(top + left, dx: 2cm, dy: 18.6cm, block(width: 17cm, grid(
    columns: (1fr, 1fr),
    column-gutter: 12pt,
    tarjeta("Tu estación y tu plan", (
      ([Indicativo], [*#cfg.indicativo* (marcador) \ #text(size: 7.8pt, fill: c.tinta2)[#deletrear(cfg.indicativo)]]),
      ([Locator], [#cfg.locator · zona CQ *#cfg.zona-cq* · zona ITU #cfg.zona-itu · #cfg.continente]),
      ([Categoría], [#cfg.categoria, overlay *#cfg.overlay*]),
      ([2026], [24–25 oct: *solo escucha* (receptores web y RTL-SDR)]),
      ([Antes], [ARRL 10 m (12–13 dic 2026) y otros concursos pequeños]),
      ([2027], [30–31 oct: *primera participación*]),
    )),
    tarjeta("Cómo usar esta guía", (
      ([5 minutos], [Resumen (cap. 1) y la chuleta del anexo.]),
      ([Este finde], [Dónde y cuándo buscar (cap. 5) y el plan de escucha (cap. 6).]),
      ([Para 2027], [Marco legal, equipo y herramientas (caps. 8–10) y entrenamiento (cap. 12).]),
      ([En el concurso], [Chuleta, plan de bandas (cap. 5), técnica (cap. 7) y listas (cap. 14).]),
      ([Pendiente], [Lo no confirmado va marcado #pv\; lista en el cap. 17.]),
      ([Pestañas], [El número del borde derecho es el capítulo; el color, la parte.]),
    )),
  )))
  #place(bottom + left, dx: 2cm, dy: -1.5cm, block(width: 17cm)[
    #set text(size: 7.4pt, fill: c.tinta2)
    Versión del #cfg.version. Los datos que caducan (precios, versiones de software, ciclo solar) llevan su fecha; lo que no se pudo confirmar en una fuente primaria está marcado como #pv. Horarios, puntos, orto y ocaso y ventanas de propagación están calculados con los scripts de `scripts/`. Compilado con Typst 0.15.1 sin paquetes externos.
  ])
]

// ---------------------------------------------------------------- índice
#page(header: none)[
  #set par(justify: false)
  #text(font: "Inter Display", size: 22pt, weight: "bold")[Índice]
  #v(-0.6em)
  #line(length: 100%, stroke: 0.9pt + c.azul-noche)
  #v(0.5em)
  #set text(size: 8.3pt, hyphenate: false)
  #columns(2, gutter: 18pt, indice())
]

#import "capitulos/01-resumen.typ" as cap01
#import "capitulos/02-que-es.typ" as cap02
#import "capitulos/03-reglas.typ" as cap03
#import "capitulos/04-conocimientos.typ" as cap04
#import "capitulos/05-donde.typ" as cap05
#import "capitulos/06-escucha-2026.typ" as cap06
#import "capitulos/07-como.typ" as cap07
#import "capitulos/08-legal.typ" as cap08
#import "capitulos/09-equipo.typ" as cap09
#import "capitulos/10-herramientas.typ" as cap10
#import "capitulos/11-historico.typ" as cap11
#import "capitulos/12-entrenamiento.typ" as cap12
#import "capitulos/13-sin-estacion.typ" as cap13
#import "capitulos/14-checklists.typ" as cap14
#import "capitulos/15-comunidad.typ" as cap15
#import "capitulos/16-glosario.typ" as cap16
#import "capitulos/17-supuestos.typ" as cap17
#import "capitulos/anexo-chuleta.typ" as chuleta

#cap01.capitulo(cfg)
#pagebreak()
#cap02.capitulo(cfg)
#cap03.capitulo(cfg)
#cap04.capitulo(cfg)
#cap05.capitulo(cfg)
#cap06.capitulo(cfg)
#cap07.capitulo(cfg)
#cap08.capitulo(cfg)
#cap09.capitulo(cfg)
#cap10.capitulo(cfg)
#cap11.capitulo(cfg)
#cap12.capitulo(cfg)
#cap13.capitulo(cfg)
#cap14.capitulo(cfg)
#cap15.capitulo(cfg)
#cap16.capitulo(cfg)
#cap17.capitulo(cfg)

// ---------------------------------------------------------------- anexo
#counter(heading).update(0)
#set heading(numbering: "A.1")
#page(margin: (x: 1.0cm, y: 0.9cm), header: none, footer: none, background: none)[
  // título del anexo para el índice, sin ocupar sitio en la página
  #place(hide[= Chuleta de una página (también en `chuleta.pdf`) <anexo-chuleta>])
  #set text(size: 7.2pt)
  #chuleta.chuleta(cfg)
]

#set heading(numbering: none)
= Bibliografía
#set text(size: 7.6pt)
#set par(leading: 0.5em)
#bibliography("bib/referencias.yml", title: none, style: "ieee", full: false)
