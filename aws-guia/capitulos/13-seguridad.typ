#import "../theme.typ": *

// ---------------------------------------------------------------------
//  Ayudantes locales de este capítulo
// ---------------------------------------------------------------------
// Marcador numerado para diagramas
#let num(n, color: col.seguridad) = box(baseline: 1.6pt, circle(radius: 5.2pt, fill: color, inset: 0pt,
  align(center + horizon, text(6.3pt, weight: "bold", fill: white, str(n)))))

// Iconos de llave y candado dibujados con primitivas de Typst
#let llave(color: col.seguridad) = box(width: 15pt, height: 7pt, baseline: 0.5pt, {
  place(left + horizon, circle(radius: 2.8pt, stroke: 1.4pt + color))
  place(left + horizon, dx: 6.2pt, rect(width: 8.8pt, height: 1.6pt, fill: color))
  place(left + top, dx: 11pt, dy: 4pt, rect(width: 1.4pt, height: 2.6pt, fill: color))
  place(left + top, dx: 13.4pt, dy: 4pt, rect(width: 1.4pt, height: 2pt, fill: color))
})

#let candado(color: col.seguridad) = box(width: 8pt, height: 10pt, baseline: 1pt, {
  place(center + top, rect(width: 5pt, height: 6pt, radius: (top-left: 2.5pt, top-right: 2.5pt),
    stroke: (top: 1.3pt + color, left: 1.3pt + color, right: 1.3pt + color)))
  place(center + bottom, rect(width: 8pt, height: 5.4pt, radius: 1.2pt, fill: color))
})

#capitulo(text(hyphenate: false)[Seguridad: cifrado con KMS, secretos y protección], color: col.seguridad,
  subtitulo: [Cifra tus datos con claves que controlas, saca los secretos del código y levanta defensas en cada capa: del borde de la red a la respuesta ante incidentes.],
  objetivos: (
    [Cifrado en reposo y en tránsito; simétrico y asimétrico],
    [Tipos de clave de KMS y cómo funcionan las key policies],
    [Cifrado envolvente, paso a paso],
    [Rotación, alias, claves multi-región y borrado],
    [Secretos y certificados: Secrets Manager, Parameter Store y ACM],
    [WAF, Shield, GuardDuty, Security Hub y respuesta a incidentes],
  ),
  servicios: ("AWS KMS", "AWS CloudHSM", "Secrets Manager", "Parameter Store", "ACM", "AWS WAF", "AWS Shield", "GuardDuty", "Security Hub", "Inspector", "Macie", "Detective"))

== Por qué cifrar

Imagina que alguien consigue una copia de tus datos: un snapshot compartido por error, una copia de seguridad olvidada, un disco retirado. Contra una copia que ya está fuera, las políticas de IAM no sirven de nada; el cifrado sí: sin la clave, el atacante se lleva ruido. Además, muchas normativas (RGPD, PCI DSS, HIPAA, ENS…) exigen cifrar y demostrar quién controla las claves. AWS cifra mucho por defecto, pero decidir qué clave protege qué datos y quién puede usarla es tu parte del modelo de responsabilidad compartida (capítulo de Fundamentos).

La primera parte del capítulo explica el cifrado y *AWS KMS* desde cero; la segunda, secretos, certificados, protección perimetral, detección y respuesta a incidentes. IAM, redes y observabilidad tienen sus propios capítulos: aquí solo los citamos.

#tarjetas(
  tarjeta("Cifrado en reposo", subtitulo: "at rest: datos almacenados")[
    Volúmenes EBS, objetos de S3, bases de datos, snapshots, copias y logs. En AWS suele bastar un ajuste (o viene activado), con claves gestionadas por *KMS*: SSE-KMS en S3, cifrado de EBS y de RDS…
  ],
  tarjeta("Cifrado en tránsito", color: col.redes, subtitulo: "in transit: datos que viajan por la red")[
    Navegador → balanceador, aplicación → base de datos… Se consigue con *TLS* (HTTPS) y certificados de *ACM*. Puedes exigirlo: `aws:SecureTransport` en una bucket policy, `rds.force_ssl` en PostgreSQL.
  ],
)

=== Simétrico y asimétrico

El cifrado *simétrico* usa la misma clave para cifrar y descifrar: es rápido y sirve para cualquier volumen de datos, pero hay que hacer llegar la clave, con seguridad, a quien descifra (el estándar es AES-256). El *asimétrico* usa un par de claves: lo que cifra la *pública*, que se reparte sin miedo, solo lo descifra la *privada*, que no sale de su dueño. Es mucho más lento, así que se usa para intercambiar claves y para *firmas digitales* (RSA, curvas elípticas o ECC). TLS combina ambos: acuerda con criptografía asimétrica una clave simétrica de sesión y cifra el tráfico con ella.

#diagrama(pie: [Cifrado simétrico (una clave compartida) frente a asimétrico (un par de claves pública y privada).])[
  #set text(hyphenate: false)
  #set par(justify: false)
  #grid(columns: (2.5cm, auto), row-gutter: 12pt, column-gutter: 8pt, align: (left + horizon, center + horizon),
    [#text(9pt, weight: "bold", fill: col.seguridad)[Simétrico] \ #text(7pt, fill: gris)[una clave compartida \ AES-256]],
    fila(espacio: 3pt,
      caja([Texto en claro]),
      flecha(etiqueta: [#llave() clave K], largo: 2.2cm),
      caja([#candado() Texto cifrado], color: col.seguridad),
      flecha(etiqueta: [#llave() la misma clave K], largo: 2.2cm),
      caja([Texto en claro])),
    [#text(9pt, weight: "bold", fill: col.datos)[Asimétrico] \ #text(7pt, fill: gris)[par de claves \ RSA, ECC]],
    fila(espacio: 3pt,
      caja([Texto en claro]),
      flecha(etiqueta: [#llave(color: col.almacenamiento) clave pública], largo: 2.2cm),
      caja([#candado(color: col.datos) Texto cifrado], color: col.datos),
      flecha(etiqueta: [#llave(color: col.datos) clave privada], largo: 2.2cm),
      caja([Texto en claro])),
  )
]

/ Clave: un secreto —256 bits en AES-256— que, junto con un algoritmo público, cifra y descifra. La seguridad depende de que la clave sea secreta, no el algoritmo.
/ HSM (Hardware Security Module): dispositivo físico resistente a manipulaciones que genera y guarda claves y opera con ellas por dentro, como una cámara acorazada donde, además de guardar las combinaciones, se abren las cajas: no le pides «dame la clave», sino «cifra esto con la clave». KMS y CloudHSM usan HSM validados según FIPS 140 de nivel 3.

== AWS KMS y sus tipos de clave

*AWS Key Management Service (KMS)* crea y guarda claves criptográficas —las *claves KMS*— en HSM gestionados por AWS. Nunca ves el material de la clave: llamas a la API (`Encrypt`, `Decrypt`, `GenerateDataKey`, `Sign`…) y KMS opera dentro del HSM y te devuelve el resultado. Cada clave vive en una región y se usa a través del endpoint de KMS de esa región. (En exámenes y textos antiguos verás *CMK*, _customer master key_: hoy se dice *clave KMS*.)

#ficha("AWS KMS", "Key Management Service: crea, guarda y usa claves criptográficas en HSM gestionados por AWS",
  ("Tipo", [Servicio gestionado y regional; pago por clave al mes y por petición]),
  ("Integración", [Más de cien servicios: S3, EBS, RDS, DynamoDB, Secrets Manager, Lambda, SQS…]),
  ("Control de acceso", [Key policy (obligatoria) + políticas IAM + grants]),
  ("Auditoría", [Cada uso de una clave queda registrado en CloudTrail]))

=== ¿De quién es la clave?

La primera clasificación responde a quién crea y controla la clave; DynamoDB, por ejemplo, te deja elegir entre las tres.

#tabla(("", "AWS owned", "AWS managed", "Customer managed"), columnas: (1.3fr, 1fr, 1.15fr, 1.35fr), tamano: 8pt,
  [Qué es], [Del servicio, compartidas entre cuentas (p. ej., DynamoDB por defecto)], [Las crea un servicio en tu cuenta: `aws/s3`, `aws/ebs`…], [Las creas y administras tú],
  [Visible y auditada en tu cuenta (CloudTrail)], no, si, si,
  [¿Editas su key policy?], no, [#no (solo lectura)], si,
  [¿La usas desde tu código?], no, [#no (solo vía el servicio)], si,
  [Rotación], [La decide AWS], [Automática y obligatoria, cada año], [Opcional: automática (365 días por defecto, de 90 a 2560) o bajo demanda],
  [¿Compartir con otra cuenta?], no, no, si,
  [Coste], [Gratis], [Sin cuota mensual; pagas las peticiones], [Cuota mensual por clave + peticiones],
)

#examen[Si el enunciado pide editar la key policy, rotar a voluntad, compartir la clave con otra cuenta o poder borrarla, la respuesta es una *customer managed*.]

=== ¿Qué criptografía? Simétricas, asimétricas y HMAC

El *uso* de una clave (cifrar, firmar, generar MAC…) se fija al crearla y no se puede cambiar.

#tarjetas(columnas: 3,
  tarjeta("Simétricas", subtitulo: "la opción por defecto")[
    AES-256-GCM (`SYMMETRIC_DEFAULT`). La usan *todos* los servicios integrados; admite contexto de cifrado, rotación automática, material importado y multi-región.
  ],
  tarjeta("Asimétricas", color: col.datos, subtitulo: "RSA y ECC")[
    La privada no sale de KMS; la pública se descarga (`GetPublicKey`). RSA cifra o firma; ECC firma o acuerda secretos. Para firmas digitales y terceros sin credenciales de AWS.
  ],
  tarjeta("HMAC", color: col.iam, subtitulo: "integridad y autenticidad")[
    Genera y verifica códigos HMAC (`GenerateMac`, `VerifyMac`) sin que la clave salga de KMS: prueba que un mensaje o un token no se ha alterado.
  ],
)

== Quién puede usar una clave: key policies, IAM y grants

En casi todo AWS, una política IAM basta para acceder a un recurso de tu cuenta (capítulo de IAM (II)). KMS es la excepción: *la key policy manda*. Nadie —ni siquiera el usuario raíz— puede usar ni administrar una clave si su key policy no lo permite, directamente o delegando en IAM. Hay tres mecanismos: la *key policy* (obligatoria: toda clave tiene *exactamente una*), las *políticas IAM* (solo cuentan si la key policy delega en la cuenta) y los *grants* (permisos puntuales que se crean y revocan por API).


=== Una key policy, comentada

Si creas una clave sin indicar política, KMS le asigna la *política por defecto*, cuya sentencia esencial es la primera de este ejemplo, pensado para una aplicación de pagos:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    { "Sid": "Delegar en IAM", "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::111122223333:root" },
      "Action": "kms:*", "Resource": "*" },
    { "Sid": "Administradores", "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::111122223333:role/AdminClaves" },
      "Action": [ "kms:Create*", "kms:Describe*", "kms:Enable*", "kms:List*",
        "kms:Put*", "kms:Update*", "kms:Revoke*", "kms:Disable*", "kms:Get*",
        "kms:Delete*", "kms:ScheduleKeyDeletion", "kms:CancelKeyDeletion" ],
      "Resource": "*" },
    { "Sid": "Uso por la app solo via S3", "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::111122223333:role/AppPagos" },
      "Action": [ "kms:GenerateDataKey", "kms:Decrypt" ], "Resource": "*",
      "Condition": { "StringEquals": {
        "kms:ViaService": "s3.eu-west-1.amazonaws.com" } } },
    { "Sid": "Otra cuenta puede descifrar", "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::444455556666:root" },
      "Action": [ "kms:Decrypt", "kms:DescribeKey" ], "Resource": "*" }
  ]
}
```

#pasos(
  [*Delegar en IAM.* El principal `…:root` no es el usuario raíz, sino la *cuenta entera*: «la cuenta decide, con IAM, quién usa esta clave». Sin esta sentencia, las políticas IAM no tienen efecto sobre la clave. Aquí `"Resource": "*"` significa «esta clave».],
  [*Administradores.* `AdminClaves` gestiona la clave (política, activación, borrado), pero no puede cifrar ni descifrar: *separación de funciones*.],
  [*Uso.* `AppPagos` genera claves de datos y descifra, pero solo a través de S3 en eu-west-1 (`kms:ViaService`), no con llamadas directas a KMS.],
  [*Otra cuenta.* La cuenta 444455556666 puede descifrar… si, además, su administrador lo concede con IAM, como verás enseguida.],
)

#cuidado[Una key policy que deja fuera a todo el mundo (sin la sentencia de la cuenta ni administradores) vuelve la clave *inmanejable*, y solo AWS Support podrá ayudarte. KMS rechaza esas políticas salvo que fuerces `BypassPolicyLockoutSafetyCheck`. No lo hagas.]

=== Cómo se evalúa una petición

KMS combina los tres mecanismos con la lógica que conoces de IAM (II): un _Deny_ explícito gana siempre y, para permitir, basta uno de los tres caminos. Por encima siguen aplicando las SCP y RCP de AWS Organizations y las políticas de los endpoints de VPC.

#diagrama(pie: [Cómo decide KMS una petición (por ejemplo, AppPagos llama a kms:Decrypt). Un _Deny_ explícito deniega; para permitir basta uno de los tres caminos.])[
  #set text(hyphenate: false)
  #set par(justify: false)
  #let decision(t) = caja(box(width: 100%, height: 1.25cm, align(center + horizon, t)), color: col.seguridad, ancho: 2.75cm)
  #let permitido = caja([*PERMITIDO*], color: col.almacenamiento, relleno: col.almacenamiento.lighten(85%), ancho: 2.3cm)
  #let denegado(t) = caja(t, color: col.iam, relleno: col.iam.lighten(85%), ancho: 2.2cm)
  #grid(columns: (2.8cm, 0.5cm, 2.8cm, 0.5cm, 2.8cm, 0.5cm, 2.8cm, 0.5cm, 2.2cm), align: center + horizon, row-gutter: 1pt,
    decision([¿Hay un _Deny_ explícito en alguna política?]), flecha(etiqueta: "no", largo: 0.5cm),
    decision([#num(1) ¿La *key policy* lo permite a ese principal?]), flecha(etiqueta: "no", largo: 0.5cm),
    decision([#num(2) ¿La key policy delega en la cuenta *y* IAM lo permite?]), flecha(etiqueta: "no", largo: 0.5cm),
    decision([#num(3) ¿Algún *grant* lo permite?]), flecha(etiqueta: "no", largo: 0.5cm),
    denegado([*DENEGADO* \ (implícito)]),
    flecha-v(etiqueta: "sí", largo: 0.55cm), [], flecha-v(etiqueta: "sí", largo: 0.55cm), [],
    flecha-v(etiqueta: "sí", largo: 0.55cm), [], flecha-v(etiqueta: "sí", largo: 0.55cm), [], [],
    denegado([*DENEGADO*]), [], permitido, [], permitido, [], permitido, [], [],
  )
]

Un *grant* da a un principal concreto ciertas operaciones sobre una clave, sin tocar la key policy, y se revoca al instante. Los servicios los usan a diario: al adjuntar un volumen EBS cifrado, EC2 crea un grant para descifrar la clave de datos del volumen mientras lo usa.

=== Acceso entre cuentas

Para que la cuenta B use una clave de la cuenta A hace falta permiso *en los dos lados*: la key policy (en A) debe permitir a la cuenta B o a un rol suyo, y una política IAM (en B) debe conceder a ese rol las acciones sobre el ARN de la clave. Si falta uno, se deniega. Desde B, la clave se indica por su *ARN completo* (el alias corto solo funciona en su cuenta), y solo se comparten operaciones de uso, nunca las de administración.

#diagrama(pie: [Acceso entre cuentas: la propietaria lo permite en la key policy y la consumidora lo concede con IAM. Hacen falta las dos.])[
  #set text(hyphenate: false)
  #set par(justify: false)
  #fila(espacio: 6pt,
    zona("Cuenta B · 444455556666 · consumidora", color: col.iam)[
      #fila(espacio: 6pt,
        svc("IAM", "Rol AppAnalitica", color: col.iam),
        caja([*Política IAM del rol* \ Allow kms:Decrypt \ sobre el ARN de la clave], color: col.iam, ancho: 3.3cm))
    ],
    flecha(etiqueta: "kms:Decrypt (ARN)", largo: 2cm),
    zona("Cuenta A · 111122223333 · propietaria", color: col.seguridad)[
      #fila(espacio: 6pt,
        svc("KMS", "Clave customer managed", color: col.seguridad),
        caja([*Key policy* \ Allow kms:Decrypt \ a la cuenta 444455556666], color: col.seguridad, ancho: 3.1cm))
    ],
  )
]

#examen[Las claves AWS managed (`aws/rds`, `aws/ebs`…) *no se pueden compartir*: no puedes editar su key policy. Para compartir un snapshot cifrado de EBS o RDS, cópialo primero cifrándolo con una customer managed cuya key policy permita a la cuenta destino.]

== Cifrado envolvente (envelope encryption)

Si KMS nunca deja salir sus claves, ¿cómo cifra S3 un objeto de 5 GB? No enviándolo a KMS: `Encrypt` solo acepta hasta 4 KB, y mandar gigabytes a un servicio compartido sería lento, caro y chocaría con las cuotas. La solución es el *cifrado envolvente*: los datos se cifran en local con una *clave de datos* (_data key_), y con la clave KMS solo se cifra esa clave de datos.

#analogia[Cierras tus documentos en una caja con una llave cualquiera (la clave de datos), metes la llave en un sobre lacrado que solo el banco sabe abrir (KMS) y pegas el sobre a la caja. Quien robe la caja se lleva el sobre, pero sin el banco no lo abre. Y el banco nunca ve tus documentos: solo abre sobres.]

#pasos(
  [*Pedir una clave de datos:* la aplicación (o S3, EBS…) llama a `GenerateDataKey` con la clave KMS, que genera una clave de datos aleatoria, normalmente AES-256.],
  [*Recibir dos copias:* la clave de datos *en claro* y otra *cifrada* con la clave KMS, que no sale del HSM.],
  [*Cifrar en local* los datos con la clave en claro (AES-GCM, rapidísimo), sean 4 KB o 40 GB.],
  [*Descartar la clave en claro* de la memoria en cuanto termina. Nunca se escribe en disco.],
  [*Guardar juntas* la clave cifrada y los datos cifrados (en los metadatos del objeto, en la cabecera del fichero…). La clave cifrada no es secreta: sin KMS no sirve de nada.],
  [*Para leer*, enviar la clave cifrada a `Decrypt`. Si hay permiso, KMS devuelve la clave en claro; se descifran los datos y se vuelve a descartar.],
)

#diagrama(pie: [Cifrado envolvente. La clave KMS no sale de KMS: lo que viaja y se guarda junto a los datos es la clave de datos cifrada.])[
  #set text(hyphenate: false)
  #set par(justify: false)
  #let lbl(t, al) = box(width: 2.5cm, align(al, text(6.6pt, fill: tinta, t)))
  #let par-flechas(izq, der) = fila(espacio: 3pt, lbl(izq, right), flecha-v(arriba: true, largo: 1cm), h(8pt), flecha-v(largo: 1cm), lbl(der, left))
  #let guardado = fila(espacio: 0pt,
    caja([#candado() Datos cifrados], color: col.seguridad),
    caja([#llave() Clave de datos cifrada], color: col.seguridad))
  #fila(espacio: 14pt,
    zona("Escritura: cifrar", color: col.seguridad, ancho: 7.3cm)[
      #columna(espacio: 3pt,
        svc("KMS", "AWS KMS", sub: "la clave KMS no sale del HSM", color: col.seguridad),
        par-flechas([#num(1) GenerateDataKey], [#num(2) clave de datos en claro + cifrada]),
        svc("App", "Tu aplicación", sub: "o S3, EBS, RDS…", color: col.computo),
        flecha-v(etiqueta: [#num(3) cifra en local \ #num(4) borra la clave en claro \ #num(5) guarda ambos juntos], largo: 1.45cm),
        guardado,
      )
    ],
    zona("Lectura: descifrar", color: col.datos, ancho: 7.3cm)[
      #columna(espacio: 3pt,
        svc("KMS", "AWS KMS", sub: "comprueba permisos y contexto", color: col.seguridad),
        par-flechas([#num(6) Decrypt (clave de datos cifrada)], [clave de datos en claro]),
        svc("App", "Tu aplicación", sub: "descifra en local y borra la clave", color: col.computo),
        flecha-v(etiqueta: [lee ambos], largo: 1.45cm, arriba: true),
        guardado,
      )
    ],
  )
]

Así se resuelven a la vez el *tamaño* (no hay límite de 4 KB), el *rendimiento* (los datos no viajan a KMS), el *coste y las cuotas* (una petición por objeto, o por lote si reutilizas la clave de datos, y no una por bloque) y la *seguridad* (sin `kms:Decrypt`, quien copie datos y clave cifrada no abre el sobre). Los servicios integrados lo hacen por ti; en tu código, usa el AWS Encryption SDK. Y si un componente solo prepara claves que otro usará después, `GenerateDataKeyWithoutPlaintext` devuelve únicamente la copia cifrada.

```bash
aws kms generate-data-key --key-id alias/app-pagos --key-spec AES_256
# "CiphertextBlob": "AQIDAHh...",  <- clave de datos cifrada: guárdala con los datos
# "Plaintext":      "c2VjcmV0...",  <- clave en claro (Base64): úsala y bórrala
```

== Contexto de cifrado, alias, rotación y ciclo de vida

*Contexto de cifrado (encryption context).* Pares clave-valor *no secretos* que acompañan al cifrado, como `{"app": "pagos"}`. KMS los vincula criptográficamente al texto cifrado: para descifrar hay que presentar el mismo contexto. Impide reutilizar un texto cifrado fuera de su sitio, permite condiciones en las políticas (`kms:EncryptionContext:app`) y aparece en claro en CloudTrail, así que nunca metas en él datos sensibles. S3, por ejemplo, usa el ARN del objeto o del bucket.

*Alias.* Un nombre amigable (`alias/app-pagos`) que apunta a una clave: tu código usa el alias y, si cambias de clave, basta con reasignarlo (`update-alias`). Una clave puede tener varios; los que empiezan por `alias/aws/` son de las AWS managed. Como las claves, son regionales.

=== Rotación de claves

Rotar es generar material criptográfico nuevo. Las claves *AWS managed* rotan solas cada año, de forma obligatoria. En las *customer managed* simétricas, la rotación automática es opcional y está desactivada por defecto; al activarla rota cada 365 días, o con el periodo que elijas entre 90 y 2560, y además puedes forzar una *rotación bajo demanda*. La clave conserva su *ID y su ARN*: aplicaciones, alias y políticas no cambian. KMS guarda todas las versiones anteriores del material para descifrar lo que se cifró con ellas y usa la más reciente para cifrar, así que los datos existentes no se recifran: no hace falta. La rotación automática solo existe en claves simétricas cuyo material genera KMS; las asimétricas y HMAC se rotan a mano, creando una clave nueva y reasignando el alias.

*Claves multi-región.* Claves en varias regiones con el mismo ID (empieza por `mrk-`) y el mismo material: lo cifrado en una región se descifra con la réplica de otra sin llamadas entre regiones. Sirven para recuperación ante desastres, aplicaciones activo-activo o firmas verificables en varias regiones. Cada réplica tiene su propia key policy y se factura como una clave más; AWS recomienda claves de una sola región salvo que las necesites.

*Deshabilitar o borrar* (las AWS managed y AWS owned no se pueden borrar):

#tarjetas(
  tarjeta("Deshabilitar", color: col.balanceo, subtitulo: "reversible")[La clave deja de poder usarse al instante (todo `Decrypt` falla) y vuelve a funcionar al habilitarla. Úsalo para comprobar si algo depende aún de ella, con una alarma sobre los intentos de uso que registra CloudTrail.],
  tarjeta("Programar el borrado", color: col.iam, subtitulo: "irreversible al acabar la espera")[`ScheduleKeyDeletion` con una espera de *7 a 30 días* (30 por defecto), durante la que puedes cancelar. Después, la clave se destruye y lo cifrado con ella es *irrecuperable*.],
)

=== Material importado, custom key stores y cuotas

/ Material importado (BYOK): creas una clave sin material e importas el tuyo, envuelto con una clave pública que te da KMS. Puedes fijarle caducidad o borrarlo al instante (la clave queda inutilizable hasta reimportarlo), pero conservar una copia es cosa tuya.
/ Custom key stores: el material vive en tu propio clúster de *CloudHSM* o, con un *external key store*, en un gestor de claves fuera de AWS al que KMS llama mediante un proxy (si cortas el acceso, AWS no puede descifrar). Solo admiten claves simétricas y añaden coste y complejidad: úsalos si una normativa lo exige.

KMS limita las peticiones por segundo por cuenta y región. Las operaciones criptográficas con claves simétricas comparten una cuota (de miles a decenas de miles por segundo, según la región), mucho menor con asimétricas, y las peticiones de los servicios en tu nombre también cuentan. Si la superas recibes `ThrottlingException`: reintenta con backoff exponencial (los SDK ya lo hacen), usa S3 Bucket Keys o caché de claves de datos, o pide un aumento en Service Quotas. Y cada llamada a KMS, también las de los servicios en tu nombre, queda en CloudTrail: quién descifró qué, cuándo y con qué contexto (capítulo de Observabilidad).

== KMS en los servicios de AWS

Los servicios integrados aplican el cifrado envolvente por ti: tú eliges la clave y la key policy decide si el servicio puede usarla en tu nombre.

#diagrama(pie: [Los servicios integrados piden a KMS claves de datos en tu nombre; la key policy, IAM y los grants deciden si pueden, y CloudTrail registra cada llamada.])[
  #set text(hyphenate: false)
  #set par(justify: false)
  #columna(espacio: 2pt,
    zona("Servicios integrados: aplican el cifrado envolvente por ti", color: col.neutro, relleno: white)[
      #fila(espacio: 3pt,
        svc("S3", "Amazon S3", sub: "SSE-KMS", color: col.almacenamiento),
        svc("EBS", "Amazon EBS", sub: "volúmenes y snapshots", color: col.computo),
        svc("RDS", "RDS y Aurora", sub: "datos, backups, réplicas", color: col.datos),
        svc("SM", "Secrets Manager", sub: "cada secreto", color: col.seguridad),
        svc("λ", "AWS Lambda", sub: "variables de entorno", color: col.serverless),
      )
    ],
    flecha-v(etiqueta: [GenerateDataKey, Decrypt], largo: 0.8cm, doble: true),
    fila(espacio: 4pt,
      caja([*Key policy, IAM y grants* \ deciden quién puede usarla], color: col.iam, ancho: 3cm),
      flecha(etiqueta: "autorizan", largo: 1.1cm),
      svc("KMS", "AWS KMS", sub: "claves en HSM", color: col.seguridad),
      flecha(etiqueta: "cada llamada", largo: 1.5cm),
      svc("CT", "AWS CloudTrail", sub: "quién, qué, cuándo", color: col.observabilidad),
    ),
  )
]

#tabla(("Servicio", "Qué se cifra", "Por defecto", "Lo que debes saber"), columnas: (0.95fr, 1.25fr, 1.3fr, 2.3fr), tamano: 8pt,
  [*S3*], [Objetos], [SSE-S3 en todos los objetos nuevos (desde 2023)], [SSE-KMS para controlar y auditar quién descifra; activa S3 Bucket Keys],
  [*EBS*], [Volúmenes, snapshots y tráfico instancia–volumen], [Sin cifrar, salvo que actives el *cifrado por defecto* (por cuenta y región)], [Con el ajuste activo, todo volumen nuevo se cifra con `aws/ebs` o con la clave que elijas],
  [*RDS / Aurora*], [Almacenamiento, backups, snapshots, réplicas y logs], [Se elige al crear la base de datos], [No se cifra en caliente una instancia existente: snapshot → copia cifrada → restaurar],
  [*Secrets Manager*], [Cada secreto], [Siempre, con `aws/secretsmanager`], [Para compartir secretos entre cuentas necesitas una customer managed],
  [*CloudTrail*], [Ficheros de log en S3], [SSE-S3, si no eliges otra cosa], [SSE-KMS con clave propia: separa quién lee los logs de quién administra el bucket],
  [*Lambda*], [Variables de entorno], [Clave AWS managed (`aws/lambda`)], [Customer managed si quieres decidir quién puede descifrarlas],
)

*S3.* Con SSE-S3 (el cifrado por defecto) S3 gestiona las claves sin coste, pero no controlas ni auditas su uso; con SSE-KMS hay doble llave (permiso de S3 *y* de KMS) y cada uso queda en CloudTrail. Existen también DSSE-KMS (doble capa) y SSE-C (tu clave en cada petición). El problema de SSE-KMS es el volumen: una petición a KMS por objeto escrito y otra por lectura. Con *S3 Bucket Keys*, S3 obtiene de KMS una clave de vida corta a nivel de bucket y deriva de ella las de muchos objetos: las llamadas a KMS caen en picado (AWS habla de hasta un 99 % menos de coste de peticiones).

#cuidado[Con SSE-KMS, `s3:GetObject` no basta: quien lee necesita `kms:Decrypt` sobre la clave, y quien sube, `kms:GenerateDataKey` (y `kms:Decrypt` en las subidas multiparte). Es la causa número uno de _Access Denied_ «misteriosos» con objetos cifrados.]

*EBS y RDS.* Con el *cifrado por defecto de EBS* activado en la región, todo volumen nuevo y toda copia de snapshot se cifran sin que nadie tenga que acordarse; un volumen existente se cifra creando otro desde su snapshot. En RDS, el cifrado se decide al crear la instancia y *no se activa en caliente* (capítulo de Bases de datos):

#pasos(
  [Crea un snapshot manual de la instancia sin cifrar y *cópialo activando el cifrado* con la clave KMS elegida.],
  [*Restaura* una instancia nueva desde la copia cifrada y apunta la aplicación a su endpoint (si la parada es inaceptable, replica antes los datos, por ejemplo con AWS DMS).],
)

== KMS frente a CloudHSM, cifrado en cliente y costes

*AWS CloudHSM* te da HSM dedicados (_single-tenant_) en tu VPC. A diferencia de KMS, gestionas tú los usuarios y las claves del HSM: AWS opera el hardware, pero no tiene acceso a tus claves.

#tabla(("", "AWS KMS", "AWS CloudHSM"), columnas: (1.05fr, 1.6fr, 1.75fr), tamano: 8.2pt,
  [Modelo], [Servicio multi-tenant totalmente gestionado; alta disponibilidad incluida], [HSM dedicados en tu VPC; la alta disponibilidad la diseñas tú (varios HSM en varias AZ)],
  [Quién controla las claves], [Tú, con políticas; AWS opera los HSM], [Solo tú; AWS no tiene acceso],
  [Integración con servicios], [#si Nativa con la mayoría], [#parcial Indirecta, como custom key store de KMS],
  [Interfaces], [API de AWS (SDK, CLI) y permisos de IAM], [Estándares: PKCS\#11, JCE, OpenSSL, CNG/KSP],
  [Precio], [Por clave y por petición: poco dinero al mes], [Por HSM y hora: del orden de mil dólares al mes por HSM],
  [Casos de uso], [Cifrar datos en los servicios de AWS y en tus aplicaciones], [Normativa de HSM dedicado, descarga de TLS, TDE en EC2, CA propia],
)

*Cifrado del lado del cliente.* Si quieres que AWS solo vea texto cifrado, cifra antes de enviar. El *AWS Encryption SDK* (para varios lenguajes y CLI) implementa el cifrado envolvente con buenas prácticas: claves de datos de KMS, la clave cifrada junto a los datos en un formato portable y caché de claves de datos. Hay clientes específicos para S3 y para bases de datos.

#coste[Importes orientativos, que varían por región:
- *Customer managed:* del orden de un dólar al mes por clave, prorrateado por horas; las primeras rotaciones lo incrementan, con un tope. Cada réplica multi-región cuenta como clave.
- *Peticiones:* del orden de céntimos por cada 10 000 simétricas (las asimétricas, más), con capa gratuita mensual; también las de claves AWS managed, que no tienen cuota mensual.
- La factura grande suele venir de las peticiones, no de las claves.]

=== KMS desde la línea de comandos

```bash
# Crear una clave simétrica customer managed, guardar su ID y ponerle alias
KEY_ID=$(aws kms create-key --description "Clave de la app de pagos" \
           --query KeyMetadata.KeyId --output text)
aws kms create-alias --alias-name alias/app-pagos --target-key-id "$KEY_ID"
aws kms enable-key-rotation --key-id "$KEY_ID" --rotation-period-in-days 180

# Cifrar un dato pequeño (máx. 4 KB) con contexto de cifrado...
aws kms encrypt --key-id alias/app-pagos --plaintext fileb://token.txt \
    --encryption-context app=pagos \
    --query CiphertextBlob --output text | base64 --decode > token.enc
# ...y descifrarlo presentando el mismo contexto
aws kms decrypt --key-id alias/app-pagos --ciphertext-blob fileb://token.enc \
    --encryption-context app=pagos --query Plaintext --output text | base64 --decode
```

== Secretos: Secrets Manager y Parameter Store

Una contraseña escrita en el código, en un fichero de configuración o en una variable de entorno en texto plano acaba, tarde o temprano, en un repositorio, un log o una captura de pantalla. *AWS Secrets Manager* y el *Parameter Store* de AWS Systems Manager la sacan del código: ambos cifran con KMS, controlan el acceso con IAM y registran cada lectura en CloudTrail.

#ficha("AWS Secrets Manager", "Almacén de secretos con rotación automática",
  ("Qué guarda", [Texto o JSON de hasta 64 KB (credenciales, claves de API, tokens), cifrado siempre con KMS]),
  ("Rotación", [Plantillas para RDS, Aurora, Redshift y DocumentDB, rotación gestionada por algunos servicios y funciones Lambda propias para el resto]),
  ("Extras", [Versiones, réplicas en otras regiones y políticas de recursos para el acceso entre cuentas]))

#tabla(("", "Secrets Manager", "Parameter Store"), columnas: (1.05fr, 1.55fr, 1.6fr), tamano: 8.2pt,
  [Pensado para], [Secretos con ciclo de vida: credenciales que rotan], [Configuración y secretos sencillos (`String`, `StringList` y `SecureString`, cifrado con KMS)],
  [Rotación automática], [#si Integrada], [#no Tendrías que montarla (EventBridge + Lambda)],
  [Tamaño máximo], [64 KB], [4 KB (Standard) · 8 KB (Advanced)],
  [Coste], [Por secreto (menos de un dólar al mes) + llamadas], [Standard: gratis · Advanced: céntimos por parámetro al mes],
  [Réplica entre regiones], [#si Réplicas de secretos], [#no],
  [Jerarquías], [#parcial Nombres con `/` y filtros por prefijo], [#si Rutas (`/prod/pagos/db-url`) y lectura por ruta (`GetParametersByPath`)],
  [Entre cuentas], [#si Política de recursos + clave customer managed], [#parcial Parámetros Advanced compartidos con AWS RAM],
  [Úsalo para], [Credenciales de bases de datos, claves de API que rotan, acceso entre cuentas o regiones], [URLs, _feature flags_, IDs de AMI, configuración por entorno, secretos que no rotan],
)

Leer un secreto desde Python es una sola llamada, y programar su rotación desde la CLI, otra:

```python
import json, boto3

sm = boto3.client("secretsmanager", region_name="eu-west-1")
resp = sm.get_secret_value(SecretId="prod/pagos/db")      # versión AWSCURRENT
cred = json.loads(resp["SecretString"])                   # usuario, contraseña, host
```

```bash
aws secretsmanager rotate-secret --secret-id prod/pagos/db \
    --rotation-lambda-arn arn:aws:lambda:eu-west-1:111122223333:function:rotar \
    --rotation-rules AutomaticallyAfterDays=30
```

*Rotación.* Según la programación (cada N días o una expresión `rate`/`cron`), Secrets Manager invoca la función de rotación, que sigue cuatro pasos: `createSecret` genera la contraseña nueva como versión `AWSPENDING`, `setSecret` la cambia en la base de datos, `testSecret` comprueba que funciona y `finishSecret` le mueve la etiqueta `AWSCURRENT` (la anterior pasa a `AWSPREVIOUS`). Quien lee `AWSCURRENT` obtiene la nueva sin redesplegar. Cachea el secreto (en Lambda, la extensión _AWS Parameters and Secrets Lambda Extension_ lo hace por ti), pero reléelo si la conexión falla por credenciales.

#examen[¿Credenciales que deben rotar solas? *Secrets Manager*. ¿Configuración o un secreto sin rotación al menor coste? *Parameter Store* con `SecureString`. Ambos se referencian desde CloudFormation (`{{resolve:secretsmanager:...}}`, `{{resolve:ssm-secure:...}}`, capítulo de IaC) y desde las tareas de ECS.]

== Certificados TLS con ACM

*AWS Certificate Manager (ACM)* emite, guarda y renueva certificados TLS para tus dominios. Los públicos son gratuitos con los servicios integrados: ACM los instala, protege la clave privada y los renueva antes de que caduquen.

#tarjetas(columnas: 3,
  tarjeta("Públicos", subtitulo: "confiables para los navegadores")[Emitidos por la CA de Amazon tras validar que controlas el dominio. Gratis con los servicios integrados; renovación automática.],
  tarjeta("Privados", color: col.datos, subtitulo: "con AWS Private CA")[Para servicios internos, mTLS o dispositivos, emitidos por tu propia CA privada (de pago). Los navegadores no confían en ellos.],
  tarjeta("Importados", color: col.neutro, subtitulo: "de otra CA")[Los subes a ACM para usarlos en servicios integrados. *ACM no los renueva*: avisa antes de que caduquen y tú los reimportas.],
)

/ Validación por DNS: añades a tu zona un CNAME que te da ACM (con Route 53, en un clic). Mientras exista, la renovación es automática y sin intervención. Es la opción recomendada.
/ Validación por email: los contactos del dominio (`admin@`, `webmaster@`…) aprueban la solicitud por correo, y las renovaciones pueden volver a requerirlo.

ACM se integra con ELB (ALB y NLB), CloudFront, API Gateway, App Runner y otros servicios. Los certificados son *regionales*: el de un ALB debe estar en la región del ALB.

#cuidado[*CloudFront solo acepta certificados de ACM de us-east-1* (Norte de Virginia), porque es un servicio global, aunque tu origen esté en otra región. Lo mismo ocurre con las API _edge-optimized_ de API Gateway. Si no ves tu certificado en la distribución, casi seguro lo creaste en otra región.]

*¿Y en mi propia EC2?* Un certificado público estándar de ACM no se puede instalar en tu servidor: ACM no deja exportar su clave privada, solo usarlo a través de los servicios integrados. Lo habitual es poner delante un ALB o CloudFront (terminan TLS con el certificado de ACM), usar _ACM for Nitro Enclaves_ o recurrir a otra CA. Desde 2025 ACM ofrece también certificados públicos *exportables*, instalables donde quieras, pero tienen coste y hay que redesplegarlos tras cada renovación.

== Protección perimetral: WAF, Shield y firewalls

Los Security Groups y las NACL (capítulo de Redes) filtran por IP, puerto y protocolo, pero no entienden lo que viaja dentro: una inyección SQL entra por el puerto 443 como cualquier otra petición. Para eso están estos servicios.

#diagrama(pie: [Dónde actúa cada servicio de protección perimetral en el camino de una petición. Firewall Manager gobierna las políticas en todas las cuentas.])[
  #set text(hyphenate: false)
  #set par(justify: false)
  #let banda(t, c) = block(width: 100%, fill: c.lighten(88%), stroke: 0.8pt + c, radius: 4pt, inset: (x: 8pt, y: 5pt),
    align(center, text(7.2pt, fill: c.darken(30%), t)))
  #let desc(t) = box(width: 2.5cm, align(center, {
    set par(justify: false, leading: 0.4em)
    text(6.5pt, fill: gris.darken(25%), t)
  }))
  #grid(columns: (2.15cm, 0.7cm, 2.6cm, 0.7cm, 2.6cm, 0.7cm, 2.6cm, 0.7cm, 2.6cm), align: center + horizon, row-gutter: 6pt,
    grid.cell(colspan: 9, banda([*AWS Firewall Manager* · define estas protecciones una vez y las aplica, y audita, en todas las cuentas de la organización], col.seguridad)),
    internet(etiqueta: "Internet"), flecha(largo: 0.7cm),
    svc("CF", "CloudFront", sub: "+ web ACL de WAF", color: col.edge), flecha(largo: 0.7cm),
    svc("NFW", "Network Firewall", sub: "en la VPC", color: col.redes), flecha(largo: 0.7cm),
    svc("ALB", "ALB", sub: "+ web ACL de WAF", color: col.balanceo), flecha(largo: 0.7cm),
    svc("EC2", "Instancias", sub: "+ Security Groups", color: col.computo),
    [], [], desc[Capa 7: inyección SQL, XSS, bots, límites de tasa, países], [],
    desc[Capas 3 a 7: IPS con firmas, filtrado por dominio], [],
    desc[Capa 7 a nivel regional, junto a la aplicación], [],
    desc[Capas 3 y 4: puertos y orígenes permitidos],
    grid.cell(colspan: 9, banda([*AWS Shield* · Standard (gratis, siempre activo): DDoS de capas 3 y 4 en todo AWS · Advanced (de pago): capa 7, equipo de respuesta y protección de costes], col.edge)),
  )
]

=== AWS WAF

#ficha("AWS WAF", "Firewall de aplicaciones web: filtra peticiones HTTP(S) antes de que lleguen a tu aplicación",
  ("Se asocia a", [CloudFront (web ACL global, creada en us-east-1), ALB, API Gateway (REST), AppSync, Cognito, App Runner y Verified Access. No a un NLB ni a una EC2]),
  ("Web ACL", [Reglas por prioridad sobre IP, país, cabeceras, URI o cuerpo (inyección SQL, XSS, regex…), con acciones Allow, Block, Count (probar sin bloquear), CAPTCHA o Challenge]),
  ("Reglas gestionadas", [Grupos de AWS (riesgos como los del OWASP Top 10, reputación de IP…) o de Marketplace. Bot Control (de pago) identifica bots; hay grupos contra el robo de cuentas]),
  ("Rate-based", [Bloquean un tiempo a quien supere N peticiones en una ventana de minutos, por IP u otra clave: fuerza bruta y DDoS de capa 7]),
  ("Coste", [Por web ACL y regla al mes + por millón de peticiones; Bot Control y similares, aparte]))

=== AWS Shield

Shield protege frente a ataques de denegación de servicio distribuida (DDoS). Todo cliente tiene *Shield Standard* sin hacer nada; *Shield Advanced* es una suscripción para aplicaciones críticas.

#tabla(("", "Shield Standard", "Shield Advanced"), columnas: (1.05fr, 1.45fr, 2fr), tamano: 8.2pt,
  [Precio], [Incluido, sin coste y automático], [Del orden de miles de dólares al mes por organización, con compromiso de un año, más transferencia de datos],
  [Qué cubre], [Ataques comunes de capas 3 y 4 (SYN floods, reflexión UDP…) en toda la infraestructura de AWS], [Detección y mitigación avanzadas, también de capa 7 (con WAF), para CloudFront, Route 53, Global Accelerator, ELB e IP elásticas],
  [Equipo de respuesta 24/7 (SRT)], no, [#si Con un plan de soporte Business o superior],
  [Protección de costes], no, [#si Créditos por el escalado que provoque un ataque],
  [AWS WAF], [Se paga aparte], [Incluido para los recursos protegidos (con excepciones)],
)

*AWS Firewall Manager* centraliza WAF, Shield Advanced, Security Groups, Network Firewall y el firewall DNS de Route 53 Resolver en todas las cuentas de una organización: defines una política («todo ALB de producción lleva esta web ACL») y la aplica, también a cuentas y recursos futuros. Requiere AWS Organizations y AWS Config.

*AWS Network Firewall* es un firewall gestionado y con estado para tus VPC: filtra de la capa 3 a la 7, con reglas compatibles con Suricata (IPS), listas de dominios permitidos para la salida e inspección de TLS. Se despliega en subredes dedicadas y el tráfico llega a sus endpoints por las tablas de rutas; con Transit Gateway, una VPC central inspecciona el de muchas otras. Se paga por hora de endpoint y por GB procesado.

== Detección y respuesta: GuardDuty, Security Hub y más

Prevenir no basta: algo acabará escapándose. Estos servicios vigilan cuentas, cargas y datos, y generan *hallazgos* (_findings_) cuando detectan algo sospechoso. Son regionales, se activan con pocos clics y se gestionan para toda la organización desde una cuenta de *administrador delegado*.

#tabla(("Servicio", "Qué hace", "Qué datos analiza", "Ejemplo de hallazgo o uso"), columnas: (1fr, 1.45fr, 1.8fr, 1.6fr), tamano: 8pt,
  [*GuardDuty*], [Detecta amenazas con inteligencia de amenazas, aprendizaje automático y anomalías], [CloudTrail, VPC Flow Logs y DNS (sin que tengas que activarlos); opcionalmente S3, EKS, RDS, Lambda, ejecución y malware], [Credenciales de una instancia usadas desde fuera de AWS; minería de criptomonedas],
  [*Security Hub*], [Agrega y prioriza hallazgos; comprueba la postura frente a estándares], [Hallazgos de los demás servicios y de terceros; controles basados en AWS Config], [Puntuación frente a AWS Foundational Security Best Practices, CIS o PCI DSS],
  [*Inspector*], [Gestiona vulnerabilidades de forma continua], [Instancias EC2, imágenes de contenedor en ECR y funciones Lambda], [CVE crítica en un paquete de la AMI; puerto expuesto a Internet],
  [*Macie*], [Descubre datos sensibles y riesgos en S3], [Objetos y configuración de los buckets], [CSV con números de tarjeta en un bucket público],
  [*Detective*], [Ayuda a investigar el origen y el alcance], [CloudTrail, Flow Logs, hallazgos de GuardDuty, logs de EKS → grafo de comportamiento], [Todas las llamadas e IP de un rol sospechoso en las últimas horas],
)

En 2025 AWS renombró las comprobaciones de postura de Security Hub como *Security Hub CSPM* y amplió Security Hub para correlacionar hallazgos y priorizar riesgos, pero el patrón no cambia: los detectores envían hallazgos a un punto central, de ahí pasan a *EventBridge* (capítulo de Mensajería) y una regla dispara la respuesta automática, como resume la figura de más abajo.

Por ejemplo, este patrón de EventBridge captura los hallazgos de GuardDuty de severidad alta o crítica para enviarlos a una función que aísle la instancia:

```json
{
  "source": ["aws.guardduty"],
  "detail-type": ["GuardDuty Finding"],
  "detail": { "severity": [{ "numeric": [">=", 7] }] }
}
```

#practica[Activa GuardDuty y Security Hub en *todas* las cuentas y regiones, también las que no usas: con credenciales robadas, un atacante suele lanzar instancias justo donde nadie mira. Con un administrador delegado en AWS Organizations, las cuentas nuevas quedan cubiertas solas.]

#diagrama(pie: [Detección y respuesta automatizada: los hallazgos convergen en Security Hub, EventBridge los enruta y Lambda, SSM o SNS responden. Detective ayuda a investigar.])[
  #set text(hyphenate: false)
  #set par(justify: false)
  #fila(espacio: 3pt,
    zona("Detección", color: col.seguridad)[
      #columna(espacio: 1pt,
        svc("GD", "GuardDuty", sub: "amenazas", color: col.seguridad),
        svc("INS", "Inspector", sub: "vulnerabilidades", color: col.seguridad),
        svc("MAC", "Macie", sub: "datos sensibles en S3", color: col.seguridad),
      )
    ],
    flecha(etiqueta: "hallazgos", largo: 1.15cm),
    columna(espacio: 2pt,
      box(height: 2.15cm),
      svc("SH", "Security Hub", sub: "agrega y prioriza (también Config y Access Analyzer)", color: col.seguridad),
      flecha-v(doble: true, largo: 0.6cm),
      svc("DET", "Detective", sub: "investigar", color: col.seguridad),
    ),
    flecha(etiqueta: "eventos", largo: 1.05cm),
    svc("EB", "EventBridge", sub: "reglas por tipo y severidad", color: col.integracion),
    flecha(largo: 0.85cm),
    zona("Respuesta", color: col.serverless)[
      #columna(espacio: 1pt,
        svc("λ", "Lambda", sub: "aislar la instancia", color: col.serverless),
        svc("SSM", "SSM Automation", sub: "runbook de respuesta", color: col.computo),
        svc("SNS", "SNS", sub: "avisar al equipo", color: col.integracion),
      )
    ],
  )
]

== Defensa en profundidad

Ningún control es perfecto, así que se apilan: si una capa falla, la siguiente frena el ataque. La figura resume en qué capa actúa cada servicio de este capítulo y de los anteriores.

#diagrama(pie: [Defensa en profundidad: cada capa frena lo que la anterior dejó pasar; la identidad es transversal y la detección vigila todas las capas.])[
  #set text(hyphenate: false)
  #set par(justify: false)
  #let alto = 0.95cm
  #let capas-dd = (
    ("Borde", "primer contacto", col.edge, ("CloudFront", "AWS WAF", "AWS Shield", "Route 53")),
    ("Red", "qué habla con qué", col.redes, ("Subredes privadas", "Security Groups", "NACL", "Network Firewall")),
    ("Cómputo", "instancias y SO", col.computo, ("Inspector", "Patch Manager", "IMDSv2", "AMI endurecidas")),
    ("Aplicación", "tu código y tus API", col.balanceo, ("Reglas L7 de WAF", "Cognito", "Secrets Manager", "TLS con ACM")),
    ("Datos", "lo que se protege", col.datos, ("KMS", "Cifrado S3/EBS/RDS", "Block Public Access", "Macie")),
    ("Identidad", "transversal a todo", col.iam, ("IAM", "Identity Center", "MFA", "SCP y RCP", "Access Analyzer")),
  )
  #let fila-dd((nombre, desc, c, ss)) = (
    block(width: 100%, height: alto, fill: gradient.linear(c, c.darken(20%)), radius: 4pt, inset: (x: 8pt, y: 5pt),
      align(left + horizon, {
        set par(justify: false, leading: 0.35em)
        text(8.4pt, weight: "bold", fill: white, nombre)
        linebreak()
        text(6.3pt, fill: white.transparentize(10%), desc)
      })),
    block(width: 100%, height: alto, fill: c.lighten(91%), stroke: 0.6pt + c.lighten(60%), radius: 4pt, inset: (x: 7pt, y: 4pt),
      align(left + horizon, {
        set par(justify: false, leading: 0.9em)
        ss.map(s => pill(s, color: c, relleno: white)).join(h(3pt))
      })),
  )
  #let deteccion = block(width: 100%, height: 6 * alto + 5 * 4pt, fill: col.seguridad.lighten(92%), stroke: (paint: col.seguridad, thickness: 0.9pt, dash: "dashed"), radius: 4pt, inset: (x: 5pt, y: 7pt),
    align(center + horizon, {
      set par(justify: false, leading: 0.4em)
      text(8.2pt, weight: "bold", fill: col.seguridad.darken(15%), "Detección y respuesta")
      v(2pt)
      text(6.3pt, fill: gris.darken(20%), "vigila todas las capas")
      v(6pt)
      for s in ("GuardDuty", "Security Hub", "Detective", "CloudTrail", "AWS Config", "EventBridge") {
        block(above: 4pt, below: 0pt, pill(s, color: col.seguridad, relleno: white))
      }
    }))
  #let filas = capas-dd.map(fila-dd)
  #grid(columns: (2.7cm, 1fr, 2.75cm), column-gutter: 4pt, row-gutter: 4pt,
    ..filas.at(0), grid.cell(rowspan: 6, deteccion),
    ..filas.slice(1).flatten(),
  )
]

== Respuesta a incidentes

Ante una alarma seria —una instancia hablando con un servidor de mando y control, unas claves usadas desde un país inesperado—, improvisar es lo peor. Prepárate antes: GuardDuty y Security Hub activos, un _trail_ organizativo de CloudTrail en una cuenta de logs protegida, roles de respuesta listos y _runbooks_ ensayados. Después, el esqueleto básico es este:

#block(breakable: false, width: 100%, above: 1em, below: 1.1em, pasos(
  [*Aislar.* Cambia el Security Group de la instancia por uno sin reglas y sácala del Auto Scaling group y del balanceador. Desactiva las claves de acceso comprometidas y revoca las sesiones activas del rol.],
  [*Preservar evidencias:* snapshots de los volúmenes EBS, captura de memoria si procede, etiquetas con el número de incidente y copia de los logs en un bucket con S3 Object Lock de otra cuenta.],
  [*Rotar credenciales:* claves de acceso, secretos, contraseñas y tokens a los que pudo llegar el atacante.],
  [*Investigar con CloudTrail* (y Detective): qué llamadas hizo la identidad comprometida, desde qué IP y qué creó o modificó (usuarios, roles, instancias en otras regiones…).],
  [*Recuperar y aprender:* reconstruye desde una AMI o una plantilla de IaC limpias, corrige la causa raíz, escribe un post-mortem sin culpables y automatiza la respuesta.],
))

#cuidado[Terminar la instancia comprometida parece lo más rápido, pero destruye las evidencias (memoria, procesos, discos efímeros) que necesitas para entender qué pasó. Aísla primero; termina después.]

#resumen[
- Cifra en reposo (KMS) y en tránsito (TLS con ACM). Con KMS, la clave se convierte en un segundo punto de control de acceso.
- KMS guarda las claves en HSM y nunca las deja salir. Hay claves *AWS owned*, *AWS managed* (`aws/servicio`, rotación anual, key policy de solo lectura) y *customer managed* (control total).
- Toda clave tiene exactamente una *key policy*; sin la sentencia que delega en la cuenta, IAM no basta. Entre cuentas hace falta permiso en la key policy *y* en IAM de la cuenta consumidora.
- *Cifrado envolvente:* `GenerateDataKey` → cifrar en local → descartar la clave en claro → guardar la clave cifrada con los datos → `Decrypt` para leer.
- La rotación mantiene el ID y el ARN y conserva el material antiguo. Borrar una clave exige una espera de 7 a 30 días y es irreversible.
- S3 Bucket Keys reduce las peticiones a KMS. RDS no se cifra en caliente: snapshot → copia cifrada → restaurar.
- *Secrets Manager* para secretos que rotan; *Parameter Store* para configuración. ACM renueva certificados gratis; para CloudFront, en us-east-1.
- WAF filtra en la capa 7, Shield frena DDoS, Firewall Manager gobierna las políticas y Network Firewall inspecciona las VPC.
- GuardDuty, Inspector y Macie detectan; Security Hub agrega; EventBridge automatiza la respuesta. Ante un incidente, aísla y preserva antes de borrar nada.
]

#repaso(
  ([Un rol con `s3:GetObject` recibe _Access Denied_ al descargar objetos cifrados con SSE-KMS y una clave customer managed. ¿Qué falta?],
   [`kms:Decrypt` sobre la clave: en la key policy, o en la política IAM del rol si la key policy delega en la cuenta.]),
  ([¿Por qué S3 no envía tus objetos a KMS para cifrarlos?],
   [Porque usa cifrado envolvente: `Encrypt` admite como máximo 4 KB y enviar los datos sería lento y caro. KMS solo genera y descifra la clave de datos; los datos se cifran en local.]),
  ([Debes compartir con la cuenta de auditoría un snapshot de RDS cifrado con `aws/rds`. ¿Cómo?],
   [Las AWS managed no se comparten: copia el snapshot cifrándolo con una customer managed, permite a la otra cuenta en su key policy y comparte el snapshot (en destino, IAM debe conceder el uso de la clave).]),
  ([Hay que cifrar una base de datos RDS de producción creada sin cifrado. ¿Qué haces?],
   [Snapshot → copia cifrada con la clave elegida → restaurar una instancia nueva → cambiar el endpoint de la aplicación (o replicar antes con DMS para reducir la parada).]),
  ([Activas la rotación automática de una clave. ¿Qué pasa con los datos ya cifrados?],
   [Nada: ID, ARN y alias no cambian, y KMS conserva el material antiguo para descifrarlos. Lo nuevo se cifra con el material actual.]),
  ([Tu certificado de ACM no aparece al configurar HTTPS en CloudFront. ¿Por qué?],
   [CloudFront solo usa certificados de ACM de us-east-1: hay que solicitarlo o importarlo en esa región.]),
  ([GuardDuty detecta una instancia que consulta dominios de minería de criptomonedas. ¿Qué automatizas y qué evitas?],
   [Una regla de EventBridge que invoque una Lambda para aislar la instancia, hacer snapshots y avisar al equipo; luego rotar credenciales e investigar con CloudTrail y Detective. No la termines antes de preservar las evidencias.]),
)
