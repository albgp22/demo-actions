#import "../theme.typ": *

// =====================================================================
//  Capítulo 1 — Fundamentos de AWS y la nube
// =====================================================================

// ---- Elementos gráficos propios del capítulo -------------------------

#let _leyenda(c, t) = box({
  box(width: 8pt, height: 8pt, radius: 2pt, fill: c, baseline: 1pt)
  h(4pt)
  text(7.5pt, fill: tinta, t)
})

#let _tu = pill("Tú", color: acento)
#let _aws = pill("AWS", color: col.fundamentos)
#let _ambos = pill("Compartida", color: col.neutro)

// Pila de capas por modelo de servicio (On-premises / IaaS / PaaS / SaaS)
#let _modelos-servicio = {
  let capas = ("Aplicaciones", "Datos", "Runtime", "Middleware", "Sistema operativo",
    "Virtualización", "Servidores", "Almacenamiento", "Red")
  let modelos = (
    ("On-premises", "tu propio centro de datos", 9),
    ("IaaS", "p. ej. Amazon EC2", 5),
    ("PaaS", "p. ej. AWS Elastic Beanstalk", 2),
    ("SaaS", "p. ej. Amazon Connect", 0),
  )
  grid(
    columns: (1fr,) * 4, column-gutter: 10pt,
    ..modelos.map(((nombre, ej, n)) => stack(dir: ttb, spacing: 2.2pt,
      align(center, text(9.5pt, weight: "bold", fill: marino, nombre)),
      align(center, text(6.6pt, fill: gris, ej)),
      v(2pt),
      ..capas.enumerate().map(((i, c)) => box(width: 100%, height: 0.4cm, radius: 2.5pt,
        fill: if i < n { acento } else { col.fundamentos.lighten(12%) },
        align(center + horizon, text(6.8pt, weight: "semibold", fill: white, c)))),
    )),
  )
  v(7pt)
  fila(espacio: 16pt, _leyenda(acento, "Gestionas tú"),
    _leyenda(col.fundamentos.lighten(12%), "Gestiona el proveedor (AWS)"))
}

// Gráfico de capacidad frente a demanda (propia vs. elástica)
#let _demanda = ((0, 0.5), (0.6, 0.7), (1.2, 1.3), (1.8, 1.1), (2.4, 1.6), (3.0, 2.2),
  (3.6, 1.9), (4.2, 2.6), (4.8, 2.9), (5.4, 2.5), (6.0, 3.0), (6.6, 3.2))
#let _fija = ((0, 3.4, 1.9), (3.4, 6.6, 3.05))
#let _elastica = ((0, 0.6, 0.85), (0.6, 1.2, 1.45), (1.2, 1.8, 1.45), (1.8, 2.4, 1.75),
  (2.4, 3.0, 2.35), (3.0, 3.6, 2.35), (3.6, 4.2, 2.75), (4.2, 4.8, 3.05), (4.8, 5.4, 3.05),
  (5.4, 6.0, 3.15), (6.0, 6.6, 3.35))
#let _rojo = rgb("#E03131")
#let _verde = rgb("#2F9E44")

#let _grafico-capacidad = {
  let kx = 1.05cm
  let ky = 0.9cm
  let H = 3.6
  let P(x, y) = (x * kx, (H - y) * ky)
  let escalones(pasos) = {
    let e = ()
    for (x0, x1, y) in pasos { e.push(P(x0, y)); e.push(P(x1, y)) }
    e
  }
  box(width: 6.6 * kx, height: (H + 0.45) * ky, {
    for (x0, x1, y) in _fija {
      place(top + left, dx: x0 * kx, dy: (H - y) * ky,
        rect(width: (x1 - x0) * kx, height: y * ky, fill: col.fundamentos.lighten(84%), stroke: none))
    }
    let ef = escalones(_fija)
    place(top + left, curve(stroke: 1.2pt + col.fundamentos,
      curve.move(ef.first()), ..ef.slice(1).map(p => curve.line(p))))
    for f in (((2.7, 1.9), (3.0, 2.2), (3.4, 2.0), (3.4, 1.9)), ((6.15, 3.05), (6.6, 3.2), (6.6, 3.05))) {
      place(top + left, polygon(fill: _rojo.transparentize(40%), stroke: none, ..f.map(((x, y)) => P(x, y))))
    }
    let ee = escalones(_elastica)
    place(top + left, curve(stroke: (paint: _verde, thickness: 1pt, dash: "dashed"),
      curve.move(ee.first()), ..ee.slice(1).map(p => curve.line(p))))
    place(top + left, curve(stroke: (paint: acento, thickness: 1.8pt, join: "round"),
      curve.move(P(.._demanda.first())),
      .._demanda.slice(1).map(((x, y)) => curve.line(P(x, y)))))
    place(top + left, line(start: (0pt, 0pt), end: (0pt, H * ky), stroke: 0.8pt + gris))
    place(top + left, line(start: (0pt, H * ky), end: (6.6 * kx, H * ky), stroke: 0.8pt + gris))
    place(top + left, dx: 6.6 * kx - 1.1cm, dy: H * ky + 2pt, text(6.3pt, fill: gris, "tiempo →"))
  })
}

#let _leyenda-capacidad = {
  set par(justify: false, leading: 0.5em)
  set text(7.3pt)
  block(width: 6.4cm, {
    grid(columns: 1, row-gutter: 5pt, align: left,
      _leyenda(acento, "Demanda real de tus usuarios"),
      _leyenda(col.fundamentos.lighten(55%), "Capacidad propia: se compra a saltos"),
      _leyenda(_verde, "Capacidad elástica: sigue a la demanda"),
      _leyenda(_rojo.transparentize(40%), "Demanda no atendida (clientes perdidos)"))
    v(6pt)
    text(fill: gris)[La zona gris por encima de la línea naranja es capacidad *pagada y ociosa*; las zonas rojas, picos que tu centro de datos no puede servir. La línea verde muestra lo que harías en la nube: pagar en cada momento algo más de lo que usas, nunca mucho más.]
  })
}

// Anatomía de un ARN
#let _arn = {
  let segs = (
    ("arn", "prefijo", gris, ""),
    ("aws", "partición", col.iam, ""),
    ("ec2", "servicio", col.computo, ""),
    ("eu-west-1", "región", col.redes, "vacía en IAM o S3"),
    ("123456789012", "cuenta", col.datos, "vacía en S3"),
    ("instance/i-0a1b2c3d4e5f67890", "recurso (tipo/ID)", col.almacenamiento, "su formato depende del servicio"),
  )
  let f1 = ()
  let f2 = ()
  let f3 = ()
  for (i, (t, l, c, n)) in segs.enumerate() {
    if i > 0 {
      f1.push(text(13pt, weight: "bold", fill: gris, font: "JetBrains Mono", ":"))
      f2.push([])
      f3.push([])
    }
    f1.push(box(fill: c, radius: 4pt, inset: (x: 5pt, y: 6pt),
      text(8.5pt, font: "JetBrains Mono", weight: "bold", fill: white, t)))
    f2.push(text(7.5pt, weight: "bold", fill: c.darken(15%), l))
    f3.push(text(6.3pt, fill: gris, n))
  }
  grid(columns: f1.len(), column-gutter: 1.5pt, row-gutter: 5pt, align: center + horizon,
    ..f1, ..f2, ..f3)
}

// Línea temporal RPO / RTO
#let _rto-rpo = box(width: 14.6cm, height: 3.1cm, {
  let y = 1.45cm
  let x1 = 2.3cm
  let x2 = 7.0cm
  let x3 = 12.4cm
  place(top + left, dy: y - 0.7pt, line(length: 14.3cm, stroke: 1.4pt + gris.lighten(30%)))
  place(top + left, dx: 14.6cm - 8pt, dy: y - 4pt, polygon(fill: gris.lighten(30%), (0pt, 0pt), (8pt, 4pt), (0pt, 8pt)))
  place(top + left, dx: x1, dy: y - 1.2cm, box(width: x2 - x1, height: 0.72cm, fill: col.datos.lighten(85%),
    stroke: (bottom: 2pt + col.datos), align(center + horizon,
      text(7.6pt, weight: "bold", fill: col.datos.darken(20%))[RPO · datos que puedes perder])))
  place(top + left, dx: x2, dy: y - 1.2cm, box(width: x3 - x2, height: 0.72cm, fill: col.iam.lighten(85%),
    stroke: (bottom: 2pt + col.iam), align(center + horizon,
      text(7.6pt, weight: "bold", fill: col.iam.darken(20%))[RTO · tiempo sin servicio])))
  let hito(x, c, titulo, sub) = {
    place(top + left, dx: x - 5.5pt, dy: y - 5.5pt, circle(radius: 5.5pt, fill: c, stroke: 1.5pt + white))
    place(top + left, dx: x - 2cm, dy: y + 0.32cm, box(width: 4cm, align(center, {
      set par(justify: false, leading: 0.4em)
      set text(hyphenate: false)
      text(7.3pt, weight: "bold", fill: tinta, titulo)
      linebreak()
      text(6.5pt, fill: gris, sub)
    })))
  }
  hito(x1, col.datos, "Último punto de recuperación", "copia o réplica más reciente")
  hito(x2, rgb("#E03131"), "Desastre", "caída de una región, borrado, ransomware…")
  hito(x3, col.almacenamiento, "Servicio restaurado", "la aplicación vuelve a funcionar")
})

// Estrategias de recuperación ante desastres
#let _estrategias-dr = {
  let est = (
    ("Backup & restore", "Horas",
      [Solo copias (snapshots, backups, plantillas de IaC) en otra región; todo se recrea tras el desastre.],
      [AWS Backup, copias entre regiones], rgb("#2F9E44")),
    ("Pilot light", "Decenas de minutos",
      [Datos replicados en vivo y núcleo mínimo listo; los servidores de aplicación, apagados.],
      [Réplicas entre regiones, Elastic Disaster Recovery], rgb("#1098AD")),
    ("Warm standby", "Minutos",
      [Copia completa a escala reducida, siempre en marcha; se amplía al conmutar.],
      [Auto Scaling, conmutación con Route 53], rgb("#E39B00")),
    ("Multi-site activo-activo", "Casi cero",
      [Dos o más regiones sirven tráfico real a la vez, con datos replicados.],
      [DynamoDB global tables, Aurora Global Database], rgb("#C92A2A")),
  )
  grid(
    columns: (1fr,) * 4, column-gutter: 6pt,
    inset: (x: 7pt, y: 6pt),
    fill: (x, y) => if y == 0 { est.at(x).at(4) } else { white },
    stroke: (x, y) => 0.8pt + est.at(x).at(4).lighten(30%),
    ..est.map(e => text(8.3pt, weight: "bold", fill: white, e.at(0))),
    ..est.map(e => {
      set par(justify: false, leading: 0.5em)
      set text(hyphenate: false)
      text(6.5pt, fill: gris, "RTO / RPO típicos")
      linebreak()
      text(10pt, weight: "bold", fill: e.at(4).darken(15%), e.at(1))
      v(1pt)
      text(7.2pt, e.at(2))
      v(1pt)
      text(6.6pt, fill: gris, e.at(3))
    }),
  )
  v(4pt)
  box(width: 100%, height: 12pt, {
    place(left + horizon, box(width: 100% - 9pt, height: 4pt, radius: 2pt,
      fill: gradient.linear(rgb("#2F9E44"), rgb("#E39B00"), rgb("#C92A2A"))))
    place(right + horizon, polygon(fill: rgb("#C92A2A"), (0pt, 0pt), (10pt, 6pt), (0pt, 12pt)))
  })
  grid(columns: (1fr, 1fr),
    align(left, text(7pt, fill: gris)[Menor coste · RTO y RPO mayores]),
    align(right, text(7pt, fill: gris)[Mayor coste · RTO y RPO menores]))
}

// Modelo de responsabilidad compartida
#let _responsabilidad = {
  let cli = acento
  let aw = col.fundamentos
  let etiqueta(t, s) = {
    set par(justify: false, leading: 0.45em)
    set text(hyphenate: false)
    text(11pt, weight: "extrabold", fill: white, t)
    linebreak()
    text(7.4pt, fill: white, s)
  }
  grid(columns: (3.1cm, 1fr), column-gutter: 6pt, row-gutter: 9pt,
    grid.cell(fill: cli.darken(10%), inset: 8pt, align: center + horizon, etiqueta("CLIENTE", "Seguridad EN la nube")),
    stack(dir: ttb, spacing: 3pt,
      capas(("Datos del cliente", cli.darken(4%)),
        ("Plataforma, aplicaciones y gestión de identidades y accesos (IAM)", cli),
        ("Sistema operativo, configuración de red y de firewall", cli.lighten(6%))),
      grid(columns: (1fr, 1fr, 1fr), column-gutter: 3pt,
        ..([Cifrado en el cliente e integridad de los datos],
          [Cifrado en el servidor (sistema de archivos o datos)],
          [Protección del tráfico de red (cifrado, integridad, identidad)]).map(t =>
          block(width: 100%, height: 0.95cm, fill: cli.lighten(14%), radius: 4pt, inset: 4pt,
            align(center + horizon, {
              set par(justify: false, leading: 0.35em)
              text(7pt, weight: "semibold", fill: white, t)
            })))),
    ),
    grid.cell(fill: aw, inset: 8pt, align: center + horizon, etiqueta("AWS", "Seguridad DE la nube")),
    capas(("Software: cómputo · almacenamiento · bases de datos · redes", aw.lighten(20%)),
      ("Hardware e infraestructura global: regiones · zonas de disponibilidad · edge locations", aw)),
  )
}

#let _cpd = caja([Centro de\ datos], ancho: 2.6cm, color: col.redes)

// =====================================================================

#capitulo("Fundamentos de AWS y la nube", color: col.fundamentos,
  subtitulo: [Qué es la nube, cómo se organiza la infraestructura global de AWS y qué reglas del juego conviene conocer antes de crear el primer recurso.],
  objetivos: (
    [Los modelos IaaS, PaaS y SaaS y el paso de CapEx a OpEx],
    [Regiones, zonas de disponibilidad y ubicaciones de borde],
    [El modelo de responsabilidad compartida],
    [Los seis pilares del AWS Well-Architected Framework],
    [Cuentas, usuario root, ARN, etiquetas y cuotas],
    [Alta disponibilidad, tolerancia a fallos y recuperación ante desastres],
  ),
  servicios: ("Infraestructura global", "AWS CLI", "AWS CloudShell", "Service Quotas", "AWS Billing and Cost Management", "AWS Well-Architected Tool"))

== ¿Qué es la nube?

La *computación en la nube* (_cloud computing_) es la entrega bajo demanda de recursos de TI —servidores, almacenamiento, bases de datos, redes, software— a través de Internet y con pago por uso. En lugar de comprar servidores y mantenerlos durante años, alquilas la capacidad que necesitas a un proveedor que opera centros de datos gigantescos, y la devuelves cuando ya no te hace falta. La distinguen el *autoservicio bajo demanda* (creas recursos en minutos desde una consola o una API), el acceso por red, los recursos compartidos entre clientes aislados entre sí, la *elasticidad* y el *servicio medido*: pagas por horas, GB o peticiones.

=== Modelos de servicio: IaaS, PaaS y SaaS

Los servicios se clasifican según cuántas capas de la pila gestiona el proveedor por ti. Cuanto más subes, menos control tienes, pero también menos trabajo operativo:

- *IaaS* (_Infrastructure as a Service_): recibes máquinas virtuales, discos y redes, y gestionas todo lo demás desde el sistema operativo. Ejemplos: Amazon EC2 (servidores virtuales), EBS (discos) y VPC (redes privadas).
- *PaaS* (_Platform as a Service_): aportas código y datos; el proveedor se ocupa del sistema operativo, el runtime, los parches y el escalado. Ejemplo: AWS Elastic Beanstalk; servicios gestionados como Amazon RDS (bases de datos) o AWS Lambda (funciones sin servidores que administrar) siguen la misma filosofía.
- *SaaS* (_Software as a Service_): consumes una aplicación terminada, como un correo web o un CRM; en AWS, Amazon Connect (centro de contacto).

#diagrama(pie: [Quién gestiona cada capa en cada modelo de servicio.])[
  #_modelos-servicio
]

#analogia[*On-premises* es hacer la pizza en casa; *IaaS*, alquilar una cocina equipada; *PaaS*, pedirla a domicilio y servirla en tu mesa; *SaaS*, ir a la pizzería y elegir del menú.]

=== CapEx, OpEx y elasticidad

Un centro de datos propio es un *gasto de capital* (CapEx): compras por adelantado servidores que amortizarás durante años y tienes que adivinar cuánta capacidad necesitarás. La nube lo convierte en *gasto operativo* (OpEx): pagas cada mes lo que consumes. Además aprovechas las economías de escala de AWS, ganas agilidad (un servidor tarda minutos, no semanas) y puedes desplegar en otros continentes en minutos.

La *escalabilidad* es la capacidad de crecer para atender más carga: en vertical (_scale up_, una máquina mayor) o en horizontal (_scale out_, más máquinas). La *elasticidad* va más allá: añadir y quitar capacidad *automáticamente* según la demanda, de modo que pagas solo lo que usas en cada momento. En AWS la consigues con EC2 Auto Scaling (capítulo de Balanceo de carga y Auto Scaling) o con servicios _serverless_, que escalan solos.

#diagrama(pie: [Capacidad propia frente a capacidad elástica a lo largo del tiempo.])[
  #fila(espacio: 18pt, _grafico-capacidad, _leyenda-capacidad)
]

== La infraestructura global de AWS

AWS organiza su infraestructura en una jerarquía sencilla: *regiones* que contienen *zonas de disponibilidad*, que a su vez agrupan *centros de datos*, más una red de *ubicaciones de borde* en cientos de ciudades. Hoy son más de 30 regiones y más de 100 zonas de disponibilidad, y la cifra crece cada año.

Una *región* es un área geográfica concreta con varios centros de datos, identificada por un código: `eu-west-1` (Irlanda), `eu-central-1` (Fráncfort), `eu-south-2` (España), `us-east-1` (Norte de Virginia). Cada región es *independiente*: tus datos no salen de ella salvo que tú los copies o replices. Las regiones abiertas a partir de marzo de 2019 vienen desactivadas (_opt-in_) y hay que habilitarlas antes de usarlas.

Cada región se divide en al menos tres *zonas de disponibilidad* (_Availability Zones_, AZ). Una AZ es uno o más centros de datos con energía, refrigeración y red redundantes, separada de las demás por muchos kilómetros (pero a menos de 100 km) para que un incendio o un corte eléctrico no afecte a dos a la vez. Las AZ se conectan con fibra dedicada y latencias de un solo dígito de milisegundos, lo que permite repartir una aplicación entre varias sin sacrificar rendimiento.

#examen[Los nombres de AZ (`eu-west-1a`) se asignan de forma independiente en cada cuenta: tu `eu-west-1a` puede ser otra ubicación física que la de otra cuenta. Para coordinarte entre cuentas usa el *AZ ID* (`euw1-az1`).]

Las *Local Zones* acercan un subconjunto de servicios (EC2, EBS, subredes…) a grandes ciudades, con latencias de milisegundos de un dígito; se nombran a partir de su región (`us-west-2-lax-1a`) y hay que habilitarlas. Las *Wavelength Zones* viven dentro de redes 5G de operadores. Con *AWS Outposts*, AWS instala y gestiona su hardware en tu centro de datos. Las *ubicaciones de borde* ejecutan CloudFront, Route 53, Global Accelerator, WAF y Shield; no lanzas instancias en ellas.

#diagrama(pie: [Una región agrupa varias AZ aisladas, cada una con uno o más centros de datos. Fuera de las regiones, AWS acerca su infraestructura a los usuarios.])[
  #zona("Región eu-west-1 (Irlanda)", color: col.fundamentos, punteada: false, relleno: white)[
    #fila(espacio: 4pt,
      zona("AZ eu-west-1a", color: col.redes)[#columna(_cpd, _cpd)],
      flecha(doble: true, largo: 2cm, etiqueta: "fibra redundante"),
      zona("AZ eu-west-1b", color: col.redes)[#columna(_cpd, _cpd)],
      flecha(doble: true, largo: 2cm, etiqueta: "< 100 km"),
      zona("AZ eu-west-1c", color: col.redes)[#columna(_cpd, _cpd, _cpd)],
    )
  ]
  #v(10pt)
  #fila(espacio: 8pt,
    zona("Local Zone", color: col.computo)[#svc("LZ", "Cómputo cercano", sub: "junto a una gran ciudad", color: col.computo)],
    zona("Wavelength", color: col.integracion)[#svc("5G", "Dentro de la red 5G", sub: "de un operador", color: col.integracion)],
    zona("AWS Outposts", color: col.neutro)[#svc("OUT", "Hardware de AWS", sub: "en tu centro de datos", color: col.neutro)],
    zona("Edge locations", color: col.edge)[#svc("PoP", "CDN y DNS", sub: "CloudFront, Route 53", color: col.edge)],
  )
]

=== Cómo elegir una región

Sigue este orden: *1) cumplimiento* —si una ley, un contrato o tu política exige que los datos residan en un país o en la UE, no es negociable—; *2) latencia* —cerca de tus usuarios: para una tienda en España, `eu-south-2` (España) o `eu-west-3` (París)—; *3) servicios disponibles* —no todos los servicios ni tipos de instancia están en todas las regiones; las novedades suelen llegar antes a `us-east-1`—; y *4) precio*, que puede variar bastante entre regiones para el mismo recurso.

=== Servicios globales, regionales y zonales

Saber en qué nivel vive cada recurso te dice qué fallos puede sufrir y desde dónde puedes usarlo:

#tarjetas(
  tarjeta("Globales", color: col.iam, subtitulo: "No dependen de una región")[IAM, Route 53, CloudFront, Organizations. En la consola, el selector de región muestra «Global».],
  tarjeta("Regionales", color: col.redes, subtitulo: "Resisten la caída de una AZ")[S3, DynamoDB, SQS, Lambda, VPC, KMS. S3 es regional, aunque los nombres de bucket son únicos en todo el mundo.],
  tarjeta("Zonales", color: col.computo, subtitulo: "Caen si cae su AZ")[Instancias EC2, volúmenes EBS, subredes. Un volumen EBS solo se conecta a instancias de su AZ; para moverlo, usa un _snapshot_ (regional).],
)

== El modelo de responsabilidad compartida

La seguridad se reparte entre AWS y tú. AWS responde de la *seguridad DE la nube*: edificios, hardware, red física y el software que hace funcionar sus servicios. Tú respondes de la *seguridad EN la nube*: lo que pones dentro y cómo lo configuras.

#diagrama(pie: [Modelo de responsabilidad compartida.])[
  #_responsabilidad
]

Cuanto más gestionado es el servicio, más capas asume AWS (el hardware y las instalaciones son siempre suyos):

#tabla(("Quién se ocupa de…", "EC2 (IaaS)", "RDS (gestionado)", "Lambda, S3"), columnas: (1.9fr, 1fr, 1.2fr, 0.9fr),
  [Datos, cifrado, permisos IAM, reglas de red, código], _tu, _tu, _tu,
  [Sistema operativo y sus parches], _tu, _aws, _aws,
  [Software de base (motor de base de datos, runtime)], _tu, [#_aws \ #text(7pt, fill: gris)[tú eliges versión y ventana]], _aws,
  [Alta disponibilidad y escalado], [#_tu \ #text(7pt, fill: gris)[varias AZ, Auto Scaling]], [#_ambos \ #text(7pt, fill: gris)[tú activas Multi-AZ]], _aws)

#examen[«¿Quién parchea el sistema operativo?» En EC2, tú; en RDS y Lambda, AWS. Datos, permisos y cifrado son *siempre* tuyos: un bucket público por error es un fallo del cliente.]

== AWS Well-Architected Framework

El *Well-Architected Framework* reúne las buenas prácticas y preguntas que AWS ha destilado de miles de arquitecturas reales para evaluar un diseño y detectar riesgos a tiempo. Tiene seis pilares:

#tarjetas(columnas: 3,
  tarjeta("Excelencia operativa", color: col.observabilidad, subtitulo: "Operar, observar y mejorar")[
    - Operaciones como código.
    - Cambios pequeños y reversibles; aprender de cada fallo.
  ],
  tarjeta("Seguridad", color: col.seguridad, subtitulo: "Proteger datos y sistemas")[
    - Identidad sólida y mínimo privilegio.
    - Trazabilidad, seguridad en todas las capas, cifrado.
  ],
  tarjeta("Fiabilidad", color: col.datos, subtitulo: "Funcionar y recuperarse")[
    - Recuperación automática y probada.
    - Escalar en horizontal; no adivinar capacidad.
  ],
  tarjeta("Eficiencia del rendimiento", color: col.computo, subtitulo: "Los recursos adecuados")[
    - Tecnologías avanzadas como servicio.
    - Serverless, alcance global y experimentación.
  ],
  tarjeta("Optimización de costes", color: col.costes, subtitulo: "Máximo valor por euro")[
    - Gestión financiera de la nube (FinOps).
    - Pagar por consumo y atribuir el gasto.
  ],
  tarjeta("Sostenibilidad", color: col.almacenamiento, subtitulo: "Menor impacto ambiental")[
    - Medir el impacto y maximizar la utilización.
    - Hardware y servicios más eficientes.
  ],
)

#consejo[La *AWS Well-Architected Tool* de la consola guía gratis la revisión de una carga pilar a pilar, con *lentes* especializadas (Serverless, SaaS, IA generativa…). Recuerda que los pilares compiten: más fiabilidad suele costar más.]

== Formas de trabajar con AWS

En AWS *todo es una API*. Cada clic en la consola, cada comando y cada llamada de un SDK se convierten en una petición HTTPS a un _endpoint_ del servicio (como `ec2.eu-west-1.amazonaws.com`), firmada con tus credenciales (Signature Version 4) y registrada por AWS CloudTrail (capítulo de Observabilidad). Lo que cambia es la herramienta: la *consola* web, para explorar y tareas puntuales; la *AWS CLI v2* (`aws <servicio> <acción>`), para consultas rápidas y scripts; *AWS CloudShell*, una terminal en el navegador ya autenticada con tu identidad de la consola, con la CLI instalada y 1 GB persistente por región; los *SDK* (boto3 para Python, JavaScript, Java, Go…), para integrar AWS en tus aplicaciones; y la *infraestructura como código* (CloudFormation, CDK, Terraform), la forma recomendada de gestionar entornos (capítulo de Infraestructura como código).

```bash
aws sts get-caller-identity     # ¿con qué identidad y en qué cuenta estoy?
aws s3 ls --profile prod --region eu-south-2    # perfil y región explícitos
```

== Cuentas, usuario root e identificadores

Una *cuenta AWS* es el contenedor de tus recursos y, a la vez, un *límite de seguridad* y de *facturación*. Se identifica con 12 dígitos (`123456789012`); lo habitual es usar varias, agrupadas con AWS Organizations, que verás en el capítulo «IAM (II)».

=== El usuario root

Al crear la cuenta nace su *usuario root*, que entra con el correo y la contraseña del registro y tiene *acceso total e irrestricto*, facturación incluida. Las políticas de IAM no pueden limitarlo en su propia cuenta, así que es tu credencial más valiosa. Úsalo solo para las pocas tareas que lo exigen —cambiar el correo o la contraseña root, cerrar la cuenta, restaurar permisos si el único administrador se ha bloqueado, activar _MFA Delete_ en S3…— y protégelo así:

#pasos(
  [*Activa MFA* (autenticación multifactor: un segundo factor además de la contraseña), mejor con una llave FIDO2 o una _passkey_, y registra más de un dispositivo. AWS la exige de forma progresiva al root desde 2024.],
  [*No crees access keys* de root (las claves para usar la CLI o la API) y elimina las que existan.],
  [Usa un *correo corporativo* compartido (una lista de distribución) y una contraseña larga guardada en un gestor.],
  [Trabaja a diario con otra identidad (idealmente de IAM Identity Center) y *vigila* con una alerta cada inicio de sesión del root. Con Organizations puedes incluso eliminar las credenciales root de las cuentas miembro (gestión centralizada del acceso root, 2024).],
)

=== Anatomía de un ARN

Cada recurso tiene un identificador único global, el *Amazon Resource Name* (ARN), que usarás en políticas de IAM, en la CLI y en plantillas:

#diagrama(pie: [Partes de un ARN. La partición es `aws` en las regiones comerciales (`aws-cn` en China, `aws-us-gov` en GovCloud).])[
  #_arn
]

```text
arn:aws:iam::123456789012:role/app-web               # IAM es global: sin región
arn:aws:s3:::mis-fotos/2026/gato.jpg                 # S3: sin región ni cuenta
arn:aws:s3:::mis-fotos/*                             # comodín: todos los objetos
```

== Etiquetas y cuotas de servicio

Una *etiqueta* (_tag_) es un par clave-valor que adjuntas a un recurso, como `Entorno=prod` o `Proyecto=tienda`. Sirven para *repartir costes* (las _cost allocation tags_ se activan en la consola de facturación), *automatizar* (apagar de noche todo lo que tenga `Horario=oficina`), *controlar el acceso* por atributos (ABAC, capítulo «IAM (II)») y *organizar* (Resource Groups, Tag Editor). La mayoría de servicios admiten hasta 50 etiquetas por recurso, que distinguen mayúsculas y minúsculas; el prefijo `aws:` está reservado. Define unas pocas obligatorias y aplícalas desde tu código de infraestructura.

Cada cuenta tiene además *cuotas* por servicio y, casi siempre, por región: protegen a AWS de abusos y a ti de errores caros. Unas son *ajustables* y se amplían pidiéndolo en la consola de *Service Quotas* (o con `aws service-quotas`); otras son *fijas*, parte del diseño del servicio. Revísalas antes de un lanzamiento, porque un aumento puede tardar desde minutos hasta días.

#tabla(("Cuota", "Valor por defecto", "¿Ajustable?"), columnas: (2.6fr, 1fr, 0.8fr),
  [VPC por región (Amazon VPC)], [5], si,
  [Ejecuciones concurrentes por región (AWS Lambda)], [1000], si,
  [Duración máxima de una invocación (AWS Lambda)], [15 minutos], no,
  [Usuarios IAM por cuenta], [5000], no)

== Facturación básica y capa gratuita

AWS factura *por uso*: tiempo de cómputo, GB-mes almacenados, peticiones y GB transferidos. La entrada de datos desde Internet suele ser gratuita; la salida a Internet, entre regiones y entre AZ se paga. Hay descuentos por compromiso (Savings Plans) y capacidad sobrante barata pero interrumpible (Spot), que verás en el capítulo de EC2; para controlar el gasto, *Cost Explorer*, *AWS Budgets* y la *Pricing Calculator* (capítulo de Costes).

La *capa gratuita* (_Free Tier_) cambió el 15 de julio de 2025: las cuentas nuevas reciben *créditos promocionales* y eligen entre un plan gratuito, limitado en tiempo y servicios, y un plan de pago; algunos servicios mantienen ofertas «siempre gratuitas». Las cuentas anteriores conservan sus ofertas de 12 meses hasta que vencen. Consulta las condiciones vigentes.

#coste[Sorpresas habituales: recursos olvidados en otra región, NAT Gateways, IPv4 públicas (de pago por hora desde febrero de 2024), snapshots huérfanos y transferencia de salida. Crea un presupuesto con alertas en AWS Budgets *el primer día*.]

== Disponibilidad, tolerancia a fallos y recuperación ante desastres

#tarjetas(columnas: 3,
  tarjeta("Alta disponibilidad", color: col.datos, subtitulo: "Minimizar la caída")[Ante un fallo puede haber un corte breve mientras conmuta. *Ej.:* RDS Multi-AZ conmuta a su réplica en uno o dos minutos.],
  tarjeta("Tolerancia a fallos", color: col.computo, subtitulo: "Ninguna interrupción visible")[Redundancia activa: sigue funcionando aunque falle un componente. *Ej.:* instancias en tres AZ con margen para perder una.],
  tarjeta("Recuperación (DR)", color: col.seguridad, subtitulo: "Volver tras un evento grave")[_Disaster recovery_: restaurar el servicio tras perder una región, un borrado masivo o un _ransomware_. Se mide con RTO y RPO.],
)

La disponibilidad se expresa en «nueves»; cada nueve más divide por diez la caída permitida. La redundancia es la palanca: dos instancias independientes del 99~% solo fallan a la vez con probabilidad 0,01 × 0,01, así que juntas llegan al 99,99~%.

#datos(("99,9 %", [≈ 8,8 h de caída al año]), ("99,95 %", [≈ 4,4 h al año]), ("99,99 %", [≈ 53 min al año]), ("99,999 %", [≈ 5 min al año]))

La recuperación ante desastres se diseña con dos objetivos: el *RPO* (_Recovery Point Objective_), cuántos datos puedes perder —un RPO de 1 hora exige copias o réplicas al menos cada hora—, y el *RTO* (_Recovery Time Objective_), cuánto puede durar la caída.

#diagrama(pie: [El RPO mira hacia atrás (datos perdidos); el RTO, hacia delante (tiempo hasta recuperar el servicio).])[
  #_rto-rpo
]

AWS describe cuatro estrategias, de más barata y lenta a más cara y rápida. Elige según el RTO y el RPO que exija el negocio, no por defecto la más sofisticada:

#diagrama(pie: [Estrategias de recuperación ante desastres entre regiones.])[
  #_estrategias-dr
]

#examen[«Lo más barato, RTO de horas» → _backup & restore_; «datos replicados y servidores apagados» → _pilot light_; «versión reducida siempre en marcha» → _warm standby_; «RTO y RPO casi cero» → _multi-site_. Y un plan de recuperación sin probar no es un plan.]

#resumen[
- La nube ofrece recursos de TI bajo demanda y con pago por uso: convierte CapEx en OpEx y aporta elasticidad. IaaS, PaaS y SaaS difieren en cuántas capas gestiona el proveedor.
- Una región es un área geográfica independiente con al menos tres AZ aisladas y bien conectadas; Local Zones, Wavelength, Outposts y las ubicaciones de borde acercan la infraestructura a los usuarios.
- Elige región por cumplimiento, latencia, servicios y precio; distingue servicios globales (IAM), regionales (S3) y zonales (EC2, EBS).
- AWS se ocupa de la seguridad *de* la nube; tú, de la seguridad *en* la nube, con una frontera que depende del servicio.
- El Well-Architected Framework tiene seis pilares: excelencia operativa, seguridad, fiabilidad, eficiencia del rendimiento, costes y sostenibilidad.
- Todo es una API (consola, CLI, SDK, IaC). Protege el root con MFA y no lo uses a diario; ARN, etiquetas y cuotas son el vocabulario básico.
- Alta disponibilidad, tolerancia a fallos y recuperación ante desastres son cosas distintas; la última se diseña a partir del RTO y el RPO.
]

#repaso(
  ([¿Qué diferencia hay entre escalabilidad y elasticidad?], [La escalabilidad es poder crecer para atender más carga; la elasticidad es ajustar la capacidad automáticamente, en ambos sentidos, según la demanda, pagando solo lo usado.]),
  ([Debes guardar datos de clientes europeos dentro de la UE y la mayoría de usuarios están en España. ¿Qué miras primero al elegir región?], [El cumplimiento (una región de la UE) y después la latencia, por ejemplo `eu-south-2`; luego, servicios disponibles y precio.]),
  ([¿Por qué conviene desplegar una aplicación en al menos dos AZ?], [Porque las AZ están aisladas físicamente: si una falla, la otra sigue sirviendo.]),
  ([En EC2, ¿quién aplica los parches del sistema operativo? ¿Y en RDS?], [En EC2, el cliente. En RDS, AWS, dentro de la ventana de mantenimiento que elige el cliente.]),
  ([Tienes un volumen EBS en `eu-west-1a` y quieres conectarlo a una instancia de `eu-west-1b`. ¿Qué haces?], [EBS es zonal: crea un snapshot del volumen (los snapshots son regionales) y restaura a partir de él un volumen nuevo en `eu-west-1b`.]),
  ([¿Por qué el ARN de un objeto S3 no lleva región ni cuenta?], [Porque los nombres de bucket son únicos en todo el mundo: el nombre basta para identificarlo.]),
  ([El negocio tolera perder 5 minutos de datos y 30 minutos de caída, con presupuesto ajustado. ¿Qué estrategia de DR encaja?], [_Pilot light_: datos replicados de forma continua (RPO de minutos) e infraestructura lista para arrancar en decenas de minutos, sin pagar una copia completa en marcha.]),
)
