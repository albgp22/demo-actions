#import "../theme.typ": *


// ---------------------------------------------------------------------
//  Utilidades locales para los diagramas de este capítulo
// ---------------------------------------------------------------------

// Gráfico de una alarma "M de N" (3 de 5) con umbral del 80 %
#let _grafico-alarma() = {
  let vals = (45, 52, 88, 60, 55, 91, 70, 85, 93, 40)
  let umbral = 80
  let h = 2.5cm
  let bw = 0.6cm
  let paso = 1.15cm
  let x0 = 1.1cm
  let n = vals.len()
  let estados = range(n).map(i => {
    let ventana = vals.slice(calc.max(0, i - 4), i + 1)
    if ventana.filter(v => v > umbral).len() >= 3 { "ALARM" } else { "OK" }
  })
  let yv(v) = h - h * v / 110
  box(width: x0 + paso * n, height: h + 1.1cm, {
    // Ventana de evaluación que dispara la alarma (t5 a t9)
    place(top + left, dx: x0 + 4 * paso + 1pt, dy: -3pt,
      rect(width: 5 * paso - 2pt, height: h + 6pt, radius: 4pt, fill: col.iam.lighten(94%),
        stroke: (paint: col.iam.lighten(35%), thickness: 0.8pt, dash: "dashed")))
    // Ejes
    for t in (0, 50, 100) {
      place(top + left, dy: yv(t) - 4pt,
        box(width: x0 - 7pt, align(right, text(6pt, fill: gris, str(t) + " %"))))
    }
    place(top + left, dx: x0 - 3pt, line(angle: 90deg, length: h, stroke: 0.6pt + gris))
    place(top + left, dx: x0 - 3pt, dy: h, line(length: paso * n, stroke: 0.6pt + gris))
    // Umbral (detrás de las barras)
    place(top + left, dx: x0 - 3pt, dy: yv(umbral),
      line(length: paso * n, stroke: (paint: col.iam, thickness: 1pt, dash: "dashed")))
    place(top + left, dx: x0 + paso * n + 1pt, dy: yv(umbral) - 4pt,
      text(6pt, weight: "bold", fill: col.iam, "umbral 80 %"))
    // Barras, valores, periodos y estado
    for (i, v) in vals.enumerate() {
      let x = x0 + i * paso + (paso - bw) / 2
      let c = if v > umbral { col.iam } else { col.observabilidad }
      place(top + left, dx: x, dy: yv(v),
        rect(width: bw, height: h - yv(v), fill: c.lighten(8%), radius: (top: 2pt)))
      place(top + left, dx: x - 2pt, dy: yv(v) - 10pt, box(width: bw + 4pt,
        align(center, box(fill: white, inset: (x: 1.5pt, y: 1pt), radius: 1.5pt,
          text(6pt, weight: "semibold", fill: c.darken(20%), str(v))))))
      place(top + left, dx: x - 6pt, dy: h + 3pt, box(width: bw + 12pt,
        align(center, text(6pt, fill: gris, "t" + str(i + 1)))))
      let e = estados.at(i)
      let ce = if e == "ALARM" { col.iam } else { rgb("#2F9E44") }
      place(top + left, dx: x0 + i * paso + 2pt, dy: h + 14pt,
        box(width: paso - 4pt, height: 11pt, radius: 2pt, fill: ce.lighten(82%),
          align(center + horizon, text(5.6pt, weight: "bold", fill: ce.darken(25%), e))))
    }
  })
}

// Diagrama de cascada de una traza de X-Ray
#let _traza() = {
  let total = 2000
  let w = 9.4cm
  let filas = (
    ("API Gateway", "segmento", 0, 1900, col.observabilidad),
    ("Lambda crear-pedido", "segmento", 40, 1850, col.serverless),
    ("DynamoDB · GetItem", "subsegmento", 80, 110, col.datos),
    ("HTTP · pasarela pago", "subsegmento", 130, 1710, col.iam),
    ("SQS · SendMessage", "subsegmento", 1730, 1770, col.integracion),
  )
  grid(columns: (4.6cm, w + 1.1cm), column-gutter: 8pt, row-gutter: 5pt,
    align: (right + horizon, left + horizon),
    ..filas.map(((nombre, tipo, a, b, c)) => (
      [#text(7pt, weight: "semibold", fill: tinta, nombre)#h(4pt)#text(6pt, fill: gris, tipo)],
      box(width: w + 1.1cm, height: 12pt, {
        place(left + horizon, dx: w * a / total,
          rect(width: w * (b - a) / total, height: 11pt, fill: c.lighten(8%), radius: 2pt))
        place(left + horizon, dx: w * b / total + 3pt,
          text(6pt, fill: gris.darken(10%), str(b - a) + " ms"))
      }),
    )).flatten(),
    [],
    box(width: w + 1.1cm, height: 14pt, {
      place(left + top, line(length: w, stroke: 0.6pt + gris))
      for t in (0, 500, 1000, 1500, 2000) {
        place(left + top, dx: w * t / total, line(angle: 90deg, length: 3pt, stroke: 0.6pt + gris))
        place(left + top, dx: w * t / total - 0.5cm, dy: 4pt,
          box(width: 1cm, align(center, text(5.8pt, fill: gris, str(t) + " ms"))))
      }
    }),
  )
}

#capitulo("Observabilidad: logging, métricas y auditoría", color: col.observabilidad,
  subtitulo: [Saber qué está pasando en tus sistemas —y quién hizo qué— antes de que te lo cuenten tus usuarios.],
  objetivos: (
    [Los tres pilares: métricas, logs y trazas],
    [Métricas y alarmas de CloudWatch],
    [Centralizar y consultar logs con CloudWatch Logs],
    [Seguir una petición entre servicios con X-Ray],
    [Auditar la cuenta con CloudTrail y AWS Config],
    [Diseñar un logging centralizado multi-cuenta],
  ),
  servicios: ("Amazon CloudWatch", "AWS X-Ray", "AWS CloudTrail", "AWS Config", "Amazon EventBridge", "Amazon Managed Grafana"))

== Por qué observar: los tres pilares

*Monitorizar* es vigilar lo que ya sabes que puede fallar: la CPU, el disco, un proceso. *Observar* va más allá: poder responder preguntas nuevas —"¿por qué solo fallan los pagos con tarjeta de este país?"— a partir de las señales que el sistema ya emite, sin desplegar código nuevo. En AWS esas señales son de tres tipos:

#tarjetas(columnas: 3,
  tarjeta("Métricas", subtitulo: "¿Va algo mal?")[Series numéricas en el tiempo: latencia, errores, CPU. Baratas de guardar y consultar; la base de alarmas y tendencias. → *CloudWatch Metrics*.],
  tarjeta("Logs", color: col.computo, subtitulo: "¿Qué ha pasado exactamente?")[Registros de eventos con detalle: un error con su traza de pila, una petición concreta. Más voluminosos: se filtran y se buscan. → *CloudWatch Logs*.],
  tarjeta("Trazas", color: col.serverless, subtitulo: "¿Dónde se va el tiempo?")[El recorrido de una petición por varios servicios, con la duración de cada tramo. → *AWS X-Ray* y *OpenTelemetry*.],
)

A estas señales de tus aplicaciones se suma la *auditoría* de la propia cuenta: quién llamó a qué API (*CloudTrail*) y cómo estaba configurado cada recurso (*AWS Config*).

#diagrama(pie: [Flujo básico: los recursos publican métricas y logs en CloudWatch y las alarmas disparan avisos o acciones automáticas.])[
  #fila(espacio: 6pt,
    columna(espacio: 4pt,
      svc("EC2", "EC2 + agente", color: col.computo),
      svc("λ", "Lambda, ECS, RDS…", color: col.serverless)),
    flecha(etiqueta: "métricas y logs", largo: 1.8cm),
    zona("Amazon CloudWatch", color: col.observabilidad)[
      #grid(columns: 2, gutter: 4pt,
        svc("MET", "Metrics", color: col.observabilidad),
        svc("LOG", "Logs", color: col.observabilidad),
        svc("ALM", "Alarms", color: col.observabilidad),
        svc("DSH", "Dashboards", color: col.observabilidad))
    ],
    flecha(etiqueta: "estado ALARM", largo: 1.8cm),
    columna(espacio: 4pt,
      svc("SNS", "Amazon SNS", sub: "correo, chat, SMS", color: col.integracion),
      svc("ASG", "Auto Scaling", sub: "u otra acción", color: col.computo)),
  )
]

== CloudWatch Metrics

#ficha("Amazon CloudWatch", "Métricas, logs, alarmas y paneles para AWS y tus aplicaciones",
  ("Ámbito", [Regional; los dashboards y la observabilidad entre cuentas reúnen varias regiones y cuentas]),
  ("Incluye", [Metrics, Alarms, Logs, Dashboards, Synthetics, RUM, Application Signals y varios "Insights"]),
  ("Facturación", [Métricas personalizadas, peticiones a la API, alarmas, GB de logs ingeridos, almacenados y analizados, dashboards…, con una capa gratuita]))

/ Namespace: contenedor de métricas: `AWS/EC2`, `AWS/Lambda`… o uno tuyo, como `TiendaOnline`.
/ Métrica: una serie temporal con nombre (`CPUUtilization`) formada por _datapoints_: marca de tiempo, valor y unidad.
/ Dimensión: par nombre-valor que identifica la serie (`InstanceId=i-0abc…`, `Entorno=prod`). Cada combinación distinta es una métrica distinta; admite hasta 30 dimensiones.
/ Estadística y periodo: los datapoints se agregan por periodos (1 minuto, 5 minutos…) con `Average`, `Sum`, `Minimum`, `Maximum`, `SampleCount` o percentiles (`p99`).
/ Resolución: *estándar* (granularidad de 1 minuto) o *alta* (hasta 1 segundo, solo para métricas personalizadas).

CloudWatch conserva las métricas 15 meses, agregándolas a medida que envejecen:

#datos(("3 h", [datapoints de 1 segundo]), ("15 días", [datapoints de 1 minuto]), ("63 días", [datapoints de 5 minutos]), ("15 meses", [datapoints de 1 hora]))

Sin instalar nada, EC2 publica cada 5 minutos (cada minuto con _detailed monitoring_, de pago) la CPU, el tráfico de red, las operaciones de disco, los _status checks_ y, en las instancias T, los créditos de CPU. Igual hacen Lambda (invocaciones, errores, duración, _throttles_), RDS, ELB, SQS y casi todos los servicios.

#cuidado[EC2 *no* publica memoria ni espacio en disco: el hipervisor ve la CPU y la red de la instancia, pero no lo que ocurre dentro del sistema operativo. Para medir memoria (`mem_used_percent`), disco (`disk_used_percent`) o procesos, instala el *agente unificado de CloudWatch*, que publica en el namespace `CWAgent`.]

=== Métricas personalizadas

Puedes publicar tus propias métricas de negocio o de aplicación con la API `PutMetricData`:

```bash
aws cloudwatch put-metric-data --namespace TiendaOnline \
  --metric-name PedidosFallidos --unit Count --value 1 \
  --dimensions Servicio=checkout,Entorno=prod
```

En Lambda y contenedores es más eficiente el *Embedded Metric Format* (EMF): escribes una línea de log JSON con un bloque `_aws` y CloudWatch extrae la métrica de forma asíncrona, sin llamadas a la API. El resto de campos (`pedidoId`) quedan en el log como contexto:

```json
{
  "_aws": {
    "Timestamp": 1773484867000,
    "CloudWatchMetrics": [{
      "Namespace": "TiendaOnline", "Dimensions": [["Servicio"]],
      "Metrics": [{ "Name": "LatenciaCheckout", "Unit": "Milliseconds" }]
    }]
  },
  "Servicio": "checkout", "LatenciaCheckout": 182, "pedidoId": "P-81"
}
```

#nota(titulo: "Media frente a percentiles")[Si 98 peticiones tardan 100 ms y dos tardan 10 s, la media ronda los 300 ms y parece aceptable, pero el percentil 99 (`p99`) es de 10 s: hay usuarios esperando diez segundos. Para latencias, vigila `p90` y `p99`, no la media.]

== CloudWatch Alarms

Una *alarma* vigila una métrica (o una expresión matemática que combine varias) y compara cada periodo con un umbral. Tiene tres estados: `OK`, `ALARM` e `INSUFFICIENT_DATA` (no hay datos suficientes: la métrica acaba de empezar, la instancia está parada…), y cada cambio de estado puede disparar acciones.

Para no despertar a nadie por un pico aislado, decides cuántos periodos evaluar (*N*, `EvaluationPeriods`) y cuántos de ellos deben superar el umbral (*M*, `DatapointsToAlarm`): con "3 de 5", la alarma salta cuando 3 de los últimos 5 periodos lo superan, aunque no sean consecutivos. También eliges cómo tratar los datos que faltan: como ausentes, como dentro del umbral (`notBreaching`), como fuera (`breaching`) o ignorándolos.

#diagrama(pie: [Alarma "3 de 5" sobre la CPU media, con umbral del 80 % y periodos de 1 minuto. El pico aislado de t3 no la dispara; en t9, tres de los últimos cinco periodos superan el umbral y pasa a `ALARM`.])[
  #_grafico-alarma()
]

```bash
aws cloudwatch put-metric-alarm --alarm-name cpu-alta-web \
  --namespace AWS/EC2 --metric-name CPUUtilization \
  --dimensions Name=AutoScalingGroupName,Value=web-asg \
  --statistic Average --period 60 --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 5 --datapoints-to-alarm 3 \
  --treat-missing-data notBreaching \
  --alarm-actions arn:aws:sns:eu-west-1:123456789012:avisos-ops
```

- *Acciones*: notificar a un tema de *SNS* (correo, SMS, chat, webhooks), ejecutar una política de *Auto Scaling*, detener, terminar, reiniciar o recuperar una *instancia EC2*, invocar una función *Lambda* o crear un OpsItem o un incidente en *Systems Manager*.
- *Alarmas compuestas*: combinan otras alarmas con `AND`, `OR` y `NOT` ("latencia alta *y* errores altos") para avisar solo cuando importa y reducir el ruido.
- *Detección de anomalías*: en lugar de un umbral fijo, CloudWatch aprende el comportamiento habitual de la métrica, con sus ciclos diarios y semanales, y dibuja una banda de valores esperados; la alarma salta cuando el valor sale de ella.

== CloudWatch Logs

/ Evento de log: una línea con marca de tiempo y mensaje (texto o JSON).
/ Log stream: secuencia de eventos de una misma fuente: una instancia, un contenedor, un entorno de ejecución de Lambda.
/ Log group: agrupa streams del mismo tipo (`/aws/lambda/pedidos`, `/ecs/web`). En él se configuran la *retención*, el cifrado con KMS, los permisos y los filtros.

Lambda, ECS (con el driver `awslogs`), API Gateway y muchos otros servicios envían sus logs sin agente. Desde EC2 o servidores on-premises, el *agente unificado de CloudWatch* envía ficheros de log y métricas del sistema; su configuración JSON se guarda en Parameter Store y se distribuye con Systems Manager. Al crear un log group eliges su *clase*: *Standard*, con todas las funciones, o *Infrequent Access*, con una ingesta más barata a cambio de menos funciones (por ejemplo, sin metric filters ni Live Tail), aunque se puede consultar con Logs Insights. La clase no se puede cambiar después.

#coste[Por defecto, un log group *nunca caduca*: pagas cada mes por todo lo acumulado desde el primer día. Fija una retención (de 1 día a 10 años) en cada log group —mejor desde IaC— y archiva en S3 lo que debas guardar años. La ingesta suele ser el mayor coste: no dejes el nivel DEBUG activado en producción.]

=== Del log a la acción: filtros y exportación

#diagrama(pie: [Qué puedes hacer con los eventos de un log group: convertirlos en métricas, enviarlos a otros destinos o consultarlos.])[
  #let c = col.observabilidad
  #grid(columns: 7, column-gutter: 4pt, row-gutter: 6pt, align: center + horizon,
    grid.cell(rowspan: 3, zona("Log group", color: c, ancho: 3.4cm)[#columna(espacio: 3pt,
      caja([stream i-0abc (EC2)], color: c),
      caja([stream tarea-1 (ECS)], color: c),
      text(6.3pt, fill: gris, [retención · KMS · clase]))]),
    flecha(largo: 0.9cm), caja([*Metric filter* \ "ERROR"], color: c, ancho: 3.2cm),
    flecha(largo: 0.8cm), svc("MET", "Métrica", color: c),
    flecha(largo: 0.8cm), svc("ALM", "Alarma", sub: "→ SNS", color: c),
    flecha(largo: 0.9cm), caja([*Subscription filter* \ tiempo casi real], color: c, ancho: 3.2cm),
    flecha(largo: 0.8cm), svc("FH", "Data Firehose", color: col.integracion),
    flecha(largo: 0.8cm), svc("S3", "S3 u OpenSearch", color: col.almacenamiento),
    flecha(largo: 0.9cm), caja([*Logs Insights* \ y Live Tail], color: c, ancho: 3.2cm),
    flecha(largo: 0.8cm), actor(etiqueta: "Investigación"),
    [], [],
  )
]

- *Metric filters*: convierten en métrica los eventos que cumplen un patrón —contar `ERROR`, extraer la latencia de un campo JSON— para crear alarmas. Solo procesan eventos nuevos, no los anteriores a su creación.
- *Subscription filters*: envían en tiempo casi real los eventos que cumplen un patrón a Kinesis Data Streams, Amazon Data Firehose, Lambda u OpenSearch Service, incluso en otra cuenta. Admiten hasta dos por log group.
- *Exportación a S3*: una tarea por lotes (`create-export-task`), no en tiempo real: los datos pueden tardar hasta 12 horas en estar disponibles para exportar. Para un flujo continuo hacia S3, usa un subscription filter con Firehose.

=== Logs Insights y Live Tail

*Logs Insights* consulta uno o varios log groups con un lenguaje de tuberías (también admite SQL y PPL de OpenSearch) y se paga por GB analizado. Descubre automáticamente los campos de los logs JSON y los de servicios como Lambda (`@duration`, `@maxMemoryUsed`…):

```logs
# Los 20 errores más recientes
fields @timestamp, @logStream, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 20

# Lambda: duración media, p99 y memoria máxima cada 5 minutos
filter @type = "REPORT"
| stats avg(@duration), pct(@duration, 99), max(@maxMemoryUsed) by bin(5m)

# Logs JSON: errores 5xx por ruta
filter status >= 500
| stats count(*) as errores by ruta
| sort errores desc
```

*Live Tail* muestra en tiempo real, con filtros, los eventos que van llegando —el `tail -f` de la nube— y se factura por minuto de sesión.

== Dashboards y monitorización de aplicaciones

#tabla(("Herramienta", "Qué hace", "Úsala para"), columnas: (1.1fr, 2.3fr, 1.5fr), tamano: 8pt,
  [*Dashboards*], [Paneles con gráficos de métricas, alarmas y consultas de logs, incluso de varias regiones y cuentas], [La vista de un servicio o del negocio],
  [*Synthetics*], [_Canaries_: scripts programados (Node.js o Python) que recorren tu web o API como un usuario, con capturas de pantalla], [Detectar caídas antes que los usuarios, aunque no haya tráfico],
  [*RUM*], [Un fragmento JavaScript mide la experiencia real en el navegador: tiempos de carga, errores, Core Web Vitals], [Saber cómo va la web para usuarios reales],
  [*Application Signals*], [APM con instrumentación automática (OpenTelemetry): latencia, errores y disponibilidad por servicio y operación, SLO y mapa de servicios], [Salud de microservicios y objetivos de nivel de servicio],
  [*Container Insights*], [Métricas y logs de ECS, EKS y Kubernetes por clúster, servicio, tarea o pod], [Contenedores (más en "Kubernetes y Amazon EKS")],
  [*Lambda Insights*], [Extensión que añade métricas de sistema por función: memoria, CPU, red, arranques en frío], [Afinar funciones Lambda],
  [*Database Insights*], [Carga de la base de datos por consulta SQL y evento de espera], [RDS y Aurora (capítulo de Bases de datos)],
)

== Trazas distribuidas con AWS X-Ray

En una arquitectura de microservicios, una petición puede pasar por API Gateway, varias funciones Lambda, una cola y una tabla de DynamoDB. Si tarda dos segundos, ¿dónde se fueron? *AWS X-Ray* sigue cada petición de extremo a extremo y lo muestra así:

#diagrama(pie: [Traza de una petición lenta: el subsegmento de la llamada HTTP a la pasarela de pago consume más del 80 % de los 1,9 s.])[
  #_traza()
]

/ Traza: el recorrido completo de una petición, identificado por un _trace ID_ que viaja en la cabecera `X-Amzn-Trace-Id`.
/ Segmento y subsegmento: el *segmento* es el trabajo de un servicio dentro de la traza (la función Lambda); los *subsegmentos* lo detallan, típicamente cada llamada a otro servicio (DynamoDB, HTTP, SQL).
/ Anotaciones y metadatos: pares clave-valor que añades tú; las *anotaciones* se indexan y permiten filtrar trazas (`cliente = "premium"`), los metadatos no.
/ Muestreo: no se traza todo; por defecto, la primera petición de cada segundo y el 5 % de las demás.
/ Mapa de servicios: grafo generado automáticamente con los servicios, sus conexiones, latencias y tasas de error.

En Lambda y API Gateway, activar el _tracing_ activo es una casilla; en tu código instrumentas con los SDK de X-Ray o, cada vez más, con *OpenTelemetry*: AWS mantiene su propia distribución, *AWS Distro for OpenTelemetry (ADOT)*, y recomienda OpenTelemetry para las instrumentaciones nuevas.

== Auditoría con AWS CloudTrail

#ficha("AWS CloudTrail", "Registro de auditoría de las llamadas a la API de tus cuentas",
  ("Qué registra", [Quién hizo qué, cuándo, desde dónde y con qué resultado, ya sea desde la consola, la CLI, un SDK o un servicio de AWS]),
  ("Sin configurar", [_Event history_: 90 días de eventos de gestión, gratis, consultables por región]),
  ("Facturación", [La primera copia de los eventos de gestión en un trail es gratuita; se pagan los eventos de datos, Insights, las copias adicionales y CloudTrail Lake]))

#tabla(("Tipo de evento", "Qué incluye", "Ejemplos", "Por defecto"), columnas: (1.15fr, 1.7fr, 1.9fr, 0.75fr), tamano: 8pt,
  [*De gestión*], [Operaciones del plano de control], [`CreateBucket`, `RunInstances`, `AttachRolePolicy`, `ConsoleLogin`], [#si Sí],
  [*De datos*], [Operaciones sobre los datos, de gran volumen], [`GetObject`/`PutObject` en S3, `Invoke` en Lambda, ítems de DynamoDB], [#no De pago],
  [*Insights*], [Actividad inusual: picos de llamadas o de errores], [Ráfaga de borrados, aumento de `AccessDenied`], [#no De pago],
  [*De actividad de red*], [Llamadas a través de VPC endpoints, incluidas las denegadas], [Accesos desde la VPC a S3 o KMS], [#no De pago],
)

Para conservar más de 90 días o registrar eventos de datos, crea un *trail*: entrega los eventos a un bucket de S3 —con unos minutos de retraso— y, si quieres, a CloudWatch Logs para crear alarmas. Hazlo *multirregión* (también registra las regiones que no usas) y, con Organizations, crea un *trail de organización*, que cubre todas las cuentas sin que estas puedan modificarlo. La *validación de integridad* entrega cada hora un _digest_ firmado con los hashes SHA-256 de los logs: `aws cloudtrail validate-logs` demuestra que nadie los ha alterado. *CloudTrail Lake* guarda los eventos en un almacén gestionado consultable con SQL, hasta 10 años.

```json
{
  "eventVersion": "1.09",
  "userIdentity": {
    "type": "AssumedRole", "accountId": "123456789012",
    "arn": "arn:aws:sts::123456789012:assumed-role/Admin/ana"
  },
  "eventTime": "2026-03-14T09:21:07Z",
  "eventSource": "s3.amazonaws.com", "eventName": "DeleteBucket",
  "awsRegion": "eu-west-1", "sourceIPAddress": "203.0.113.25",
  "userAgent": "aws-cli/2.17.0",
  "requestParameters": { "bucketName": "facturas-2025" },
  "readOnly": false, "managementEvent": true
}
```

#examen[CloudTrail responde a *quién* hizo *qué* llamada a la API y *cuándo*; AWS Config, a *cómo estaba configurado* un recurso y si *cumple* tus reglas; CloudWatch, a *cómo está funcionando*. Event history guarda 90 días y solo eventos de gestión; los eventos de datos (`GetObject`, `Invoke`) están desactivados por defecto.]

== AWS Config: configuración y cumplimiento

*AWS Config* inventaría tus recursos y registra cada cambio de configuración como un _configuration item_, junto con sus relaciones (esta instancia usa este Security Group, en esta subred). Así obtienes la *línea temporal de configuración* de cada recurso —qué cambió y cuándo, con enlace al evento de CloudTrail que dice quién— y puedes evaluar el cumplimiento:

- *Reglas*: comprueban la configuración deseada. Hay cientos de reglas gestionadas (`s3-bucket-public-read-prohibited`, `encrypted-volumes`, `restricted-ssh`…) y puedes escribir las tuyas con Lambda o con Guard. Se evalúan al cambiar un recurso o periódicamente.
- *Remediación*: asocia a una regla un documento de *Systems Manager Automation* que corrige el problema, a mano o automáticamente (por ejemplo, bloquear el acceso público de un bucket).
- *Conformance packs*: paquetes de reglas y remediaciones que se despliegan como una unidad, incluso en toda la organización, con plantillas para marcos como CIS o PCI DSS.
- *Agregadores*: reúnen el cumplimiento de varias cuentas y regiones en una sola vista.

#cuidado[AWS Config es *detectivo*: avisa (y puede corregir) después del cambio, pero no lo impide. Para impedirlo usa controles *preventivos*, como las SCP o las políticas IAM (capítulo "IAM (II): permisos — políticas y evaluación"). Además, se factura por _configuration item_ registrado y por evaluación de reglas: en cuentas con muchos cambios, limita los tipos de recurso que registra.]

== Reaccionar a eventos y otros logs

Muchos servicios emiten eventos a *Amazon EventBridge*: cambios de estado de EC2, hallazgos de GuardDuty, avisos de AWS Health, cambios de cumplimiento de Config, llamadas a la API registradas por CloudTrail… Una *regla* con un patrón los filtra y los envía a un destino (Lambda, SNS, SQS, Step Functions, una automatización de Systems Manager). Así pasas de observar a *reaccionar* automáticamente. Este patrón avisa cada vez que alguien borra un bucket o cambia su política (EventBridge se trata a fondo en el capítulo de Mensajería):

```json
{
  "source": ["aws.s3"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["s3.amazonaws.com"],
    "eventName": ["DeleteBucket", "PutBucketPolicy"]
  }
}
```

Otros servicios generan sus propios logs, que conviene activar y centralizar:

#tabla(("Fuente", "Qué registra", "Destino", "Capítulo"), columnas: (1.1fr, 2.3fr, 1.5fr, 0.85fr), tamano: 8pt,
  [*VPC Flow Logs*], [Metadatos del tráfico IP por VPC, subred o ENI: IP, puertos, bytes, `ACCEPT`/`REJECT`. No el contenido], [CloudWatch Logs, S3 o Firehose], [Redes],
  [*Logs de ELB*], [Cada petición al balanceador: cliente, latencias, códigos de estado], [S3], [Balanceo],
  [*Logs de CloudFront*], [Logs estándar de cada petición y logs en tiempo real], [S3, CloudWatch Logs, Firehose o Kinesis], [CloudFront],
  [*Logs de acceso de S3*], [Peticiones a un bucket, con entrega "best effort"; para auditoría fiable, eventos de datos de CloudTrail], [Otro bucket de S3], [Almacenamiento],
)

== Logging centralizado multi-cuenta

En una organización con decenas de cuentas no quieres iniciar sesión en cada una para investigar un incidente. El patrón habitual —el que despliega AWS Control Tower— lleva cada tipo de dato a una cuenta especializada:

#diagrama(pie: [Logging centralizado en una organización: los datos de las cuentas de trabajo terminan en cuentas dedicadas a archivo, auditoría y monitorización.])[
  #grid(columns: 3, column-gutter: 6pt, row-gutter: 8pt, align: center + horizon,
    grid.cell(rowspan: 3, zona("Cargas de trabajo", color: col.neutro, ancho: 4cm)[
      #columna(espacio: 6pt,
        svc("PRD", "Producción", sub: "EC2, Lambda, ECS…", color: col.computo),
        svc("DEV", "Desarrollo", color: col.computo),
        svc("…", "Más cuentas", color: col.neutro))
    ]),
    flecha(etiqueta: "CloudTrail, Config, Flow Logs", largo: 3cm),
    zona("Cuenta Log Archive", color: col.almacenamiento)[#fila(
      svc("S3", "Bucket central", sub: "Object Lock y ciclo de vida", color: col.almacenamiento),
      svc("ATH", "Athena", sub: "consultas SQL", color: col.datos))],
    flecha(etiqueta: "cumplimiento y hallazgos", largo: 3cm),
    zona("Cuenta de auditoría y seguridad", color: col.seguridad)[#fila(
      svc("CFG", "Config", sub: "agregador", color: col.observabilidad),
      svc("SH", "Security Hub", sub: "y GuardDuty", color: col.seguridad))],
    flecha(etiqueta: "métricas, logs y trazas", largo: 3cm),
    zona("Cuenta de monitorización", color: col.observabilidad)[#fila(
      svc("CW", "CloudWatch", sub: "entre cuentas", color: col.observabilidad),
      svc("AMG", "Managed Grafana", color: col.observabilidad))],
  )
]

- Un *trail de organización* lleva los eventos de todas las cuentas a un bucket de la cuenta *Log Archive*, con acceso mínimo, Object Lock contra borrados y ciclo de vida hacia clases más baratas; se consulta con Athena.
- Un *agregador* de AWS Config en la cuenta de auditoría da la vista de cumplimiento de la organización, junto a Security Hub y GuardDuty (capítulo de Seguridad).
- La *observabilidad entre cuentas* de CloudWatch deja que una cuenta de monitorización vea métricas, logs y trazas de las demás sin copiarlos; para copiar logs, subscription filters hacia Firehose.

#nota(titulo: "Amazon Managed Grafana y Managed Service for Prometheus")[Si tus equipos ya usan herramientas de código abierto, AWS las ofrece gestionadas. *Amazon Managed Service for Prometheus* almacena métricas compatibles con Prometheus —muy habitual en Kubernetes— y se consulta con PromQL. *Amazon Managed Grafana* crea paneles sobre CloudWatch, Prometheus, X-Ray, OpenSearch, Athena y otras fuentes, con inicio de sesión mediante IAM Identity Center o SAML.]

== ¿Qué herramienta para qué pregunta?

#block(breakable: false)[#tabla(("Pregunta", "Herramienta"), columnas: (2.3fr, 1fr), tamano: 8.4pt,
  [¿Quién borró este bucket o cambió este Security Group?], [CloudTrail],
  [¿Cómo estaba configurado este recurso el martes? ¿Están cifrados todos los volúmenes?], [AWS Config],
  [¿Por qué va lenta la API? ¿En qué servicio se va el tiempo?], [X-Ray, Application Signals],
  [¿Cuántos errores 5xx hay? ¿Está la CPU al límite?], [CloudWatch Metrics y Alarms],
  [¿Qué excepción lanzó la aplicación a las 03:12?], [CloudWatch Logs Insights],
  [¿Qué IP intenta conectar al puerto 22 y es rechazada?], [VPC Flow Logs],
  [¿Funciona el login desde fuera, aunque ahora nadie lo use?], [CloudWatch Synthetics],
  [¿Cuánto tarda en cargar la web para los usuarios reales?], [CloudWatch RUM],
  [¿Qué consulta SQL satura la base de datos?], [Database Insights],
  [¿Hay un pico anómalo de llamadas a la API en la cuenta?], [CloudTrail Insights],
)]

== Buenas prácticas

- *Logs estructurados en JSON*: campos consultables (`nivel`, `servicio`, `ruta`, `latencia_ms`) en lugar de texto libre; Logs Insights los descubre solos.
- *Correlación*: incluye en cada línea el _request id_ o el _trace id_ y propágalo entre servicios para reconstruir una petición completa.
- *Alarmas sobre síntomas*: alerta por lo que nota el usuario (tasa de errores, latencia `p99`, disponibilidad), no por cada causa posible (CPU al 85 %); las causas, a los paneles. Y que cada alarma sea accionable, con un destinatario claro y un _runbook_.
- *Retención en todos los log groups*, archivado en S3 para lo que deba conservarse años y nada de secretos ni datos personales en los logs (las _data protection policies_ de CloudWatch Logs pueden enmascararlos).
- *Observabilidad como código*: alarmas, dashboards y retenciones en CloudFormation, CDK o Terraform (capítulo de Infraestructura como código).
- En Lambda, *Powertools for AWS Lambda* genera por ti logs JSON con el _request id_, métricas EMF y trazas; a mano, sería algo así:

```python
import json, logging, time
log = logging.getLogger()
log.setLevel(logging.INFO)

def handler(event, context):
    inicio = time.time()
    # ... lógica de negocio ...
    log.info(json.dumps({
        "nivel": "INFO", "servicio": "checkout", "ruta": event.get("rawPath"),
        "request_id": context.aws_request_id,               # correlación
        "latencia_ms": round((time.time() - inicio) * 1000)}))
```

#resumen[
- Observar se apoya en *métricas* (¿va algo mal?), *logs* (¿qué pasó?) y *trazas* (¿dónde se va el tiempo?), más la *auditoría* de la cuenta.
- CloudWatch Metrics organiza las series por namespace y dimensiones; EC2 no publica memoria ni disco sin el agente unificado. Publica métricas propias con `PutMetricData` o EMF y vigila percentiles.
- Las alarmas (`OK`, `ALARM`, `INSUFFICIENT_DATA`) se evalúan con "M de N" y avisan por SNS o actúan; las compuestas reducen ruido y la detección de anomalías evita umbrales fijos.
- CloudWatch Logs: retención indefinida por defecto (¡fíjala!), metric filters, subscription filters, exportación por lotes a S3, Logs Insights y Live Tail.
- Synthetics, RUM, Application Signals y los "Insights" cubren usuarios y aplicaciones; X-Ray (u OpenTelemetry con ADOT) traza cada petición.
- CloudTrail registra las llamadas a la API: 90 días de eventos de gestión gratis; trails multirregión y de organización, eventos de datos, Insights, Lake y validación de integridad.
- AWS Config registra la configuración en el tiempo y evalúa reglas con remediación; es detectivo, no preventivo.
- EventBridge convierte eventos en acciones, y el modelo multi-cuenta centraliza archivo, auditoría y monitorización.
]

#repaso(
  ([No ves la memoria de tus instancias EC2 en CloudWatch. ¿Por qué y cómo lo solucionas?],
   [El hipervisor no ve el interior del sistema operativo, así que EC2 no publica memoria ni disco. Instala el agente unificado de CloudWatch, que publica `mem_used_percent` y `disk_used_percent` en el namespace `CWAgent`.]),
  ([Una alarma tiene periodos de 1 minuto, `EvaluationPeriods = 5` y `DatapointsToAlarm = 3`. ¿Cuándo pasa a `ALARM`?],
   [Cuando 3 de los últimos 5 datapoints de un minuto superan el umbral, aunque no sean consecutivos. Un pico aislado no la dispara.]),
  ([Tu factura de CloudWatch Logs crece cada mes aunque el tráfico es estable. ¿Causa probable y solución?],
   [Los log groups tienen retención indefinida por defecto y acumulan datos. Fija una retención en cada uno, archiva en S3 lo que deba conservarse y reduce la verbosidad (o usa la clase Infrequent Access donde encaje).]),
  ([Alguien eliminó una tabla de DynamoDB hace tres semanas. ¿Dónde averiguas quién fue?],
   [En CloudTrail: el Event history guarda 90 días de eventos de gestión, y `DeleteTable` lo es. Verás la identidad, la IP de origen, la hora y los parámetros.]),
  ([¿Qué diferencia hay entre CloudTrail y AWS Config?],
   [CloudTrail registra las llamadas a la API (quién hizo qué y cuándo); Config registra el estado de la configuración de cada recurso a lo largo del tiempo y evalúa si cumple tus reglas.]),
  ([¿Cómo llevarías en tiempo casi real los logs de aplicación de todas las cuentas a un bucket central?],
   [Con subscription filters en cada log group hacia un destino entre cuentas que alimente Amazon Data Firehose, que entrega en S3 de la cuenta Log Archive. Para CloudTrail, un trail de organización.]),
  ([Una API de microservicios tarda 3 segundos de vez en cuando. ¿Qué herramienta te dice en qué servicio se va el tiempo?],
   [AWS X-Ray (o Application Signals): las trazas muestran la duración de cada segmento y subsegmento, y el mapa de servicios señala dónde se acumulan la latencia y los errores.]),
)
