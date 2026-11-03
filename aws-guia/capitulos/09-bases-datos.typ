#import "../theme.typ": *


// ---------------------------------------------------------------------
//  Utilidades locales para los diagramas de este capítulo
// ---------------------------------------------------------------------
#let _mono(t, size: 6.8pt) = text(font: "JetBrains Mono", size: size, t)

// Cilindro que representa una copia de almacenamiento
#let _disco(t, c: col.datos) = box(width: 1.2cm, height: 0.95cm, {
  let h = 0.95cm
  let e = 6pt
  let st = 0.7pt + c.darken(10%)
  place(bottom + left, ellipse(width: 1.2cm, height: e, fill: c.lighten(62%), stroke: st))
  place(top + left, dy: e / 2, rect(width: 1.2cm, height: h - e, fill: c.lighten(62%), stroke: none))
  place(top + left, dy: e / 2, line(angle: 90deg, length: h - e, stroke: st))
  place(top + left, dx: 1.2cm, dy: e / 2, line(angle: 90deg, length: h - e, stroke: st))
  place(top + left, ellipse(width: 1.2cm, height: e, fill: c.lighten(82%), stroke: st))
  place(center + horizon, dy: 2pt, text(6pt, weight: "bold", fill: c.darken(35%), t))
})

// Icono mínimo, sin etiqueta
#let _mini(t, c) = box(width: 0.62cm, height: 0.62cm, radius: 3pt,
  fill: gradient.linear(c.lighten(8%), c.darken(18%), angle: 90deg),
  align(center + horizon, text(7.5pt, weight: "bold", fill: white, t)))

#capitulo("Bases de datos", color: col.datos,
  subtitulo: [Relacionales, NoSQL, en memoria y analíticas: cómo elegir la base de datos adecuada para cada problema y operarla en AWS sin sobresaltos.],
  objetivos: (
    [Elegir el tipo de base de datos según el patrón de acceso],
    [Qué te quita de encima una base de datos gestionada],
    [Alta disponibilidad en RDS: Multi-AZ frente a réplicas de lectura],
    [La arquitectura de Aurora: almacenamiento compartido y endpoints],
    [Modelar en DynamoDB: claves, índices, capacidad y consistencia],
    [Cachés con ElastiCache, analítica con Redshift y migraciones con DMS],
  ),
  servicios: ("Amazon RDS", "Amazon Aurora", "Amazon DynamoDB", "Amazon ElastiCache", "Amazon Redshift", "AWS DMS"))

== Una base de datos para cada problema

Durante décadas, la respuesta automática a «¿dónde guardo los datos?» fue una base de datos relacional. Sigue siendo la mejor opción en muchísimos casos, pero no en todos: un carrito con millones de usuarios simultáneos, un ranking que cambia cada segundo o un informe que recorre cinco años de ventas tienen necesidades muy distintas. AWS defiende las *bases de datos de propósito específico* (_purpose-built_): eliges el motor que encaja con tu *patrón de acceso* y, si hace falta, combinas varios.

Para decidir, pregúntate cómo vas a leer y escribir (por clave, con SQL y _joins_, recorriendo relaciones, buscando texto, agregando millones de filas), qué latencia y escala necesitas, qué garantías transaccionales exiges y cuánta infraestructura quieres operar. Y distingue dos tipos de carga: *OLTP* (_Online Transaction Processing_), muchas operaciones pequeñas y concurrentes, como crear un pedido, y *OLAP* (_Online Analytical Processing_), pocas consultas enormes que agregan millones de filas, como un informe de ventas.

#tabla(("Tipo", "Pensado para (ejemplos)", "Servicio de AWS"),
  columnas: (1.05fr, 2.1fr, 1.75fr), tamano: 8pt,
  [*Relacional (OLTP)*], [SQL, joins y transacciones ACID (ERP, tiendas, CRM)], [Amazon RDS, Amazon Aurora],
  [*Clave-valor*], [Acceso por clave a cualquier escala en milisegundos (carritos, perfiles)], [Amazon DynamoDB],
  [*Documental*], [Documentos JSON flexibles (catálogos, contenidos)], [Amazon DocumentDB (API de MongoDB)],
  [*En memoria*], [Microsegundos y estructuras de datos (cachés, sesiones, rankings)], [Amazon ElastiCache, Amazon MemoryDB],
  [*Columnar ancha*], [Escrituras masivas con el modelo de Cassandra (telemetría)], [Amazon Keyspaces],
  [*Grafos*], [Relaciones entre entidades (redes sociales, fraude)], [Amazon Neptune],
  [*Series temporales*], [Mediciones con marca de tiempo (IoT, métricas)], [Amazon Timestream],
  [*Ledger*], [Historial inmutable y verificable (registros contables)], [Amazon QLDB cerró en julio de 2025; AWS propone Aurora PostgreSQL],
  [*Búsqueda*], [Texto completo y relevancia (buscadores, logs)], [Amazon OpenSearch Service],
  [*Data warehouse (OLAP)*], [Consultas analíticas sobre grandes volúmenes (BI, informes)], [Amazon Redshift; Athena sobre S3],
)

== Gestionada frente a autogestionada

Nada te impide lanzar una instancia EC2, instalar PostgreSQL y administrarlo tú. Pero una base de datos en producción exige mucho más que instalarla: parches, copias y pruebas de restauración, réplicas, failover, monitorización, ampliar el disco a las tres de la mañana… Con un servicio gestionado, AWS asume esas tareas y tú te concentras en el modelo de datos y las consultas.

#analogia[EC2 es comprar una casa: decides cada detalle, pero las goteras las arreglas tú. RDS es un piso con conserje: amueblas a tu gusto y el mantenimiento lo hace otro. DynamoDB es un hotel: pides habitación y la usas.]

#diagrama(pie: [Quién se ocupa de cada tarea según el modelo de base de datos.])[
  #set par(justify: false)
  #let quien = (
    tu: (col.iam, "Tú"),
    aws: (col.datos, "AWS"),
    amb: (col.balanceo, "Compartido"),
  )
  #let celda(k) = {
    let (c, t) = quien.at(k)
    box(width: 100%, height: 15pt, radius: 3pt, fill: c,
      align(center + horizon, text(7.3pt, weight: "bold", fill: white, t)))
  }
  #let filas = (
    ("Esquema, consultas y usuarios", "tu", "tu", "tu"),
    ("Capacidad y escalado", "tu", "amb", "aws"),
    ("Alta disponibilidad y failover", "tu", "amb", "aws"),
    ("Copias de seguridad", "tu", "amb", "amb"),
    ("Instalación y parches del motor", "tu", "aws", "aws"),
    ("Sistema operativo", "tu", "aws", "aws"),
    ("Hardware, red y centro de datos", "aws", "aws", "aws"),
  )
  #grid(columns: (4.4cm, 1fr, 1fr, 1fr), column-gutter: 5pt, row-gutter: 3.5pt, align: horizon,
    [],
    ..("Base de datos en EC2", "Amazon RDS / Aurora", "Amazon DynamoDB").map(t =>
      align(center, text(8pt, weight: "bold", fill: marino, t))),
    ..filas.map(f => (
      align(right, text(7.6pt, fill: tinta, f.at(0))),
      ..f.slice(1).map(celda),
    )).flatten(),
  )
  #v(6pt)
  #text(7pt, fill: gris)[_Compartido_: tú decides y configuras (tamaño, Multi-AZ, retención) y AWS lo ejecuta.]
]

Con RDS o Aurora *sigue siendo tuyo* el esquema, los índices, las consultas, los usuarios del motor, el tamaño de la instancia, la red (subredes y _Security Groups_) y la retención de copias. ¿Cuándo tiene sentido EC2? Cuando necesitas un motor o versión que RDS no ofrece, acceso de administrador al sistema operativo o extensiones no soportadas. Entre ambos extremos está *RDS Custom* (Oracle y SQL Server): automatiza copias y monitorización, pero te deja entrar en el sistema operativo.

== Amazon RDS

#ficha("Amazon RDS", "Bases de datos relacionales gestionadas",
  ("Motores", [MySQL, PostgreSQL, MariaDB, Oracle, SQL Server e IBM Db2 (Aurora es una familia aparte; la vemos en la sección siguiente)]),
  ("Ámbito", [Regional; cada instancia vive en una AZ y, con Multi-AZ, su standby en otra]),
  ("Facturación", [Horas de instancia, GB de almacenamiento (e IOPS según el tipo), copias por encima del tamaño aprovisionado y transferencia de datos]),
  ("Ideal para", [Aplicaciones transaccionales con SQL que no quieren administrar servidores]))

=== Motores, instancias y almacenamiento

Una *instancia de base de datos* (_DB instance_) es un entorno aislado con su propia capacidad de cómputo —la *clase de instancia*— y su almacenamiento en EBS. Te conectas a ella con un nombre DNS del estilo `pedidos.abc123xyz.eu-west-1.rds.amazonaws.com`, nunca con una IP fija.

- *Clases de instancia*: `db.t4g` y `db.t3` (con ráfagas de CPU, para desarrollo), `db.m*` (uso general) y `db.r*` o `db.x*` (optimizadas en memoria). La `g` indica Graviton, con mejor relación precio-rendimiento. Cambiar de clase implica un reinicio; con Multi-AZ, el corte se reduce a un failover.
- *Almacenamiento*: `gp3` (uso general, IOPS configurables) o `io1`/`io2` Block Express (IOPS aprovisionadas y latencia muy estable). *Storage Auto Scaling* amplía el disco cuando se llena, hasta el máximo que fijes.

```bash
aws rds create-db-instance \
  --db-instance-identifier pedidos-prod \
  --engine postgres --db-instance-class db.r7g.large \
  --storage-type gp3 --allocated-storage 100 --max-allocated-storage 500 \
  --master-username appadmin --manage-master-user-password \
  --multi-az --storage-encrypted --backup-retention-period 14 \
  --db-subnet-group-name subredes-privadas-bd \
  --vpc-security-group-ids sg-0a1b2c3d4e5f67890 --no-publicly-accessible
```

`--max-allocated-storage` activa Storage Auto Scaling y `--manage-master-user-password` guarda la contraseña maestra en Secrets Manager, que además la rota por ti.

=== Alta disponibilidad: Multi-AZ y réplicas de lectura

RDS ofrece dos mecanismos que a menudo se confunden, porque los dos «copian la base de datos», pero responden a preguntas distintas: *Multi-AZ*, a «¿qué pasa si se cae?» (disponibilidad), y las *réplicas de lectura*, a «¿cómo atiendo más consultas?» (rendimiento). Piensa en Multi-AZ como la rueda de repuesto, que no usas hasta que pinchas, y en las réplicas como ventanillas extra, que atienden a más gente pero no sustituyen solas a la principal si cierra.

- *Multi-AZ* mantiene un *standby* en otra AZ que recibe cada cambio de forma *síncrona*: una escritura no se confirma hasta que está en las dos AZ, así que al conmutar no se pierde nada. El standby *no admite conexiones*, solo espera. Si la primaria o su AZ fallan, RDS hace el _failover_ (la conmutación) solo y apunta al standby el mismo nombre DNS: la aplicación únicamente tiene que reconectar. En el *despliegue de clúster* (MySQL y PostgreSQL) hay un writer y *dos standbys legibles* en tres AZ, con un endpoint de escritura, otro de lectura y failovers más rápidos.
- Las *réplicas de lectura* (_read replicas_) reciben los cambios de forma *asíncrona*, así que pueden ir unos segundos por detrás (_replica lag_). Cada una tiene su propio endpoint, y es tu aplicación la que les envía las lecturas (MySQL, MariaDB y PostgreSQL admiten hasta 15). Pueden estar en otra región y, ante un desastre, se *promocionan* a base de datos independiente, pero a mano.

#diagrama(pie: [Las tres formas de replicar en RDS: Multi-AZ de instancia, Multi-AZ de clúster y réplicas de lectura.])[
  #let c = col.datos
  #grid(columns: 3, column-gutter: 5pt, align: center + top,
    zona("Multi-AZ · instancia", color: c, ancho: 3.75cm)[
      #columna(espacio: 2pt,
        svc("RDS", "Primaria", sub: "AZ a · lee y escribe", color: c),
        flecha-v(etiqueta: "síncrona", largo: 0.8cm),
        svc("RDS", "Standby", sub: "AZ b · sin lecturas", color: gris),
      )
    ],
    zona("Multi-AZ · clúster", color: c)[
      #columna(espacio: 2pt,
        svc("RDS", "Writer", sub: "AZ a", color: c),
        flecha-v(etiqueta: "semisíncrona", largo: 0.8cm),
        fila(espacio: 2pt,
          svc("RDS", "Standby legible", sub: "AZ b", color: c.lighten(25%)),
          svc("RDS", "Standby legible", sub: "AZ c", color: c.lighten(25%))),
      )
    ],
    zona("Réplicas de lectura", color: c)[
      #columna(espacio: 2pt,
        svc("RDS", "Primaria", sub: "región A", color: c),
        flecha-v(etiqueta: "asíncrona", largo: 0.8cm),
        fila(espacio: 2pt,
          svc("RR", "Réplica", sub: "misma región", color: c.lighten(25%)),
          svc("RR", "Réplica", sub: "región B (DR)", color: c.lighten(25%))),
      )
    ],
  )
]

#tabla(("", "Multi-AZ (instancia)", "Multi-AZ (clúster)", "Réplica de lectura"),
  columnas: (0.95fr, 1.2fr, 1.35fr, 1.25fr), tamano: 8pt,
  [*Objetivo*], [Disponibilidad], [Disponibilidad y lecturas], [Escalar lecturas y DR],
  [*Replicación*], [Síncrona], [Semisíncrona (confirma un standby)], [Asíncrona],
  [*¿Sirve lecturas?*], [#no El standby solo espera], [#si Los dos standbys], [#si],
  [*Ubicación*], [Otra AZ], [Tres AZ], [Cualquier AZ u otra región],
  [*Failover*], [Automático, 60–120 s], [Automático, menos de 35 s], [Manual: se _promociona_],
)

#examen[Multi-AZ = disponibilidad; réplica de lectura = rendimiento de lectura (y DR entre regiones). Una réplica puede ser a su vez Multi-AZ, y replicar dentro de la región no genera cargos de transferencia; entre regiones, sí.]

=== Copias de seguridad y restauración

RDS hace dos tipos de copias:

- *Backups automáticos*: una instantánea diaria en la *ventana de backup* más los *logs de transacciones*, que se suben a S3 cada cinco minutos. Permiten una *restauración a un punto en el tiempo* (PITR) a cualquier segundo del periodo de retención —de 1 a 35 días—, normalmente hasta unos cinco minutos antes del presente.
- *Snapshots manuales*: se conservan hasta que los borras, aunque elimines la instancia. Puedes copiarlos a otra región y compartirlos con otras cuentas (si están cifrados, con una clave KMS gestionada por el cliente, no con `aws/rds`).
- *Coste*: las copias no se cobran hasta el 100 % del almacenamiento aprovisionado en la región; el exceso (snapshots acumulados, retenciones largas) se paga por GB-mes.

#cuidado[Restaurar —un snapshot o un PITR— *siempre crea una instancia nueva*, con otro endpoint: no «rebobina» la existente, así que planifica cómo apuntará la aplicación a ella. Al borrar una instancia, los backups automáticos desaparecen salvo que elijas conservarlos: haz siempre un snapshot final. Y si detienes una instancia para ahorrar, vuelve a arrancar sola a los siete días.]

=== Seguridad: red, cifrado y credenciales

- *Red*: subredes privadas (un _DB subnet group_ con al menos dos AZ), sin acceso público, y el puerto del motor abierto solo al _Security Group_ de la aplicación (capítulo de Redes).
- *Cifrado en reposo* con KMS: cubre almacenamiento, backups, snapshots, réplicas y logs. Se elige *al crear* la instancia; para cifrar una existente, copia un snapshot activando el cifrado y restaura desde él (detalles en «Seguridad: cifrado con KMS, secretos y protección»).
- *Cifrado en tránsito* con TLS, obligatorio si lo fijas por parámetro (`rds.force_ssl` en PostgreSQL, `require_secure_transport` en MySQL).
- *Credenciales*: contraseña maestra gestionada en *Secrets Manager*, o *autenticación IAM* (MySQL, MariaDB y PostgreSQL): la aplicación obtiene con su rol un *token* válido 15 minutos (`aws rds generate-db-auth-token`) y lo usa como contraseña, por TLS. El rol necesita el permiso `rds-db:connect` sobre ese usuario de la base de datos y, en PostgreSQL, el usuario debe tener el rol `rds_iam` (`GRANT rds_iam TO app_lectura;`).

=== RDS Proxy

Cada conexión a una base de datos relacional consume memoria y CPU del servidor, y una flota de funciones Lambda que escala a cientos de copias en segundos puede agotar `max_connections`. *RDS Proxy* es un _pool_ de conexiones gestionado entre la aplicación y la base de datos: mantiene pocas conexiones abiertas y las reutiliza entre muchos clientes.

#diagrama(pie: [RDS Proxy absorbe las conexiones cortas de cientos de funciones Lambda y las multiplexa sobre unas pocas.])[
  #fila(espacio: 10pt,
    zona("Funciones Lambda", color: col.serverless)[
      #grid(columns: 4, gutter: 4pt, ..range(8).map(_ => _mini("λ", col.serverless)))
    ],
    flecha(etiqueta: "cientos de conexiones", largo: 2.6cm),
    svc("PRX", "RDS Proxy", sub: "pool de conexiones", color: col.datos),
    flecha(etiqueta: "pocas, reutilizadas", largo: 2.6cm),
    svc("RDS", "Aurora o RDS", sub: "instancia primaria", color: col.datos),
  )
]

Durante un failover, RDS Proxy mantiene las conexiones de los clientes y las redirige a la nueva primaria, así que la aplicación apenas lo nota. Lee las credenciales de Secrets Manager, puede exigir autenticación IAM, es compatible con MySQL, PostgreSQL, MariaDB y SQL Server (y con Aurora), solo es accesible desde la VPC y se paga por vCPU (o ACU) de la base de datos a la que sirve.

=== Operación: configuración, mantenimiento y actualizaciones

/ Parameter group: configuración del motor (`max_connections`, `work_mem`…). El grupo por defecto no se edita: crea uno propio. Los parámetros *dinámicos* se aplican al momento; los *estáticos* dejan la instancia en `pending-reboot` hasta reiniciarla. Los *option groups* añaden funciones extra de algunos motores, sobre todo Oracle y SQL Server.
/ Ventana de mantenimiento: franja semanal para parches del sistema operativo y, si activas _auto minor version upgrade_, versiones menores del motor. Con Multi-AZ se parchea primero el standby y se hace failover. Las versiones *mayores* las decides tú.
/ Monitorización: además de las métricas de CloudWatch (`CPUUtilization`, `FreeStorageSpace`, `ReplicaLag`…), *Enhanced Monitoring* muestra el sistema operativo y los procesos, y *CloudWatch Database Insights* (desde finales de 2024, sucesor de Performance Insights) desglosa la carga por consulta SQL y evento de espera: _¿qué consulta satura la base de datos?_ Su modo Standard es gratuito; el Advanced, de pago, guarda 15 meses y añade la vista de flota y los planes de ejecución.
/ Blue/Green deployments: para cambios con riesgo (versión mayor, parámetros, clase de instancia), RDS crea un entorno *green*, copia del de producción (*blue*) sincronizada por replicación lógica. Lo modificas y lo pruebas; en el *switchover*, RDS bloquea las escrituras, espera a que green esté al día e intercambia los endpoints, normalmente en menos de un minuto y sin cambiar la cadena de conexión. Existe para RDS MySQL, MariaDB y PostgreSQL y para Aurora MySQL y PostgreSQL.

#coste[Si una versión mayor llega al final de su soporte estándar y no actualizas, pasa a *RDS Extended Support*, que se factura aparte por vCPU y hora.]

== Amazon Aurora

Aurora es el motor relacional que AWS diseñó para la nube: compatible con MySQL y PostgreSQL —tus drivers y herramientas funcionan igual—, pero con un almacenamiento completamente distinto.

#ficha("Amazon Aurora", "Base de datos relacional nativa de la nube, compatible con MySQL y PostgreSQL",
  ("Almacenamiento", [Volumen distribuido y compartido, con 6 copias en 3 AZ, que crece solo]),
  ("Réplicas", [Hasta 15 réplicas de Aurora, con un retardo típico inferior a 100 ms]),
  ("Facturación", [Instancias (o ACU), GB-mes almacenados, operaciones de E/S (salvo con I/O-Optimized), copias y transferencia]))

=== Cómputo y almacenamiento separados

En RDS, cada instancia tiene su propio volumen EBS. En Aurora, todas las instancias del *clúster* —un *writer* y hasta 15 *réplicas*— trabajan sobre el mismo *volumen de clúster*: una capa distribuida que divide los datos en segmentos y guarda *seis copias de cada uno en tres AZ*. El writer solo envía registros del log de _redo_, y una escritura se confirma cuando 4 de las 6 copias la han recibido.

#diagrama(pie: [Arquitectura de Aurora: las instancias comparten un único volumen distribuido con seis copias de los datos en tres AZ.])[
  #let c = col.datos
  #grid(columns: (1fr, 1fr, 1fr), column-gutter: 10pt, row-gutter: 2pt, align: center + horizon,
    zona("AZ a", color: col.neutro)[#svc("W", "Instancia writer", sub: "lecturas y escrituras", color: c)],
    zona("AZ b", color: col.neutro)[#svc("R", "Réplica de Aurora", sub: "solo lectura", color: c.lighten(25%))],
    zona("AZ c", color: col.neutro)[#svc("R", "Réplica de Aurora", sub: "solo lectura", color: c.lighten(25%))],
    flecha-v(etiqueta: "envía el log de redo", largo: 0.9cm),
    flecha-v(arriba: true, etiqueta: "lee páginas", largo: 0.9cm),
    flecha-v(arriba: true, etiqueta: "lee páginas", largo: 0.9cm),
    grid.cell(colspan: 3, block(width: 100%, fill: c.lighten(90%), stroke: 1pt + c, radius: 6pt,
      inset: (x: 8pt, top: 7pt, bottom: 9pt), {
        text(7pt, weight: "bold", fill: c.darken(20%), tracking: 0.4pt,
          "VOLUMEN DE CLÚSTER COMPARTIDO · UN ÚNICO VOLUMEN LÓGICO QUE CRECE SOLO")
        v(5pt)
        grid(columns: (1fr, 1fr, 1fr), column-gutter: 10pt,
          ..range(3).map(i => fila(espacio: 8pt,
            _disco("copia " + str(2 * i + 1)), _disco("copia " + str(2 * i + 2)))))
      })),
  )
]

Consecuencias: el clúster sigue escribiendo aunque pierda dos copias y leyendo aunque pierda tres (sobrevive a la caída de una AZ), y las copias dañadas se reparan solas; las réplicas no necesitan copiar datos, así que se crean enseguida y apenas se retrasan; y no dimensionas disco: el volumen crece (y se reduce) solo y pagas por lo que ocupas.

=== Endpoints, réplicas y failover

En Aurora te conectas a *endpoints* que AWS mantiene actualizados aunque cambien los papeles de las instancias:

#tabla(("Endpoint", "Apunta a", "Úsalo para"), columnas: (0.9fr, 1.6fr, 1.5fr),
  [*Cluster (writer)*], [La instancia writer actual (`app.cluster-abc123…`); tras un failover, la nueva], [Escrituras y lecturas que deben ver el último dato],
  [*Reader*], [Reparte las conexiones entre las réplicas (`app.cluster-ro-abc123…`)], [Lecturas escalables],
  [*Custom*], [El subconjunto de instancias que tú elijas], [Separar cargas: informes en réplicas más grandes, por ejemplo],
  [*Instance*], [Una instancia concreta], [Diagnóstico y casos muy específicos],
)

Si el writer falla, Aurora *promociona una réplica* —según su prioridad (_tier_ 0 a 15) y, a igualdad, la de mayor tamaño— y repunta el endpoint del clúster, normalmente en unos 30 segundos. Sin réplicas, tiene que recrear la instancia y tarda bastante más: en producción, mantén al menos una réplica en otra AZ. *Aurora Auto Scaling* añade o quita réplicas según la CPU o las conexiones. Ojo: el reader endpoint reparte *conexiones* (por DNS), no consultas; un pool que nunca renueva sus conexiones puede desequilibrar la carga.

=== Aurora Serverless v2

Con *Aurora Serverless v2*, la capacidad se mide en *ACU* (_Aurora Capacity Units_; cada una equivale a unos 2 GiB de memoria con su CPU y red) y se ajusta sola, en incrementos de 0,5 ACU, entre el mínimo y el máximo que definas: desde 0 ACU —la instancia se pausa sin conexiones y tarda unos segundos en reanudarse— hasta 256 ACU. Pagas por ACU-hora. Encaja con cargas variables, entornos de desarrollo y aplicaciones con muchos inquilinos, y puede convivir con instancias aprovisionadas en el mismo clúster.

=== Global Database, backtrack y clonado

#tarjetas(columnas: 3,
  tarjeta("Global Database", subtitulo: "Multirregión")[Replica el volumen a otras regiones con retardo típico inferior a un segundo; las secundarias sirven lecturas locales. Ante un desastre regional, promocionas una: RPO de segundos, RTO del orden de un minuto.],
  tarjeta("Backtrack", subtitulo: "Solo Aurora MySQL")[«Rebobina» el clúster en el sitio hasta 72 horas atrás sin restaurar ningún backup: ideal para deshacer un `DELETE` sin `WHERE`. Se activa al crear el clúster.],
  tarjeta("Clonado", subtitulo: "Copy-on-write")[Crea en minutos un clúster que comparte las páginas del original y solo copia las que cambian. Pruebas con datos reales sin tocar producción.],
)

#nota(titulo: "Aurora DSQL")[Disponible desde 2025, *Aurora DSQL* es una base de datos SQL distribuida y _serverless_, compatible con PostgreSQL, que funciona en modo activo-activo en varias regiones con consistencia fuerte y sin instancias. No es «Aurora con otro nombre»: usa control de concurrencia optimista y no admite todas las funciones de PostgreSQL (por ejemplo, las claves foráneas).]

#coste[Con *Aurora Standard* pagas las operaciones de E/S por millón; con *Aurora I/O-Optimized* no pagas E/S, a cambio de instancias y almacenamiento más caros. Regla práctica de AWS: si la E/S supera aproximadamente el 25 % del gasto en Aurora, I/O-Optimized suele salir más barato.]

== Amazon DynamoDB

DynamoDB es la base de datos NoSQL serverless de AWS: sin instancias, parches ni ventanas de mantenimiento. Creas una tabla, eliges cómo pagar la capacidad y lees y escribes en milisegundos de un dígito, tengas cien ítems o cien mil millones. A cambio, te pide *diseñar la tabla a partir de tus patrones de acceso*.

#ficha("Amazon DynamoDB", "Base de datos NoSQL clave-valor y documental, totalmente serverless",
  ("Ámbito", [Regional; los datos se replican en 3 AZ (global tables para multirregión)]),
  ("Límites clave", [Ítem de hasta 400 KB; Query y Scan devuelven como mucho 1 MB por página]),
  ("Facturación", [Por petición (on-demand) o por capacidad aprovisionada, más GB almacenados y extras (backups, streams, réplicas)]))

=== Modelo de datos

/ Tabla, ítem y atributo: una tabla es una colección de *ítems* (el equivalente a filas, de hasta 400 KB) y cada ítem es un conjunto de *atributos* nombre-valor: escalares, documentos (listas y mapas anidados) y conjuntos. Sin esquema fijo salvo la clave.
/ Partition key: clave de partición (_hash key_). Su hash decide en qué partición física se guarda el ítem.
/ Sort key: clave de ordenación (_range key_), opcional. Ordena los ítems que comparten partition key —una *colección de ítems*— y permite consultas por rango. La *clave primaria* es la partition key sola o junto con la sort key, y es única: no puede haber dos ítems con la misma.

#diagrama(pie: [Tabla `Pedidos` con clave primaria compuesta. DynamoDB reparte los ítems entre particiones según el hash de la partition key y, dentro de cada una, los ordena por la sort key.])[
  #set par(justify: false)
  #let c = col.datos
  #let hd(t, f) = box(width: 100%, inset: (x: 5pt, y: 3.5pt), fill: f,
    text(7pt, weight: "bold", fill: white, t))
  #let cel(t, f: white, mono: false) = box(width: 100%, height: 13pt, inset: (x: 5pt), fill: f,
    align(left + horizon, if mono { _mono(t) } else { text(7pt, t) }))
  #let k1 = c.lighten(78%)
  #let k2 = c.lighten(90%)
  #grid(columns: (3.2cm, 2.6cm, 1.5cm, 1.9cm, 1fr), column-gutter: 1.5pt, row-gutter: 1.5pt,
    grid.cell(colspan: 2, align(center, text(7pt, weight: "bold", fill: c.darken(20%), [Clave primaria compuesta]))),
    grid.cell(colspan: 3, align(center, text(7pt, weight: "bold", fill: gris, [Atributos: cada ítem puede tener los suyos]))),
    hd([cliente · partition key], c.darken(25%)), hd([fecha · sort key], c),
    hd([importe], gris), hd([estado], gris), hd([otros atributos], gris),
    cel("C#001", f: k1, mono: true), cel("2026-01-15", f: k1, mono: true), cel([49,90]), cel([ENVIADO]), cel([]),
    cel("C#001", f: k1, mono: true), cel("2026-02-03", f: k1, mono: true), cel([120,00]), cel([PENDIENTE]), cel([cupon = "VERANO"]),
    cel("C#002", f: k2, mono: true), cel("2026-01-20", f: k2, mono: true), cel([15,50]), cel([ENTREGADO]), cel([]),
    cel("C#003", f: k2, mono: true), cel("2026-02-11", f: k2, mono: true), cel([89,99]), cel([ENVIADO]), cel([regalo = true]),
  )
  #v(1pt)
  #flecha-v(etiqueta: [hash(partition key) → partición física], largo: 0.75cm)
  #v(1pt)
  #fila(espacio: 10pt,
    zona("Partición A", color: c)[#caja(_mono("C#002 · 2026-01-20"), color: c)],
    zona("Partición B · colección de C#001", color: c)[#fila(espacio: 3pt,
      caja(_mono("C#001 · 2026-01-15"), color: c),
      text(8pt, fill: gris, "→"),
      caja(_mono("C#001 · 2026-02-03"), color: c))],
    zona("Partición C", color: c)[#caja(_mono("C#003 · 2026-02-11"), color: c)],
  )
]

=== Particiones y claves calientes

Cada partición física guarda en torno a 10 GB y admite hasta *3000 RCU y 1000 WCU* (unidades de lectura y escritura que verás en el apartado siguiente). DynamoDB divide particiones por ti cuando crecen los datos o el tráfico, pero no puede repartir lo que se concentra en *un único valor* de partition key. Si todo va a la misma clave —la fecha de hoy, un producto viral, un estado como `PENDIENTE`— aparece una *partición caliente*: _throttling_ aunque la tabla tenga capacidad de sobra. La *capacidad adaptativa* mitiga desequilibrios moderados, pero el remedio está en el diseño.

#practica[Elige una partition key con *muchos valores distintos* y accesos repartidos (id de usuario, de pedido). Si un valor es inevitablemente popular, reparte sus escrituras con un sufijo (`2026-03-14#0` … `#9`); para lecturas repetidas de pocas claves, pon una caché delante.]

=== Capacidad y consistencia

Cada lectura y escritura consume *unidades de capacidad*. *1 RCU* (_read capacity unit_) es una lectura fuertemente consistente por segundo de hasta *4 KB*, o dos eventualmente consistentes; *1 WCU* (_write capacity unit_), una escritura por segundo de hasta *1 KB*. Los tamaños se *redondean hacia arriba* (6 KB cuentan como 8 KB al leer; 2,5 KB, como 3 KB al escribir) y las operaciones transaccionales cuestan el doble.

¿Eventual o fuerte? Por defecto, las lecturas son *eventualmente consistentes*: pueden no reflejar una escritura de hace un instante (normalmente todo converge en un segundo). Con `ConsistentRead=True` obtienes una lectura *fuertemente consistente*, que devuelve el último valor confirmado, a cambio del doble de capacidad:

#block(breakable: false)[#tabla(("Necesidad", "Cálculo", "Capacidad"), columnas: (1.7fr, 1.7fr, 0.7fr), tamano: 8pt,
  [80 lecturas/s de 6 KB, fuertemente consistentes], [6 KB → 2 bloques de 4 KB = 2 RCU × 80], [*160 RCU*],
  [Las mismas lecturas, eventualmente consistentes], [La mitad: 160 / 2], [*80 RCU*],
  [40 escrituras/s de 2,5 KB], [2,5 KB → 3 KB = 3 WCU × 40], [*120 WCU*],
  [Las mismas escrituras, dentro de transacciones], [El doble: 120 × 2], [*240 WCU*],
)]

Esa capacidad se paga de una de estas dos maneras, y puedes cambiar de modo más adelante:

#tarjetas(
  tarjeta("On-demand", subtitulo: "Pagas por petición")[Sin planificar: absorbe al instante hasta el doble del pico de tráfico anterior. Ideal para cargas nuevas, impredecibles o con picos; tras la rebaja de precios de finales de 2024, AWS lo recomienda por defecto para la mayoría de tablas.],
  tarjeta("Aprovisionada", color: col.costes, subtitulo: "Reservas RCU y WCU")[Fijas las unidades por segundo y pagas por hora, las uses o no; *Auto Scaling* las ajusta y la capacidad reservada abarata más. Lo más económico con tráfico estable; si te quedas corto, hay throttling.],
)

=== Query frente a Scan

Para leer un ítem concreto basta `GetItem` con su clave primaria completa: es la operación más rápida y barata. Para leer varios ítems hay dos operaciones muy distintas:

#tarjetas(
  tarjeta("Query", subtitulo: "Eficiente: lee solo lo que pides")[
    - Exige la partition key (igualdad).
    - Condición opcional sobre la sort key: `=`, `<`, `>`, `BETWEEN`, `begins_with`.
    - Devuelve los ítems ordenados por la sort key.
    - Consume capacidad solo por lo que lee.
  ],
  tarjeta("Scan", color: col.iam, subtitulo: "Caro: recorre toda la tabla")[
    - Lee todos los ítems de todas las particiones.
    - Consume capacidad por *todo* lo leído.
    - Un `FilterExpression` se aplica *después* de leer: no abarata nada.
    - Úsalo para tablas pequeñas o procesos puntuales; para analítica, exporta a S3.
  ],
)

```python
import boto3
from boto3.dynamodb.conditions import Key

pedidos = boto3.resource("dynamodb").Table("Pedidos")
# Pedidos de 2026 del cliente C#001, del más reciente al más antiguo
resp = pedidos.query(
    KeyConditionExpression=Key("cliente").eq("C#001")
        & Key("fecha").begins_with("2026-"),
    ScanIndexForward=False,
)
for p in resp["Items"]:      # más de 1 MB → paginar con LastEvaluatedKey
    print(p["fecha"], p["importe"])
```

=== Índices secundarios: LSI y GSI

Una Query solo busca por la clave primaria. Para consultar por otros atributos —«el pedido P81», sin saber de qué cliente es— creas *índices secundarios*: copias de la tabla organizadas con otra clave, que DynamoDB mantiene al día por ti. Decides qué atributos se *proyectan* (se copian) en el índice (`KEYS_ONLY`, `INCLUDE` o `ALL`), y como el índice solo contiene los ítems que tienen su clave, permite *índices dispersos* muy baratos.

#block(breakable: false)[#tabla(("Característica", "LSI (índice secundario local)", "GSI (índice secundario global)"),
  columnas: (1.15fr, 1.4fr, 1.4fr),
  [Clave del índice], [Misma partition key, *otra sort key*], [*Otra partition key* (y sort key opcional)],
  [Cuándo se crea], [Solo al crear la tabla], [En cualquier momento],
  [Máximo por tabla], [5], [20 (cuota ajustable)],
  [Capacidad], [Comparte la de la tabla], [Propia (en modo aprovisionado)],
  [Lecturas fuertemente consistentes], si, no,
  [Restricción de tamaño], [10 GB por valor de partition key], [Ninguna específica],
  [Alcance de la consulta], [Dentro de una colección de ítems], [Toda la tabla],
)]

En la tabla `Pedidos` del ejemplo (clave `cliente` + `fecha`):

- Un *GSI* con partition key `num_pedido` responde a «dame el pedido P81» con una Query, sea del cliente que sea. Como se crea en cualquier momento, es la solución habitual cuando aparece un patrón de acceso nuevo.
- Un *LSI* con sort key `importe` daría «los pedidos de C\#001, ordenados por importe», pero tendría que haberse definido al crear la tabla. A cambio, admite lecturas fuertemente consistentes: el GSI se actualiza de forma asíncrona.

=== TTL, Streams y transacciones

#tarjetas(columnas: 3,
  tarjeta("TTL", subtitulo: "Caducidad automática")[Indicas un atributo con una fecha en _epoch_ (segundos) y DynamoDB borra los ítems caducados en segundo plano, sin consumir WCU. No es inmediato —puede tardar días—, así que filtra los caducados al leer. Ideal para sesiones, cachés y datos temporales.],
  tarjeta("Streams", subtitulo: "Registro de cambios")[Cada alta, cambio o borrado genera un registro, ordenado por ítem y retenido 24 horas, con la imagen nueva, la antigua o ambas. Una función Lambda puede procesarlos para auditar, notificar, agregar o replicar.],
  tarjeta("Transacciones", subtitulo: "ACID entre ítems")[`TransactWriteItems` y `TransactGetItems` agrupan hasta 100 acciones (máximo 4 MB) sobre una o varias tablas de la misma cuenta y región: o se aplican todas o ninguna. Cuestan el doble de capacidad.],
)

=== Operaciones condicionales

Las escrituras aceptan una *expresión de condición*: si no se cumple, fallan con `ConditionalCheckFailedException` sin cambiar nada. Con `attribute_not_exists(PK)` evitas sobrescribir un ítem existente, y con un número de versión implementas *bloqueo optimista*:

```python
# Solo si nadie ha cambiado la revisión 7 mientras tanto
pedidos.update_item(
    Key={"cliente": "C#001", "fecha": "2026-02-03"},
    UpdateExpression="SET estado = :e, revision = revision + :uno",
    ConditionExpression="revision = :r",
    ExpressionAttributeValues={":e": "ENVIADO", ":uno": 1, ":r": 7},
)
```

=== Global tables, DAX y copias de seguridad

- *Global tables*: réplicas *activas* en varias regiones (todas aceptan lecturas y escrituras); los cambios se propagan normalmente en torno a un segundo y los conflictos se resuelven con «gana la última escritura». Desde 2025 hay también un modo de consistencia fuerte multirregión.
- *DAX* (_DynamoDB Accelerator_): caché en memoria compatible con la API de DynamoDB que baja las lecturas a *microsegundos*; cambias el cliente, no la lógica. Es un clúster dentro de tu VPC y solo acelera lecturas eventualmente consistentes.
- *Copias*: PITR restaura a cualquier segundo de los últimos 35 días (periodo configurable); los backups bajo demanda duran hasta que los borras y AWS Backup los copia a otras regiones o cuentas. Restaurar crea una *tabla nueva*, y exportar a S3 desde PITR no consume capacidad.

=== Introducción al single-table design

DynamoDB no tiene joins: enumeras tus *patrones de acceso* y diseñas las claves para resolver cada uno con una sola Query. El *single-table design* lleva la idea al extremo: varias entidades en *una misma tabla*, con claves genéricas (`PK`, `SK`) y prefijos de tipo, para que los datos relacionados se lean juntos.

#tabla(("PK", "SK", "Atributos", "Entidad"), columnas: (1.15fr, 1.75fr, 1.9fr, 0.75fr), tamano: 8pt,
  [`CLIENTE#ana`], [`PERFIL`], [nombre, email, fecha de alta], [Cliente],
  [`CLIENTE#ana`], [`PEDIDO#2026-02-03#P81`], [importe: 120, estado: PENDIENTE], [Pedido],
  [`CLIENTE#ana`], [`PEDIDO#2026-01-15#P42`], [importe: 49,90, estado: ENVIADO], [Pedido],
  [`PEDIDO#P81`], [`LINEA#01`], [sku: TAZA-AZUL, cantidad: 2], [Línea],
  [`PEDIDO#P81`], [`LINEA#02`], [sku: CAFE-1KG, cantidad: 1], [Línea],
)

- Perfil y pedidos de Ana en una sola petición: Query con `PK = "CLIENTE#ana"`.
- Solo sus pedidos de 2026: añade `begins_with(SK, "PEDIDO#2026")`.
- Líneas de un pedido: Query con `PK = "PEDIDO#P81"`.
- Pedidos pendientes de todos los clientes: un GSI disperso, cuya clave (estado y fecha) solo llevan los pedidos pendientes.

No es obligatorio: exige conocer los patrones de acceso de antemano y complica la analítica y la evolución del modelo. Varias tablas bien diseñadas también son una opción válida.

== Amazon ElastiCache y MemoryDB

Muchas aplicaciones leen los mismos datos una y otra vez (la ficha de un producto, la sesión del usuario). Guardarlos en memoria baja la latencia a microsegundos o pocos milisegundos y descarga a la base de datos.

#ficha("Amazon ElastiCache", "Caché en memoria gestionada: Valkey, Redis OSS y Memcached",
  ("Modalidades", [Clústeres de nodos (eliges tipo y número) o ElastiCache Serverless]),
  ("Despliegue", [Dentro de tu VPC; accesible solo desde la red privada]),
  ("Ideal para", [Cachear consultas y objetos, sesiones, rankings, contadores y limitación de peticiones]))

*Valkey*, el _fork_ abierto de Redis nacido en 2024 (Linux Foundation) tras su cambio de licencia, tiene la misma API que Redis OSS y un precio inferior en ElastiCache: es la opción recomendada para proyectos nuevos. Memcached, más simple, solo sirve como caché volátil que escala en horizontal.

#block(breakable: false)[#tabla(("", "Valkey / Redis OSS", "Memcached"), columnas: (1.5fr, 1fr, 1fr),
  [Estructuras de datos (hashes, listas, sets ordenados, streams…)], si, no,
  [Réplicas, Multi-AZ con failover y snapshots], si, no,
  [Particionado (_sharding_)], [#si Modo clúster], [#si Desde el cliente],
  [Pub/Sub, scripts Lua y transacciones], si, no,
)]

=== Estrategias de caché

#diagrama(pie: [Patrón _lazy loading_: la aplicación consulta primero la caché y solo va a la base de datos cuando no encuentra el dato.])[
  #fila(espacio: 4pt,
    svc("EC", "ElastiCache", sub: "Valkey o Redis OSS", color: col.datos),
    flecha(etiqueta: [1 · GET (no está) · 3 · SET con TTL], largo: 3.4cm, doble: true),
    svc("App", "Aplicación", color: col.computo),
    flecha(etiqueta: [2 · SELECT], largo: 2.6cm, doble: true),
    svc("RDS", "Base de datos", sub: "RDS, Aurora…", color: col.datos),
  )
]

#tarjetas(
  tarjeta("Lazy loading (cache-aside)", subtitulo: "Se carga al leer")[Solo se cachea lo que alguien pide y una caída de la caché no rompe nada. A cambio, cada fallo cuesta tres viajes y el dato puede quedar *obsoleto* hasta que caduque su TTL.],
  tarjeta("Write-through", subtitulo: "Se actualiza al escribir")[Cada escritura actualiza también la caché: datos siempre frescos, a cambio de escrituras más lentas y de cachear datos que quizá nadie lea. Combina ambos y pon siempre un TTL.],
)

*Amazon MemoryDB* va un paso más allá: es una *base de datos* en memoria, compatible con Valkey y Redis OSS, que guarda cada escritura en un log transaccional distribuido en varias AZ. No pierde datos si cae un nodo, así que puede ser la base de datos principal, no solo una caché.

#examen[«Caché delante de una base de datos» → ElastiCache; «caché para DynamoDB sin tocar el código» → DAX; «base de datos principal en memoria y duradera» → MemoryDB.]

== Otras bases de datos de propósito específico

#tabla(("Servicio", "Modelo", "Lo esencial"), columnas: (1.25fr, 1.1fr, 3fr), tamano: 8pt,
  [*Amazon DocumentDB*], [Documental (API de MongoDB)], [Documentos JSON con índices y consultas ricas; almacenamiento al estilo Aurora (6 copias en 3 AZ) y _elastic clusters_ para repartir datos.],
  [*Amazon Keyspaces*], [Columnar ancha (Cassandra)], [Compatible con CQL y los drivers de Cassandra, pero serverless: on-demand o aprovisionado, sin nodos.],
  [*Amazon Neptune*], [Grafos], [Grafos de propiedades (Gremlin, openCypher) y RDF (SPARQL): fraude, recomendaciones, relaciones de varios saltos.],
  [*Amazon Timestream*], [Series temporales], [Para proyectos nuevos, *Timestream for InfluxDB*; Timestream for LiveAnalytics dejó de aceptar clientes nuevos en 2025.],
  [*Amazon OpenSearch Service*], [Búsqueda, logs y vectores], [OpenSearch gestionado (antes Amazon Elasticsearch Service), en clústeres o Serverless: texto completo, logs y búsqueda vectorial.],
)

=== Analítica: Redshift y Athena

*Amazon Redshift* es el _data warehouse_ de AWS. Guarda los datos por *columnas* —sumar importes solo lee esa columna, muy comprimida— y reparte el trabajo con una arquitectura *MPP* (_massively parallel processing_): un nodo líder planifica y los nodos de cómputo ejecutan en paralelo. Los nodos RA3 separan cómputo y almacenamiento, *Redshift Spectrum* consulta S3 sin cargar los datos y *Redshift Serverless* elimina el clúster (pagas por RPU-hora). Las integraciones *zero-ETL* traen datos de Aurora, RDS y DynamoDB casi en tiempo real.

*Amazon Athena* es un motor SQL serverless que consulta ficheros en S3 (CSV, JSON, Parquet, ORC…) usando el catálogo de AWS Glue. No hay nada que aprovisionar y se paga por datos escaneados: perfecto para consultas ad hoc sobre un _data lake_ o sobre logs, como los de los balanceadores:

```sql
SELECT elb_status_code, count(*) AS peticiones
FROM alb_logs
WHERE day = '2026/03/14' AND elb_status_code >= 500
GROUP BY elb_status_code
ORDER BY peticiones DESC;
```

#coste[En Athena pagas por TB escaneado: usa formato columnar (Parquet u ORC), comprime y *particiona* (por fecha, por ejemplo) para que el `WHERE` descarte carpetas enteras. La misma consulta puede costar decenas de veces menos.]

== Migraciones: AWS DMS y SCT

*AWS Database Migration Service (DMS)* copia datos de un origen a un destino mientras el origen *sigue funcionando*: primero una *carga completa* y después los cambios en curso (*CDC*, _change data capture_) hasta el corte, así que la parada se reduce a minutos. Admite migraciones *homogéneas* (MySQL → Aurora MySQL) y *heterogéneas* (Oracle → Aurora PostgreSQL), desde bases de datos en tu centro de datos, en EC2 o en RDS hacia destinos como RDS, Aurora, S3, DynamoDB o Redshift, con una instancia de replicación o con *DMS Serverless*.

#diagrama(pie: [Migración heterogénea de Oracle a Aurora PostgreSQL: SCT convierte el esquema y DMS copia los datos y replica los cambios hasta el corte.])[
  #fila(espacio: 8pt,
    zona("Centro de datos", color: col.neutro, ancho: 3.8cm)[#svc("ORA", "Oracle", sub: "origen, sigue en uso", color: col.neutro)],
    flecha(etiqueta: [carga completa + CDC], largo: 2.7cm),
    zona("AWS · VPC", color: col.redes)[#fila(espacio: 4pt,
      svc("DMS", "AWS DMS", sub: "instancia o Serverless", color: col.datos),
      flecha(largo: 1.2cm),
      svc("APG", "Aurora PostgreSQL", sub: "destino", color: col.datos))],
  )
]

DMS mueve *datos*, no traduce esquemas: en una migración heterogénea, primero conviertes tablas, vistas y procedimientos (PL/SQL → PL/pgSQL, por ejemplo) con *AWS Schema Conversion Tool (SCT)*, una aplicación de escritorio, o con *DMS Schema Conversion*, integrada en la consola; ambas informan de lo que exige revisión manual. El plan típico: evaluar, convertir el esquema, carga completa más CDC, validar los datos y cambiar la aplicación al destino.

#resumen[
- Elige por *patrón de acceso*: relacional para SQL y transacciones, DynamoDB para clave-valor a escala, ElastiCache para microsegundos, Redshift y Athena para analítica. Lo gestionado te quita parches, backups y failover.
- RDS: *Multi-AZ* da disponibilidad (standby síncrono; la variante de clúster tiene dos standbys legibles) y las *réplicas de lectura* escalan lecturas de forma asíncrona, incluso entre regiones.
- PITR de hasta 35 días (restaurar crea una instancia nueva); RDS Proxy agrupa conexiones y Blue/Green reduce el riesgo de actualizar.
- Aurora separa cómputo y almacenamiento: 6 copias en 3 AZ, hasta 15 réplicas con poco retardo, endpoints de escritura y lectura, Serverless v2 desde 0 ACU y Global Database.
- DynamoDB se diseña desde las claves: partition key con muchos valores, Query en lugar de Scan, GSI para accesos nuevos y RCU/WCU por bloques de 4 KB y 1 KB; TTL, Streams, transacciones, global tables y DAX lo completan.
- ElastiCache (Valkey, Redis OSS, Memcached) acelera lecturas con lazy loading o write-through; MemoryDB es una base de datos en memoria duradera.
- DMS migra con parada mínima (carga completa + CDC); SCT convierte el esquema en migraciones heterogéneas.
]

#repaso(
  ([Tu aplicación en RDS necesita sobrevivir a la caída de una AZ y, además, descargar los informes de la primaria. ¿Qué configuras?],
   [Multi-AZ para la disponibilidad y réplicas de lectura para los informes. Alternativa en MySQL o PostgreSQL: un despliegue Multi-AZ de clúster, cuyos dos standbys sí admiten lecturas.]),
  ([Alguien borró una tabla a las 10:42. ¿Cómo recuperas los datos en RDS y qué debes tener en cuenta?],
   [Con una restauración a un punto en el tiempo (PITR) a las 10:41, dentro del periodo de retención. Se crea una instancia nueva con otro endpoint; luego copias los datos o apuntas la aplicación a ella. En Aurora MySQL con backtrack activado podrías rebobinar el clúster en el sitio.]),
  ([Cientos de funciones Lambda agotan las conexiones de tu base de datos Aurora. ¿Qué servicio lo resuelve?],
   [RDS Proxy, que mantiene un pool de conexiones y las reutiliza entre las invocaciones; además, acelera los failovers y admite autenticación IAM.]),
  ([Necesitas 100 lecturas por segundo, eventualmente consistentes, de ítems de 10 KB. ¿Cuántas RCU aprovisionas?],
   [10 KB se redondean a 12 KB, es decir, 3 RCU por lectura fuertemente consistente; eventual es la mitad, 1,5 RCU. En total, 100 × 1,5 = 150 RCU.]),
  ([Quieres consultar una tabla de DynamoDB existente por un atributo que no forma parte de la clave. ¿LSI o GSI?],
   [Un GSI: se puede crear en cualquier momento y admite otra partition key. Los LSI solo se definen al crear la tabla y comparten la partition key de la tabla.]),
  ([Vas a migrar de Oracle a Aurora PostgreSQL con la mínima parada. ¿Qué herramientas usas?],
   [SCT (o DMS Schema Conversion) para convertir el esquema y el código, y DMS con carga completa más CDC para copiar los datos y mantenerlos sincronizados hasta el corte.]),
)
