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
#page(margin: (x: 2.2cm, top: 2.6cm, bottom: 2cm), header: none, footer: none)[
  #set par(justify: false)
  #set text(hyphenate: false)
  #text(size: 10pt, fill: c.azul, weight: "semibold", tracking: 0.08em)[CQ WORLD WIDE DX CONTEST · SSB]
  #v(0.6em)
  #text(size: 27pt, weight: "bold", fill: c.azul-osc)[Guía práctica para escucharlo, prepararlo y participar]
  #v(0.4em)
  #text(size: 12pt, fill: c.tinta2)[Manual de referencia para una estación novel en #cfg.qth: reglas, marco legal, propagación, equipo, software, técnica operativa y listas de comprobación.]
  #v(1.6em)
  #block(width: 100%, fill: c.cab, inset: 12pt, radius: 4pt)[
    #set text(size: 9.5pt)
    #grid(
      columns: (auto, 1fr),
      column-gutter: 14pt,
      row-gutter: 7pt,
      text(fill: c.tinta2)[Indicativo], [*#cfg.indicativo* (marcador) · #deletrear(cfg.indicativo)],
      text(fill: c.tinta2)[Locator], [#cfg.locator · zona CQ *#cfg.zona-cq* · zona ITU #cfg.zona-itu · #cfg.continente],
      text(fill: c.tinta2)[Categoría prevista], [#cfg.categoria, overlay *#cfg.overlay*],
      text(fill: c.tinta2)[2026], [24–25 oct: *solo escucha* (receptores web y RTL-SDR)],
      text(fill: c.tinta2)[Antes], [ARRL 10 m (12–13 dic 2026) y otros concursos pequeños],
      text(fill: c.tinta2)[2027], [30–31 oct: *primera participación* en el CQ WW SSB],
    )
  ]
  #v(1.2em)
  #block(width: 100%, stroke: 0.6pt + c.linea, inset: 12pt, radius: 4pt)[
    #set text(size: 9.5pt)
    #text(weight: "bold", fill: c.azul-osc)[Cómo usar esta guía]
    #v(0.2em)
    #grid(
      columns: (auto, 1fr),
      column-gutter: 14pt,
      row-gutter: 7pt,
      text(fill: c.tinta2)[Si tienes 5 minutos], [Resumen (cap. 1) y la chuleta del anexo.],
      text(fill: c.tinta2)[Este fin de semana], [Dónde y cuándo buscar (cap. 5) y el plan de escucha (cap. 6).],
      text(fill: c.tinta2)[Para preparar 2027], [Marco legal, equipo y herramientas (caps. 8–10), entrenamiento (cap. 12).],
      text(fill: c.tinta2)[Durante el concurso], [Chuleta, plan de bandas (cap. 5), técnica (cap. 7) y checklists (cap. 14).],
      text(fill: c.tinta2)[Datos sin confirmar], [Marcados como #pv\; lista en el capítulo 17.],
    )
  ]
  #v(1fr)
  #set text(size: 8pt, fill: c.tinta2)
  Versión del #cfg.version. Los datos que caducan (precios, versiones de software, ciclo solar) llevan su fecha; lo que no se pudo confirmar en una fuente primaria está marcado como #pv. Las cifras de horarios, puntos y orto/ocaso se han calculado con los scripts de `scripts/`. Compilado con Typst 0.15.1 sin paquetes externos.
]

// ---------------------------------------------------------------- índice
#page(header: none)[
  #set par(justify: false)
  #text(size: 17pt, weight: "bold", fill: c.azul-osc)[Índice]
  #v(0.4em)
  #show outline.entry.where(level: 1): set block(above: 0.75em)
  #show outline.entry.where(level: 1): set text(weight: "semibold")
  #set text(size: 8.6pt, hyphenate: false)
  #columns(2, gutter: 16pt, outline(title: none, depth: 2, indent: 1.1em))
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
#page(margin: (x: 1.0cm, y: 0.9cm), header: none, footer: none)[
  // título del anexo para el índice, sin ocupar sitio en la página
  #place(hide[= Chuleta de una página (también en `chuleta.pdf`) <anexo-chuleta>])
  #set text(size: 7.2pt)
  #chuleta.chuleta(cfg)
]

#set heading(numbering: none)
= Bibliografía
#set text(size: 8pt)
#bibliography("bib/referencias.yml", title: none, style: "ieee", full: false)
