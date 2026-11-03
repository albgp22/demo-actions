// =====================================================================
//  theme.typ — Sistema visual de la "Guía visual de AWS"
//  Todas las funciones de maquetación y componentes reutilizables.
// =====================================================================

// ---------------------------------------------------------------------
//  Paleta
// ---------------------------------------------------------------------
#let tinta = rgb("#1B2333")
#let marino = rgb("#0B1F3A")
#let gris = rgb("#6B7686")
#let gris-claro = rgb("#E4E8EE")
#let fondo-suave = rgb("#F6F8FB")
#let acento = rgb("#F28C28")

// Colores por categoría de servicio (úsalos como `col.redes`, etc.)
#let col = (
  fundamentos: rgb("#2B3A55"),
  iam: rgb("#D6334A"),
  redes: rgb("#7C4DDB"),
  computo: rgb("#E8720C"),
  balanceo: rgb("#E39B00"),
  contenedores: rgb("#0CA678"),
  serverless: rgb("#F76707"),
  almacenamiento: rgb("#2F9E44"),
  datos: rgb("#3B5BDB"),
  integracion: rgb("#D6336C"),
  edge: rgb("#9C36B5"),
  observabilidad: rgb("#1098AD"),
  seguridad: rgb("#C92A2A"),
  iac: rgb("#5F3DC4"),
  costes: rgb("#A67C00"),
  arquitectura: rgb("#364FC7"),
  neutro: rgb("#5C6878"),
)

// Color del capítulo actual (lo fija `capitulo`)
#let chap-color = state("chap-color", col.fundamentos)

// ---------------------------------------------------------------------
//  Utilidades pequeñas
// ---------------------------------------------------------------------
#let pill(texto, color: col.neutro, relleno: auto) = box(
  fill: if relleno == auto { color.lighten(88%) } else { relleno },
  inset: (x: 5pt, y: 2.2pt),
  outset: (y: 1pt),
  radius: 8pt,
  text(7.5pt, weight: "semibold", fill: color.darken(15%), texto),
)

#let tecla(texto) = box(
  fill: white, stroke: 0.6pt + gris, radius: 2pt,
  inset: (x: 3pt, y: 1.5pt), outset: (y: 1pt),
  text(7.5pt, font: "JetBrains Mono", texto),
)

// ---------------------------------------------------------------------
//  Cajas destacadas (callouts)
// ---------------------------------------------------------------------
#let _tipos = (
  nota: (titulo: "Nota", color: rgb("#1C7ED6"), icono: "i"),
  consejo: (titulo: "Consejo", color: rgb("#2F9E44"), icono: "✓"),
  cuidado: (titulo: "Cuidado", color: rgb("#E03131"), icono: "!"),
  examen: (titulo: "Clave para la certificación", color: rgb("#7048E8"), icono: "★"),
  coste: (titulo: "Costes", color: rgb("#A67C00"), icono: "$"),
  practica: (titulo: "Buena práctica", color: rgb("#0C8599"), icono: "◆"),
  analogia: (titulo: "Analogía", color: rgb("#D6336C"), icono: "≈"),
)

#let _callout(tipo, titulo: none, body) = {
  let t = _tipos.at(tipo)
  let c = t.color
  block(
    width: 100%,
    fill: c.lighten(93%),
    stroke: (left: 3pt + c),
    radius: (right: 6pt),
    inset: (left: 11pt, right: 12pt, y: 9pt),
    above: 1.1em, below: 1.1em,
    breakable: false,
    grid(
      columns: (auto, 1fr),
      column-gutter: 9pt,
      circle(radius: 7.5pt, fill: c, inset: 0pt, align(center + horizon,
        text(8pt, weight: "bold", fill: white, font: ("Inter", "DejaVu Sans"), t.icono))),
      {
        text(8.5pt, weight: "bold", fill: c.darken(25%), tracking: 0.3pt,
          upper(if titulo == none { t.titulo } else { titulo }))
        v(2pt)
        set text(9.4pt)
        set par(justify: false)
        body
      },
    ),
  )
}

#let nota(titulo: none, body) = _callout("nota", titulo: titulo, body)
#let consejo(titulo: none, body) = _callout("consejo", titulo: titulo, body)
#let cuidado(titulo: none, body) = _callout("cuidado", titulo: titulo, body)
#let examen(titulo: none, body) = _callout("examen", titulo: titulo, body)
#let coste(titulo: none, body) = _callout("coste", titulo: titulo, body)
#let practica(titulo: none, body) = _callout("practica", titulo: titulo, body)
#let analogia(titulo: none, body) = _callout("analogia", titulo: titulo, body)

// ---------------------------------------------------------------------
//  Ficha de servicio
//  #ficha("Amazon SQS", "Colas de mensajes gestionadas",
//     ("Tipo", [Serverless]), ("Ámbito", [Regional]), ...)
// ---------------------------------------------------------------------
#let ficha(nombre, descripcion, color: auto, ..campos) = context {
  let c = if color == auto { chap-color.get() } else { color }
  block(
    width: 100%, radius: 8pt, clip: true, breakable: false,
    stroke: 0.8pt + c.lighten(55%),
    above: 1.2em, below: 1.2em,
    {
      block(
        width: 100%, spacing: 0pt,
        fill: gradient.linear(c, c.darken(30%), angle: 0deg),
        inset: (x: 14pt, y: 11pt),
        {
          text(6.8pt, weight: "bold", fill: white.transparentize(25%), tracking: 1.2pt, "FICHA DEL SERVICIO")
          linebreak()
          text(15pt, weight: "bold", fill: white, nombre)
          linebreak()
          text(9pt, fill: white.transparentize(10%), descripcion)
        },
      )
      block(
        width: 100%, spacing: 0pt, fill: c.lighten(96%),
        inset: (x: 14pt, y: 10pt),
        grid(
          columns: (auto, 1fr), column-gutter: 14pt, row-gutter: 7pt,
          ..campos.pos().map(((k, v)) => (
            text(7.5pt, weight: "bold", fill: c.darken(10%), tracking: 0.4pt, upper(k)),
            text(9pt, v),
          )).flatten()
        ),
      )
    },
  )
}

// ---------------------------------------------------------------------
//  Cifras destacadas:  #datos(("15 min", [Duración máx.]), ("10 GB", [RAM máx.]))
// ---------------------------------------------------------------------
#let datos(color: auto, ..items) = context {
  let c = if color == auto { chap-color.get() } else { color }
  let xs = items.pos()
  block(above: 1.1em, below: 1.1em, grid(
    columns: (1fr,) * xs.len(), column-gutter: 8pt,
    ..xs.map(((v, l)) => block(
      width: 100%, fill: c.lighten(92%), radius: 6pt,
      inset: (x: 10pt, y: 9pt), stroke: (top: 2.5pt + c),
      {
        text(17pt, weight: "extrabold", fill: c.darken(5%), v)
        linebreak()
        text(7.8pt, fill: gris, l)
      },
    ))
  ))
}

// ---------------------------------------------------------------------
//  Tarjetas en columnas:  #tarjetas(tarjeta("A")[...], tarjeta("B")[...])
// ---------------------------------------------------------------------
#let tarjeta(titulo, color: auto, subtitulo: none, body) = context {
  let c = if color == auto { chap-color.get() } else { color }
  block(
    width: 100%, radius: 7pt, breakable: false,
    stroke: 0.8pt + c.lighten(55%), fill: white, clip: true,
    {
      block(width: 100%, spacing: 0pt, fill: c.lighten(88%), inset: (x: 10pt, y: 7pt), {
        text(9.5pt, weight: "bold", fill: c.darken(20%), titulo)
        if subtitulo != none { linebreak(); text(7.5pt, fill: gris, subtitulo) }
      })
      block(width: 100%, spacing: 0pt, inset: (x: 10pt, y: 8pt), {
        set text(8.8pt)
        set par(justify: false)
        body
      })
    },
  )
}

#let tarjetas(columnas: auto, ..items) = {
  let xs = items.pos()
  let n = if columnas == auto { xs.len() } else { columnas }
  block(above: 1.1em, below: 1.1em, grid(columns: (1fr,) * n, column-gutter: 8pt, row-gutter: 8pt, ..xs))
}

// ---------------------------------------------------------------------
//  Tabla estilizada
//  #tabla(("Col A", "Col B"), columnas: (1fr, 2fr), [a1], [b1], [a2], [b2])
// ---------------------------------------------------------------------
#let tabla(encabezado, columnas: auto, color: auto, tamano: 8.6pt, ..celdas) = context {
  let c = if color == auto { chap-color.get() } else { color }
  let n = encabezado.len()
  block(above: 1.1em, below: 1.2em, table(
    columns: if columnas == auto { n } else { columnas },
    stroke: (x, y) => if y > 0 { (bottom: 0.5pt + gris-claro) },
    inset: (x: 7pt, y: 6pt),
    fill: (x, y) => if y == 0 { c } else if calc.even(y) { c.lighten(95%) } else { white },
    align: left + horizon,
    table.header(..encabezado.map(h => text(fill: white, weight: "bold", size: tamano - 0.3pt, h))),
    ..celdas.pos().map(x => {
      set par(justify: false)
      text(size: tamano, x)
    }),
    table.hline(stroke: 1pt + c),
  ))
}

// Marcas de sí/no/parcial para tablas comparativas
#let si = text(fill: rgb("#2F9E44"), weight: "bold", font: ("Inter", "DejaVu Sans"), "✔")
#let no = text(fill: rgb("#E03131"), weight: "bold", font: ("Inter", "DejaVu Sans"), "✘")
#let parcial = text(fill: rgb("#E39B00"), weight: "bold", font: ("Inter", "DejaVu Sans"), "◐")

// ---------------------------------------------------------------------
//  Pasos numerados
// ---------------------------------------------------------------------
#let pasos(color: auto, ..items) = context {
  let c = if color == auto { chap-color.get() } else { color }
  block(above: 1em, below: 1.1em, {
    for (i, it) in items.pos().enumerate() {
      block(breakable: false, above: 0pt, below: 9pt, grid(
        columns: (auto, 1fr), column-gutter: 10pt,
        circle(radius: 9pt, fill: c, inset: 0pt,
          align(center + horizon, text(8.5pt, fill: white, weight: "bold", str(i + 1)))),
        align(horizon, block(it)),
      ))
    }
  })
}

// ---------------------------------------------------------------------
//  Diagramas
// ---------------------------------------------------------------------

// Icono de servicio: insignia con abreviatura + etiqueta
#let svc(abbr, etiqueta, sub: none, color: col.neutro, ancho: 1.05cm) = box(
  inset: (x: 2pt, y: 2pt),
  align(center, stack(
    dir: ttb, spacing: 3.5pt,
    align(center, box(
      width: ancho, height: 1.05cm, radius: 5pt,
      fill: gradient.linear(color.lighten(8%), color.darken(18%), angle: 90deg),
      align(center + horizon, text(
        if abbr.len() > 4 { 6.2pt } else if abbr.len() > 3 { 7pt } else { 8.5pt },
        weight: "bold", fill: white, abbr)),
    )),
    align(center, box(width: 2.4cm, align(center, {
      set par(justify: false, leading: 0.4em)
      text(7.3pt, weight: "semibold", fill: tinta, etiqueta)
      if sub != none { linebreak(); text(6.3pt, fill: gris, sub) }
    }))),
  )),
)

// Persona / usuario
#let actor(etiqueta: "Usuario", color: marino) = box(inset: 2pt, align(center, stack(
  dir: ttb, spacing: 2pt,
  align(center, circle(radius: 5.5pt, fill: color)),
  align(center, box(width: 20pt, height: 11pt, fill: color, radius: (top: 9pt))),
  v(1.5pt),
  align(center, text(7.3pt, weight: "semibold", fill: tinta, etiqueta)),
)))

// Internet / nube genérica
#let internet(etiqueta: "Internet") = box(
  fill: white, stroke: 1pt + gris, radius: 50%, inset: (x: 12pt, y: 7pt),
  text(7.5pt, weight: "semibold", fill: gris.darken(20%), etiqueta),
)

// Caja simple (recurso genérico, texto libre)
#let caja(contenido, color: col.neutro, ancho: auto, relleno: white) = box(
  width: ancho, fill: relleno, stroke: 1pt + color, radius: 4pt,
  inset: (x: 7pt, y: 5pt),
  align(center, {
    set par(justify: false, leading: 0.4em)
    text(7.3pt, weight: "medium", fill: tinta, contenido)
  }),
)

// Flecha horizontal
#let flecha(etiqueta: none, largo: 1.4cm, color: rgb("#7A8699"), doble: false, punteada: false) = box(
  width: largo, height: 2.6em,
  {
    let st = (paint: color, thickness: 1.2pt, dash: if punteada { "dashed" } else { none })
    let ini = if doble { 5pt } else { 0pt }
    place(left + horizon, dx: ini, line(length: largo - ini - 5pt, stroke: st))
    place(right + horizon, polygon(fill: color, (0pt, 0pt), (7pt, 3.5pt), (0pt, 7pt)))
    if doble { place(left + horizon, polygon(fill: color, (7pt, 0pt), (0pt, 3.5pt), (7pt, 7pt))) }
    if etiqueta != none {
      place(center + top, dy: -1pt, box(width: largo + 0.8cm, align(center, {
        set par(justify: false, leading: 0.3em)
        text(6.4pt, fill: color.darken(25%), weight: "medium", etiqueta)
      })))
    }
  },
)

// Flecha vertical (hacia abajo; `arriba: true` invierte)
#let flecha-v(etiqueta: none, largo: 0.9cm, color: rgb("#7A8699"), doble: false, arriba: false, punteada: false) = box(
  width: 8pt, height: largo,
  {
    let st = (paint: color, thickness: 1.2pt, dash: if punteada { "dashed" } else { none })
    let up = arriba or doble
    let down = not arriba or doble
    place(center + top, dy: if up { 5pt } else { 0pt },
      line(angle: 90deg, length: largo - (if up { 5pt } else { 0pt }) - (if down { 5pt } else { 0pt }), stroke: st))
    if down { place(center + bottom, polygon(fill: color, (0pt, 0pt), (7pt, 0pt), (3.5pt, 7pt))) }
    if up { place(center + top, polygon(fill: color, (3.5pt, 0pt), (7pt, 7pt), (0pt, 7pt))) }
    if etiqueta != none {
      place(left + horizon, dx: 11pt, box(width: 4cm, text(6.4pt, fill: color.darken(25%), weight: "medium", etiqueta)))
    }
  },
)

// Disposición horizontal centrada verticalmente
#let fila(espacio: 4pt, ..items) = {
  let xs = items.pos()
  box(grid(columns: xs.len(), column-gutter: espacio, align: center + horizon, ..xs))
}

// Disposición vertical centrada
#let columna(espacio: 4pt, ..items) = {
  box(grid(columns: 1, row-gutter: espacio, align: center + horizon, ..items.pos()))
}

// Zona / agrupación (Región, VPC, subred, AZ, cuenta...)
#let zona(titulo, color: col.redes, punteada: true, relleno: auto, ancho: auto, body) = box(
  width: ancho,
  stroke: (paint: color, thickness: 1pt, dash: if punteada { "dashed" } else { none }),
  radius: 6pt,
  fill: if relleno == auto { color.lighten(95%) } else { relleno },
  inset: (top: 17pt, x: 9pt, bottom: 9pt),
  {
    place(top + left, dx: -3pt, dy: -13pt, box(
      fill: color, inset: (x: 5pt, y: 2.5pt), radius: 3pt,
      text(6.3pt, weight: "bold", fill: white, tracking: 0.4pt, upper(titulo)),
    ))
    align(center, body)
  },
)

// Marco de figura para diagramas
#let diagrama(pie: none, body) = figure(
  kind: "diagrama",
  supplement: [Figura],
  block(
    width: 100%, breakable: false,
    fill: fondo-suave, stroke: 0.6pt + gris-claro, radius: 8pt,
    inset: (x: 12pt, y: 16pt),
    align(center, body),
  ),
  caption: pie,
)

// Pila de capas (modelos por niveles, p. ej. responsabilidad compartida)
// #capas(("Datos del cliente", col.iam), ("Sistema operativo", col.computo), ...)
#let capas(ancho: 100%, ..items) = block(width: ancho, stack(
  dir: ttb, spacing: 3pt,
  ..items.pos().map(((t, c)) => block(
    width: 100%, fill: c, radius: 4pt, inset: (x: 10pt, y: 6pt),
    align(center, text(8.3pt, weight: "semibold", fill: white, t)),
  )),
))

// ---------------------------------------------------------------------
//  Cierre de capítulo
// ---------------------------------------------------------------------
#let resumen(body) = context {
  let c = chap-color.get()
  block(
    width: 100%, radius: 8pt, clip: true, breakable: true,
    stroke: 1pt + c.lighten(45%), above: 1.6em, below: 1.2em,
    {
      block(width: 100%, spacing: 0pt, fill: c, inset: (x: 14pt, y: 8pt), sticky: true,
        text(10pt, weight: "bold", fill: white, tracking: 0.5pt, "RESUMEN DEL CAPÍTULO"))
      block(width: 100%, spacing: 0pt, fill: c.lighten(94%), inset: (x: 14pt, y: 11pt), {
        set text(9.3pt)
        body
      })
    },
  )
}

// Preguntas de repaso: #repaso(([¿Pregunta?], [Respuesta]), ...)
#let repaso(..qs) = context {
  let c = chap-color.get()
  block(above: 1.4em, below: 1em, {
    block(sticky: true, below: 8pt, text(11pt, weight: "bold", fill: c, "Preguntas de repaso"))
    for (i, (q, a)) in qs.pos().enumerate() {
      block(breakable: false, below: 8pt, grid(
        columns: (auto, 1fr), column-gutter: 8pt,
        box(fill: c.lighten(85%), radius: 3pt, inset: (x: 4pt, y: 2.5pt),
          text(8pt, weight: "bold", fill: c.darken(15%), str(i + 1))),
        {
          text(9.3pt, weight: "semibold", q)
          linebreak()
          text(8.7pt, fill: gris.darken(10%), [_Respuesta:_ #a])
        },
      ))
    }
  })
}

// ---------------------------------------------------------------------
//  Apertura de capítulo
// ---------------------------------------------------------------------
#let _patron(color, filas: 6, columnas: 14, lado: 9pt, sep: 5pt) = box(width: columnas * (lado + sep), height: filas * (lado + sep), {
  for f in range(filas) {
    for k in range(columnas) {
      let h = calc.rem(f * 7 + k * 13 + f * k * 3, 11)
      if h > 3 {
        place(
          dx: k * (lado + sep), dy: f * (lado + sep),
          rect(width: lado, height: lado, radius: 2pt,
            fill: white.transparentize(100% - (h * 2.2%) - 4%)),
        )
      }
    }
  }
})

#let capitulo(titulo, color: col.fundamentos, subtitulo: none, objetivos: (), servicios: ()) = {
  pagebreak(weak: true)
  chap-color.update(color)
  page(header: none, footer: none, margin: 0pt, {
    // Banda superior
    block(width: 100%, height: 55%, spacing: 0pt,
      fill: gradient.linear(color.lighten(5%), color.darken(40%), angle: 35deg), {
        place(top + right, dx: -1.6cm, dy: 1.7cm, _patron(color))
        place(bottom + right, dx: -0.3cm, dy: 2.9cm, context text(
          250pt, weight: "black", fill: white.transparentize(88%),
          {
            let n = counter(heading).get().at(0, default: 0) + 1
            if n < 10 { "0" + str(n) } else { str(n) }
          },
        ))
        place(bottom + left, dx: 2.2cm, dy: -1.6cm, block(width: 15cm, {
          context text(9pt, weight: "bold", fill: white.transparentize(20%), tracking: 3pt,
            "CAPÍTULO " + str(counter(heading).get().at(0, default: 0) + 1))
          v(2pt)
          box(width: 1.4cm, height: 3pt, fill: acento, radius: 2pt)
          v(10pt)
          heading(level: 1, titulo)
          if subtitulo != none {
            v(6pt)
            set par(justify: false)
            text(12.5pt, fill: white.transparentize(12%), subtitulo)
          }
        }))
      })
    // Parte inferior
    block(width: 100%, inset: (x: 2.2cm, top: 1.4cm), spacing: 0pt, {
      if objetivos.len() > 0 {
        text(8.5pt, weight: "bold", fill: color, tracking: 2pt, "EN ESTE CAPÍTULO APRENDERÁS")
        v(10pt)
        grid(
          columns: (1fr, 1fr), column-gutter: 14pt, row-gutter: 10pt,
          ..objetivos.enumerate().map(((i, o)) => grid(
            columns: (auto, 1fr), column-gutter: 8pt,
            box(width: 20pt, height: 20pt, radius: 4pt, fill: color.lighten(85%),
              align(center + horizon, text(8pt, weight: "bold", fill: color, str(i + 1)))),
            align(horizon, text(9.3pt, fill: tinta, o)),
          ))
        )
      }
      if servicios.len() > 0 {
        v(22pt)
        text(8.5pt, weight: "bold", fill: color, tracking: 2pt, "SERVICIOS PROTAGONISTAS")
        v(8pt)
        servicios.map(s => pill(s, color: color)).join(h(5pt))
      }
    })
  })
}

// Apertura de apéndice (sin numeración)
#let apendice(letra, titulo, color: col.fundamentos, subtitulo: none) = {
  pagebreak(weak: true)
  chap-color.update(color)
  block(width: 100%, inset: (y: 4pt), below: 1.4em, {
    text(9pt, weight: "bold", fill: color, tracking: 3pt, "APÉNDICE " + letra)
    v(-4pt)
    heading(level: 1, numbering: none, outlined: true, titulo)
    if subtitulo != none { text(11pt, fill: gris, subtitulo) }
    v(2pt)
    box(width: 100%, height: 2pt, fill: gradient.linear(color, color.lighten(80%)))
  })
}

// ---------------------------------------------------------------------
//  Plantilla del documento
// ---------------------------------------------------------------------
#let guia(titulo: "Guía visual de AWS", body) = {
  set document(title: titulo, author: "Guía visual de AWS")
  set text(font: ("Inter", "DejaVu Sans"), size: 10pt, lang: "es", fill: tinta, hyphenate: true)
  set par(justify: true, leading: 0.68em, spacing: 1.05em)
  set page(
    paper: "a4",
    margin: (x: 2.1cm, top: 2.4cm, bottom: 2.2cm),
    header: context {
      let previos = query(heading.where(level: 1).before(here()))
      if previos.len() == 0 { return }
      let h1 = previos.last()
      let c = chap-color.get()
      set text(7.5pt, fill: gris)
      grid(
        columns: (1fr, auto), align: (left + bottom, right + bottom),
        {
          box(width: 7pt, height: 7pt, radius: 1.5pt, fill: c)
          h(5pt)
          if h1.numbering != none {
            text(weight: "bold", fill: c, numbering("1", counter(heading).at(h1.location()).first()))
            h(4pt)
          }
          text(weight: "semibold", fill: tinta.lighten(25%), h1.body)
        },
        text(tracking: 0.6pt, upper(titulo)),
      )
      v(-3pt)
      line(length: 100%, stroke: 0.5pt + gris-claro)
    },
    footer: context {
      let c = chap-color.get()
      align(center, box(
        fill: c.lighten(88%), inset: (x: 9pt, y: 3.5pt), radius: 8pt,
        text(7.8pt, weight: "bold", fill: c.darken(10%), counter(page).display()),
      ))
    },
  )

  // Títulos
  set heading(numbering: "1.1")
  show heading.where(level: 1): it => {
    set par(justify: false, leading: 0.35em)
    text(32pt, weight: "extrabold", fill: white, hyphenate: false, it.body)
  }
  show heading.where(level: 2): it => {
    v(1.5em, weak: true)
    block(sticky: true, below: 1em, context {
      let c = chap-color.get()
      grid(
        columns: (auto, 1fr), column-gutter: 9pt, align: horizon,
        if it.numbering != none {
          box(fill: c, inset: (x: 6pt, y: 4.5pt), radius: 3.5pt,
            text(9pt, weight: "bold", fill: white, counter(heading).display("1.1")))
        },
        {
          set par(justify: false)
          text(15pt, weight: "bold", fill: marino, hyphenate: false, it.body)
        },
      )
    })
  }
  show heading.where(level: 3): it => {
    v(1.1em, weak: true)
    block(sticky: true, below: 0.7em, context {
      let c = chap-color.get()
      text(11.5pt, weight: "bold", fill: c.darken(15%), hyphenate: false, [#box(width: 4pt, height: 9pt, fill: c, radius: 1pt) #h(3pt) #it.body])
    })
  }
  show heading.where(level: 4): it => block(sticky: true, above: 1em, below: 0.6em,
    text(10pt, weight: "bold", fill: tinta, hyphenate: false, it.body))

  // Listas
  set list(indent: 4pt, body-indent: 7pt, marker: (
    context text(fill: chap-color.get(), font: ("Inter", "DejaVu Sans"), "▸"),
    text(fill: gris, "–"),
  ))
  set enum(indent: 4pt, body-indent: 6pt, numbering: n => context text(weight: "bold", fill: chap-color.get(), str(n) + "."))
  set terms(separator: [: ], hanging-indent: 12pt)
  show terms.item: it => block(below: 0.6em, {
    context text(weight: "bold", fill: chap-color.get().darken(10%), it.term)
    [ — ]
    it.description
  })

  // Énfasis
  show strong: set text(weight: "semibold", fill: marino)

  // Código
  show raw: set text(font: ("JetBrains Mono", "DejaVu Sans Mono"), features: (calt: 0), ligatures: false)
  show raw.where(block: false): it => box(
    fill: rgb("#EEF1F6"), inset: (x: 3pt, y: 0pt), outset: (y: 2.5pt), radius: 2.5pt,
    text(8.6pt, fill: rgb("#24324A"), it),
  )
  show raw.where(block: true): it => context {
    let c = chap-color.get()
    block(
      width: 100%, fill: rgb("#F7F9FC"), radius: (right: 6pt),
      stroke: (left: 3pt + c, rest: 0.5pt + gris-claro),
      inset: (x: 12pt, y: 10pt), above: 1em, below: 1.1em,
      breakable: it.text.split("\n").len() > 22,
      {
        if it.lang != none {
          place(top + right, dx: 6pt, dy: -5pt, text(6.3pt, weight: "bold", fill: c, tracking: 0.8pt, upper(it.lang)))
        }
        set text(8pt)
        set par(justify: false, leading: 0.55em)
        it
      },
    )
  }

  // Figuras
  show figure.caption: it => {
    set text(8pt, fill: gris)
    context text(weight: "bold", fill: chap-color.get(), [#it.supplement #it.counter.display(it.numbering)])
    [ · ]
    it.body
  }
  set figure(gap: 0.7em)
  show figure: set block(above: 1.3em, below: 1.3em)

  // Enlaces
  show link: set text(fill: rgb("#1C7ED6"))

  body
}

// ---------------------------------------------------------------------
//  Índice
// ---------------------------------------------------------------------
#let indice() = {
  set page(header: none)
  block(below: 1.2em, {
    text(9pt, weight: "bold", fill: acento, tracking: 3pt, "CONTENIDO")
    v(-2pt)
    text(30pt, weight: "extrabold", fill: marino, "Índice")
  })
  show outline.entry.where(level: 1): it => {
    v(9pt, weak: true)
    block(sticky: true, link(it.element.location(), grid(
      columns: (26pt, 1fr, auto), align: (left + horizon, left + horizon, right + horizon),
      if it.element.numbering != none {
        box(width: 20pt, height: 18pt, radius: 4pt, fill: marino,
          align(center + horizon, text(8.5pt, weight: "bold", fill: white,
            numbering("1", counter(heading).at(it.element.location()).first()))))
      } else {
        box(width: 20pt, height: 18pt, radius: 4pt, fill: acento,
          align(center + horizon, text(8.5pt, weight: "bold", fill: white, "A")))
      },
      text(10.5pt, weight: "bold", fill: marino, it.element.body),
      text(10pt, weight: "bold", fill: marino, it.page()),
    )))
  }
  show outline.entry.where(level: 2): it => {
    block(above: 3.5pt, below: 3.5pt, link(it.element.location(), grid(
      columns: (26pt, 26pt, 1fr, auto), align: (left, left, left, right),
      [],
      text(8.5pt, fill: gris, numbering("1.1", ..counter(heading).at(it.element.location()))),
      text(8.8pt, fill: tinta, [#it.element.body #box(width: 1fr, repeat(text(fill: gris-claro, " . ")))]),
      text(8.8pt, fill: gris, it.page()),
    )))
  }
  columns(1, outline(title: none, depth: 2, indent: 0pt))
}
