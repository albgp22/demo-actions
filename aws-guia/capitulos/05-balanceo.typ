#import "../theme.typ": *

// ---------------------------------------------------------------------
//  Ayudas locales
// ---------------------------------------------------------------------

// Icono compacto para filas con muchos elementos
#let mini(abbr, titulo, color) = box(width: 1.7cm, align(center + top, stack(dir: ttb, spacing: 3pt,
  align(center, box(width: 0.85cm, height: 0.85cm, radius: 4pt,
    fill: gradient.linear(color.lighten(8%), color.darken(18%), angle: 90deg),
    align(center + horizon, text(7.4pt, weight: "bold", fill: white, abbr)))),
  align(center, text(6.6pt, weight: "semibold", fill: tinta, hyphenate: false, titulo)),
)))

// Texto monoespaciado pequeño para diagramas
#let mono(t, tam: 6.8pt, color: tinta) = text(tam, font: "JetBrains Mono", fill: color, t)

// Regla y destino en el diagrama de enrutamiento del ALB
#let regla(n, campo, valor) = box(width: 4.75cm, fill: white, stroke: 0.9pt + col.balanceo, radius: 4pt,
  inset: (x: 5pt, y: 4.5pt), align(left, {
    box(fill: col.balanceo, radius: 2pt, inset: (x: 3pt, y: 1.5pt), text(6pt, weight: "bold", fill: white, n))
    h(3pt)
    mono(campo, tam: 6.2pt, color: col.balanceo.darken(35%))
    h(3pt)
    mono(valor, tam: 6.2pt)
  }))
#let destino(accion, resto, color: col.contenedores) = box(width: 4.75cm, fill: color.lighten(90%), stroke: 0.9pt + color, radius: 4pt,
  inset: (x: 5pt, y: 4.5pt), align(left, text(6.6pt, fill: tinta, [#text(weight: "bold", fill: color.darken(30%), accion) #resto])))

// Target con su porcentaje de tráfico (diagrama de cross-zone)
#let tgt(p, c) = box(width: 0.9cm, height: 0.62cm, radius: 3pt, fill: c.lighten(82%), stroke: 0.8pt + c,
  align(center + horizon, text(6.2pt, weight: "bold", fill: c.darken(35%), p)))

// Estado del ciclo de vida de Auto Scaling
#let est(nombre, color) = box(width: 2.45cm, height: 0.8cm, radius: 4pt, fill: color.lighten(86%), stroke: 1pt + color,
  align(center + horizon, text(6.5pt, weight: "bold", font: "JetBrains Mono", fill: color.darken(35%), nombre)))
#let nota-est(cuerpo) = box(width: 2.6cm, {
  set par(justify: false, leading: 0.4em)
  align(center, text(6.5pt, fill: gris.darken(20%), hyphenate: false, cuerpo))
})

#capitulo("Balanceo de carga y Auto Scaling", color: col.balanceo,
  subtitulo: [Reparte el tráfico entre muchas instancias sanas y deja que la flota crezca y se encoja sola según la demanda.],
  objetivos: (
    [Por qué balancear y qué aporta Elastic Load Balancing],
    [Elegir entre ALB, NLB y GWLB],
    [Listeners, reglas, target groups y health checks],
    [TLS con ACM, cross-zone, stickiness y drenaje de conexiones],
    [Auto Scaling Groups: capacidad, políticas y health checks],
    [Lifecycle hooks, instance refresh, warm pools y Spot],
  ),
  servicios: ("Elastic Load Balancing", "Application Load Balancer", "Network Load Balancer", "Gateway Load Balancer", "Amazon EC2 Auto Scaling", "AWS Certificate Manager"))

== ¿Por qué balancear la carga?

Una aplicación servida por un único servidor tiene tres problemas: si cae, la aplicación cae (punto único de fallo); si el tráfico crece, solo puedes comprar una máquina más grande (escalado vertical, con techo); y cada despliegue obliga a cortar el servicio. Un *balanceador de carga* ofrece un único punto de entrada (un nombre DNS), reparte las peticiones entre varios servidores —los *targets*— de varias zonas de disponibilidad y deja de enviar tráfico a los que fallan sus comprobaciones de salud. Con *Auto Scaling*, que lanza y retira servidores según la demanda, obtienes una flota elástica que se repara sola.

#analogia[Piensa en el maître de un restaurante grande: los clientes solo ven la puerta (el nombre DNS); él los reparte entre las mesas de varios camareros, deja de asignar mesas al que se ha puesto enfermo y, si se forma cola, el gerente (Auto Scaling) llama a más camareros.]

#ficha("Elastic Load Balancing", "Balanceadores de carga gestionados, elásticos y multi-AZ",
  ("Tipos", [Application (ALB), Network (NLB) y Gateway (GWLB); el Classic (CLB) es de la generación anterior]),
  ("Ámbito", [Regional: el balanceador tiene nodos en cada AZ que habilites y escala solo]),
  ("Facturación", [Por hora y por unidades de capacidad consumidas (LCU en ALB, NLCU en NLB, GLCU en GWLB)]),
  ("Se integra con", [Auto Scaling, ECS, EKS, Lambda, ACM, AWS WAF (ALB), CloudFront y Global Accelerator]))

== Tipos de balanceador

#tabla(("Característica", "Application LB", "Network LB", "Gateway LB"), columnas: (1.15fr, 1.6fr, 1.6fr, 1.5fr), tamano: 8pt,
  [*Capa OSI*], [7 (aplicación)], [4 (transporte)], [3 (red)],
  [*Protocolos*], [HTTP, HTTPS, HTTP/2, gRPC, WebSocket], [TCP, UDP, TLS, TCP_UDP], [Todo el tráfico IP, encapsulado en GENEVE (puerto 6081)],
  [*Enrutamiento*], [Por host, ruta, cabeceras, método, _query string_ o IP de origen], [Por listener (protocolo y puerto)], [Transparente hacia los appliances],
  [*IP estática*], [#no Solo nombre DNS; sus IPs cambian], [#si Una por AZ (admite Elastic IP)], [No aplica: se usa a través de _GWLB endpoints_],
  [*Security Groups*], si, [#si Desde 2023, solo si se asignan al crearlo], no,
  [*Targets*], [Instancias, IPs y funciones Lambda], [Instancias, IPs y un ALB], [Instancias e IPs],
  [*IP del cliente*], [En la cabecera `X-Forwarded-For`], [Se conserva (o Proxy Protocol v2)], [Se conserva: el paquete llega intacto],
  [*Casos de uso*], [Webs, APIs, microservicios y contenedores], [TCP/UDP de alto rendimiento, IP fija, PrivateLink, IoT, juegos], [Firewalls, IDS/IPS e inspección de tráfico de terceros],
)

El *ALB* es la opción por defecto para el tráfico web: entiende HTTP, así que enruta por contenido, termina TLS, autentica usuarios o devuelve respuestas fijas. El *NLB* reenvía conexiones TCP/UDP sin mirar dentro, con latencia muy baja; es la base de *AWS PrivateLink*. El *GWLB* inserta de forma transparente una flota de appliances de seguridad en el camino del tráfico, que llega a él por rutas hacia un GWLB endpoint. El *Classic Load Balancer* (CLB), de la generación anterior, funciona en capa 4 y 7 pero sin reglas, target groups ni targets Lambda: úsalo solo en cargas heredadas y planifica su migración a ALB o NLB (la consola incluye un asistente).

#consejo[¿Necesitas IP fija *y* reglas HTTP? Pon un NLB delante de un ALB (target group de tipo `alb`) o usa Global Accelerator. Y si creas un NLB, asígnale Security Groups desde el principio: no se pueden añadir después a un NLB creado sin ellos.]

== Listeners, reglas y target groups

/ Listener: escucha en un protocolo y un puerto (por ejemplo, HTTPS:443) y aplica reglas a lo que llega. Un balanceador puede tener varios.
/ Regla: condiciones y acciones, evaluadas por prioridad (primero el número más bajo); si ninguna coincide se aplica la regla por defecto. Las reglas por contenido son exclusivas del ALB.
/ Target group: conjunto de destinos con su protocolo, su puerto y su health check. Un mismo target group puede usarse en varias reglas.
/ Target: cada destino registrado: una instancia EC2 (por ID), una IP (contenedores en modo `awsvpc`, servidores on-premises vía VPN o Direct Connect), una función Lambda (en ALB) o un ALB completo detrás de un NLB.

La @fig-alb-reglas muestra un listener típico. Las condiciones disponibles son `host-header`, `path-pattern`, `http-header`, `http-request-method`, `query-string` y `source-ip`; dentro de una regla se combinan con «y». El _forward ponderado_ reparte el tráfico entre varios target groups por pesos, la base de los despliegues _canary_ y _blue/green_. Las acciones `authenticate-cognito` y `authenticate-oidc` (solo en listeners HTTPS) delegan el inicio de sesión en Amazon Cognito o en cualquier proveedor OpenID Connect antes de dejar pasar la petición.

```bash
# Target group para contenedores en modo awsvpc (target type ip)
aws elbv2 create-target-group --name tg-api --protocol HTTP --port 8080 \
  --vpc-id vpc-0abc1234 --target-type ip --health-check-path /health
# Regla: lo que llegue a api.ejemplo.com va al target group de la API
aws elbv2 create-rule --listener-arn "$LISTENER_ARN" --priority 10 \
  --conditions Field=host-header,Values=api.ejemplo.com \
  --actions Type=forward,TargetGroupArn="$TG_API_ARN"
# Listener HTTP que solo redirige a HTTPS
aws elbv2 create-listener --load-balancer-arn "$ALB_ARN" --protocol HTTP \
  --port 80 --default-actions \
  'Type=redirect,RedirectConfig={Protocol=HTTPS,Port=443,StatusCode=HTTP_301}'
```

#diagrama(pie: [Un listener de ALB evalúa sus reglas por prioridad: condiciones de host, ruta, cabeceras o query string, y acciones _forward_ (simple o ponderado), _authenticate_, _redirect_ y _fixed-response_.])[
  #fila(espacio: 4pt,
    columna(actor(etiqueta: "Clientes"), flecha-v(etiqueta: "HTTPS"), svc("ALB", "Listener HTTPS :443", sub: "certificado de ACM", color: col.balanceo)),
    flecha(largo: 1.0cm),
    zona("Reglas del listener · por prioridad", color: col.balanceo)[
      #columna(espacio: 4pt,
        fila(regla("1", "host-header", "api.ejemplo.com"), flecha(largo: 0.7cm), destino("forward", [→ TG #mono("api") (IPs de ECS)])),
        fila(regla("2", "path-pattern", "/admin/*"), flecha(largo: 0.7cm), destino("authenticate-oidc", [→ TG #mono("admin")], color: col.iam)),
        fila(regla("3", "http-header", "X-Canary: 1"), flecha(largo: 0.7cm), destino("forward", [→ TG #mono("web-v2")])),
        fila(regla("4", "query-string", "lang=en"), flecha(largo: 0.7cm), destino("forward", [→ TG #mono("web-en")])),
        fila(regla("5", "path-pattern", "/antiguo/*"), flecha(largo: 0.7cm), destino("redirect", [301 → #mono("/nuevo/")], color: col.datos)),
        fila(regla("6", "host-header", "www.ejemplo.com"), flecha(largo: 0.7cm), destino("forward ponderado", [90 % #mono("v1") · 10 % #mono("v2")])),
        fila(regla("—", "por defecto", ""), flecha(largo: 0.7cm), destino("fixed-response", [404 «No encontrado»], color: col.neutro)),
      )
    ],
  )
] <fig-alb-reglas>

== Health checks

El balanceador comprueba periódicamente cada target y solo le envía tráfico si está sano. En el target group defines el protocolo, el puerto y la ruta (por ejemplo, `HTTP` y `/health`), el intervalo y el _timeout_ (30 s y 5 s por defecto en ALB), los umbrales de éxitos y fallos consecutivos para cambiar de estado (5 y 2) y los códigos que cuentan como éxito (`200` o un rango como `200-399`). Si *todos* los targets están no sanos, el ALB reparte entre todos igualmente (_fail open_): prefiere servir algo a no servir nada.

#cuidado[Un health check «profundo» que comprueba también la base de datos parece buena idea hasta que la base de datos tiene un problema: todos los targets fallan a la vez y el balanceador deja de servir incluso las páginas que no la necesitan. Comprueba que *tu proceso* responde y vigila las dependencias con métricas y alarmas.]

== TLS, certificados y SNI

El ALB y el NLB pueden *terminar TLS*: descifran en el balanceador y descargan ese trabajo de tus servidores. El certificado sale normalmente de *AWS Certificate Manager (ACM)*, que emite certificados públicos sin coste y los renueva automáticamente si los validaste por DNS; debe estar en la misma región que el balanceador (ACM se explica en el capítulo de Seguridad). La *política de seguridad* del listener fija versiones y cifrados (elige una con TLS 1.3). Con *SNI* (_Server Name Indication_), un listener sirve varios dominios con certificados distintos, elegidos según el nombre que pide el cliente. Para cifrar de extremo a extremo, usa un target group HTTPS; el ALB admite además TLS mutuo (mTLS).

== Cross-zone load balancing

Cada AZ habilitada tiene su nodo del balanceador, y el DNS reparte a los clientes por igual entre los nodos. ¿Qué pasa si las AZ tienen distinto número de targets? Depende del *cross-zone load balancing*:

#let verde = rgb("#2F9E44")
#diagrama(pie: [Dos targets en la AZ a y ocho en la AZ b. Con cross-zone, el tráfico se reparte por igual entre los diez; sin él, cada AZ recibe la mitad y los dos targets de la AZ a quedan sobrecargados.])[
  #grid(columns: (3.3cm, auto), column-gutter: 10pt, row-gutter: 10pt, align: (left + horizon, center + horizon),
    {
      set par(justify: false)
      text(8.5pt, weight: "bold", fill: verde.darken(20%), "Con cross-zone")
      linebreak()
      text(7.5pt, fill: gris.darken(20%), "cada target recibe el 10 %")
    },
    fila(espacio: 8pt,
      zona("AZ a", color: col.neutro)[#fila(espacio: 3pt, tgt("10 %", verde), tgt("10 %", verde))],
      zona("AZ b", color: col.neutro)[#fila(espacio: 3pt, ..range(8).map(_ => tgt("10 %", verde)))]),
    {
      set par(justify: false)
      text(8.5pt, weight: "bold", fill: col.seguridad, "Sin cross-zone")
      linebreak()
      text(7.5pt, fill: gris.darken(20%), "cada AZ recibe el 50 %")
    },
    fila(espacio: 8pt,
      zona("AZ a", color: col.neutro)[#fila(espacio: 3pt, tgt("25 %", col.seguridad), tgt("25 %", col.seguridad))],
      zona("AZ b", color: col.neutro)[#fila(espacio: 3pt, ..range(8).map(_ => tgt("6,25 %", col.balanceo)))]),
  )
]

En el *ALB* viene siempre activado en el balanceador (puedes desactivarlo por target group) y no cobra la transferencia entre AZ. En el *NLB* y el *GWLB* viene *desactivado* por defecto y, si lo activas, pagas la transferencia de datos entre AZ.

== Comportamiento fino del balanceador

/ Deregistration delay: al retirar un target, el balanceador deja de enviarle peticiones nuevas pero espera a que terminen las que tiene en curso (300 s por defecto, de 0 a 3600 s). Es el antiguo _connection draining_.
/ Slow start: en el ALB, un target nuevo recibe una parte creciente del tráfico durante 30 a 900 s, para que caliente cachés.
/ Sticky sessions: el ALB fija un cliente a un target con una cookie propia (`AWSALB`, de 1 segundo a 7 días) o de tu aplicación; el NLB, por IP de origen. Desequilibran la carga: mejor una aplicación sin estado con la sesión en ElastiCache o DynamoDB.
/ X-Forwarded-For: el ALB sustituye la IP de origen por la suya y añade la del cliente en esa cabecera, junto a `X-Forwarded-Proto` y `X-Forwarded-Port`. Configura tus logs para leerlas.
/ Internet-facing o interno: el primero tiene IPs públicas y vive en subredes públicas; el _internal_ solo tiene IPs privadas. Patrón típico: ALB público → capa web → ALB interno → capa de aplicación.
/ Access logs: el ALB (y el NLB con listeners TLS) puede dejar en S3, cada 5 minutos, el detalle de cada petición: IP del cliente, latencias, ruta, códigos. Desactivados por defecto; analízalos con Athena.

#practica[Vigila en CloudWatch `TargetResponseTime`, `HTTPCode_Target_5XX_Count` (errores de tu aplicación), `HTTPCode_ELB_5XX_Count` (del balanceador) y `UnHealthyHostCount` (capítulo de Observabilidad).]

== Auto Scaling Groups

Un *Auto Scaling Group (ASG)* mantiene una flota de instancias EC2 del tamaño adecuado: lanza instancias cuando falta capacidad o alguna falla, y las termina cuando sobra. Cada ASG combina tres cosas: *qué* lanzar (una launch template, que vimos en el capítulo de EC2), *dónde* (una lista de subredes, idealmente en varias AZ) y *cuántas* (capacidad mínima, deseada y máxima).

#ficha("Amazon EC2 Auto Scaling", "Flotas de EC2 que se escalan y se reparan solas",
  ("Coste", [Sin coste adicional: pagas las instancias y las alarmas de CloudWatch que use]),
  ("Capacidad", [Mínimo ≤ deseada ≤ máximo; el ASG mantiene la deseada y las políticas la mueven entre los límites]),
  ("Reparación", [Sustituye las instancias que fallan los health checks y reparte la flota entre las AZ]))

#diagrama(pie: [Arquitectura clásica. El usuario resuelve el nombre en Route 53 (1) y se conecta por HTTPS a los nodos del ALB _internet-facing_ en las subredes públicas de dos AZ (2), que reparten el tráfico entre las instancias del ASG en subredes privadas. Una alarma de CloudWatch y una política de escalado ajustan la capacidad deseada.])[
  #let dns = fila(flecha(etiqueta: "1 · consulta DNS", largo: 1.7cm), svc("R53", "Route 53", sub: "alias → ALB", color: col.edge))
  #grid(columns: 3, column-gutter: 6pt, align: center + bottom,
    columna(
      svc("CW", "CloudWatch", sub: "alarma: CPU media del grupo", color: col.observabilidad),
      flecha-v(etiqueta: "dispara", largo: 0.7cm),
      svc("ASG", "Escalado", sub: "target tracking: 50 %", color: col.computo),
      v(0.5cm),
    ),
    box(inset: (bottom: 1.25cm), flecha(etiqueta: "ajusta la deseada", largo: 1.6cm)),
    columna(espacio: 0pt,
      fila(espacio: 0pt, hide(dns), actor(etiqueta: "Usuarios"), dns),
      flecha-v(etiqueta: "2 · HTTPS :443", largo: 0.65cm),
      zona("VPC 10.0.0.0/16", color: col.redes)[
        #columna(espacio: 2pt,
          zona("Subredes públicas · ALB internet-facing", color: col.almacenamiento)[
            #fila(espacio: 3.4cm, caja([Nodo del ALB · AZ a], color: col.balanceo), caja([Nodo del ALB · AZ b], color: col.balanceo))
          ],
          flecha-v(etiqueta: "HTTP :8080 · target group web", largo: 0.75cm),
          zona("Auto Scaling Group · mín 2 · deseada 4 · máx 8", color: col.computo)[
            #fila(espacio: 8pt,
              zona("Privada · AZ a", color: col.datos)[#fila(espacio: 2pt, mini("EC2", [web-1], col.computo), mini("EC2", [web-2], col.computo))],
              zona("Privada · AZ b", color: col.datos)[#fila(espacio: 2pt, mini("EC2", [web-3], col.computo), mini("EC2", [web-4], col.computo))],
            )
          ],
        )
      ],
    ),
  )
]

=== Políticas de escalado

#tabla(("Política", "Cómo funciona", "Cuándo usarla"), columnas: (0.95fr, 2.6fr, 1.55fr), tamano: 8pt,
  [*Target tracking*], [Mantiene una métrica en un objetivo (CPU media del 50 %, peticiones por target...) como un termostato; crea las alarmas por ti], [La opción por defecto],
  [*Step scaling*], [Alarmas con escalones: +1 instancia si la CPU pasa del 60 %, +3 si pasa del 80 %], [Respuesta proporcional al pico],
  [*Simple scaling*], [Un ajuste por alarma y espera al _cooldown_], [Heredada],
  [*Scheduled*], [Cambia mínimo, deseada y máximo a una hora (_cron_)], [Horario laboral, campañas],
  [*Predictive*], [Aprende del histórico con _machine learning_ y escala por adelantado], [Cargas cíclicas, arranques lentos],
)

```bash
# Target tracking: mantener la CPU media del grupo en el 50 %
aws autoscaling put-scaling-policy --auto-scaling-group-name web-asg \
  --policy-name cpu-50 --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{"TargetValue": 50.0,
    "PredefinedMetricSpecification":
      {"PredefinedMetricType": "ASGAverageCPUUtilization"}}'
# Programada: mínimo de 6 instancias los días laborables a las 7:00 UTC
aws autoscaling put-scheduled-update-group-action \
  --auto-scaling-group-name web-asg --scheduled-action-name laborable \
  --recurrence "0 7 * * 1-5" --min-size 6
```

Para que el grupo no «oscile», el *cooldown* (300 s por defecto) hace esperar a una política simple tras cada ajuste, y el *instance warm-up* evita que las instancias recién lanzadas cuenten en la métrica agregada hasta que han arrancado.

=== Health checks y ciclo de vida

Por defecto, el ASG solo usa los *health checks de EC2* (la máquina funciona y pasa los _status checks_). Detrás de un balanceador, activa también los *health checks de ELB* para sustituir instancias cuyo servidor web no responde aunque la máquina siga viva. El _health check grace period_ da tiempo a que una instancia nueva arranque antes de evaluarla.

#diagrama(pie: [Los _lifecycle hooks_ pausan una instancia al entrar o salir del grupo para que ejecutes acciones propias (por defecto, hasta 1 hora) antes de continuar.])[
  #grid(columns: 9, column-gutter: 3pt, row-gutter: 5pt, align: center + horizon,
    est("Pending", col.neutro), flecha(largo: 0.6cm), est("Pending:Wait", col.balanceo), flecha(largo: 0.6cm),
    est("InService", rgb("#2F9E44")), flecha(largo: 0.6cm), est("Terminating:Wait", col.balanceo), flecha(largo: 0.6cm), est("Terminated", col.seguridad),
    [], [], nota-est[instalar software, registrar, calentar caché], [], [], [], nota-est[drenar trabajo, copiar logs, desregistrar], [], [],
  )
]

- *Lifecycle hooks*: la instancia espera en `Pending:Wait` o `Terminating:Wait` hasta que tu script o una función Lambda llaman a `complete-lifecycle-action`, o vence el plazo.
- *Instance refresh*: sustituye las instancias por tandas para aplicar una nueva AMI o plantilla, manteniendo un mínimo sano (90 % por defecto), con vuelta atrás automática si la activas.
- *Warm pools*: instancias ya inicializadas y paradas (o en marcha, o hibernadas) que el ASG usa al escalar para evitar arranques lentos; las paradas solo cuestan su EBS.
- *Terminación*: al reducir, el ASG elige la AZ con más instancias y, dentro de ella, por defecto, la de plantilla más antigua. Puedes proteger instancias con _scale-in protection_.

=== Mezclar tipos de instancia y Spot

Con una *mixed instances policy*, un mismo ASG combina varios tipos de instancia y modelos de compra: una base On-Demand fija y, por encima, un porcentaje On-Demand y el resto en Spot, diversificado entre tipos y AZ. *Capacity Rebalancing* sustituye por adelantado las instancias Spot con riesgo alto de interrupción.

```json
"MixedInstancesPolicy": {
  "LaunchTemplate": {
    "LaunchTemplateSpecification": { "LaunchTemplateName": "web",
                                     "Version": "$Latest" },
    "Overrides": [{ "InstanceType": "m7g.large" }, { "InstanceType": "m6g.large" },
                  { "InstanceType": "c7g.xlarge" }] },
  "InstancesDistribution": { "OnDemandBaseCapacity": 2,
    "OnDemandPercentageAboveBaseCapacity": 25,
    "SpotAllocationStrategy": "price-capacity-optimized" } }
```

Las dos primeras instancias son On-Demand; por encima, una de cada cuatro es On-Demand y tres son Spot, repartidas entre tres tipos Graviton (la AMI debe ser `arm64`). Cuantos más tipos y AZ admitas, menos interrupciones sufrirás; si además cubres la base On-Demand con Savings Plans (capítulo de EC2), la flota cuesta una fracción de una flota fija dimensionada para el pico.

== Application Auto Scaling

*Application Auto Scaling* aplica el mismo modelo (recurso con mínimo y máximo, y políticas de target tracking, step o programadas) a recursos que no son instancias EC2: tareas de servicios ECS, capacidad de tablas DynamoDB, réplicas de Aurora, concurrencia aprovisionada de Lambda, endpoints de SageMaker o Spot Fleet, entre otros. Lo veremos con ECS en el capítulo de Contenedores.

#resumen[
  - Un balanceador da un único punto de entrada, reparte el tráfico entre targets de varias AZ y aparta los que fallan sus health checks.
  - *ALB* (capa 7) para HTTP: reglas por host, ruta, cabeceras, método o query string, y acciones `forward`, `redirect`, `fixed-response` y `authenticate`. *NLB* (capa 4) para TCP/UDP, IP estática y PrivateLink. *GWLB* (capa 3) para appliances. El CLB es heredado.
  - Listener → reglas → target groups → targets (instancias, IPs, Lambda o un ALB detrás de un NLB).
  - Health checks superficiales; si todos fallan, el ALB hace fail open.
  - TLS con certificados de ACM (en la región del balanceador) y SNI para varios dominios en un listener.
  - Cross-zone siempre activo en ALB; opcional y con coste entre AZ en NLB y GWLB. Deregistration delay (300 s por defecto), slow start, stickiness y `X-Forwarded-For`.
  - Un ASG mantiene la capacidad deseada entre un mínimo y un máximo, en varias AZ, a partir de una launch template; target tracking es la política por defecto.
  - Health checks de ELB en el ASG, lifecycle hooks, instance refresh y warm pools para operar flotas; mixed instances para combinar On-Demand y Spot.
]

#repaso(
  ([Tu aplicación web necesita enrutar `/api/*` a un servicio y el resto a otro. ¿Qué balanceador usas?], [Un ALB, con una regla `path-pattern` para `/api/*` que reenvíe a un target group y la regla por defecto apuntando al otro.]),
  ([Un cliente necesita incluir en su firewall las IPs fijas de tu servicio TCP. ¿Qué haces?], [Usar un NLB, que tiene una IP estática por AZ y admite Elastic IP (o poner Global Accelerator delante).]),
  ([Tras un despliegue, los usuarios ven errores al retirar instancias antiguas. ¿Qué ajuste revisas?], [El _deregistration delay_ del target group, para que las peticiones en curso terminen antes de retirar el target, además de los health checks.]),
  ([Tienes 2 targets en una AZ y 8 en otra detrás de un NLB, y los dos primeros están saturados. ¿Por qué?], [En NLB el cross-zone viene desactivado: cada AZ recibe la mitad del tráfico, así que cada target de la primera AZ recibe el 25 %. Activa cross-zone o equilibra los targets.]),
  ([Tu ASG no sustituye instancias cuyo nginx se ha caído. ¿Qué falta?], [Activar los health checks de ELB en el ASG; por defecto solo usa los de EC2, que solo comprueban que la máquina funciona.]),
  ([¿Qué política de escalado eliges para mantener la CPU media en torno al 50 %?], [Target tracking sobre la métrica `ASGAverageCPUUtilization` con objetivo 50; el ASG crea y gestiona las alarmas.]),
)
