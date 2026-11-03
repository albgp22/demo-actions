#import "../theme.typ": *

// ---------------------------------------------------------------------
//  Utilidades locales del apéndice
// ---------------------------------------------------------------------


// Título de sección del apéndice (sin numerar y fuera del índice)
#let seccion(t) = heading(level: 2, numbering: none, outlined: false, t)

// Filas «dato · valor» dentro de una tarjeta
#let kv(..pares) = {
  set par(justify: false, leading: 0.45em)
  grid(columns: (1fr, auto), column-gutter: 6pt, row-gutter: 4.6pt,
    ..pares.pos().map(((k, v)) => (
      text(7.2pt, fill: gris.darken(25%), hyphenate: false, k),
      align(right, text(7.5pt, weight: "bold", fill: tinta, v)),
    )).flatten())
}

#apendice("B", "Chuleta de referencia rápida", color: col.arquitectura,
  subtitulo: [Cifras que conviene tener a mano, los comandos de AWS CLI más útiles y una guía rápida para elegir servicio.])

#seccion[Cifras y límites clave]

Valores por defecto o máximos vigentes al redactar esta guía (2026). Un asterisco (\*) indica una cuota *ajustable* desde Service Quotas; «car.» son caracteres. Antes de diseñar al límite, comprueba la documentación.

#tarjetas(columnas: 3,
  tarjeta("Lambda", color: col.serverless)[#kv(
    ([Duración máxima], [15 min]),
    ([Memoria], [128–10 240 MB]),
    ([/tmp efímero], [512 MB–10 GB]),
    ([Payload síncrono], [6 MB]),
    ([Payload asíncrono], [1 MB]),
    ([Zip / sin comprimir], [50 / 250 MB]),
    ([Imagen de contenedor], [10 GB]),
    ([Concurrencia], [1 000\*]),
  )],
  tarjeta("SQS", color: col.integracion)[#kv(
    ([Mensaje], [1 MiB]),
    ([Retención], [1 min–14 días]),
    ([… por defecto], [4 días]),
    ([Visibility timeout], [0 s–12 h]),
    ([… por defecto], [30 s]),
    ([Long polling], [hasta 20 s]),
    ([Retardo (delay)], [hasta 15 min]),
    ([FIFO sin lotes], [300 msg/s]),
  )],
  tarjeta("DynamoDB", color: col.datos)[#kv(
    ([Ítem], [400 KB]),
    ([1 RCU: lectura fuerte/s], [4 KB]),
    ([1 WCU: escritura/s], [1 KB]),
    ([Query / Scan], [1 MB/página]),
    ([BatchWrite / Get], [25 / 100 ítems]),
    ([Transacción], [100 acciones]),
    ([GSI / LSI], [20\* / 5]),
    ([Streams], [24 h]),
  )],
  tarjeta("S3", color: col.almacenamiento)[#kv(
    ([Objeto máximo], [50 TB]),
    ([Antes de dic. 2025], [5 TB]),
    ([Una sola PUT], [5 GB]),
    ([Multipart], [10 000 partes]),
    ([Tamaño de parte], [5 MiB–5 GiB]),
    ([Escrituras/prefijo], [3 500/s]),
    ([Lecturas/prefijo], [5 500/s]),
    ([Buckets por cuenta], [10 000\*]),
  )],
  tarjeta("VPC", color: col.redes)[#kv(
    ([CIDR de VPC y subred], [/16 a /28]),
    ([IPs reservadas/subred], [5]),
    ([VPC por región], [5\*]),
    ([SG por ENI], [5\*]),
    ([Reglas por SG], [60 + 60\*]),
    ([Reglas por NACL], [20 por sentido\*]),
    ([Peering], [no transitivo]),
  )],
  tarjeta("EC2, EBS y ELB", color: col.computo)[#kv(
    ([Aviso de Spot], [2 min]),
    ([Linux: por segundo], [mín. 60 s]),
    ([IMDS], [169.254.169.254]),
    ([gp3: IOPS base], [3 000]),
    ([gp3: MB/s base], [125 MB/s]),
    ([ALB idle timeout], [60 s]),
    ([Deregistration], [300 s]),
  )],
  tarjeta("IAM y Organizations", color: col.iam)[#kv(
    ([Usuarios IAM], [5 000]),
    ([Grupos por usuario], [10]),
    ([Sesión de un rol], [1 h (máx. 12 h)]),
    ([Roles encadenados], [máx. 1 h]),
    ([Política gestionada], [6 144 car.]),
    ([SCP por destino], [5]),
    ([Tamaño de SCP], [5 120 car.]),
    ([Niveles de OU], [5]),
  )],
  tarjeta("Observabilidad", color: col.observabilidad)[#kv(
    ([CloudTrail: historial], [90 días]),
    ([Métricas: retención], [15 meses]),
    ([Resolución estándar], [1 min]),
    ([Alta resolución], [1 s]),
    ([EC2 básico / detall.], [5 / 1 min]),
    ([CloudWatch Logs], [sin caducidad]),
  )],
  tarjeta("KMS", color: col.seguridad)[#kv(
    ([Encrypt directo], [4 KB]),
    ([Espera de borrado], [7–30 días]),
    ([… por defecto], [30 días]),
    ([Rotación automática], [anual]),
    ([Configurable], [90–2 560 días]),
  )],
  tarjeta("API Gateway y streaming", color: col.serverless)[#kv(
    ([API GW: timeout], [29 s\*]),
    ([API GW: payload], [10 MB]),
    ([Step Functions Std.], [1 año]),
    ([Step Functions Expr.], [5 min]),
    ([Kinesis: retención], [24 h–365 días]),
    ([Shard: escritura], [1 MB/s]),
    ([Shard: lectura], [2 MB/s]),
  )],
  tarjeta("RDS y Aurora", color: col.datos)[#kv(
    ([Backups automáticos], [hasta 35 días]),
    ([Réplicas de lectura], [hasta 15]),
    ([Failover Multi-AZ], [~1–2 min]),
    ([Copias de Aurora], [6 en 3 AZ]),
    ([Global Database], [< 1 s típico]),
  )],
  tarjeta("Borde y costes", color: col.edge)[#kv(
    ([Cert. de CloudFront], [ACM, #box[us-east-1]]),
    ([TTL por defecto (CF)], [24 h]),
    ([Alias de Route 53], [gratis]),
    ([Salida gratis], [100 GB/mes]),
    ([IPv4 pública], [por hora]),
  )],
)

#seccion[Comandos de AWS CLI más útiles]

```bash
# Identidad y perfiles
aws configure sso                              # perfil con IAM Identity Center
aws sso login --profile prod
aws sts get-caller-identity                    # ¿con qué identidad estoy?

# EC2 y Systems Manager
aws ec2 describe-instances --filters Name=instance-state-name,Values=running \
  --query 'Reservations[].Instances[].[InstanceId,InstanceType]' --output table
aws ssm start-session --target i-0123456789abcdef0     # shell sin SSH ni bastión

# S3
aws s3 ls s3://mi-bucket/datos/ --recursive --human-readable --summarize
aws s3 sync ./dist s3://mi-web --delete
aws s3 presign s3://mi-bucket/informe.pdf --expires-in 3600   # URL temporal

# Lambda y CloudWatch Logs
aws lambda invoke --function-name procesador \
  --cli-binary-format raw-in-base64-out --payload '{"id": 42}' salida.json
aws logs tail /aws/lambda/procesador --follow --since 15m
```

```bash
# Contenedores
aws ecr get-login-password | docker login --username AWS \
  --password-stdin 111111111111.dkr.ecr.eu-west-1.amazonaws.com
aws ecs update-service --cluster prod --service api --force-new-deployment
aws eks update-kubeconfig --name prod --region eu-west-1

# Mensajería y datos
aws sqs send-message --queue-url "$COLA" --message-body '{"pedido": 42}'
aws sqs get-queue-attributes --queue-url "$COLA" \
  --attribute-names ApproximateNumberOfMessages
aws dynamodb get-item --table-name Pedidos --key '{"pk": {"S": "PEDIDO#42"}}'

# IaC, CDN y costes
aws cloudformation deploy --template-file plantilla.yaml --stack-name app \
  --capabilities CAPABILITY_NAMED_IAM --parameter-overrides Entorno=prod
aws cloudformation detect-stack-drift --stack-name app
aws cloudfront create-invalidation --distribution-id E1A2B3C4D5 --paths "/*"
aws ce get-cost-and-usage --time-period Start=2026-10-01,End=2026-11-01 \
  --granularity MONTHLY --metrics UnblendedCost \
  --group-by Type=DIMENSION,Key=SERVICE
```

#consejo[Añade `--query` (JMESPath) y `--output table` o `text` para filtrar la salida, `--dry-run` en EC2 para comprobar permisos sin ejecutar nada, y `--debug` para ver qué petición firma la CLI cuando algo falla.]

#seccion[¿Qué servicio uso para…?]

#set text(hyphenate: false)

#tabla(("Necesito…", "Usa", "Alternativa o matiz"), columnas: (2.3fr, 1.55fr, 2.4fr), tamano: 8pt,
  [Ejecutar código por eventos, en tareas cortas], [Lambda], [Contenedores si dura más de 15 min o la carga es constante],
  [Contenedores sin gestionar servidores], [ECS con Fargate], [EKS si ya trabajas con Kubernetes],
  [Kubernetes gestionado], [EKS (Auto Mode)], [ECS si no necesitas Kubernetes],
  [Máquinas virtuales con control del SO], [EC2 + Auto Scaling], [Spot para lotes tolerantes a interrupciones],
  [Orquestar un flujo de varios pasos], [Step Functions], [EventBridge para coreografía por eventos],
  [Base de datos relacional gestionada], [RDS o Aurora], [Aurora DSQL para SQL distribuido multirregión],
  [Clave-valor a gran escala con latencia de ms], [DynamoDB], [DAX si necesitas microsegundos],
  [Caché en memoria], [ElastiCache], [DAX, específica para DynamoDB],
  [Analítica SQL a gran escala (warehouse)], [Redshift], [Athena para consultas puntuales sobre S3],
  [Consultar con SQL datos en S3], [Athena], [Redshift Spectrum desde el warehouse],
  [Objetos: estáticos, backups, data lake], [S3], [Clases Glacier para archivo],
  [Disco de bloque para una instancia], [EBS], [Instance store para datos temporales],
  [Sistema de ficheros compartido], [EFS], [FSx (Windows, Lustre, ONTAP, OpenZFS)],
  [Desacoplar con una cola], [SQS], [SQS FIFO si importa el orden],
  [Un mensaje para muchos suscriptores], [SNS], [EventBridge si necesitas reglas más ricas o más destinos],
  [Bus de eventos con reglas, SaaS o horarios], [EventBridge], [SNS para fan-out simple],
  [Streaming en tiempo real con relectura], [Kinesis Data Streams], [Amazon MSK si necesitas Kafka],
  [Cargar streams en S3 o Redshift sin código], [Data Firehose], [Glue para ETL por lotes],
  [Publicar una API], [API Gateway], [ALB si ya hay contenedores o EC2 detrás],
  [Balancear HTTP(S) con reglas por ruta], [ALB], [NLB para TCP/UDP, IP fija o latencia mínima],
  [CDN y caché global], [CloudFront], [Global Accelerator para TCP/UDP sin caché],
  [Conectar muchas VPC entre sí], [Transit Gateway], [VPC peering si son pocas],
  [Ofrecer un servicio privado a otras VPC], [PrivateLink], [VPC Lattice para comunicación entre servicios],
  [Conectar con el centro de datos], [Site-to-Site VPN], [Direct Connect para un enlace dedicado],
  [Acceso de personas a varias cuentas], [IAM Identity Center], [Usuarios IAM solo como excepción],
  [Registro e inicio de sesión de tus usuarios], [Cognito], [Incluye federación con Google, Apple o SAML],
  [Secretos con rotación automática], [Secrets Manager], [Parameter Store para configuración],
  [Claves de cifrado], [KMS], [CloudHSM para un HSM dedicado],
  [Proteger una web de ataques de capa 7], [AWS WAF], [Shield Advanced frente a DDoS grandes],
  [Auditar quién hizo qué], [CloudTrail], [AWS Config para cambios de configuración],
  [Detectar amenazas y vulnerabilidades], [GuardDuty e Inspector], [Macie para datos sensibles en S3],
  [Métricas, logs y alarmas], [CloudWatch], [X-Ray para trazas distribuidas],
  [Infraestructura como código], [CloudFormation o CDK], [Terraform si usas varios proveedores],
  [Copias de seguridad centralizadas], [AWS Backup], [Vault Lock para copias inmutables],
  [Entrar en una instancia sin SSH], [Session Manager], [EC2 Instance Connect (SSH con claves temporales)],
)
