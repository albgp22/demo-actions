#import "../theme.typ": *

// ---------------------------------------------------------------------
//  Utilidades locales del apéndice
// ---------------------------------------------------------------------

// El tema dibuja los títulos de nivel 1 en blanco (para la portada de capítulo):
// en el apéndice, sobre fondo blanco, lo mostramos en el color de texto principal.
#show heading.where(level: 1): it => block(above: 12pt, below: 8pt,
  text(32pt, weight: "extrabold", fill: marino, hyphenate: false, it.body))

// Título de sección del apéndice (sin numerar y fuera del índice)
#let seccion(t) = heading(level: 2, numbering: none, outlined: false, t)

// Filas «dato · valor» dentro de una tarjeta
#let kv(..pares) = {
  set par(justify: false, leading: 0.45em)
  grid(columns: (1.2fr, 1fr), column-gutter: 6pt, row-gutter: 5pt,
    ..pares.pos().map(((k, v)) => (
      text(7.6pt, fill: gris.darken(25%), k),
      align(right, text(7.8pt, weight: "bold", fill: tinta, v)),
    )).flatten())
}

#apendice("B", "Chuleta de referencia rápida", color: col.arquitectura,
  subtitulo: [Cifras que conviene tener a mano, los comandos de AWS CLI más útiles y una guía rápida para elegir servicio.])

#seccion[Cifras y límites clave]

Valores por defecto o máximos a fecha de 2026. Los marcados como _ajustables_ son cuotas que puedes ampliar desde Service Quotas; consulta siempre la documentación antes de diseñar al límite.

#tarjetas(columnas: 3,
  tarjeta("Lambda", color: col.serverless)[#kv(
    ([Duración máxima], [15 min]),
    ([Memoria], [128–10 240 MB]),
    ([/tmp efímero], [512 MB–10 GB]),
    ([Payload síncrono], [6 MB]),
    ([Payload asíncrono], [1 MB (desde 2025)]),
    ([Paquete .zip], [50 MB · 250 MB descomprimido]),
    ([Imagen de contenedor], [10 GB]),
    ([Concurrencia por región], [1 000 (ajustable)]),
  )],
  tarjeta("SQS", color: col.integracion)[#kv(
    ([Tamaño de mensaje], [1 MiB (desde 2025)]),
    ([Retención], [1 min–14 días (4 por defecto)]),
    ([Visibility timeout], [0 s–12 h (30 s por defecto)]),
    ([Long polling], [hasta 20 s]),
    ([Retardo de entrega], [hasta 15 min]),
    ([Mensajes por lote], [10]),
    ([FIFO sin lotes], [300 msg/s por acción]),
  )],
  tarjeta("DynamoDB", color: col.datos)[#kv(
    ([Tamaño de ítem], [400 KB]),
    ([1 RCU], [1 lectura fuerte/s de 4 KB]),
    ([1 WCU], [1 escritura/s de 1 KB]),
    ([Query / Scan], [1 MB por página]),
    ([BatchWrite / BatchGet], [25 / 100 ítems]),
    ([Transacción], [hasta 100 acciones]),
    ([Índices], [20 GSI (ajustable) · 5 LSI]),
    ([Streams], [24 h]),
  )],
  tarjeta("S3", color: col.almacenamiento)[#kv(
    ([Tamaño de objeto], [5 TB históricamente; 50 TB desde finales de 2025]),
    ([Una sola PUT], [hasta 5 GB]),
    ([Multipart], [hasta 10 000 partes de 5 MiB a 5 GiB]),
    ([Peticiones por prefijo], [3 500 escrituras/s · 5 500 lecturas/s]),
    ([Durabilidad (diseño)], [99,999999999 %]),
    ([Buckets por cuenta], [10 000 (ajustable)]),
  )],
  tarjeta("VPC", color: col.redes)[#kv(
    ([CIDR de VPC y subred], [de /16 a /28]),
    ([IPs reservadas por subred], [5]),
    ([VPC por región], [5 (ajustable)]),
    ([Security Groups por ENI], [5 (ajustable)]),
    ([Reglas por Security Group], [60 entrada + 60 salida (ajustable)]),
    ([Reglas por NACL], [20 por sentido (ajustable)]),
    ([Peering], [no transitivo]),
  )],
  tarjeta("EC2, EBS y ELB", color: col.computo)[#kv(
    ([Aviso de interrupción Spot], [2 min]),
    ([Facturación en Linux], [por segundo, mínimo 60 s]),
    ([Metadatos (IMDS)], [169.254.169.254]),
    ([gp3 de base], [3 000 IOPS · 125 MB/s]),
    ([ALB: idle timeout], [60 s por defecto]),
    ([Deregistration delay], [300 s por defecto]),
  )],
  tarjeta("IAM y Organizations", color: col.iam)[#kv(
    ([Usuarios IAM por cuenta], [5 000]),
    ([Grupos por usuario], [10]),
    ([Sesión de un rol], [1–12 h (1 h por defecto)]),
    ([Encadenar roles], [máximo 1 h]),
    ([Política gestionada], [6 144 caracteres]),
    ([SCP], [5 por destino · 5 120 caracteres]),
    ([Niveles de OU], [5]),
  )],
  tarjeta("Observabilidad", color: col.observabilidad)[#kv(
    ([CloudTrail Event history], [90 días]),
    ([Retención de métricas], [15 meses]),
    ([Resolución de métricas], [1 min (alta: 1 s)]),
    ([EC2 básico / detallado], [5 min / 1 min]),
    ([Logs de CloudWatch], [no caducan por defecto]),
  )],
  tarjeta("KMS", color: col.seguridad)[#kv(
    ([Encrypt directo], [hasta 4 KB]),
    ([Más datos], [envelope encryption]),
    ([Espera de borrado], [7–30 días (30 por defecto)]),
    ([Rotación automática], [anual por defecto (90–2 560 días)]),
  )],
  tarjeta("API Gateway, Step Functions, Kinesis", color: col.serverless)[#kv(
    ([Timeout de integración], [29 s por defecto]),
    ([Payload de API Gateway], [10 MB]),
    ([Step Functions Standard], [hasta 1 año]),
    ([Step Functions Express], [hasta 5 min]),
    ([Retención de Kinesis], [24 h–365 días]),
    ([Shard de Kinesis], [entrada 1 MB/s o 1 000 reg./s · salida 2 MB/s]),
  )],
  tarjeta("RDS y Aurora", color: col.datos)[#kv(
    ([Backups automáticos], [hasta 35 días]),
    ([Réplicas de lectura], [hasta 15]),
    ([Failover Multi-AZ], [normalmente 1–2 min]),
    ([Aurora], [6 copias en 3 AZ]),
    ([Aurora Global Database], [retraso típico < 1 s]),
  )],
  tarjeta("Borde y costes", color: col.edge)[#kv(
    ([Certificado para CloudFront], [ACM en #box[us-east-1]]),
    ([TTL por defecto de CloudFront], [24 h]),
    ([Consultas alias de Route 53], [gratuitas]),
    ([Salida a Internet gratis], [100 GB/mes]),
    ([IPv4 pública], [se cobra por hora]),
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
  [Un mensaje para muchos suscriptores], [SNS], [EventBridge si hay que filtrar por contenido],
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
  [Entrar en una instancia sin SSH], [Session Manager], [EC2 Instance Connect],
)
