// diagramas.typ — diagramas dibujados con Typst (sin imágenes): estación,
// trámite de la licencia, secuencia de un QSO y hoja de ruta hasta 2027.
#import "../plantilla.typ": *
#import "fonetica.typ": deletrear

// ------------------------------------------------------------ estación
#let diagrama-estacion() = {
  let cm = 1cm
  let fila = 2.43cm // altura del coaxial
  let caja-n(x, y, w, h, t, ..o) = nodo(x * cm, y * cm, w * cm, h * cm, t, ..o)
  let fino = 0.75pt + c.tinta2
  box(width: 100%, height: 5.55cm, {
    // zonas
    place(dx: 0cm, dy: 0cm, rect(width: 5.8cm, height: 5.55cm, radius: 5pt, fill: rgb("#eef5ef")))
    place(dx: 6.1cm, dy: 0cm, rect(width: 11.2cm, height: 5.55cm, radius: 5pt, fill: rgb("#f0f3f8")))
    rotulo(0.3cm, 0.22cm, text(weight: "bold", tracking: 0.1em, fill: c.verde)[TERRAZA], tam: 6.4pt)
    rotulo(6.4cm, 0.22cm, text(weight: "bold", tracking: 0.1em, fill: c.azul-osc)[CUARTO DE RADIO], tam: 6.4pt)
    // pared
    place(line(start: (5.95cm, 0.15cm), end: (5.95cm, 5.4cm), stroke: (paint: c.tenue, thickness: 0.9pt, dash: "dashed")))
    place(dx: 5.4cm, dy: 4.62cm, box(width: 1.1cm, fill: white, radius: 2pt, inset: (y: 2pt), align(center, text(size: 6.2pt, fill: c.tenue, hyphenate: false)[pared o \ ventana])))
    // coaxial
    place(line(start: (3.65cm, fila), end: (10.4cm, fila), stroke: 1.8pt + c.tinta2))
    // cadena de antena
    caja-n(0.35, 1.62, 3.3, 1.62, [*Antena* \ EFHW, vertical o lazo \ #text(size: 6.6pt, fill: c.tinta2)[cerca de 50 Ω en cada banda]], color: c.verde, fondo: white)
    caja-n(4.05, 2.0, 1.5, 0.86, [*Choke 1* \ #text(size: 6.4pt)[en la antena]], color: c.naranja, fondo: white)
    caja-n(6.3, 2.0, 1.5, 0.86, [*Choke 2* \ #text(size: 6.4pt)[al entrar]], color: c.naranja, fondo: white)
    caja-n(8.2, 2.0, 1.8, 0.86, [*Vatímetro* \ #text(size: 6.4pt)[ROE y ≤ 100 W]], color: c.tinta2, fondo: white)
    caja-n(10.4, 1.76, 6.9, 1.34, text(fill: white)[*Transceptor de 100 W* \ #text(size: 6.8pt)[IC-7300MK2 o FT-710 · acoplador interno (≤ 3:1)]], color: c.azul-noche, fondo: c.azul-noche, tam: 8pt)
    // alimentación
    caja-n(12.2, 0.42, 3.5, 0.72, [*Fuente* 13,8 V · ≥ 25 A], color: c.tinta2, fondo: white)
    place(line(start: (13.95cm, 1.14cm), end: (13.95cm, 1.76cm), stroke: fino))
    // periféricos
    caja-n(10.4, 4.3, 2.15, 0.95, [*Mac* \ #text(size: 6.4pt)[logger · voice keyer]], color: c.azul-osc, fondo: white)
    caja-n(12.78, 4.3, 2.15, 0.95, [*Cascos* \ #text(size: 6.4pt)[con micro de pértiga]], color: c.azul-osc, fondo: white)
    caja-n(15.15, 4.3, 2.15, 0.95, [*Pedal* \ #text(size: 6.4pt)[de PTT]], color: c.azul-osc, fondo: white)
    for (x, t) in ((11.47, [USB: CAT + audio]), (13.85, [audio y micro]), (16.22, [PTT])) {
      place(line(start: (x * cm, 3.1cm), end: (x * cm, 4.3cm), stroke: fino))
      rotulo(x * cm + 3pt, 3.46cm, t, tam: 6.2pt)
    }
    // notas
    rotulo(0.35cm, 3.55cm, [Un choke en cada extremo del coaxial evita que la RF vuelva al cuarto por la malla.], tam: 6.6pt, ancho: 4.4cm)
    rotulo(6.3cm, 3.55cm, [Coaxial de 50 Ω corto y de baja pérdida; ferritas en los cables USB y de alimentación.], tam: 6.6pt, ancho: 3.8cm)
  })
}

// ------------------------------------------------------------ licencia
#let diagrama-licencia() = {
  let col = rgb("#4a3aa7")
  let pasos = (
    ([Examen], [Dos partes: técnica y normativa. Certificado *HAREC*. Tasa: 23,67 €.]),
    ([Autorización e indicativo], [Por la sede electrónica. Tasa: 114,36 €. Resolución en 6 semanas (si no, desestimada).]),
    ([Licencia de estación], [Memoria técnica de la antena; la comunidad tiene *2 meses* para alegar.]),
    ([Montaje y seguro], [Seguro de RC; comunicas el fin de montaje y la Jefatura verifica en 30 días.]),
    ([En el aire desde casa], [Con la licencia de estación. Mientras, en *portable* (no la necesita).]),
  )
  box(width: 100%, {
    place(dx: 10%, dy: 8.5pt, line(length: 80%, stroke: 1.2pt + col.lighten(55%)))
    grid(
      columns: (1fr,) * 5,
      column-gutter: 8pt,
      ..pasos.enumerate().map(((i, (t, d))) => {
        set par(justify: false, leading: 0.45em)
        align(center, box(width: 17pt, height: 17pt, radius: 8.5pt, fill: col, stroke: 2pt + white, align(center + horizon, text(
          font: "Inter Display",
          weight: "bold",
          size: 8.5pt,
          fill: white,
        )[#(i + 1)])))
        v(0.25em)
        align(center, text(size: 7.8pt, weight: "bold", fill: col, hyphenate: false)[#t])
        v(-0.3em)
        align(center, text(size: 7.2pt, fill: c.tinta2, hyphenate: false)[#d])
      })
    )
  })
}

// ------------------------------------------------------------ QSO
#let diagrama-qso(cfg) = {
  let cm = 1cm
  let xa = 3.6 // línea de vida de la estación que llama CQ
  let xb = 12.1 // tu línea de vida
  let col-a = c.tinta2
  let col-b = rgb("#b84a1c")
  let msgs = (
    (1.55, "a", "0 s", "CQ contest, Kilo One Alfa Bravo Charlie, contest", [Espera a oír su indicativo completo.]),
    (2.55, "b", "≈ 3 s", deletrear(cfg.indicativo), [Una vez, completo, justo cuando calla.]),
    (3.55, "a", "≈ 5 s", deletrear(cfg.indicativo) + ", five nine zero five", [¿Tu indicativo bien? Copia la zona: 05.]),
    (4.55, "b", "≈ 8 s", "Thank you, five nine one four", [Solo el intercambio: nada más.]),
    (5.55, "a", "≈ 10 s", "Thank you, Kilo One Alfa Bravo Charlie, QRZ", [Registra (#tecla("Enter")) y sigue buscando.]),
  )
  box(width: 100%, height: 6.25cm, {
    // cabeceras
    nodo((xa - 1.9) * cm, 0cm, 3.8cm, 0.78cm, [*K1ABC* · llama CQ · zona 5], color: col-a, fondo: c.papel)
    nodo((xb - 1.9) * cm, 0cm, 3.8cm, 0.78cm, text(fill: white)[*Tú* · #cfg.indicativo · S&P], color: col-b, fondo: col-b)
    for x in (xa, xb) {
      place(line(start: (x * cm, 0.78cm), end: (x * cm, 6.15cm), stroke: (paint: c.tenue, thickness: 0.7pt, dash: "dashed")))
    }
    for (y, quien, t, frase, nota) in msgs {
      let (x1, x2, col) = if quien == "a" { (xa, xb, col-a) } else { (xb, xa, col-b) }
      flecha((x1 * cm, y * cm + 0.12cm), (x2 * cm, y * cm + 0.12cm), color: col, grosor: 1pt)
      rotulo((xa + 0.15) * cm, (y - 0.33) * cm, dice(frase), tam: 7.4pt, ancho: (xb - xa - 0.3) * cm, alinea: center)
      rotulo(0cm, (y - 0.04) * cm, text(weight: "semibold", fill: c.tenue, number-width: "tabular")[#t], tam: 6.8pt, ancho: 1.3cm)
      rotulo((xb + 0.25) * cm, (y - 0.12) * cm, nota, tam: 6.8pt, ancho: (17.3 - xb - 0.25) * cm)
    }
  })
}

// ------------------------------------------------------------ hoja de ruta
#let hoja-de-ruta(hitos) = {
  let col = rgb("#4a3aa7")
  set par(justify: false, leading: 0.48em)
  grid(
    columns: (2.4cm, 1fr),
    column-gutter: 0pt,
    align: (right, left),
    stroke: (x, y) => if x == 1 { (left: 1.4pt + col.lighten(60%)) },
    inset: (x, y) => if x == 0 { (right: 9pt, y: 5pt) } else { (left: 12pt, y: 5pt) },
    ..hitos.map(((cuando, que, como, meta)) => (
      align(right, text(size: 7.8pt, weight: "bold", fill: if meta { col } else { c.tinta2 }, number-width: "tabular")[#cuando]),
      {
        place(dx: -12pt - 4.4pt, dy: 1.6pt, box(width: 8.8pt, height: 8.8pt, radius: 4.4pt, fill: if meta { col } else { white }, stroke: 1.6pt + col))
        text(size: 8.6pt, weight: "bold")[#que]
        h(0.45em)
        text(size: 8.2pt, fill: c.tinta2)[#como]
      },
    )).flatten(),
  )
}

// ------------------------------------------------------------ fórmula de la puntuación
#let formula-puntuacion(ej) = {
  let ficha(valor, etiqueta, col) = box(width: 4.1cm, inset: (x: 8pt, y: 7pt), radius: 5pt, fill: col.lighten(90%), stroke: 0.7pt + col)[
    #set par(justify: false, leading: 0.4em)
    #align(center)[#text(font: "Inter Display", size: 13.5pt, weight: "bold", fill: col)[#valor] \ #text(size: 7.3pt, fill: c.tinta2)[#etiqueta]]
  ]
  let op(t) = text(font: "Inter Display", size: 18pt, weight: "bold", fill: c.tenue)[#t]
  align(center, grid(
    columns: 5,
    column-gutter: 9pt,
    align: horizon,
    ficha([Σ puntos], [suma de los puntos de cada QSO (0, 1 o 3)], c.azul-osc),
    op[×],
    ficha([zonas + países], [multiplicadores, contados en cada una de las seis bandas], rgb("#b84a1c")),
    op[=],
    ficha([puntuación], [la que publica el CQ WW tras comprobar los logs], c.verde),
  ))
  v(0.2em)
  align(center, text(size: 7.8pt, fill: c.tinta2)[Mini-log del ejemplo siguiente: #ej.mini_log.puntos_qso × (#ej.mini_log.zonas + #ej.mini_log.paises) = *#ej.mini_log.total*.])
}

// ------------------------------------------------------------ escucha remota
#let diagrama-escucha() = {
  let cm = 1cm
  let w = 2.78
  let g = 0.85
  let cajas = (
    ([*Antena de hilo* \ #text(size: 6.4pt)[solo recibe; lejos del ruido de casa]], c.verde),
    ([*RTL-SDR Blog V4* \ #text(size: 6.4pt)[conversor de HF interno]], c.azul-osc),
    ([*Raspberry Pi 5* \ #text(size: 6.4pt)[OpenWebRX+ (8073) o SDR++ server (5259)]], c.azul-osc),
    ([*Tailscale* \ #text(size: 6.4pt)[red privada: nada abierto a internet]], c.tinta2),
    ([*Tu Mac* \ #text(size: 6.4pt)[navegador o SDR++; grabas el audio]], c.azul-osc),
  )
  let etiquetas = ([coaxial], [USB], [red], [])
  box(width: 100%, height: 1.25cm, {
    for (i, (t, col)) in cajas.enumerate() {
      let x = i * (w + g)
      nodo(x * cm, 0cm, w * cm, 1.2cm, t, color: col, fondo: white)
      if i < 4 {
        flecha(((x + w) * cm, 0.6cm), ((x + w + g) * cm, 0.6cm), color: c.tinta2, grosor: 0.8pt)
        rotulo((x + w) * cm, 0.22cm, etiquetas.at(i), tam: 5.8pt, ancho: g * cm, alinea: center)
      }
    }
  })
}
