// plantilla.typ — estilos y componentes comunes de la guía.
// Compatible con Typst 0.15 (sin paquetes externos).

#let c = (
  azul: rgb("#2a78d6"),
  azul-osc: rgb("#184f95"),
  azul-claro: rgb("#eaf2fc"),
  cab: rgb("#eef3f9"),
  tinta: rgb("#0b0b0b"),
  tinta2: rgb("#52514e"),
  tenue: rgb("#898781"),
  linea: rgb("#e1e0d9"),
  rojo: rgb("#a3231a"),
  rojo-claro: rgb("#fcecea"),
  verde: rgb("#006300"),
  verde-claro: rgb("#e9f4e9"),
  ambar: rgb("#7a4f00"),
  ambar-claro: rgb("#fff1d6"),
)

// ---------------------------------------------------------------- cajas
#let caja(etiqueta, color, fondo, cuerpo) = block(
  width: 100%,
  fill: fondo,
  inset: (left: 9pt, right: 8pt, y: 6.5pt),
  radius: (right: 3pt),
  stroke: (left: 2.5pt + color),
  above: 0.9em,
  below: 0.9em,
)[
  #set par(justify: false)
  #text(weight: "bold", fill: color, size: 0.9em, tracking: 0.02em)[#upper(etiqueta)]
  #h(0.35em)
  #cuerpo
]

#let importante(cuerpo) = caja("Importante", c.azul-osc, c.azul-claro, cuerpo)
#let error-tipico(cuerpo) = caja("Error típico", c.rojo, c.rojo-claro, cuerpo)
#let truco(cuerpo) = caja("Truco", c.verde, c.verde-claro, cuerpo)
#let nota(cuerpo) = caja("Nota", c.tinta2, rgb("#f3f2ee"), cuerpo)

// Marca «por verificar» (dato que no se pudo confirmar en fuente primaria)
#let pv = box(
  inset: (x: 2.5pt, y: 0.5pt),
  outset: (y: 1.5pt),
  radius: 2pt,
  fill: c.ambar-claro,
  text(size: 0.78em, weight: "bold", fill: c.ambar, tracking: 0.02em)[POR VERIFICAR],
)

// Línea de fuentes al final de una sección: #fuentes("rules-cqww-2026", ...)
#let fuentes(..claves) = block(above: 0.8em, below: 0.6em)[
  #set text(size: 7.8pt, fill: c.tinta2)
  #set par(justify: false)
  *Fuentes:* #claves.pos().map(k => cite(label(k))).join(", ")
]

// Enlace con la URL visible y abreviada
#let url(u, texto: none) = link(u)[#if texto == none {
    u.replace(regex("^https?://(www\.)?"), "").trim("/", at: end)
  } else { texto }]

// Números a la española: coma decimal y punto de miles
#let coma(x) = str(x).replace(".", ",")
#let miles(n) = {
  let s = str(int(calc.round(float(n))))
  let neg = s.starts-with("-")
  let d = if neg { s.slice(1) } else { s }
  let out = ""
  let k = 0
  for ch in d.clusters().rev() {
    if k > 0 and calc.rem(k, 3) == 0 { out = "." + out }
    out = ch + out
    k += 1
  }
  if neg { "−" + out } else { out }
}
#let redondea(x, n) = coma(str(calc.round(float(x), digits: n)))
// Kp en notación de tercios: 4,67 → «5−», 4,33 → «4+», 4,00 → «4o»
#let kp(v) = {
  let k = float(v)
  let f = int(calc.floor(k))
  let r = k - f
  if r < 0.17 { str(f) + "o" } else if r < 0.5 { str(f) + "+" } else { str(f + 1) + "−" }
}

// Etiqueta de dato fechado
#let fecha(f) = text(size: 0.85em, fill: c.tinta2)[(#f)]

// Tecla / botón
#let tecla(t) = box(
  inset: (x: 3pt, y: 0pt),
  outset: (y: 2pt),
  radius: 2pt,
  stroke: 0.5pt + c.tenue,
  fill: rgb("#f7f7f5"),
  text(font: "JetBrains Mono", size: 0.82em, t),
)

// Frase para decir por radio (en inglés)
#let dice(t) = text(font: "JetBrains Mono", size: 0.86em, fill: c.azul-osc)[«#t»]

// Figura de tabla larga que puede partirse entre páginas
#let larga(fig) = {
  show figure: set block(breakable: true)
  fig
}

// ---------------------------------------------------------------- tablas
#let tabla(..args) = {
  set text(size: 8.2pt)
  set par(justify: false, leading: 0.5em)
  table(
    stroke: (x, y) => (
      top: if y == 0 { 0.7pt + c.tinta2 } else if y == 1 { 0.7pt + c.tinta2 } else { 0.4pt + c.linea },
      bottom: 0.7pt + c.tinta2,
    ),
    fill: (x, y) => if y == 0 { c.cab },
    inset: (x: 4.5pt, y: 3.2pt),
    align: left + horizon,
    ..args,
  )
}

// ---------------------------------------------------------------- diagrama
#let paso(cuerpo, color: c.azul-osc, fondo: c.azul-claro) = rect(
  width: 100%,
  inset: (x: 6pt, y: 4.5pt),
  radius: 3pt,
  fill: fondo,
  stroke: 0.6pt + color,
)[#set text(size: 8pt); #set par(justify: false, leading: 0.45em); #cuerpo]

#let decision(cuerpo) = paso(cuerpo, color: c.ambar, fondo: c.ambar-claro)
#let flecha-abajo = align(center, text(fill: c.tinta2, size: 9pt)[↓])
#let flecha-der(t: none) = align(center + horizon, text(fill: c.tinta2, size: 7pt, hyphenate: false)[#if t != none [#t ] →])

// ---------------------------------------------------------------- documento
#let documento(cfg, cuerpo) = {
  set document(
    title: "Guía del CQ World Wide DX Contest SSB",
    author: cfg.indicativo,
    keywords: ("CQ WW", "SSB", "concursos", "radioafición", "EA"),
  )
  set text(lang: "es", region: "ES", font: "Inter", size: 9.4pt, fill: c.tinta, hyphenate: true)
  set par(justify: true, leading: 0.6em, spacing: 0.85em)
  set page(
    paper: "a4",
    margin: (top: 2.1cm, bottom: 1.9cm, x: 1.85cm),
    header: context {
      let p = here().page()
      if p > 2 {
        // capítulo vigente al principio de la página (o el que empieza arriba del todo)
        let hs = query(heading.where(level: 1))
        let aqui = hs.filter(h => h.location().page() == p)
        let antes = hs.filter(h => h.location().page() < p)
        let actual = if aqui.len() > 0 and aqui.first().location().position().y < 5cm { aqui.first() } else if antes.len() > 0 { antes.last() } else if aqui.len() > 0 { aqui.first() } else { none }
        set text(size: 7.5pt, fill: c.tenue)
        grid(
          columns: (1fr, auto),
          [Guía CQ WW DX SSB · #cfg.indicativo · #cfg.locator],
          if actual != none {
            if actual.numbering != none [#numbering(actual.numbering, ..counter(heading).at(actual.location())). #actual.body] else [#actual.body]
          },
        )
        v(-3pt)
        line(length: 100%, stroke: 0.4pt + c.linea)
      }
    },
    footer: context {
      let p = here().page()
      if p > 1 {
        set text(size: 7.5pt, fill: c.tenue)
        align(center)[#counter(page).display()]
      }
    },
  )
  set heading(numbering: "1.1", supplement: none)
  show heading: set text(font: "Inter", weight: "bold", fill: c.azul-osc)
  show heading.where(level: 1): it => {
    block(above: 2.2em, below: 1.0em, width: 100%, sticky: true)[
      #set text(size: 17pt)
      #if it.numbering != none {
        text(fill: c.azul)[#counter(heading).display(it.numbering)]
        h(0.45em)
      }
      #it.body
      #v(-0.55em)
      #line(length: 100%, stroke: 1pt + c.azul)
    ]
  }
  show heading.where(level: 2): set text(size: 11.5pt)
  show heading.where(level: 2): set block(above: 1.35em, below: 0.65em)
  show heading.where(level: 3): set text(size: 9.8pt, fill: c.tinta)
  show heading.where(level: 3): set block(above: 1.1em, below: 0.55em)
  show link: set text(fill: c.azul-osc)
  show raw: set text(font: "JetBrains Mono", size: 7.8pt)
  show raw.where(block: true): block.with(
    width: 100%,
    fill: rgb("#f6f6f3"),
    inset: 6pt,
    radius: 2pt,
    stroke: 0.4pt + c.linea,
  )
  set list(indent: 0.5em, body-indent: 0.45em, spacing: 0.55em)
  set enum(indent: 0.5em, body-indent: 0.45em, spacing: 0.55em)
  set figure(gap: 0.6em)
  show figure.caption: set text(size: 8pt, fill: c.tinta2)
  show figure.caption: set par(justify: false)
  show figure.where(kind: table): set figure.caption(position: top)
  set footnote.entry(separator: line(length: 25%, stroke: 0.4pt + c.tenue))
  show footnote.entry: set text(size: 7.5pt)
  cuerpo
}
