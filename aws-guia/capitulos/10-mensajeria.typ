#import "../theme.typ": *

// Sin ligaduras en el código (para que `:::` o `->` se lean tal cual)
#show raw: set text(features: (calt: 0))

// ---------------------------------------------------------------------
//  Utilidades locales
// ---------------------------------------------------------------------

// Mensaje en una cola (cuadradito)
#let _msg(color: col.integracion) = box(width: 0.55cm, height: 0.42cm, radius: 2pt,
  fill: color.lighten(55%), stroke: 0.8pt + color)

// Segmento de una línea temporal
#let _seg(color, titulo, sub, ancho: 3cm, letra: white) = box(
  width: ancho, fill: color, radius: 3pt, inset: (x: 4pt, y: 4pt),
  align(center, {
    set par(justify: false, leading: 0.35em)
    text(6.8pt, weight: "bold", fill: letra, titulo)
    linebreak()
    text(6pt, fill: letra, sub)
  }),
)

// Shard de Kinesis con registros numerados
#let _shard(nombre, n) = box(
  width: 4.3cm, stroke: 0.8pt + col.integracion, radius: 3pt, fill: white, inset: (x: 5pt, y: 4pt),
  grid(columns: (1.2cm, auto), align: horizon, column-gutter: 4pt,
    text(6.5pt, weight: "bold", fill: col.integracion.darken(20%), nombre),
    stack(dir: ltr, spacing: 2pt, ..range(n).map(i => box(width: 0.42cm, height: 0.42cm, radius: 2pt,
      fill: col.integracion.lighten(70% - i * 8%),
      align(center + horizon, text(5.5pt, weight: "bold", fill: col.integracion.darken(30%), str(i + 1)))))),
  ),
)

// ---------------------------------------------------------------------
#capitulo("Mensajería e integración: SQS, SNS, EventBridge y Kinesis", color: col.integracion,
  subtitulo: [Conecta componentes que no se esperan unos a otros: colas, publicación-suscripción, buses de eventos y streaming de datos.],
  objetivos: (
    [Por qué desacoplar y qué cuesta hacerlo],
    [SQS a fondo: Standard y FIFO, visibilidad, DLQ y Lambda],
    [Publicar y suscribir con SNS y el patrón _fan-out_],
    [Enrutar eventos con EventBridge: reglas, Pipes y Scheduler],
    [Streaming con Kinesis, Firehose, Flink y MSK],
    [Elegir servicio y aplicar patrones: saga, _outbox_, idempotencia],
  ),
  servicios: ("Amazon SQS", "Amazon SNS", "Amazon EventBridge", "Kinesis Data Streams", "Amazon Data Firehose", "Amazon MSK", "Amazon MQ"))

== Acoplamiento y desacoplamiento

Imagina una tienda online: al confirmar un pedido hay que cobrar, enviar un correo y avisar al almacén. Si el servicio de pedidos llama a los demás de forma *síncrona*, el cliente espera la suma de todos los tiempos y, si el servicio de correo se cae, falla el pedido entero. Ese es el problema del *acoplamiento*: cada componente depende de que los demás estén disponibles, sean rápidos y aguanten su ritmo.

#diagrama(pie: [Arriba, una cadena síncrona: un fallo al final tumba la petición. Abajo, la cola absorbe el fallo y los picos.])[
  #set text(hyphenate: false)
  #zona("Acoplado · llamadas síncronas en cadena", color: col.iam, ancho: 100%)[
    #fila(actor(etiqueta: "Cliente"), flecha(etiqueta: "espera…", largo: 1.3cm),
      svc("API", "Pedidos", color: col.computo), flecha(etiqueta: "espera…", largo: 1.3cm),
      svc("PAY", "Cobros", color: col.computo), flecha(etiqueta: "espera…", largo: 1.3cm),
      svc("MAIL", "Correo", sub: [caído #no → error 500], color: col.neutro))
  ]
  #v(4pt)
  #zona("Desacoplado · mensajes asíncronos", color: col.almacenamiento, ancho: 100%)[
    #fila(actor(etiqueta: "Cliente"), flecha(etiqueta: "202 al instante", largo: 1.5cm),
      svc("API", "Pedidos", color: col.computo), flecha(etiqueta: "mensaje", largo: 1.3cm),
      svc("SQS", "Cola", sub: "guarda los mensajes", color: col.integracion), flecha(etiqueta: "a su ritmo", largo: 1.5cm),
      svc("MAIL", "Correo", sub: [vuelve y procesa #si], color: col.computo))
  ]
]

Con mensajería *asíncrona*, el productor deja un mensaje y sigue; los consumidores lo procesan a su ritmo. Ganas *resiliencia* (si un consumidor cae, los mensajes esperan), *absorción de picos* (la cola actúa de amortiguador), *escalado independiente* de cada parte y *evolución* (añadir un consumidor no obliga a tocar al productor). A cambio aceptas consistencia eventual, mensajes duplicados o desordenados y una depuración más difícil, que exige trazas distribuidas (capítulo de Observabilidad).

#analogia[Llamar por teléfono es síncrono: si no contestan, no avanzas. Dejar una carta en un buzón es asíncrono: el cartero la guarda hasta que el destinatario la recoge, aunque esté de vacaciones.]

== Amazon SQS: colas de mensajes

Amazon SQS (_Simple Queue Service_) ofrece colas totalmente gestionadas: los *productores* envían mensajes y los *consumidores* los reciben, los procesan y los borran. Es un modelo *pull*: el consumidor pregunta; la cola no empuja.

#ficha("Amazon SQS", "Colas de mensajes totalmente gestionadas",
  ("Tipo", [Serverless; pago por petición, sin coste por cola]),
  ("Ámbito", [Regional; los mensajes se guardan de forma redundante en varias AZ]),
  ("Ideal para", [Desacoplar productores y consumidores, colas de trabajo, absorber picos]),
  ("Límites clave", [Mensaje de hasta 1 MiB; retención de 1 minuto a 14 días (4 por defecto); _visibility timeout_ de hasta 12 horas]))

=== Standard frente a FIFO

#block(breakable: false)[#tarjetas(
  tarjeta("Standard", subtitulo: "Rendimiento prácticamente ilimitado")[
    - Entrega *al menos una vez*: un mensaje puede llegar duplicado.
    - Orden *aproximado* (_best effort_): «pedido pagado» podría llegar antes que «pedido creado».
    - Casi sin límite de mensajes por segundo.
  ],
  tarjeta("FIFO", color: col.datos, subtitulo: "Orden estricto y sin duplicados")[
    - Orden estricto *dentro de cada message group*.
    - Procesamiento *exactamente una vez* (deduplicación en una ventana de 5 min).
    - 300 operaciones/s por acción (3000 mensajes/s con lotes); mucho más en modo de alto rendimiento. El nombre acaba en `.fifo`.
  ],
)]

En una cola FIFO, cada mensaje lleva un *MessageGroupId*: los mensajes de un mismo grupo (un pedido, un cliente) se entregan en orden y de uno en uno, mientras que grupos distintos se procesan en paralelo; por eso el paralelismo lo marca el número de grupos. La *deduplicación* descarta repetidos durante 5 minutos, según un *MessageDeduplicationId* explícito o un hash del cuerpo (_content-based deduplication_).

=== Ciclo de vida de un mensaje

#diagrama(pie: [Un mensaje recibido queda invisible durante el visibility timeout; si no se borra, reaparece y, tras varios intentos, va a la DLQ.])[
  #set text(hyphenate: false)
  #grid(columns: 5, align: center + horizon, column-gutter: 4pt, row-gutter: 3pt,
    svc("APP", "Productor", color: col.computo), flecha(etiqueta: "1 · SendMessage", largo: 2cm),
    zona("Cola pedidos", color: col.integracion)[#stack(dir: ltr, spacing: 3pt, _msg(), _msg(), _msg(), _msg())],
    flecha(etiqueta: "2 · Receive / 4 · Delete", largo: 2.6cm, doble: true),
    svc("WRK", "Consumidor", sub: "3 · procesa", color: col.computo),
    [], [], flecha-v(etiqueta: "supera maxReceiveCount", largo: 0.8cm), [], [],
    [], [], svc("DLQ", "Dead-letter queue", sub: "para inspeccionar", color: col.iam), [], [],
  )
  #v(6pt)
  #fila(espacio: 3pt,
    _seg(col.almacenamiento, "Visible", "esperando consumidor", ancho: 2.6cm),
    flecha(etiqueta: "ReceiveMessage", largo: 1.7cm),
    _seg(col.balanceo, "Invisible (en vuelo)", "visibility timeout: 30 s por defecto", ancho: 3.6cm),
    flecha(largo: 0.8cm),
    columna(espacio: 3pt,
      _seg(col.neutro, "DeleteMessage a tiempo", "el mensaje desaparece", ancho: 3.8cm),
      _seg(col.almacenamiento.darken(10%), "Expira sin Delete", "vuelve a ser visible (+1 recepción)", ancho: 3.8cm)))
]

/ Visibility timeout: SQS no borra un mensaje al entregarlo: lo oculta al resto de consumidores durante este tiempo (30 s por defecto, hasta 12 h) y espera a que el consumidor lo borre con `DeleteMessage` al terminar. Si no lo hace a tiempo —porque falló o tardó demasiado—, el mensaje reaparece y otro consumidor lo procesará. Ajústalo por encima del tiempo de proceso y amplíalo sobre la marcha con `ChangeMessageVisibility` si una tarea se alarga.
/ Long polling: con `WaitTimeSeconds` de 1 a 20 s, `ReceiveMessage` espera a que lleguen mensajes antes de responder. El *short polling* responde al instante consultando solo parte de los servidores, así que puede devolver vacío aunque haya mensajes. Usa siempre long polling (o fíjalo en la cola con `ReceiveMessageWaitTimeSeconds`): menos respuestas vacías y menos coste.
/ Retención: de 1 minuto a 14 días (4 días por defecto); después, el mensaje se borra aunque nadie lo haya procesado.
/ Tamaño: hasta 1 MiB por mensaje (256 KB hasta agosto de 2025). Para más, la *Extended Client Library* (Java y Python) guarda el cuerpo en S3 y envía solo una referencia, hasta 2 GB: el patrón *claim check*.
/ Delay queues: retrasan la entrega de los mensajes nuevos de 0 a 15 minutos; en colas Standard, también por mensaje (_message timers_).

=== _Dead-letter queues_ y _redrive_

Un mensaje que falla una y otra vez —un *poison pill*: datos corruptos, un bug— se reintentaría eternamente. La *redrive policy* fija un `maxReceiveCount`: cuando un mensaje se recibe más veces sin borrarse, SQS lo mueve a una *dead-letter queue (DLQ)*, una cola normal del mismo tipo, cuenta y región. Allí lo inspeccionas, alertas con una alarma de CloudWatch y, cuando corrijas el fallo, lo devuelves a la cola original con un *redrive* desde la consola o la API (`StartMessageMoveTask`).

```python
import json
import boto3

sqs = boto3.client("sqs")
dlq_arn = "arn:aws:sqs:eu-west-1:123456789012:pedidos-dlq"
sqs.create_queue(
    QueueName="pedidos",
    Attributes={
        "VisibilityTimeout": "60",               # segundos
        "ReceiveMessageWaitTimeSeconds": "20",   # long polling
        "MessageRetentionPeriod": "345600",      # 4 días
        "RedrivePolicy": json.dumps({"deadLetterTargetArn": dlq_arn,
                                     "maxReceiveCount": "5"}),
    },
)
```

#cuidado[Da a la DLQ una retención mayor que la de la cola de origen: en las colas Standard la caducidad se cuenta desde que el mensaje entró en la cola original, así que un mensaje veterano podría expirar nada más llegar a la DLQ.]

=== Lotes, costes y escalado de consumidores

`SendMessageBatch`, `DeleteMessageBatch` y `ChangeMessageVisibilityBatch` agrupan hasta 10 mensajes, y `ReceiveMessage` devuelve hasta 10 por llamada: menos peticiones, menos coste. Para escalar consumidores en EC2 o ECS, usa como métrica el *backlog por consumidor* (mensajes visibles ÷ consumidores activos) con una política de _target tracking_: si cada consumidor procesa 10 mensajes/s y aceptas 30 s de retraso, el objetivo es 300 mensajes por consumidor. Vigila con una alarma `ApproximateAgeOfOldestMessage`: si crece, los consumidores no dan abasto.

#coste[SQS cobra por petición (del orden de 0,40 USD por millón en Standard y algo más en FIFO; el primer millón al mes es gratis), y cada fragmento de 64 KB de _payload_ cuenta como una petición: un mensaje de 1 MiB equivale a 16. Los consumidores con short polling disparan la factura con miles de respuestas vacías.]

=== SQS como origen de eventos de Lambda

Con un event source mapping, Lambda sondea la cola con long polling, invoca tu función con lotes y borra los mensajes si termina bien. Si falla, *todo el lote* vuelve a la cola… salvo que actives `ReportBatchItemFailures` y devuelvas solo los fallidos:

```python
import json

def handler(event, context):
    fallidos = []
    for record in event["Records"]:
        try:
            procesar(json.loads(record["body"]))
        except Exception:
            # Solo este mensaje volverá a la cola (y, tras varios intentos, a la DLQ)
            fallidos.append({"itemIdentifier": record["messageId"]})
    return {"batchItemFailures": fallidos}
```

#practica[Fija el visibility timeout de la cola en al menos *seis veces* el timeout de la función, configura siempre una DLQ y limita la *concurrencia máxima* del event source mapping para no saturar una base de datos. En colas FIFO, si un mensaje falla, devuelve también como fallidos los siguientes del mismo lote para no romper el orden.]

== Amazon SNS: publicar y suscribir

SNS (_Simple Notification Service_) implementa *publicación-suscripción*: un productor publica un mensaje en un *topic* y SNS lo *empuja* (modelo _push_) a todos sus suscriptores a la vez. El productor no sabe quién escucha ni cuántos son.

#ficha("Amazon SNS", "Mensajería pub/sub totalmente gestionada",
  ("Tipo", [Serverless; pago por millón de publicaciones; las entregas a SQS y Lambda no se cobran, las de HTTP, email o SMS sí]),
  ("Suscriptores", [Colas SQS, funciones Lambda, endpoints HTTP/HTTPS, Data Firehose, email, SMS y notificaciones _push_ móviles]),
  ("Ideal para", [Difundir un evento a varios sistemas (_fan-out_) y notificar a personas]))

/ Filtros: cada suscripción puede tener una *filter policy* sobre los atributos del mensaje o sobre su cuerpo JSON, para recibir solo lo que le interesa. Esta solo deja pasar pedidos creados o cancelados, de fuera de EE. UU. y de al menos 1000 euros:

```json
{
  "tipo": ["pedido_creado", "pedido_cancelado"],
  "pais": [{ "anything-but": ["US"] }],
  "importe": [{ "numeric": [">=", 1000] }]
}
```

/ Fiabilidad: SNS reintenta las entregas fallidas —con mucha más insistencia hacia SQS y Lambda que hacia HTTP, cuya política puedes ajustar— y cada suscripción puede tener su propia DLQ.
/ Raw message delivery: hacia SQS o HTTP, entrega el mensaje tal cual, sin el sobre JSON de SNS.
/ Topics FIFO: orden estricto y deduplicación, normalmente con colas SQS FIFO como suscriptores; permiten además archivar mensajes y reproducirlos.

== El patrón _fan-out_: SNS + SQS

El patrón más conocido de la integración en AWS combina ambos servicios: el productor publica *una vez* en un topic y cada sistema interesado tiene *su propia cola SQS* suscrita, con su propio filtro. Cada consumidor procesa a su ritmo, con sus reintentos y su DLQ, y un fallo en uno no afecta a los demás. Añadir un consumidor nuevo es crear otra cola y otra suscripción, sin tocar al productor.

#diagrama(pie: [Fan-out: una publicación, tres colas independientes, cada una con su filtro y su consumidor.])[
  #set text(hyphenate: false)
  #fila(espacio: 3pt,
    svc("API", "Pedidos", sub: "productor", color: col.computo), flecha(etiqueta: "Publish", largo: 1.2cm),
    svc("SNS", "Topic pedidos", color: col.integracion),
    columna(espacio: 2pt,
      fila(flecha(etiqueta: "todos", largo: 1.9cm), svc("SQS", "Cola facturación", color: col.integracion),
        flecha(largo: 0.9cm), svc("λ", "Facturar", color: col.serverless)),
      fila(flecha(etiqueta: "pais = ES", largo: 1.9cm), svc("SQS", "Cola envíos ES", color: col.integracion),
        flecha(largo: 0.9cm), svc("ECS", "Envíos", color: col.contenedores)),
      fila(flecha(etiqueta: "importe ≥ 1000", largo: 1.9cm), svc("SQS", "Cola antifraude", color: col.integracion),
        flecha(largo: 0.9cm), svc("λ", "Antifraude", color: col.serverless))))
]

#cuidado[Cada cola necesita una *política de acceso* que permita `sqs:SendMessage` a `sns.amazonaws.com` con la condición `aws:SourceArn` igual al ARN del topic; si la cola se cifra con una clave KMS propia, SNS necesita además permiso para usarla. Es el fallo de configuración más habitual del fan-out.]

== Amazon EventBridge: el bus de eventos

Mientras SNS difunde mensajes a suscriptores, *EventBridge* enruta *eventos* —avisos de que algo ha pasado— según su *contenido*. Es el pegamento de las arquitecturas dirigidas por eventos en AWS: recibe eventos de tus aplicaciones, de cientos de servicios de AWS y de aplicaciones SaaS, y los entrega a los destinos cuyas reglas coinciden.

#ficha("Amazon EventBridge", "Bus de eventos serverless con enrutamiento por contenido",
  ("Tipo", [Serverless; pago por millón de eventos publicados (los de servicios de AWS en el bus por defecto son gratuitos)]),
  ("Ámbito", [Regional, con envío de eventos a otras cuentas y regiones]),
  ("Ideal para", [Arquitecturas dirigidas por eventos, reaccionar a cambios en AWS, integrar SaaS]))

/ Event bus: canal que recibe eventos. El *bus por defecto* recibe los de los servicios de AWS (una instancia que se detiene, un _job_ fallido…); creas *buses personalizados* para tus aplicaciones, y los *buses de socios* traen eventos de SaaS como Zendesk, Datadog o Shopify.
/ Regla: un *patrón* JSON que selecciona eventos por cualquier campo, con hasta 5 *destinos*: Lambda, Step Functions, SQS, SNS, Kinesis, Firehose, tareas ECS, otro bus (de otra cuenta o región) o *API destinations* (cualquier API HTTP externa, con autenticación y límite de ritmo). Un *input transformer* adapta el evento al formato del destino.
/ Entrega: al menos una vez y sin orden garantizado; si un destino falla, EventBridge reintenta hasta 24 horas y puedes asignar una DLQ a cada destino.

#diagrama(pie: [EventBridge recibe eventos de varias fuentes y cada regla los enruta, según su contenido, a sus destinos.])[
  #set text(hyphenate: false)
  #fila(espacio: 3pt,
    columna(espacio: 5pt,
      caja([Servicios de AWS], color: col.fundamentos, ancho: 2.5cm),
      caja([Tus apps (`PutEvents`)], color: col.computo, ancho: 2.5cm),
      caja([SaaS de socios], color: col.edge, ancho: 2.5cm)),
    flecha(etiqueta: "eventos", largo: 1.1cm),
    svc("EB", "Event bus", sub: "por defecto, propio o de socio", color: col.integracion),
    flecha(largo: 0.9cm),
    columna(espacio: 5pt,
      fila(caja([Regla: `PedidoCreado`], color: col.integracion, ancho: 3.6cm), flecha(largo: 0.8cm),
        caja([Step Functions], color: col.serverless, ancho: 2.7cm)),
      fila(caja([Regla: importe > 1000], color: col.integracion, ancho: 3.6cm), flecha(largo: 0.8cm),
        caja([SNS · alerta de fraude], color: col.integracion, ancho: 2.7cm)),
      fila(caja([Regla: EC2 detenida], color: col.integracion, ancho: 3.6cm), flecha(largo: 0.8cm),
        caja([Lambda · inventario], color: col.serverless, ancho: 2.7cm))))
]

Un evento tiene campos fijos (`source`, `detail-type`, `account`, `region`, `time`…) y un `detail` libre. Este patrón selecciona pedidos de España o México de más de 1000 euros que no sean de clientes internos (tus aplicaciones publican los eventos con `PutEvents`):

```json
{
  "source": ["com.acme.pedidos"],
  "detail-type": ["PedidoCreado"],
  "detail": {
    "pais": ["ES", "MX"],
    "importe": [{ "numeric": [">", 1000] }],
    "cliente": { "tipo": [{ "anything-but": "interno" }] }
  }
}
```

/ Schema registry: EventBridge puede *descubrir* la estructura de los eventos de un bus, guardarla como esquema y generar tipos para tu código (Java, Python, TypeScript, Go).
/ Archivo y replay: archiva los eventos de un bus (todos o los que cumplen un patrón) y los reproduce más tarde, para recuperarte de un fallo o probar un consumidor nuevo.
/ Pipes: integraciones *punto a punto* de un origen (SQS, Kinesis, DynamoDB Streams, MSK, Amazon MQ) a un destino, con filtrado, enriquecimiento opcional (con una Lambda, por ejemplo) y transformación, sin código de «pegamento».
/ Scheduler: el «cron» serverless: programaciones puntuales (`at(...)`), periódicas (`rate(5 minutes)`) o `cron(...)` con zona horaria que invocan Lambda, Step Functions, SQS o casi cualquier API de AWS, con reintentos y DLQ. Escala a millones (un recordatorio por usuario, por ejemplo) y sustituye a las antiguas reglas programadas. Esta lanza a diario, a las 7:00 de Madrid, una función de informes:

```bash
aws scheduler create-schedule --name informe-diario \
  --schedule-expression "cron(0 7 * * ? *)" \
  --schedule-expression-timezone "Europe/Madrid" \
  --flexible-time-window '{"Mode": "OFF"}' \
  --target '{"Arn": "arn:aws:lambda:eu-west-1:123456789012:function:informe",
             "RoleArn": "arn:aws:iam::123456789012:role/scheduler-invoca"}'
```

== Amazon Kinesis Data Streams: _streaming_ en tiempo real

Una cola entrega cada mensaje a *un* consumidor y lo borra. Un *stream* es distinto: un registro ordenado e inmutable (un _log_) que *varios* consumidores leen a la vez, cada uno a su ritmo, y que se conserva aunque ya se haya leído. Es la base de la analítica en tiempo real: clics, telemetría IoT, logs, transacciones.

#ficha("Amazon Kinesis Data Streams", "Streaming de datos en tiempo real, escalable y duradero",
  ("Tipo", [Gestionado y regional (datos en tres AZ); _on-demand_ (por GB y hora de stream) o provisionado (por shard y hora)]),
  ("Límites clave", [Por shard: escritura de 1 MB/s o 1000 registros/s y lectura de 2 MB/s; retención de 24 h (por defecto) a 365 días]))

#diagrama(pie: [La partition key decide el shard; dentro de cada shard los registros están ordenados y varios consumidores los leen.])[
  #set text(hyphenate: false)
  #fila(espacio: 4pt,
    svc("APP", "Productores", sub: "apps, IoT, logs", color: col.computo),
    flecha(etiqueta: [PutRecords +\ partition key], largo: 1.9cm),
    zona("Data stream · clics", color: col.integracion)[
      #columna(espacio: 4pt, _shard("Shard 1", 6), _shard("Shard 2", 4), _shard("Shard 3", 5))
    ],
    flecha(etiqueta: "lectura", largo: 1.1cm),
    columna(espacio: 4pt,
      caja([*Lambda* · event source mapping], color: col.serverless, ancho: 3.7cm),
      caja([*App con KCL* · progreso en DynamoDB], color: col.computo, ancho: 3.7cm),
      caja([*Firehose* → S3], color: col.integracion, ancho: 3.7cm),
      caja([*Flink* · analítica con estado], color: col.observabilidad, ancho: 3.7cm)))
]

/ Shard: la unidad de capacidad y de orden. La capacidad del stream es la suma de la de sus shards (los límites de cada uno están en la ficha).
/ Partition key: la elige el productor (un ID de usuario o de dispositivo) y su hash decide el shard. Los registros con la misma clave van al mismo shard y se leen *en orden*; una clave muy repetida crea un *shard caliente* (los errores `ProvisionedThroughputExceeded` delatan ese reparto o shards insuficientes).
/ Retención: 24 h por defecto, ampliable hasta 365 días; puedes *releer* el pasado para reprocesar tras un bug o alimentar un consumidor nuevo.
/ Consumidores: Lambda, aplicaciones con la *Kinesis Client Library* (KCL, que reparte shards entre instancias y guarda el progreso en DynamoDB), Firehose o Flink. Por defecto comparten los 2 MB/s de lectura de cada shard; con *enhanced fan-out*, cada consumidor registrado recibe sus propios 2 MB/s por shard, empujados por HTTP/2 y con menor latencia.
/ Capacidad: en modo *on-demand* escala solo y pagas por GB escrito y leído, más una tarifa por hora de stream (ideal si el tráfico es impredecible); en modo *provisionado* fijas los shards (y los divides o fusionas para reajustar) y pagas por shard y hora.

== Firehose, Flink, MSK y Amazon MQ

#tarjetas(columnas: 2,
  tarjeta("Amazon Data Firehose", subtitulo: "Antes Kinesis Data Firehose")[Entrega datos en streaming *sin gestionar capacidad* a S3, Redshift, OpenSearch, Splunk, Snowflake, tablas Apache Iceberg o endpoints HTTP. Agrupa por tamaño o tiempo (casi tiempo real), transforma con Lambda, convierte a Parquet y comprime; se paga por GB. La forma más sencilla de llevar logs y eventos a un _data lake_.],
  tarjeta("Managed Service for Apache Flink", color: col.observabilidad, subtitulo: "Antes Kinesis Data Analytics")[Ejecuta aplicaciones Apache Flink (Java, Python o SQL) que procesan streams *con estado*: ventanas temporales, agregaciones, _joins_ y detección de anomalías sobre datos de Kinesis o MSK.],
  tarjeta("Amazon MSK", color: col.datos, subtitulo: "Apache Kafka gestionado")[Clústeres Kafka provisionados (con _brokers_ Standard o Express) o MSK Serverless, y MSK Connect para conectores. Elígelo si ya usas Kafka o necesitas su ecosistema, retenciones largas y relectura por _offset_.],
  tarjeta("Amazon MQ", color: col.neutro, subtitulo: "ActiveMQ y RabbitMQ gestionados")[_Brokers_ con protocolos estándar (JMS, AMQP, MQTT, STOMP, OpenWire) para *migrar* aplicaciones que ya los usan sin reescribirlas. Para desarrollos nuevos, SQS y SNS escalan mejor y no hay _brokers_ que dimensionar.],
)

== ¿Qué servicio elijo?

#tabla(("Servicio", "Modelo", "¿Quién recibe cada mensaje?", "Orden", "Retención y relectura", "Ideal para"),
  columnas: (1fr, 1fr, 1.25fr, 0.9fr, 1.25fr, 1.4fr), tamano: 7.8pt,
  [*SQS*], [Cola (_pull_)], [Un consumidor], [Solo FIFO], [Hasta 14 días; sin relectura], [Colas de trabajo, amortiguar picos],
  [*SNS*], [Pub/sub (_push_)], [Todos los suscriptores], [Solo FIFO], [No guarda (salvo archivo en FIFO)], [_Fan-out_, notificaciones],
  [*EventBridge*], [Bus con reglas (_push_)], [Los destinos de cada regla que coincide], [No], [Archivo y _replay_ opcionales], [Integrar servicios, SaaS y eventos de AWS],
  [*Kinesis Data Streams*], [Stream (_pull_)], [Todos, cada uno a su ritmo], [Por shard], [De 24 h a 365 días; relectura], [Telemetría, clics, analítica en tiempo real],
  [*Amazon MSK*], [Stream Kafka], [Todos los grupos de consumidores], [Por partición], [Configurable; relectura por _offset_], [Plataformas y ecosistema Kafka],
)

== Patrones de integración

Ya conoces dos patrones básicos: la *cola de trabajo*, en la que varios consumidores idénticos compiten por los mensajes de una cola (_competing consumers_) y escalas añadiendo consumidores, y el _fan-out_. Sobre ellos se construyen los demás. El primer dilema es quién dirige el flujo:

#block(breakable: false)[#tarjetas(
  tarjeta("Coreografía", subtitulo: "EventBridge, SNS")[Cada servicio reacciona a eventos y publica los suyos; nadie dirige. Muy desacoplado y fácil de ampliar, pero el flujo completo es difícil de ver y depurar.],
  tarjeta("Orquestación", color: col.serverless, subtitulo: "Step Functions")[Un coordinador central llama a cada paso y decide el siguiente, con reintentos y compensaciones explícitos. El flujo es visible y auditable, a costa de que el orquestador conozca a todos.],
)]

En la práctica se combinan: orquestación *dentro* de un dominio (el proceso de un pedido) y coreografía *entre* dominios (Pedidos publica `PedidoConfirmado` y Envíos reacciona).

/ Saga: una transacción de negocio repartida entre servicios sin transacción distribuida: cada paso tiene una *acción compensatoria* (reembolsar el cobro, liberar el stock) que se ejecuta si un paso posterior falla. Step Functions, con `Catch`, es la forma natural de orquestarla.
/ Transactional outbox: si un servicio guarda en su base de datos *y* publica un evento, un fallo entre ambas operaciones pierde o inventa eventos. La solución: escribir el evento en una tabla _outbox_ en la *misma transacción* y que otro proceso lo publique. En AWS es habitual usar DynamoDB Streams (o la captura de cambios de la base de datos) con EventBridge Pipes como relé.
/ Idempotencia: casi toda la mensajería de AWS entrega *al menos una vez*, así que los consumidores deben tolerar duplicados: registra una *clave de idempotencia* (el ID del mensaje o del pedido) con una escritura condicional y descarta lo ya procesado. La deduplicación de SQS FIFO solo cubre 5 minutos; Powertools for AWS Lambda lo resuelve con DynamoDB.

#diagrama(pie: [Outbox con DynamoDB: el pedido y su evento se guardan juntos; el stream de la tabla y Pipes publican el evento.])[
  #set text(hyphenate: false)
  #fila(espacio: 3pt,
    svc("API", "Servicio Pedidos", color: col.computo),
    flecha(etiqueta: [1 · una sola\ transacción], largo: 1.7cm),
    zona("Tabla DynamoDB", color: col.datos)[
      #columna(espacio: 3pt, caja([Ítem *pedido* p-42], color: col.datos, ancho: 2.8cm),
        caja([Ítem *outbox* · PedidoCreado], color: col.datos, ancho: 2.8cm))
    ],
    flecha(etiqueta: "2 · Streams", largo: 1.4cm),
    svc("PIPE", "EventBridge Pipes", sub: "relé", color: col.integracion),
    flecha(etiqueta: "3 · publica", largo: 1.3cm),
    svc("EB", "Event bus", color: col.integracion))
]

#block(breakable: false)[#resumen[
- Desacoplar con mensajería asíncrona da resiliencia, absorbe picos y permite escalar y evolucionar cada parte; a cambio exige tolerar duplicados y consistencia eventual.
- *SQS* es una cola _pull_: Standard (al menos una vez, rendimiento casi ilimitado) o FIFO (orden por _message group_ y exactamente una vez).
- Un mensaje recibido queda invisible durante el *visibility timeout*; si no se borra, reaparece y, tras `maxReceiveCount`, va a la *DLQ*.
- Usa long polling, lotes y, con Lambda, respuestas parciales de lote; el tamaño máximo de mensaje es 1 MiB.
- *SNS* empuja cada publicación a todos sus suscriptores, con filtros por suscripción; *SNS + SQS* es el patrón _fan-out_.
- *EventBridge* enruta eventos por contenido con reglas y patrones JSON; añade schema registry, archivo y _replay_, Pipes y Scheduler.
- *Kinesis Data Streams* es un log ordenado por shard que leen varios consumidores, con relectura de hasta 365 días; Firehose entrega a destinos, Flink procesa con estado, y MSK (Kafka) y Amazon MQ (ActiveMQ, RabbitMQ) cubren ecosistemas y migraciones existentes.
- Patrones clave: cola de trabajo, _fan-out_, coreografía frente a orquestación, saga, _outbox_ e idempotencia.
]]

#repaso(
  ([Un consumidor tarda unos 2 minutos por mensaje y los mensajes se procesan dos veces. ¿Qué ajustas?], [El visibility timeout, por encima de 2 minutos (o ampliado con `ChangeMessageVisibility` durante el proceso); además, consumidor idempotente.]),
  ([Necesitas procesar en orden los eventos de cada cliente, pero en paralelo entre clientes. ¿Cómo?], [Cola SQS FIFO con el ID de cliente como `MessageGroupId`.]),
  ([¿Qué ventaja tiene SNS + SQS frente a suscribir varias Lambda directamente al topic?], [Cada consumidor tiene su cola: absorbe picos, procesa a su ritmo, reintenta y tiene su DLQ sin afectar a los demás.]),
  ([Quieres reaccionar cuando cualquier instancia EC2 de la cuenta se detenga. ¿Qué servicio usas?], [Una regla de EventBridge en el bus por defecto con un patrón sobre el evento de cambio de estado de EC2.]),
  ([Una función que lee de SQS falla con un mensaje de cada lote de 10 y se reprocesan los 10. ¿Solución?], [Activar `ReportBatchItemFailures` y devolver en `batchItemFailures` solo los mensajes fallidos.]),
  ([Tres equipos deben leer el mismo flujo de clics y poder reprocesar la última semana. ¿SQS o Kinesis?], [Kinesis Data Streams con retención de al menos 7 días: varios consumidores leen los mismos datos y pueden releerlos.]),
  ([¿Qué problema resuelve el patrón _transactional outbox_?], [La inconsistencia entre guardar en la base de datos y publicar el evento: ambos se escriben en la misma transacción y un relé publica después.]),
)
