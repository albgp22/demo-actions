// plantilla.typ — estilos y componentes comunes de la guía.
// Compatible con Typst 0.15 (sin paquetes externos).

#let c = (
  azul: rgb("#2a78d6"),
  azul-osc: rgb("#184f95"),
  azul-noche: rgb("#0d366b"),
  azul-claro: rgb("#eaf2fc"),
  azul-hielo: rgb("#cde2fb"),
  cab: rgb("#eef3f9"),
  tinta: rgb("#0b0b0b"),
  tinta2: rgb("#52514e"),
  tenue: rgb("#898781"),
  linea: rgb("#e1e0d9"),
  papel: rgb("#f4f3ef"),
  cebra: rgb("#f7f7f4"),
  naranja: rgb("#eb6834"),
  rojo: rgb("#a3231a"),
  rojo-claro: rgb("#fcecea"),
  verde: rgb("#006300"),
  verde-claro: rgb("#e9f4e9"),
  ambar: rgb("#7a4f00"),
  ambar-claro: rgb("#fff1d6"),
)

// Colores fijos de las bandas del concurso (los mismos que en las figuras, scripts/figlib.py)
#let color-banda = (
  "160": rgb("#2a78d6"),
  "80": rgb("#eb6834"),
  "40": rgb("#1baf7a"),
  "20": rgb("#eda100"),
  "15": rgb("#e87ba4"),
  "10": rgb("#008300"),
)

// ---------------------------------------------------------------- partes
// Cada parte tiene su color: aperturas de capítulo, pestañas del borde, índice.
#let partes = (
  (num: "I", nombre: "Lo esencial", color: rgb("#0d366b"), caps: (1,)),
  (num: "II", nombre: "El concurso", color: rgb("#256abf"), caps: (2, 3, 4, 5)),
  (num: "III", nombre: "Este fin de semana", color: rgb("#0f6b4b"), caps: (6,)),
  (num: "IV", nombre: "En el aire", color: rgb("#b84a1c"), caps: (7,)),
  (num: "V", nombre: "Preparar 2027", color: rgb("#4a3aa7"), caps: (8, 9, 10, 11, 12, 13)),
  (num: "VI", nombre: "Consulta", color: rgb("#52514e"), caps: (14, 15, 16, 17)),
)
#let anexo = (num: "A", nombre: "Anexo", color: rgb("#0d366b"), caps: ())
#let parte-de(n) = {
  let p = partes.find(p => n in p.caps)
  if p == none { anexo } else { p }
}

// Color de la parte en curso (necesita contexto)
#let color-parte() = {
  let n = counter(heading).get()
  if n.len() == 0 or n.first() == 0 { c.azul-osc } else { parte-de(n.first()).color }
}

// Capítulo vigente en la página actual (el que empieza arriba del todo o el anterior)
#let cap-de-pagina() = {
  let p = here().page()
  let hs = query(heading.where(level: 1))
  let aqui = hs.filter(h => h.location().page() == p)
  let antes = hs.filter(h => h.location().page() < p)
  if aqui.len() > 0 and aqui.first().location().position().y < 5cm { aqui.first() } else if antes.len() > 0 {
    antes.last()
  } else if aqui.len() > 0 { aqui.first() } else { none }
}

// ---------------------------------------------------------------- iconos
#let icono(tipo, color, tam: 12pt) = {
  let glifo(t) = text(font: "Inter Display", size: tam * 0.68, weight: "bold", fill: white, t)
  box(
    width: tam,
    height: tam,
    radius: tam / 2,
    fill: color,
    baseline: 22%,
    if tipo == "ok" {
      let k = tam / 12pt
      place(curve(
        stroke: (paint: white, thickness: 1.5pt * k, cap: "round", join: "round"),
        curve.move((3.4pt * k, 6.3pt * k)),
        curve.line((5.3pt * k, 8.4pt * k)),
        curve.line((8.8pt * k, 4.0pt * k)),
      ))
    } else {
      align(center + horizon, glifo(if tipo == "error" { "×" } else if tipo == "info" { "i" } else { "!" }))
    },
  )
}

// ---------------------------------------------------------------- cajas
#let caja(etiqueta, color, fondo, cuerpo, tipo: "aviso") = block(
  width: 100%,
  fill: fondo,
  inset: (left: 8pt, right: 9pt, top: 7pt, bottom: 7pt),
  radius: 4pt,
  above: 1em,
  below: 1em,
)[
  #set par(justify: false)
  #grid(
    columns: (12pt, 1fr),
    column-gutter: 7pt,
    pad(top: 0.4pt, icono(tipo, color)),
    [#text(weight: "bold", fill: color, size: 0.84em, tracking: 0.05em)[#upper(etiqueta)]#h(0.45em)#cuerpo],
  )
]

#let importante(cuerpo) = caja("Importante", c.azul-osc, c.azul-claro, cuerpo, tipo: "aviso")
#let error-tipico(cuerpo) = caja("Error típico", c.rojo, c.rojo-claro, cuerpo, tipo: "error")
#let truco(cuerpo) = caja("Truco", c.verde, c.verde-claro, cuerpo, tipo: "ok")
#let nota(cuerpo) = caja("Nota", c.tinta2, c.papel, cuerpo, tipo: "info")

// Marca «por verificar» (dato que no se pudo confirmar en fuente primaria)
#let pv = box(
  inset: (x: 3pt, y: 0.5pt),
  outset: (y: 1.5pt),
  radius: 6pt,
  fill: c.ambar-claro,
  stroke: 0.4pt + rgb("#e3c27a"),
  text(size: 0.74em, weight: "bold", fill: c.ambar, tracking: 0.04em)[POR VERIFICAR],
)

// Línea de fuentes al final de una sección: #fuentes("rules-cqww-2026", ...)
#let fuentes(..claves) = block(above: 0.9em, below: 0.6em)[
  #set text(size: 7.6pt, fill: c.tinta2)
  #set par(justify: false)
  #text(weight: "semibold", fill: c.tenue, tracking: 0.04em)[#upper[Fuentes]]#h(0.4em)#claves.pos().map(k => cite(label(k))).join(", ")
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
  stroke: (paint: c.tenue, thickness: 0.5pt),
  fill: rgb("#f7f7f5"),
  text(font: "JetBrains Mono", size: 0.82em, t),
)

// Frase para decir por radio (en inglés)
#let dice(t) = text(font: "JetBrains Mono", size: 0.86em, fill: c.azul-osc)[«#t»]

// Banda con su color (como en las figuras)
#let banda(b) = {
  let k = str(b).replace(" m", "")
  let col = color-banda.at(k, default: c.tenue)
  box(
    inset: (x: 3.2pt, y: 0.6pt),
    outset: (y: 1.4pt),
    radius: 6pt,
    fill: col.lighten(82%),
    stroke: 0.5pt + col,
    text(size: 0.86em, weight: "semibold", fill: c.tinta, number-width: "tabular")[#k m],
  )
}

// Viñetas de las listas
#let marcadores = (
  text(fill: c.azul, size: 1.1em, baseline: -0.05em)[•],
  text(fill: c.tenue)[–],
)

// Casilla de lista de comprobación
#let casilla = box(width: 7pt, height: 7pt, radius: 1.2pt, stroke: 0.7pt + c.tinta2, baseline: 0.6pt)

// Figura de tabla larga que puede partirse entre páginas
#let larga(fig) = {
  show figure: set block(breakable: true)
  fig
}

// ---------------------------------------------------------------- tablas
#let tabla(..args) = {
  set text(size: 8.2pt)
  set par(justify: false, leading: 0.5em)
  show table.cell.where(y: 0): set text(weight: "semibold", fill: c.azul-noche)
  table(
    stroke: (x, y) => (
      top: if y == 0 { 0.8pt + c.tinta2 } else if y == 1 { 0.5pt + c.tinta2 } else { none },
    ),
    fill: (x, y) => if y == 0 { c.cab } else if calc.even(y) { c.cebra },
    inset: (x: 4.5pt, y: 3.4pt),
    align: left + horizon,
    ..args.named(),
    ..args.pos(),
    table.hline(stroke: 0.8pt + c.tinta2),
  )
}

// ---------------------------------------------------------------- diagramas
#let paso(cuerpo, color: c.azul-osc, fondo: c.azul-claro) = rect(
  width: 100%,
  inset: (x: 7pt, y: 5pt),
  radius: 4pt,
  fill: fondo,
  stroke: 0.6pt + color,
)[#set text(size: 8pt); #set par(justify: false, leading: 0.45em); #cuerpo]

#let decision(cuerpo) = paso(cuerpo, color: rgb("#b07a00"), fondo: c.ambar-claro)
#let flecha-abajo = align(center, box(height: 9pt, {
  place(center + top, line(start: (0pt, 0pt), end: (0pt, 6pt), stroke: 0.8pt + c.tenue))
  place(center + top, dy: 5pt, polygon(fill: c.tenue, (-2.6pt, 0pt), (2.6pt, 0pt), (0pt, 4pt)))
}))
#let flecha-der(t: none) = align(center + horizon, box(width: 100%, {
  set text(fill: c.tinta2, size: 6.8pt, hyphenate: false)
  set par(justify: false)
  if t != none { align(center, t) }
  v(-0.3em)
  box(width: 100%, height: 6pt, {
    place(left + horizon, line(length: 100% - 4pt, stroke: 0.8pt + c.tenue))
    place(right + horizon, polygon(fill: c.tenue, (0pt, -2.6pt), (4pt, 0pt), (0pt, 2.6pt)))
  })
}))

// Lienzo con coordenadas absolutas para diagramas propios
#let nodo(x, y, w, h, cuerpo, color: c.azul-osc, fondo: c.azul-claro, tam: 7.4pt, grosor: 0.6pt, radio: 4pt) = place(
  dx: x,
  dy: y,
  box(width: w, height: h, fill: fondo, stroke: grosor + color, radius: radio, inset: (x: 4pt, y: 3pt), align(
    center + horizon,
    {
      set text(size: tam, hyphenate: false)
      set par(justify: false, leading: 0.42em)
      cuerpo
    },
  )),
)

// Flecha recta de p a q (puntos en longitudes); punta opcional en cada extremo
#let flecha(p, q, color: c.tinta2, grosor: 0.8pt, punta: true, cola: false, guiones: none) = {
  let (x1, y1) = p
  let (x2, y2) = q
  let ang = calc.atan2((x2 - x1) / 1pt, (y2 - y1) / 1pt)
  let tip(x, y, a) = {
    let l = 4.6pt
    let w = 2.5pt
    let bx = x - l * calc.cos(a)
    let by = y - l * calc.sin(a)
    polygon(
      fill: color,
      (x, y),
      (bx + w * calc.sin(a), by - w * calc.cos(a)),
      (bx - w * calc.sin(a), by + w * calc.cos(a)),
    )
  }
  let acorta = 4pt
  let s = if cola { (x1 + acorta * calc.cos(ang), y1 + acorta * calc.sin(ang)) } else { p }
  let e = if punta { (x2 - acorta * calc.cos(ang), y2 - acorta * calc.sin(ang)) } else { q }
  place(line(start: s, end: e, stroke: (paint: color, thickness: grosor, dash: guiones, cap: "round")))
  if punta { place(tip(x2, y2, ang)) }
  if cola { place(tip(x1, y1, ang + 180deg)) }
}

#let rotulo(x, y, cuerpo, tam: 6.8pt, color: c.tinta2, ancho: auto, alinea: left) = place(dx: x, dy: y, box(
  width: ancho,
  {
    set text(size: tam, fill: color, hyphenate: false)
    set par(justify: false, leading: 0.4em)
    align(alinea, cuerpo)
  },
))

// ---------------------------------------------------------------- índice
#let indice() = context {
  let hs = query(heading.where(outlined: true).and(heading.where(level: 1).or(heading.where(level: 2))))
  let parte-previa = none
  set par(justify: false, leading: 0.45em, spacing: 0pt)
  for h in hs {
    let pag = counter(page).at(h.location()).first()
    let nums = counter(heading).at(h.location())
    let es-cap = h.level == 1 and h.numbering == "1.1"
    let es-anexo = h.numbering == "A.1"
    let parte = if es-anexo { anexo } else if h.numbering == none { none } else { parte-de(nums.first()) }
    if h.level == 1 and parte != none and parte != parte-previa {
      block(above: if parte-previa == none { 0pt } else { 1.15em }, below: 0.45em, sticky: true)[
        #text(size: 6.6pt, weight: "bold", fill: parte.color, tracking: 0.12em)[#upper[#if parte.num != "A" [Parte #parte.num · ]#parte.nombre]]
      ]
      parte-previa = parte
    }
    if h.level == 1 {
      let numero = if es-cap { str(nums.first()) } else if es-anexo { "A" } else { "" }
      let col = if parte == none { c.tinta2 } else { parte.color }
      block(above: if parte == none { 1.1em } else { 0.62em }, below: 0.34em, sticky: true, link(h.location(), grid(
        columns: (1.55em, 1fr, auto),
        column-gutter: 0.3em,
        text(font: "Inter Display", weight: "bold", fill: col)[#numero],
        text(weight: "semibold", fill: c.tinta)[#h.body],
        text(weight: "semibold", fill: c.tinta2, number-width: "tabular")[#pag],
      )))
    } else {
      block(above: 0.34em, below: 0.34em, link(h.location(), grid(
        columns: (1.55em, 1fr, auto),
        column-gutter: 0.3em,
        [],
        text(fill: c.tinta2)[#h.body #box(width: 1fr, repeat(gap: 2.2pt, text(fill: c.linea)[.]))],
        text(fill: c.tenue, number-width: "tabular")[#pag],
      )))
    }
  }
}

// ---------------------------------------------------------------- documento
#let documento(cfg, cuerpo) = {
  set document(
    title: "Guía del CQ World Wide DX Contest SSB",
    author: cfg.indicativo,
    keywords: ("CQ WW", "SSB", "concursos", "radioafición", "EA"),
  )
  set text(lang: "es", region: "ES", font: "Inter", size: 9.4pt, fill: c.tinta, hyphenate: true)
  set par(justify: true, leading: 0.62em, spacing: 0.88em)
  set page(
    paper: "a4",
    margin: (top: 2.1cm, bottom: 1.9cm, x: 1.85cm),
    header: context {
      let p = here().page()
      if p > 2 {
        let cap = cap-de-pagina()
        set text(size: 7.4pt, fill: c.tenue)
        grid(
          columns: (1fr, auto),
          [#text(weight: "semibold", tracking: 0.06em)[GUÍA CQ WW DX SSB] #h(0.3em) · #h(0.3em) #cfg.indicativo · #cfg.locator],
          if cap != none {
            if cap.numbering == "1.1" {
              let n = counter(heading).at(cap.location()).first()
              [#text(weight: "bold", fill: parte-de(n).color)[#n] #h(0.35em) #cap.body]
            } else [#cap.body]
          },
        )
        v(-3pt)
        line(length: 100%, stroke: 0.4pt + c.linea)
      }
    },
    footer: context {
      let p = here().page()
      if p > 1 {
        set text(size: 7.6pt, fill: c.tenue, number-width: "tabular")
        align(center)[#counter(page).display()]
      }
    },
    // Pestaña lateral del capítulo (como el índice de uñero de un diccionario)
    background: context {
      let p = here().page()
      if p > 2 {
        let cap = cap-de-pagina()
        if cap != none and cap.numbering == "1.1" {
          let n = counter(heading).at(cap.location()).first()
          let alto = 12.2mm
          let paso = 13.4mm
          place(top + right, dy: 2.55cm + (n - 1) * paso, box(
            width: 11mm,
            height: alto,
            fill: parte-de(n).color,
            radius: (top-left: 3pt, bottom-left: 3pt),
            align(left + horizon, pad(left: 2.1mm, text(
              font: "Inter Display",
              size: 9.5pt,
              weight: "bold",
              fill: white,
              number-width: "tabular",
            )[#n])),
          ))
        }
      }
    },
  )
  set heading(numbering: "1.1", supplement: none)
  show heading: set text(font: "Inter Display", weight: "bold", fill: c.tinta)
  // Apertura de capítulo: número en un bloque del color de la parte
  show heading.where(level: 1): it => block(above: 2.5em, below: 1.15em, width: 100%, sticky: true, breakable: false)[
    #context {
      if it.numbering == "1.1" {
        let n = counter(heading).get().first()
        let pa = parte-de(n)
        grid(
          columns: (auto, 1fr),
          column-gutter: 10pt,
          align: (left + horizon, left + horizon),
          box(width: 31pt, height: 31pt, radius: 4pt, fill: pa.color, align(center + horizon, text(
            font: "Inter Display",
            size: 17pt,
            weight: "bold",
            fill: white,
          )[#n])),
          {
            set par(justify: false, leading: 0.35em)
            text(size: 6.8pt, weight: "bold", fill: pa.color, tracking: 0.12em, font: "Inter")[#upper[Parte #pa.num · #pa.nombre]]
            linebreak()
            text(size: 18.5pt, hyphenate: false)[#it.body]
          },
        )
        v(-0.15em)
        line(length: 100%, stroke: 0.9pt + pa.color)
      } else {
        set par(justify: false)
        text(size: 18.5pt, hyphenate: false)[#it.body]
        v(-0.5em)
        line(length: 100%, stroke: 0.9pt + c.tinta2)
      }
    }
  ]
  show heading.where(level: 2): it => block(above: 1.45em, below: 0.7em, sticky: true)[
    #set text(size: 12pt, weight: "semibold")
    #set par(justify: false)
    #context if it.numbering != none {
      text(fill: color-parte())[#counter(heading).display(it.numbering)]
      h(0.55em)
    }
    #it.body
  ]
  show heading.where(level: 3): it => block(above: 1.15em, below: 0.55em, sticky: true)[
    #set text(font: "Inter", size: 9.8pt, weight: "semibold")
    #set par(justify: false)
    #context if it.numbering != none {
      text(fill: color-parte())[#counter(heading).display(it.numbering)]
      h(0.5em)
    }
    #it.body
  ]
  show link: set text(fill: c.azul-osc)
  show raw: set text(font: "JetBrains Mono", size: 7.8pt)
  show raw.where(block: true): block.with(
    width: 100%,
    fill: rgb("#f5f5f2"),
    inset: (x: 7pt, y: 6pt),
    radius: 3pt,
    stroke: 0.4pt + c.linea,
  )
  set list(indent: 0.5em, body-indent: 0.5em, spacing: 0.55em, marker: marcadores)
  set enum(indent: 0.5em, body-indent: 0.5em, spacing: 0.55em, numbering: n => text(
    weight: "semibold",
    fill: c.azul-osc,
    number-width: "tabular",
  )[#n.])
  show terms: it => {
    for item in it.children {
      block(above: 0.62em, below: 0.62em)[#text(weight: "semibold", fill: c.azul-noche)[#item.term:]#h(0.35em)#item.description]
    }
  }
  set figure(gap: 0.7em)
  show figure.caption: it => {
    set text(size: 8pt, fill: c.tinta2)
    set par(justify: false, leading: 0.5em)
    block(width: 100%)[#text(weight: "semibold", fill: c.azul-noche)[#it.supplement #context it.counter.display(it.numbering)]#h(0.55em)#it.body]
  }
  show figure.where(kind: table): set figure.caption(position: top)
  set footnote.entry(separator: line(length: 25%, stroke: 0.4pt + c.tenue))
  show footnote.entry: set text(size: 7.5pt)
  cuerpo
}
