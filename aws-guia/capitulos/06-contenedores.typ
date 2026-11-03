#import "../theme.typ": *

// ---------------------------------------------------------------------
//  Ayudas locales para los diagramas de este capítulo
// ---------------------------------------------------------------------
// Icono compacto para filas con muchos elementos
#let mini(abbr, titulo, color) = box(width: 1.7cm, align(center + top, stack(dir: ttb, spacing: 3pt,
  align(center, box(width: 0.85cm, height: 0.85cm, radius: 4pt,
    fill: gradient.linear(color.lighten(8%), color.darken(18%), angle: 90deg),
    align(center + horizon, text(if abbr.len() > 3 { 6.4pt } else { 7.4pt }, weight: "bold", fill: white, abbr)))),
  align(center, {
    set par(justify: false, leading: 0.35em)
    text(6.5pt, weight: "semibold", fill: tinta, hyphenate: false, titulo)
  }),
)))

// Banda de una pila de capas (VM frente a contenedores)
#let capa(t, c) = box(width: 100%, fill: c, radius: 3pt, inset: (y: 4pt),
  align(center, text(6.8pt, weight: "semibold", fill: white, t)))

// Contenedor y tarea en miniatura
#let ctr(t) = box(width: 0.62cm, height: 0.42cm, radius: 2pt, fill: col.contenedores.lighten(55%),
  align(center + horizon, text(5.6pt, weight: "bold", fill: col.contenedores.darken(40%), t)))
#let tarea(n) = box(stroke: 1pt + col.contenedores, radius: 4pt, inset: 3.5pt, fill: white,
  stack(dir: ttb, spacing: 2.5pt,
    align(center, text(6.2pt, weight: "bold", fill: tinta, n)),
    stack(dir: ltr, spacing: 2pt, ctr("app"), ctr("log"))))

// Caja pequeña de texto para diagramas
#let cb(t, color: col.contenedores, ancho: auto) = box(width: ancho, fill: color.lighten(88%), stroke: 0.8pt + color,
  radius: 3pt, inset: (x: 4pt, y: 3.5pt), align(center, {
    set par(justify: false, leading: 0.35em)
    text(6.4pt, fill: tinta, hyphenate: false, t)
  }))
#let nota-dg(t) = text(6.3pt, fill: gris.darken(20%), t)

#capitulo("Contenedores: ECS, Fargate, ECR y EKS", color: col.contenedores,
  subtitulo: [Empaqueta tu aplicación una vez y ejecútala en cualquier parte: registro de imágenes, orquestación y cómputo sin servidores para contenedores.],
  objetivos: (
    [Imágenes, contenedores y el registro Amazon ECR],
    [Clúster, task definition, tarea y servicio en ECS],
    [EC2, Fargate y Fargate Spot como capacidad],
    [Modos de red e IAM: execution role frente a task role],
    [Despliegues, balanceo, escalado, secretos y logs],
    [Cuándo elegir ECS, EKS o App Runner],
  ),
  servicios: ("Amazon ECS", "AWS Fargate", "Amazon ECR", "AWS Cloud Map", "Amazon EKS", "AWS App Runner"))

== Contenedores en dos minutos

«En mi máquina funciona» es el problema clásico: la aplicación depende de una versión concreta del lenguaje, de librerías del sistema y de ficheros de configuración que nunca son idénticos en desarrollo, pruebas y producción. Un *contenedor* empaqueta la aplicación con todas sus dependencias en una unidad que se ejecuta igual en cualquier sitio. A diferencia de una máquina virtual, no lleva un sistema operativo completo: comparte el kernel del host y se aísla con mecanismos del propio kernel, así que arranca en segundos y ocupa megas en lugar de gigas.

#diagrama(pie: [Una máquina virtual incluye un sistema operativo completo; los contenedores comparten el kernel del host y solo empaquetan la aplicación y sus librerías.])[
  #grid(columns: (6.6cm, 6.6cm), column-gutter: 26pt, row-gutter: 6pt,
    text(8.5pt, weight: "bold", fill: col.computo.darken(20%), "Máquinas virtuales"),
    text(8.5pt, weight: "bold", fill: col.contenedores.darken(20%), "Contenedores"),
    stack(dir: ttb, spacing: 3pt,
      grid(columns: (1fr, 1fr, 1fr), column-gutter: 3pt, row-gutter: 3pt,
        ..("A", "B", "C").map(a => capa("App " + a, col.contenedores)),
        ..range(3).map(_ => capa("Librerías", col.contenedores.lighten(30%))),
        ..range(3).map(_ => capa("SO invitado", col.computo))),
      capa("Hipervisor", col.balanceo),
      capa("Servidor físico", col.neutro)),
    stack(dir: ttb, spacing: 3pt,
      grid(columns: (1fr, 1fr, 1fr), column-gutter: 3pt, row-gutter: 3pt,
        ..("A", "B", "C").map(a => capa("App " + a, col.contenedores)),
        ..range(3).map(_ => capa("Librerías", col.contenedores.lighten(30%)))),
      capa("Motor de contenedores (containerd, Docker)", col.redes),
      capa("SO del host: un único kernel compartido", col.computo),
      capa("Servidor físico", col.neutro)),
  )
]

/ Imagen: plantilla inmutable de solo lectura, formada por capas, que contiene la aplicación y sus dependencias. Sigue el estándar OCI y se identifica por repositorio y etiqueta (`web-api:1.4.2`) o por _digest_ (`sha256:...`).
/ Contenedor: una imagen en ejecución, con su sistema de ficheros efímero, sus procesos y su red.
/ Registro: almacén de imágenes del que se descargan (_pull_) y al que se suben (_push_): Docker Hub, Amazon ECR...
/ Orquestador: decide dónde se ejecuta cada contenedor, lo reinicia si falla, lo conecta al balanceador y lo escala: Amazon ECS o Kubernetes (Amazon EKS).

```dockerfile
# Etapa 1: compilar con todas las herramientas
FROM golang:1.23 AS build
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -o /app ./cmd/api
# Etapa 2: imagen final mínima, sin compiladores ni shell
FROM gcr.io/distroless/static-debian12
COPY --from=build /app /app
USER nonroot
EXPOSE 8080
ENTRYPOINT ["/app"]
```

#consejo[Las construcciones en varias etapas (_multi-stage builds_) como esta producen imágenes pequeñas: menos superficie de ataque, menos vulnerabilidades que parchear y descargas más rápidas al escalar.]

== Amazon ECR: el registro de imágenes

#ficha("Amazon ECR", "Registro de imágenes de contenedor totalmente gestionado",
  ("Tipo", [Registro privado por cuenta y región (y ECR Public para imágenes públicas); un repositorio por imagen]),
  ("Seguridad", [Permisos con IAM y políticas de repositorio; cifrado en reposo con AES-256 o KMS]),
  ("Facturación", [Por GB almacenado al mes y por transferencia de datos de salida (gratuita dentro de la misma región)]),
  ("Integración", [ECS, EKS, Lambda (imágenes de contenedor), App Runner, CodeBuild y Amazon Inspector]))

/ Etiquetas inmutables: con `IMMUTABLE`, nadie puede sobrescribir `web-api:1.4.2` con otro contenido. Despliega siempre etiquetas concretas, nunca `latest`.
/ Escaneo de vulnerabilidades: el básico analiza paquetes del sistema operativo al subir la imagen; el mejorado, con Amazon Inspector, escanea de forma continua también las dependencias de los lenguajes.
/ Lifecycle policies: borran automáticamente imágenes antiguas o sin etiqueta, para no pagar almacenamiento de más.
/ Replicación y _pull through cache_: copian imágenes a otras regiones o cuentas, y cachean en tu registro imágenes de registros públicos (Docker Hub, Quay, GitHub, ECR Public...).

```bash
REG=123456789012.dkr.ecr.eu-west-1.amazonaws.com
aws ecr create-repository --repository-name web-api \
  --image-tag-mutability IMMUTABLE --image-scanning-configuration scanOnPush=true
# Docker se autentica con un token temporal (válido 12 horas)
aws ecr get-login-password --region eu-west-1 \
  | docker login --username AWS --password-stdin "$REG"
docker build -t "$REG/web-api:1.4.2" . && docker push "$REG/web-api:1.4.2"
```

```json
{ "rules": [
  { "rulePriority": 1, "description": "Sin etiqueta: borrar a los 14 días",
    "selection": { "tagStatus": "untagged", "countType": "sinceImagePushed",
                   "countUnit": "days", "countNumber": 14 },
    "action": { "type": "expire" } },
  { "rulePriority": 2, "description": "Conservar las 50 más recientes",
    "selection": { "tagStatus": "any", "countType": "imageCountMoreThan",
                   "countNumber": 50 },
    "action": { "type": "expire" } } ] }
```

== Amazon ECS: conceptos clave

*Amazon Elastic Container Service (ECS)* es el orquestador de contenedores propio de AWS: tú describes qué contenedores quieres y cuántas copias, y ECS decide dónde ejecutarlos, los vigila, los sustituye si fallan y los registra en el balanceador.

#ficha("Amazon ECS", "Orquestación de contenedores totalmente gestionada",
  ("Plano de control", [Gestionado por AWS y sin coste: pagas solo la capacidad (instancias EC2 o Fargate)]),
  ("Ámbito", [Regional; las tareas se reparten entre las AZ de las subredes que elijas]),
  ("Capacidad", [AWS Fargate (sin servidores) o instancias EC2 propias con el agente de ECS]),
  ("Integración", [ELB, Auto Scaling, IAM, CloudWatch, Secrets Manager, Cloud Map, CodeDeploy]))

/ Clúster: agrupación lógica de servicios, tareas y capacidad. Puede mezclar Fargate e instancias EC2.
/ Task definition: plantilla JSON *versionada* (familia + revisión, como `web-api:7`) que describe uno o varios contenedores: imagen, CPU y memoria, puertos, variables, secretos, logs, roles IAM y modo de red.
/ Tarea: una instancia en ejecución de una task definition. Sus contenedores comparten ciclo de vida y, en `awsvpc`, la misma IP.
/ Servicio: mantiene N tareas en marcha (_desired count_), sustituye las que fallan, gestiona los despliegues y las registra en un balanceador.
/ Agente de ECS: proceso que corre en cada instancia EC2 del clúster, la registra y arranca o para sus contenedores. En Fargate lo gestiona AWS.

#diagrama(pie: [Jerarquía de ECS: un servicio mantiene varias copias de una task definition en un clúster; también puedes lanzar tareas sueltas, como una migración de base de datos.])[
  #fila(espacio: 4pt,
    svc("TD", "Task definition", sub: "web-api:7, versionada", color: col.contenedores),
    flecha(etiqueta: "se ejecuta como", largo: 1.7cm),
    zona("Clúster ECS · prod", color: col.contenedores)[
      #columna(espacio: 6pt,
        fila(espacio: 8pt,
          zona("Servicio web-api · deseadas: 3", color: col.contenedores)[#fila(espacio: 4pt, tarea("tarea 1"), tarea("tarea 2"), tarea("tarea 3"))],
          zona("Tarea suelta", color: col.neutro, ancho: 3.1cm)[#tarea("migración")],
        ),
        caja([Capacidad: AWS Fargate o instancias EC2 con el agente de ECS], color: col.computo, ancho: 8.6cm),
      )
    ],
  )
]

Así se ve una task definition para Fargate con un contenedor, un secreto y logs en CloudWatch:

```json
{
  "family": "web-api", "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512", "memory": "1024",
  "runtimePlatform": { "cpuArchitecture": "ARM64",
                       "operatingSystemFamily": "LINUX" },
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789012:role/web-api-task",
  "containerDefinitions": [{
    "name": "api", "essential": true,
    "image": "123456789012.dkr.ecr.eu-west-1.amazonaws.com/web-api:1.4.2",
    "portMappings": [{ "containerPort": 8080 }],
    "environment": [{ "name": "APP_ENV", "value": "prod" }],
    "secrets": [{ "name": "DB_PASSWORD", "valueFrom":
      "arn:aws:secretsmanager:eu-west-1:123456789012:secret:prod/db-AbCdEf" }],
    "logConfiguration": { "logDriver": "awslogs",
      "options": { "awslogs-group": "/ecs/web-api",
                   "awslogs-region": "eu-west-1",
                   "awslogs-stream-prefix": "api" } }
  }]
}
```

== Capacidad: EC2, Fargate y Fargate Spot

Las tareas necesitan CPU y memoria de algún sitio. Con *ECS sobre EC2* las pones tú: un grupo de Auto Scaling con la AMI optimizada para ECS, que también debes parchear y dimensionar. Con *AWS Fargate* no hay servidores a la vista: declaras la CPU y la memoria de cada tarea y AWS la ejecuta en un entorno aislado, facturando por segundo. *Fargate Spot* usa capacidad sobrante con descuento, a cambio de poder interrumpir la tarea.

#datos(("0,25–16", [vCPU por tarea en Fargate]), ("120 GB", [memoria máxima por tarea]), ("200 GiB", [almacenamiento efímero máximo (20 por defecto)]), ("70 %", [descuento máximo de Fargate Spot]))

#tabla(("Característica", "ECS sobre EC2", "Fargate", "Fargate Spot"), columnas: (1.15fr, 1.5fr, 1.4fr, 1.4fr), tamano: 8pt,
  [*Servidores*], [Los gestionas tú (AMI, parches, escalado)], [Los gestiona AWS], [Los gestiona AWS],
  [*Facturación*], [Instancias EC2, aunque estén medio vacías], [vCPU y GB de memoria por segundo (mínimo 1 min)], [Igual, con hasta un 70 % de descuento],
  [*Interrupciones*], [No (salvo que uses Spot de EC2)], no, [Sí: aviso de 2 minutos y `SIGTERM`],
  [*Modos de red*], [`awsvpc`, `bridge`, `host`, `none`], [Solo `awsvpc`], [Solo `awsvpc`],
  [*GPU y tipos concretos*], si, no, no,
  [*Tareas daemon*], [#si Una por instancia], no, no,
  [*Ideal para*], [Flotas grandes y estables, GPU, requisitos especiales], [La opción por defecto: sin servidores que mantener], [Lotes, _workers_ y entornos no productivos],
)

Los *capacity providers* deciden dónde va cada tarea. Un servicio puede usar una estrategia que combine varios: con `FARGATE` (base 2, peso 1) y `FARGATE_SPOT` (peso 3), las dos primeras tareas van a Fargate normal y, de las siguientes, una de cada cuatro va a Fargate y tres a Spot. Con EC2, un capacity provider asociado a un ASG escala las instancias según las tareas pendientes (_managed scaling_) y evita terminar instancias que aún ejecutan tareas.

#nota[Desde 2025 existe además *ECS Managed Instances*, un punto intermedio: ECS lanza y mantiene por ti instancias EC2 en tu cuenta (selección del tipo, parches, sustitución) y conservas el acceso a toda la gama de EC2, GPU incluidas.]

== Redes de las tareas

El *modo de red* de la task definition decide cómo se conectan los contenedores:

#diagrama(pie: [Modos de red de ECS. En `awsvpc` cada tarea es un ciudadano más de la VPC; en `bridge` las tareas comparten la red del host mediante puertos dinámicos; en `host` usan directamente los puertos del host.])[
  #grid(columns: 3, column-gutter: 8pt, align: center + top,
    zona("awsvpc · Fargate y EC2", color: col.contenedores, ancho: 4.95cm)[
      #columna(espacio: 4pt,
        fila(espacio: 4pt, cb([Tarea A \ :8080], ancho: 2cm), cb([Tarea B \ :8080], ancho: 2cm)),
        fila(espacio: 4pt, cb([ENI propia \ 10.0.11.23 + SG], color: col.redes, ancho: 2cm), cb([ENI propia \ 10.0.11.57 + SG], color: col.redes, ancho: 2cm)),
        nota-dg[Cada tarea tiene su IP y sus Security Groups])
    ],
    zona("bridge · EC2", color: col.contenedores, ancho: 4.95cm)[
      #columna(espacio: 4pt,
        fila(espacio: 4pt, cb([Tarea A \ :80], ancho: 2cm), cb([Tarea B \ :80], ancho: 2cm)),
        cb([Red virtual de Docker (docker0)], color: col.neutro, ancho: 4.1cm),
        cb([ENI del host \ :32768 → A · :32769 → B], color: col.redes, ancho: 4.1cm),
        nota-dg[Puertos dinámicos del host])
    ],
    zona("host · EC2", color: col.contenedores, ancho: 4.95cm)[
      #columna(espacio: 4pt,
        cb([Tarea A \ :80], ancho: 2cm),
        cb([ENI del host \ :80, el mismo puerto], color: col.redes, ancho: 4.1cm),
        nota-dg[Una sola tarea por puerto y host])
    ],
  )
]

*awsvpc* es el modo recomendado (y el único en Fargate): cada tarea recibe su propia ENI con IP privada de la subred, así que aplicas Security Groups por tarea y ves su tráfico en los VPC Flow Logs. En *bridge*, los contenedores usan una red virtual dentro de la instancia y se publican en puertos del host; si dejas el puerto del host vacío (o a 0), Docker asigna uno alto aleatorio: es el _dynamic port mapping_, que permite varias copias de la misma tarea en una instancia. *host* elimina esa capa y da el máximo rendimiento de red, pero dos tareas no pueden usar el mismo puerto en la misma instancia.

#consejo[En EC2 con `awsvpc`, el número de tareas por instancia está limitado por las ENI que admite el tipo de instancia. Activa el *ENI trunking* (ajuste de cuenta `awsvpcTrunking`) para multiplicarlo en los tipos compatibles.]

== IAM en ECS: execution role y task role

Una tarea puede llevar dos roles IAM distintos, y confundirlos es uno de los errores más habituales en ECS:

#diagrama(pie: [El _task execution role_ lo usa ECS para preparar la tarea; el _task role_ lo usa tu código. Ambos confían en el principal `ecs-tasks.amazonaws.com`.])[
  #grid(columns: 3, column-gutter: 6pt, row-gutter: 10pt, align: center + horizon,
    svc("ECS", "Agente de ECS o Fargate", sub: "prepara la tarea", color: col.contenedores),
    flecha(etiqueta: "task execution role", largo: 2.6cm, color: col.iam),
    fila(espacio: 2pt, svc("ECR", "Descargar imagen", sub: "de Amazon ECR", color: col.contenedores), svc("LOGS", "Enviar los logs", sub: "CloudWatch Logs", color: col.observabilidad), svc("SM", "Leer los secretos", sub: "de la task definition", color: col.seguridad)),
    svc("APP", "Tu código", sub: "dentro del contenedor", color: col.neutro),
    flecha(etiqueta: "task role", largo: 2.6cm, color: col.iam),
    fila(espacio: 2pt, svc("S3", "Amazon S3", color: col.almacenamiento), svc("DDB", "DynamoDB", color: col.datos), svc("SQS", "Amazon SQS", color: col.integracion)),
  )
]

/ Task execution role: lo asume el agente de ECS (o Fargate) *antes* de arrancar tus contenedores: descarga la imagen de ECR, crea el flujo de logs y lee los secretos referenciados en la task definition. La política gestionada `AmazonECSTaskExecutionRolePolicy` cubre ECR y CloudWatch Logs; los secretos requieren permisos adicionales.
/ Task role: lo usa *tu aplicación* para llamar a otros servicios. El SDK obtiene credenciales temporales de un endpoint local de la tarea, igual que una instancia EC2 las obtiene del IMDS. Usa un rol por servicio, con el mínimo privilegio.
/ Rol de instancia: solo en ECS sobre EC2; permite al agente registrar la instancia en el clúster. No lo uses para dar permisos a las aplicaciones.

#cuidado(titulo: "Error típico")[Tu código recibe `AccessDenied` al leer de S3: le diste el permiso al *execution role*, pero la aplicación usa el *task role*. Y al revés: si la tarea ni siquiera arranca (`CannotPullContainerError` o `ResourceInitializationError`), revisa el *execution role* y que la subred tenga salida hacia ECR y Secrets Manager (NAT Gateway o VPC endpoints).]

== Servicios: despliegue, balanceo y escalado

Un servicio mantiene el número deseado de tareas repartidas entre AZ. La estrategia `REPLICA` (la habitual) mantiene N copias; `DAEMON` ejecuta exactamente una por instancia EC2, útil para agentes de monitorización (no existe en Fargate). En EC2 puedes además influir en la colocación con estrategias (`spread` por AZ, `binpack` para llenar instancias) y restricciones.

#tarjetas(columnas: 3,
  tarjeta("Rolling update", subtitulo: "Por defecto")[ECS sustituye las tareas por tandas, entre `minimumHealthyPercent` (100 % por defecto) y `maximumPercent` (200 %). Con el *circuit breaker*, si las tareas nuevas no se estabilizan, vuelve solo a la versión anterior.],
  tarjeta("Blue/green", color: col.datos, subtitulo: "Con CodeDeploy o nativo")[Levanta la versión nueva junto a la antigua con un segundo target group y desplaza el tráfico de golpe, por porcentajes (_canary_) o poco a poco (_linear_), con vuelta atrás inmediata. Desde 2025 ECS lo ofrece también de forma nativa.],
  tarjeta("Alarmas", color: col.observabilidad, subtitulo: "Vuelta atrás por métricas")[Asocia alarmas de CloudWatch al despliegue (errores 5XX, latencia): si saltan durante el despliegue, ECS revierte automáticamente.],
)

Para recibir tráfico, el servicio se registra en un *target group* del balanceador (vimos ALB y NLB en el capítulo anterior). En `awsvpc`, el target group es de tipo `ip` y registra la IP de cada tarea (obligatorio en Fargate); en `bridge`, de tipo `instance`, y el ALB registra cada instancia con el puerto dinámico de cada tarea. El Security Group de las tareas debe permitir el puerto del contenedor *solo desde el Security Group del ALB*, y el _health check grace period_ evita que ECS mate tareas que aún están arrancando.

```bash
NET='awsvpcConfiguration={subnets=[subnet-0a1b,subnet-0c2d],securityGroups=[sg-0e3f]}'
aws ecs create-service --cluster prod --service-name web-api \
  --task-definition web-api:7 --desired-count 4 \
  --capacity-provider-strategy capacityProvider=FARGATE,base=2,weight=1 \
      capacityProvider=FARGATE_SPOT,weight=3 \
  --network-configuration "$NET" \
  --load-balancers targetGroupArn=$TG_ARN,containerName=api,containerPort=8080 \
  --deployment-configuration 'deploymentCircuitBreaker={enable=true,rollback=true}'
```

El número de tareas se escala con *Application Auto Scaling* (presentado en el capítulo anterior): registras el servicio como recurso escalable y le asocias una política, normalmente de target tracking sobre la CPU media (`ECSServiceAverageCPUUtilization`), la memoria o las peticiones por target del ALB.

```bash
aws application-autoscaling register-scalable-target --service-namespace ecs \
  --scalable-dimension ecs:service:DesiredCount \
  --resource-id service/prod/web-api --min-capacity 2 --max-capacity 20
aws application-autoscaling put-scaling-policy --service-namespace ecs \
  --scalable-dimension ecs:service:DesiredCount \
  --resource-id service/prod/web-api --policy-name cpu-60 \
  --policy-type TargetTrackingScaling \
  --target-tracking-scaling-policy-configuration '{"TargetValue": 60.0,
    "PredefinedMetricSpecification":
      {"PredefinedMetricType": "ECSServiceAverageCPUUtilization"}}'
```

== Comunicación entre servicios

Cuando un servicio llama a otro (la web a la API de pagos, por ejemplo), necesita encontrarlo aunque sus tareas cambien de IP en cada despliegue. Hay tres opciones:

#tabla(("", "Service Discovery", "Service Connect", "ALB interno"), columnas: (0.9fr, 1.4fr, 1.6fr, 1.2fr), tamano: 8pt,
  [*Cómo se invoca*], [Nombre DNS en AWS Cloud Map: `pagos.prod.local`], [Alias corto: `http://pagos:8080`], [Nombre DNS del ALB],
  [*Quién reparte*], [El cliente, con lo que devuelve el DNS], [Un proxy que ECS añade a cada tarea], [El balanceador],
  [*Extras*], [Registro y health checks automáticos], [Reintentos, detección de destinos con fallos y métricas por servicio en CloudWatch], [Reglas HTTP, TLS, WAF],
)

*Service Connect* es la opción recomendada para comunicar servicios ECS entre sí: usa un _namespace_ de Cloud Map, pero los clientes no dependen del DNS ni de su caché. AWS App Mesh, la malla de servicios que se usaba antes, llegó al fin de su soporte el 30 de septiembre de 2026.

== Configuración, logs y depuración

*Secretos y configuración.* Nunca metas contraseñas en la imagen ni en variables `environment` en claro. En la sección `secrets` de la task definition referencias un secreto de *Secrets Manager* (por ARN, incluso una clave concreta de un secreto JSON) o un parámetro de *SSM Parameter Store*: ECS lo lee con el execution role y lo inyecta como variable de entorno al arrancar el contenedor. Si cambias el secreto, las tareas en marcha no se enteran: fuerza un nuevo despliegue. Para mucha configuración no sensible puedes usar `environmentFiles` (un fichero `.env` en S3).

*Logs.* El driver `awslogs` envía la salida estándar de cada contenedor a CloudWatch Logs (grupo, región y prefijo del _stream_ en `logConfiguration`). Para enviarlos a varios destinos (S3, Amazon Data Firehose, OpenSearch o herramientas de terceros), *FireLens* añade a la tarea un contenedor con Fluent Bit que enruta los logs (driver `awsfirelens`). Activa también *Container Insights* para tener métricas de CPU, memoria y red por servicio y tarea; lo ampliaremos en el capítulo de Observabilidad.

*ECS Exec.* Para entrar en un contenedor en ejecución sin SSH ni puertos abiertos, ECS Exec usa por debajo el canal de Session Manager. Requiere activar `enableExecuteCommand` en el servicio, permisos `ssmmessages` en el task role y el plugin de Session Manager en tu equipo; cada sesión queda registrada en CloudTrail.

```bash
aws ecs update-service --cluster prod --service web-api \
  --enable-execute-command --force-new-deployment
aws ecs execute-command --cluster prod --task "$TASK_ID" --container api \
  --interactive --command "/bin/sh"
```

== Arquitectura de referencia

Juntando todas las piezas, este es el despliegue típico de una API en contenedores: un ALB público, un servicio ECS en Fargate repartido en subredes privadas de dos AZ y una base de datos RDS Multi-AZ, con acceso privado a ECR, CloudWatch Logs y Secrets Manager mediante VPC endpoints.

#diagrama(pie: [Arquitectura de referencia: ALB público → servicio ECS en Fargate en subredes privadas → RDS. Las tareas descargan la imagen de ECR, envían logs y leen secretos a través de VPC endpoints, sin salir a Internet.])[
  #fila(espacio: 3pt,
    actor(etiqueta: "Usuarios"),
    flecha(etiqueta: "HTTPS", largo: 1.1cm),
    zona("VPC · eu-west-1", color: col.redes)[
      #fila(espacio: 3pt,
        zona("Públicas", color: col.almacenamiento)[#mini("ALB", [ALB con nodos en 2 AZ], col.balanceo)],
        flecha(etiqueta: ":8080", largo: 0.95cm),
        zona("Privadas · ECS Fargate", color: col.contenedores)[
          #columna(espacio: 6pt,
            zona("AZ a", color: col.neutro)[#fila(espacio: 2pt, mini("TASK", [tarea 1], col.contenedores), mini("TASK", [tarea 2], col.contenedores))],
            zona("AZ b", color: col.neutro)[#fila(espacio: 2pt, mini("TASK", [tarea 3], col.contenedores), mini("TASK", [tarea 4], col.contenedores))],
          )
        ],
        flecha(etiqueta: "SQL", largo: 0.95cm),
        zona("Datos", color: col.datos)[#columna(espacio: 6pt, mini("RDS", [primaria · AZ a], col.datos), mini("RDS", [standby · AZ b], col.datos))],
      )
    ],
  )
  #v(8pt)
  #fila(espacio: 6pt,
    caja([Acceso privado, por VPC endpoints, a servicios regionales:], color: col.neutro, ancho: 5.2cm),
    flecha(largo: 0.9cm),
    mini("ECR", [ECR: imágenes], col.contenedores),
    mini("LOGS", [CloudWatch Logs], col.observabilidad),
    mini("SM", [Secrets Manager], col.seguridad),
    mini("S3", [S3 (capas de ECR)], col.almacenamiento),
  )
]

#coste[Si las tareas de subredes privadas descargan imágenes a través de un NAT Gateway, pagas su procesamiento por GB en cada despliegue y cada escalado. Los VPC endpoints de ECR (`ecr.api` y `ecr.dkr`), el endpoint _gateway_ de S3 (gratuito, ahí están las capas) y el de CloudWatch Logs suelen salir más baratos y mantienen el tráfico dentro de AWS.]

== ¿ECS, EKS o App Runner?

*Amazon Elastic Kubernetes Service (EKS)* es la otra gran opción para orquestar contenedores en AWS: Kubernetes gestionado. AWS opera el plano de control de Kubernetes (servidor de API y base de datos etcd, replicados en varias AZ, con parches y actualizaciones) y tú decides cómo ejecutar los nodos de trabajo, en EC2 o en Fargate. Es Kubernetes estándar y certificado, así que funcionan `kubectl`, Helm y todo el ecosistema de la CNCF; a cambio, se paga una tarifa por clúster y hora y exige dominar Kubernetes y actualizar su versión periódicamente. Lo estudiaremos a fondo en el capítulo siguiente, «Kubernetes y Amazon EKS».

#tabla(("Criterio", "Amazon ECS", "Amazon EKS"), columnas: (1fr, 2fr, 2fr), tamano: 8pt,
  [*Modelo*], [Orquestador propio de AWS, con una API sencilla], [Kubernetes estándar y certificado],
  [*Curva de aprendizaje*], [Baja: pocos conceptos], [Alta: Kubernetes y su ecosistema],
  [*Plano de control*], [Sin coste], [Tarifa por clúster y hora],
  [*Portabilidad*], [Ligado a AWS], [Manifiestos portables a otros Kubernetes, on-premises o en otras nubes],
  [*Ecosistema*], [Integración nativa con los servicios de AWS], [Helm, operadores y herramientas CNCF],
  [*Mantenimiento*], [Sin versiones que actualizar], [Actualizar la versión de Kubernetes y sus complementos],
  [*Elígelo si*], [Quieres simplicidad y todo tu entorno está en AWS], [Ya usas Kubernetes, necesitas portabilidad o su ecosistema],
)

En el otro extremo está *AWS App Runner*, aún más sencillo: le das una imagen de contenedor (o el código fuente) y se encarga de construir, desplegar, servir con HTTPS, escalar según las peticiones y conectarse a tu VPC. Es cómodo para webs y APIs sin equipo de plataforma, a cambio de mucho menos control sobre la red y el despliegue; antes de elegirlo para un proyecto nuevo, revisa su estado y sus límites en la documentación.

== Buenas prácticas

- *Imágenes*: pequeñas (_multi-stage_, _distroless_), etiquetas inmutables y versionadas, escaneo continuo con Inspector y _lifecycle policies_ en ECR.
- *Seguridad*: un task role por servicio con mínimo privilegio, secretos en Secrets Manager, contenedores sin `root` y Security Groups por tarea en `awsvpc`.
- *Fiabilidad*: tareas en al menos dos AZ, health checks en contenedor y balanceador, circuit breaker con vuelta atrás y despliegues blue/green para lo crítico.
- *Coste*: Fargate por defecto, Graviton (`ARM64`) e imágenes multiarquitectura, Fargate Spot para lo tolerante a interrupciones, Savings Plans de cómputo y VPC endpoints en lugar de NAT para ECR.
- *Operación*: logs con retención definida, Container Insights, ECS Exec para depurar e infraestructura como código para clúster, servicios y task definitions.

#resumen[
  - Un contenedor empaqueta la aplicación y sus dependencias y comparte el kernel del host; se construye a partir de una imagen OCI inmutable.
  - *ECR* almacena las imágenes con etiquetas inmutables, escaneo de vulnerabilidades (básico o con Inspector), _lifecycle policies_ y replicación.
  - En *ECS*, una *task definition* versionada describe los contenedores; una *tarea* es una ejecución y un *servicio* mantiene N tareas detrás de un balanceador.
  - La capacidad la ponen instancias EC2 propias o *Fargate* (sin servidores, por segundo); *Fargate Spot* abarata hasta un 70 % con aviso de 2 minutos.
  - `awsvpc` da a cada tarea su ENI y sus Security Groups (único modo en Fargate); `bridge` usa puertos dinámicos y `host` los puertos del host.
  - El *execution role* prepara la tarea (ECR, logs, secretos); el *task role* da permisos a tu código. Confundirlos es el error más común.
  - Despliegues _rolling_ con circuit breaker, _blue/green_ y vuelta atrás por alarmas; target groups de tipo `ip`; escalado con Application Auto Scaling.
  - *Service Connect* comunica servicios entre sí; los secretos se inyectan desde Secrets Manager o Parameter Store; los logs van a CloudWatch con `awslogs` o FireLens.
  - *EKS* ofrece Kubernetes gestionado (capítulo siguiente) y *App Runner*, la máxima sencillez para webs y APIs.
]

#repaso(
  ([Tu aplicación en ECS recibe `AccessDenied` al escribir en DynamoDB, aunque el execution role tiene el permiso. ¿Qué pasa?], [Los permisos de la aplicación van en el *task role*; el execution role solo lo usa ECS para descargar la imagen, enviar logs y leer los secretos.]),
  ([¿Qué tipo de target group necesitas para un servicio en Fargate detrás de un ALB?], [De tipo `ip`, porque en `awsvpc` (el único modo de Fargate) cada tarea tiene su propia IP.]),
  ([¿Qué diferencia hay entre una tarea y un servicio en ECS?], [Una tarea es una ejecución de una task definition; un servicio mantiene un número deseado de tareas, sustituye las que fallan, gestiona despliegues y las registra en el balanceador.]),
  ([¿Cuándo elegirías ECS sobre EC2 en lugar de Fargate?], [Cuando necesitas GPU o tipos de instancia concretos, tareas daemon, acceso al host, o una flota grande y estable en la que llenar instancias sale más barato.]),
  ([Un despliegue deja tareas que se reinician en bucle. ¿Cómo evitas que el servicio se quede roto?], [Activando el deployment circuit breaker con `rollback`: ECS detecta que las tareas nuevas no se estabilizan y vuelve a la versión anterior.]),
  ([¿Cómo inyectas la contraseña de la base de datos en un contenedor sin incluirla en la imagen?], [Con la sección `secrets` de la task definition, apuntando a Secrets Manager o Parameter Store; ECS la lee con el execution role y la expone como variable de entorno.]),
  ([Tu equipo ya usa Kubernetes en su centro de datos y quiere portabilidad. ¿ECS o EKS?], [EKS: es Kubernetes estándar, así que reutilizan manifiestos, Helm y herramientas, aunque pagan el plano de control y deben gestionar las actualizaciones de versión.]),
)
