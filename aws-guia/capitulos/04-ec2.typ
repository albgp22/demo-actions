#import "../theme.typ": *

// ---------------------------------------------------------------------
//  Ayudas locales para los diagramas de este capítulo
// ---------------------------------------------------------------------
#let gf = rgb("#7A8699") // gris de las flechas del tema


// Segmento recto y punta de flecha para diagramas dibujados sobre un lienzo
#let seg(x1, y1, x2, y2, color: gf) = place(line(start: (x1, y1), end: (x2, y2), stroke: 1.2pt + color))
#let punta(x, y, dir, color: gf) = {
  let pts = if dir == "der" { ((x - 7pt, y - 3.5pt), (x, y), (x - 7pt, y + 3.5pt)) }
  else if dir == "izq" { ((x + 7pt, y - 3.5pt), (x, y), (x + 7pt, y + 3.5pt)) }
  else if dir == "abajo" { ((x - 3.5pt, y - 7pt), (x, y), (x + 3.5pt, y - 7pt)) }
  else { ((x - 3.5pt, y + 7pt), (x, y), (x + 3.5pt, y + 7pt)) }
  place(polygon(fill: color, ..pts))
}
#let rotulo(x, y, ancho, cuerpo, tam: 6.6pt, alin: center) = place(dx: x, dy: y, box(width: ancho, {
  set par(justify: false, leading: 0.35em)
  align(alin, text(tam, weight: "medium", fill: gf.darken(30%), cuerpo))
}))
#let estado(x, y, nombre, color) = place(dx: x, dy: y, box(
  width: 2.4cm, height: 0.85cm, radius: 5pt,
  fill: color.lighten(86%), stroke: 1.2pt + color,
  align(center + horizon, text(7.6pt, weight: "bold", fill: color.darken(35%), font: "JetBrains Mono", nombre)),
))

// Icono compacto (como `svc`, pero más estrecho) para filas largas
#let mini(abbr, titulo, color) = box(width: 1.85cm, height: 1.75cm, align(center + top, stack(dir: ttb, spacing: 3.5pt,
  align(center, box(width: 0.85cm, height: 0.85cm, radius: 4pt,
    fill: gradient.linear(color.lighten(8%), color.darken(18%), angle: 90deg),
    align(center + horizon, text(if abbr.len() > 3 { 6.4pt } else { 7.6pt }, weight: "bold", fill: white, abbr)))),
  align(center, {
    set par(justify: false, leading: 0.35em)
    text(6.6pt, weight: "semibold", fill: tinta, hyphenate: false, titulo)
  }),
)))

// Rack con 5 huecos; `n` huecos ocupados por instancias
#let rack(n, color: col.computo) = box(
  width: 0.55cm, inset: 2.5pt, radius: 2pt, stroke: 0.8pt + gris, fill: white,
  stack(dir: ttb, spacing: 2pt, ..range(5).map(i => box(width: 100%, height: 0.2cm, radius: 1pt,
    fill: if i < n { color } else { gris-claro }))),
)

#capitulo("EC2: cómputo en la nube", color: col.computo,
  subtitulo: [Servidores virtuales en minutos: elige imagen, tipo de instancia, almacenamiento, red y modelo de compra, y opéralos sin abrir un solo puerto SSH.],
  objetivos: (
    [Qué es una instancia y cómo nace a partir de una AMI],
    [Leer nombres como `m7g.xlarge` y elegir la familia adecuada],
    [El ciclo de vida de una instancia y qué se factura en cada estado],
    [Almacenamiento: EBS, instance store y EFS],
    [Red, user data, metadatos IMDSv2 y roles de instancia],
    [Modelos de compra, acceso seguro y Systems Manager],
  ),
  servicios: ("Amazon EC2", "Amazon EBS", "Amazon EFS", "AWS Systems Manager", "EC2 Image Builder", "AWS Nitro System"))

== ¿Qué es Amazon EC2?

Antes de la nube, conseguir un servidor implicaba pedirlo, esperar semanas, instalarlo en un rack y amortizarlo durante años. *Amazon Elastic Compute Cloud (EC2)* lo convierte en una llamada a una API: en uno o dos minutos tienes una *instancia* —una máquina virtual, o un servidor físico completo en los tipos _bare metal_— con el sistema operativo, la CPU, la memoria, el disco y la red que elijas, y dejas de pagar el cómputo cuando la paras o la eliminas. A cambio de esa flexibilidad, y según el modelo de responsabilidad compartida que vimos en el capítulo de Fundamentos, tú gestionas el sistema operativo invitado (parches incluidos), el software, los datos y las reglas de acceso; AWS, el hardware, la virtualización y la red física.

#ficha("Amazon EC2", "Capacidad de cómputo redimensionable en la nube",
  ("Tipo", [IaaS: máquinas virtuales y servidores _bare metal_ bajo demanda]),
  ("Ámbito", [Cada instancia vive en una subred y, por tanto, en una única zona de disponibilidad]),
  ("Facturación", [Por segundo (mínimo 60 s) en Linux y Windows; por hora en algunas AMI comerciales. Aparte: EBS, IPv4 públicas y transferencia de datos]),
  ("Límites clave", [Cuotas de vCPU por región y grupo de familias (ajustables en Service Quotas)]))

#datos(("750+", [tipos de instancia disponibles]), ("60 s", [mínimo facturable; después, por segundo]), ("2 min", [de aviso antes de interrumpir una Spot]), ("90 %", [descuento máximo de Spot frente a On-Demand]))

Da igual que lances la instancia desde la consola, la CLI, CloudFormation o un grupo de Auto Scaling: siempre decides los mismos ocho ingredientes, que este capítulo recorre uno por uno.

#diagrama(pie: [Los ocho ingredientes de una instancia. Una _launch template_ los guarda todos en una plantilla versionada.])[
  #fila(espacio: 3pt,
    mini("AMI", [Imagen (AMI)], col.computo),
    mini("m7g", [Tipo de instancia], col.computo),
    mini("EBS", [Discos: EBS o locales], col.almacenamiento),
    mini("VPC", [Red: subred, ENI, IPs], col.redes),
    mini("SG", [Security Groups], col.seguridad),
    mini("IAM", [Rol IAM (instance profile)], col.iam),
    mini("SSM", [Acceso: Session Manager o SSH], col.observabilidad),
    mini("init", [User data (primer arranque)], col.neutro),
  )
]

== Imágenes de máquina (AMI)

Una *Amazon Machine Image (AMI)* es la plantilla de la que nace el disco raíz: sistema operativo, software preinstalado y configuración. Por dentro, una AMI respaldada por EBS es una o varias *snapshots* más los permisos de lanzamiento (qué cuentas pueden usarla) y el *block device mapping* (qué volúmenes crear). Las AMI son *regionales*: el mismo sistema tiene un ID `ami-...` distinto en cada región, y para llevar una AMI propia a otra región hay que copiarla.

#tarjetas(
  tarjeta("Públicas", subtitulo: "AWS, editores y comunidad")[Amazon Linux 2023, Ubuntu, Windows Server, RHEL... Cualquiera puede publicar _community AMIs_: comprueba siempre el propietario.],
  tarjeta("AWS Marketplace", subtitulo: "Software de terceros listo para usar")[Firewalls, bases de datos o sistemas endurecidos; la licencia se suma a tu factura de EC2, normalmente por hora.],
)
#tarjetas(
  tarjeta("Propias", subtitulo: "Creadas por ti")[Desde una instancia configurada (`create-image`), con EC2 Image Builder o con Packer. Privadas por defecto; puedes compartirlas con otras cuentas.],
  tarjeta("Golden AMI", subtitulo: "La imagen oficial de la empresa")[AMI propia endurecida, parcheada, con los agentes corporativos y versionada. Todas las instancias parten de ella: arranques rápidos y homogéneos.],
)

#diagrama(pie: [Canalización de una _golden AMI_. EC2 Image Builder automatiza construcción, pruebas y distribución, y puede repetirla periódicamente para incorporar parches.])[
  #fila(
    svc("AMI", "AMI base", sub: "Amazon Linux 2023", color: col.neutro),
    flecha(etiqueta: "construir", largo: 1.2cm),
    caja([Parches + agentes SSM y CloudWatch + _hardening_ CIS], color: col.computo, ancho: 2.9cm),
    flecha(etiqueta: "probar", largo: 1.2cm),
    svc("AMI", "Golden AMI", sub: "web-v42", color: col.computo),
    flecha(etiqueta: "distribuir", largo: 1.3cm),
    columna(espacio: 5pt, caja([Otras regiones], ancho: 2.8cm), caja([Otras cuentas], ancho: 2.8cm), caja([Launch templates], ancho: 2.8cm)),
  )
]

No copies IDs de AMI a mano: los *parámetros públicos* de Systems Manager siempre apuntan a la última versión.

```bash
# ID de la última Amazon Linux 2023 para ARM64 (Graviton) en la región actual
aws ssm get-parameter --query Parameter.Value --output text \
  --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64
# Crear una AMI propia y copiarla a otra región
aws ec2 create-image --instance-id i-0abc1234def567890 --name web-v42
aws ec2 copy-image --source-region eu-west-1 --region eu-central-1 \
  --source-image-id ami-0123456789abcdef0 --name web-v42
```

#coste[`create-image` reinicia la instancia por defecto para obtener un sistema de ficheros consistente (`--no-reboot` lo evita, con riesgo). Y *dar de baja* (_deregister_) una AMI no borra sus snapshots, que se siguen facturando hasta que las eliminas.]

== Tipos de instancia: familias y nomenclatura

El *tipo de instancia* fija la combinación de CPU, memoria, almacenamiento local, red y aceleradores. AWS los agrupa en familias según el tipo de carga para el que están optimizados:

#tabla(("Familia", "Optimizada para", "Ejemplos", "Casos de uso típicos"), columnas: (0.5fr, 1.6fr, 1.05fr, 1.85fr), tamano: 8pt,
  [*T*], [General, CPU _burstable_], [`t4g`, `t3`, `t3a`], [Desarrollo y webs con poca carga],
  [*M*], [Equilibrada (1 vCPU : 4 GiB)], [`m7g`, `m7i`, `m8g`], [Aplicaciones y backends],
  [*C*], [Cómputo (1 vCPU : 2 GiB)], [`c7g`, `c7i`, `c8g`], [Lotes, vídeo, juegos, inferencia en CPU],
  [*R*], [Memoria (1 vCPU : 8 GiB)], [`r7g`, `r7i`, `r8g`], [Bases de datos y cachés en memoria],
  [*X*], [Mucha memoria (16+ GiB/vCPU)], [`x2idn`, `x8g`], [SAP HANA, bases de datos en memoria],
  [*I*], [NVMe local con muchas IOPS], [`i4i`, `i4g`], [NoSQL, OLTP, motores de búsqueda],
  [*D*], [HDD local denso], [`d3`, `d3en`], [HDFS, almacenamiento distribuido],
  [*P*], [GPU para entrenamiento y HPC], [`p4d`, `p5`], [Entrenamiento de IA a gran escala],
  [*G*], [GPU para gráficos e inferencia], [`g5`, `g6`, `g6e`], [Renderizado, _streaming_, inferencia],
  [*Inf*], [Chips AWS Inferentia], [`inf2`], [Inferencia al menor coste],
  [*Trn*], [Chips AWS Trainium], [`trn1`, `trn2`], [Entrenamiento de modelos de IA],
  [*Hpc*], [HPC con red EFA], [`hpc7g`, `hpc7a`], [Simulación (CFD), meteorología],
)

Dentro de cada familia, el nombre completo no es arbitrario: se lee por partes.

#let c1 = col.computo
#let c2 = col.datos
#let c3 = col.contenedores
#let c4 = col.redes
#diagrama(pie: [Anatomía de un nombre de tipo de instancia, letras de atributo frecuentes y escalera de tamaños.])[
  #grid(columns: 2, column-gutter: 20pt, align: horizon,
    {
      let s(t, c) = box(fill: c, radius: 5pt, inset: (x: 7pt, y: 8pt),
        text(26pt, weight: "bold", fill: white, font: "JetBrains Mono", t))
      s("m", c1); h(2pt); s("7", c2); h(2pt); s("g", c3)
      text(26pt, weight: "bold", fill: tinta, font: "JetBrains Mono", ".")
      s("xlarge", c4)
    },
    {
      set align(left)
      set par(justify: false)
      let it(c, tit, desc) = block(below: 6pt, {
        box(width: 8pt, height: 8pt, radius: 2pt, fill: c)
        h(4pt)
        text(8.5pt, weight: "bold", fill: c.darken(20%), tit)
        h(3pt)
        text(8pt, desc)
      })
      it(c1, "Familia", [`m`: propósito general])
      it(c2, "Generación", [7.ª; cuanto más alta, más moderna])
      it(c3, "Atributos", [`g`: procesador AWS Graviton (ARM)])
      it(c4, "Tamaño", [`xlarge`: 4 vCPU y 16 GiB de memoria])
    },
  )
  #v(8pt)
  #(("a · AMD", "g · Graviton", "i · Intel", "d · NVMe local", "n · red y EBS mejorados", "e · memoria o disco extra", "z · alta frecuencia", "b · optimizada para EBS", "flex · instancia Flex").map(t => pill(t, color: col.computo)).join(h(4pt)))
  #v(8pt)
  #{
    let tams = ("nano", "micro", "small", "medium", "large", "xlarge", "2xlarge", "…", "48xlarge", "metal")
    fila(espacio: 6pt, ..tams.enumerate().map(((i, t)) => {
      let lado = 0.3cm + i * 0.08cm
      columna(espacio: 3pt,
        box(width: lado, height: lado, radius: 2pt, fill: if t == "…" { white } else { c4.lighten(60% - i * 5%) }),
        text(6.3pt, font: "JetBrains Mono", fill: tinta, t))
    }), text(6.8pt, fill: gris.darken(15%))[#h(6pt) cada escalón suele duplicar \ #h(6pt) recursos y precio])
  }
]

#consejo[Truco: C de _Compute_, R de _RAM_, I de _IOPS_, D de _Dense storage_, G de _Graphics_. Elige la generación más reciente y deja que AWS Compute Optimizer te recomiende el tamaño según el uso real.]

=== Instancias T y créditos de CPU

Las instancias *T* son baratas porque no garantizan el 100 % de la CPU: tienen una *línea base* (el 10 % por vCPU en una `t3.micro`) y acumulan *créditos de CPU* mientras trabajan por debajo; en los picos los gastan. Un crédito es una vCPU al 100 % durante un minuto.

#tarjetas(
  tarjeta("Modo standard", subtitulo: "Por defecto en T2")[Sin créditos, la CPU queda limitada a la línea base: barato y predecible, pero la aplicación se ralentiza.],
  tarjeta("Modo unlimited", color: col.balanceo, subtitulo: "Por defecto en T3, T3a y T4g")[Puedes superar la línea base sin créditos; si la media de 24 h la excede, pagas un recargo por los créditos excedentes.],
)

#cuidado[Una T con CPU alta sostenida en modo _unlimited_ acaba costando más que una M equivalente. Si `CPUCreditBalance` vive en cero o `CPUSurplusCreditsCharged` crece, cambia de familia.]

=== Graviton y el sistema Nitro

*AWS Graviton* son los procesadores ARM64 diseñados por AWS (Graviton2, 3 y 4; letra `g`): mejor relación precio-rendimiento y menor consumo que las x86 comparables, también en RDS, ElastiCache, Lambda o Fargate. Java, Python, Node.js, Go o .NET funcionan sin cambios; solo necesitas binarios o imágenes de contenedor `arm64` (o multiarquitectura).

Por debajo de las instancias modernas está el *AWS Nitro System*: AWS sacó las funciones de virtualización (red VPC, acceso a EBS, almacenamiento local, gestión) de la CPU principal y las llevó a *tarjetas Nitro* dedicadas, con un hipervisor mínimo y un chip de seguridad como raíz de confianza. Consecuencias prácticas:

- Casi todos los recursos del servidor quedan para tus instancias, y existen tipos `.metal` sin hipervisor.
- Por diseño, ningún operador de AWS puede iniciar sesión en el host ni leer la memoria de tus instancias; *Nitro Enclaves* crea entornos aislados, sin red ni disco persistente, para datos muy sensibles.
- Los volúmenes EBS aparecen como dispositivos NVMe (`/dev/nvme1n1`) y la red usa siempre el adaptador ENA.

== Ciclo de vida de una instancia

Una instancia pasa por estados bien definidos. Conocerlos evita sustos, tanto en la factura como en los datos.

#diagrama(pie: [Estados de una instancia EC2. Solo se factura el cómputo en _running_ (y en _stopping_ cuando hibernas). En _stopped_ sigues pagando los volúmenes EBS y las IPv4 públicas asignadas.])[
  #box(width: 15cm, height: 4.75cm, {
    let ambar = col.balanceo
    let verde = rgb("#2F9E44")
    let y1 = 1.2cm
    let yc = y1 + 0.425cm
    let y2 = 3.5cm
    let yc2 = y2 + 0.425cm
    // Lanzamiento
    place(dx: 0.1cm, dy: yc - 4pt, circle(radius: 4pt, fill: tinta))
    seg(0.1cm + 8pt, yc, 1.5cm, yc)
    punta(1.5cm, yc, "der")
    rotulo(-0.1cm, yc - 0.55cm, 1.6cm, [lanzar])
    estado(1.5cm, y1, "pending", ambar)
    seg(3.9cm, yc, 5.0cm, yc)
    punta(5.0cm, yc, "der")
    estado(5.0cm, y1, "running", verde)
    place(dx: 5.0cm - 6.5pt, dy: y1 - 7pt, circle(radius: 6.5pt, fill: col.costes,
      align(center + horizon, text(7pt, weight: "bold", fill: white, "$"))))
    seg(7.4cm, yc, 9.4cm, yc)
    punta(9.4cm, yc, "der")
    rotulo(7.4cm, yc - 0.5cm, 2.0cm, [stop / hibernate])
    estado(9.4cm, y1, "stopping", ambar)
    seg(11.8cm, yc, 12.6cm, yc)
    punta(12.6cm, yc, "der")
    estado(12.6cm, y1, "stopped", col.neutro)
    // start: de stopped a pending por arriba
    seg(13.8cm, y1, 13.8cm, 0.45cm)
    seg(13.8cm, 0.45cm, 2.7cm, 0.45cm)
    seg(2.7cm, 0.45cm, 2.7cm, y1)
    punta(2.7cm, y1, "abajo")
    rotulo(7.6cm, 0.05cm, 5.6cm, [start (normalmente en otro host físico)])
    rotulo(4.5cm, 0.62cm, 3.0cm, [↻ reboot: sigue en running], tam: 6.2pt)
    rotulo(9.4cm, 2.2cm, 2.4cm, [hibernate: la RAM se guarda en el volumen raíz], tam: 6.2pt)
    // terminate desde running
    seg(6.2cm, y1 + 0.85cm, 6.2cm, y2)
    punta(6.2cm, y2, "abajo")
    rotulo(6.35cm, 2.6cm, 2cm, [terminate], alin: left)
    // terminate desde stopped
    seg(13.8cm, y1 + 0.85cm, 13.8cm, yc2)
    seg(13.8cm, yc2, 7.4cm, yc2)
    punta(7.4cm, yc2, "izq")
    rotulo(9.6cm, yc2 - 0.42cm, 2.0cm, [terminate])
    estado(5.0cm, y2, "shutting-down", ambar)
    seg(5.0cm, yc2, 3.9cm, yc2)
    punta(3.9cm, yc2, "izq")
    estado(1.5cm, y2, "terminated", col.seguridad)
  })
]

#tabla(("Acción", "Qué se conserva", "IPv4 pública automática", "Instance store", "RAM"), columnas: (0.9fr, 2fr, 1.3fr, 1fr, 1fr), tamano: 8pt,
  [*Reboot*], [Todo: mismo host, IPs y volúmenes], [Se mantiene], [Se conserva], [Se pierde],
  [*Stop / start*], [Volúmenes EBS, ID, IP privada e IP elástica], [Cambia], [Se pierde], [Se pierde],
  [*Hibernate*], [Lo mismo que _stop_ más la RAM], [Cambia], [Se pierde], [Se restaura],
  [*Terminate*], [Nada, salvo volúmenes con `DeleteOnTermination=false`], [Se libera], [Se pierde], [Se pierde],
)

Al terminar se borra por defecto el volumen raíz y se conservan los demás volúmenes EBS. Activa la *protección contra terminación* en instancias críticas; un `shutdown` desde el sistema operativo *para* la instancia salvo que lo configures. La *hibernación* ayuda con arranques lentos o cachés calientes: exige un volumen raíz cifrado con espacio para la RAM, solo existe en ciertos tipos y AMI y dura como máximo 60 días.

== Almacenamiento: EBS, instance store y EFS

Una instancia puede usar discos de red persistentes (EBS), discos locales efímeros (instance store) y sistemas de ficheros compartidos (EFS). El diagrama resume dónde vive cada uno.

#diagrama(pie: [Un volumen EBS pertenece a una AZ; para llevarlo a otra se pasa por una snapshot regional. El instance store vive en el host físico y EFS se comparte entre AZ mediante _mount targets_.])[
  #grid(columns: 5, column-gutter: 4pt, row-gutter: 2pt, align: center + horizon,
    zona("AZ a", color: col.neutro)[
      #columna(
        zona("Host físico", color: col.computo)[#fila(svc("EC2", "Instancia A", color: col.computo), svc("NVMe", "Instance store", sub: "efímero", color: col.computo))],
        flecha-v(doble: true, etiqueta: "red", largo: 0.7cm),
        svc("EBS", "Volumen gp3", sub: "solo en la AZ a", color: col.almacenamiento),
      )
    ],
    flecha(etiqueta: "snapshot", largo: 1.25cm),
    svc("SNAP", "Snapshot", sub: "incremental, en S3 (regional)", color: col.almacenamiento),
    flecha(etiqueta: "restaurar", largo: 1.25cm),
    zona("AZ b", color: col.neutro)[
      #columna(
        svc("EC2", "Instancia B", color: col.computo),
        flecha-v(doble: true, etiqueta: "red", largo: 0.7cm),
        svc("EBS", "Volumen nuevo", sub: "en la AZ b", color: col.almacenamiento),
      )
    ],
    flecha-v(etiqueta: "NFS", largo: 0.6cm), [], [], [], flecha-v(etiqueta: "NFS", largo: 0.6cm),
    grid.cell(colspan: 5, zona("Amazon EFS · regional, multi-AZ", color: col.almacenamiento, ancho: 100%)[
      #grid(columns: (6.2cm, 1fr, 3.1cm), align: center + horizon,
        caja([Mount target · AZ a], color: col.almacenamiento),
        text(6.8pt, fill: gris.darken(20%))[Clases: Standard · Infrequent Access · Archive],
        caja([Mount target · AZ b], color: col.almacenamiento))
    ]),
  )
]

=== Amazon EBS: discos de red persistentes

*Elastic Block Store (EBS)* ofrece volúmenes de bloque conectados por la red que sobreviven a la instancia. Cada volumen vive en *una sola AZ* (y se replica dentro de ella) y solo se conecta a instancias de esa AZ. Con _Elastic Volumes_ amplías el tamaño o cambias el tipo y el rendimiento en caliente.

#tabla(("Tipo", "Medio", "Rendimiento", "Arranque", "Casos de uso"), columnas: (1.1fr, 0.6fr, 2.5fr, 0.65fr, 1.6fr), tamano: 8pt,
  [*gp3*], [SSD], [3000 IOPS y 125 MiB/s incluidos con cualquier tamaño; más IOPS y _throughput_ aprovisionables sin agrandar el volumen], si, [Por defecto: discos raíz, aplicaciones, bases de datos medianas],
  [*gp2*], [SSD], [3 IOPS por GiB (de 100 a 16~000), ráfagas de 3000 en volúmenes pequeños], si, [Heredado: migra a gp3],
  [*io2 Block Express*], [SSD], [Hasta 256~000 IOPS y 4000 MiB/s, latencia submilisegundo, durabilidad del 99,999~%], si, [Bases de datos críticas],
  [*st1*], [HDD], [_Throughput_ secuencial de hasta 500 MiB/s], no, [Big data, logs],
  [*sc1*], [HDD], [Hasta 250 MiB/s; el menor coste por GB], no, [Datos fríos],
)

/ Snapshots: copias incrementales que AWS guarda en S3 (no aparecen en tus _buckets_). Son regionales: con ellas creas volúmenes en cualquier AZ, las copias a otra región o las compartes. Automatízalas con AWS Backup o Data Lifecycle Manager; la _Recycle Bin_ protege de borrados accidentales.
/ Cifrado: con KMS cifra los datos en reposo, en tránsito hacia la instancia y las snapshots. Activa el *cifrado por defecto* en cada región. Un volumen sin cifrar no se cifra «en el sitio»: snapshot, copia cifrada y volumen nuevo.
/ Multi-Attach: solo io1/io2, hasta 16 instancias Nitro de la misma AZ, y con un sistema de ficheros de clúster (ext4 o XFS se corromperían).

#consejo[gp3 es hasta un 20 % más barato por GB que gp2 y desacopla rendimiento y tamaño: migra con Elastic Volumes sin parar la instancia.]

=== Instance store y Amazon EFS

El *instance store* son discos (normalmente NVMe) físicamente conectados al host: rapidísimos e incluidos en el precio de los tipos que los tienen (letra `d`, familias I y D), pero *efímeros*. Sus datos sobreviven a un reinicio y se pierden al parar, hibernar o terminar la instancia, o si falla el hardware. Úsalos para cachés, temporales o datos replicados en otros nodos (Cassandra, Kafka), nunca para algo que no puedas regenerar.

#ficha("Amazon EFS", "Sistema de ficheros NFS elástico y totalmente gestionado",
  ("Protocolo", [NFS v4.0 y v4.1 para clientes Linux; miles de instancias, contenedores o funciones Lambda a la vez]),
  ("Ámbito", [Regional (datos en varias AZ) u One Zone; un _mount target_ por AZ con Security Group (puerto 2049)]),
  ("Capacidad", [Crece y decrece sola; pagas por GB almacenado. Las clases IA y Archive abaratan lo que no se lee; el modo de _throughput_ Elastic se ajusta solo]))

Para otros protocolos o rendimiento extremo existe *Amazon FSx*: para Windows File Server (SMB y Active Directory), Lustre (HPC y ML, integrado con S3), NetApp ONTAP (NFS, SMB e iSCSI) y OpenZFS. Lo veremos junto a S3 en el capítulo de Almacenamiento.

#tabla(("Característica", "EBS", "Instance store", "EFS"), columnas: (1.1fr, 1.3fr, 1.3fr, 1.3fr), tamano: 8pt,
  [Tipo y ámbito], [Bloque, en una AZ], [Bloque, en el host físico], [Ficheros (NFS), regional],
  [Persistencia], [Independiente de la instancia], [Se pierde al parar o terminar], [Independiente],
  [Acceso simultáneo], [Una instancia (Multi-Attach en io1/io2)], [Solo su instancia], [Miles de clientes],
  [Se paga por], [GB aprovisionado (+ IOPS y _throughput_)], [Incluido en la instancia], [GB usado (+ accesos IA/Archive)],
  [Caso típico], [Disco raíz, bases de datos], [Cachés, temporales], [Contenido compartido, _home_],
)

== Redes en EC2

Toda instancia se conecta a la VPC con al menos una *Elastic Network Interface (ENI)*: una tarjeta de red virtual con IP privada principal, IPs secundarias opcionales, MAC y sus propios Security Groups (5 por ENI por defecto, ampliable). La principal (`eth0`) no se separa; las secundarias pueden moverse a otra instancia de la misma AZ. El máximo de ENI e IPs depende del tipo.

#diagrama(pie: [El sistema operativo solo ve IPs privadas: el Internet Gateway traduce 1:1 la IPv4 pública (o elástica) a la privada de la ENI.])[
  #fila(
    internet(),
    flecha(etiqueta: "203.0.113.10", largo: 1.9cm),
    svc("IGW", "Internet Gateway", sub: "NAT 1:1", color: col.redes),
    flecha(etiqueta: "10.0.1.25", largo: 1.6cm),
    zona("VPC 10.0.0.0/16", color: col.redes)[
      #zona("Instancia EC2", color: col.computo)[
        #columna(espacio: 6pt,
          caja([*eth0* · ENI principal \ 10.0.1.25 + IP elástica \ SG: _web_], color: col.redes, ancho: 4.6cm),
          caja([*eth1* · ENI secundaria \ 10.0.2.40 · subred de gestión \ SG: _admin_], color: col.redes, ancho: 4.6cm),
        )
      ]
    ],
  )
]

/ IP privada: sale del rango de la subred y se mantiene toda la vida de la instancia, aunque la pares.
/ IPv4 pública automática: la asigna AWS al lanzar si la subred o la ENI lo piden; cambia en cada _stop/start_.
/ IP elástica (EIP): IPv4 pública estática y regional que reservas en tu cuenta y mueves entre instancias en segundos.
/ IPv6: direcciones globales sin NAT; para permitir solo salida se usa un _egress-only internet gateway_ (capítulo de Redes).

#coste[Desde febrero de 2024 AWS factura por hora *todas* las IPv4 públicas, incluidas las automáticas y las IP elásticas, asociadas o no. Libera las EIP que no uses y no expongas cada instancia: pon un balanceador delante.]

Los *Security Groups* filtran el tráfico de cada ENI con estado (los estudiamos en el capítulo de Redes). Todas las instancias actuales usan *enhanced networking* con el *Elastic Network Adapter (ENA)*, que mediante SR-IOV ofrece decenas o cientos de Gbps según el tipo. Para HPC y entrenamiento distribuido, el *Elastic Fabric Adapter (EFA)* añade a ENA un modo _OS-bypass_ con el que MPI o NCCL hablan con el hardware de red sin pasar por el kernel; ese tráfico solo funciona dentro de una misma subred.

=== Placement groups

Por defecto, EC2 reparte tus instancias por el hardware como mejor le parece. Un *placement group*, sin coste adicional, te deja influir en esa colocación:

#let pg(titulo, dibujo, cuerpo) = columna(espacio: 6pt,
  box(height: 1.75cm, align(center + horizon, dibujo)),
  text(9pt, weight: "bold", fill: col.computo.darken(20%), titulo),
  box(width: 100%, {
    set par(justify: false, leading: 0.45em)
    align(left, text(7.8pt, cuerpo))
  }))
#diagrama(pie: [Estrategias de _placement group_. Cada rectángulo vertical es un rack con su propia red y alimentación.])[
  #grid(columns: (1fr, 1fr, 1fr), column-gutter: 16pt, align: center + top,
    pg("Cluster",
      box(fill: col.computo.lighten(85%), radius: 4pt, inset: 4pt, fila(espacio: 2pt, rack(5), rack(5), rack(4))),
      [Juntas en hardware cercano de *una sola AZ*: mínima latencia y máximo ancho de banda (HPC con EFA). Un fallo del hardware compartido puede afectar a todas.]),
    pg("Spread",
      fila(espacio: 7pt, rack(1), rack(1), rack(1), rack(1), rack(1)),
      [Cada instancia en un rack distinto, *máximo 7 por AZ* y grupo. Para pocas instancias críticas que no deben caer juntas (quórum, primario y réplica).]),
    pg("Partition",
      fila(espacio: 7pt, ..((col.contenedores, "P1", 4, 3), (col.datos, "P2", 4, 4), (col.iam, "P3", 3, 4)).map(((c, p, a, b)) =>
        columna(espacio: 3pt, fila(espacio: 2pt, rack(a, color: c), rack(b, color: c)), text(6.5pt, weight: "bold", fill: c, p)))),
      [Particiones (*hasta 7 por AZ*) que no comparten racks; cientos de instancias. HDFS, HBase, Cassandra o Kafka leen su partición en los metadatos.]),
  )
]

#examen[¿Mínima latencia entre nodos HPC? Placement group _cluster_ + EFA. ¿IP pública fija? IP elástica. ¿Conmutar una IP a un servidor de respaldo? ENI secundaria movida a otra instancia de la misma AZ. ¿Instancias críticas sin hardware compartido? Placement group _spread_.]

== Arranque, metadatos e identidad

=== User data y cloud-init

El *user data* es un script (o una configuración de cloud-init) que la instancia ejecuta como `root` en su *primer arranque*; en Linux lo interpreta *cloud-init* y en Windows, EC2Launch. Admite hasta 16 KB y su salida queda en `/var/log/cloud-init-output.log`.

```bash
#!/bin/bash
# User data: se ejecuta como root en el primer arranque (Amazon Linux 2023)
dnf install -y nginx
echo "<h1>Hola desde $(hostname)</h1>" > /usr/share/nginx/html/index.html
systemctl enable --now nginx
```

*Cuidado*: el user data no es secreto (lo lee cualquier proceso de la instancia y quien tenga `ec2:DescribeInstanceAttribute`); las contraseñas, léelas al arrancar de Secrets Manager o Parameter Store.

=== Roles de instancia (instance profile)

Una aplicación en EC2 que llama a S3 o DynamoDB *nunca* debe llevar _access keys_ en un fichero: asocia a la instancia un *rol IAM* mediante un *instance profile* (un contenedor con exactamente un rol). EC2 asume el rol y publica en el servicio de metadatos (IMDS, que vemos a continuación) credenciales temporales que se renuevan solas y que los SDK y la CLI encuentran automáticamente. La consola crea el instance profile por ti (con la CLI: `create-instance-profile` y `add-role-to-instance-profile`), y el rol se puede cambiar en caliente.

#diagrama(pie: [Cómo llegan las credenciales de un rol a tu código sin guardar ninguna clave en la instancia.])[
  #fila(
    svc("IAM", "Rol IAM", sub: "en un instance profile", color: col.iam),
    flecha(etiqueta: "asociado a", largo: 1.3cm),
    zona("Instancia EC2", color: col.computo)[
      #fila(
        svc("IMDS", "Metadatos", sub: "credenciales del rol", color: col.computo),
        flecha(etiqueta: "token + GET", doble: true, largo: 1.5cm),
        svc("APP", "Tu aplicación", sub: "SDK o CLI", color: col.neutro),
      )
    ],
    flecha(etiqueta: "API firmada", largo: 1.5cm),
    svc("S3", "Amazon S3", color: col.almacenamiento),
  )
]

=== Metadatos de instancia: IMDSv2

Cada instancia consulta datos sobre sí misma (ID, tipo, AZ, IPs, user data, credenciales de su rol) en el *Instance Metadata Service (IMDS)*, accesible solo desde dentro en `169.254.169.254`. Con *IMDSv2* primero se pide un _token_ con un `PUT` (válido de 1 segundo a 6 horas) y después se envía en cada consulta:

```bash
TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
curl -sH "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone
```

¿Por qué? Con IMDSv1 bastaba un `GET`: una vulnerabilidad SSRF (_Server-Side Request Forgery_) o un proxy mal configurado permitían robar las credenciales del rol. El `PUT` con cabecera propia es mucho más difícil de provocar, y la respuesta no pasa de un salto de red (_hop limit_).

#practica[Exige IMDSv2 (`HttpTokens=required`) en las launch templates y por defecto en la cuenta (`modify-instance-metadata-defaults`); Amazon Linux 2023 ya lo exige. Sube el _hop limit_ a 2 solo si hay contenedores que usen el IMDS.]

== Modelos de compra

La misma instancia puede costar muy distinto según cómo la compres; es la palanca de ahorro más potente de EC2 (el capítulo de Costes amplía la estrategia).

#tabla(("Modelo", "Compromiso", "Ahorro orientativo", "¿Interrupción?", "Ideal para"), columnas: (1.15fr, 1.5fr, 1.2fr, 0.9fr, 1.7fr), tamano: 8pt,
  [*On-Demand*], [Ninguno; pagas por segundo], [Precio de referencia], no, [Cargas impredecibles, pruebas, picos],
  [*Savings Plans*], [Gasto por hora durante 1 o 3 años], [Hasta 72~% (EC2 Instance) o 66~% (Compute)], no, [Base estable; Compute SP cubre también Fargate y Lambda],
  [*Reserved Instances*], [Tipo y región (o AZ), 1 o 3 años], [Hasta 72~% (Standard)], no, [Cargas muy estables; hoy se prefieren los Savings Plans],
  [*Spot*], [Ninguno], [Hasta 90~%], [Sí, aviso de 2 min], [Lotes, CI, contenedores, cargas tolerantes a fallos],
  [*Dedicated Instances*], [Ninguno (también reservables)], [Más caras], no, [Hardware no compartido con otras cuentas],
  [*Dedicated Hosts*], [Por servidor físico], [Más caros], no, [Licencias por socket o núcleo (BYOL), macOS],
  [*Capacity Reservations*], [Capacidad en una AZ, sin plazo mínimo], [Ninguno (se combinan con SP o RI)], no, [Garantizar capacidad para eventos o DR],
)

#let demanda = (5, 5, 4, 4, 4, 5, 6, 8, 10, 11, 12, 12, 11, 12, 12, 11, 10, 9, 8, 7, 7, 6, 6, 5)
#let lotes = (4, 4, 4, 4, 3, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 3, 4)
#let c-sp = col.computo
#let c-od = col.balanceo.lighten(35%)
#let c-spot = col.contenedores
#diagrama(pie: [Estrategia típica: la base 24/7 con Savings Plans, los picos diurnos con On-Demand y los lotes nocturnos con Spot.])[
  #grid(columns: (auto, auto), column-gutter: 22pt, align: horizon,
    {
      let u = 0.155cm
      let alto = 2.2cm
      box(width: 9.6cm, height: alto + 0.42cm, {
        for (i, d) in demanda.enumerate() {
          let x = i * 0.4cm
          let hb = 4 * u
          let ho = (d - 4) * u
          let hs = lotes.at(i) * u
          place(dx: x, dy: alto - hb, rect(width: 0.32cm, height: hb, fill: c-sp))
          if d > 4 { place(dx: x, dy: alto - hb - ho, rect(width: 0.32cm, height: ho, fill: c-od)) }
          if lotes.at(i) > 0 { place(dx: x, dy: alto - hb - ho - hs, rect(width: 0.32cm, height: hs, fill: c-spot)) }
        }
        place(dx: 0cm, dy: alto, line(length: 9.6cm, stroke: 0.6pt + gris))
        place(dx: 0cm, dy: alto + 0.12cm, text(6.3pt, fill: gris, "0 h"))
        place(dx: 4.6cm, dy: alto + 0.12cm, text(6.3pt, fill: gris, "12 h"))
        place(dx: 9.1cm, dy: alto + 0.12cm, text(6.3pt, fill: gris, "24 h"))
      })
    },
    {
      set align(left)
      set par(justify: false)
      let ley(c, t, d) = block(below: 7pt, grid(columns: (auto, 4.2cm), column-gutter: 6pt,
        box(width: 9pt, height: 9pt, radius: 2pt, fill: c),
        [#text(8pt, weight: "bold", t) \ #text(7pt, fill: gris.darken(15%), d)]))
      ley(c-spot, "Spot", [Lotes nocturnos que pueden reintentarse])
      ley(c-od, "On-Demand", [Picos variables del horario laboral])
      ley(c-sp, "Savings Plans / RI", [Capacidad mínima encendida 24/7])
    },
  )
]

*Spot* aprovecha la capacidad libre de EC2, con un precio que varía poco a poco (ya no hay pujas). Cuando AWS la necesita, avisa con *2 minutos* de antelación en los metadatos (`spot/instance-action`) y en EventBridge (a veces antes llega una *rebalance recommendation*), y la instancia se termina, se para o se hiberna. Diversifica tipos y AZ y deja elegir a Auto Scaling o EC2 Fleet con `price-capacity-optimized`.

#coste[Los Compute Savings Plans siguen aplicándose aunque cambies de familia, región o SO, o pases a Fargate o Lambda. Las Capacity Reservations se cobran *las uses o no*.]

== Acceso a las instancias

La forma clásica de entrar en un Linux es SSH con un *par de claves*: EC2 inyecta la clave pública en la instancia y tú custodias la privada (AWS no guarda copia). Obliga a abrir el puerto 22, a rotar ficheros `.pem` y a mantener bastiones.

#tabla(("", "SSH con par de claves", "EC2 Instance Connect", "Session Manager"), columnas: (1fr, 1.3fr, 1.4fr, 1.4fr), tamano: 8pt,
  [*Puerto entrante*], [22 abierto en el SG], [22 (desde tu IP o desde un EC2 Instance Connect Endpoint)], [Ninguno],
  [*Claves*], [Las custodias y rotas tú], [Temporales, válidas 60 s], [No hay claves],
  [*Quién entra*], [Quien tenga la clave privada], [Quien tenga permisos IAM], [Quien tenga permisos IAM],
  [*Auditoría*], [Logs del sistema operativo], [CloudTrail registra cada envío de clave], [CloudTrail + registro de sesión en S3 o CloudWatch Logs],
  [*Subredes privadas*], [Bastión o VPN], [Con EC2 Instance Connect Endpoint], [Sí, vía NAT o VPC endpoints],
)

```bash
ssh -i ~/.ssh/mi-clave.pem ec2-user@203.0.113.10                # SSH clásico
aws ec2-instance-connect ssh --instance-id i-0abc1234def567890  # Instance Connect
aws ssm start-session --target i-0abc1234def567890              # Session Manager
aws ssm start-session --target i-0abc1234def567890 \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters '{"host":["db.interna.local"],"portNumber":["5432"],
                 "localPortNumber":["5432"]}'        # túnel a una BD privada
```

#practica[Usa *Session Manager* por defecto: sin puertos entrantes ni claves, con acceso por IAM y sesiones auditadas. Necesita el SSM Agent (preinstalado en las AMI de Amazon Linux, Ubuntu y Windows de AWS), un rol con la política `AmazonSSMManagedInstanceCore` y salida hacia los endpoints `ssm`, `ssmmessages` y `ec2messages`, por NAT o con VPC endpoints.]

== AWS Systems Manager

Session Manager es solo una de las capacidades de *AWS Systems Manager*, la navaja suiza para operar flotas de servidores sin entrar en ellos uno a uno.

#ficha("AWS Systems Manager", "Operación centralizada de instancias y servidores",
  ("Requisitos", [SSM Agent, permisos IAM y conectividad con los endpoints de Systems Manager]),
  ("Ámbito", [Regional; gestiona EC2 y también servidores on-premises o de otras nubes (nodos híbridos)]),
  ("Coste", [Muchas capacidades no tienen coste adicional en EC2; algunas avanzadas sí]))

/ Run Command: ejecuta un documento (como `AWS-RunShellScript`) en cientos de instancias elegidas por etiquetas, con control de concurrencia y de errores.
/ Patch Manager: aplica parches del sistema operativo según _patch baselines_ y ventanas de mantenimiento, e informa del cumplimiento.
/ Parameter Store: configuración y secretos jerárquicos (`SecureString`, cifrados con KMS); lo ampliamos en el capítulo de Seguridad. Hay más: Inventory, State Manager, Automation o Fleet Manager.

```bash
# Reiniciar nginx en todas las instancias web de producción
aws ssm send-command --document-name AWS-RunShellScript \
  --targets "Key=tag:App,Values=web" "Key=tag:Entorno,Values=prod" \
  --parameters 'commands=["systemctl restart nginx"]' \
  --max-concurrency 25% --max-errors 1
```

== Launch templates

Una *launch template* guarda todos los parámetros de lanzamiento (AMI, tipo, Security Groups, instance profile, volúmenes, metadatos, user data, opciones de Spot) en una plantilla *versionada*. Cada cambio crea una versión (puedes marcar una como _default_, usar `$Latest` o fijar un número). La usan `run-instances`, Auto Scaling y EC2 Fleet, y sustituye a las antiguas _launch configurations_, obsoletas. `UserData` va en base64:

```json
{
  "ImageId": "ami-0123456789abcdef0",
  "InstanceType": "m7g.large",
  "IamInstanceProfile": { "Name": "web-profile" },
  "SecurityGroupIds": ["sg-0123456789abcdef0"],
  "MetadataOptions": { "HttpTokens": "required", "HttpPutResponseHopLimit": 1 },
  "BlockDeviceMappings": [{ "DeviceName": "/dev/xvda",
    "Ebs": { "VolumeSize": 20, "VolumeType": "gp3", "Encrypted": true } }],
  "UserData": "IyEvYmluL2Jhc2gKZG5mIGluc3RhbGwgLXkgbmdpbngK"
}
```

```bash
aws ec2 create-launch-template --launch-template-name web \
  --launch-template-data file://lt.json
aws ec2 run-instances --launch-template LaunchTemplateName=web,Version='$Latest'
```


== Buenas prácticas

- *Seguridad*: IMDSv2 obligatorio, roles de instancia, Session Manager y cifrado de EBS por defecto.
- *Inmutabilidad*: instancias como ganado, no mascotas: golden AMI + launch templates, y reemplazar en vez de parchear a mano.
- *Fiabilidad*: varias AZ con Auto Scaling y balanceadores; snapshots automáticas con AWS Backup.
- *Coste*: Compute Optimizer, Graviton, Savings Plans + Spot, gp3; borra volúmenes sueltos, snapshots viejas y EIP libres.
- *Operación*: etiqueta todo, parchea con Patch Manager y envía métricas y logs a CloudWatch.

#resumen[
  - EC2 da máquinas virtuales facturadas por segundo; tú gestionas el sistema operativo y lo de encima. Nacen de una *AMI* (regional); las *golden AMI* homogeneizan los despliegues.
  - `m7g.xlarge` = familia, generación, atributos y tamaño. Las T usan créditos de CPU; Graviton mejora el precio-rendimiento y Nitro sostiene todo.
  - Solo se factura el cómputo en _running_; parar conserva EBS, pero libera la IPv4 pública automática y borra el instance store.
  - *EBS* es un disco de red persistente ligado a una AZ (gp3 por defecto); el *instance store* es local y efímero; *EFS* es NFS compartido y multi-AZ.
  - Las IPv4 públicas y elásticas se pagan por hora; ENA y EFA aceleran la red y los _placement groups_ controlan la colocación. *IMDSv2* y los *roles de instancia* dan credenciales sin claves en disco.
  - Savings Plans para la base, On-Demand para los picos, Spot (aviso de 2 minutos) para lo tolerante a interrupciones.
  - Accede con *Session Manager*, opera con Systems Manager y lanza siempre desde *launch templates* versionadas.
]

#repaso(
  ([Necesitas mover un volumen EBS de `eu-west-1a` a `eu-west-1b`. ¿Cómo lo haces?], [Creas una snapshot (regional) y, a partir de ella, un volumen nuevo en `eu-west-1b`. Un volumen EBS no se conecta a instancias de otra AZ.]),
  ([¿Qué significa cada parte de `c7gn.2xlarge`?], [Familia C (cómputo), 7.ª generación, atributos `g` (Graviton) y `n` (red mejorada), tamaño `2xlarge`.]),
  ([Paras y vuelves a arrancar una instancia. ¿Qué cambia?], [Conserva EBS, IP privada e IP elástica; cambia la IPv4 pública automática y se pierden la RAM y el instance store. Parada no paga cómputo, pero sí EBS.]),
  ([¿Por qué IMDSv2 es más seguro que IMDSv1?], [Exige un token obtenido con un `PUT` y enviado en una cabecera, difícil de provocar con un ataque SSRF, y la respuesta con el token no sale de la instancia (_hop limit_).]),
  ([Un clúster HPC necesita la mínima latencia entre nodos. ¿Qué configuras?], [Un placement group _cluster_ en una sola AZ, con tipos de instancia que admitan EFA.]),
  ([¿Qué modelo de compra eliges para un proceso nocturno que puede reintentarse?], [Spot (hasta un 90 % de descuento), diversificando tipos y AZ, porque tolera interrupciones con 2 minutos de aviso.]),
)
