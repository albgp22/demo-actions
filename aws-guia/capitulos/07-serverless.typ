#import "../theme.typ": *

// Sin ligaduras en el código (para que `:::` o `->` se lean tal cual)
#show raw: set text(features: (calt: 0))

// ---------------------------------------------------------------------
//  Utilidades locales para los diagramas de este capítulo
// ---------------------------------------------------------------------

#let _fase(color, titulo, sub: none, letra: white) = box(
  width: 100%, height: 1.2cm, fill: color, radius: 3pt, inset: (x: 2pt, y: 3pt),
  align(center + horizon, {
    set par(justify: false, leading: 0.35em)
    text(6.8pt, weight: "bold", fill: letra, titulo)
    if sub != none { linebreak(); text(5.9pt, fill: letra, sub) }
  }),
)

#let _llave(color, etiqueta, abajo: false) = {
  let lados = if abajo { (bottom: 1pt + color, left: 1pt + color, right: 1pt + color) } else {
    (top: 1pt + color, left: 1pt + color, right: 1pt + color)
  }
  let marca = box(width: 100%, height: 5pt, stroke: lados)
  let rotulo = align(center, {
    set par(justify: false)
    text(6.3pt, weight: "bold", fill: color, etiqueta)
  })
  if abajo { stack(dir: ttb, spacing: 3pt, marca, rotulo) } else { stack(dir: ttb, spacing: 3pt, rotulo, marca) }
}

#let _estado(tipo, nombre, color: col.serverless, ancho: 3.1cm) = box(
  width: ancho, fill: white, stroke: 1pt + color, radius: 5pt, inset: (x: 4pt, y: 4pt),
  align(center, {
    set par(justify: false, leading: 0.35em)
    text(5.8pt, weight: "bold", fill: color.darken(10%), tracking: 0.4pt, upper(tipo))
    linebreak()
    text(7.1pt, weight: "semibold", fill: tinta, nombre)
  }),
)

#let _terminal(texto, color: col.neutro) = box(
  fill: color, radius: 8pt, inset: (x: 9pt, y: 3.5pt),
  text(6.6pt, weight: "bold", fill: white, texto),
)

// ---------------------------------------------------------------------
#capitulo("Serverless: Lambda, API Gateway y Step Functions", color: col.serverless,
  subtitulo: [Ejecuta código, publica tus API y orquesta procesos sin aprovisionar ni administrar un solo servidor.],
  objetivos: (
    [Qué significa realmente _serverless_ y cuándo encaja],
    [Cómo ejecuta Lambda tu código: entorno, _cold starts_ y concurrencia],
    [Los modos de invocación y cómo se gestionan los errores],
    [Permisos, VPC, secretos, versiones y _aliases_],
    [Publicar API con API Gateway: tipos, autorización y límites],
    [Orquestar flujos con Step Functions y desplegar con SAM],
  ),
  servicios: ("AWS Lambda", "Amazon API Gateway", "AWS Step Functions", "AWS SAM"))

== ¿Qué significa serverless?

_Serverless_ («sin servidor») no significa que no haya servidores: significa que *no son asunto tuyo*. AWS los aprovisiona, parchea, escala y reemplaza; tú entregas código o configuración y pagas por el uso real. Un servicio es serverless cuando reúne cuatro rasgos:

#tarjetas(columnas: 4,
  tarjeta("Sin servidores")[Ni sistema operativo que parchear ni capacidad que dimensionar.],
  tarjeta("Escala sola")[De cero a miles de peticiones por segundo, y de vuelta a cero.],
  tarjeta("Pago por uso")[Por petición, por milisegundo o por GB, no por horas encendido.],
  tarjeta("Alta disponibilidad")[Repartido entre varias AZ de serie, sin configurar nada.],
)

El ecosistema va más allá de Lambda: API Gateway, Step Functions, S3, DynamoDB, SQS, SNS, EventBridge, Fargate o Aurora Serverless v2 comparten esta filosofía, y combinándolos construyes aplicaciones completas sin una sola instancia EC2. A cambio aceptas límites (duración, tamaño de los mensajes), latencias de arranque ocasionales, una arquitectura distribuida más difícil de depurar y un coste que, con carga alta y constante, puede superar al de instancias o contenedores.

#analogia[Tener servidores es como tener coche: pagas compra, seguro y garaje aunque lo uses una hora al día. Serverless es un taxi: pagas por trayecto, no te ocupas del mantenimiento y, si mañana necesitas diez, aparecen diez; eso sí, no eliges el motor.]

== AWS Lambda: funciones bajo demanda

Lambda ejecuta tu código en respuesta a eventos —una petición HTTP, un fichero que llega a S3, un mensaje en una cola, una hora programada—. Subes una *función* (código y configuración), defines qué la dispara y Lambda crea entornos de ejecución aislados, escala con la demanda y te factura por milisegundo.

#ficha("AWS Lambda", "Cómputo serverless dirigido por eventos",
  ("Tipo", [Serverless; pago por petición y por duración (GB-segundo, al milisegundo)]),
  ("Ámbito", [Regional; Lambda reparte los entornos entre varias AZ]),
  ("Ideal para", [API, procesamiento de eventos y ficheros, tareas programadas, «pegamento» entre servicios]),
  ("Límites clave", [15 min por invocación; de 128 MB a 10~240 MB de memoria; _payload_ síncrono de 6 MB; 1000 ejecuciones concurrentes por región por defecto (ampliable)]))

=== El modelo de ejecución: eventos y handler

Toda función tiene un *handler*, el punto de entrada que Lambda llama en cada invocación con dos argumentos: el *evento* (un JSON cuya forma depende del origen) y el *contexto* (metadatos como el identificador de la petición o el tiempo restante). Lo que devuelve el handler es la respuesta.

```python
import json, os
from decimal import Decimal
import boto3

# Fase Init: se ejecuta una vez por entorno y se reutiliza después
tabla = boto3.resource("dynamodb").Table(os.environ["TABLA_PEDIDOS"])

def lambda_handler(event, context):
    """Crea un pedido a partir de una petición de API Gateway."""
    pedido = json.loads(event["body"], parse_float=Decimal)
    tabla.put_item(Item={"id": pedido["id"], "importe": pedido["importe"]})
    return {"statusCode": 201,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"id": pedido["id"]})}
```

El cliente de DynamoDB se crea *fuera* del handler: ese código se ejecuta una sola vez, al preparar el entorno de ejecución (lo verás enseguida), y se reutiliza en las invocaciones siguientes. Es la optimización más sencilla y rentable de Lambda.

=== Runtimes, paquetes y recursos

Hay *runtimes gestionados* para Node.js, Python, Java, .NET y Ruby, y *runtimes de solo sistema operativo* (`provided.al2023`) para Go, Rust o runtimes propios. AWS los parchea y los retira según un calendario publicado. El código se empaqueta como *.zip* (hasta 50 MB comprimido en subida directa y 250 MB descomprimido) o como *imagen de contenedor* de hasta 10 GB alojada en ECR. Puedes elegir `x86_64` o `arm64` (Graviton), con un precio por GB-segundo en torno a un 20 % menor.

Lambda tiene un solo mando de potencia: la *memoria*, de 128 MB a 10~240 MB. La CPU y la red crecen *en proporción*: con 1769 MB tienes el equivalente a una vCPU y con el máximo, 6 vCPU. Por eso subir la memoria acelera a menudo funciones que ni usan esa RAM y, como terminan antes, pueden salir igual de baratas (la herramienta de código abierto *Lambda Power Tuning* te dibuja la curva coste-velocidad).

/ Timeout: de 1 s a 900 s; 3 s por defecto. Ajústalo a lo esperado más un margen, no al máximo.
/ `/tmp`: almacenamiento efímero de 512 MB (incluido) a 10~240 MB. Sobrevive entre invocaciones *del mismo entorno* —sirve de caché—, nunca entre entornos.

=== Ciclo de vida del entorno de ejecución

Cada invocación se ejecuta en un *entorno de ejecución*: una microVM Firecracker aislada con tu runtime y tu código.

#diagrama(pie: [Vida de un entorno de ejecución: una fase Init, muchas invocaciones y un apagado final.])[
  #set text(hyphenate: false)
  #let ini = col.serverless
  #let inv = col.datos
  #let congelado = gris-claro
  #grid(
    columns: (1.85cm, 1.6cm, 2.05cm, 1.95cm, 1.65cm, 1.95cm, 1.65cm, 1.85cm),
    column-gutter: 2pt, row-gutter: 4pt,
    grid.cell(colspan: 4, _llave(col.iam, "COLD START · entorno nuevo")), [],
    _llave(col.almacenamiento, "WARM START"), [], [],
    _fase(ini.lighten(25%), "Extensiones", sub: "se inician"),
    _fase(ini.lighten(10%), "Runtime", sub: "Python, Java…"),
    _fase(ini.darken(10%), "Tu código Init", sub: "fuera del handler"),
    _fase(inv, "Invoke 1", sub: "handler"),
    _fase(congelado, "Congelado", sub: "en espera", letra: gris.darken(25%)),
    _fase(inv, "Invoke 2", sub: "reutiliza Init"),
    _fase(congelado, "Congelado", sub: "en espera", letra: gris.darken(25%)),
    _fase(col.neutro, "Shutdown", sub: "fin del entorno"),
    grid.cell(colspan: 3, _llave(ini.darken(15%), "INIT · una vez por entorno", abajo: true)),
    _llave(inv.darken(10%), "INVOKE", abajo: true), [],
    _llave(inv.darken(10%), "INVOKE", abajo: true), [],
    _llave(col.neutro, "SHUTDOWN", abajo: true),
  )
]

/ Init: descarga el código, arranca extensiones y runtime y ejecuta tu inicialización (lo que está fuera del handler). En funciones bajo demanda dispone de hasta 10 s.
/ Invoke: ejecuta el handler; al terminar, el entorno se *congela* y queda listo para otra invocación (_warm start_).
/ Shutdown: tras un tiempo sin uso, o periódicamente para aplicar actualizaciones, Lambda destruye el entorno.

Un *cold start* es la latencia extra de una invocación que necesita un entorno nuevo: la primera, cada invocación *concurrente* adicional al escalar y las que llegan tras un periodo de inactividad. Va de decenas de milisegundos en funciones pequeñas de Python o Node.js a varios segundos en Java o imágenes grandes; según AWS, en cargas reales afecta a menos del 1 % de las invocaciones. Y no solo cuesta tiempo: desde agosto de 2025, AWS factura la fase Init en todas las configuraciones (antes era gratuita en las funciones .zip con runtimes gestionados).

#tarjetas(
  tarjeta("SnapStart", subtitulo: "Java, Python y .NET")[
    Al *publicar una versión*, Lambda ejecuta Init y guarda una instantánea cifrada de la microVM; los entornos nuevos se *restauran* desde ella. Gratis en Java; en Python y .NET se cobran caché y restauraciones. Ojo: lo que debería ser único (aleatorios, conexiones) se repite en cada entorno restaurado; regenéralo con _runtime hooks_.
  ],
  tarjeta("Concurrencia aprovisionada", color: col.datos, subtitulo: "Cualquier runtime")[
    Mantiene N entornos *ya inicializados*: cero cold starts dentro de ese margen. Se configura sobre una versión o un alias y se paga mientras está activa, haya tráfico o no. Se puede escalar con Application Auto Scaling, por ejemplo con una programación para las horas punta.
  ],
)

=== Concurrencia: cuánto escala una función

La *concurrencia* es el número de invocaciones simultáneas, es decir, de entornos ocupados: aproximadamente peticiones por segundo × duración media. Así, 200 peticiones/s de 0,5 s necesitan unos 100 entornos.

/ Cuota regional: 1000 ejecuciones concurrentes por cuenta y región, compartidas por *todas* las funciones; es ampliable (y algunas cuentas nuevas empiezan con menos). Al agotarse hay _throttling_ (Lambda rechaza las invocaciones que no caben): error 429 en las síncronas; las asíncronas y los event source mappings reintentan. Cada función puede sumar hasta 1000 entornos cada 10 segundos.
/ Concurrencia reservada: aparta parte de la cuota para una función. Le *garantiza* capacidad y a la vez la *limita* (útil para proteger una base de datos). Sin coste. Reservar 0 detiene la función: un interruptor de emergencia.

== Cómo se invoca una función

Hay tres formas de llegar a una función, y en cada una cambia quién espera la respuesta y quién reintenta si algo falla.

/ Síncrona: el llamante espera (`aws lambda invoke` lo hace por defecto); los errores le llegan a él y es él quien reintenta.
/ Asíncrona: Lambda encola el evento, responde al instante y lo procesa después; así invocan S3, SNS, EventBridge o EventBridge Scheduler, que lanza funciones a horas fijas (capítulo de Mensajería e integración). Si la función falla, Lambda reintenta dos veces más con esperas crecientes (configurable) y descarta el evento cuando supera su antigüedad máxima (hasta 6 h). Para no perderlo, configura un *destino* de fallo —SQS, SNS, EventBridge, S3 u otra función—, que recibe el evento y el error, o una *dead-letter queue* (DLQ) clásica: una cola SQS o un topic SNS que aparta los eventos fallidos, sin el error. Como la entrega es «al menos una vez», haz tus funciones *idempotentes*: que procesar dos veces el mismo evento no cambie el resultado.
/ Event source mapping: con SQS, Kinesis, DynamoDB Streams, Kafka o Amazon MQ, Lambda lee lotes y llama a tu función de forma síncrona. La función necesita permiso para leer del origen, y puedes *filtrar* eventos para no pagar invocaciones inútiles.

#diagrama(pie: [Los tres modos de invocación de Lambda.])[
  #set text(hyphenate: false)
  #let lam = svc("λ", "Tu función", color: col.serverless)
  #zona("Síncrona · el llamante espera la respuesta y decide si reintenta", color: col.datos, ancho: 100%)[
    #fila(actor(etiqueta: "Cliente"), flecha(etiqueta: "HTTPS", largo: 1.3cm),
      svc("API", "API Gateway", sub: [o ALB, SDK,\ function URL], color: col.serverless),
      flecha(etiqueta: "invoca y espera", largo: 2.3cm, doble: true), lam)
  ]
  #v(4pt)
  #zona("Asíncrona · Lambda encola el evento, responde 202 y reintenta", color: col.integracion, ancho: 100%)[
    #fila(svc("S3", [S3, SNS,\ EventBridge…], color: col.almacenamiento), flecha(etiqueta: "evento", largo: 1.1cm),
      caja([Cola interna\ de Lambda], color: col.integracion), flecha(largo: 0.9cm), lam,
      flecha(etiqueta: "éxito / fallo", largo: 1.5cm),
      svc("DEST", "Destino", sub: [SQS · SNS ·\ EventBridge · λ], color: col.integracion))
  ]
  #v(4pt)
  #zona("Event source mapping · Lambda sondea el origen y procesa lotes", color: col.computo, ancho: 100%)[
    #fila(svc("SQS", "Cola o stream", sub: [SQS · Kinesis ·\ DynamoDB Streams], color: col.integracion),
      flecha(etiqueta: "sondeo", largo: 1.3cm),
      caja([Event source mapping\ (sondeador gestionado)], color: col.computo),
      flecha(etiqueta: "lote", largo: 1.2cm), lam)
  ]
]

El comportamiento depende del origen (colas y _streams_ se explican a fondo en el capítulo de Mensajería e integración). Con *SQS*, Lambda añade sondeadores a medida que crece la cola y, si un lote falla, sus mensajes vuelven a la cola y se reintentan; tras varios fallos, acaban en su DLQ. Un stream de *Kinesis* o de *DynamoDB Streams* se divide en _shards_ (particiones ordenadas): Lambda procesa un lote por shard a la vez (hasta 10 con el _parallelization factor_) y respeta el orden, así que un lote que falla *bloquea el shard* hasta que tiene éxito o caduca. Para evitarlo, puedes partir en dos el lote que falla y enviar los registros fallidos a un destino.

== Permisos, red y configuración

Los permisos de una función van en dos direcciones, y confundirlas es un error clásico:

#tarjetas(
  tarjeta("Execution role", color: col.iam, subtitulo: "¿Qué puede hacer la función?")[
    Rol IAM que Lambda asume al ejecutar tu código: escribir logs (`AWSLambdaBasicExecutionRole`) y lo que haga tu código, como leer de DynamoDB o de una cola.
  ],
  tarjeta("Resource-based policy", color: col.iam, subtitulo: "¿Quién puede invocarla?")[
    La política de recurso de la función: permite invocarla a servicios (S3, SNS, API Gateway…) o a otras cuentas. La consola la crea al añadir un disparador.
  ],
)

```bash
aws lambda add-permission --function-name procesar-foto \
  --statement-id s3-invoca --action lambda:InvokeFunction \
  --principal s3.amazonaws.com --source-arn arn:aws:s3:::mis-fotos \
  --source-account 123456789012   # restringe el origen: evita el confused deputy
```

Cómo se combinan estas políticas con las de identidad lo explica el capítulo «IAM (II): permisos — políticas y evaluación».

*Lambda en una VPC.* Por defecto, una función llega a Internet y a los endpoints públicos de AWS, pero no a recursos privados como una base de datos RDS. Para alcanzarlos la asocias a subredes y Security Groups; Lambda crea interfaces de red (*Hyperplane ENIs*) compartidas por las funciones con la misma combinación, de modo que conectarla a una VPC ya no alarga apreciablemente los cold starts.

#cuidado[Una función conectada a una VPC *pierde el acceso a Internet*, incluso en una subred pública: sus ENI nunca tienen IP pública. Necesitas subredes privadas con ruta a un NAT Gateway o, para S3, DynamoDB o Secrets Manager, VPC endpoints (capítulo de Redes).]

*Configuración y secretos.* Las *variables de entorno* (hasta 4 KB) separan configuración y código; se cifran con KMS, pero quien lea la configuración las ve en claro, así que *no son sitio para secretos*: usa Secrets Manager o Parameter Store (capítulo «Seguridad: cifrado con KMS, secretos y protección») con la extensión *AWS Parameters and Secrets Lambda Extension*, que los cachea.

*Layers.* Un _layer_ es un .zip con bibliotecas, un runtime o datos que se monta en `/opt` y se comparte entre funciones; cada función admite hasta 5, dentro de los 250 MB descomprimidos (con imágenes de contenedor todo va en la imagen).

== Versiones, aliases y function URLs

Mientras desarrollas editas `$LATEST`, la versión mutable. Al *publicar una versión*, Lambda congela código y configuración en una versión numerada e inmutable (`:5`, `:6`…) con su propio ARN. Un *alias* (`prod`, `staging`) es un puntero a una versión: los clientes apuntan al alias, y promocionar o volver atrás es mover el puntero. Un alias también puede repartir el tráfico entre *dos versiones* con pesos: la base de los despliegues *canary*.

```bash
aws lambda update-alias --function-name crear-pedido --name prod \
  --function-version 5 --routing-config 'AdditionalVersionWeights={"6"=0.1}'
```

En la práctica, SAM o CodeDeploy desplazan el tráfico gradualmente (`Canary10Percent5Minutes`, `Linear10PercentEvery1Minute`…) y vuelven atrás solos si salta una alarma.

#diagrama(pie: [Despliegue canary con un alias ponderado: el 10 % del tráfico prueba la versión nueva.])[
  #set text(hyphenate: false)
  #fila(svc("API", "API Gateway", sub: "invoca …:prod", color: col.serverless), flecha(largo: 1.1cm),
    caja([*Alias* `prod`], color: col.serverless, ancho: 2cm),
    columna(espacio: 0pt,
      fila(flecha(etiqueta: "90 %", largo: 1.5cm), caja([*Versión 5* · estable], color: col.neutro, ancho: 3cm)),
      fila(flecha(etiqueta: "10 %", largo: 1.5cm), caja([*Versión 6* · canary], color: col.serverless, ancho: 3cm))),
    flecha(etiqueta: "errores", largo: 1.3cm, punteada: true),
    svc("CW", "Alarma", sub: "CloudWatch · rollback", color: col.observabilidad))
]

Para exponer una función por HTTPS sin más, una *function URL* da un endpoint dedicado (`https://<id>.lambda-url.<región>.on.aws`) con autenticación `AWS_IAM` o `NONE`, CORS y _response streaming_. No ofrece throttling por cliente, API keys, caché ni dominio propio: para eso, CloudFront delante (que firma las peticiones con OAC) o API Gateway.

== Buenas prácticas con Lambda

- *Inicializa fuera del handler* clientes, conexiones y configuración; con bases de datos relacionales, usa RDS Proxy para no agotar conexiones al escalar.
- *Hazla idempotente*: un identificador por operación y una escritura condicional (por ejemplo, en DynamoDB) evitan cobrar dos veces un pedido.
- *Una función, una responsabilidad*, con pocas dependencias: paquetes pequeños, cold starts cortos.
- *Evita bucles recursivos* (escribir en el bucket o la cola que te dispara); Lambda detecta y corta algunos, no todos.
- *No orquestes desde el código* encadenando funciones que se esperan: para eso está Step Functions (o, desde finales de 2025, las *durable functions* de Lambda, que guardan su progreso en _checkpoints_ y esperan sin consumir cómputo).
- *Observa*: Lambda envía la salida estándar a CloudWatch Logs, con formato JSON y niveles nativos (capítulo de Observabilidad).
- *Apóyate en Powertools for AWS Lambda*, biblioteca de código abierto de AWS (Python, TypeScript, Java y .NET) que aplica estas prácticas en pocas líneas: logs JSON, trazas de X-Ray, métricas, idempotencia sobre DynamoDB, respuestas parciales de lote y secretos con caché.

#coste[Pagas por petición (del orden de 0,20 USD por millón) y por GB-segundo, más extras como la concurrencia aprovisionada; la capa gratuita incluye un millón de peticiones al mes. Lambda es imbatible con tráfico bajo o irregular; con carga alta y constante, compara con Fargate o EC2 (los Compute Savings Plans también cubren Lambda) o con *Lambda Managed Instances* (finales de 2025), que ejecuta tus funciones sobre instancias EC2 gestionadas por Lambda.]

== Amazon API Gateway

API Gateway es la puerta de entrada gestionada de tus API: recibe peticiones HTTP o WebSocket, las autentica, aplica límites y las enruta a un _backend_ —Lambda, un servicio HTTP u otro servicio de AWS—. Escala solo y se paga por petición.

#ficha("Amazon API Gateway", "API REST, HTTP y WebSocket totalmente gestionadas",
  ("Tipo", [Serverless; pago por millón de peticiones (mensajes y minutos de conexión en WebSocket)]),
  ("Ámbito", [Regional; las REST API también pueden ser _edge-optimized_ (vía CloudFront) o privadas]),
  ("Límites clave", [Payload de 10 MB; 10~000 peticiones/s por cuenta y región (ampliable); el backend debe responder en 29 s (REST; ampliable en API regionales y privadas desde 2024) o 30 s (HTTP API): para trabajos largos, responde un 202 y procesa de forma asíncrona]))

#tabla(("Característica", "REST API", "HTTP API", "WebSocket API"), columnas: (1.35fr, 1.25fr, 1.25fr, 1.15fr), tamano: 8.2pt,
  [Modelo y precio], [Petición-respuesta; la más cara], [Petición-respuesta; más barata y rápida], [Conexión persistente bidireccional],
  [Endpoints], [Edge-optimized, regional, privado], [Regional], [Regional],
  [Autorización], [IAM, Cognito, Lambda, políticas de recurso], [IAM, JWT (OIDC/OAuth 2.0), Lambda], [IAM, Lambda en `$connect`],
  [Caché y AWS WAF], si, no, no,
)

Empieza por *HTTP API*, la opción por defecto si solo enrutas a Lambda o a un servicio HTTP con JWT o IAM. Elige *REST API* si necesitas API keys, caché, WAF, validación, endpoints privados o transformar peticiones, y *WebSocket* para chats, notificaciones o paneles en tiempo real.

*Stages.* Una API se compone de *rutas* (`POST /pedidos`), cada una con su integración, y se despliega en *stages* (`dev`, `prod`) con su propia URL, límites, logs y *stage variables* (por ejemplo, a qué alias de Lambda apuntar). En REST cada cambio exige un despliegue explícito y los stages admiten canary; las HTTP API pueden desplegarse solas. Un *dominio personalizado* con certificado de ACM publica `api.miempresa.com`.

/ Integraciones: *Lambda proxy* (pasa la petición completa como evento y la función devuelve `statusCode`, `headers` y `body`; la más común), *HTTP* (cualquier endpoint, y servicios privados de tu VPC a través de un *VPC Link*), *servicios AWS* (llama directamente a `SendMessage` de SQS, `PutItem` de DynamoDB o `StartExecution` de Step Functions, sin Lambda intermedia) y *mock*.
/ Autorización: *IAM* (peticiones firmadas con SigV4, ideal entre servicios); *Cognito* (REST), cuyos _user pools_ registran e identifican a los usuarios de tu aplicación (capítulo «IAM (I): identidades — usuarios, grupos, roles y permission sets»), o *JWT authorizer* (HTTP API), que valida los _JSON Web Tokens_ de cualquier proveedor OIDC (Cognito, Auth0, Okta, Entra ID…); *Lambda authorizer*, tu función decide y su resultado se cachea (300 s por defecto, hasta 1 h); y *políticas de recurso* (REST) por cuenta, IP o VPC endpoint. La combinación típica (Cognito, JWT, Lambda y DynamoDB) se monta paso a paso en el capítulo de Arquitecturas de referencia.
/ Throttling: _token bucket_ de 10~000 peticiones/s con ráfagas de 5000 por cuenta y región, más límites por stage y método; el exceso recibe *429 Too Many Requests*. En REST, los *usage plans* asocian *API keys* a límites y cuotas por cliente (por ejemplo, 1000 peticiones al día en el plan gratuito).
/ Caché (REST): por stage, de 0,5 GB a 237 GB, TTL de 300 s por defecto (máx. 3600 s); se paga por hora, se use o no.
/ CORS: si `app.ejemplo.com` llama a una API de otro dominio, el navegador exige cabeceras `Access-Control-Allow-*` y a menudo un `OPTIONS` previo. Las HTTP API traen CORS integrado; en REST con proxy, *tu función* debe devolver las cabeceras.

#cuidado[Las API keys *identifican* a un cliente para aplicarle un plan, pero *no autentican*: cualquiera que vea la clave puede usarla. Combínalas con IAM, Cognito o un Lambda authorizer.]

== AWS Step Functions

Encadenar funciones que se llaman entre sí produce código frágil: ¿quién reintenta?, ¿qué pasa si falla el tercer paso?, ¿dónde se ve el estado? *Step Functions* lo resuelve con *máquinas de estado*: defines el flujo de forma declarativa en *Amazon States Language (ASL)*, un JSON —o lo dibujas en *Workflow Studio*—, y el servicio lo ejecuta, guarda el estado de cada ejecución y gestiona reintentos y errores.

#ficha("AWS Step Functions", "Orquestación serverless de flujos de trabajo",
  ("Tipo", [Serverless; Standard por transición de estado, Express por ejecución y duración]),
  ("Ideal para", [Procesos de negocio, ETL, microservicios, aprobaciones humanas, proceso masivo en paralelo]))

#block(breakable: false)[#tabla(("", "Standard", "Express"), columnas: (1.1fr, 1.5fr, 1.5fr), tamano: 8.2pt,
  [Duración máxima], [1 año], [5 minutos],
  [Semántica], [Exactamente una vez], [Al menos una vez (asíncrona) o como máximo una vez (síncrona)],
  [Precio e historial], [Por transición; historial de 90 días en la consola], [Por ejecución, duración y memoria; historial en CloudWatch Logs],
  [Esperar trabajos y _callbacks_], si, no,
  [Casos típicos], [Procesos largos, aprobaciones, ETL], [Eventos de alto volumen (más de 100~000 ejecuciones/s)],
)]


/ Task: hace el trabajo: invoca una Lambda, llama a un servicio de AWS o a una API HTTPS, o espera un _callback_.
/ Choice, Parallel, Map: bifurcan según los datos, ejecutan ramas en paralelo o recorren una lista; el Map *distribuido* procesa millones de objetos de S3 con hasta 10~000 ejecuciones hijas a la vez.
/ Wait, Pass, Succeed, Fail: esperan (sin pagar cómputo), transforman datos o terminan.

Cada Task, Parallel o Map puede declarar *Retry* (qué errores reintentar, cuántas veces y con qué _backoff_) y *Catch* (a qué estado saltar al agotar los reintentos). Los errores se identifican por nombre: los tuyos o predefinidos como `States.Timeout`, `States.TaskFailed` o el comodín `States.ALL`.

#grid(columns: (1.12fr, 1fr), column-gutter: 10pt,
  [
    #show raw.line: set text(size: 7.2pt)
    ```json
    "Cobrar": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "cobrar-pedido",
        "Payload.$": "$"
      },
      "OutputPath": "$.Payload",
      "Retry": [{
        "ErrorEquals": ["States.TaskFailed"],
        "IntervalSeconds": 2,
        "MaxAttempts": 3,
        "BackoffRate": 2
      }],
      "Catch": [{
        "ErrorEquals": ["States.ALL"],
        "ResultPath": "$.error",
        "Next": "NotificarFallo"
      }],
      "Next": "EnviarPedido"
    }
    ```
  ],
  diagrama(pie: [Flujo de un pedido; a la izquierda, el estado «Cobrar» en ASL.])[
    #set text(hyphenate: false)
    #grid(columns: 3, align: center + horizon, column-gutter: 2pt,
      _terminal("Inicio"), [], [],
      flecha-v(largo: 0.45cm), [], [],
      _estado("Task · DynamoDB", "Reservar stock"), [], [],
      flecha-v(largo: 0.45cm), [], [],
      _estado("Choice", "¿Hay stock?", color: col.datos), flecha(etiqueta: "no", largo: 0.75cm),
      _estado("Fail", "Sin stock", color: col.iam, ancho: 1.9cm),
      flecha-v(etiqueta: "sí", largo: 0.45cm), [], [],
      _estado("Task · Lambda", "Cobrar (Retry ×3)"), flecha(etiqueta: "Catch", largo: 0.75cm),
      _estado("Task · SNS", "Notificar fallo", ancho: 1.9cm),
      flecha-v(largo: 0.45cm), [], flecha-v(largo: 0.45cm),
      _estado("Task · SQS", "Enviar pedido"), [], _estado("Fail", "Pago fallido", color: col.iam, ancho: 1.9cm),
      flecha-v(largo: 0.45cm), [], [],
      _terminal("Fin", color: col.almacenamiento), [], [],
    )
  ],
)

Step Functions no necesita Lambda para todo: con las *integraciones optimizadas* (DynamoDB, SQS, SNS, ECS/Fargate, Batch, Glue, EventBridge, Bedrock…) y las del *AWS SDK* (`arn:aws:states:::aws-sdk:servicio:acción`, más de 200 servicios) llama a las API directamente, de tres maneras: *Request Response* sigue en cuanto el servicio responde; *Run a Job* (`.sync`) espera a que termine el trabajo, como una tarea de ECS o un _job_ de Glue, y *Wait for Callback* (`.waitForTaskToken`) se pausa hasta que alguien devuelve un _token_, por ejemplo tras una aprobación humana. Además transforma datos con JSONata y permite relanzar (_redrive_) una ejecución desde el paso que falló.

== Desplegar con AWS SAM

*AWS SAM* (_Serverless Application Model_) es una extensión de AWS CloudFormation, el servicio de infraestructura como código de AWS, que verás junto a CDK y Terraform en el capítulo de Infraestructura como código. Con recursos abreviados describes funciones, API y eventos, y su CLI construye, prueba en local y despliega (`sam build`, `sam local invoke`, `sam deploy --guided`). Estas líneas crean función, rol, HTTP API, tabla, alias y despliegue canary:

```yaml
Transform: AWS::Serverless-2016-10-31
Resources:
  CrearPedido:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: src/
      Handler: app.lambda_handler
      Runtime: python3.13
      Architectures: [arm64]
      Environment: { Variables: { TABLA_PEDIDOS: !Ref Pedidos } }
      Policies: [{ DynamoDBCrudPolicy: { TableName: !Ref Pedidos } }]
      AutoPublishAlias: prod
      DeploymentPreference: { Type: Canary10Percent5Minutes }
      Events:
        Api: { Type: HttpApi, Properties: { Path: /pedidos, Method: post } }
  Pedidos:
    Type: AWS::Serverless::SimpleTable
```


#block(breakable: false)[#resumen[
- Serverless: nada que administrar, escala sola (incluso a cero), pago por uso y alta disponibilidad.
- Lambda: un *handler* por evento, hasta 15 min y 10~240 MB de memoria, con CPU proporcional.
- El entorno pasa por *Init → Invoke (reutilizable) → Shutdown*; los *cold starts* se mitigan con SnapStart o concurrencia aprovisionada.
- La concurrencia regional (1000 por defecto) es compartida; la *reservada* garantiza y limita, la *aprovisionada* preinicializa.
- Invocación *síncrona* (reintenta el cliente), *asíncrona* (reintenta Lambda; destinos y DLQ) y *event source mapping* (Lambda sondea SQS, Kinesis o DynamoDB Streams).
- El *execution role* define qué hace la función; la *resource-based policy*, quién puede invocarla.
- Versiones inmutables y *aliases* ponderados permiten despliegues canary con _rollback_ automático.
- API Gateway: REST (más funciones), HTTP (más barata) y WebSocket; autorización IAM, JWT/Cognito o Lambda; throttling con 429.
- Step Functions orquesta pasos con Retry y Catch: Standard (flujos largos) o Express (alto volumen).
]]

#repaso(
  ([¿Por qué conviene crear los clientes del SDK fuera del handler?], [Porque ese código se ejecuta una vez, en la fase Init, y se reutiliza en todas las invocaciones del mismo entorno.]),
  ([Una API en Java sufre cold starts en horas punta. ¿Qué opciones tienes?], [SnapStart (sin coste extra en Java) o concurrencia aprovisionada sobre un alias, escalada con una programación.]),
  ([¿Qué ocurre si una invocación asíncrona falla repetidamente?], [Lambda la reintenta (2 veces por defecto) y, si sigue fallando o caduca, la envía al destino de fallo o a la DLQ; sin ellos, se pierde.]),
  ([Una función en una VPC no puede llamar a una API externa. ¿Por qué?], [Sus ENI no tienen IP pública: necesita una subred privada con ruta a un NAT Gateway.]),
  ([Necesitas API keys con cuotas por cliente y caché. ¿REST o HTTP API?], [REST API: las HTTP API no tienen _usage plans_, API keys ni caché.]),
  ([¿Cuándo elegirías Express en lugar de Standard?], [Para ejecuciones cortas (menos de 5 minutos) y de muy alto volumen, donde «al menos una vez» es aceptable.]),
)
