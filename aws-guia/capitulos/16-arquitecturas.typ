#import "../theme.typ": *

// ---------------------------------------------------------------------
//  Utilidades locales del capítulo
// ---------------------------------------------------------------------
#let gris-flecha = rgb("#7A8699")

// Marcador numerado: enlaza cada flecha del diagrama con su paso
#let n(i) = box(baseline: 2.2pt, circle(radius: 5.2pt, fill: col.arquitectura, inset: 0pt,
  align(center + horizon, text(6.2pt, weight: "bold", fill: white, str(i)))))

// Marcador pequeño para títulos de zona
#let nm(i) = box(baseline: 1.2pt, circle(radius: 3.9pt, fill: white, inset: 0pt,
  align(center + horizon, text(5.4pt, weight: "bold", fill: col.arquitectura, str(i)))))

// Flecha horizontal hacia la izquierda (mismo estilo que `flecha`)
#let flecha-izq(etiqueta: none, largo: 1.4cm, color: gris-flecha, punteada: false) = box(
  width: largo, height: 2.6em, {
    let st = (paint: color, thickness: 1.2pt, dash: if punteada { "dashed" } else { none })
    place(right + horizon, line(length: largo - 5pt, stroke: st))
    place(left + horizon, polygon(fill: color, (7pt, 0pt), (0pt, 3.5pt), (7pt, 7pt)))
    if etiqueta != none {
      place(center + top, dy: -1pt, box(width: largo + 0.8cm, align(center, {
        set par(justify: false, leading: 0.3em)
        text(6.4pt, fill: color.darken(25%), weight: "medium", etiqueta)
      })))
    }
  },
)

// Abanico (fan-out): una barra con n flechas hacia abajo
#let abanico(ancho, piezas: 3, alto: 0.55cm, color: gris-flecha) = box(width: ancho + 8pt, height: alto, {
  place(top + left, dx: 4pt, line(length: ancho, stroke: 1.2pt + color))
  for i in range(piezas) {
    let x = ancho * i / (piezas - 1)
    place(top + left, dx: x, flecha-v(largo: alto, color: color))
  }
})

// Cuenta de AWS (diagrama multi-cuenta)
#let cuenta(nombre, desc, color: col.fundamentos, ancho: 2.75cm) = box(
  width: ancho, fill: white, radius: (right: 4pt),
  stroke: (left: 3pt + color, top: 0.8pt + color.lighten(30%), right: 0.8pt + color.lighten(30%), bottom: 0.8pt + color.lighten(30%)),
  inset: (left: 6pt, right: 5pt, y: 4pt),
  align(left, {
    set par(justify: false, leading: 0.35em)
    text(7.2pt, weight: "bold", fill: tinta, nombre)
    linebreak()
    text(6.2pt, fill: gris, desc)
  }),
)

#capitulo(text(hyphenate: false)[Arquitecturas de referencia], color: col.arquitectura,
  subtitulo: [Ocho diseños que verás una y otra vez, explicados pieza a pieza: el punto de partida para tus propias arquitecturas.],
  objetivos: (
    [Web de tres capas altamente disponible],
    [Microservicios en contenedores con ECS],
    [APIs serverless y procesamiento por eventos],
    [Sitios estáticos y pipelines de datos],
    [Estrategia multi-cuenta con Organizations],
    [Recuperación ante desastres multirregión],
  ),
  servicios: ("Route 53", "CloudFront", "ALB", "ECS Fargate", "Lambda", "DynamoDB", "SQS", "EventBridge", "Kinesis", "Organizations"))

Este capítulo junta las piezas de toda la guía en ocho arquitecturas habituales. En cada diagrama, los números siguen el recorrido de una petición o de un dato y coinciden con los pasos, que explican qué hace cada pieza y *por qué* está ahí. Son puntos de partida: contrástalos con la checklist Well-Architected del final.

== Aplicación web de tres capas altamente disponible

El clásico: presentación, lógica y datos separados en capas, cada una repartida en dos zonas de disponibilidad para sobrevivir a la caída de una de ellas.

#diagrama(pie: [Web de tres capas: borde global (Route 53, CloudFront, WAF), balanceador en subredes públicas, Auto Scaling en subredes privadas y datos Multi-AZ.])[
  #grid(columns: (3.84cm, 1.4cm, 2.7cm, 1fr), align: center + horizon,
    actor(etiqueta: "Usuarios"),
    flecha(etiqueta: [#n(1) DNS], largo: 1.4cm),
    svc("R53", "Route 53", sub: "alias → CloudFront", color: col.edge),
    grid.cell(rowspan: 3, zona("Servicios de apoyo", color: col.neutro)[
      #grid(columns: 2, column-gutter: 4pt, row-gutter: 2pt,
        svc("ACM", "ACM", sub: "certificados TLS", color: col.seguridad),
        svc("CW", "CloudWatch", sub: "métricas y alarmas", color: col.observabilidad),
        svc("SECR", "Secrets Manager", sub: "credenciales de BD", color: col.seguridad),
        svc("SSM", "Systems Manager", sub: "acceso sin SSH", color: col.neutro))
    ]),
    flecha-v(etiqueta: [#n(2) HTTPS], largo: 0.65cm), [], [],
    svc("CF", "CloudFront", sub: "+ AWS WAF", color: col.edge),
    flecha(etiqueta: [#n(3) /static/\*], largo: 1.4cm),
    svc("S3", "Bucket S3", sub: "estáticos · OAC", color: col.almacenamiento),
    flecha-v(etiqueta: [#n(4) contenido dinámico], largo: 0.65cm), [], [], [],
    grid.cell(colspan: 4, align: left, zona("VPC 10.0.0.0/16 · eu-west-1", color: col.redes)[
      #grid(columns: 5, align: center + horizon, column-gutter: 2pt,
        zona("Públicas · 2 AZ", color: col.almacenamiento)[#columna(espacio: 6pt,
          svc("ALB", "Application LB", sub: "nodos en 2 AZ", color: col.balanceo),
          svc("NAT", "NAT Gateway", sub: "uno por AZ", color: col.redes))],
        flecha(etiqueta: n(5), largo: 0.9cm),
        zona("Auto Scaling group", color: col.computo)[#columna(espacio: 4pt,
          zona("Privada · AZ a", color: col.neutro)[#svc("EC2", "Instancia", color: col.computo)],
          zona("Privada · AZ b", color: col.neutro)[#svc("EC2", "Instancia", color: col.computo)])],
        flecha(etiqueta: n(6), largo: 0.9cm),
        columna(espacio: 0pt,
          zona("Datos · AZ a", color: col.datos)[#fila(
            svc("RDS", "RDS primaria", color: col.datos),
            svc("CACHE", "ElastiCache", color: col.datos))],
          flecha-v(etiqueta: "réplica síncrona", doble: true, largo: 0.6cm),
          zona("Datos · AZ b", color: col.datos)[#fila(
            svc("RDS", "RDS standby", color: col.datos),
            svc("CACHE", "Réplica", color: col.datos))]),
      )
    ]),
  )
]

#pasos(
  [*Route 53* resuelve el dominio con un registro _alias_ hacia CloudFront (las consultas alias a recursos de AWS no se cobran).],
  [*CloudFront* termina HTTPS con un certificado de ACM, sirve desde la caché del borde y aplica *AWS WAF* contra inyecciones, bots y abusos.],
  [Las rutas estáticas van a un *bucket S3 privado* al que solo accede CloudFront mediante OAC.],
  [El resto se reenvía al *ALB*, único punto de entrada a la VPC, cuyos nodos viven en las subredes públicas de ambas AZ.],
  [El ALB reparte entre las instancias sanas del *Auto Scaling group*, que mantiene capacidad en dos AZ y escala según la carga; las instancias, sin estado, salen a Internet por el NAT de su AZ.],
  [La aplicación lee de *ElastiCache* (sesiones y consultas frecuentes) y escribe en *RDS Multi-AZ*: si cae la primaria, la réplica síncrona de la otra AZ toma el relevo en uno o dos minutos.],
)

#consejo(titulo: "Variantes")[Con *CloudFront VPC Origins* el ALB puede ser interno, sin exposición directa a Internet. Cambia EC2 por contenedores (siguiente arquitectura) o RDS por *Aurora*, con réplicas de lectura y conmutación más rápida.]

== Microservicios en contenedores con ECS Fargate

Varios servicios pequeños, cada uno con su equipo, su ciclo de despliegue y sus datos, ejecutados como contenedores sin gestionar servidores.

#diagrama(pie: [Microservicios en ECS con Fargate: el ALB enruta por ruta a cada servicio, Service Connect comunica los servicios entre sí y cada servicio es dueño de sus datos.])[
  #grid(columns: 3, align: center + horizon, column-gutter: 4pt,
    columna(espacio: 0pt,
      fila(actor(etiqueta: "Clientes"), flecha(etiqueta: [#n(1) HTTPS], largo: 1.5cm),
        svc("ALB", "Application LB", sub: "reglas por ruta", color: col.balanceo)),
      flecha-v(etiqueta: [#n(2) target group por servicio], largo: 0.6cm),
      zona("VPC · subredes privadas en 2 AZ", color: col.redes)[
        #zona("Clúster ECS · Fargate", color: col.contenedores)[
          #fila(espacio: 6pt,
            zona("Web", color: col.contenedores)[#svc("ECS", "Tareas web", sub: "2 a 10 tareas", color: col.contenedores)],
            zona("Pedidos", color: col.contenedores)[#svc("ECS", "Tareas pedidos", sub: "2 a 6 tareas", color: col.contenedores)],
            zona("Pagos", color: col.contenedores)[#svc("ECS", "Tareas pagos", sub: "2 a 4 tareas", color: col.contenedores)])
          #v(-2pt)
          #caja(ancho: 100%, [#n(3) *Service Connect*: los servicios se llaman por nombre (`http://pagos:8080`) con reintentos, balanceo y métricas], color: col.contenedores, relleno: col.contenedores.lighten(92%))
        ]
      ],
      flecha-v(etiqueta: [#n(4) cada servicio, sus datos], largo: 0.6cm),
      fila(espacio: 8pt,
        svc("AUR", "Aurora", sub: "pedidos", color: col.datos),
        svc("DDB", "DynamoDB", sub: "pagos", color: col.datos),
        svc("SQS", "Amazon SQS", sub: "eventos", color: col.integracion)),
    ),
    columna(espacio: 24pt,
      flecha-izq(etiqueta: [#n(5) imagen], largo: 1.2cm),
      flecha-izq(etiqueta: "secretos", largo: 1.2cm),
      flecha(etiqueta: "logs", largo: 1.2cm)),
    columna(espacio: 8pt,
      svc("ECR", "Amazon ECR", sub: "imágenes", color: col.contenedores),
      svc("SECR", "Secrets Manager", color: col.seguridad),
      svc("CW", "CloudWatch", sub: "Container Insights", color: col.observabilidad)),
  )
]

#pasos(
  [El *ALB* recibe HTTPS y enruta por ruta o cabecera (`/pedidos/*`, `/pagos/*`) al _target group_ de cada servicio.],
  [Cada microservicio es un *servicio de ECS sobre Fargate*: sin servidores que parchear, con tareas repartidas en dos AZ (cada una con su propia IP en la VPC) y Auto Scaling por CPU o por peticiones.],
  [Entre servicios, *ECS Service Connect* resuelve nombres cortos y añade reintentos, balanceo y métricas sin tocar el código.],
  [Cada servicio es *dueño de sus datos* (Aurora, DynamoDB) y publica eventos en *SQS* para desacoplar los procesos lentos.],
  [Al arrancar, cada tarea descarga su imagen de *ECR* y recibe sus secretos de *Secrets Manager* como variables de entorno; logs y métricas van a *CloudWatch*.],
)

#consejo(titulo: "Variantes")[*Amazon EKS* (con Auto Mode) es la alternativa si tu organización ya trabaja con Kubernetes o necesita su ecosistema (Helm, operadores). Para cargas grandes y estables, ECS puede usar *instancias EC2* como capacidad; despliega con los *blue/green o canary nativos de ECS*.]

== API serverless

Una API REST o HTTP sin un solo servidor: pagas por petición, escala de cero a miles de peticiones por segundo y AWS se ocupa de la disponibilidad.

#diagrama(pie: [API serverless: Cognito autentica, API Gateway valida el token y limita el tráfico, Lambda ejecuta la lógica y DynamoDB guarda los datos.])[
  #grid(columns: 7, align: center + horizon,
    svc("COG", "Cognito", sub: "User Pool", color: col.iam), [], [], [], [], [], [],
    flecha-v(etiqueta: [#n(1) login → JWT], doble: true, largo: 0.7cm), [], [], [], [], [], [],
    actor(etiqueta: "App web o móvil"),
    flecha(etiqueta: [#n(2) HTTPS + JWT], largo: 1.6cm),
    svc("APIGW", "API Gateway", sub: "autorizador JWT", color: col.serverless),
    flecha(etiqueta: n(3), largo: 1.2cm),
    svc("λ", "Lambda", sub: "una función por ruta", color: col.serverless),
    flecha(etiqueta: n(4), largo: 1.2cm),
    svc("DDB", "DynamoDB", sub: "on-demand", color: col.datos),
    [], [], flecha-v(etiqueta: "logs", largo: 0.6cm, punteada: true), [],
    flecha-v(etiqueta: "trazas", largo: 0.6cm, punteada: true), [],
    flecha-v(etiqueta: [#n(5) Streams], largo: 0.6cm),
    [], [], svc("CW", "CloudWatch", sub: "logs y métricas", color: col.observabilidad), [],
    svc("XRAY", "X-Ray", sub: "trazas distribuidas", color: col.observabilidad), [],
    svc("λ", "Lambda asíncrona", sub: "avisos, agregados", color: col.serverless),
  )
]

#pasos(
  [El usuario inicia sesión en un *User Pool de Cognito* (registro, MFA, acceso con Google o SAML) y recibe tokens JWT.],
  [La app llama a *API Gateway* con el token: un *autorizador JWT* valida firma y caducidad antes de ejecutar nada, y el _throttling_ protege el backend.],
  [Cada ruta invoca una función *Lambda* pequeña, con un rol IAM de mínimo privilegio, que escala sola.],
  [*DynamoDB* en modo on-demand guarda los datos con latencia de milisegundos, sin conexiones que agotar ni capacidad que dimensionar.],
  [*DynamoDB Streams* dispara funciones asíncronas (notificaciones, agregados, indexación) sin ralentizar la API.],
)

#consejo(titulo: "Variantes")[Una *API HTTP* es más sencilla y barata; una *API REST* añade WAF, caché y planes de uso. Para flujos de varios pasos, *Step Functions*; si necesitas SQL, *Aurora Serverless v2* o *Aurora DSQL*; contra el _cold start_, SnapStart o concurrencia aprovisionada.]

== Procesamiento asíncrono orientado a eventos

Cuando un trabajo tarda (procesar un fichero, generar un informe), no lo hagas dentro de la petición: encólalo y deja que los _workers_ lo procesen a su ritmo.

#diagrama(pie: [Procesamiento asíncrono: S3 emite eventos, EventBridge los filtra, SQS absorbe los picos (con DLQ para los fallidos) y SNS reparte el resultado a varios suscriptores.])[
  #grid(columns: 7, align: center + horizon,
    actor(etiqueta: "Aplicación"), [], [], [], [], [], [],
    flecha-v(etiqueta: [#n(1) PUT], largo: 0.6cm), [], [], [], [], [], [],
    svc("S3", "Bucket de entrada", color: col.almacenamiento),
    flecha(etiqueta: [#n(2) evento], largo: 1.5cm),
    svc("EB", "EventBridge", sub: "regla: *.csv", color: col.integracion),
    flecha(etiqueta: n(3), largo: 1.5cm),
    svc("SQS", "Cola de trabajos", color: col.integracion),
    flecha(etiqueta: [tras N intentos], largo: 1.5cm, color: rgb("#E03131")),
    svc("DLQ", "Dead-letter queue", sub: "+ alarma", color: rgb("#C92A2A")),
    [], [], [], [], flecha-v(etiqueta: [#n(4) sondeo], largo: 0.6cm), [], [],
    [], [],
    svc("SNS", "SNS", sub: "trabajo-completado", color: col.integracion),
    flecha-izq(etiqueta: [#n(6) publica], largo: 1.5cm),
    svc("λ", "Workers", sub: "Lambda o ECS", color: col.serverless),
    flecha(etiqueta: [#n(5) guarda], largo: 1.5cm),
    svc("DDB", "Resultados", sub: "S3 o DynamoDB", color: col.datos),
    [], [], line(angle: 90deg, length: 0.3cm, stroke: 1.2pt + gris-flecha), [], [], [], [],
    grid.cell(colspan: 5, abanico(5.79cm)),
    [], [],
    grid.cell(colspan: 5, fila(espacio: 10pt,
      svc("SQS", "Cola de email", color: col.integracion),
      svc("λ", "Indexación", color: col.serverless),
      svc("SQS", "Cola de analítica", color: col.integracion))),
    [], [],
  )
]

#pasos(
  [La aplicación sube un fichero al *bucket de entrada* (directamente o con una URL prefirmada).],
  [S3 emite el evento _Object Created_ a *EventBridge*, cuya regla filtra (solo ciertos prefijos o extensiones) y enruta.],
  [El destino es una *cola SQS*, que absorbe los picos y guarda cada trabajo hasta que se procesa.],
  [Los *workers* (Lambda, o tareas de ECS que escalan con la profundidad de la cola) procesan y borran el mensaje; si fallan, reaparece tras el _visibility timeout_ y, tras `maxReceiveCount` intentos, pasa a la *DLQ*, vigilada por una alarma.],
  [El resultado se guarda en *S3 o DynamoDB*.],
  [El worker publica un aviso en *SNS*, que hace _fan-out_: cada suscriptor (dos colas y una función) recibe su copia y avanza a su ritmo.],
)

#consejo(titulo: "Variantes")[Con un único consumidor, S3 → SQS directamente es más simple; para orquestar pasos, *Step Functions*; para orden por clave, *SQS FIFO*; para grandes volúmenes con relectura, *Kinesis*. Y haz los workers *idempotentes*: SQS estándar entrega *al menos una vez*.]

== Sitio estático o SPA

Una web corporativa, una documentación o el front-end de una aplicación de una sola página (React, Vue, Angular): ficheros estáticos servidos desde el borde, sin servidores.

#diagrama(pie: [Sitio estático: CloudFront sirve el contenido desde la caché del borde y lee de un bucket privado mediante OAC; las llamadas a la API van a otro origen.])[
  #grid(columns: 5, align: center + horizon,
    svc("R53", "Route 53", sub: "alias A y AAAA", color: col.edge), [],
    svc("ACM", "ACM", sub: [certificado en #box[us-east-1]], color: col.seguridad), [],
    svc("CI", "Pipeline CI/CD", sub: "GitHub Actions…", color: col.iac),
    flecha-v(etiqueta: [#n(1) DNS], doble: true, largo: 0.7cm), [],
    flecha-v(etiqueta: "TLS", largo: 0.7cm, punteada: true), [],
    flecha-v(etiqueta: [#n(5) sync], largo: 0.7cm),
    actor(etiqueta: "Usuarios"),
    flecha(etiqueta: [#n(2) HTTPS], largo: 1.8cm),
    svc("CF", "CloudFront", sub: "WAF · Functions", color: col.edge),
    flecha(etiqueta: [#n(3) OAC (SigV4)], largo: 2.2cm),
    svc("S3", "Bucket privado", sub: "Block Public Access", color: col.almacenamiento),
    [], [], flecha-v(etiqueta: [#n(4) /api/\*], largo: 0.7cm), [], [],
    [], [], svc("APIGW", "API Gateway o ALB", sub: "otro origen, sin caché", color: col.serverless), [], [],
  )
]

#pasos(
  [*Route 53* responde con registros alias (A y AAAA) que apuntan a la distribución.],
  [*CloudFront* termina HTTPS con un certificado de *ACM*, que para CloudFront debe estar en *#box[us-east-1]*; WAF filtra el tráfico y una *CloudFront Function* reescribe las rutas de la SPA (`/perfil` → `/index.html`) o añade cabeceras de seguridad.],
  [Si el objeto no está en caché, CloudFront lo pide al *bucket privado* firmando con *OAC*: Block Public Access sigue activo y la política del bucket solo admite a esa distribución.],
  [Las peticiones `/api/*` usan otro _behavior_ con otro origen (API Gateway o un ALB) y sin caché.],
  [El pipeline publica con `aws s3 sync` y crea una invalidación (o, mejor, usa nombres de fichero con _hash_ para no tener que invalidar).],
)

```json
{ "Effect": "Allow",
  "Principal": { "Service": "cloudfront.amazonaws.com" },
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::mi-web/*",
  "Condition": { "StringEquals": {
    "AWS:SourceArn": "arn:aws:cloudfront::111111111111:distribution/E1A2B3C4D5" } } }
```

#consejo(titulo: "Variantes")[Con OAC usa el endpoint REST del bucket, no el de _website_ de S3 (solo HTTP y exige bucket público). Si necesitas renderizado en servidor, *AWS Amplify Hosting*; con tráfico previsible, los planes de tarifa plana de CloudFront.]

== Pipeline de datos y analítica

Recoger eventos de aplicaciones, dispositivos o logs, guardarlos en un _data lake_ barato y consultarlos con SQL y paneles, sin gestionar clústeres.

#diagrama(pie: [Pipeline de analítica: ingesta en streaming, data lake en S3 por zonas, catálogo y transformación con Glue, consultas con Athena y paneles con Quick Sight.])[
  #grid(columns: 7, align: center + horizon,
    caja(ancho: 2.4cm, [*Productores*\ #text(6.3pt, fill: gris)[apps, IoT, logs, clics]], color: col.neutro),
    flecha(etiqueta: n(1), largo: 1.3cm),
    svc("KDS", "Kinesis Data Streams", sub: "orden y relectura", color: col.integracion),
    flecha(etiqueta: n(2), largo: 1.3cm),
    svc("FH", "Data Firehose", sub: "búfer · Parquet", color: col.integracion),
    [], [],
    [], [], [], [], flecha-v(etiqueta: [#n(3) escribe por lotes], largo: 0.6cm), [], [],
    grid.cell(colspan: 7, zona("Data lake en Amazon S3", color: col.almacenamiento)[
      #fila(espacio: 4pt,
        zona("Bronce", color: col.almacenamiento)[#svc("S3", "Raw", sub: "JSON tal cual", color: col.almacenamiento)],
        flecha(etiqueta: [#n(4) Glue ETL], largo: 1.6cm),
        zona("Plata", color: col.almacenamiento)[#svc("S3", "Procesado", sub: "Parquet particionado", color: col.almacenamiento)],
        flecha(etiqueta: "Glue ETL", largo: 1.6cm),
        zona("Oro", color: col.almacenamiento)[#svc("S3", "Curado", sub: "agregados de negocio", color: col.almacenamiento)])
    ]),
    flecha-v(etiqueta: [#n(5) crawler], largo: 0.6cm), [], flecha-v(etiqueta: [#n(6) SQL sobre S3], largo: 0.6cm), [], [], [], [],
    svc("GLUE", "Glue Data Catalog", sub: "+ Lake Formation", color: col.datos),
    flecha(etiqueta: "esquemas", largo: 1.3cm),
    svc("ATH", "Athena", sub: "SQL serverless", color: col.datos),
    flecha(etiqueta: n(7), largo: 1.3cm),
    svc("QS", "Quick Sight", sub: "paneles de BI", color: col.datos),
    [], [],
  )
]

#pasos(
  [Aplicaciones y dispositivos envían eventos a *Kinesis Data Streams*, que los ordena por clave de partición, admite varios consumidores y permite releer (24 h por defecto, hasta 365 días).],
  [*Amazon Data Firehose* consume el stream, acumula por tamaño o tiempo, puede transformar con Lambda y convierte a *Parquet*.],
  [Firehose escribe en la zona *raw* del data lake: almacenamiento barato, duradero y separado del cómputo.],
  [Trabajos de *AWS Glue* (Spark serverless) limpian, deduplican y escriben las zonas *procesada* y *curada* en formato columnar y particionado.],
  [Un _crawler_ registra esquemas y particiones en el *Glue Data Catalog*; *Lake Formation* da permisos por tabla, columna o fila.],
  [*Athena* consulta con SQL directamente sobre S3 (pagas por datos escaneados: Parquet y particiones lo abaratan mucho).],
  [*Amazon Quick Sight* (antes QuickSight) publica los paneles para negocio.],
)

#consejo(titulo: "Variantes")[Sin varios consumidores, las apps pueden escribir directamente en Firehose. Para tiempo real, *Managed Service for Apache Flink*; para un _data warehouse_ muy concurrente, *Redshift*; las tablas *Apache Iceberg* (también en *S3 Tables*) añaden transacciones al lake.]

== Estrategia multi-cuenta con Organizations

Una sola cuenta para todo mezcla permisos, costes y riesgos. La práctica recomendada es una *landing zone*: muchas cuentas pequeñas, agrupadas por función y gobernadas desde un único punto.

#diagrama(pie: [Landing zone típica: cuenta de administración sin cargas de trabajo, cuentas agrupadas en OU con SCP heredadas, seguridad y red centralizadas, y una cuenta por aplicación y entorno.])[
  #zona("AWS Organizations · landing zone con AWS Control Tower", color: col.iam, punteada: false, relleno: white)[
    #fila(espacio: 10pt,
      cuenta("Cuenta de administración", [Organizations, facturación consolidada, IAM Identity Center. *Sin cargas de trabajo*.], color: col.iam, ancho: 6cm),
      caja([#n(1) Control Tower · Account Factory · controles preventivos y detectivos], color: col.iam))
    #flecha-v(etiqueta: [#n(2) SCP y RCP heredadas por OU], largo: 0.6cm)
    #grid(columns: 4, column-gutter: 6pt, align: top,
      zona([#nm(3) OU Security], color: col.seguridad)[#columna(espacio: 5pt,
        cuenta("Log Archive", [CloudTrail y Config de toda la organización, inmutables], color: col.seguridad),
        cuenta("Audit", [GuardDuty y Security Hub como administrador delegado], color: col.seguridad))],
      zona([#nm(4) OU Infra], color: col.redes)[#columna(espacio: 5pt,
        cuenta("Network", [Transit Gateway, salida a Internet, DNS], color: col.redes),
        cuenta("Shared Services", [pipelines, artefactos, AMIs], color: col.redes))],
      zona([#nm(5) OU Workloads], color: col.contenedores)[#columna(espacio: 5pt,
        zona("Prod", color: col.iam)[#cuenta("app-prod", [producción], color: col.iam, ancho: 2.5cm)],
        zona("No prod", color: col.neutro)[#columna(espacio: 4pt,
          cuenta("app-staging", [preproducción], color: col.neutro, ancho: 2.5cm),
          cuenta("app-dev", [desarrollo], color: col.neutro, ancho: 2.5cm))])],
      zona([#nm(5) OU Sandbox], color: col.costes)[#columna(espacio: 5pt,
        cuenta("sandbox-ana", [experimentos con presupuesto], color: col.costes),
        cuenta("sandbox-luis", [limpieza automática], color: col.costes))],
    )
    #v(2pt)
    #caja(ancho: 100%, [#n(6) Las personas entran con *IAM Identity Center* y _permission sets_; los pipelines asumen roles de despliegue en cada cuenta], color: col.iam, relleno: col.iam.lighten(94%))
  ]
]

#pasos(
  [La *cuenta de administración* solo gestiona Organizations, la facturación e Identity Center; *AWS Control Tower* monta la landing zone y crea cuentas configuradas con *Account Factory*.],
  [Las cuentas se agrupan en *OU*. Las *SCP* (límites para las identidades) y las *RCP* (límites para los recursos) se heredan y fijan el máximo permitido: prohibir regiones, impedir desactivar CloudTrail…],
  [La OU *Security* reúne *Log Archive*, que recibe los logs de toda la organización, y *Audit*, administradora delegada de los servicios de seguridad.],
  [La OU *Infrastructure* («Infra») centraliza la red (Transit Gateway, salida a Internet, DNS) y los servicios compartidos.],
  [Cada aplicación tiene una cuenta por entorno en *Workloads*, y los equipos experimentan en *Sandbox* con presupuesto y limpieza automática.],
  [Nadie usa usuarios IAM: las personas entran con *IAM Identity Center* y _permission sets_; los pipelines, con roles.],
)

#consejo(titulo: "Variantes")[Las organizaciones grandes añaden OU como *Suspended* (cuentas en baja) o *Policy Staging*, o separan por unidad de negocio. Sin Control Tower, la misma estructura se monta con IaC (*Landing Zone Accelerator on AWS*, StackSets).]

== Recuperación ante desastres multirregión

Multi-AZ te protege de la caída de un centro de datos; para sobrevivir a la de una región entera necesitas una segunda región. Dos cifras guían el diseño: el *RPO* (_Recovery Point Objective_, cuántos datos puedes perder) y el *RTO* (_Recovery Time Objective_, cuánto tiempo puedes estar sin servicio).

#let estrategia(t, rpo, sec, coste, c) = block(width: 100%, height: 2.75cm, fill: c, radius: 6pt, inset: 7pt, align(left, {
  set par(justify: false, leading: 0.4em)
  grid(columns: (1fr, auto), column-gutter: 4pt,
    text(8.4pt, weight: "bold", fill: white, t),
    text(8.4pt, weight: "bold", fill: white.transparentize(15%), coste))
  v(1pt)
  text(6.8pt, weight: "bold", fill: white, [RPO/RTO: #rpo])
  v(2pt)
  text(6.7pt, fill: white.transparentize(5%), sec)
}))

#diagrama(pie: [Arriba, las cuatro estrategias de recuperación: cuanto menor es el RPO/RTO, mayor es el coste. Abajo, un _warm standby_: Route 53 envía el tráfico a la primaria, los datos se replican de forma continua y, ante un desastre, la secundaria se promueve y escala.])[
  #grid(columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 6pt,
    estrategia("Backup y restauración", "horas", [En la región secundaria solo hay copias (AWS Backup, snapshots, S3); todo se recrea con IaC al activarla.], "$", col.arquitectura.lighten(35%)),
    estrategia("Pilot light", "decenas de minutos", [Datos replicados y la infraestructura básica creada, pero sin servidores de aplicación en marcha.], "$$", col.arquitectura.lighten(15%)),
    estrategia("Warm standby", "minutos", [Una copia completa funcionando a escala reducida, lista para crecer.], "$$$", col.arquitectura),
    estrategia("Activo-activo", "casi cero", [Ambas regiones sirven tráfico a la vez; datos replicados en ambos sentidos.], "$$$$", col.arquitectura.darken(30%)),
  )
  #v(4pt)
  #fila(text(7pt, fill: gris)[menos coste], flecha(largo: 8cm, doble: true), text(7pt, fill: gris)[menor RPO y RTO])
  #v(10pt)
  #line(length: 100%, stroke: 0.6pt + gris-claro)
  #v(6pt)
  #let region(titulo, color, asg, aurora, relleno: white) = zona(titulo, color: color, punteada: false, relleno: relleno)[
    #fila(
      svc("ALB", "ALB", color: col.balanceo), flecha(largo: 0.9cm),
      svc("EC2", "Auto Scaling", sub: asg, color: col.computo), flecha(largo: 0.9cm),
      svc("AUR", "Aurora", sub: aurora, color: col.datos))
  ]
  #grid(columns: 3, align: center + horizon, row-gutter: 0pt,
    grid.cell(rowspan: 3, columna(espacio: 2pt,
      actor(etiqueta: "Usuarios"),
      flecha-v(largo: 0.6cm),
      svc("R53", "Route 53", sub: "failover + health checks", color: col.edge))),
    flecha(etiqueta: [#n(1) activo], largo: 1.6cm),
    region("Región primaria · eu-west-1", col.fundamentos, "capacidad completa", "clúster de escritura"),
    [],
    grid(columns: (0.32cm, 2.54cm, 0.9cm, 2.54cm, 0.9cm, 2.54cm, 0.32cm), align: center + horizon,
      [], [], [], flecha-v(etiqueta: [#n(3) misma IaC], largo: 0.75cm, punteada: true), [],
      flecha-v(etiqueta: [#n(2) global database], doble: true, largo: 0.75cm), []),
    flecha(etiqueta: [#n(5) failover], largo: 1.6cm, punteada: true),
    region("Región secundaria · eu-central-1", col.neutro, [mínima · #n(4) escala], [secundaria · #n(4) se promueve], relleno: fondo-suave),
  )
]

#pasos(
  [En condiciones normales, *Route 53* envía el tráfico a la región primaria mediante un registro de _failover_ con health check.],
  [Los datos se replican de forma continua: *Aurora Global Database* (normalmente con menos de un segundo de retraso), *DynamoDB global tables*, *S3 Cross-Region Replication* y copias de *AWS Backup* entre regiones.],
  [La región secundaria tiene la misma infraestructura, desplegada con la *misma IaC*, pero a escala mínima.],
  [Ante un desastre, el clúster secundario de Aurora se *promueve* a escritura y el Auto Scaling group crece hasta la capacidad de producción.],
  [Route 53 conmuta el DNS, automáticamente por health check o de forma controlada con *Application Recovery Controller*, y el tráfico pasa a la secundaria.],
)

Un plan de DR que no se ensaya no existe: programa simulacros y mide el RTO real. Y recuerda que la replicación también copia los errores; conserva además copias inmutables (AWS Backup Vault Lock).

== Checklist de revisión Well-Architected

Antes de dar por buena una arquitectura, repásala con los seis pilares del *AWS Well-Architected Framework*; la *Well-Architected Tool* de la consola (gratuita) guía la revisión y ofrece _lenses_ específicas.

#tabla(("Pilar", "Comprueba que…"), columnas: (1.15fr, 4.6fr), tamano: 8pt,
  [*Excelencia operativa*], [#si Todo se despliega con IaC y pipelines #h(4pt) #si Despliegues pequeños, frecuentes y reversibles #h(4pt) #si Alarmas accionables con _runbooks_ #h(4pt) #si Revisiones post-incidente sin culpables],
  [*Seguridad*], [#si Multi-cuenta y acceso con Identity Center, sin claves de larga duración #h(4pt) #si Mínimo privilegio y SCP #h(4pt) #si Cifrado en reposo (KMS) y en tránsito (TLS) #h(4pt) #si CloudTrail, GuardDuty y Security Hub activos; WAF en lo público],
  [*Fiabilidad*], [#si Multi-AZ en todas las capas #h(4pt) #si Auto Scaling y health checks #h(4pt) #si Backups probados restaurándolos #h(4pt) #si RPO y RTO definidos y DR ensayado #h(4pt) #si Cuotas vigiladas],
  [*Eficiencia del rendimiento*], [#si Servicios gestionados o serverless donde encajen #h(4pt) #si Cachés (CloudFront, ElastiCache, DAX) #h(4pt) #si Pruebas de carga #h(4pt) #si Tipos de instancia y Graviton elegidos con datos],
  [*Optimización de costes*], [#si Etiquetas, presupuestos y alertas #h(4pt) #si Rightsizing y apagado de no-prod #h(4pt) #si Savings Plans para la base #h(4pt) #si Lifecycle en S3, retención de logs y endpoints en lugar de NAT],
  [*Sostenibilidad*], [#si Capacidad ajustada a la demanda real #h(4pt) #si Graviton y serverless #h(4pt) #si Borrado de datos y recursos sin uso #h(4pt) #si Regiones y horarios con menor impacto],
)

#resumen[
- *Web de tres capas*: cada capa en dos AZ, con CloudFront y WAF en el borde, ALB, Auto Scaling y RDS Multi-AZ.
- *Microservicios*: ECS Fargate tras un ALB, Service Connect entre servicios y datos propios; EKS si ya usas Kubernetes.
- *API serverless*: Cognito, API Gateway, Lambda y DynamoDB, con pago por uso y escalado automático.
- *Asíncrono*: EventBridge, SQS con DLQ y SNS para el fan-out, con workers idempotentes.
- *Sitio estático*: CloudFront con un bucket privado vía OAC y certificado de ACM en #box[us-east-1].
- *Datos*: Kinesis y Firehose hacia un data lake en S3, catalogado con Glue y consultado con Athena y Quick Sight.
- *Multi-cuenta*: landing zone con OU, SCP, Log Archive, Audit e Identity Center.
- *DR*: de backup y restauración a activo-activo según RPO, RTO y presupuesto; y siempre ensayada.
]

#repaso(
  ([¿Qué hace que la web de tres capas sobreviva a la caída de una AZ?], [Cada capa está en dos AZ: el ALB tiene nodos en ambas, el Auto Scaling group repone instancias y RDS Multi-AZ conmuta a su réplica síncrona.]),
  ([¿Para qué sirve ECS Service Connect?], [Para que los servicios se llamen por nombre dentro del clúster, con descubrimiento, reintentos, balanceo y métricas, sin cambiar el código.]),
  ([En la arquitectura asíncrona, ¿qué pasa con un mensaje que falla una y otra vez?], [Reaparece en la cola al vencer el visibility timeout y, al superar `maxReceiveCount`, SQS lo mueve a la DLQ, donde una alarma avisa para revisarlo.]),
  ([¿Por qué el bucket del sitio estático puede ser privado?], [Porque CloudFront accede con Origin Access Control (OAC), firmando las peticiones, y la política del bucket solo permite a esa distribución; Block Public Access sigue activo.]),
  ([¿Qué diferencia hay entre pilot light y warm standby?], [En pilot light la secundaria tiene los datos y la infraestructura básica, pero ningún servidor de aplicación en marcha; en warm standby hay una copia completa funcionando a escala reducida (menor RTO).]),
)
