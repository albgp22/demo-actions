#import "../theme.typ": *

// ---------------------------------------------------------------------
//  Utilidades locales del capítulo
// ---------------------------------------------------------------------
#let verde = rgb("#2F9E44")
#let naranja = rgb("#E8590C")
#let rojo = rgb("#E03131")

// Gráfico de demanda de 24 h con la parte cubierta por compromiso, On-Demand y Spot
#let grafico-compra() = {
  let demanda = (3, 3, 3, 3, 3, 3, 4, 6, 8, 9, 9, 8, 8, 9, 9, 8, 7, 6, 5, 4, 4, 3, 3, 3)
  let lotes = (2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2)
  let base = 3
  let u = 0.27cm
  let w = 0.42cm
  let g = 0.14cm
  let ancho = 24 * (w + g)
  columna(espacio: 3pt,
    box(width: ancho, height: 9.4 * u, {
      for (i, v) in demanda.enumerate() {
        let x = i * (w + g)
        let b = calc.min(v, base)
        place(bottom + left, dx: x, rect(width: w, height: b * u, fill: col.costes))
        if v > base {
          place(bottom + left, dx: x, dy: -b * u, rect(width: w, height: (v - base) * u, fill: col.costes.lighten(60%)))
        }
        let s = lotes.at(i)
        if s > 0 {
          place(bottom + left, dx: x, dy: -v * u, rect(width: w, height: s * u, fill: verde.lighten(25%)))
        }
      }
      place(bottom + left, dy: -base * u, line(length: ancho, stroke: (paint: tinta, thickness: 0.8pt, dash: "dashed")))
      place(top + right, dx: 0pt, dy: 0pt, text(6.5pt, fill: gris, [demanda (vCPU)]))
    }),
    box(width: ancho, height: 8pt, {
      for (k, t) in ("0 h", "6 h", "12 h", "18 h", "24 h").enumerate() {
        place(left + top, dx: k * 6 * (w + g) - 5pt, text(6.5pt, fill: gris, t))
      }
    }),
  )
}

#let chip(c, t) = box(baseline: 1pt, {
  box(width: 9pt, height: 7pt, radius: 1.5pt, fill: c)
  h(3pt)
  text(7.2pt, t)
})

#capitulo("Costes y optimización", color: col.costes,
  subtitulo: [Entiende cómo se factura AWS, dónde se va el dinero y qué palancas tienes para pagar solo por lo que aporta valor.],
  objetivos: (
    [El modelo de pago por uso],
    [Qué tráfico de datos se paga y cuál no],
    [Cost Explorer, Budgets y compañía],
    [Etiquetas de asignación de costes],
    [Savings Plans, Reserved Instances y Spot],
    [Optimizar y evitar las trampas típicas],
  ),
  servicios: ("Cost Explorer", "AWS Budgets", "Data Exports", "Cost Anomaly Detection", "Compute Optimizer", "Savings Plans"))

== El modelo de pago por uso

En AWS no compras servidores: pagas por segundo, por hora, por GB o por petición, sin inversión inicial, y dejas de pagar cuando apagas el recurso. Ojo con el matiz: pagas por lo que *aprovisionas*, no por lo que usas. Una instancia al 3 % de CPU o un volumen sin adjuntar se facturan entero. El precio por unidad baja con el volumen (tramos) y con el *compromiso* de uso a uno o tres años, y varía por región.

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

La transferencia es la partida que más sorprende, porque no aparece en ningún «recurso» de la consola. La regla: *entrar es gratis y salir cuesta*; *cruzar zonas de disponibilidad cuesta en los dos sentidos*; *entre regiones paga la de origen*; y lo que atraviesa un *NAT Gateway* paga además su procesamiento por GB, vaya a Internet o a S3. Dentro de una AZ, con IPs privadas, es gratis, y servir contenido por CloudFront suele salir más barato que hacerlo desde EC2 o S3.

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

#consejo[El primer día en una cuenta nueva: un presupuesto mensual con alertas al 80 % del gasto real y al 100 % del previsto, y Cost Anomaly Detection activado. Cinco minutos que evitan sustos.]

=== Etiquetas de asignación de costes

Las etiquetas (_tags_) responden a «¿cuánto cuesta este proyecto?». Define un esquema común —`Proyecto`, `Entorno`, `Equipo`, `CentroDeCoste`—, aplícalo desde la IaC (con `default_tags`, como en el capítulo de IaC) y hazlo obligatorio con *tag policies* de Organizations o SCP que denieguen crear recursos sin etiquetas. Las *Cost Categories* agrupan cuentas, servicios y etiquetas en categorías de negocio.

#cuidado[Tus etiquetas no aparecen en Cost Explorer ni en Data Exports hasta que las *activas* como etiquetas de asignación de costes en la consola de facturación (en la cuenta de administración). Y no todo el gasto es etiquetable: el plan de soporte, por ejemplo, no lleva etiquetas.]

== Modelos de compra

Pagar todo bajo demanda es lo más flexible y lo más caro. AWS ofrece descuentos a cambio de compromiso o de aceptar interrupciones:

#tabla(("Modelo", "Descuento", "Compromiso", "Flexibilidad e ideal para"), columnas: (1.35fr, 0.8fr, 1.2fr, 3.1fr), tamano: 8pt,
  [*On-Demand*], [—], [Ninguno], [Máxima flexibilidad: cargas nuevas, impredecibles o cortas.],
  [*Compute Savings Plans*], [hasta 66 %], [1 o 3 años, en \$/hora], [Cualquier familia, tamaño, región o SO de EC2, además de Fargate y Lambda. Se aplican solos.],
  [*EC2 Instance Savings Plans*], [hasta 72 %], [1 o 3 años, en \$/hora], [Una familia de instancias en una región (cualquier tamaño, SO o AZ).],
  [*Database Savings Plans*], [hasta 35 %], [1 año, en \$/hora], [Bases de datos gestionadas (Aurora, RDS, DynamoDB, ElastiCache…); lanzados en diciembre de 2025.],
  [*Reserved Instances*], [hasta 72 %], [1 o 3 años], [Standard o Convertible; las zonales reservan además capacidad. También para RDS, ElastiCache, OpenSearch o Redshift.],
  [*Spot*], [hasta 90 %], [Ninguno], [Capacidad sobrante que AWS recupera con *2 minutos* de aviso: lotes, CI, análisis, contenedores sin estado.],
)

La estrategia habitual es cubrir con *compromisos* la base de uso que nunca baja, dejar los picos en *On-Demand* y llevar a *Spot* lo que tolera interrupciones:

#diagrama(pie: [Un día de uso de cómputo: la línea discontinua marca el compromiso (Savings Plan); los picos van bajo demanda y los lotes nocturnos, a Spot.])[
  #grafico-compra()
  #v(4pt)
  #fila(espacio: 14pt, chip(col.costes, "Savings Plan o RI (base estable)"), chip(col.costes.lighten(60%), "On-Demand (picos)"), chip(verde.lighten(25%), "Spot (lotes interrumpibles)"))
]

#examen[Savings Plans: compromiso en \$/hora que se aplica solo a lo elegible; Compute SP es el más flexible. Para garantizar capacidad sin descuento propio existen las *On-Demand Capacity Reservations*, combinables con Savings Plans.]

== Estrategias de optimización

#tarjetas(columnas: 3,
  tarjeta("Rightsizing", subtitulo: "ajustar el tamaño")[Compute Optimizer y CloudWatch delatan lo sobredimensionado. Baja de talla *antes* de comprometerte.],
  tarjeta("Apagar fuera de horario", subtitulo: "dev y test")[Sin noches ni fines de semana eliminas casi dos tercios de las horas (EventBridge Scheduler, Instance Scheduler).],
  tarjeta("Graviton", subtitulo: "procesadores Arm de AWS")[Más baratas por hora que sus equivalentes x86 y con mejor relación precio-rendimiento; también en Lambda, Fargate y RDS.],
  tarjeta("Clases de S3 y lifecycle", subtitulo: "datos fríos, precio frío")[Reglas que mueven a Standard-IA o Glacier, Intelligent-Tiering, y expirar versiones antiguas y multipart incompletos.],
  tarjeta("gp3 en lugar de gp2", subtitulo: "EBS")[Más barato por GB, con 3 000 IOPS y 125 MB/s de base sea cual sea el tamaño; se cambia en caliente.],
  tarjeta("Retención de logs", subtitulo: "CloudWatch Logs")[Por defecto los logs no caducan nunca: fija la retención y archiva en S3 lo que debas conservar.],
  tarjeta("Endpoints de VPC", subtitulo: "esquivar el NAT")[S3 y DynamoDB por endpoint de gateway: gratis. Por NAT: cada GB paga procesamiento.],
  tarjeta("Serverless si es intermitente", subtitulo: "pagar por actividad")[Lambda, DynamoDB on-demand o Aurora Serverless v2 (que puede bajar a 0 ACU) no cobran cómputo en reposo.],
  tarjeta("Caché con CloudFront", subtitulo: "menos origen, menos salida")[Menos carga en el origen y salida más barata; del origen de AWS a CloudFront no se paga transferencia.],
)

== Trampas comunes

#tabla(("Trampa", "Por qué cuesta", "Cómo evitarla"), columnas: (1.2fr, 2.5fr, 2.3fr), tamano: 8pt,
  [*NAT Gateway*], [Hora por cada AZ más cada GB procesado, incluido el tráfico a S3, DynamoDB o ECR.], [Endpoints de gateway (y de interfaz si compensa); VPC Flow Logs para ver quién lo usa.],
  [*IPv4 públicas y Elastic IPs*], [Desde febrero de 2024 cada IPv4 pública se cobra por hora (instancias, balanceadores, NAT), y una Elastic IP sin asociar también.], [Subredes privadas tras un balanceador, IPv6 donde se pueda, liberar EIPs e inventario con VPC IPAM.],
  [*Logs sin retención*], [Los GB almacenados se acumulan mes a mes, para siempre.], [Retención por grupo de logs; archivo en S3.],
  [*Snapshots y AMIs huérfanos*], [Se pagan por GB-mes aunque el volumen original ya no exista.], [Data Lifecycle Manager o AWS Backup con retención.],
  [*EBS sin adjuntar*], [Un volumen en estado _available_ cuesta lo mismo que uno en uso.], [Revisión periódica: snapshot si hace falta y borrar.],
  [*Tráfico entre AZ*], [Microservicios «habladores» o lecturas de réplicas en otra AZ pagan cada GB en ambos sentidos.], [Afinidad por AZ, cachés locales y compresión.],
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

#nota(titulo: "Cambios recientes en la forma de pagar")[Desde el 15 de julio de 2025, las cuentas nuevas ya no reciben la antigua capa gratuita de 12 meses: obtienen créditos promocionales y pueden elegir un *plan gratuito* de hasta seis meses, y se mantienen las cuotas «siempre gratuitas» de servicios como Lambda o DynamoDB. Desde noviembre de 2025, CloudFront ofrece además *planes de tarifa plana* mensual, sin cargos por exceso, que agrupan CDN, WAF, protección DDoS y DNS de Route 53: interesantes para webs con tráfico previsible.]

#resumen[
- Pagas por lo que *aprovisionas*: un recurso ocioso cuesta lo mismo que uno ocupado.
- Los grandes conductores son cómputo, almacenamiento y *transferencia*: entrar es gratis, salir y cruzar AZ o regiones cuesta, y el NAT Gateway cobra por GB procesado.
- Cost Explorer analiza, Budgets avisa (y actúa), Data Exports da el detalle, Anomaly Detection vigila y Compute Optimizer recomienda tamaños.
- Las etiquetas de asignación de costes solo cuentan una vez *activadas*; hazlas obligatorias desde la IaC y las políticas de Organizations.
- Cubre la base con Savings Plans o RI, los picos con On-Demand y lo interrumpible con Spot.
- Palancas rápidas: rightsizing, apagar dev de noche, Graviton, gp3, lifecycle de S3, retención de logs y endpoints de VPC.
]

#repaso(
  ([¿Qué tráfico de datos no se cobra?], [La entrada desde Internet, el tráfico dentro de la misma AZ con IPs privadas, el acceso a S3 o DynamoDB por un endpoint de gateway en la misma región y la transferencia de un origen de AWS a CloudFront.]),
  ([¿Qué diferencia hay entre Compute Savings Plans y EC2 Instance Savings Plans?], [Compute SP (hasta 66 %) vale para cualquier familia, región o SO de EC2 y para Fargate y Lambda; EC2 Instance SP (hasta 72 %) se limita a una familia en una región.]),
  ([Has etiquetado todo, pero las etiquetas no salen en Cost Explorer. ¿Por qué?], [Hay que activarlas como etiquetas de asignación de costes en la consola de facturación; hasta entonces no aparecen en los informes.]),
  ([Un proceso por lotes nocturno tolera interrupciones. ¿Cómo lo abaratas?], [Con instancias Spot (hasta un 90 % de descuento), diversificando tipos de instancia y preparando el trabajo para el aviso de 2 minutos.]),
  ([La partida de NAT Gateway se ha disparado. ¿Qué revisas?], [Qué tráfico pasa por él (VPC Flow Logs); llevar S3 y DynamoDB a endpoints de gateway y valorar endpoints de interfaz para servicios como ECR o CloudWatch.]),
  ([¿En qué se diferencian AWS Budgets y Cost Anomaly Detection?], [Budgets avisa (o actúa) cuando el gasto real o previsto supera umbrales que tú defines; Anomaly Detection usa aprendizaje automático para detectar gastos inusuales sin umbrales fijos.]),
)
