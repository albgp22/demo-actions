#import "../theme.typ": *

// ---------------------------------------------------------------------
//  Utilidades locales de este capítulo (diagramas a medida)
// ---------------------------------------------------------------------
#let _m(s, size: 7.4pt) = text(font: "JetBrains Mono", size: size, s)

// En este capítulo las cajas destacadas no se parten entre páginas
#let _entera(caja-tema) = (titulo: none, body) => block(breakable: false,
  above: 1.1em, below: 1.1em, caja-tema(titulo: titulo, body))
#let nota = _entera(nota)
#let consejo = _entera(consejo)
#let cuidado = _entera(cuidado)
#let examen = _entera(examen)
#let coste = _entera(coste)
#let practica = _entera(practica)
#let analogia = _entera(analogia)

// Un octeto en binario: los bits de red van en color y los de host en blanco
#let _octeto(valor, inicio, prefijo, c) = {
  let celdas = range(8).map(k => {
    let bit = calc.rem(calc.quo(valor, calc.pow(2, 7 - k)), 2)
    let red = inicio + k < prefijo
    box(width: 0.3cm, height: 0.42cm, radius: 1.5pt,
      fill: if red { c } else { white },
      stroke: if red { none } else { 0.6pt + c.lighten(45%) },
      align(center + horizon, text(6.5pt, weight: "bold", font: "JetBrains Mono",
        fill: if red { white } else { c.darken(10%) }, str(bit))))
  })
  stack(dir: ttb, spacing: 3pt,
    align(center, text(8.5pt, weight: "bold", fill: tinta, str(valor))),
    stack(dir: ltr, spacing: 1.2pt, ..celdas))
}

#let _ip-bits(ip, prefijo, c) = {
  let os = ip.split(".").map(int)
  let partes = ()
  for (i, o) in os.enumerate() {
    if i > 0 { partes.push(text(11pt, weight: "bold", fill: gris, ".")) }
    partes.push(_octeto(o, i * 8, prefijo, c))
  }
  grid(columns: partes.len(), column-gutter: 2.5pt, align: center + bottom, ..partes)
}

#let _bits-fila(ip, prefijo, titulo, detalle, c: col.redes) = (
  block(width: 2.9cm, {
    set par(justify: false, leading: 0.45em)
    text(11pt, weight: "extrabold", fill: c, "/" + str(prefijo))
    h(4pt)
    text(7.5pt, weight: "semibold", fill: tinta, titulo)
    linebreak()
    text(6.8pt, fill: gris, detalle)
  }),
  _ip-bits(ip, prefijo, c),
)

// Celdas del plan de direccionamiento
#let _celda(cidr, nota, c) = block(width: 100%, fill: c.lighten(90%),
  stroke: 0.6pt + c.lighten(35%), radius: 4pt, inset: (x: 4pt, y: 5pt),
  align(center, {
    text(8pt, weight: "bold", font: "JetBrains Mono", fill: c.darken(30%), cidr)
    linebreak()
    text(6.5pt, fill: gris, nota)
  }))

#let _capa(nombre, detalle, c) = block(width: 100%,
  fill: gradient.linear(c, c.darken(20%)), radius: 4pt, inset: (x: 7pt, y: 5pt),
  align(left, {
    set par(justify: false, leading: 0.45em)
    text(8pt, weight: "bold", fill: white, nombre)
    linebreak()
    text(6.5pt, fill: white.transparentize(10%), detalle)
  }))

// Mini tabla de rutas para los diagramas
#let _rt(titulo, color: col.redes, ..rutas) = box(
  stroke: 0.8pt + color.lighten(30%), radius: 4pt, clip: true, fill: white,
  table(columns: 2, stroke: none, inset: (x: 5pt, y: 2.6pt), align: left,
    fill: (x, y) => if y == 0 { color.lighten(85%) },
    table.cell(colspan: 2, text(6.4pt, weight: "bold", fill: color.darken(30%), titulo)),
    ..rutas.pos().map(((d, t)) => (
      text(6.6pt, font: "JetBrains Mono", fill: tinta, d),
      text(6.6pt, font: "JetBrains Mono", weight: "bold", fill: color.darken(25%), "→ " + t),
    )).flatten()))

// Campo de un registro de Flow Logs
#let _campo(valor, nombre, c) = stack(dir: ttb, spacing: 3pt,
  align(center, box(fill: c.lighten(86%), stroke: 0.6pt + c.lighten(30%), radius: 3pt,
    inset: (x: 4pt, y: 4pt),
    text(7.5pt, weight: "bold", font: "JetBrains Mono", fill: c.darken(30%), valor))),
  align(center, text(6.3pt, fill: gris, nombre)))

// Una AZ del diseño de referencia
#let _az(letra, pub, app, dat, rds) = zona("AZ " + letra, color: col.neutro)[
  #columna(espacio: 2pt,
    zona("Pública " + pub, color: col.almacenamiento, ancho: 3.55cm)[#svc("NAT", "NAT Gateway", color: col.redes)],
    flecha-v(largo: 0.45cm, arriba: true),
    zona("App " + app, color: col.computo, ancho: 3.55cm)[#svc("ECS", "Tareas o EC2", color: col.computo)],
    flecha-v(largo: 0.45cm),
    zona("Datos " + dat, color: col.datos, ancho: 3.55cm)[#svc("RDS", rds, color: col.datos)],
  )
]

// =====================================================================

#capitulo(text(hyphenate: false)[Redes: VPC y conectividad], color: col.redes,
  subtitulo: [Construye tu propia red privada en AWS: direcciones, subredes, rutas, salida a Internet, cortafuegos y conexiones con otras redes y con tu centro de datos.],
  objetivos: (
    [Calcular rangos CIDR y planificar direcciones sin solapamientos],
    [Diseñar subredes públicas y privadas repartidas en varias AZ],
    [Entender tablas de rutas, Internet Gateway y NAT Gateway],
    [Combinar Security Groups y Network ACL con criterio],
    [Acceder en privado a servicios de AWS con VPC Endpoints],
    [Conectar VPC entre sí y con tu red local],
  ),
  servicios: ("Amazon VPC", "NAT Gateway", "VPC Endpoints", "AWS PrivateLink", "AWS Transit Gateway", "VPC Lattice", "Site-to-Site VPN", "AWS Direct Connect", "Route 53 Resolver", "VPC Flow Logs"))

== Direccionamiento IP y CIDR en cinco minutos

Casi todo lo que despliegas en AWS —una instancia EC2, una base de datos RDS, una tarea de ECS, un balanceador o una función Lambda conectada a tu red— recibe una dirección IP dentro de una red que diseñas tú. Antes de construirla, repasemos cómo se escriben y se reparten esas direcciones: con cuatro ideas tendrás suficiente para todo el capítulo.

Una dirección *IPv4* tiene 32 bits que se escriben como cuatro números de 0 a 255 (octetos) separados por puntos, como `10.0.1.25`. La notación *CIDR* (_Classless Inter-Domain Routing_) describe un bloque de direcciones con una dirección base y un *prefijo*: en `10.0.0.0/16`, los primeros 16 bits son fijos e identifican la red, y los 16 restantes quedan libres para numerar equipos. Cuantos más bits fijos, más pequeño es el bloque: un /_n_ contiene 2#super[32−_n_] direcciones. Para redes privadas se usan los rangos de la RFC 1918, que no se enrutan en Internet: `10.0.0.0/8`, `172.16.0.0/12` y `192.168.0.0/16`.

#diagrama(pie: [Cada bit del prefijo queda fijo (en color) y los restantes numeran direcciones (en blanco). Del /16 al /28, el bloque pasa de 65 536 a 16 direcciones.])[
  #grid(columns: 2, column-gutter: 14pt, row-gutter: 12pt, align: (left + horizon, center + horizon),
    .._bits-fila("10.0.0.0", 16, "VPC", "16 bits libres: 65 536 IPs"),
    .._bits-fila("10.0.1.0", 24, "Subred", "8 bits libres: 256 IPs"),
    .._bits-fila("10.0.1.16", 28, "Mínimo", "4 bits libres: 16 IPs"),
  )
]

#tabla(("Prefijo", "Direcciones", "Utilizables en AWS", "Uso típico"), columnas: (0.75fr, 0.95fr, 1.15fr, 3fr),
  [#strong("/16")], [65~536], [65~531], [VPC grande: es el máximo que admite AWS],
  [#strong("/20")], [4~096], [4~091], [Subredes de la VPC por defecto; subredes para contenedores],
  [#strong("/24")], [256], [251], [La subred «clásica»: fácil de leer y de calcular],
  [#strong("/26")], [64], [59], [Subred pequeña (por ejemplo, para bases de datos)],
  [#strong("/28")], [16], [11], [El mínimo permitido: subredes de tránsito o para _endpoints_],
)

=== Las cinco direcciones reservadas

En cada subred, AWS reserva las cuatro primeras direcciones y la última. Para la subred `10.0.0.0/24`:

#datos((".0", [Dirección de red]), (".1", [Router de la VPC]), (".2", [DNS de Amazon]), (".3", [Uso futuro]), (".255", [Difusión]))

La última se reserva aunque la VPC no admite difusión (_broadcast_). Por eso una /24 ofrece 251 direcciones utilizables y una /28, solo 11. Y recuerda que balanceadores, NAT Gateways, endpoints o tareas de Fargate crean interfaces de red (ENI) en tus subredes: cada una consume una dirección.

#examen[Las cinco IPs reservadas son un clásico. Si te piden «al menos 30 instancias en una subred», una /27 no basta (32 − 5 = 27 utilizables): necesitas una /26.]

== Amazon VPC: tu red privada en la nube

Una *VPC* (_Virtual Private Cloud_) es una red virtual aislada lógicamente del resto de clientes de AWS, en la que decides el rango de direcciones, las subredes, las rutas y los cortafuegos. Es un recurso *regional*: abarca todas las zonas de disponibilidad (AZ) de la región, mientras que cada subred vive en una sola AZ.

#ficha("Amazon VPC", "Red virtual privada y aislada dentro de una región",
  ("Ámbito", [Regional; cada subred pertenece a una única AZ]),
  ("Tamaño", [IPv4 de /16 a /28, ampliable con bloques secundarios; IPv6 opcional]),
  ("Coste", [La VPC, las subredes, las tablas de rutas, los Security Groups y las NACL son gratis. Se paga por NAT Gateway, endpoints de interfaz, VPN, Transit Gateway, IPv4 públicas y transferencia de datos]),
  ("Cuotas", [5 VPC por región y 5 bloques IPv4 por VPC por defecto (ambas ajustables)]))

#analogia[Una VPC es como una planta de oficinas que alquilas en exclusiva: tú numeras los despachos (direcciones IP), levantas tabiques (subredes), decides dónde está la puerta a la calle (Internet Gateway) y pones vigilantes en cada puerta (Security Groups y NACL).]

=== VPC por defecto frente a VPC personalizada

#tarjetas(
  tarjeta("VPC por defecto", subtitulo: "Lista para usar en cada región")[
    - CIDR `172.31.0.0/16` y una subred /20 en cada AZ.
    - Internet Gateway con ruta `0.0.0.0/0`: todas las subredes son públicas y las instancias reciben IPv4 pública.
    - Perfecta para pruebas, no para producción.
  ],
  tarjeta("VPC personalizada", color: col.arquitectura, subtitulo: "La que diseñas tú")[
    - CIDR coordinado con el resto de tus redes.
    - Subredes públicas y privadas con tablas de rutas explícitas.
    - Salida a Internet controlada (NAT, endpoints): la opción para cualquier entorno serio.
  ],
)

=== Elegir el CIDR sin solapamientos

El CIDR principal de una VPC no se puede cambiar. Elígelo pensando en todas las redes con las que algún día tendrás que hablar: otras VPC, tu centro de datos, las oficinas o redes de socios. Si dos redes conectadas comparten direcciones, el router no sabe adónde enviar los paquetes; AWS ni siquiera permite un peering entre VPC con CIDR solapados.

Lo habitual es un *plan de direccionamiento* central: por ejemplo, `10.0.0.0/16` para producción, `10.1.0.0/16` para preproducción y `10.2.0.0/16` para desarrollo, evitando el `192.168.0.0/16` de las oficinas. En organizaciones grandes, *Amazon VPC IP Address Manager* (IPAM) automatiza el reparto entre cuentas y regiones.

#consejo[Renumerar una red en producción es un proyecto doloroso. Ante la duda, sé generoso: las direcciones privadas no cuestan nada, y un /16 por VPC es una elección habitual. Si borras la VPC por defecto de una región, puedes recrearla con `aws ec2 create-default-vpc`.]

=== Bloques secundarios e IPv6

Si te quedas corto, puedes *asociar bloques CIDR secundarios* a la VPC y crear subredes en ellos. No pueden solaparse y hay combinaciones restringidas: si el bloque principal pertenece a `10.0.0.0/8`, no puedes añadir bloques de los otros rangos RFC 1918, pero sí del rango `100.64.0.0/10`, muy usado para dar direcciones a los pods de Kubernetes (lo verás en el capítulo «Kubernetes y Amazon EKS»).

La VPC también puede ser *dual stack*: le asocias un bloque IPv6 /56 proporcionado por Amazon (o tus propias direcciones) y cada subred recibe un /64. Las IPv6 que asigna Amazon son públicas (globalmente únicas): lo que decide si son accesibles desde Internet son las rutas y los cortafuegos, y no hace falta NAT para salir. A cambio, no tienen el coste por hora de las IPv4 públicas. También puedes crear subredes solo IPv6.

== Subredes y zonas de disponibilidad

Una *subred* es un trozo del CIDR de la VPC que vive en una única AZ; al lanzar una instancia eliges la subred y, con ella, la AZ. Como una subred no puede abarcar varias AZ, la alta disponibilidad se consigue *repitiendo* cada capa en dos o, mejor, tres AZ.

El CIDR de una subred debe estar contenido en el de la VPC (entre /16 y /28) y no puede solaparse con el de otras subredes. El atributo _Auto-assign public IPv4 address_ decide si las instancias nuevas reciben una IP pública. La @fig-redes-plan muestra un plan típico de tres capas en tres AZ, que reutilizaremos al final del capítulo.

#diagrama(pie: [Plan de direcciones para una VPC 10.0.0.0/16 con tres capas en tres AZ. La capa de aplicación recibe bloques grandes porque los contenedores consumen muchas IPs.])[
  #grid(columns: (2.9cm, 1fr, 1fr, 1fr), column-gutter: 6pt, row-gutter: 6pt, align: center + horizon,
    [], ..("eu-west-1a", "eu-west-1b", "eu-west-1c").map(z => text(7.5pt, weight: "bold", fill: col.redes.darken(20%), z)),
    _capa("Pública", "ALB, NAT Gateway", col.almacenamiento),
    _celda("10.0.0.0/24", "251 IPs", col.almacenamiento),
    _celda("10.0.1.0/24", "251 IPs", col.almacenamiento),
    _celda("10.0.2.0/24", "251 IPs", col.almacenamiento),
    _capa("Aplicación", "Privada · EC2, ECS, Lambda", col.computo),
    _celda("10.0.16.0/20", "4 091 IPs", col.computo),
    _celda("10.0.32.0/20", "4 091 IPs", col.computo),
    _celda("10.0.48.0/20", "4 091 IPs", col.computo),
    _capa("Datos", "Privada · RDS, ElastiCache", col.datos),
    _celda("10.0.64.0/24", "251 IPs", col.datos),
    _celda("10.0.65.0/24", "251 IPs", col.datos),
    _celda("10.0.66.0/24", "251 IPs", col.datos),
    grid.cell(colspan: 4, block(width: 100%, stroke: (paint: gris, dash: "dashed", thickness: 0.7pt),
      radius: 4pt, inset: 5pt,
      text(7pt, fill: gris.darken(15%))[Libre: casi el 80 % del /16 queda disponible para nuevas capas, una cuarta AZ o servicios futuros])),
  )
] <fig-redes-plan>

#examen[Los nombres de AZ (`eu-west-1a`) se asignan de forma independiente en cada cuenta: tu `eu-west-1a` puede no ser la misma AZ física que la de otra cuenta. Para coordinarte entre cuentas usa el *AZ ID* (`euw1-az1`), que identifica la misma ubicación física para todos.]

== Tablas de rutas

Cada subred está asociada a exactamente una *tabla de rutas* (_route table_), que decide adónde enviar el tráfico según su destino. Una misma tabla puede servir a varias subredes. Toda VPC tiene una *tabla principal* (_main_), que se aplica a las subredes sin asociación explícita.

Todas las tablas incluyen la *ruta local* (el CIDR de la VPC hacia `local`), que permite que cualquier subred alcance a cualquier otra dentro de la VPC. No se puede borrar: dentro de una VPC, el aislamiento entre subredes no lo dan las rutas, sino los Security Groups y las NACL. Esta es la tabla de una subred privada típica:

#tabla(("Destino", "Target", "Para qué sirve"), columnas: (1.35fr, 1.45fr, 2fr),
  [`10.0.0.0/16`], [`local`], [Tráfico dentro de la VPC (siempre presente)],
  [`10.20.0.0/16`], [`pcx-0a1b2c3d` (peering)], [Llegar a la VPC de servicios compartidos],
  [`192.168.0.0/16`], [`tgw-0f1e2d3c` (Transit Gateway)], [Llegar al centro de datos],
  [`pl-1a2b3c4d` (_prefix list_ de S3)], [`vpce-09a8b7c6` (gateway endpoint)], [Hablar con S3 sin pasar por el NAT],
  [`0.0.0.0/0`], [`nat-0123abcd` (NAT Gateway)], [Todo lo demás: salida a Internet],
)

Cuando varias rutas coinciden con un destino, gana la *más específica*, la de prefijo más largo (_longest prefix match_). Con la tabla anterior:

- `10.0.3.7` coincide con `10.0.0.0/16` y con `0.0.0.0/0`; gana el /16: tráfico local.
- `10.20.5.9` coincide con `10.20.0.0/16` y con `0.0.0.0/0`; viaja por el peering.
- Una IP de S3 figura en la _prefix list_, cuyos bloques son más específicos que `/0`: va por el endpoint.
- `8.8.8.8` solo coincide con `0.0.0.0/0`: sale por el NAT Gateway.

Otros _targets_ habituales: Internet Gateway (`igw-`), Egress-only IGW (`eigw-`), _virtual private gateway_ de una VPN (`vgw-`) o una interfaz de red (`eni-`), como la de un _appliance_ de seguridad.

#practica[Deja la tabla principal como privada (solo la ruta local) y asocia explícitamente cada subred a su tabla. Así, una subred nueva que olvides asociar nunca quedará expuesta a Internet por accidente.]

== Internet Gateway, IPs públicas y NAT

=== Internet Gateway y subredes públicas

El *Internet Gateway* (IGW) conecta la VPC con Internet. Es gestionado, redundante y escala solo: no es un cuello de botella ni un punto único de fallo, y no tiene coste propio. Cada VPC admite uno como máximo. Para IPv4 traduce 1:1 la IP privada de la instancia a su IP pública: el sistema operativo solo ve la privada. Y si quieres un freno de emergencia, *VPC Block Public Access* (2024) bloquea por cuenta y región el tráfico de los Internet Gateways, con exclusiones para las VPC o subredes que deban ser públicas.

¿Qué hace *pública* a una subred? Solo una cosa: que su tabla de rutas tenga una ruta `0.0.0.0/0` (o `::/0`) hacia un IGW. No existe ninguna casilla «subred pública», y el nombre que le pongas no cambia nada. Para que una instancia sea accesible desde Internet deben cumplirse cuatro condiciones:

#pasos(
  [La tabla de rutas de su subred tiene una ruta hacia el Internet Gateway.],
  [La instancia tiene una IPv4 pública o una Elastic IP (o una dirección IPv6).],
  [Su Security Group permite el tráfico entrante (por ejemplo, TCP 443).],
  [La NACL de la subred permite la entrada y también la salida de las respuestas.],
)

=== IP pública frente a Elastic IP

Una *IPv4 pública automática* se asigna al lanzar la instancia desde el _pool_ de Amazon y se pierde al detenerla o terminarla: tras un _stop/start_ tendrá otra. Una *Elastic IP* es una dirección estática que reservas en tu cuenta y región; puedes asociarla a una instancia o interfaz, moverla a otra en segundos, y es tuya hasta que la liberes.

#coste[Desde el 1 de febrero de 2024, AWS cobra *todas* las IPv4 públicas por hora, estén en uso o no: las asignadas automáticamente a EC2, las Elastic IP y también las de NAT Gateways, balanceadores y otros servicios. La tarifa es de 0,005 USD por hora y dirección (unos 3,6 USD al mes): poco por IP, mucho multiplicado por cientos. Localiza las tuyas con _Public IP Insights_ (en VPC IPAM), libera las Elastic IP que no uses y valora IPv6.]

=== NAT Gateway: salida a Internet para subredes privadas

Las instancias de una subred privada no tienen IP pública, pero a menudo necesitan salir a Internet (parches, APIs externas). El *NAT Gateway* lo resuelve: se crea en una subred pública con una Elastic IP, y la tabla de rutas de las subredes privadas envía `0.0.0.0/0` hacia él. Traduce las conexiones salientes a su IP pública y deja volver las respuestas, pero nunca acepta conexiones iniciadas desde Internet.

#diagrama(pie: [Subred pública y subred privada. El Internet Gateway da entrada y salida a la subred pública; la privada solo puede salir, a través del NAT Gateway.])[
  #fila(actor(etiqueta: "Clientes"), flecha(doble: true), internet(), flecha(doble: true), svc("IGW", "Internet Gateway", color: col.redes))
  #v(-2pt)
  #flecha-v(doble: true, largo: 0.7cm)
  #v(-2pt)
  #zona("VPC 10.0.0.0/16", color: col.redes)[
    #columna(espacio: 2pt,
      fila(espacio: 12pt,
        zona("Subred pública · 10.0.0.0/24", color: col.almacenamiento)[
          #fila(espacio: 6pt,
            svc("EC2", "Servidor web", sub: "IP pública", color: col.computo),
            svc("NAT", "NAT Gateway", sub: "Elastic IP", color: col.redes))
        ],
        _rt("Tabla de rutas pública", ("10.0.0.0/16", "local"), ("0.0.0.0/0", "igw-0a1b"), color: col.almacenamiento),
      ),
      flecha-v(arriba: true, largo: 0.8cm, etiqueta: "salida vía NAT"),
      fila(espacio: 12pt,
        zona("Subred privada · 10.0.16.0/20", color: col.computo)[
          #fila(espacio: 6pt,
            svc("EC2", "Aplicación", sub: "solo IP privada", color: col.computo),
            svc("RDS", "Base de datos", color: col.datos))
        ],
        _rt("Tabla de rutas privada", ("10.0.0.0/16", "local"), ("0.0.0.0/0", "nat-0c3d"), color: col.computo),
      ),
    )
  ]
]

Antes del NAT Gateway se usaban *NAT instances*: instancias EC2 configuradas para hacer NAT. Hoy solo tienen sentido en laboratorios o con presupuestos mínimos:

#tabla(("", "NAT Gateway", "NAT instance"), columnas: (1fr, 1.7fr, 1.7fr), tamano: 8pt,
  [Gestión], [Gestionado por AWS; redundante dentro de su AZ], [Una EC2 (con el _source/destination check_ desactivado) que administras, parcheas y haces redundante tú],
  [Ancho de banda], [5 Gbps, escala solo hasta 100 Gbps], [El del tipo de instancia],
  [Security Groups], [#no #h(2pt) Solo la NACL de su subred], [#si],
  [Coste], [Por hora + por GB procesado], [El de la instancia; más barata con poco tráfico],
)

#cuidado(titulo: "Alta disponibilidad: un NAT por AZ")[Un NAT Gateway clásico es *zonal*: si su AZ cae, todas las subredes que lo usan se quedan sin salida. El patrón recomendado es un NAT Gateway por AZ y una tabla de rutas privada por AZ que apunte a su NAT local; de paso evitas pagar tráfico entre AZ. Desde noviembre de 2025 existe además un modo *regional*: un único NAT Gateway que se extiende solo a las AZ donde tienes recursos, sin necesidad de subred pública (se factura por AZ activa y no admite NAT privado).]

#coste[Cada NAT Gateway se paga por hora de existencia y por GB procesado, además de su IPv4 pública y de la transferencia a Internet. En us-east-1 ronda los 0,045 USD por hora y por GB (varía según la región): tres NAT suponen unos 100 USD al mes antes de mover un solo byte. Lo que más infla la factura es el tráfico hacia S3, DynamoDB o ECR que cruza el NAT sin necesidad: los *VPC Endpoints* lo evitan.]

=== Egress-only Internet Gateway

Con IPv6 no hace falta NAT para salir a Internet, porque las direcciones que asigna Amazon ya son públicas. Para que las instancias puedan iniciar conexiones IPv6 hacia Internet sin aceptar conexiones entrantes se usa un *Egress-only Internet Gateway*, con la ruta `::/0 → eigw-…`. Es _stateful_ como el NAT, pero no traduce direcciones y no tiene coste por hora. Existen también NAT Gateways *privados*, sin IP pública, para conectar redes con CIDR solapados.

== Security Groups y Network ACL

AWS te da dos cortafuegos complementarios. El *Security Group* (SG) protege interfaces de red concretas (la ENI de una instancia, un balanceador, una base de datos RDS...); la *Network ACL* (NACL) filtra el tráfico que entra en una subred o sale de ella.

#tabla(("Característica", "Security Group", "Network ACL"), columnas: (1.05fr, 1.55fr, 1.55fr),
  [Se aplica a], [Interfaces de red (ENI) de los recursos], [Subredes completas],
  [Estado], [*Stateful*: la respuesta se permite sola], [*Stateless*: hay que permitir ida y vuelta],
  [Reglas], [Solo _allow_], [_Allow_ y _deny_],
  [Evaluación], [Todas las reglas a la vez], [Por número, de menor a mayor; decide la primera que coincide],
  [Origen o destino], [CIDR, _prefix list_ u otro Security Group], [Solo CIDR],
  [Por defecto], [Uno nuevo: sin entrada, toda la salida], [La NACL por defecto lo permite todo; una nueva lo deniega todo],
  [Asociación], [Hasta 5 por ENI (ajustable)], [Exactamente una por subred],
  [Bloquear una IP concreta], no, si,
)

=== Security Groups encadenados: una aplicación de tres capas

La gran ventaja de los SG es que una regla puede tener como origen *otro Security Group*: «permite el puerto 5432 a cualquier recurso que lleve `sg-app`». La regla sigue a los recursos aunque cambien de IP o pasen de dos a cien instancias.

#diagrama(pie: [Security Groups encadenados: cada capa solo acepta tráfico de la capa anterior, identificada por su SG y no por sus direcciones IP.])[
  #fila(espacio: 2pt,
    actor(etiqueta: "Clientes"),
    flecha(etiqueta: "TCP 443", largo: 1.3cm),
    zona("sg-alb", color: col.seguridad)[#svc("ALB", "Balanceador", color: col.balanceo)],
    flecha(etiqueta: "TCP 8080", largo: 1.3cm),
    zona("sg-app", color: col.seguridad)[#svc("EC2", "Aplicación", color: col.computo)],
    flecha(etiqueta: "TCP 5432", largo: 1.3cm),
    zona("sg-db", color: col.seguridad)[#svc("RDS", "PostgreSQL", color: col.datos)],
  )
]

#tabla(("Security Group", "Entrada", "Salida"), columnas: (0.9fr, 1.6fr, 1.9fr),
  [`sg-alb`], [TCP 443 desde `0.0.0.0/0` y `::/0`], [TCP 8080 hacia `sg-app`],
  [`sg-app`], [TCP 8080 desde `sg-alb`], [TCP 5432 hacia `sg-db`; TCP 443 hacia `0.0.0.0/0` (APIs, parches)],
  [`sg-db`], [TCP 5432 desde `sg-app`], [Ninguna: las respuestas salen solas],
)

```bash
aws ec2 authorize-security-group-ingress --group-id sg-0db1111aaaa2222bb \
  --protocol tcp --port 5432 --source-group sg-0app333cccc4444dd
```

Los cambios se aplican al instante. Puedes referenciar SG de una VPC emparejada de la misma región y, desde 2024, de VPC conectadas por Transit Gateway (en reglas de entrada). Cada SG admite por defecto 60 reglas de entrada y 60 de salida (ajustable).

=== NACL y puertos efímeros

Al ser _stateless_, una NACL evalúa por separado el paquete de ida y el de vuelta. La respuesta de un servidor se dirige al *puerto efímero* que eligió el cliente: Linux usa por defecto el rango 32768–60999, Windows 49152–65535, y los balanceadores y el NAT Gateway 1024–65535. Por eso la NACL debe permitir 1024–65535 en el sentido de las respuestas. Ejemplo para una subred que solo aloja el balanceador:

#tabla(("Regla", "Sentido", "Protocolo y puertos", "Origen / destino", "Acción"), columnas: (0.55fr, 0.75fr, 1.3fr, 1.25fr, 2.1fr), tamano: 8pt,
  [90], [Entrada], [Todo], [`203.0.113.0/24`], [DENY: red maliciosa conocida],
  [100], [Entrada], [TCP 443], [`0.0.0.0/0`], [ALLOW: clientes HTTPS],
  [110], [Entrada], [TCP 1024–65535], [`10.0.0.0/16`], [ALLOW: respuestas de la capa de aplicación],
  [\*], [Entrada], [Todo], [`0.0.0.0/0`], [DENY implícito],
  [100], [Salida], [TCP 1024–65535], [`0.0.0.0/0`], [ALLOW: respuestas a los clientes],
  [110], [Salida], [TCP 8080], [`10.0.0.0/16`], [ALLOW: hacia la capa de aplicación],
  [\*], [Salida], [Todo], [`0.0.0.0/0`], [DENY implícito],
)

#examen[SG: _stateful_, solo _allow_, nivel de ENI. NACL: _stateless_, _allow_ y _deny_, nivel de subred, reglas numeradas. Si te piden bloquear una IP o un rango concreto, la respuesta es una NACL (o AWS WAF, si el tráfico es HTTP), nunca un Security Group.]

#practica[Haz de los SG tu control principal y deja las NACL casi abiertas, para bloqueos gruesos (rangos concretos, aislar subredes sensibles). Replicar toda la lógica en las NACL multiplica los errores con los puertos efímeros.]

== VPC Endpoints y PrivateLink

Una instancia de una subred privada que llama a S3, SQS o Secrets Manager habla con endpoints públicos de AWS: sin más, necesita un NAT Gateway y paga su procesamiento. Los *VPC Endpoints* permiten llegar a esos servicios por la red privada de AWS, sin Internet Gateway, sin NAT y sin IP pública. Hay dos tipos principales:

#diagrama(pie: [Dos formas de llegar a servicios de AWS sin NAT: el gateway endpoint es una ruta en la tabla de rutas; el interface endpoint es una interfaz de red con IP privada.])[
  #columna(espacio: 10pt,
    fila(espacio: 4pt,
      zona("VPC · subred privada", color: col.redes)[#fila(espacio: 4pt,
        svc("EC2", "Aplicación", color: col.computo),
        flecha(etiqueta: "ruta pl-… → vpce-…", largo: 2.3cm),
        svc("GW", "Gateway endpoint", sub: "gratuito", color: col.redes))],
      flecha(largo: 1.3cm),
      svc("S3", "Amazon S3", color: col.almacenamiento)),
    fila(espacio: 4pt,
      zona("VPC · subred privada", color: col.redes)[#fila(espacio: 4pt,
        svc("EC2", "Aplicación", color: col.computo),
        flecha(etiqueta: "DNS privado", largo: 2.3cm),
        svc("ENI", "Interface endpoint", sub: "IP 10.0.16.50", color: col.redes))],
      flecha(etiqueta: "PrivateLink", largo: 1.3cm),
      svc("SQS", "Amazon SQS", color: col.integracion)),
  )
]

#tabla(("", "Gateway endpoint", "Interface endpoint (PrivateLink)"), columnas: (1.15fr, 1.5fr, 1.75fr),
  [Servicios], [Solo S3 y DynamoDB], [La mayoría de servicios de AWS, de terceros y los tuyos propios],
  [Funcionamiento], [Una ruta en la tabla de rutas (_prefix list_ → `vpce-`)], [Una ENI con IP privada en cada subred elegida],
  [DNS], [Sin cambios: se usan los nombres públicos], [DNS privado: el nombre del servicio resuelve a IPs privadas],
  [Accesible desde on-premises u otras VPC], no, si,
  [Security Groups], no, si,
  [Coste], [*Gratis*], [Por hora y AZ + por GB procesado],
)

S3 y, desde 2024, DynamoDB admiten también interface endpoints, útiles para llegar a ellos desde tu red local. El DNS privado de los interface endpoints requiere los atributos `enableDnsSupport` y `enableDnsHostnames` (sección de DNS).

=== Endpoint policies

Cada endpoint admite una *endpoint policy*: una política JSON que limita qué se puede hacer *a través de él*. No concede permisos (siguen haciendo falta los de IAM y los del recurso), pero evita, por ejemplo, que alguien use tu red para copiar datos a un bucket ajeno:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "SoloBucketsDeLaEmpresa",
    "Effect": "Allow",
    "Principal": "*",
    "Action": ["s3:GetObject", "s3:PutObject", "s3:ListBucket"],
    "Resource": ["arn:aws:s3:::empresa-datos", "arn:aws:s3:::empresa-datos/*"]
  }]
}
```

En sentido contrario, la *bucket policy* puede exigir que las peticiones lleguen por tu endpoint con la condición `aws:SourceVpce`. Crear un gateway endpoint es un solo comando (`aws ec2 create-vpc-endpoint --vpc-endpoint-type Gateway`) en el que indicas el servicio (`com.amazonaws.eu-west-1.s3`) y las tablas de rutas que deben recibir la ruta.

=== PrivateLink para tus propios servicios

Con *AWS PrivateLink* también puedes publicar un servicio propio: lo colocas detrás de un Network Load Balancer, creas un *endpoint service* y los consumidores crean un interface endpoint hacia él. La conexión es unidireccional (solo inicia el consumidor), no expone el resto de tu red y funciona aunque los CIDR se solapen. Un tercer tipo de endpoint, el de *Gateway Load Balancer*, intercala _appliances_ de inspección (cortafuegos, IDS) en el camino del tráfico.

== Conectar VPC: Peering, Transit Gateway y VPC Lattice

=== VPC Peering

Un *VPC Peering* une dos VPC de forma privada, como si fueran una sola red, aunque sean de cuentas o regiones distintas, y sin ningún gateway que dimensionar. Tras aceptar la conexión, añades en cada lado la ruta hacia el CIDR del otro (`10.1.0.0/16 → pcx-…`). Sus reglas son estrictas:

- Los CIDR de ambas VPC no pueden solaparse.
- *No es transitivo*: si A está emparejada con B, y B con C, A no llega a C a través de B.
- Tampoco hay _edge-to-edge routing_: A no puede usar el IGW, el NAT, la VPN ni el gateway endpoint de B.
- La malla crece deprisa: _n_ VPC necesitan _n_(_n_ − 1)/2 peerings (10 VPC, 45 conexiones).

#diagrama(pie: [El peering no es transitivo: cada pareja de VPC que deba comunicarse necesita su propia conexión.])[
  #fila(
    zona("VPC A", color: col.redes)[#caja(_m("10.0.0.0/16"), color: col.redes)],
    flecha(etiqueta: "peering A–B", largo: 2.2cm, doble: true),
    zona("VPC B", color: col.redes)[#caja(_m("10.1.0.0/16"), color: col.redes)],
    flecha(etiqueta: "peering B–C", largo: 2.2cm, doble: true),
    zona("VPC C", color: col.redes)[#caja(_m("10.2.0.0/16"), color: col.redes)],
  )
  #v(6pt)
  #caja([#no #h(3pt) A no puede llegar a C *a través de* B: crea un peering A–C o usa un Transit Gateway], color: rgb("#E03131"))
]

#coste[El peering no tiene coste por hora: pagas la transferencia de datos, gratuita dentro de la misma AZ y con la tarifa habitual entre AZ o entre regiones.]

=== Transit Gateway

Con decenas de VPC más conexiones a tu centro de datos, la malla de peerings se vuelve inmanejable. *AWS Transit Gateway* (TGW) es un router regional gestionado con topología _hub-and-spoke_: cada VPC, VPN o Direct Connect se conecta una sola vez al TGW (un *attachment*) y este enruta entre todos de forma transitiva.

#diagrama(pie: [Transit Gateway como hub: cada red se conecta una sola vez y las tablas de rutas del TGW deciden quién llega a quién.])[
  #let red(t, cidr) = zona(t, color: col.redes)[#caja(_m(cidr), color: col.redes)]
  #grid(columns: (1fr, 1fr, 1fr), row-gutter: 3pt, align: center + horizon,
    red("VPC producción", "10.0.0.0/16"), red("VPC desarrollo", "10.1.0.0/16"), red("Servicios compartidos", "10.100.0.0/16"),
    flecha-v(doble: true, largo: 0.8cm), flecha-v(doble: true, largo: 0.8cm), flecha-v(doble: true, largo: 0.8cm),
    grid.cell(colspan: 3, box(width: 94%, radius: 6pt, inset: (y: 9pt),
      fill: gradient.linear(col.redes.lighten(8%), col.redes.darken(25%)),
      align(center, text(9.5pt, weight: "bold", fill: white)[Transit Gateway #h(8pt) #text(7.3pt, weight: "regular")[tablas de rutas: producción · desarrollo · compartida]]))),
    flecha-v(doble: true, largo: 0.8cm), flecha-v(doble: true, largo: 0.8cm), flecha-v(doble: true, largo: 0.8cm),
    caja([*Oficina* \ Site-to-Site VPN], color: col.neutro),
    caja([*Centro de datos* \ Direct Connect Gateway], color: col.neutro),
    caja([*TGW en us-east-1* \ peering entre regiones], color: col.redes),
  )
]

#ficha("AWS Transit Gateway", "Router regional gestionado para interconectar VPC y redes locales",
  ("Ámbito", [Regional; se comparte entre cuentas con AWS RAM y se une a TGW de otras regiones mediante _peering_]),
  ("Attachments", [VPC, Site-to-Site VPN, Direct Connect Gateway, peering de TGW y Connect (SD-WAN)]),
  ("Segmentación", [Varias tablas de rutas: producción y desarrollo aisladas entre sí, ambas con acceso a servicios compartidos]),
  ("Coste", [Por hora de cada attachment + por GB procesado]))

Para redes globales gestionadas mediante políticas, *AWS Cloud WAN* lleva la misma idea a varias regiones desde una sola consola.

#examen[Peering: uno a uno, no transitivo, sin coste por hora. Transit Gateway: hub transitivo para muchas VPC y redes locales, con coste por attachment y por GB. Si el enunciado habla de «cientos de VPC» o de «simplificar la conectividad», la respuesta es Transit Gateway.]

=== VPC Lattice

*Amazon VPC Lattice* ataca el problema desde la capa de aplicación: en lugar de unir redes, conecta *servicios*. Defines una _service network_, registras en ella tus servicios (instancias, contenedores, funciones Lambda...) y asocias las VPC consumidoras. Lattice se encarga del descubrimiento, del enrutamiento HTTP, HTTPS y gRPC, de la autorización con políticas de IAM y de la observabilidad, incluso entre cuentas y con CIDR solapados; desde finales de 2024 también da acceso a recursos TCP, como una base de datos RDS. Resumiendo: Peering y Transit Gateway conectan *redes* (y exigen CIDR sin solapar); PrivateLink expone *un servicio* concreto; Lattice gestiona la comunicación entre *muchos servicios*.

== Conectividad híbrida

Conectar AWS con tu centro de datos u oficinas es el escenario *híbrido*. Dispones de tres herramientas, que a menudo se combinan:

/ Site-to-Site VPN: túneles IPsec cifrados sobre Internet entre tu router (*customer gateway*) y un *virtual private gateway* asociado a una VPC o un Transit Gateway. Cada conexión incluye dos túneles hacia endpoints distintos de AWS y admite rutas estáticas o BGP. Desde finales de 2025, las conexiones a Transit Gateway o Cloud WAN pueden usar túneles «grandes» de hasta 5 Gbps.
/ Client VPN: acceso remoto para personas, compatible con OpenVPN, con autenticación mediante Active Directory, SAML (tu proveedor de identidad) o certificados.
/ Direct Connect: un enlace físico privado entre tu red y AWS a través de una ubicación de Direct Connect, dedicado (1, 10, 100 o 400 Gbps) o alojado (_hosted_) mediante un socio. No va cifrado por defecto: usa MACsec en las conexiones dedicadas compatibles o una VPN por encima. Llega a tus VPC mediante _virtual interfaces_ y un *Direct Connect Gateway*.

#diagrama(pie: [Conectividad híbrida: dos túneles VPN sobre Internet, un enlace de Direct Connect y acceso de usuarios remotos con Client VPN.])[
  #fila(espacio: 4pt,
    zona("Centro de datos", color: col.neutro, ancho: 3.4cm)[#columna(espacio: 4pt,
      svc("SRV", "Servidores", color: col.neutro),
      svc("CGW", "Customer gateway", sub: "router IPsec y BGP", color: col.neutro))],
    columna(espacio: 0pt,
      flecha(etiqueta: "túnel IPsec 1", largo: 3cm, doble: true),
      flecha(etiqueta: "túnel IPsec 2", largo: 3cm, doble: true),
      flecha(etiqueta: "Direct Connect", largo: 3cm, doble: true, color: col.redes)),
    zona("Región AWS", color: col.fundamentos, punteada: false, relleno: white)[#fila(espacio: 4pt,
      svc("TGW", "Transit Gateway", sub: "o VGW", color: col.redes),
      flecha(doble: true, largo: 1cm),
      zona("VPC", color: col.redes)[#svc("EC2", "Aplicación", color: col.computo)])],
  )
  #v(8pt)
  #fila(espacio: 4pt, actor(etiqueta: "Empleado remoto"), flecha(etiqueta: "Client VPN", largo: 2.4cm),
    caja([Endpoint de Client VPN #sym.arrow subredes de la VPC], color: col.redes))
]

#tabla(("", "Site-to-Site VPN", "Client VPN", "Direct Connect"), columnas: (1fr, 1.35fr, 1.2fr, 1.35fr), tamano: 8pt,
  [Para quién], [Redes: CPD, oficinas], [Personas: portátiles], [Redes con mucho tráfico],
  [Medio], [IPsec sobre Internet], [TLS (OpenVPN) sobre Internet], [Enlace físico privado (sin cifrar por defecto)],
  [Ancho de banda], [Hasta 1,25 Gbps por túnel (5 Gbps en túneles grandes)], [Por usuario], [Dedicado: de 1 a 400 Gbps; alojado: de 50 Mbps a 25 Gbps],
  [Puesta en marcha], [Minutos], [Minutos], [Semanas],
  [Facturación], [Por hora de conexión + datos], [Por hora de asociación y de conexión], [Por hora de puerto + GB salientes],
)

#practica[Un patrón clásico de resiliencia: Direct Connect como camino principal y una Site-to-Site VPN como respaldo. Para cargas críticas, AWS recomienda además dos conexiones de Direct Connect en ubicaciones distintas.]

== DNS dentro de la VPC

Cada VPC incluye un servidor DNS gestionado, el *Route 53 Resolver* (también llamado _Amazon DNS server_), en la dirección base del CIDR más dos (en `10.0.0.0/16`, la `10.0.0.2`) y en `169.254.169.253`. Resuelve nombres públicos de Internet, los nombres internos de EC2 (`ip-10-0-1-25.eu-west-1.compute.internal`) y tus *zonas privadas* de Route 53. Su comportamiento depende de dos atributos de la VPC:

#tabla(("Atributo", "Qué controla", "VPC por defecto", "VPC nueva"), columnas: (1.45fr, 2.6fr, 0.95fr, 0.85fr),
  [`enableDnsSupport`], [Que el Resolver de Amazon responda a las instancias], [`true`], [`true`],
  [`enableDnsHostnames`], [Que las instancias con IP pública reciban un nombre DNS público], [`true`], [`false`],
)

Ambos deben estar en `true` para usar zonas privadas de Route 53 y el DNS privado de los interface endpoints; es un olvido clásico en VPC creadas por CLI o con infraestructura como código (se corrige con `aws ec2 modify-vpc-attribute`).

Para el *DNS híbrido*, el Resolver ofrece endpoints: uno *de entrada* (_inbound_), para que tus servidores DNS locales resuelvan nombres privados de AWS, y uno *de salida* (_outbound_) con *reglas de reenvío*, para que la VPC resuelva dominios corporativos como `corp.ejemplo.com` contra tus DNS internos. *Route 53 Resolver DNS Firewall* permite además bloquear consultas a dominios maliciosos. Las zonas, los tipos de registro y las políticas de enrutamiento de Route 53 se tratan en el capítulo «CloudFront, Route 53 y el borde de la red».

== Visibilidad: VPC Flow Logs y Reachability Analyzer

*VPC Flow Logs* registra metadatos de las conexiones IP —quién habla con quién, por qué puertos, cuántos bytes y si se aceptó o se rechazó—, no el contenido de los paquetes (para eso está _Traffic Mirroring_). Se activa por VPC, subred o interfaz, envía los registros a CloudWatch Logs, S3 o Amazon Data Firehose y agrega cada flujo en ventanas de 1 o 10 minutos. Así es un registro en el formato por defecto (versión 2):

#diagrama(pie: [Anatomía de un registro de VPC Flow Logs: una conexión HTTPS aceptada hacia una instancia. Los campos `start` y `end` son marcas de tiempo Unix; el protocolo 6 es TCP.])[
  #columna(espacio: 8pt,
    fila(espacio: 5pt,
      _campo("2", "version", col.neutro),
      _campo("123456789012", "account-id", col.neutro),
      _campo("eni-1235b8ca", "interface-id", col.neutro),
      _campo("203.0.113.12", "srcaddr", col.redes),
      _campo("10.0.1.25", "dstaddr", col.redes),
      _campo("49761", "srcport", col.computo),
      _campo("443", "dstport", col.computo)),
    fila(espacio: 5pt,
      _campo("6", "protocol", col.datos),
      _campo("18", "packets", col.datos),
      _campo("6120", "bytes", col.datos),
      _campo("1730620800", "start", col.observabilidad),
      _campo("1730620860", "end", col.observabilidad),
      _campo("ACCEPT", "action", col.almacenamiento),
      _campo("OK", "log-status", col.neutro)),
  )
]

```bash
aws ec2 create-flow-logs --resource-type VPC --resource-ids vpc-0abc1234 \
  --traffic-type ALL --log-destination-type s3 --max-aggregation-interval 60 \
  --log-destination arn:aws:s3:::mis-flow-logs/vpc-prod/
```

Un diagnóstico clásico: para el mismo intento de conexión SSH aparecen estos dos registros (abreviados):

```text
... 198.51.100.7 10.0.1.25 51234 22 6 4 240 ... ACCEPT OK
... 10.0.1.25 198.51.100.7 22 51234 6 4 240 ... REJECT OK
```

La entrada se aceptó, pero la respuesta se rechazó. Un Security Group nunca bloquearía una respuesta, porque es _stateful_: el culpable es la NACL, que no permite la salida hacia los puertos efímeros del cliente. En el capítulo de Observabilidad verás cómo consultar estos registros con CloudWatch Logs Insights o Athena.

*Reachability Analyzer* responde a «¿puede A hablar con B?» analizando la *configuración* (rutas, SG, NACL, endpoints, peerings, Transit Gateway...) entre un origen y un destino, por ejemplo del Internet Gateway a una instancia por el puerto 443, y señala el componente que bloquea el camino. No envía paquetes reales, así que funciona antes incluso de desplegar la aplicación; se paga por análisis. Su hermano, *Network Access Analyzer*, busca accesos no deseados a gran escala («¿qué es accesible desde Internet?»).

== Diseño de referencia: VPC multi-AZ de tres capas

Juntemos todas las piezas. La @fig-redes-referencia muestra la VPC que encontrarás, con variaciones, en la mayoría de aplicaciones web en producción; usa el plan de direcciones de la @fig-redes-plan. Las decisiones de diseño, una a una:

- *Tres AZ y tres capas* (pública, aplicación y datos), replicadas en todas las AZ.
- *Tablas de rutas*: una pública (`0.0.0.0/0 → igw`), una privada por AZ (`0.0.0.0/0 → NAT de su AZ`) y una de datos sin salida a Internet.
- *Nada con IP pública salvo el balanceador y los NAT*; la administración, con Session Manager (AWS Systems Manager), sin bastiones ni SSH abierto.
- *Security Groups encadenados* (`sg-alb → sg-app → sg-db`), NACL casi abiertas, endpoints para no pagar NAT de más y Flow Logs desde el primer día.

#consejo[El asistente _VPC and more_ de la consola crea en un minuto la VPC, subredes públicas y privadas en varias AZ, tablas de rutas, IGW, NAT Gateways y un gateway endpoint de S3. Úsalo para aprender; en producción, define la red con infraestructura como código (capítulo de IaC).]

#diagrama(pie: [Diseño de referencia: VPC de tres capas en tres AZ. El ALB tiene nodos en las tres subredes públicas, hay un NAT Gateway por AZ, la base de datos es Multi-AZ y los endpoints evitan el NAT.])[
  #fila(actor(etiqueta: "Usuarios"), flecha(etiqueta: "HTTPS"), internet(), flecha(), svc("IGW", "Internet Gateway", color: col.redes))
  #v(-4pt)
  #flecha-v(largo: 0.6cm)
  #v(-4pt)
  #zona("Región eu-west-1", color: col.fundamentos, punteada: false, relleno: white)[
    #zona("VPC 10.0.0.0/16", color: col.redes)[
      #columna(espacio: 4pt,
        svc("ALB", "Application Load Balancer", color: col.balanceo),
        flecha-v(largo: 0.5cm),
        fila(espacio: 6pt,
          _az("a", "10.0.0.0/24", "10.0.16.0/20", "10.0.64.0/24", "Primaria"),
          _az("b", "10.0.1.0/24", "10.0.32.0/20", "10.0.65.0/24", "Standby"),
          _az("c", "10.0.2.0/24", "10.0.48.0/20", "10.0.66.0/24", "Réplica de lectura")),
        v(2pt),
        fila(espacio: 8pt,
          caja([*Gateway endpoints* \ S3 · DynamoDB], color: col.redes),
          caja([*Interface endpoints* \ ECR · CloudWatch Logs · SSM · Secrets Manager], color: col.redes),
          caja([*Flow Logs* \ hacia S3], color: col.observabilidad)),
      )
    ]
  ]
] <fig-redes-referencia>

== Errores comunes

#tabla(("Síntoma", "Causa probable", "Solución"), columnas: (1.5fr, 1.7fr, 1.7fr), tamano: 8pt,
  [La instancia de la subred «pública» no responde desde Internet], [Falta la ruta al IGW, no tiene IP pública o el SG o la NACL lo impiden], [Revisa las cuatro condiciones; lanza Reachability Analyzer],
  [Las instancias privadas no salen a Internet], [El NAT está en una subred privada o falta la ruta `0.0.0.0/0`], [NAT siempre en subred pública; ruta en la tabla privada],
  [Factura de NAT disparada], [El tráfico hacia S3, DynamoDB o ECR cruza el NAT], [Gateway endpoints e interface endpoints],
  [No puedes crear el peering, o el tráfico hacia la oficina se pierde], [CIDR solapados], [Plan de direccionamiento (IPAM) antes de crear VPC],
  [El DNS privado del endpoint no resuelve], [`enableDnsHostnames` o `enableDnsSupport` desactivados], [Activa ambos atributos],
  [La caída de una AZ deja sin Internet a todas], [Un único NAT Gateway zonal compartido], [Un NAT por AZ (o un NAT regional)],
)

#resumen[
- Una *VPC* es una red privada regional; cada subred vive en una sola AZ y pierde *5 IPs* reservadas. Elige un CIDR (de /16 a /28) que no se solape con tus otras redes: no se puede cambiar, solo ampliar con bloques secundarios.
- Las *tablas de rutas* deciden el camino: gana la ruta más específica y la ruta local no se puede borrar.
- Una subred es *pública* porque su tabla de rutas envía `0.0.0.0/0` a un Internet Gateway; la instancia necesita además IP pública y reglas que la dejen pasar.
- Las subredes privadas salen a Internet con un *NAT Gateway* (uno por AZ, o en modo regional), que se paga por hora y por GB; en IPv6 se usa el Egress-only IGW. Todas las IPv4 públicas se cobran por hora desde 2024.
- *Security Groups*: _stateful_, solo _allow_, a nivel de ENI y referenciables entre sí. *NACL*: _stateless_, _allow_ y _deny_ ordenados, a nivel de subred; cuidado con los puertos efímeros.
- Los *gateway endpoints* (S3, DynamoDB) son gratuitos; los *interface endpoints* (PrivateLink) cubren el resto y se pagan por hora y GB. *Peering* une dos VPC sin transitividad; *Transit Gateway* es el hub transitivo; *VPC Lattice* conecta servicios.
- Para el entorno híbrido: *Site-to-Site VPN* (IPsec sobre Internet, lista en minutos), *Client VPN* (para personas) y *Direct Connect* (enlace dedicado, tarda semanas).
- El *Route 53 Resolver* da DNS en cada VPC; *Flow Logs* y *Reachability Analyzer* son tus herramientas de diagnóstico.
]

#repaso(
  ([¿Cuántas direcciones utilizables tiene una subred /26 en AWS?], [59: el bloque tiene 64 direcciones y AWS reserva 5.]),
  ([Una instancia tiene IP pública pero no responde desde Internet. ¿Qué compruebas?], [Que la tabla de rutas de su subred tenga `0.0.0.0/0` hacia el IGW, que su Security Group permita el puerto, que la NACL permita la entrada y la salida (puertos efímeros) y que el servicio esté escuchando.]),
  ([¿Por qué se recomienda un NAT Gateway por AZ?], [Porque un NAT zonal depende de su AZ: si cae, las subredes de otras AZ que lo usan pierden la salida. Además, evita cargos de tráfico entre AZ.]),
  ([Tu NACL permite la entrada al puerto 443, pero los clientes no reciben respuesta. ¿Qué falta?], [Una regla de salida hacia los puertos efímeros (1024–65535): la NACL es _stateless_ y no permite las respuestas automáticamente.]),
  ([¿Cómo accedes a S3 desde una subred privada sin NAT y sin coste adicional?], [Con un gateway endpoint de S3 asociado a la tabla de rutas de esa subred.]),
  ([Las VPC A y B están emparejadas, y también B y C. ¿Puede A hablar con C?], [No: el peering no es transitivo. Necesitas un peering A–C o un Transit Gateway.]),
)
