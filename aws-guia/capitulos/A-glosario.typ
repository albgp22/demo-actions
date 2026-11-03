#import "../theme.typ": *

// ---------------------------------------------------------------------
//  Utilidades locales del apéndice
// ---------------------------------------------------------------------
#let c-glos = col.fundamentos

// Separador de letra (no es un heading: no aparece en el índice)
#let L(letra) = block(above: 8pt, below: 5pt, sticky: true, breakable: false,
  grid(columns: (auto, 1fr), column-gutter: 7pt, align: horizon,
    box(width: 19pt, height: 19pt, radius: 4pt, fill: gradient.linear(c-glos.lighten(10%), c-glos.darken(20%), angle: 90deg),
      align(center + horizon, text(11pt, weight: "black", fill: white, letra))),
    line(length: 100%, stroke: 0.8pt + c-glos.lighten(70%)),
  ))

// Entrada del glosario
#let T(termino, definicion) = block(below: 4.6pt, breakable: false, {
  set par(justify: false, leading: 0.6em)
  set text(8.6pt)
  text(weight: "bold", fill: c-glos.darken(5%), termino)
  h(3pt)
  text(fill: acento, weight: "bold", "·")
  h(3pt)
  definicion
})


#apendice("A", "Glosario", color: col.fundamentos,
  subtitulo: [Los términos y siglas que aparecen a lo largo de la guía, con una definición breve. Cada sigla empieza con su desarrollo en cursiva; dentro de una definición, la cursiva señala un término que tiene su propia entrada.])

#columns(2, gutter: 16pt)[

#L("A")
#T[ABAC][_Attribute-Based Access Control_. Control de acceso basado en atributos: las políticas comparan etiquetas del principal y del recurso (`aws:PrincipalTag`, `aws:ResourceTag`) en lugar de enumerar recursos.]
#T[Access key][Clave de acceso (ID y secreto) de un _usuario IAM_ para la CLI o los SDK. Credencial de larga duración: mejor _roles_ o _IAM Identity Center_.]
#T[Account Factory][Función de _Control Tower_ que crea cuentas nuevas ya configuradas según la _landing zone_.]
#T[ACL][_Access Control List_. En VPC, la _NACL_ filtra el tráfico de una subred; en S3, las ACL son un mecanismo heredado, desactivado en los buckets nuevos.]
#T[ACM][_AWS Certificate Manager_. Emite y renueva certificados _TLS_; los públicos son gratuitos con servicios integrados como ELB, CloudFront o API Gateway.]
#T[ALB][_Application Load Balancer_. Balanceador de capa 7 (HTTP, HTTPS, gRPC, WebSocket) con reglas por ruta, host o cabeceras hacia _target groups_.]
#T[Alias][En _Route 53_, registro que apunta a un recurso de AWS (CloudFront, ELB…), incluso en el dominio raíz, sin coste por consulta. En Lambda y KMS, nombre de una versión o de una clave que se reasigna sin tocar a los clientes.]
#T[AMI][_Amazon Machine Image_. Plantilla para lanzar instancias EC2 (volumen raíz, permisos, mapeo de dispositivos); es regional, pero se puede copiar a otras.]
#T[API Gateway][Servicio para publicar API REST, HTTP y WebSocket con autorización, _throttling_ y transformación de peticiones.]
#T[AppConfig][Configuración dinámica y _feature flags_ con validación, despliegue gradual y reversión automática por alarmas.]
#T[ARN][_Amazon Resource Name_. Identificador único de un recurso, con la forma `arn:partición:servicio:` `región:cuenta:recurso`.]
#T[ASG][_Auto Scaling group_. Grupo de instancias EC2 con capacidad mínima, deseada y máxima que sustituye las no sanas y escala según políticas.]
#T[Assumed role][Sesión con credenciales temporales obtenida al asumir un _rol_ (`sts:AssumeRole`); su ARN tiene la forma `arn:aws:sts::cuenta:` `assumed-role/rol/sesión`.]
#T[Athena][Consultas SQL serverless sobre datos guardados en S3; se paga por datos escaneados.]
#T[Aurora][Base de datos relacional compatible con MySQL y PostgreSQL, con almacenamiento en tres AZ; ofrece Serverless v2 (escala en ACU, incluso a 0), Global Database (multirregión) y DSQL (distribuida).]
#T[AZ][_Availability Zone_. Uno o más centros de datos con energía y red independientes dentro de una _región_. Su nombre (`eu-west-1a`) puede variar entre cuentas; su AZ ID (`euw1-az1`), no.]

#L("B")
#T[Backup (AWS Backup)][Copias de seguridad centralizadas de muchos servicios, con planes, bóvedas y copias entre cuentas y regiones.]
#T[Backup & restore][La estrategia de recuperación ante desastres más barata y lenta (RTO de horas): solo copias en otra región, y todo se recrea al activar el plan.]
#T[Bastión][Instancia de salto para llegar a recursos privados; hoy suele sustituirse por _Session Manager_.]
#T[Behavior][Regla de una distribución de CloudFront que asocia un patrón de ruta a un origen y a una política de caché.]
#T[Block Public Access][Ajuste de S3 que impide exponer públicamente buckets y objetos; activado por defecto en los buckets nuevos.]
#T[Blue/green][Despliegue que levanta la versión nueva completa en paralelo y cambia todo el tráfico de una vez, con vuelta atrás inmediata.]
#T[Bucket][Contenedor de objetos de S3, con nombre único global, ubicado en una región.]
#T[Bucket policy][Política de recurso de un bucket S3: quién puede acceder a él y en qué condiciones.]
#T[Budgets][Presupuestos de coste o uso con alertas y acciones si el gasto real o previsto supera un umbral.]

#L("C")
#T[Canary][Despliegue que envía primero un pequeño porcentaje del tráfico a la versión nueva y, si las métricas son buenas, el resto.]
#T[CDK][_AWS Cloud Development Kit_. Define infraestructura con TypeScript, Python, Java, C\#, Go o JavaScript a partir de piezas llamadas constructs; genera plantillas de _CloudFormation_.]
#T[Change set][Vista previa de los cambios que CloudFormation aplicará a un _stack_, incluido si algún recurso se reemplazará.]
#T[CIDR][Notación de rangos IP con prefijo (`10.0.0.0/16`): cuanto mayor es el prefijo, menor es el rango.]
#T[CloudFormation][IaC nativa de AWS: plantillas YAML o JSON que crean _stacks_; las funciones intrínsecas (`!Ref`, `!GetAtt`…) calculan valores al desplegar.]
#T[CloudFront][Red de entrega de contenidos (CDN) de AWS, con cientos de _edge locations_ en todo el mundo.]
#T[CloudFront Functions][Funciones JavaScript muy ligeras que se ejecutan en el borde para reescribir URL, redirigir o añadir cabeceras.]
#T[CloudHSM][_HSM_ dedicados y de un solo inquilino en tu VPC, con control exclusivo de las claves; puede servir a _KMS_ como almacén de claves personalizado.]
#T[CloudTrail][Auditoría de las llamadas a la API. Guarda 90 días de eventos de gestión sin configurar nada; un trail los entrega a S3 para conservarlos más tiempo.]
#T[CloudWatch][Métricas, logs, alarmas y paneles para recursos y aplicaciones.]
#T[CodeBuild][Compilación y pruebas gestionadas: ejecuta un `buildspec.yml` en contenedores efímeros.]
#T[CodeCommit][Repositorios Git gestionados de AWS. Cerró a nuevos clientes en julio de 2024 y volvió a abrirse a ellos el 25 de noviembre de 2025.]
#T[CodeDeploy][Automatiza despliegues en EC2, servidores on-premises, Lambda y ECS: in-place, blue/green, canary o lineal.]
#T[CodePipeline][Orquesta el CI/CD por etapas: origen, compilación, pruebas, aprobación y despliegue.]
#T[Cognito][Identidad para los usuarios de tus aplicaciones: user pools (registro e inicio de sesión) e identity pools (credenciales de AWS).]
#T[Cold start][Arranque en frío: latencia extra cuando Lambda crea un entorno de ejecución nuevo; se mitiga con _SnapStart_ o _provisioned concurrency_.]
#T[Compute Optimizer][Recomendaciones de tamaño para EC2, Auto Scaling, EBS, Lambda, ECS y RDS basadas en el uso real.]
#T[Config (AWS Config)][Inventario e historial de la configuración de los recursos, con reglas que evalúan su cumplimiento.]
#T[Confused deputy][«Ayudante confundido»: alguien engaña a un servicio o a un tercero con permisos legítimos para que actúe sobre recursos ajenos; lo evitan el _External ID_ y condiciones como `aws:SourceArn`.]
#T[Control plane][Plano de control de Kubernetes (API server, etcd, scheduler…), que gestiona el clúster; en EKS lo opera AWS.]
#T[Control Tower][Monta y gobierna una _landing zone_ con controles preventivos, detectivos y proactivos.]
#T[Cost Explorer][Análisis y previsión del gasto por servicio, cuenta, región o etiqueta.]
#T[Cuenta de administración][_Management account_. La que crea la organización en _Organizations_, paga la factura consolidada y gestiona las políticas; las _SCP_ no la limitan, así que no aloja cargas de trabajo.]
#T[Cuota de servicio][Límite de recursos o peticiones por cuenta y región; muchas se pueden ampliar en Service Quotas.]
#T[CUR][_Cost and Usage Report_. Detalle línea a línea de la factura; hoy se obtiene con Data Exports (CUR 2.0 o FOCUS).]

#L("D")
#T[Data key][Clave de datos: clave simétrica que genera _KMS_ (`GenerateDataKey`) para cifrar datos en local; se guarda cifrada junto a ellos.]
#T[Data lake][Repositorio central, normalmente en S3, con datos en bruto y procesados listos para analítica.]
#T[DAX][_DynamoDB Accelerator_. Caché en memoria compatible con la API de DynamoDB, con latencias de microsegundos.]
#T[DeletionPolicy][Atributo de CloudFormation que decide si un recurso se borra, se conserva o se guarda en un snapshot al eliminar el stack.]
#T[Deployment][Objeto de Kubernetes que mantiene N réplicas de un _pod_ sin estado y las actualiza poco a poco (para aplicaciones con estado, StatefulSet; un pod por _nodo_, DaemonSet).]
#T[Direct Connect][Conexión de red dedicada y privada entre tu centro de datos y AWS.]
#T[Distribución][Configuración de CloudFront con sus orígenes, _behaviors_, certificados y dominios.]
#T[DLQ][_Dead-letter queue_. Cola que recibe los mensajes que no se han podido procesar tras varios intentos, para analizarlos aparte.]
#T[Drift][Diferencia entre la configuración declarada en la IaC y la real, casi siempre por cambios manuales.]
#T[DynamoDB][Base de datos NoSQL clave-valor y de documentos, serverless, con latencia de milisegundos a cualquier escala e ítems de hasta 400 KB. Las global tables la replican en varias regiones.]
#T[DynamoDB Streams][Registro ordenado de los cambios de una tabla durante 24 horas, que puede disparar funciones Lambda.]

#L("E")
#T[EBS][_Elastic Block Store_. Volúmenes de bloque persistentes para EC2, ligados a una AZ (gp3, io2…).]
#T[EC2][_Elastic Compute Cloud_. Máquinas virtuales (instancias) de multitud de tipos y tamaños.]
#T[ECR][_Elastic Container Registry_. Registro privado y público de imágenes de contenedor.]
#T[ECS][_Elastic Container Service_. Orquestador de contenedores de AWS: ejecuta tareas y servicios sobre _Fargate_ o EC2.]
#T[Edge location][Punto de presencia de la red de AWS donde CloudFront cachea contenido y Route 53 responde consultas.]
#T[EFS][_Elastic File System_. Sistema de ficheros NFS gestionado y elástico, compartible entre muchas instancias y AZ.]
#T[EKS][_Elastic Kubernetes Service_. Kubernetes gestionado: AWS opera el plano de control y, con Auto Mode, también los nodos.]
#T[EKS Pod Identity][Forma de dar un rol IAM a los pods de EKS mediante asociaciones y un agente en el nodo; más sencilla que _IRSA_.]
#T[Elastic IP][IPv4 pública estática reservada para tu cuenta (a veces abreviada EIP); como toda IPv4 pública, se factura por hora.]
#T[ElastiCache][Caché en memoria gestionada compatible con Valkey, Redis OSS y Memcached.]
#T[ELB][_Elastic Load Balancing_. Familia de balanceadores: _ALB_, _NLB_, _GWLB_ y el Classic, heredado.]
#T[Encryption context][Pares clave-valor no secretos vinculados a una operación de _KMS_: hay que repetirlos al descifrar y quedan registrados en CloudTrail.]
#T[Endpoint de VPC][Acceso privado a servicios de AWS sin pasar por Internet: de gateway (S3 y DynamoDB, gratuitos) o de interfaz (_PrivateLink_).]
#T[ENI][_Elastic Network Interface_. Interfaz de red con IP privada, _Security Groups_ y, opcionalmente, IP pública.]
#T[Envelope encryption][Cifrado envolvente: los datos se cifran con una _data key_ y esta, con una _KMS key_; así los datos nunca viajan a KMS.]
#T[Event source mapping][Recurso de Lambda que lee de SQS, Kinesis o DynamoDB Streams e invoca la función con lotes de registros.]
#T[EventBridge][Bus de eventos serverless que enruta eventos de AWS, de SaaS y de tus aplicaciones mediante reglas; incluye un programador (Scheduler).]
#T[Execution role][En Lambda, el rol que asume la función; en ECS, el del agente, que descarga la imagen, lee secretos y envía logs (el código usa el _task role_).]
#T[External ID][Valor que un tercero debe enviar al asumir un rol en tu cuenta; protege del _confused deputy_.]

#L("F")
#T[Failover][Conmutación por error: el servicio pasa automáticamente a una réplica o a otra región cuando falla la principal (RDS Multi-AZ, registros de failover de Route 53).]
#T[Fan-out][Patrón en el que un mensaje se replica a varios consumidores, por ejemplo un tema SNS suscrito por varias colas SQS.]
#T[Fargate][Motor serverless para contenedores en ECS y EKS: pagas por la vCPU y la memoria de cada tarea, sin gestionar instancias.]
#T[Feature flag][Interruptor que activa una funcionalidad sin redesplegar, por ejemplo con _AppConfig_.]
#T[Federación][Acceso con identidades de un proveedor externo (IdP) mediante _SAML_ u _OIDC_, sin crear _usuarios IAM_: el IdP autentica y AWS entrega credenciales temporales.]
#T[FIFO (cola)][Cola de SQS que conserva el orden dentro de cada grupo de mensajes y descarta duplicados (procesamiento exactamente una vez).]
#T[FinOps][Práctica de gestionar el coste de la nube de forma compartida entre ingeniería, finanzas y negocio.]
#T[Firehose][_Amazon Data Firehose_ (antes Kinesis Data Firehose). Entrega datos en streaming a S3, Redshift u OpenSearch, con búfer y transformación.]

#L("G")
#T[Glacier][Clases de archivo de S3 (Instant Retrieval, Flexible Retrieval y Deep Archive), muy baratas y con distintos tiempos de recuperación.]
#T[Global Accelerator][Red global de AWS con IP anycast estáticas que acelera el tráfico TCP/UDP y conmuta entre regiones.]
#T[Glue][Integración de datos serverless: catálogo, crawlers que descubren esquemas y ETL sobre Spark.]
#T[Grant][Permiso puntual sobre una _KMS key_ para un _principal_ concreto, que se crea y revoca por API sin tocar la _key policy_; los servicios lo usan para cifrar y descifrar en tu nombre.]
#T[Graviton][Procesadores Arm de AWS, con mejor relación precio-rendimiento en EC2, Lambda, Fargate, RDS y otros servicios.]
#T[Grupo IAM][Conjunto de _usuarios IAM_ que heredan las políticas del grupo. No es un _principal_: no puede asumir roles ni aparecer en una política de recurso.]
#T[GSI y LSI][Índices secundarios de DynamoDB: el global (GSI) usa otra clave de partición y se crea en cualquier momento; el local (LSI) comparte la de la tabla y solo se define al crearla.]
#T[GuardDuty][Detección de amenazas con aprendizaje automático sobre CloudTrail, VPC Flow Logs, DNS y otras fuentes.]
#T[GWLB][_Gateway Load Balancer_. Inserta de forma transparente appliances de red de terceros (cortafuegos, IDS).]

#L("H")
#T[Health check][Comprobación periódica del estado de un destino (ELB, Route 53, Auto Scaling) para dejar de enviarle tráfico si falla.]
#T[Helm][Gestor de paquetes de Kubernetes: instala aplicaciones como charts parametrizables.]
#T[Hosted zone][Zona alojada: contenedor de los registros DNS de un dominio en Route 53, pública o privada (asociada a VPC).]
#T[HSM][_Hardware Security Module_. Dispositivo resistente a manipulaciones que genera y guarda claves y opera con ellas por dentro; _KMS_ y _CloudHSM_ usan HSM validados FIPS 140.]

#L("I")
#T[IaC][Infraestructura como código: definir la infraestructura en ficheros versionados que una herramienta aplica de forma repetible.]
#T[IAM][_Identity and Access Management_. Servicio global que controla quién puede hacer qué sobre qué recursos.]
#T[IAM Access Analyzer][Detecta recursos compartidos fuera de tu cuenta u organización, valida políticas y genera las de _mínimo privilegio_ según la actividad real.]
#T[IAM Identity Center][Acceso centralizado de las personas a varias cuentas y aplicaciones mediante _permission sets_; es el antiguo AWS SSO.]
#T[Idempotencia][Propiedad de una operación que da el mismo resultado aunque se repita; imprescindible con entregas «al menos una vez».]
#T[IGW][_Internet Gateway_. Conecta una VPC con Internet; una subred es pública si su tabla de rutas apunta a él.]
#T[IMDS][_Instance Metadata Service_. En `169.254.169.254`, da a la instancia sus metadatos y credenciales temporales; IMDSv2 exige un token de sesión.]
#T[Ingress][Reglas HTTP de entrada a los servicios de un clúster de Kubernetes; en EKS, el AWS Load Balancer Controller las convierte en un ALB.]
#T[Inline policy][Política IAM incrustada en un solo usuario, grupo o rol, que se borra con él; frente a ella, la _managed policy_ es reutilizable.]
#T[Inspector][Escaneo continuo de vulnerabilidades en instancias EC2, imágenes de ECR y funciones Lambda.]
#T[Instance profile][Contenedor que da un _rol_ IAM a una instancia EC2 para que obtenga credenciales temporales.]
#T[Instance store][Discos locales de algunos tipos de instancia EC2, muy rápidos pero efímeros: sus datos se pierden al parar o terminar la instancia.]
#T[Invalidación][Orden para que CloudFront descarte objetos de su caché antes de que expire su _TTL_.]
#T[IOPS][Operaciones de entrada/salida por segundo de un volumen de almacenamiento.]
#T[IRSA][_IAM Roles for Service Accounts_. Asocia roles IAM a cuentas de servicio de Kubernetes mediante el proveedor _OIDC_ del clúster de EKS.]

#L("J")
#T[JWT][_JSON Web Token_. Token firmado con afirmaciones (claims) sobre un usuario; Cognito los emite y API Gateway los valida.]

#L("K")
#T[Karpenter][Autoescalador de nodos de Kubernetes, de código abierto, que lanza la instancia más adecuada para los pods pendientes; EKS Auto Mode lo integra.]
#T[Key policy][Política de recurso de una _KMS key_: cada clave tiene exactamente una y es la base de su acceso.]
#T[Kinesis Data Streams][Streaming en tiempo real, ordenado por clave de partición, con varios consumidores y relectura; su capacidad se mide en _shards_.]
#T[KMS][_Key Management Service_. Crea y gestiona claves de cifrado y las usa desde los servicios de AWS, con cada uso auditado en CloudTrail.]
#T[KMS key][Clave lógica de KMS (antes CMK) cuyo material nunca sale del servicio sin cifrar: AWS owned (del servicio), AWS managed (`aws/servicio`) o customer managed (la controlas tú).]
#T[kubelet][Agente que se ejecuta en cada _nodo_ de Kubernetes y arranca y vigila los contenedores de los pods asignados.]
#T[Kubernetes][Orquestador de contenedores de código abierto; en AWS se ofrece gestionado con _EKS_.]

#L("L")
#T[Lake Formation][Gobierno de _data lakes_ en S3 con permisos finos por base de datos, tabla, columna y fila.]
#T[Lambda][Funciones serverless que se ejecutan por eventos, hasta 15 minutos y 10~240 MB de memoria, con pago por uso.]
#T[Lambda\@Edge][Funciones Lambda que se ejecutan en las ubicaciones regionales de CloudFront para personalizar peticiones y respuestas.]
#T[Landing zone][Entorno multicuenta bien diseñado (cuentas, OU, políticas y logs centralizados) desde el que crecer de forma segura.]
#T[Launch template][Plantilla versionada con la configuración de lanzamiento de instancias (AMI, tipo, red, _user data_) que usa Auto Scaling.]
#T[Lifecycle (S3)][Reglas que mueven objetos a clases más baratas o los eliminan según su antigüedad.]
#T[Listener][Proceso de un balanceador que escucha en un puerto y protocolo y aplica reglas para reenviar a _target groups_.]
#T[Log group][Agrupación de flujos de logs de CloudWatch Logs con su retención, sus permisos y sus filtros; se consulta con Logs Insights.]
#T[Long polling][Recepción de mensajes de SQS que espera hasta 20 segundos a que lleguen, lo que reduce las peticiones vacías.]

#L("M")
#T[Macie][Descubre datos sensibles (como datos personales) en S3 mediante aprendizaje automático.]
#T[Managed policy][Política IAM independiente y reutilizable, creada por AWS o por el cliente, que se adjunta a varias identidades.]
#T[MFA][Autenticación multifactor: un segundo factor (app TOTP, llave de seguridad, passkey) además de la contraseña.]
#T[Mínimo privilegio][Principio de conceder solo los permisos imprescindibles para cada tarea.]
#T[Modelo de responsabilidad compartida][AWS protege la infraestructura de la nube; el cliente, lo que pone en ella: datos, configuración, identidades y aplicaciones.]
#T[Multi-AZ][Despliegue repartido en varias zonas de disponibilidad para tolerar la caída de una de ellas.]
#T[Multi-site][Estrategia de recuperación ante desastres activo-activo: dos o más regiones sirven tráfico real a la vez, con RTO y RPO casi nulos y el mayor coste.]
#T[Multipart upload][Subida a S3 en partes enviadas en paralelo; obligatoria por encima de 5 GB.]

#L("N")
#T[NACL][_Network ACL_. Cortafuegos sin estado a nivel de subred, con reglas numeradas de permitir y denegar.]
#T[Namespace][En Kubernetes, partición lógica de un clúster para aislar recursos, cuotas y permisos; en CloudWatch, contenedor de métricas (`AWS/EC2`…).]
#T[NAT Gateway][Permite que los recursos de subredes privadas salgan a Internet sin ser accesibles desde fuera; se paga por hora y por GB procesado.]
#T[Nested stack][Stack de CloudFormation incluido como recurso dentro de otro para reutilizar componentes.]
#T[NLB][_Network Load Balancer_. Balanceador de capa 4 (TCP, UDP, TLS) de latencia muy baja, con IP estática por AZ.]
#T[Nodo][Máquina de un clúster de Kubernetes (instancia EC2 o capacidad de Fargate) en la que corren los pods.]

#L("O")
#T[OAC][_Origin Access Control_. Mecanismo con el que CloudFront firma sus peticiones a un bucket S3 privado; sustituye a OAI.]
#T[OIDC][_OpenID Connect_. Estándar de identidad sobre OAuth 2.0; permite a GitHub Actions o a EKS obtener credenciales de AWS sin claves.]
#T[On-Demand][Modelo de compra de pago por uso, sin compromiso.]
#T[Organizations][Gestión centralizada de varias cuentas desde la _cuenta de administración_, con _OU_, facturación consolidada y políticas como las _SCP_ y _RCP_.]
#T[Origen][Servidor del que CloudFront obtiene el contenido: un bucket S3, un ALB, API Gateway o cualquier servidor HTTP.]
#T[OU][_Organizational Unit_. Grupo de cuentas de Organizations; sus políticas se heredan.]

#L("P")
#T[Parameter Store][Almacén jerárquico de configuración y secretos de Systems Manager.]
#T[Partition key][Clave de partición: atributo con el que DynamoDB o Kinesis reparten los datos.]
#T[Peering de VPC][Conexión privada entre dos VPC, incluso de cuentas o regiones distintas; no es transitiva.]
#T[Permission set][Plantilla de permisos de IAM Identity Center que se materializa como un _rol_ en cada cuenta asignada.]
#T[Permissions boundary][Límite de permisos: política gestionada que fija el máximo que puede tener un usuario o rol, aunque sus políticas concedan más.]
#T[Pilot light][Estrategia de recuperación ante desastres con datos replicados e infraestructura mínima en otra región, sin servidores de aplicación en marcha.]
#T[Placement group][Colocación de instancias EC2: `cluster` (baja latencia), `spread` (separadas) o `partition`.]
#T[Pod][Unidad mínima de Kubernetes: uno o varios contenedores que comparten red y almacenamiento.]
#T[Política de recurso][Política de un recurso (bucket, cola, _KMS key_, rol) que indica qué _principals_ pueden usarlo.]
#T[Política IAM][Documento JSON con declaraciones `Effect`, `Action`, `Resource` y `Condition` que concede o deniega permisos.]
#T[Principal][Quien hace una petición a AWS: usuario, rol, servicio, cuenta o identidad federada; en una política de recurso, a quién se aplica.]
#T[PrivateLink][Expone y consume servicios de forma privada mediante endpoints de interfaz en tu VPC.]
#T[Provisioned concurrency][Entornos de Lambda preinicializados que eliminan el _cold start_ a cambio de un coste fijo.]

#L("Q")
#T[Quick Sight][Servicio de BI y paneles de AWS (antes QuickSight).]

#L("R")
#T[RCP][_Resource Control Policy_. Política de Organizations (2024) que limita los permisos máximos sobre los recursos de las cuentas, sea quien sea el solicitante.]
#T[RCU y WCU][Unidades de capacidad aprovisionada de DynamoDB: 1 RCU da una lectura fuerte por segundo de hasta 4 KB (o dos eventuales); 1 WCU, una escritura por segundo de hasta 1 KB.]
#T[RDS][_Relational Database Service_. Bases de datos relacionales gestionadas: PostgreSQL, MySQL, MariaDB, Oracle, SQL Server y Db2.]
#T[Read replica][Réplica de lectura: copia asíncrona de una base de datos para escalar lecturas o como base de recuperación.]
#T[Redshift][_Data warehouse_ columnar gestionado para analítica a gran escala, también en versión serverless.]
#T[Región][Área geográfica con varias AZ aisladas entre sí; la mayoría de servicios son regionales.]
#T[Reserved Instance][Descuento a cambio de comprometerse a usar una configuración concreta durante 1 o 3 años.]
#T[Rightsizing][Ajustar el tamaño de los recursos a su uso real.]
#T[Rol IAM][Identidad sin credenciales permanentes que asumen usuarios, servicios o cuentas para obtener credenciales temporales.]
#T[Rolling][Despliegue por lotes en el que la versión antigua y la nueva conviven durante el proceso.]
#T[Root user][Usuario root (o raíz): identidad creada con la cuenta, con acceso total. Protégelo con MFA y no lo uses en el día a día.]
#T[Route 53][DNS gestionado de AWS, con registro de dominios, _health checks_ y políticas de enrutamiento.]
#T[Route table][Tabla de rutas: reglas que deciden a dónde se envía el tráfico que sale de una subred.]
#T[RPO y RTO][_Recovery Point Objective_ (cuántos datos se pueden perder) y _Recovery Time Objective_ (cuánto tiempo sin servicio) ante un desastre.]

#L("S")
#T[S3][_Simple Storage Service_. Almacenamiento de objetos diseñado para once nueves de durabilidad, con clases según coste y frecuencia de acceso (Standard, Standard-IA, Intelligent-Tiering, _Glacier_…).]
#T[SAM][_Serverless Application Model_. Extensión de CloudFormation y CLI para aplicaciones serverless.]
#T[SAML][Estándar de _federación_ basado en XML: el proveedor de identidad corporativo (Entra ID, Okta…) autentica a la persona y AWS o IAM Identity Center confían en su aserción.]
#T[Savings Plans][Descuento a cambio de un compromiso de gasto por hora durante 1 o 3 años según el tipo (Compute, EC2 Instance, Database…).]
#T[SCP][_Service Control Policy_. Política de Organizations que fija los permisos máximos de las identidades de las cuentas afectadas; no concede permisos.]
#T[Secrets Manager][Secretos (contraseñas, claves de API) cifrados con KMS y con rotación automática.]
#T[Security Group][Cortafuegos con estado a nivel de interfaz de red; solo admite reglas de permitir.]
#T[Security Hub][Panel central de hallazgos de seguridad (findings) y de comprobaciones de cumplimiento frente a estándares.]
#T[Serverless][Modelo en el que no gestionas servidores, la capacidad escala sola y pagas por uso.]
#T[Service (Kubernetes)][Punto de acceso estable (IP y nombre DNS) a un conjunto de pods; puede exponerse con un balanceador.]
#T[Service Connect][Función de ECS para que los servicios se descubran y se comuniquen por nombre, con reintentos y métricas.]
#T[Service-linked role][Rol predefinido vinculado a un servicio de AWS, que el servicio crea y usa para actuar en tu nombre; solo él puede asumirlo.]
#T[Session Manager][Función de Systems Manager para abrir sesiones de shell en instancias sin SSH ni bastión, con auditoría.]
#T[Session policy][Política que se pasa al asumir un rol o al federarse y que recorta los permisos de esa sesión; nunca los amplía.]
#T[Shard][Unidad de capacidad y de orden de Kinesis Data Streams: cada uno admite 1 MB/s (o 1000 registros/s) de escritura y 2 MB/s de lectura.]
#T[Shield][Protección contra DDoS: Standard, gratuita y automática, y Advanced, de pago, con equipo de respuesta y protección de costes.]
#T[Snapshot][Copia puntual e incremental de un volumen EBS o de una base de datos.]
#T[SnapStart][Optimización de Lambda que restaura una instantánea del entorno ya inicializado para reducir el _cold start_.]
#T[SNS][_Simple Notification Service_. Mensajería pub/sub: un mensaje publicado en un tema llega a todos sus suscriptores.]
#T[Sort key][Segundo atributo de la clave primaria de DynamoDB: ordena los ítems de una partición.]
#T[Spot][Capacidad sobrante de EC2, muy barata, que AWS puede recuperar con 2 minutos de aviso.]
#T[SQS][_Simple Queue Service_. Colas de mensajes gestionadas, estándar o _FIFO_, para desacoplar productores y consumidores.]
#T[SSE][Cifrado del lado del servidor: el servicio cifra los datos en reposo. En S3, SSE-S3 se aplica por defecto, SSE-KMS usa claves de KMS y las Bucket Keys reducen sus llamadas a KMS.]
#T[Stack][Conjunto de recursos de CloudFormation que se crean, actualizan y borran como una unidad.]
#T[StackSets][Despliegan el mismo stack de CloudFormation en varias cuentas y regiones a la vez.]
#T[Stateful y stateless][Un cortafuegos con estado (_Security Group_) recuerda cada conexión y deja pasar sola la respuesta; uno sin estado (_NACL_) evalúa cada paquete y necesita reglas en ambos sentidos.]
#T[Step Functions][Orquestación serverless de flujos de trabajo definidos como máquinas de estados.]
#T[STS][_Security Token Service_. Emite credenciales temporales (AssumeRole, federación) para identidades de AWS.]
#T[Subred][Rango de IP de una VPC ubicado en una sola AZ; es pública si su tabla de rutas apunta a un _IGW_.]
#T[Systems Manager][Conjunto de herramientas para operar flotas: _Session Manager_, _Parameter Store_, Patch Manager, Run Command…]

#L("T")
#T[Tag][Etiqueta: par clave-valor de un recurso para organizarlo, controlar el acceso (_ABAC_) y asignar costes.]
#T[Target group][Conjunto de destinos (instancias, IP, funciones Lambda) a los que un balanceador envía tráfico y cuya salud comprueba.]
#T[Task definition][Plantilla de ECS que describe los contenedores de una tarea: imagen, CPU, memoria, puertos, roles y logs.]
#T[Task role][Rol IAM que usa el código de una tarea de ECS para llamar a otros servicios; no confundir con el _execution role_.]
#T[Terraform][IaC multiproveedor de HashiCorp, con lenguaje HCL y un fichero de estado.]
#T[Throttling][Limitación de la tasa de peticiones: por encima, el servicio responde con errores (HTTP 429).]
#T[TLS][_Transport Layer Security_. Protocolo que cifra y autentica las comunicaciones: la base de HTTPS.]
#T[Transit Gateway][Hub regional que interconecta VPC y redes on-premises de forma transitiva.]
#T[Trust policy][Política de confianza: política de recurso de un _rol_ que indica qué _principals_ pueden asumirlo.]
#T[Trusted Advisor][Comprobaciones automáticas de buenas prácticas de coste, seguridad, rendimiento, tolerancia a fallos y cuotas.]
#T[TTL][_Time To Live_. Tiempo que un dato puede conservarse en caché (DNS, CloudFront) o tras el que expira (DynamoDB).]

#L("U")
#T[UpdateReplacePolicy][Atributo de CloudFormation que decide qué hacer con el recurso antiguo cuando una actualización lo reemplaza.]
#T[URL prefirmada][URL temporal, firmada con las credenciales de quien la genera, para descargar o subir un objeto concreto de S3 sin abrir el bucket.]
#T[User data][Script que se ejecuta al arrancar por primera vez una instancia EC2.]
#T[Usuario IAM][Identidad con credenciales de larga duración (contraseña o _access keys_); hoy se prefieren _roles_ e _IAM Identity Center_.]

#L("V")
#T[Versionado (S3)][Conserva todas las versiones de cada objeto para recuperar borrados y sobrescrituras.]
#T[Visibility timeout][Tiempo durante el que un mensaje de SQS recibido queda oculto al resto de consumidores; si no se borra, vuelve a la cola.]
#T[VPC][_Virtual Private Cloud_. Red virtual aislada, dentro de una región, en la que despliegas tus recursos.]
#T[VPC Flow Logs][Registros con los metadatos del tráfico IP de una VPC, subred o interfaz, enviados a CloudWatch Logs, S3 o Firehose.]
#T[VPN (Site-to-Site)][Túneles IPsec cifrados sobre Internet entre tu red y una VPC o un Transit Gateway.]

#L("W")
#T[WAF][_AWS WAF_. Cortafuegos web para CloudFront, ALB, API Gateway y otros: una web ACL reúne reglas propias o gestionadas y límites de tasa.]
#T[Warm standby][Estrategia de recuperación ante desastres con una copia completa funcionando a escala reducida en otra región.]
#T[Well-Architected][Marco de buenas prácticas de AWS en seis pilares: excelencia operativa, seguridad, fiabilidad, eficiencia del rendimiento, optimización de costes y sostenibilidad.]

#L("X")
#T[X-Ray][Trazas distribuidas para seguir una petición a través de varios servicios y localizar latencias y errores; también admite OpenTelemetry (ADOT).]

#L("Z")
#T[Zona de disponibilidad][Véase _AZ_.]
]
