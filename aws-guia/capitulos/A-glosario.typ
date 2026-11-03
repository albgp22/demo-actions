#import "../theme.typ": *

// ---------------------------------------------------------------------
//  Utilidades locales del apéndice
// ---------------------------------------------------------------------
#let c-glos = col.fundamentos

// Separador de letra (no es un heading: no aparece en el índice)
#let L(letra) = block(above: 10pt, below: 6pt, sticky: true, breakable: false,
  grid(columns: (auto, 1fr), column-gutter: 7pt, align: horizon,
    box(width: 19pt, height: 19pt, radius: 4pt, fill: gradient.linear(c-glos.lighten(10%), c-glos.darken(20%), angle: 90deg),
      align(center + horizon, text(11pt, weight: "black", fill: white, letra))),
    line(length: 100%, stroke: 0.8pt + c-glos.lighten(70%)),
  ))

// Entrada del glosario
#let T(termino, definicion) = block(below: 5.5pt, breakable: false, {
  set par(justify: false, leading: 0.62em)
  set text(8.9pt)
  text(weight: "bold", fill: c-glos.darken(5%), termino)
  h(3pt)
  text(fill: acento, weight: "bold", "·")
  h(3pt)
  definicion
})

// El tema dibuja los títulos de nivel 1 en blanco (para la portada de capítulo):
// en el apéndice, sobre fondo blanco, lo mostramos en el color de texto principal.
#show heading.where(level: 1): it => block(above: 12pt, below: 8pt,
  text(32pt, weight: "extrabold", fill: marino, hyphenate: false, it.body))

#apendice("A", "Glosario", color: col.fundamentos,
  subtitulo: [Los términos y siglas que aparecen a lo largo de la guía, con una definición breve. Las palabras en _cursiva_ dentro de una definición tienen su propia entrada.])

#columns(2, gutter: 16pt)[

#L("A")
#T[ABAC][_Attribute-Based Access Control_. Control de acceso basado en atributos: las políticas comparan etiquetas del principal y del recurso (`aws:PrincipalTag`, `aws:ResourceTag`) en lugar de enumerar recursos.]
#T[Account Factory][Función de _Control Tower_ que crea cuentas nuevas ya configuradas según la _landing zone_.]
#T[ACL][_Access Control List_. En VPC, la _NACL_ filtra el tráfico de una subred; en S3, las ACL son un mecanismo heredado, deshabilitado por defecto en los buckets nuevos.]
#T[ACM][_AWS Certificate Manager_. Emite, gestiona y renueva certificados TLS; los públicos no tienen coste cuando se usan con servicios integrados como ELB, CloudFront o API Gateway.]
#T[Alias (registro)][Registro de _Route 53_ que apunta a un recurso de AWS (CloudFront, ELB, S3…), incluso en el dominio raíz; sus consultas no se cobran.]
#T[ALB][_Application Load Balancer_. Balanceador de capa 7 (HTTP, HTTPS, gRPC, WebSocket) con reglas por ruta, host o cabeceras hacia _target groups_.]
#T[AMI][_Amazon Machine Image_. Plantilla para lanzar instancias EC2 (volumen raíz, permisos y mapeo de dispositivos). Es regional y puede copiarse a otras regiones.]
#T[API Gateway][Servicio gestionado para publicar APIs REST, HTTP y WebSocket con autorización, _throttling_ y transformación de peticiones.]
#T[AppConfig][Servicio de configuración dinámica y _feature flags_ con validación, despliegue gradual y reversión automática por alarmas.]
#T[ARN][_Amazon Resource Name_. Identificador único de un recurso, con la forma `arn:partición:servicio:` `región:cuenta:recurso`.]
#T[ASG][_Auto Scaling group_. Grupo de instancias EC2 con capacidad mínima, deseada y máxima que sustituye las instancias no sanas y escala según políticas.]
#T[Assumed role][Sesión con credenciales temporales obtenida al asumir un _rol_ con `sts:AssumeRole`; su ARN tiene la forma `arn:aws:sts::cuenta:` `assumed-role/rol/sesión`.]
#T[Athena][Servicio serverless para consultar con SQL datos guardados en S3; se paga por datos escaneados.]
#T[Aurora][Base de datos relacional de AWS compatible con MySQL y PostgreSQL, con almacenamiento distribuido en tres AZ y variantes serverless (Serverless v2, DSQL).]
#T[AZ][_Availability Zone_. Uno o más centros de datos con energía y red independientes dentro de una _región_, conectados con baja latencia.]

#L("B")
#T[Backup (AWS Backup)][Copias de seguridad centralizadas de muchos servicios mediante planes, bóvedas (_vaults_) y copias entre cuentas y regiones.]
#T[Bastión][Instancia de salto para llegar a recursos privados; hoy suele sustituirse por _Session Manager_.]
#T[Behavior][Regla de una distribución de CloudFront que asocia un patrón de ruta a un origen y a una política de caché.]
#T[Block Public Access][Configuración de S3 que impide exponer públicamente buckets y objetos; está activada por defecto en los buckets nuevos.]
#T[Blue/green][Estrategia de despliegue que levanta la versión nueva completa en paralelo y cambia todo el tráfico de una vez, con vuelta atrás inmediata.]
#T[Bucket][Contenedor de objetos de S3, con nombre único global, ubicado en una región.]
#T[Bucket policy][Política de recurso JSON de un bucket S3 que controla quién puede acceder a él y en qué condiciones.]
#T[Budgets][Servicio de presupuestos de coste o uso con alertas y acciones cuando el gasto real o previsto supera un umbral.]

#L("C")
#T[Canary][Despliegue que envía primero un pequeño porcentaje del tráfico a la versión nueva y, si las métricas son buenas, el resto.]
#T[CDK][_AWS Cloud Development Kit_. Framework para definir infraestructura con TypeScript, Python, Java, C\#, Go o JavaScript; genera plantillas de _CloudFormation_.]
#T[Change set][Vista previa de los cambios que CloudFormation aplicará a un _stack_, incluido si algún recurso se reemplazará.]
#T[CIDR][Notación de rangos IP con prefijo, como `10.0.0.0/16`: cuanto mayor es el prefijo, menor es el rango.]
#T[CloudFormation][Servicio de infraestructura como código nativo de AWS basado en plantillas YAML o JSON que crean _stacks_.]
#T[CloudFront][Red de entrega de contenidos (CDN) de AWS, con cientos de _edge locations_ en todo el mundo.]
#T[CloudFront Functions][Funciones JavaScript muy ligeras que se ejecutan en el borde para reescribir URL, redirigir o añadir cabeceras.]
#T[CloudHSM][HSM dedicados y de un solo inquilino en tu VPC, para cuando necesitas control exclusivo de las claves; puede integrarse con _KMS_ como almacén de claves personalizado.]
#T[CloudTrail][Registro de auditoría de las llamadas a la API de AWS; el historial de eventos conserva 90 días de eventos de gestión sin configurar nada.]
#T[CloudWatch][Servicio de métricas, logs, alarmas y paneles para recursos y aplicaciones.]
#T[CodeBuild][Servicio gestionado de compilación y pruebas que ejecuta un `buildspec.yml` en contenedores efímeros.]
#T[CodeDeploy][Automatiza despliegues en EC2, servidores on-premises, Lambda y ECS con estrategias in-place, blue/green, canary o lineal.]
#T[CodePipeline][Orquestador de CI/CD por etapas: origen, compilación, pruebas, aprobaciones y despliegue.]
#T[Cognito][Identidad para los usuarios finales de tus aplicaciones: _user pools_ (registro e inicio de sesión) e _identity pools_ (credenciales de AWS).]
#T[Cold start][Arranque en frío: latencia extra cuando Lambda crea un entorno de ejecución nuevo; se mitiga con _SnapStart_ o concurrencia aprovisionada.]
#T[Compute Optimizer][Recomendaciones de tamaño para EC2, Auto Scaling, EBS, Lambda, ECS y RDS basadas en el uso real.]
#T[Config (AWS Config)][Inventario e historial de la configuración de los recursos, con reglas que evalúan su cumplimiento.]
#T[Control plane][Plano de control de Kubernetes (API server, etcd, scheduler…), que gestiona el clúster; en EKS lo opera AWS.]
#T[Control Tower][Servicio que monta y gobierna una _landing zone_ multi-cuenta con controles preventivos, detectivos y proactivos.]
#T[Cost Explorer][Herramienta para analizar y prever el gasto por servicio, cuenta, región o etiqueta.]
#T[Cuota de servicio][Límite de recursos o peticiones por cuenta y región; muchas son ajustables desde Service Quotas.]
#T[CUR][_Cost and Usage Report_. Detalle línea a línea de la factura; hoy se obtiene con Data Exports (CUR 2.0 o formato FOCUS).]

#L("D")
#T[Data key][Clave de datos: clave simétrica que genera _KMS_ (`GenerateDataKey`) para cifrar datos localmente; se guarda cifrada junto a ellos.]
#T[Data lake][Repositorio central, normalmente en S3, con datos en bruto y procesados listos para analítica.]
#T[DAX][_DynamoDB Accelerator_. Caché en memoria compatible con la API de DynamoDB, con latencias de microsegundos.]
#T[DeletionPolicy][Atributo de CloudFormation que decide si un recurso se borra, se conserva o se guarda en una instantánea al eliminar el stack.]
#T[Deployment][Objeto de Kubernetes que declara cuántas réplicas de un _Pod_ deben ejecutarse y gestiona sus actualizaciones progresivas.]
#T[Direct Connect][Conexión de red dedicada y privada entre tu centro de datos y AWS.]
#T[Distribución][Configuración de CloudFront con sus orígenes, _behaviors_, certificados y dominios.]
#T[DLQ][_Dead-letter queue_. Cola que recibe los mensajes que no se han podido procesar tras varios intentos, para analizarlos aparte.]
#T[Drift][Diferencia entre la configuración declarada en el código de IaC y la real, casi siempre por cambios manuales.]
#T[DynamoDB][Base de datos NoSQL clave-valor y de documentos, serverless, con latencia de milisegundos a cualquier escala; ítems de hasta 400 KB.]
#T[DynamoDB Streams][Registro ordenado de los cambios de una tabla durante 24 horas, que puede disparar funciones Lambda.]

#L("E")
#T[EBS][_Elastic Block Store_. Volúmenes de bloque persistentes para EC2, ligados a una AZ (gp3, io2, st1, sc1).]
#T[EC2][_Elastic Compute Cloud_. Máquinas virtuales (instancias) en multitud de tipos y tamaños.]
#T[ECR][_Elastic Container Registry_. Registro privado y público de imágenes de contenedor.]
#T[ECS][_Elastic Container Service_. Orquestador de contenedores de AWS: ejecuta tareas y servicios sobre _Fargate_ o EC2.]
#T[Edge location][Punto de presencia de la red de AWS donde CloudFront cachea contenido y Route 53 responde consultas.]
#T[EFS][_Elastic File System_. Sistema de ficheros NFS gestionado y elástico, compartible entre muchas instancias y AZ.]
#T[EIP][_Elastic IP_. Dirección IPv4 pública estática reservada para tu cuenta; como toda IPv4 pública, se factura por hora.]
#T[EKS][_Elastic Kubernetes Service_. Kubernetes gestionado: AWS opera el plano de control y, con Auto Mode, también los nodos.]
#T[EKS Pod Identity][Forma de dar un rol IAM a los pods de EKS mediante asociaciones y un agente en el nodo; más sencilla que _IRSA_.]
#T[ElastiCache][Caché en memoria gestionada compatible con Valkey, Redis OSS y Memcached.]
#T[ELB][_Elastic Load Balancing_. Familia de balanceadores: _ALB_, _NLB_, _GWLB_ y el Classic, heredado.]
#T[Encryption context][Pares clave-valor no secretos vinculados a una operación de _KMS_: hay que repetirlos al descifrar y quedan registrados en CloudTrail.]
#T[Endpoint de VPC][Acceso privado a servicios de AWS sin pasar por Internet: de gateway (S3 y DynamoDB, gratuitos) o de interfaz (_PrivateLink_).]
#T[ENI][_Elastic Network Interface_. Interfaz de red virtual con IP privada, _Security Groups_ y, opcionalmente, IP pública.]
#T[Envelope encryption][Cifrado de sobre: los datos se cifran con una _data key_ y esta, con una _KMS key_; así los datos nunca viajan a KMS.]
#T[Event source mapping][Recurso de Lambda que lee de SQS, Kinesis o DynamoDB Streams e invoca la función con lotes de registros.]
#T[EventBridge][Bus de eventos serverless que enruta eventos de AWS, de SaaS y de tus aplicaciones mediante reglas; incluye un programador (Scheduler).]
#T[External ID][Valor que un tercero debe enviar al asumir un rol en tu cuenta; protege del problema del «diputado confundido».]

#L("F")
#T[Fan-out][Patrón en el que un mensaje se replica a varios consumidores, por ejemplo un tema SNS suscrito por varias colas SQS.]
#T[Fargate][Motor serverless para contenedores en ECS y EKS: pagas por la vCPU y la memoria de cada tarea, sin gestionar instancias.]
#T[Feature flag][Interruptor de configuración que activa una funcionalidad sin redesplegar, por ejemplo con _AppConfig_.]
#T[FIFO (cola)][Cola de SQS que mantiene el orden y procesa cada mensaje exactamente una vez dentro de su grupo.]
#T[FinOps][Práctica y cultura de gestionar el coste de la nube de forma compartida entre ingeniería, finanzas y negocio.]
#T[Firehose][_Amazon Data Firehose_ (antes Kinesis Data Firehose). Entrega datos en streaming a S3, Redshift, OpenSearch y otros destinos, con búfer y transformación.]

#L("G")
#T[Glacier][Clases de almacenamiento de archivo de S3 (Instant Retrieval, Flexible Retrieval y Deep Archive), muy baratas y con distintos tiempos de recuperación.]
#T[Global Accelerator][Red global de AWS con IPs anycast estáticas que acelera el tráfico TCP/UDP y conmuta entre regiones.]
#T[Glue][Servicio serverless de integración de datos: catálogo, _crawlers_ y trabajos ETL sobre Spark.]
#T[Grant][Permiso delegable sobre una _KMS key_, que los servicios de AWS usan para cifrar y descifrar en tu nombre.]
#T[Graviton][Procesadores Arm diseñados por AWS, con mejor relación precio-rendimiento en EC2, Lambda, Fargate, RDS y otros servicios.]
#T[GuardDuty][Detección de amenazas con aprendizaje automático sobre CloudTrail, VPC Flow Logs, DNS y otras fuentes.]
#T[GWLB][_Gateway Load Balancer_. Inserta de forma transparente appliances de red de terceros (cortafuegos, IDS).]

#L("H")
#T[Health check][Comprobación periódica del estado de un destino (ELB, Route 53, Auto Scaling) para dejar de enviarle tráfico si falla.]
#T[Helm][Gestor de paquetes de Kubernetes: instala aplicaciones como _charts_ parametrizables.]
#T[Hosted zone][Zona hospedada: contenedor de los registros DNS de un dominio en Route 53, pública o privada (asociada a VPC).]

#L("I")
#T[IaC][Infraestructura como código: definir la infraestructura en ficheros versionados que una herramienta aplica de forma repetible.]
#T[IAM][_Identity and Access Management_. Servicio global que controla quién puede hacer qué sobre qué recursos.]
#T[IAM Identity Center][Acceso centralizado de las personas a varias cuentas y aplicaciones mediante _permission sets_; es el antiguo AWS SSO.]
#T[Idempotencia][Propiedad de una operación que da el mismo resultado aunque se repita; imprescindible con entregas «al menos una vez».]
#T[IGW][_Internet Gateway_. Conecta una VPC con Internet; una subred es pública si su tabla de rutas apunta a él.]
#T[IMDS][_Instance Metadata Service_. Servicio en `169.254.169.254` que da a una instancia sus metadatos y credenciales temporales; IMDSv2 exige un token de sesión.]
#T[Ingress][Reglas HTTP de entrada a los servicios de un clúster de Kubernetes; en EKS, el AWS Load Balancer Controller las convierte en un ALB.]
#T[Inspector][Escaneo continuo de vulnerabilidades en instancias EC2, imágenes de ECR y funciones Lambda.]
#T[Instance profile][Contenedor que entrega un _rol_ IAM a una instancia EC2 para que obtenga credenciales temporales.]
#T[Invalidación][Orden para que CloudFront descarte objetos de su caché antes de que expire su TTL.]
#T[IOPS][Operaciones de entrada/salida por segundo de un volumen de almacenamiento.]
#T[IRSA][_IAM Roles for Service Accounts_. Asocia roles IAM a cuentas de servicio de Kubernetes mediante el proveedor OIDC del clúster de EKS.]

#L("J")
#T[JWT][_JSON Web Token_. Token firmado con afirmaciones (_claims_) sobre un usuario; Cognito los emite y API Gateway los valida.]

#L("K")
#T[Karpenter][Autoescalador de nodos de Kubernetes, de código abierto, que lanza la instancia más adecuada para los pods pendientes; EKS Auto Mode lo integra.]
#T[Key policy][Política de recurso de una _KMS key_: toda clave tiene exactamente una y es la base de su control de acceso.]
#T[Kinesis Data Streams][Streaming de datos en tiempo real, ordenado por clave de partición, con varios consumidores y relectura.]
#T[KMS][_Key Management Service_. Crea y gestiona claves de cifrado y las usa desde los servicios de AWS, con cada uso auditado en CloudTrail.]
#T[KMS key][Clave lógica de KMS (antes llamada CMK) cuyo material nunca sale del servicio sin cifrar; puede estar gestionada por AWS o por el cliente.]
#T[kubelet][Agente que se ejecuta en cada _nodo_ de Kubernetes y arranca y vigila los contenedores de los pods asignados.]
#T[Kubernetes][Orquestador de contenedores de código abierto; en AWS se ofrece gestionado con _EKS_.]

#L("L")
#T[Lake Formation][Gobierno de _data lakes_ en S3 con permisos finos por base de datos, tabla, columna y fila.]
#T[Lambda][Funciones serverless que se ejecutan por eventos, hasta 15 minutos y 10 240 MB de memoria, con pago por uso.]
#T[Lambda\@Edge][Funciones Lambda que se ejecutan en las ubicaciones regionales de CloudFront para personalizar peticiones y respuestas.]
#T[Landing zone][Entorno multi-cuenta bien diseñado (cuentas, OU, políticas y logs centralizados) desde el que crecer de forma segura.]
#T[Launch template][Plantilla versionada con la configuración de lanzamiento de instancias (AMI, tipo, red, _user data_) que usa Auto Scaling.]
#T[Lifecycle (S3)][Reglas que mueven objetos a clases más baratas o los eliminan según su antigüedad.]
#T[Listener][Proceso de un balanceador que escucha en un puerto y protocolo y aplica reglas para reenviar a _target groups_.]
#T[Log group][Agrupación de flujos de logs de CloudWatch Logs, con su propia retención y permisos.]
#T[Long polling][Recepción de mensajes de SQS que espera hasta 20 segundos a que lleguen mensajes, lo que reduce las peticiones vacías.]

#L("M")
#T[Macie][Descubre y clasifica datos sensibles (como datos personales) en S3 mediante aprendizaje automático.]
#T[Managed policy][Política IAM independiente y reutilizable, creada por AWS o por el cliente, que se adjunta a varias identidades.]
#T[MFA][Autenticación multifactor: un segundo factor (app TOTP, llave de seguridad, _passkey_) además de la contraseña.]
#T[Mínimo privilegio][Principio de conceder solo los permisos imprescindibles para cada tarea.]
#T[Modelo de responsabilidad compartida][AWS protege la infraestructura de la nube; el cliente, lo que pone en ella: datos, configuración, identidades y aplicaciones.]
#T[Multi-AZ][Despliegue repartido en varias zonas de disponibilidad para tolerar la caída de una de ellas.]
#T[Multipart upload][Subida de un objeto a S3 en partes que se envían en paralelo; obligatoria por encima de 5 GB.]

#L("N")
#T[NACL][_Network ACL_. Cortafuegos sin estado a nivel de subred, con reglas numeradas de permitir y denegar.]
#T[Namespace][Partición lógica de un clúster de Kubernetes para aislar recursos, cuotas y permisos entre equipos o entornos.]
#T[NAT Gateway][Permite que los recursos de subredes privadas salgan a Internet sin ser accesibles desde fuera; se paga por hora y por GB procesado.]
#T[Nested stack][Stack de CloudFormation incluido como recurso dentro de otro para reutilizar componentes.]
#T[NLB][_Network Load Balancer_. Balanceador de capa 4 (TCP, UDP, TLS) de latencia muy baja, con IP estática por AZ.]
#T[Nodo][Máquina de un clúster de Kubernetes (una instancia EC2 o capacidad de Fargate) donde se ejecutan los pods.]

#L("O")
#T[OAC][_Origin Access Control_. Mecanismo con el que CloudFront firma sus peticiones a un bucket S3 privado; sustituye a OAI.]
#T[OIDC][_OpenID Connect_. Estándar de identidad sobre OAuth 2.0; permite a GitHub Actions o a EKS obtener credenciales de AWS sin claves.]
#T[On-Demand][Modelo de compra de pago por uso, sin compromiso.]
#T[Organizations][Gestión centralizada de varias cuentas con _OU_, facturación consolidada y políticas como las _SCP_ y _RCP_.]
#T[Origen][Servidor del que CloudFront obtiene el contenido: un bucket S3, un ALB, API Gateway o cualquier servidor HTTP.]
#T[OU][_Organizational Unit_. Grupo de cuentas dentro de Organizations al que se aplican políticas que se heredan.]

#L("P")
#T[Parameter Store][Almacén jerárquico de configuración y secretos de Systems Manager.]
#T[Partition key][Clave de partición: atributo que DynamoDB o Kinesis usan para repartir los datos entre particiones.]
#T[Peering de VPC][Conexión privada entre dos VPC, incluso de cuentas o regiones distintas; no es transitiva.]
#T[Permission boundary][Límite de permisos: política gestionada que fija el máximo que puede tener un usuario o rol, aunque sus políticas concedan más.]
#T[Permission set][Plantilla de permisos de IAM Identity Center que se materializa como un _rol_ en cada cuenta asignada.]
#T[Pilot light][Estrategia de recuperación ante desastres con datos replicados e infraestructura mínima en otra región, sin servidores de aplicación en marcha.]
#T[Placement group][Estrategia de colocación de instancias EC2: _cluster_ (baja latencia), _spread_ (separadas) o _partition_.]
#T[Pod][Unidad mínima de Kubernetes: uno o varios contenedores que comparten red y almacenamiento.]
#T[Política IAM][Documento JSON con declaraciones `Effect`, `Action`, `Resource` y `Condition` que concede o deniega permisos.]
#T[Política de recurso][Política asociada a un recurso (bucket, cola, _KMS key_, rol) que indica qué _principales_ pueden usarlo.]
#T[Principal][Quien hace una petición a AWS: usuario, rol, servicio, cuenta o identidad federada; en una política de recurso, a quién se aplica.]
#T[PrivateLink][Tecnología para exponer y consumir servicios de forma privada mediante endpoints de interfaz en tu VPC.]
#T[Provisioned concurrency][Entornos de Lambda preinicializados que eliminan el _cold start_ a cambio de un coste fijo.]

#L("Q")
#T[Quick Sight][Servicio de BI y paneles de AWS (antes QuickSight), integrado en Amazon Quick Suite.]

#L("R")
#T[RCP][_Resource Control Policy_. Política de Organizations (2024) que limita los permisos máximos sobre los recursos de las cuentas, sea quien sea el solicitante.]
#T[RDS][_Relational Database Service_. Bases de datos relacionales gestionadas: PostgreSQL, MySQL, MariaDB, Oracle, SQL Server y Db2.]
#T[Read replica][Réplica de lectura: copia asíncrona de una base de datos para escalar lecturas o como base de recuperación.]
#T[Redshift][_Data warehouse_ columnar gestionado para analítica a gran escala, también en versión serverless.]
#T[Región][Área geográfica con varias AZ aisladas entre sí; la mayoría de servicios son regionales.]
#T[Reserved Instance][Descuento a cambio de comprometerse a usar una configuración concreta durante 1 o 3 años.]
#T[Rightsizing][Ajustar el tamaño de los recursos a su uso real.]
#T[Rol IAM][Identidad sin credenciales permanentes que asumen usuarios, servicios o cuentas para obtener credenciales temporales.]
#T[Rolling][Despliegue por lotes en el que la versión antigua y la nueva conviven durante el proceso.]
#T[Root user][Usuario raíz: identidad creada con la cuenta, con acceso total. Protégelo con MFA y no lo uses en el día a día.]
#T[Route 53][DNS gestionado de AWS, con registro de dominios, _health checks_ y políticas de enrutamiento.]
#T[Route table][Tabla de rutas: reglas que deciden a dónde se envía el tráfico que sale de una subred.]
#T[RPO y RTO][_Recovery Point Objective_ (cuántos datos se pueden perder) y _Recovery Time Objective_ (cuánto tiempo sin servicio) ante un desastre.]

#L("S")
#T[S3][_Simple Storage Service_. Almacenamiento de objetos diseñado para once nueves de durabilidad, con clases según coste y frecuencia de acceso.]
#T[SAM][_Serverless Application Model_. Extensión de CloudFormation y CLI para aplicaciones serverless.]
#T[Savings Plans][Descuento a cambio de un compromiso de gasto por hora durante 1 o 3 años según el tipo (Compute, EC2 Instance, Database…).]
#T[SCP][_Service Control Policy_. Política de Organizations que fija los permisos máximos de las identidades de las cuentas afectadas; no concede permisos.]
#T[Secrets Manager][Almacena secretos (contraseñas, claves de API) cifrados con KMS y los rota automáticamente.]
#T[Security Group][Cortafuegos con estado a nivel de interfaz de red; solo admite reglas de permitir.]
#T[Security Hub][Panel central de hallazgos de seguridad y de comprobaciones de cumplimiento frente a estándares.]
#T[Serverless][Modelo en el que no gestionas servidores, la capacidad escala sola y pagas por uso.]
#T[Service (Kubernetes)][Punto de acceso estable (IP y nombre DNS) a un conjunto de pods; puede exponerse con un balanceador.]
#T[Service Connect][Funcionalidad de ECS para que los servicios se descubran y se comuniquen por nombre, con reintentos y métricas.]
#T[Service-linked role][Rol predefinido vinculado a un servicio de AWS, que el servicio crea y usa para actuar en tu nombre; solo él puede asumirlo.]
#T[Session Manager][Función de Systems Manager para abrir sesiones de shell en instancias sin SSH ni bastión, con auditoría.]
#T[Shield][Protección contra DDoS: Standard, gratuita y automática, y Advanced, de pago, con equipo de respuesta y protección de costes.]
#T[SnapStart][Optimización de Lambda que restaura una instantánea del entorno ya inicializado para reducir el _cold start_.]
#T[Snapshot][Copia puntual e incremental de un volumen EBS o de una base de datos.]
#T[SNS][_Simple Notification Service_. Mensajería pub/sub: un mensaje publicado en un tema llega a todos sus suscriptores.]
#T[Sort key][Segundo atributo de la clave primaria de DynamoDB, que ordena los ítems dentro de una partición.]
#T[Spot][Capacidad sobrante de EC2 con grandes descuentos que AWS puede recuperar con un aviso de 2 minutos.]
#T[SQS][_Simple Queue Service_. Colas de mensajes gestionadas, estándar o _FIFO_, para desacoplar productores y consumidores.]
#T[SSE][Cifrado del lado del servidor: el servicio cifra los datos en reposo. En S3, SSE-S3 se aplica por defecto y SSE-KMS usa claves de KMS.]
#T[Stack][Conjunto de recursos de CloudFormation que se crean, actualizan y borran como una unidad.]
#T[StackSets][Despliegue del mismo stack de CloudFormation en varias cuentas y regiones con una sola operación.]
#T[Step Functions][Orquestación serverless de flujos de trabajo definidos como máquinas de estados.]
#T[STS][_Security Token Service_. Emite credenciales temporales (AssumeRole, federación) para identidades de AWS.]
#T[Subred][Rango de IPs de una VPC ubicado en una sola AZ; es pública si su tabla de rutas apunta a un _IGW_.]
#T[Systems Manager][Conjunto de herramientas para operar flotas: _Session Manager_, _Parameter Store_, Patch Manager, Run Command…]

#L("T")
#T[Tag][Etiqueta: par clave-valor asociado a un recurso para organizarlo, controlar el acceso (_ABAC_) y asignar costes.]
#T[Target group][Conjunto de destinos (instancias, IPs, funciones Lambda) a los que un balanceador envía tráfico y cuya salud comprueba.]
#T[Task definition][Plantilla de ECS que describe los contenedores de una tarea: imagen, CPU, memoria, puertos, rol y logs.]
#T[Terraform][Herramienta de IaC de HashiCorp, multiproveedor, con lenguaje HCL y un fichero de estado.]
#T[Throttling][Limitación de la tasa de peticiones; al superarla, el servicio responde con errores (por ejemplo, HTTP 429).]
#T[Transit Gateway][Hub regional que interconecta VPC y redes on-premises de forma transitiva.]
#T[Trust policy][Política de confianza: política de recurso de un _rol_ que indica qué principales pueden asumirlo.]
#T[Trusted Advisor][Comprobaciones automáticas de buenas prácticas de coste, seguridad, rendimiento, tolerancia a fallos y cuotas.]
#T[TTL][_Time To Live_. Tiempo que un dato puede conservarse en caché (DNS, CloudFront) o tras el que expira (DynamoDB).]

#L("U")
#T[UpdateReplacePolicy][Atributo de CloudFormation que decide qué hacer con el recurso antiguo cuando una actualización lo reemplaza.]
#T[User data][Script que se ejecuta al arrancar por primera vez una instancia EC2.]
#T[Usuario IAM][Identidad con credenciales de larga duración (contraseña o claves de acceso); hoy se prefieren _roles_ e _IAM Identity Center_.]

#L("V")
#T[Versionado (S3)][Conserva todas las versiones de cada objeto para recuperar borrados y sobrescrituras.]
#T[Visibility timeout][Tiempo durante el que un mensaje de SQS recibido queda oculto al resto de consumidores; si no se borra, vuelve a la cola.]
#T[VPC][_Virtual Private Cloud_. Red virtual aislada, dentro de una región, en la que despliegas tus recursos.]
#T[VPC Flow Logs][Registros con los metadatos del tráfico IP de una VPC, subred o interfaz, enviados a CloudWatch Logs o S3.]
#T[VPN (Site-to-Site)][Túneles IPsec cifrados sobre Internet entre tu red y una VPC o un Transit Gateway.]

#L("W")
#T[WAF][_AWS WAF_. Cortafuegos de aplicaciones web para CloudFront, ALB, API Gateway y otros, con reglas gestionadas y límites de tasa.]
#T[Warm standby][Estrategia de recuperación ante desastres con una copia completa funcionando a escala reducida en otra región.]
#T[Well-Architected][Marco de buenas prácticas de AWS en seis pilares: excelencia operativa, seguridad, fiabilidad, eficiencia del rendimiento, costes y sostenibilidad.]

#L("X")
#T[X-Ray][Trazas distribuidas para seguir una petición a través de varios servicios y localizar latencias y errores.]

#L("Z")
#T[Zona de disponibilidad][Véase _AZ_.]
]
