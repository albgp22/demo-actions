#import "../theme.typ": *

// ---------------------------------------------------------------------
//  Utilidades locales del capítulo
// ---------------------------------------------------------------------
#let verde = rgb("#2F9E44")
#let naranja = rgb("#E8590C")
#let rojo = rgb("#E03131")

#capitulo("Costes y optimización", color: col.costes,
  subtitulo: [Entiende cómo se factura AWS, dónde se va el dinero y qué palancas tienes para pagar solo por lo que aporta valor.],
  objetivos: (
    [El modelo de pago por uso],
    [Qué tráfico de datos se paga y cuál no],
    [Cost Explorer, Budgets y compañía],
    [Etiquetas de asignación de costes],
    [A qué servicios llega cada descuento por compromiso],
    [Optimizar y evitar las trampas típicas],
  ),
  servicios: ("AWS Cost Explorer", "AWS Budgets", "AWS Data Exports", "AWS Cost Anomaly Detection", "AWS Compute Optimizer", "Savings Plans"))

== El modelo de pago por uso

En AWS no compras servidores: pagas por segundo, por hora, por GB o por petición, sin inversión inicial, y dejas de pagar cuando apagas el recurso. Ojo con el matiz: pagas por lo que *aprovisionas*, no por lo que usas. Una instancia al 3 % de CPU o un volumen sin adjuntar se facturan enteros. El precio por unidad baja con el volumen (tramos) y con el *compromiso* de uso a uno o tres años, y varía por región. La capa gratuita, que cambió en julio de 2025, se resume en el capítulo de Fundamentos.

#datos(
  ("0", [coste de los datos que *entran* desde Internet]),
  ("100 GB", [de salida a Internet gratis al mes (agregado)]),
  ("72 %", [descuento máximo con compromiso a 3 años]),
  ("90 %", [descuento máximo con instancias Spot]),
)

== Los grandes conductores de coste

#tarjetas(columnas: 3,
  tarjeta("Cómputo", subtitulo: "suele ser la mayor partida")[EC2 y RDS por tiempo de instancia; Lambda por petición y GB-segundo; Fargate por vCPU y GB.],
  tarjeta("Almacenamiento", subtitulo: "crece en silencio")[GB-mes de S3 (y peticiones), EBS aprovisionado (y sus IOPS), snapshots, backups y logs.],
  tarjeta("Transferencia de datos", subtitulo: "la gran olvidada")[Salida a Internet, tráfico entre AZ y regiones, y procesamiento del NAT Gateway.],
)

La transferencia es la partida que más sorprende, porque no aparece en ningún «recurso» de la consola. La regla: *entrar es gratis y salir cuesta*; *cruzar zonas de disponibilidad cuesta en los dos sentidos*; *entre regiones paga la de origen*; y lo que atraviesa un *NAT Gateway* paga además su procesamiento por GB, vaya a Internet o a S3. Dentro de una AZ, con IP privadas, es gratis, y servir contenido por CloudFront suele salir más barato que hacerlo desde EC2 o S3.

#diagrama(pie: [Qué tráfico se paga: en verde, gratis; en naranja, pago por GB o por hora; en rojo, salida a Internet o entre regiones. Los importes varían por región y volumen; lo importante es el patrón.])[
  #grid(columns: (3.6cm, 2.9cm, 3.2cm, 4.2cm), align: center + horizon, row-gutter: 0pt,
    internet(etiqueta: "Internet"),
    svc("CF", "CloudFront", sub: "tarifa propia", color: col.edge),
    fila(flecha(etiqueta: "$/GB", color: naranja, largo: 1.2cm), actor(etiqueta: "Usuarios")),
    zona("Región B", color: col.fundamentos, punteada: false, relleno: white)[#caja([EC2 · réplica], color: col.computo)],
    // Fila de flechas
    fila(espacio: 2pt, flecha-v(largo: 0.7cm, color: verde), flecha-v(largo: 0.7cm, arriba: true, color: rojo),
      h(2pt), align(left, text(6.4pt, weight: "medium")[#text(fill: verde)[entrada: gratis]\ #text(fill: rojo)[salida: \$/GB]])),
    flecha-v(largo: 0.7cm, arriba: true, color: verde, etiqueta: "origen → CloudFront: gratis"),
    [],
    flecha-v(largo: 0.7cm, doble: true, color: rojo, etiqueta: "entre regiones: $/GB"),
    // Región principal
    grid.cell(colspan: 4, zona("Región A · eu-west-1", color: col.fundamentos, punteada: false, relleno: white)[
      #columna(espacio: 0pt, zona("VPC", color: col.redes)[
        #fila(espacio: 4pt,
          zona("AZ a", color: col.neutro)[#fila(
            svc("EC2", "App", sub: "subred privada", color: col.computo),
            flecha(etiqueta: "$/GB procesado", color: naranja, largo: 1.5cm),
            svc("NAT", "NAT Gateway", sub: "$/hora por AZ", color: col.redes))],
          flecha(etiqueta: "$/GB por sentido", color: naranja, doble: true, largo: 2.2cm),
          zona("AZ b", color: col.neutro)[#svc("EC2", "App", color: col.computo)],
        )
      ])
      #columna(espacio: 0pt,
        flecha-v(largo: 0.6cm, color: verde, etiqueta: "endpoint de gateway: gratis"),
        fila(espacio: 10pt, svc("S3", "Amazon S3", color: col.almacenamiento), svc("DDB", "DynamoDB", color: col.datos)))
    ]),
  )
]

== Herramientas de visibilidad y control

#tabla(("Herramienta", "Para qué sirve"), columnas: (1.3fr, 4fr), tamano: 8pt,
  [*Billing and Cost Management*], [Facturas, pagos y créditos. Con Organizations, la *facturación consolidada* suma el uso (y los descuentos por volumen) de todas las cuentas.],
  [*Cost Explorer*], [Explorar el gasto por servicio, cuenta, región o etiqueta, con granularidad diaria o mensual, previsiones y recomendaciones de Savings Plans y reservas.],
  [*AWS Budgets*], [Presupuestos de coste, uso o cobertura con alertas (correo, SNS) cuando el gasto real o *previsto* supera un umbral; las *budget actions* pueden aplicar políticas o detener instancias.],
  [*Data Exports (CUR 2.0)*], [El detalle línea a línea de la factura (el antiguo Cost and Usage Report, también en formato FOCUS) entregado en S3 para consultarlo con Athena o una herramienta de BI.],
  [*Cost Anomaly Detection*], [Aprendizaje automático que detecta gastos inusuales (un servicio que se dispara) y avisa, sin umbrales fijos.],
  [*Pricing Calculator*], [Estimar el coste de una arquitectura *antes* de construirla.],
  [*Compute Optimizer*], [Recomendaciones de tamaño para EC2, Auto Scaling, EBS, Lambda, ECS en Fargate y RDS, basadas en métricas reales.],
  [*Trusted Advisor* y *Cost Optimization Hub*], [Comprobaciones de recursos ociosos o infrautilizados (las de coste requieren soporte Business o superior) y un panel que reúne todas las recomendaciones de ahorro.],
)

Configúralo el primer día en cada cuenta nueva: un presupuesto mensual con alertas al 80 % del gasto real y al 100 % del previsto, y Cost Anomaly Detection activado.

=== Etiquetas de asignación de costes

Las etiquetas (_tags_) responden a «¿cuánto cuesta este proyecto?». Define un esquema común —`Proyecto`, `Entorno`, `Equipo`, `CentroDeCoste`—, aplícalo desde la IaC (con `default_tags`, como en el capítulo de Infraestructura como código) y hazlo obligatorio con *tag policies* de Organizations o SCP que denieguen crear recursos sin etiquetas. Las *Cost Categories* agrupan cuentas, servicios y etiquetas en categorías de negocio.

#cuidado[Tus etiquetas no aparecen en Cost Explorer ni en Data Exports hasta que las *activas* como etiquetas de asignación de costes en la consola de facturación (en la cuenta de administración). Y no todo el gasto es etiquetable: el plan de soporte, por ejemplo, no lleva etiquetas.]

== Estrategias de optimización

#tarjetas(columnas: 3,
  tarjeta("Rightsizing", subtitulo: "ajustar el tamaño")[Compute Optimizer y CloudWatch delatan lo sobredimensionado. Baja de talla *antes* de comprometerte.],
  tarjeta("Apagar fuera de horario", subtitulo: "dev y test")[Sin noches ni fines de semana eliminas casi dos tercios de las horas (EventBridge Scheduler, Instance Scheduler).],
  tarjeta("Graviton", subtitulo: "procesadores Arm de AWS")[Instancias más baratas por hora que sus equivalentes x86 y con mejor relación precio-rendimiento; también en Lambda, Fargate y RDS.],
  tarjeta("Clases de S3 y lifecycle", subtitulo: "datos fríos, precio frío")[Reglas que mueven los datos a Standard-IA o Glacier (o Intelligent-Tiering) y expiran versiones antiguas y subidas multipart incompletas.],
  tarjeta("gp3 en lugar de gp2", subtitulo: "EBS")[Más barato por GB, con 3000 IOPS y 125 MiB/s de base sea cual sea el tamaño; se cambia en caliente.],
  tarjeta("Serverless si es intermitente", subtitulo: "pagar por actividad")[Lambda, DynamoDB on-demand o Aurora Serverless v2 (que puede bajar a 0 ACU) no cobran cómputo en reposo.],
)

Súmales las palancas de la transferencia (endpoints de VPC en lugar de NAT, caché en CloudFront) y la retención de logs, que verás entre las trampas.

== Modelos de compra

Con los recursos ya ajustados, toca comprometer el uso estable. Los modelos y la estrategia —*compromisos* para la base que nunca baja, *On-Demand* para los picos y *Spot* para lo interrumpible— se explican en el capítulo «EC2: cómputo en la nube»; aquí importa a qué servicios llega cada descuento (los Savings Plans, un compromiso de gasto en \$/hora, se aplican solos):

#tabla(("Modelo", "Descuento", "Plazo", "A qué se aplica"), columnas: (1.75fr, 0.85fr, 0.8fr, 3.3fr), tamano: 8pt,
  [*Compute Savings Plans*], [hasta 66 %], [1 o 3 años], [EC2 (cualquier familia, región o SO), *Fargate* y *Lambda*],
  [*EC2 Instance Savings Plans*], [hasta 72 %], [1 o 3 años], [Una familia de EC2 en una región (cualquier tamaño, SO o AZ)],
  [*Database Savings Plans*], [hasta 35 %], [1 año], [Aurora, RDS, DynamoDB, ElastiCache… (desde diciembre de 2025)],
  [*Reserved Instances*], [hasta 72 %], [1 o 3 años], [EC2 y también RDS, ElastiCache, OpenSearch y Redshift],
  [*Spot*], [hasta 90 %], [—], [Capacidad sobrante de EC2 y Fargate; 2 minutos de aviso],
)

== Trampas comunes

#tabla(("Trampa", "Por qué cuesta", "Cómo evitarla"), columnas: (1.2fr, 2.5fr, 2.3fr), tamano: 8pt,
  [*NAT Gateway*], [Hora por cada AZ más cada GB procesado, incluido el tráfico a S3, DynamoDB o ECR.], [Endpoints de gateway (y de interfaz si compensa); VPC Flow Logs para ver quién lo usa.],
  [*IPv4 públicas y Elastic IP*], [Desde febrero de 2024 cada IPv4 pública se cobra por hora (instancias, balanceadores, NAT), también las Elastic IP sin asociar.], [Subredes privadas tras un balanceador, IPv6 donde se pueda, liberar las Elastic IP que sobren; inventario con VPC IPAM.],
  [*Logs sin retención*], [Los GB almacenados se acumulan mes a mes, para siempre.], [Retención por grupo de logs; archivo en S3.],
  [*Snapshots y AMI huérfanos*], [Se pagan por GB-mes aunque el volumen original ya no exista.], [Data Lifecycle Manager o AWS Backup con retención.],
  [*EBS sin adjuntar*], [Un volumen en estado _available_ cuesta lo mismo que uno en uso.], [Revisión periódica: snapshot si hace falta y borrar.],
  [*Tráfico entre AZ*], [Microservicios «habladores» o réplicas en otra AZ pagan cada GB en ambos sentidos.], [Afinidad por AZ, cachés locales y compresión.],
  [*Recursos olvidados*], [Entornos de prueba, balanceadores o clústeres en otra región siguen facturando.], [Etiquetas obligatorias, presupuestos y limpieza automática.],
)

== FinOps: el coste como responsabilidad compartida

*FinOps* es la práctica —y la cultura— de gestionar el gasto en la nube entre ingeniería, finanzas y negocio. La FinOps Foundation la organiza en tres fases que se repiten en ciclo:

#diagrama(pie: [El ciclo FinOps: cada vuelta mejora la visibilidad, el ahorro y los procesos.])[
  #fila(
    caja(ancho: 4cm, [*Informar*\ #text(6.6pt, fill: gris)[visibilidad y asignación: etiquetas, _showback_ y _chargeback_]], color: col.costes),
    flecha(largo: 1cm),
    caja(ancho: 4cm, [*Optimizar*\ #text(6.6pt, fill: gris)[rightsizing, compromisos, arquitectura, apagados]], color: col.costes),
    flecha(largo: 1cm),
    caja(ancho: 4cm, [*Operar*\ #text(6.6pt, fill: gris)[presupuestos, políticas, automatización y mejora continua]], color: col.costes),
  )
]

La métrica más útil es el *coste unitario* (por cliente, por pedido, por millón de peticiones): si la factura crece pero el coste unitario baja, el negocio escala bien.

#resumen[
- Pagas por lo que *aprovisionas*: un recurso ocioso cuesta lo mismo que uno ocupado.
- Los grandes conductores son cómputo, almacenamiento y *transferencia*: entrar es gratis, salir y cruzar AZ o regiones cuesta, y el NAT Gateway cobra por GB procesado.
- Cost Explorer analiza, Budgets avisa (y actúa), Data Exports da el detalle, Anomaly Detection vigila y Compute Optimizer recomienda tamaños.
- Las etiquetas de asignación de costes solo cuentan una vez *activadas*; hazlas obligatorias desde la IaC y las políticas de Organizations.
- Cubre la base con Savings Plans o RI, los picos con On-Demand y lo interrumpible con Spot (capítulo de EC2); Compute SP llega también a Fargate y Lambda.
- Palancas rápidas: rightsizing, apagar dev de noche, Graviton, gp3, lifecycle de S3, retención de logs y endpoints de VPC.
]

#repaso(
  ([¿Qué tráfico de datos no se cobra?], [La entrada desde Internet, el tráfico dentro de la misma AZ con IP privadas, el acceso a S3 o DynamoDB por un endpoint de gateway en la misma región y la transferencia de un origen de AWS a CloudFront.]),
  ([Has etiquetado todo, pero las etiquetas no salen en Cost Explorer. ¿Por qué?], [Hay que activarlas como etiquetas de asignación de costes en la consola de facturación; hasta entonces no aparecen en los informes.]),
  ([Una instancia de desarrollo funciona 24/7 al 3 % de CPU. ¿Por qué cuesta lo mismo que si fuera al 90 % y qué haces?], [Porque se paga lo aprovisionado, no lo usado. Baja de talla con las recomendaciones de Compute Optimizer y apágala fuera de horario (EventBridge Scheduler o Instance Scheduler); si la carga es intermitente, valora un servicio serverless.]),
  ([La partida de NAT Gateway se ha disparado. ¿Qué revisas?], [Qué tráfico pasa por él (VPC Flow Logs); llevar S3 y DynamoDB a endpoints de gateway y valorar endpoints de interfaz para servicios como ECR o CloudWatch.]),
  ([¿En qué se diferencian AWS Budgets y Cost Anomaly Detection?], [Budgets avisa (o actúa) cuando el gasto real o previsto supera umbrales que tú defines; Anomaly Detection usa aprendizaje automático para detectar gastos inusuales sin umbrales fijos.]),
)
