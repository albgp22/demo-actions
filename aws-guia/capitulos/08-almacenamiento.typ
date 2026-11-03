#import "../theme.typ": *

// Sin ligaduras en el código (para que `s3://` o `:::` se lean tal cual)
#show raw: set text(features: (calt: 0))

// ---------------------------------------------------------------------
//  Utilidades locales
// ---------------------------------------------------------------------

// Caja de clase de almacenamiento para los diagramas
#let _clase(nombre, sub, color, ancho: 2.6cm) = box(
  width: ancho, radius: 5pt, stroke: 1pt + color, fill: white, clip: true,
  stack(
    block(width: 100%, fill: color, inset: (x: 3pt, y: 4pt),
      align(center, text(7.2pt, weight: "bold", fill: white, nombre))),
    block(width: 100%, inset: (x: 4pt, y: 4pt), align(center, {
      set par(justify: false, leading: 0.35em)
      text(6.4pt, fill: gris.darken(25%), sub)
    })),
  ),
)

// ---------------------------------------------------------------------
#capitulo("Almacenamiento: S3 y compañía", color: col.almacenamiento,
  subtitulo: [Guarda cualquier cantidad de datos de forma duradera, segura y barata: objetos, ficheros, archivo y copias de seguridad.],
  objetivos: (
    [Diferenciar almacenamiento de bloque, de ficheros y de objetos],
    [Los conceptos de S3: buckets, objetos, claves y durabilidad],
    [Elegir clase de almacenamiento y automatizar con _lifecycle_],
    [Proteger datos: versionado, Object Lock, replicación y cifrado],
    [Controlar el acceso: _bucket policies_, URLs prefirmadas y endpoints],
    [Conocer EFS, FSx, Storage Gateway, DataSync y AWS Backup],
  ),
  servicios: ("Amazon S3", "S3 Glacier", "Amazon EFS", "Amazon FSx", "AWS DataSync", "AWS Backup"))

== Bloque, ficheros y objetos

Antes de elegir servicio conviene distinguir tres formas de guardar datos, porque responden a necesidades distintas:

#tarjetas(columnas: 3,
  tarjeta("Bloque · Amazon EBS", subtitulo: "Un disco duro virtual")[
    El sistema operativo ve un volumen de bloques y lo formatea. Baja latencia; se conecta a una instancia en una sola AZ. Para sistemas operativos y bases de datos (lo viste en el capítulo de EC2).
  ],
  tarjeta("Ficheros · EFS y FSx", color: col.contenedores, subtitulo: "Una carpeta compartida")[
    Directorios accesibles por NFS o SMB desde muchas máquinas a la vez, con permisos y bloqueos. Para contenido compartido, directorios de usuario y aplicaciones heredadas.
  ],
  tarjeta("Objetos · Amazon S3", color: col.datos, subtitulo: "Un almacén accesible por API")[
    Cada objeto (datos y metadatos) se guarda y lee entero con una API HTTP y una clave única. Escala sin límite práctico y es el más barato. Para backups, _data lakes_, web y logs.
  ],
)

#analogia[EBS es el disco de tu portátil; EFS, la unidad compartida de la oficina; S3, un guardarropa con resguardo: entregas el abrigo (el objeto), te dan un número (la clave) y lo recuperas entero, sin poder cambiarle un botón en el sitio.]

== Amazon S3: conceptos esenciales

Amazon S3 (_Simple Storage Service_) es probablemente el servicio más usado de AWS: almacena desde las imágenes de una web hasta data lakes de exabytes, y casi todos los demás servicios lo usan para guardar logs, copias o artefactos.

#ficha("Amazon S3", "Almacenamiento de objetos ilimitado, duradero y económico",
  ("Tipo", [Serverless; pago por GB-mes almacenado, por petición y por transferencia de salida]),
  ("Ámbito", [Buckets regionales, con nombres únicos en todo AWS]),
  ("Durabilidad", [Diseñado para el 99,999999999 % (11 nueves): datos repartidos en al menos 3 AZ, salvo las clases One Zone]),
  ("Límites clave", [Objetos de hasta 50 TB; un único PUT sube hasta 5 GB (por encima, _multipart upload_); 3500 escrituras y 5500 lecturas por segundo por prefijo]))

/ Bucket: contenedor de objetos que creas en una región; los datos no salen de ella salvo que los copies o repliques. Su nombre (3–63 caracteres: minúsculas, números, guiones y puntos) es *único en todo AWS*: si alguien tiene `fotos`, tú no.
/ Objeto: los datos —desde 0 bytes hasta 50 TB (desde diciembre de 2025; antes, 5 TB)— más metadatos (tipo de contenido, metadatos propios, hasta 10 etiquetas) y, si hay versionado, un identificador de versión. Es inmutable: para cambiarlo se sube entero de nuevo.
/ Clave: el nombre completo del objeto en el bucket, como `facturas/2026/03/f-0042.pdf`.
/ Prefijo: S3 no tiene carpetas, su espacio de nombres es plano. La consola las simula con prefijos (`facturas/2026/`) y el delimitador `/`, que también sirven para filtrar listados, reglas y permisos.

```bash
aws s3 mb s3://facturas-acme-prod --region eu-west-1          # crear bucket
aws s3 cp f-0042.pdf s3://facturas-acme-prod/facturas/2026/03/
aws s3 ls s3://facturas-acme-prod/facturas/2026/ --recursive
aws s3 sync ./web s3://web-acme --delete                       # sincronizar carpeta
```

Con una durabilidad de 11 nueves, si guardas diez millones de objetos puedes esperar perder uno cada 10~000 años de media. Desde diciembre de 2020, S3 ofrece además *consistencia fuerte*: tras escribir o borrar un objeto, cualquier lectura o listado posterior ve el cambio. Si dos clientes escriben a la vez la misma clave gana el último, salvo que uses *escrituras condicionales* (`If-None-Match`, `If-Match`, disponibles desde 2024).

#nota[Además de los buckets de propósito general existen *directory buckets* (para S3 Express One Zone), *table buckets* (S3 Tables, tablas Apache Iceberg gestionadas) y *vector buckets* (S3 Vectors, para búsquedas por similitud en aplicaciones de IA).]

== Clases de almacenamiento

Cada objeto tiene una *clase de almacenamiento* que fija su precio por GB, su disponibilidad y cuánto cuesta —en dinero y en tiempo— leerlo. La durabilidad es la misma en todas; lo que cambia es el equilibrio entre almacenar barato y leer barato.

#[#set text(hyphenate: false)
#tabla(("Clase", "Uso típico", "AZ", "Disponib.", "Mínimo", "Recuperación"),
  columnas: (1.45fr, 2fr, 0.45fr, 0.75fr, 0.75fr, 1.5fr), tamano: 7.9pt,
  [*Standard*], [Datos de uso frecuente], [≥ 3], [99,99 %], [—], [Milisegundos],
  [*Intelligent-Tiering*], [Patrón de acceso desconocido o cambiante], [≥ 3], [99,9 %], [—], [Milisegundos (capas de archivo opcionales: horas)],
  [*Standard-IA*], [Acceso infrecuente pero inmediato], [≥ 3], [99,9 %], [30 días], [Milisegundos, con cargo por GB],
  [*One Zone-IA*], [Copias que puedes regenerar], [1], [99,5 %], [30 días], [Milisegundos, con cargo por GB],
  [*Glacier Instant\ Retrieval*], [Archivo consultado unas pocas veces al año], [≥ 3], [99,9 %], [90 días], [Milisegundos, con cargo por GB],
  [*Glacier Flexible\ Retrieval*], [Archivo y copias de seguridad], [≥ 3], [99,99 %], [90 días], [De minutos a 12 horas],
  [*Glacier Deep Archive*], [Archivo a largo plazo y normativo], [≥ 3], [99,99 %], [180 días], [De 12 a 48 horas],
  [*Express One Zone*], [Latencia mínima (ML, analítica)], [1], [99,95 %], [—], [Un dígito de milisegundos],
)]

- *Intelligent-Tiering* es la opción por defecto cuando no conoces el patrón de acceso: por una pequeña cuota de monitorización por objeto, mueve cada objeto a una capa infrecuente tras 30 días sin accesos y a una de archivo instantáneo tras 90, y lo devuelve a la frecuente en cuanto se lee, sin cargos de recuperación. Los objetos de menos de 128 KB no se mueven.
- *Glacier Flexible Retrieval* y *Deep Archive* no se leen directamente: pides una *restauración* que crea una copia temporal. Flexible ofrece tres velocidades —_Expedited_ (1–5 min), _Standard_ (3–5 h) y _Bulk_ (5–12 h, gratuita)— y Deep Archive, Standard (hasta 12 h) y Bulk (hasta 48 h).
- *Express One Zone* usa directory buckets en la AZ que elijas, junto a tu cómputo, para entrenamiento de ML o analítica interactiva.

#examen[Las clases IA y Glacier Instant Retrieval facturan como mínimo 128 KB por objeto, y todas las que tienen duración mínima cobran los días restantes si borras o mueves antes el objeto. Glacier Flexible y Deep Archive añaden unos 40 KB de metadatos por objeto: archivar millones de ficheros diminutos sale caro, mejor agruparlos antes.]

== _Lifecycle_: mover y borrar automáticamente

Las *reglas de lifecycle* aplican a los objetos que cumplen un filtro (prefijo, etiquetas o tamaño) dos tipos de acciones: *transiciones* a clases más baratas y *expiraciones* (borrado). Siguen una cascada: solo se baja de clase, nunca se sube.

#diagrama(pie: [Ciclo de vida de los logs con la regla del ejemplo: cada transición abarata el almacenamiento y encarece la lectura.])[
  #set text(hyphenate: false)
  #fila(espacio: 3pt,
    _clase("S3 Standard", [Día 0: el log\ se escribe], col.serverless),
    flecha(etiqueta: "30 días", largo: 1.3cm),
    _clase("Standard-IA", [Consultas\ ocasionales], col.balanceo),
    flecha(etiqueta: "90 días", largo: 1.3cm),
    _clase("Glacier Flexible", [Archivo: lectura\ en horas], col.datos),
    flecha(etiqueta: "365 días", largo: 1.3cm),
    _clase("Expiración", [El objeto\ se elimina], col.neutro))
  #v(8pt)
  #block(width: 92%, {
    rect(width: 100%, height: 7pt, radius: 3pt, fill: gradient.linear(col.serverless, col.balanceo, col.datos, col.neutro))
    v(-4pt)
    grid(columns: (1fr, 1fr), align: (left, right),
      text(6.6pt, fill: gris.darken(20%))[*Almacenar:* más caro · *leer:* inmediato y barato],
      text(6.6pt, fill: gris.darken(20%))[*Almacenar:* muy barato · *leer:* lento y con cargo])
  })
]

```json
{
  "Rules": [{
    "ID": "logs-a-archivo",
    "Filter": { "Prefix": "logs/" },
    "Status": "Enabled",
    "Transitions": [
      { "Days": 30, "StorageClass": "STANDARD_IA" },
      { "Days": 90, "StorageClass": "GLACIER" }
    ],
    "Expiration": { "Days": 365 },
    "NoncurrentVersionExpiration": { "NoncurrentDays": 30 },
    "AbortIncompleteMultipartUpload": { "DaysAfterInitiation": 7 }
  }]
}
```

En la API, `GLACIER` es Glacier Flexible Retrieval, `GLACIER_IR` Instant Retrieval y `DEEP_ARCHIVE` Deep Archive. La regla se aplica así:

```bash
aws s3api put-bucket-lifecycle-configuration --bucket logs-acme \
  --lifecycle-configuration file://lifecycle.json
```

#cuidado[S3 exige 30 días en Standard antes de pasar a Standard-IA o One Zone-IA y, desde 2024, por defecto no transiciona objetos de menos de 128 KB. Cada transición se cobra como una petición: mover millones de objetos pequeños puede costar más de lo que ahorras.]

== Versionado, MFA Delete y Object Lock

Con el *versionado* activado, cada escritura crea una versión nueva y un borrado no elimina nada: añade un *delete marker* que oculta el objeto (y que puedes quitar para «resucitarlo»). Un bucket puede estar sin versionar, con versionado activado o suspendido; una vez activado, nunca vuelve al estado inicial. Cada versión se factura como un objeto completo: combínalo con `NoncurrentVersionExpiration`. *MFA Delete* exige además un código MFA para borrar versiones definitivamente o cambiar el estado del versionado; solo la cuenta root puede activarlo, y únicamente por CLI o API.

*Object Lock* aplica el modelo *WORM* (_write once, read many_): impide borrar o sobrescribir una versión durante un *periodo de retención* o mientras tenga una *retención legal* (_legal hold_, sin fecha de fin). Requiere versionado, puede fijar una retención por defecto en el bucket y tiene dos modos:

#block(breakable: false)[#tarjetas(
  tarjeta("Governance", subtitulo: "Protección con válvula de escape")[Los usuarios con el permiso `s3:BypassGovernanceRetention` pueden saltarse la retención o acortarla. Útil contra errores humanos y para probar antes de pasar a Compliance.],
  tarjeta("Compliance", color: col.iam, subtitulo: "Inmutable de verdad")[Nadie, ni siquiera la cuenta root, puede borrar la versión ni acortar la retención hasta que expire. Para normativas financieras o sanitarias y protección frente a _ransomware_.],
)]

== Replicación entre buckets

La *replicación* copia objetos de forma asíncrona a otro bucket, en otra región (*CRR*, _Cross-Region Replication_: recuperación ante desastres, latencia, requisitos geográficos) o en la misma (*SRR*: agregar logs, copiar entre cuentas de producción y pruebas).

- Exige versionado en origen y destino y un rol IAM que S3 asume para copiar; el destino puede estar en otra cuenta y usar otra clase de almacenamiento.
- Solo replica objetos nuevos; para los ya existentes se usa *S3 Batch Replication*.
- Los delete markers se replican solo si lo indicas, y los borrados de versiones concretas nunca, lo que protege frente a borrados maliciosos. Tampoco es transitiva: con A → B → C, los objetos de A no llegan a C.
- *Replication Time Control (RTC)* garantiza por SLA que el 99,99 % de los objetos se replica en 15 minutos.

#diagrama(pie: [Replicación entre regiones (CRR) hacia una cuenta de recuperación ante desastres.])[
  #set text(hyphenate: false)
  #fila(espacio: 6pt,
    zona("Cuenta producción · eu-west-1", color: col.almacenamiento)[
      #fila(svc("S3", "datos-prod", sub: "versionado activo", color: col.almacenamiento),
        svc("IAM", "Rol de replicación", sub: "lo asume S3", color: col.iam))
    ],
    flecha(etiqueta: [CRR asíncrona\ (RTC: 15 min)], largo: 2.4cm),
    zona("Cuenta DR · us-east-1", color: col.datos, ancho: 3.9cm)[
      #svc("S3", "datos-dr", sub: "Glacier Instant Retrieval", color: col.almacenamiento)
    ])
]

== Seguridad en S3

La mayoría de las fugas de datos en S3 de la última década se debieron a buckets públicos por error. Hoy los valores por defecto son seguros, pero conviene entender las capas:

/ Block Public Access: cuatro ajustes, a nivel de cuenta, bucket o access point, que impiden ACL y políticas públicas aunque alguien las escriba. Activado por defecto en los buckets nuevos desde 2023; actívalo también a nivel de cuenta.
/ Object Ownership: con *Bucket owner enforced*, valor por defecto desde 2023, las ACL quedan deshabilitadas y el dueño del bucket posee todos los objetos: el acceso se controla solo con políticas.
/ Políticas: las *políticas IAM* dicen qué puede hacer una identidad; la *bucket policy*, quién puede acceder al bucket, incluidas otras cuentas y servicios. Un `Deny` explícito en cualquiera de ellas gana siempre. Cómo se evalúan, con una bucket policy de ejemplo, lo viste en «IAM (II): permisos — políticas y evaluación».

=== Cifrado

En tránsito, S3 admite HTTPS, y puedes exigirlo con una bucket policy que deniegue las peticiones con `aws:SecureTransport` igual a `false`. En reposo, *todos los objetos nuevos se cifran por defecto* desde 2023 con *SSE-S3*: S3 gestiona las claves, sin coste ni configuración. Por bucket u objeto puedes elegir otro método:

/ SSE-KMS: con una clave de AWS KMS, controlas con políticas quién puede usarla y cada uso queda auditado en CloudTrail. Cada operación llama a KMS (con coste): activa las *S3 Bucket Keys*, que reducen esas llamadas hasta un 99 %.
/ DSSE-KMS: dos capas de cifrado con KMS, para normativas que exigen doble cifrado.
/ SSE-C: envías tu propia clave en cada petición (siempre por HTTPS) y S3 no la guarda.

Cómo funcionan las claves de KMS y qué permisos necesitas para leer un objeto cifrado se explica en el capítulo «Seguridad: cifrado con KMS, secretos y protección».

=== URLs prefirmadas, Access Points y VPC endpoints

Una *URL prefirmada* concede acceso temporal a un objeto concreto con los permisos de quien la firma, sin abrir el bucket. Es el patrón estándar para que un navegador suba o descargue directamente de S3 sin pasar el fichero por tu servidor. Con credenciales de un usuario IAM puede durar hasta 7 días; firmada con credenciales temporales de un rol, caduca como muy tarde con ellas.

```python
import boto3

s3 = boto3.client("s3")
url = s3.generate_presigned_url(
    "put_object",
    Params={"Bucket": "subidas-app", "Key": "fotos/u-42/perfil.jpg",
            "ContentType": "image/jpeg"},
    ExpiresIn=900,  # 15 minutos
)
# El navegador hace PUT de la foto directamente a esa URL
```

Para descargar basta la CLI: `aws s3 presign s3://informes/2026/q3.pdf --expires-in 3600`.

#diagrama(pie: [Subida directa a S3 con una URL prefirmada: el fichero nunca pasa por tu backend.])[
  #set text(hyphenate: false)
  #grid(columns: 5, align: center + horizon, column-gutter: 4pt, row-gutter: 6pt,
    grid.cell(rowspan: 2, actor(etiqueta: "Navegador")),
    flecha(etiqueta: "1 · pide una URL", largo: 2.6cm, doble: true),
    svc("λ", "Backend", sub: "firma con su rol IAM", color: col.serverless), [], [],
    flecha(etiqueta: "2 · PUT con la URL", largo: 2.6cm),
    svc("S3", "subidas-app", sub: "bucket privado", color: col.almacenamiento),
    flecha(etiqueta: "3 · ObjectCreated", largo: 2cm),
    svc("λ", "Procesado", sub: "valida y redimensiona", color: col.serverless),
  )
]

- Un *Access Point* es un punto de acceso con nombre, su propia política y, si quieres, restringido a una VPC. Simplifica buckets compartidos por muchos equipos: una política por consumidor en lugar de una bucket policy gigante. Un *Multi-Region Access Point* ofrece un único endpoint global que enruta cada petición al bucket replicado más cercano.
- El *acceso entre cuentas* exige dos permisos: que la bucket policy permita a la otra cuenta (o a un rol suyo) y que una política IAM de esa cuenta conceda la acción a quien accede. Alternativa: que la otra cuenta asuma un rol de la tuya.
- Desde tu VPC, un *gateway endpoint* para S3 (gratuito, mediante una ruta) evita pasar por Internet o por un NAT Gateway; un *interface endpoint* (de pago) además es accesible desde tu red local. La bucket policy puede exigir `aws:SourceVpce` para aceptar solo tráfico de tu endpoint (capítulo de Redes).

#block(breakable: false)[#practica[Activa Block Public Access a nivel de cuenta, exige TLS, usa SSE-KMS con Bucket Keys para datos sensibles, revisa los hallazgos de IAM Access Analyzer y, para auditar accesos, activa los eventos de datos de CloudTrail o los _server access logs_. Amazon Macie detecta datos personales en tus buckets.]]

== Rendimiento

/ Peticiones por prefijo: al menos 3500 escrituras y 5500 lecturas por segundo *por prefijo*, sin límite de prefijos: reparte las claves y paraleliza. Mientras S3 escala puede responder `503 Slow Down`; los SDK reintentan con _backoff_ exponencial.
/ Multipart upload: divide el objeto en partes (hasta 10~000) que se suben en paralelo y se reintentan por separado. Recomendado desde unos 100 MB y obligatorio por encima de 5 GB; `aws s3 cp` lo usa automáticamente. Las subidas que nunca se completan dejan partes invisibles que se *facturan*: de ahí la regla `AbortIncompleteMultipartUpload` del ejemplo de lifecycle.
/ Byte-range fetches: la cabecera `Range` descarga solo una parte del objeto, para paralelizar descargas o leer la cabecera de un fichero grande.
/ Transfer Acceleration: enruta las transferencias por las ubicaciones _edge_ de CloudFront y la red de AWS (`bucket.s3-accelerate.amazonaws.com`); útil desde lejos, con un cargo por GB acelerado.

== Eventos de S3

S3 puede notificar cuando se crea, borra, restaura, replica o transiciona un objeto (`s3:ObjectCreated:*`, `s3:ObjectRemoved:*`…), filtrando por prefijo y sufijo. Los destinos directos son Lambda, colas SQS Standard y topics SNS Standard, y el permiso se concede en el destino (política de la cola o del topic, o permiso de invocación). Si activas *EventBridge* en el bucket, todos los eventos llegan también al bus por defecto, con filtros más ricos, varios destinos por regla, archivo y repetición.

#diagrama(pie: [Un objeto nuevo dispara una notificación hacia los destinos configurados.])[
  #set text(hyphenate: false)
  #fila(espacio: 4pt,
    actor(etiqueta: "App"), flecha(etiqueta: "PUT", largo: 1.1cm),
    svc("S3", "Bucket fotos", sub: "prefijo subidas/", color: col.almacenamiento),
    flecha(etiqueta: "ObjectCreated", largo: 1.8cm),
    zona("Destinos de la notificación", color: col.integracion)[
      #grid(columns: 2, column-gutter: 6pt, row-gutter: 4pt,
        svc("λ", "Lambda", sub: "crea miniaturas", color: col.serverless),
        svc("SQS", "Cola SQS", sub: "trabajos por lotes", color: col.integracion),
        svc("SNS", "Topic SNS", sub: "varios suscriptores", color: col.integracion),
        svc("EB", "EventBridge", sub: "reglas y filtros ricos", color: col.integracion))
    ])
]

#cuidado[Las notificaciones suelen llegar en segundos, pero *al menos una vez* y sin orden garantizado: el consumidor debe ser idempotente. Y no escribas el resultado en el mismo bucket y prefijo que dispara la función, o crearás un bucle infinito.]

== Alojamiento web estático

S3 puede servir una web estática (HTML, CSS, JavaScript, imágenes) desde el *website endpoint* del bucket, con documento de índice, página de error y reglas de redirección. Pero ese endpoint solo habla HTTP y exige un bucket público. En producción se pone *CloudFront* delante de un bucket *privado*: obtienes HTTPS con tu dominio y caché en el borde, y solo la distribución puede leer el bucket, gracias a *Origin Access Control* (OAC). Además, la transferencia de S3 a CloudFront no se cobra. La arquitectura completa, con su bucket policy, está en el capítulo «CloudFront, Route 53 y el borde de la red».

== Consultar datos y controlar costes

*S3 Select*, que filtraba con SQL el contenido de un objeto CSV o JSON, no está disponible para clientes nuevos desde julio de 2024. Para consultar con SQL los datos de tus buckets se usa *Amazon Athena*, que verás en el capítulo de Bases de datos. La factura de S3 tiene cuatro componentes:

#block(breakable: false)[#tarjetas(columnas: 4,
  tarjeta("Almacenamiento")[GB-mes según la clase: del orden de 2 céntimos de dólar por GB en Standard, mucho menos en Glacier.],
  tarjeta("Peticiones")[Escribir y listar cuesta unas diez veces más que leer; IA y Glacier suman la recuperación por GB.],
  tarjeta("Transferencia")[Entrar es gratis; salir a Internet o a otra región se paga por GB (incluida la replicación).],
  tarjeta("Gestión")[Monitorización de Intelligent-Tiering, Inventory, Storage Lens avanzado, RTC…],
)]

#coste[Trampas típicas: versiones antiguas que nadie expira, subidas multipart incompletas, millones de objetos diminutos en clases con mínimo de 128 KB o con transiciones de lifecycle, y descargas masivas a Internet sin CloudFront. Con un bucket *Requester Pays*, quien descarga paga peticiones y transferencia. *S3 Storage Lens* te muestra dónde se va el dinero.]

Para gestionar miles de millones de objetos, *S3 Inventory* genera listados diarios o semanales de tus objetos y sus propiedades (clase, cifrado, réplica…), y *S3 Batch Operations* aplica una acción a todos los de una lista: copiar, etiquetar, restaurar desde Glacier o invocar una Lambda por objeto.

== Más allá de S3

=== Amazon EFS: ficheros compartidos para Linux

*Amazon EFS*, cuya ficha viste en el capítulo de EC2, es el sistema de ficheros NFS compartido de AWS: elástico (pagas por GB usado), replicado en varias AZ (o en una sola, más barato) y con clases Infrequent Access y Archive para lo que no se lee. Lo montan a la vez miles de instancias EC2, contenedores de ECS, EKS o Fargate y funciones Lambda, pero solo clientes Linux: para Windows está FSx. No lo confundas con *Mountpoint for Amazon S3*, un cliente que monta un bucket en Linux como si fuera un directorio: rinde muy bien leyendo ficheros grandes y escribiendo ficheros nuevos, pero no es un sistema de ficheros POSIX completo (no permite, por ejemplo, editar en el sitio un fichero existente).

=== Amazon FSx: sistemas de ficheros conocidos, gestionados

#block(breakable: false)[#tabla(("Servicio", "Protocolos", "Para qué"), columnas: (1.5fr, 0.9fr, 3fr), tamano: 8.2pt,
  [*FSx for Windows File Server*], [SMB], [Recursos compartidos de Windows integrados con Active Directory (permisos NTFS, DFS)],
  [*FSx for Lustre*], [Lustre (POSIX)], [HPC, ML y renderizado: _throughput_ muy alto y latencia inferior al milisegundo; se enlaza con un bucket S3],
  [*FSx for NetApp ONTAP*], [NFS, SMB, iSCSI], [Migrar cabinas NetApp: multiprotocolo, _snapshots_, SnapMirror, deduplicación y compresión],
  [*FSx for OpenZFS*], [NFS], [Migrar servidores ZFS o Linux: snapshots y clones instantáneos, baja latencia],
)]

=== Híbrido, migración y copias de seguridad

/ AWS Storage Gateway: _appliance_ virtual en tu centro de datos (o en EC2) que expone almacenamiento de AWS con protocolos locales y una caché: *S3 File Gateway* (NFS/SMB sobre objetos de S3), *Volume Gateway* (volúmenes iSCSI con snapshots en AWS) y *Tape Gateway* (cintas virtuales para tu software de backup, archivadas en Glacier).
/ AWS DataSync: transferencias en línea para migrar o sincronizar periódicamente: un agente lee de NFS, SMB, HDFS u otros almacenes de objetos (incluidas otras nubes) y copia a S3, EFS o FSx con cifrado, verificación de integridad, programación y límite de ancho de banda.
/ Snow Family: dispositivos físicos (Snowball Edge) para mover decenas o cientos de terabytes sin red suficiente o para cómputo en el edge. AWS ha retirado parte de la familia (Snowmobile, Snowcone): consulta la disponibilidad actual y prefiere DataSync o Direct Connect cuando la red lo permita.
/ AWS Backup: copias centralizadas por políticas para EBS, EC2, RDS y Aurora, DynamoDB, EFS, FSx, S3 y más. Los *backup plans* (frecuencia, retención, paso a almacenamiento frío) se asignan por etiquetas; admite copias entre regiones y cuentas, *Vault Lock* (WORM), políticas de backup de AWS Organizations y pruebas de restauración automatizadas.

#practica[Aplica la regla 3-2-1 en la nube: varias copias, en al menos dos ubicaciones (otra región) y una inmutable y aislada (otra cuenta, con Vault Lock u Object Lock en modo Compliance). Y prueba las restauraciones: una copia que nunca has restaurado es solo una esperanza.]

=== ¿Qué servicio de almacenamiento elijo?

#tabla(("Si necesitas…", "Usa"), columnas: (2.6fr, 1.4fr), tamano: 8.2pt,
  [Disco para el sistema operativo o una base de datos en EC2], [*Amazon EBS*],
  [Guardar ficheros de cualquier tamaño a escala: backups, data lake, web, logs], [*Amazon S3*],
  [Archivar durante años al mínimo coste], [*S3 Glacier Deep Archive*],
  [Una carpeta compartida por muchas instancias Linux, contenedores o Lambda], [*Amazon EFS*],
  [Recursos compartidos de Windows con Active Directory], [*FSx for Windows File Server*],
  [Rendimiento extremo para HPC o entrenamiento de ML], [*FSx for Lustre*],
  [Ampliar el almacenamiento de tu centro de datos con la nube], [*AWS Storage Gateway*],
  [Migrar o sincronizar terabytes por la red], [*AWS DataSync*],
  [Políticas de copia centralizadas para muchos servicios y cuentas], [*AWS Backup*],
)

#block(breakable: false)[#resumen[
- *Bloque* (EBS) para discos de una instancia, *ficheros* (EFS, FSx) para carpetas compartidas, *objetos* (S3) para todo lo demás a escala.
- S3 guarda objetos inmutables con una clave en buckets regionales de nombre global; 11 nueves de durabilidad y consistencia fuerte.
- Las clases de almacenamiento equilibran precio por GB y coste de lectura; Intelligent-Tiering es la opción por defecto si no conoces el patrón.
- Las reglas de lifecycle transicionan y expiran objetos automáticamente; vigila duraciones mínimas, el mínimo de 128 KB y las multipart incompletas.
- Versionado, MFA Delete y Object Lock (Governance o Compliance) protegen contra borrados; la replicación CRR/SRR copia a otro bucket.
- Seguridad por capas: Block Public Access, ACL deshabilitadas, bucket policies, cifrado por defecto (SSE-S3, SSE-KMS, DSSE-KMS, SSE-C) y URLs prefirmadas.
- Rendimiento: paraleliza por prefijos, usa multipart y byte-range; los eventos de S3 alimentan Lambda, SQS, SNS y EventBridge.
- Para webs estáticas, CloudFront con OAC delante de un bucket privado.
- EFS (NFS para Linux), FSx (Windows, Lustre, ONTAP, OpenZFS), Storage Gateway, DataSync y AWS Backup completan el catálogo.
]]

#block(breakable: false)[#repaso(
  ([¿Qué hace falta para que un objeto en Glacier Deep Archive sea legible?], [Solicitar una restauración (Standard, hasta 12 h; Bulk, hasta 48 h), que crea una copia temporal durante los días indicados.]),
  ([Unos logs se consultan mucho la primera semana y casi nunca después; deben conservarse un año. ¿Qué harías?], [Una regla de lifecycle que los pase a Standard-IA o Glacier Instant Retrieval tras 30 días, a Glacier Flexible o Deep Archive después y los expire a los 365 días.]),
  ([Un auditor exige que nadie, ni siquiera root, pueda borrar ciertos documentos durante 7 años. ¿Qué configuras?], [Object Lock en modo Compliance con una retención de 7 años (requiere versionado).]),
  ([¿Cómo permites que un navegador suba un fichero a un bucket privado sin pasar por tu servidor?], [Generando en el backend una URL prefirmada para `PutObject` con caducidad corta.]),
  ([¿Por qué no basta el website endpoint de S3 para una web en producción?], [Solo admite HTTP y exige un bucket público; con CloudFront y OAC obtienes HTTPS, dominio propio, caché y un bucket privado.]),
  ([Varios cientos de servidores Linux necesitan leer y escribir los mismos ficheros. ¿S3, EBS o EFS?], [EFS: un sistema de ficheros NFS compartido que montan muchas instancias a la vez en varias AZ.]),
  ([¿Qué aporta SSE-KMS frente a SSE-S3?], [Controlas con políticas quién puede usar la clave y cada uso queda auditado en CloudTrail; a cambio, cada operación llama a KMS (con coste), algo que las S3 Bucket Keys reducen.]),
  ([Unas instancias en subredes privadas leen terabytes de S3 a través de un NAT Gateway y la factura se dispara. ¿Qué cambias?], [Creas un gateway endpoint para S3 (gratuito) asociado a sus tablas de rutas: el tráfico deja de pasar por el NAT.]),
)]
