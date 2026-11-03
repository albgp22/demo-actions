#import "../theme.typ": *

// =====================================================================
//  Capítulo 2 (II) — IAM: permisos, políticas y evaluación
// =====================================================================

// ---- Elementos propios del capítulo -----------------------------------

#let _rojo = rgb("#E03131")
#let _verde = rgb("#2F9E44")

// Ficha de concepto: qué es / qué no es / para qué / ejemplo / error típico
#let _concepto(nombre, lema, es, noes, sirve, ejemplo, error) = {
  let c = col.iam
  let fc(etq, color, cuerpo) = (
    box(width: 2.3cm, pill(etq, color: color)),
    { set par(justify: false); text(8.9pt, cuerpo) },
  )
  block(width: 100%, breakable: false, radius: 8pt, clip: true,
    stroke: 0.8pt + c.lighten(55%), above: 1.2em, below: 1.2em, {
      block(width: 100%, spacing: 0pt, fill: gradient.linear(c, c.darken(30%), angle: 0deg),
        inset: (x: 13pt, y: 8pt), {
          set par(justify: false)
          text(6.6pt, weight: "bold", fill: white.transparentize(25%), tracking: 1.2pt, "CONCEPTO")
          linebreak()
          text(13pt, weight: "bold", fill: white, nombre)
          h(7pt)
          text(8.8pt, fill: white.transparentize(8%), lema)
        })
      block(width: 100%, spacing: 0pt, fill: c.lighten(96%), inset: (x: 13pt, y: 9pt),
        grid(columns: (auto, 1fr), column-gutter: 8pt, row-gutter: 6.5pt,
          ..fc("QUÉ ES", col.datos, es),
          ..fc("QUÉ NO ES", _rojo, noes),
          ..fc("PARA QUÉ", _verde, sirve),
          ..fc("EJEMPLO", col.neutro, ejemplo),
          ..fc("ERROR TÍPICO", acento, error),
        ))
    })
}

// Diagrama de flujo de la evaluación
#let _decision(t) = box(width: 6.9cm, fill: white, stroke: 1pt + col.iam.lighten(20%), radius: 5pt,
  inset: (x: 8pt, y: 6pt), align(center, text(7.8pt, fill: tinta, t)))
#let _final(t, c) = box(width: 3.2cm, fill: c, radius: 5pt, inset: (x: 6pt, y: 5pt),
  align(center, { set par(leading: 0.4em); text(7.5pt, weight: "bold", fill: white, t) }))
#let _bajar(t) = flecha-v(etiqueta: t, largo: 0.55cm)
#let _no-deny = _final([DENEGADO \ deny implícito], _rojo.lighten(10%))

// Diagrama de intersección (permisos efectivos)
#let _venn = box(width: 8.3cm, height: 6.6cm, {
  let r = 2.1cm
  let circ(dx, dy, c) = place(top + left, dx: dx, dy: dy,
    circle(radius: r, fill: c.transparentize(80%), stroke: 1.2pt + c))
  circ(0.9cm, 0.5cm, col.iam)
  circ(3.3cm, 0.5cm, col.datos)
  circ(2.1cm, 2.2cm, acento)
  let et(dx, dy, c, t) = place(top + left, dx: dx, dy: dy, text(7.4pt, weight: "bold", fill: c.darken(15%), t))
  et(0.0cm, 0.0cm, col.iam, "Política de identidad")
  et(5.3cm, 0.0cm, col.datos, "Permissions boundary")
  et(0.0cm, 5.9cm, acento, "SCP de la cuenta")
  place(top + left, dx: 3.35cm, dy: 2.85cm, box(width: 1.7cm, align(center, {
    set par(leading: 0.35em)
    text(7.4pt, weight: "extrabold", fill: tinta)[Permisos \ efectivos]
  })))
})

// Ejercicio resuelto
#let _ejercicio(n, peticion, codigo, permitido, porque) = block(width: 100%, breakable: false,
  above: 1em, below: 1em, stroke: 0.8pt + col.iam.lighten(60%), radius: 7pt, clip: true, {
    block(width: 100%, spacing: 0pt, fill: col.iam.lighten(91%), inset: (x: 10pt, y: 5pt),
      grid(columns: (auto, 1fr), column-gutter: 8pt, align: horizon,
        box(fill: col.iam, radius: 3pt, inset: (x: 5pt, y: 3pt),
          text(7.3pt, weight: "bold", fill: white, tracking: 0.5pt, "EJERCICIO " + str(n))),
        text(9pt, weight: "semibold", fill: col.iam.darken(30%), peticion)))
    block(width: 100%, spacing: 0pt, inset: (x: 10pt, y: 6pt),
      grid(columns: (1.1fr, 1fr), column-gutter: 12pt, codigo, {
        set text(8.9pt)
        set par(justify: false)
        v(4pt)
        if permitido { pill("PERMITIDO", color: _verde) } else { pill("DENEGADO", color: _rojo) }
        v(2pt)
        porque
      }))
  })

#let _mini(cuerpo) = align(center, text(hyphenate: false, cuerpo))

// =====================================================================

#show figure.where(kind: "diagrama"): set text(hyphenate: false)

#capitulo("IAM (II): permisos — políticas y evaluación", color: col.iam,
  subtitulo: [Qué puede hacer cada identidad, sobre qué recursos y en qué condiciones: cómo se escriben las políticas y cómo decide AWS cada petición.],
  objetivos: (
    [Leer y escribir políticas JSON elemento a elemento],
    [Los tipos de políticas y cómo se combinan sus límites],
    [La lógica de evaluación, en la misma cuenta y entre cuentas],
    [Condiciones, variables y control de acceso por etiquetas (ABAC)],
    [Permission boundaries, SCP y RCP para poner límites],
    [Depurar un AccessDenied y aplicar el mínimo privilegio],
  ),
  servicios: ("AWS IAM", "AWS Organizations", "IAM Access Analyzer", "Policy Simulator", "AWS CloudTrail", "AWS Control Tower"))

== Del quién al qué: tres reglas de oro

En el capítulo anterior viste *quién* hace cada petición y *cómo* obtiene sus credenciales (los pasos 1 y 2 del mapa de IAM). Este capítulo trata el paso 3: *qué puede hacer*. En nuestro edificio, ya sabemos quién lleva cada tarjeta o acreditación; ahora toca decidir qué puertas abre cada una, qué dicen los carteles de cada sala y qué normas del grupo están por encima de todo. Todo se apoya en tres reglas que conviene grabarse a fuego:

#diagrama(pie: [Las tres reglas de la autorización en AWS. La tercera no tiene excepciones: ningún Allow puede anular un Deny explícito.])[
  #fila(espacio: 5pt,
    caja([*1 · Deny implícito* \ por defecto, todo está denegado], ancho: 4cm, color: col.neutro, relleno: col.neutro.lighten(90%)),
    flecha(etiqueta: "salvo que", largo: 1.35cm),
    caja([*2 · Allow explícito* \ alguna política lo permite…], ancho: 4cm, color: _verde, relleno: _verde.lighten(90%)),
    flecha(etiqueta: "salvo que", largo: 1.35cm),
    caja([*3 · Deny explícito* \ …otra lo prohíbe: gana siempre], ancho: 4cm, color: _rojo, relleno: _rojo.lighten(90%)),
  )
]

Los permisos se expresan con *políticas*: documentos JSON que se adjuntan a identidades o a recursos.

#_concepto("Política", "un documento JSON que permite o deniega",
  [Un documento con una o varias sentencias (_statements_) que permiten o deniegan acciones sobre recursos, opcionalmente bajo condiciones.],
  [No es una identidad ni un principal, y no hace nada hasta que la adjuntas a una identidad o a un recurso. Tampoco es un rol: un rol *tiene* políticas.],
  [Conceder permisos (Allow) o limitarlos (Deny, permission boundaries, SCP…).],
  [La política gestionada `ReadOnlyAccess`, o una tuya que permite leer solo el bucket `facturas`.],
  [Poner `"Action": "*"` y `"Resource": "*"` «para probar» y no volver a quitarlo nunca.])

== Anatomía de una política, paso a paso

Esta política permite leer el bucket `facturas`, pero solo desde la red de la oficina. Recorre sus elementos en orden:

#grid(columns: (0.95fr, 1fr), column-gutter: 14pt,
  [
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LeerFacturas",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::facturas",
        "arn:aws:s3:::facturas/*"
      ],
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "203.0.113.0/24"
        }
      }
    }
  ]
}
```
  ],
  [
    #set text(9pt)
    #pasos(
      [*Version*: la versión del lenguaje, no de tu política. Usa siempre `"2012-10-17"`; la antigua `2008-10-17` no admite variables.],
      [*Statement*: la lista de sentencias. Cada una se evalúa por separado.],
      [*Sid*: un nombre opcional para la sentencia; útil para leer y depurar.],
      [*Effect*: `Allow` o `Deny`.],
      [*Action*: qué operaciones de la API (`servicio:Acción`).],
      [*Resource*: sobre qué recursos, por su ARN.],
      [*Condition* (opcional): cuándo aplica la sentencia.],
    )
    En las políticas de recurso aparece además *Principal*: a quién se aplica.
  ],
)

=== Action: qué operaciones

Cada acción tiene la forma `servicio:Operación` (`s3:GetObject`, `ec2:StartInstances`, `dynamodb:Query`) y no distingue mayúsculas. Admite comodines: `s3:Get*` (todas las que empiezan por `Get`), `s3:*` (todo S3) o `*` (todo AWS). Las acciones son operaciones de la *API*, no pantallas de la consola: ver una página de la consola suele requerir varias acciones `List*` y `Describe*`. La lista completa de acciones, tipos de recurso y claves de condición de cada servicio está en la *Service Authorization Reference* de la documentación de AWS: tenla siempre a mano.

=== Resource: sobre qué recursos

Los recursos se indican con su ARN, y también admiten comodines (`*` y `?`). Cada acción se autoriza contra un *tipo de recurso* concreto, y aquí está el error más típico de S3: `s3:ListBucket` actúa sobre el *bucket* (`arn:aws:s3:::facturas`), mientras que `s3:GetObject` actúa sobre los *objetos* (`arn:aws:s3:::facturas/*`). Por eso el ejemplo lista los dos ARN. Algunas acciones no admiten permisos a nivel de recurso (por ejemplo, `ec2:DescribeInstances` o `s3:ListAllMyBuckets`) y exigen `"Resource": "*"`.

=== Condition: cuándo aplica

El bloque `Condition` añade requisitos sobre el contexto de la petición, con la estructura `{"Operador": {"clave": "valor"}}`. Dos reglas de lógica: *operadores o claves distintos se combinan con Y* (deben cumplirse todos) y *varios valores de una misma clave se combinan con O* (basta con uno). Si una condición no se cumple, la sentencia simplemente *no aplica*.

#tabla(("Operadores", "Para comparar…", "Ejemplo"), columnas: (1.5fr, 1.2fr, 2.3fr), tamano: 8.2pt,
  [`StringEquals`, `StringLike`, `StringNotEquals`], [Texto (con `*` y `?` en `Like`)], [`"aws:PrincipalTag/Equipo": "pagos"`],
  [`ArnEquals`, `ArnLike`], [ARN], [`"aws:SourceArn": "arn:aws:sns:eu-west-1:111122223333:*"`],
  [`IpAddress`, `NotIpAddress`], [Rangos IP (CIDR)], [`"aws:SourceIp": "203.0.113.0/24"`],
  [`Bool`, `Null`], [Verdadero/falso; si existe la clave], [`"aws:SecureTransport": "false"`],
  [`NumericLessThan`, `DateGreaterThan`…], [Números y fechas], [`"aws:MultiFactorAuthAge": "3600"`])

Dos modificadores completan el lenguaje: el sufijo `…IfExists` («compruébalo solo si la clave existe») y los prefijos `ForAnyValue:` / `ForAllValues:` para claves con varios valores, como `aws:TagKeys`.

=== Principal: a quién (solo en políticas de recurso)

Las políticas de identidad no llevan `Principal`: se aplican a la identidad a la que se adjuntan. Las de recurso sí, y admiten una cuenta (`{"AWS": "arn:aws:iam::111122223333:root"}`), un rol o un usuario concretos, un servicio (`{"Service": "lambda.amazonaws.com"}`), un proveedor federado o `"*"` (cualquiera, incluido el público anónimo: úsalo solo con condiciones que lo acoten). Nunca un grupo.

=== NotAction y NotResource, con cuidado

`NotAction` significa «todas las acciones *excepto* estas», y `NotResource`, «todos los recursos excepto estos». Combinados con `Deny` son muy útiles —«deniega todo salvo lo necesario para configurar la MFA», «deniega todo fuera de estas regiones salvo los servicios globales»—; verás ambos ejemplos en este capítulo.

#cuidado[`"Effect": "Allow"` con `NotAction` concede *todo lo demás*, incluidos los servicios que AWS lance mañana. Un `Allow` + `NotAction: "iam:*"` no es «todo menos IAM con prudencia»: es administrador de casi todo. Úsalo solo si lo entiendes y, preferiblemente, nunca con `Allow`.]

== Los tipos de políticas

No todas las políticas hacen lo mismo. Unas *conceden* permisos y otras solo *limitan* lo que las primeras pueden conceder:

#tabla(("Tipo", "Se adjunta a", "¿Concede?", "Para qué", "En nuestro edificio"), columnas: (1.35fr, 1.4fr, 0.75fr, 1.6fr, 1.7fr), tamano: 8pt,
  [*De identidad* (gestionada o inline)], [Usuarios, grupos y roles], [#si Sí], [Los permisos del día a día], [Lo que abre tu tarjeta o tu acreditación],
  [*De recurso*], [Recursos: bucket S3, cola SQS, clave KMS, función Lambda, trust policy de un rol…], [#si Sí], [Acceso entre cuentas y desde servicios], [El cartel de la puerta: «solo Contabilidad»],
  [*Permissions boundary*], [Usuarios y roles], [#no No, limita], [Delegar la creación de roles con un techo], [El máximo que un jefe de equipo puede dar a su gente],
  [*SCP* (Organizations)], [Raíz, OU o cuenta], [#no No, limita], [Guardarraíles para los principals de una cuenta], [Las normas del grupo que nadie puede saltarse],
  [*RCP* (Organizations)], [Raíz, OU o cuenta], [#no No, limita], [Perímetro para los recursos de una cuenta], [«En estas salas no entra nadie de fuera del grupo»],
  [*Session policy*], [Una sesión (al asumir un rol o federarse)], [#no No, limita], [Reducir los permisos de una sesión concreta], [Un pase de un día con menos permisos que tu acreditación],
  [*ACL*], [Algunos recursos (S3, heredado)], [#si Sí], [Compatibilidad; desactivadas por defecto en S3], [Un sistema antiguo de llaves; evítalo])

Las políticas de identidad, a su vez, pueden ser de tres clases:

#tarjetas(columnas: 3,
  tarjeta("Gestionada por AWS", subtitulo: "AdministratorAccess, ReadOnlyAccess…")[Las crea y mantiene AWS; cómodas para empezar y para funciones típicas (`PowerUserAccess`, `SecurityAudit`, `ViewOnlyAccess`). Son amplias, y AWS las amplía cuando lanza servicios nuevos.],
  tarjeta("Gestionada por el cliente", subtitulo: "reutilizable y versionada")[La creas tú, la adjuntas a varias identidades y guarda hasta cinco versiones para volver atrás. Es la opción recomendada para el mínimo privilegio.],
  tarjeta("Inline", subtitulo: "pegada a una sola identidad")[Vive dentro de un usuario, grupo o rol y se borra con él. Útil para una relación estricta uno a uno; difícil de auditar si abusas de ella.],
)

Cuando aplican varias, los permisos efectivos son la *intersección* de lo que concede la política de identidad y los límites que no conceden nada (boundary, SCP y, si existe, la session policy), siempre que ninguna lo deniegue explícitamente:

#diagrama(pie: [Solo se permite lo que cae dentro de todas las políticas aplicables. Un Deny explícito en cualquiera de ellas lo bloquea.])[
  #grid(columns: (8.3cm, 1fr), column-gutter: 14pt, align: horizon,
    _venn,
    align(left, {
      set text(8.4pt)
      set par(justify: false)
      [*Ejemplo:* la política de identidad permite S3 y SQS; el boundary permite S3 y DynamoDB; la SCP permite todo salvo regiones fuera de la UE. Resultado: *solo S3, solo en la UE*.]
      v(6pt)
      [Las *políticas de recurso* son el otro camino: en la misma cuenta pueden conceder acceso por sí solas, como verás en la lógica de evaluación.]
    }))
]

== Cómo decide AWS: la lógica de evaluación

Para cada petición, AWS reúne el *contexto* (principal, acción, recurso, datos del entorno y etiquetas) y todas las políticas que aplican, y sigue siempre el mismo razonamiento:

#diagrama(pie: [Lógica de evaluación de una petición dentro de una cuenta (simplificada). (\*) Entre cuentas, además, debe permitirlo la política de identidad del principal.])[
  #grid(columns: (6.9cm, 1.9cm, 3.2cm), align: center + horizon,
    _decision([¿Hay un *Deny explícito* en *cualquiera* de las políticas aplicables?]), flecha(etiqueta: "Sí", largo: 1.7cm, color: _rojo), _final([DENEGADO \ deny explícito], _rojo),
    _bajar("No"), [], [],
    _decision([¿Las *RCP* y *SCP* de Organizations permiten la acción?]), flecha(etiqueta: "No", largo: 1.7cm, color: _rojo), _no-deny,
    _bajar("Sí, o no hay"), [], [],
    _decision([¿Una *política de recurso* concede el acceso a este principal?]), flecha(etiqueta: "Sí", largo: 1.7cm, color: _verde), _final([PERMITIDO (\*)], _verde),
    _bajar("No"), [], [],
    _decision([¿Una *política de identidad* permite la acción?]), flecha(etiqueta: "No", largo: 1.7cm, color: _rojo), _no-deny,
    _bajar("Sí"), [], [],
    _decision([¿El *permissions boundary* (si existe) la permite?]), flecha(etiqueta: "No", largo: 1.7cm, color: _rojo), _no-deny,
    _bajar("Sí"), [], [],
    _decision([¿La *session policy* (si existe) la permite?]), flecha(etiqueta: "No", largo: 1.7cm, color: _rojo), _no-deny,
    _bajar("Sí"), [], [],
    _final([PERMITIDO], _verde), [], [],
  )
]

Dos matices importantes. Primero, en la misma cuenta, un Allow en una política de recurso puede bastar aunque la identidad no tenga ninguna política que lo permita (la interacción con boundaries y session policies tiene detalles adicionales que recoge la documentación). Segundo, hay dos excepciones en las que la política de recurso es *obligatoria*: la *trust policy* de un rol (nadie puede asumirlo si no lo permite) y la *key policy* de una clave KMS (las políticas de IAM solo funcionan si la key policy lo delega en la cuenta).

#examen[Las SCP, las RCP y los permission boundaries *nunca conceden* permisos: solo recortan. Si una pregunta dice «se ha adjuntado una SCP que permite S3» y el usuario no tiene ninguna política de identidad, la respuesta es que *no puede* usar S3.]

=== Misma cuenta frente a entre cuentas

Cuando el principal y el recurso están en *cuentas distintas*, la regla cambia: hacen falta *dos* Allow, uno en cada lado. La cuenta del principal debe permitir la acción en su política de identidad (y sus SCP no deben impedirlo), y la cuenta del recurso debe permitirla en la política del recurso (y sus RCP no deben impedirlo).

#diagrama(pie: [Acceso entre cuentas con una política de recurso: cada cuenta controla su lado y hacen falta los dos permisos.])[
  #fila(espacio: 6pt,
    zona("Cuenta A (quien pide)", color: col.iam)[
      #columna(espacio: 4pt,
        svc("ROL", "Rol analitica", sub: "111111111111", color: col.iam),
        caja([*Su política de identidad:* \ Allow s3:GetObject en datos-b/\*], ancho: 4.4cm, color: _verde),
        caja([Las SCP de A no lo impiden], ancho: 4.4cm, color: col.neutro))
    ],
    flecha(etiqueta: "s3:GetObject", largo: 2.1cm),
    zona("Cuenta B (el recurso)", color: col.fundamentos)[
      #columna(espacio: 4pt,
        svc("S3", "Bucket datos-b", sub: "222222222222", color: col.almacenamiento),
        caja([*Su política de bucket:* \ Allow al rol de la cuenta A], ancho: 4.4cm, color: _verde),
        caja([Las RCP de B no lo impiden], ancho: 4.4cm, color: col.neutro))
    ],
  )
]

#tabla(("Política de identidad del principal", "Política del recurso", "Misma cuenta", "Entre cuentas"), columnas: (1.6fr, 1.6fr, 1fr, 1fr),
  [Allow], [No dice nada], [#si Permitido], [#no Denegado],
  [No dice nada], [Allow a ese principal], [#si Permitido], [#no Denegado],
  [Allow], [Allow a ese principal], [#si Permitido], [#si Permitido],
  [Allow], [Deny], [#no Denegado], [#no Denegado])

Esta es la política del bucket en la cuenta B. Fíjate en que nombra al rol concreto de A; nombrar `arn:aws:iam::111111111111:root` delegaría en toda la cuenta A, que decidiría con sus propias políticas quién entra:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "LecturaDesdeAnalitica",
    "Effect": "Allow",
    "Principal": {"AWS": "arn:aws:iam::111111111111:role/analitica"},
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::datos-b/*"
  }]
}
```

#nota[Si en lugar de esto la cuenta A *asume un rol* de la cuenta B, el acceso deja de ser «entre cuentas» a efectos de evaluación: la sesión del rol pertenece a B y se evalúa como cualquier petición de B. Es la opción 2 del escenario 6 del capítulo anterior.]

== Condiciones útiles y variables de política

Las condiciones son lo que convierte una política correcta en una política *precisa*. Estas claves globales son las que más verás:

#tabla(("Clave de condición", "Qué compara", "Uso típico"), columnas: (2fr, 1.7fr, 2fr), tamano: 8pt,
  [`aws:SourceIp`], [IP pública de origen], [Solo desde la oficina (no aplica si la petición llega por un VPC endpoint)],
  [`aws:SourceVpce`, `aws:SourceVpc`], [Endpoint o VPC de origen], [Bucket accesible solo desde tu red privada],
  [`aws:PrincipalOrgID`], [Organización del principal], [Política de recurso: «cualquiera de mi organización»],
  [`aws:RequestedRegion`], [Región de destino], [SCP que limita las regiones permitidas],
  [`aws:MultiFactorAuthPresent`], [Si la sesión usó MFA], [Exigir MFA para acciones sensibles],
  [`aws:SecureTransport`], [Si la petición usa TLS], [Denegar el acceso sin HTTPS a un bucket],
  [`aws:PrincipalTag/…`, `aws:ResourceTag/…`, `aws:RequestTag/…`, `aws:TagKeys`], [Etiquetas del principal, del recurso o de la petición], [Control de acceso por atributos (ABAC)],
  [`aws:SourceArn`, `aws:SourceAccount`], [En nombre de qué recurso o cuenta actúa un servicio], [Evitar el _confused deputy_ entre servicios],
  [`aws:CalledVia`, `aws:ViaAWSService`], [Si la petición la hace un servicio en tu nombre], [Permitir ciertas acciones solo a través de un servicio])

Un ejemplo clásico: denegar *todo* salvo lo necesario para configurar la MFA cuando la sesión no se ha autenticado con ella. Se usa `BoolIfExists` porque, con access keys de largo plazo, la clave `aws:MultiFactorAuthPresent` ni siquiera existe; con un simple `Bool`, la condición no se cumpliría y esas peticiones se escaparían del Deny:

```json
{
  "Sid": "DenegarSinMFA",
  "Effect": "Deny",
  "NotAction": [
    "iam:CreateVirtualMFADevice", "iam:EnableMFADevice", "iam:ListMFADevices",
    "iam:GetUser", "sts:GetSessionToken"
  ],
  "Resource": "*",
  "Condition": {"BoolIfExists": {"aws:MultiFactorAuthPresent": "false"}}
}
```

Las *variables de política* se sustituyen en cada petición por un valor del contexto. Con `${aws:username}` una sola política sirve para que cada usuario IAM gestione *sus propias* credenciales; con `${aws:PrincipalTag/Equipo}`, para comparar etiquetas. Solo funcionan con `"Version": "2012-10-17"`.

```json
{
  "Sid": "GestionarMisPropiasClaves",
  "Effect": "Allow",
  "Action": ["iam:ChangePassword", "iam:CreateAccessKey", "iam:ListAccessKeys"],
  "Resource": "arn:aws:iam::*:user/${aws:username}"
}
```

== ABAC: permisos basados en etiquetas

El modelo clásico (RBAC, por roles) obliga a escribir una política por equipo y por recurso: «el equipo de pagos puede parar las instancias A, B y C». Con *ABAC* (_attribute-based access control_) escribes *una sola* política que compara etiquetas: «puedes parar una instancia si su etiqueta `Equipo` coincide con la tuya». Cuando se crea una instancia nueva bien etiquetada, nadie tiene que tocar ninguna política.

#diagrama(pie: [La misma política para Lucía y para Marco: lo que cambia son sus etiquetas.])[
  #columna(espacio: 6pt,
    fila(espacio: 6pt,
      columna(espacio: 2pt, actor(etiqueta: "Lucía", color: col.iam), pill("Equipo = pagos", color: col.iam)),
      flecha(etiqueta: "ec2:StopInstances", largo: 2.6cm, color: _verde),
      columna(espacio: 2pt, svc("EC2", "i-pagos-01", color: col.computo), pill("Equipo = pagos", color: col.iam)),
      box(width: 3cm, text(8pt, weight: "bold", fill: _verde)[#si las etiquetas coinciden])),
    fila(espacio: 6pt,
      columna(espacio: 2pt, actor(etiqueta: "Marco", color: col.datos), pill("Equipo = web", color: col.datos)),
      flecha(etiqueta: "ec2:StopInstances", largo: 2.6cm, color: _rojo),
      columna(espacio: 2pt, svc("EC2", "i-pagos-01", color: col.computo), pill("Equipo = pagos", color: col.iam)),
      box(width: 3cm, text(8pt, weight: "bold", fill: _rojo)[#no no coinciden])),
  )
]

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["ec2:StartInstances", "ec2:StopInstances"],
    "Resource": "arn:aws:ec2:*:*:instance/*",
    "Condition": {
      "StringEquals": {"aws:ResourceTag/Equipo": "${aws:PrincipalTag/Equipo}"}
    }
  }]
}
```

#cuidado[En ABAC, las etiquetas *son* permisos. Si cualquiera puede cambiar la etiqueta `Equipo` de una instancia (o la suya propia), puede darse acceso a sí mismo. Restringe quién puede etiquetar con condiciones sobre `aws:RequestTag` y `aws:TagKeys` sobre `ec2:CreateTags`, y protege las etiquetas de las identidades (en Identity Center pueden venir del IdP corporativo como atributos de sesión).]

== Permissions boundaries: delegar sin escalada de privilegios

Imagina que quieres que los desarrolladores creen los roles de sus propias Lambdas sin pasar por el equipo de seguridad. El peligro es evidente: quien puede crear roles y adjuntarles políticas podría crear un rol de administrador, dárselo a una Lambda (gracias a `iam:PassRole`) y escalar privilegios.

#_concepto("Permissions boundary", "el techo de permisos de un usuario o rol",
  [Una política gestionada que fijas como *límite máximo* de un usuario o rol: sus permisos efectivos son la intersección entre sus políticas de identidad y el boundary.],
  [No concede nada por sí misma: un rol con boundary y sin políticas no puede hacer nada. No se aplica a grupos.],
  [Delegar la gestión de IAM (crear roles para aplicaciones) sin riesgo de que alguien se conceda más de lo permitido.],
  [El boundary `LimiteApps` permite S3, DynamoDB y CloudWatch Logs; todo rol que creen los desarrolladores debe llevarlo.],
  [Fijar el boundary pero permitir a los desarrolladores quitarlo o editarlo: se lo saltarían en un minuto.])

#diagrama(pie: [Aunque la desarrolladora adjunte al rol una política muy amplia, el boundary obligatorio recorta el resultado.])[
  #fila(espacio: 5pt,
    actor(etiqueta: "Desarrolladora", color: col.iam),
    flecha(etiqueta: "crea el rol", largo: 1.7cm),
    zona("Rol apps/mi-funcion", color: col.iam)[
      #fila(espacio: 5pt,
        caja([*Su política* \ s3:\*, dynamodb:\*, iam:\*], ancho: 3cm, color: col.iam),
        text(14pt, weight: "bold", fill: gris)[∩],
        caja([*Boundary LimiteApps* \ s3:\*, dynamodb:\*, logs:\*], ancho: 3cm, color: col.datos))
    ],
    flecha(etiqueta: "efectivo", largo: 1.4cm),
    caja([s3:\*, dynamodb:\* \ (nada de IAM)], ancho: 2.5cm, color: _verde),
  )
]

La política de los desarrolladores solo les deja crear roles *si llevan el boundary*, pasar a Lambda solo roles de su ruta y nunca quitar ni modificar el límite:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CrearRolesSoloConLimite",
      "Effect": "Allow",
      "Action": ["iam:CreateRole", "iam:AttachRolePolicy", "iam:PutRolePolicy"],
      "Resource": "arn:aws:iam::111122223333:role/apps/*",
      "Condition": {"StringEquals": {
        "iam:PermissionsBoundary": "arn:aws:iam::111122223333:policy/LimiteApps"}}
    },
    {
      "Sid": "PasarSoloRolesDeApps",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::111122223333:role/apps/*",
      "Condition": {"StringEquals": {"iam:PassedToService": "lambda.amazonaws.com"}}
    },
    {
      "Sid": "NoQuitarNiEditarElLimite",
      "Effect": "Deny",
      "Action": ["iam:DeleteRolePermissionsBoundary", "iam:CreatePolicyVersion",
                 "iam:DeletePolicy", "iam:SetDefaultPolicyVersion"],
      "Resource": ["arn:aws:iam::111122223333:role/*",
                   "arn:aws:iam::111122223333:policy/LimiteApps"]
    }
  ]
}
```

== AWS Organizations: SCP y RCP

*AWS Organizations* agrupa tus cuentas en una jerarquía: una *raíz* (_root_), *unidades organizativas* (OU) que pueden anidarse y *cuentas miembro*, todas gobernadas desde la *cuenta de gestión*, que paga la factura consolidada (con descuentos por volumen compartidos) y aplica las políticas de la organización. Las dos más importantes para IAM son las SCP y las RCP.

#diagrama(pie: [Una organización típica. Las SCP se adjuntan a la raíz, a las OU o a las cuentas y se heredan hacia abajo; no afectan a la cuenta de gestión.])[
  #columna(espacio: 0pt,
    caja([*Raíz de la organización*], ancho: 5cm, color: col.fundamentos),
    flecha-v(largo: 0.5cm),
    fila(espacio: 6pt,
      caja([*Cuenta de gestión* \ facturación, Organizations, Identity Center \ (las SCP no la afectan)], ancho: 3.1cm, color: col.fundamentos),
      zona("OU Security", color: col.seguridad)[
        #columna(espacio: 4pt, pill("SCP: proteger CloudTrail", color: col.seguridad),
          caja([Log Archive], ancho: 2.3cm, color: col.seguridad), caja([Security Tooling], ancho: 2.3cm, color: col.seguridad))
      ],
      zona("OU Workloads", color: col.iam)[
        #columna(espacio: 4pt, pill("SCP: solo regiones de la UE", color: col.iam),
          fila(espacio: 5pt,
            zona("OU Prod", color: col.iam)[#caja([tienda-prod], ancho: 2cm, color: col.iam)],
            zona("OU Dev", color: col.iam)[#caja([tienda-dev], ancho: 2cm, color: col.iam)]))
      ],
      zona("OU Sandbox", color: col.computo)[
        #columna(espacio: 4pt, pill("SCP: tipos de instancia", color: col.computo),
          caja([sandbox-ana], ancho: 2.3cm, color: col.computo))
      ],
    ),
  )
]

#_concepto("SCP", "los guardarraíles de los principals de una cuenta",
  [Una política de Organizations que fija el *máximo* de lo que pueden hacer los usuarios y roles de las cuentas a las que se aplica, incluido su usuario root.],
  [No concede permisos: dentro de la cuenta sigue haciendo falta una política de identidad. No afecta a la cuenta de gestión ni a los roles vinculados a servicios.],
  [Imponer reglas de la organización que ningún administrador de cuenta puede saltarse: regiones, servicios prohibidos, no desactivar la auditoría.],
  [Denegar cualquier acción fuera de `eu-west-1` y `eu-south-2`, salvo los servicios globales.],
  [Quitar la SCP por defecto `FullAWSAccess` sin poner otra que permita: todo queda denegado en las cuentas afectadas.])

Una acción solo se permite si las SCP la permiten *en cada nivel* desde la raíz hasta la cuenta, y un Deny en cualquier nivel se hereda hacia abajo. Por eso el patrón más habitual es dejar `FullAWSAccess` y añadir SCP de *denegación*:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SoloRegionesUE",
      "Effect": "Deny",
      "NotAction": ["iam:*", "organizations:*", "sts:*", "route53:*", "cloudfront:*",
                    "support:*", "budgets:*"],
      "Resource": "*",
      "Condition": {"StringNotEquals": {
        "aws:RequestedRegion": ["eu-west-1", "eu-south-2"]}}
    },
    {
      "Sid": "ProtegerAuditoria",
      "Effect": "Deny",
      "Action": ["cloudtrail:StopLogging", "cloudtrail:DeleteTrail",
                 "organizations:LeaveOrganization"],
      "Resource": "*"
    }
  ]
}
```

La lista de `NotAction` está abreviada: la documentación de AWS ofrece la lista completa de servicios globales que deben quedar fuera de la restricción de regiones.

Las *RCP* (_resource control policies_, 2024) son la otra mitad: limitan lo que se puede hacer *sobre los recursos* de tus cuentas, sin importar quién lo pida, aunque sea un principal de fuera de la organización. Son la pieza clave de un *perímetro de datos*. Esta RCP impide que nadie ajeno a la organización acceda a los buckets, salvo los servicios de AWS que actúan en tu nombre:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "PerimetroDeDatosS3",
    "Effect": "Deny",
    "Principal": "*",
    "Action": "s3:*",
    "Resource": "*",
    "Condition": {
      "StringNotEqualsIfExists": {"aws:PrincipalOrgID": "o-a1b2c3d4e5"},
      "BoolIfExists": {"aws:PrincipalIsAWSService": "false"}
    }
  }]
}
```

#tabla(("", "SCP", "RCP"), columnas: (1.3fr, 2fr, 2fr),
  [*Limitan…*], [A los principals (usuarios y roles) de las cuentas miembro], [A los recursos de las cuentas miembro, los use quien los use],
  [*¿Afectan a identidades externas?*], [#no No], [#si Sí],
  [*Servicios*], [Todos], [Un subconjunto (al lanzarse: S3, STS, KMS, SQS y Secrets Manager)],
  [*¿Conceden permisos?*], [#no No], [#no No],
  [*Cuenta de gestión y roles vinculados a servicios*], [No les afectan], [No les afectan],
  [*Política por defecto*], [`FullAWSAccess`], [`RCPFullAWSAccess`])

#practica(titulo: "Estrategia multicuenta y AWS Control Tower")[Una estructura habitual separa una OU *Security* (cuentas de archivo de logs y de herramientas de seguridad), una OU *Infrastructure* (red y servicios compartidos), una OU *Workloads* con producción y no producción en cuentas distintas, y una OU *Sandbox* para experimentar con límites estrictos. *AWS Control Tower* automatiza esta *landing zone*: crea las cuentas de logs y auditoría, aplica *controles* preventivos (SCP y RCP), detectivos (reglas de AWS Config) y proactivos (hooks de CloudFormation), y ofrece una *Account Factory* para crear cuentas ya configuradas. Organizations admite además otros tipos de políticas: de etiquetas, de copias de seguridad y declarativas, entre otras.]

== Depurar un AccessDenied paso a paso

Tarde o temprano verás un mensaje como este. No lo resuelvas a ciegas añadiendo permisos: léelo.

```text
An error occurred (AccessDenied) when calling the GetObject operation:
User: arn:aws:sts::111122223333:assumed-role/app-web/i-0a1b2c3d4e5f67890
is not authorized to perform: s3:GetObject on resource:
"arn:aws:s3:::facturas/2026/enero.pdf" because no identity-based policy
allows the s3:GetObject action
```

#pasos(
  [*Lee el mensaje entero*: quién (aquí, una sesión del rol `app-web` lanzada por una instancia), qué acción y sobre qué recurso. Muchos servicios añaden *qué tipo de política* lo ha impedido.],
  [*Confirma la identidad* con `aws sts get-caller-identity`. Un perfil, un rol o una cuenta equivocados son la causa más común.],
  [*Busca el evento en CloudTrail* (`errorCode` = `AccessDenied` o `UnauthorizedOperation`) para ver la identidad, la acción y los recursos exactos.],
  [*Recorre las capas* del diagrama de evaluación: SCP/RCP → política de recurso → identidad → boundary → sesión. Entre cuentas, revisa los dos lados.],
  [*Reproduce y valida*: el simulador de políticas comprueba qué permitiría una política; IAM Access Analyzer valida su sintaxis y buenas prácticas.],
)

#tabla(("Si el mensaje dice…", "Mira aquí"), columnas: (2.2fr, 1.6fr), tamano: 8.2pt,
  [«…because no identity-based policy allows the … action»], [Falta un Allow en las políticas del usuario, de sus grupos o del rol],
  [«…with an explicit deny in an identity-based policy»], [Un Deny en esas mismas políticas],
  [«…because no resource-based policy allows…»], [La política del recurso (muy típico entre cuentas)],
  [«…with an explicit deny in a service control policy»], [Una SCP de la organización: habla con el equipo de plataforma],
  [«…because no permissions boundary allows…»], [El permissions boundary de la identidad],
  [«…because no session policy allows…»], [La session policy usada al asumir el rol o federarse])

```bash
aws sts get-caller-identity
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::111122223333:role/app-web \
  --action-names s3:GetObject --resource-arns arn:aws:s3:::facturas/2026/enero.pdf
aws sts decode-authorization-message --encoded-message <mensaje>   # p. ej., errores de EC2
aws accessanalyzer validate-policy --policy-type IDENTITY_POLICY \
  --policy-document file://politica.json
```

#tarjetas(columnas: 2,
  tarjeta("IAM Access Analyzer · validación", subtitulo: "antes de desplegar")[Revisa tus políticas y devuelve errores, avisos de seguridad y sugerencias. También ofrece comprobaciones personalizadas («¿esta política concede acceso público?»).],
  tarjeta("IAM Access Analyzer · acceso externo", subtitulo: "¿qué está compartido fuera?")[Detecta recursos (buckets, roles, claves KMS, funciones Lambda, colas, secretos…) accesibles desde fuera de tu cuenta u organización.],
  tarjeta("IAM Access Analyzer · acceso sin usar", subtitulo: "de pago")[Señala roles, access keys, contraseñas y permisos que no se usan, para retirarlos.],
  tarjeta("IAM Access Analyzer · generación", subtitulo: "a partir de la actividad")[Genera una política de mínimo privilegio a partir de las acciones que un rol ha usado realmente según CloudTrail.],
)

== Mínimo privilegio en la práctica

El principio de *mínimo privilegio* dice que cada identidad debe tener solo los permisos que necesita, y nada más. Nadie acierta a la primera, así que se aplica como un ciclo:

#diagrama(pie: [El ciclo del mínimo privilegio: empezar amplio pero acotado, observar el uso real y recortar.])[
  #fila(espacio: 4pt,
    caja([*1 · Empieza* \ con una política gestionada acotada], ancho: 2.5cm, color: col.iam),
    flecha(largo: 0.75cm),
    caja([*2 · Observa* \ CloudTrail y la información de último acceso], ancho: 2.5cm, color: col.iam),
    flecha(largo: 0.75cm),
    caja([*3 · Genera* \ una política con Access Analyzer], ancho: 2.5cm, color: col.iam),
    flecha(largo: 0.75cm),
    caja([*4 · Valida* \ y añade condiciones], ancho: 2.5cm, color: col.iam),
    flecha(largo: 0.75cm),
    caja([*5 · Revisa* \ y retira lo que no se usa], ancho: 2.5cm, color: col.iam),
  )
]

Para revisar periódicamente tienes el *informe de credenciales* (`aws iam generate-credential-report`: un CSV con el estado de contraseñas, MFA y access keys de cada usuario), la *información de último acceso* (qué servicios, y en algunos casos qué acciones, ha usado cada identidad y cuándo) y los hallazgos de acceso sin usar de Access Analyzer.

#tarjetas(
  tarjeta("Haz", color: _verde)[
    - Personas con Identity Center; cargas de trabajo con roles.
    - Políticas gestionadas por el cliente, acotadas a recursos concretos.
    - Condiciones (MFA, organización, red, etiquetas) donde aporten.
    - Guardarraíles con SCP/RCP y boundaries para delegar.
    - Revisiones periódicas con Access Analyzer.
  ],
  tarjeta("Evita", color: _rojo)[
    - `"Action": "*"` sobre `"Resource": "*"` fuera de administradores.
    - Access keys de largo plazo y usuarios compartidos.
    - `Allow` con `NotAction`.
    - `Principal: "*"` sin condiciones en políticas de recurso.
    - Usar la cuenta de gestión para cargas de trabajo.
  ],
)

== Ejercicios resueltos

Antes de leer la solución, decide tú: ¿se permite la petición? Recuerda las tres reglas y el diagrama de evaluación.

#_ejercicio(1, [Laura ejecuta `aws s3 ls s3://fotos`. Su única política es esta.],
  [```json
{
  "Effect": "Allow",
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::fotos/*"
}
```], false,
  [Listar es `s3:ListBucket` y se autoriza contra el ARN del *bucket* (`arn:aws:s3:::fotos`), que esta sentencia no cubre: deny implícito. Puede descargar objetos si conoce su nombre, pero no listarlos.])

#_ejercicio(2, [Ana (grupos Desarrollo y Seguridad-prod) intenta terminar una instancia con la etiqueta `Entorno=prod`.],
  [```json
[{"Effect": "Allow", "Action": "ec2:*",
  "Resource": "*"},
 {"Effect": "Deny",
  "Action": "ec2:TerminateInstances",
  "Resource": "*",
  "Condition": {"StringEquals":
    {"aws:ResourceTag/Entorno": "prod"}}}]
```], false,
  [La primera sentencia (grupo Desarrollo) lo permite, pero la segunda (grupo Seguridad-prod) lo deniega explícitamente y el Deny gana. Con una instancia `Entorno=dev`, la condición no se cumple, el Deny no aplica y la acción se *permite*.])

#_ejercicio(3, [Un usuario lanza desde casa (IP `198.51.100.7`) un `aws s3 cp` a un bucket.],
  [```json
{
  "Effect": "Allow",
  "Action": "s3:*",
  "Resource": "*",
  "Condition": {"IpAddress":
    {"aws:SourceIp": "203.0.113.0/24"}}
}
```], false,
  [La condición no se cumple, así que la sentencia no aplica y no queda ningún Allow: deny implícito. Ojo: si la petición llegara a S3 por un VPC endpoint, `aws:SourceIp` tampoco serviría, porque no contiene la IP pública.])

#_ejercicio(4, [El rol `analitica` (cuenta A) lee un objeto de `datos-b` (cuenta B), cuya política de bucket no menciona a la cuenta A.],
  [```json
{
  "Effect": "Allow",
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::datos-b/*"
}
```], false,
  [Es una política de identidad en la cuenta A: entre cuentas hace falta *también* un Allow en la política del bucket de B. Soluciones: añadirlo en B o hacer que A asuma un rol de B.])

#_ejercicio(5, [Un administrador con `AdministratorAccess` lanza una instancia en `us-east-1`. Su cuenta está en la OU Workloads, con la SCP de regiones de este capítulo.],
  [```json
{
  "Effect": "Deny",
  "NotAction": ["iam:*", "sts:*", "..."],
  "Resource": "*",
  "Condition": {"StringNotEquals":
    {"aws:RequestedRegion":
      ["eu-west-1", "eu-south-2"]}}
}
```], false,
  [`ec2:RunInstances` no está en `NotAction` y la región no es de la UE: la SCP lo deniega explícitamente. Da igual que sea administrador, e incluso el usuario root de la cuenta miembro: solo la cuenta de gestión queda fuera del alcance de las SCP.])

#resumen[
- Tres reglas: todo empieza denegado; un Allow explícito lo abre; un Deny explícito gana siempre.
- Una sentencia combina `Effect`, `Action`, `Resource` y, opcionalmente, `Condition`; las políticas de recurso añaden `Principal`. Usa siempre `"Version": "2012-10-17"`.
- En las condiciones, claves distintas se combinan con Y y los valores de una clave, con O. `NotAction` con `Allow` es peligroso.
- Las políticas de identidad y de recurso conceden; los boundaries, las SCP, las RCP y las session policies solo limitan. Los permisos efectivos son la intersección.
- En la misma cuenta basta un Allow (de identidad o de recurso, salvo trust policies y claves KMS); entre cuentas hacen falta los dos.
- Las condiciones globales (`aws:PrincipalOrgID`, `aws:SourceIp`, `aws:MultiFactorAuthPresent`…) y ABAC con etiquetas dan precisión sin multiplicar políticas.
- Los permissions boundaries permiten delegar la creación de roles sin escalada de privilegios.
- Las SCP limitan a los principals de las cuentas; las RCP, a sus recursos. Ninguna afecta a la cuenta de gestión.
- Ante un AccessDenied: lee el mensaje, confirma la identidad, busca en CloudTrail, recorre las capas y valida con el simulador y Access Analyzer.
]

#repaso(
  ([Un usuario sin ninguna política de identidad está en una cuenta cuya SCP permite `s3:*`. ¿Puede leer un bucket de su cuenta?], [No, salvo que la política del bucket le conceda acceso a él directamente. Las SCP no conceden permisos: solo limitan.]),
  ([¿Por qué hace falta listar `arn:aws:s3:::facturas` y `arn:aws:s3:::facturas/*` en la misma política?], [Porque `s3:ListBucket` actúa sobre el bucket y `s3:GetObject` sobre los objetos: son tipos de recurso distintos.]),
  ([Un rol tiene una política que permite `s3:*` y `sqs:*`, y un boundary que permite `s3:*` y `dynamodb:*`. ¿Puede enviar un mensaje a SQS?], [No: los permisos efectivos son la intersección (solo S3). El boundary no concede DynamoDB, porque la política del rol tampoco lo permite.]),
  ([La cuenta A necesita leer un bucket de la cuenta B con una política de recurso. ¿Qué dos permisos hacen falta?], [Un Allow en la política de identidad del principal de A y un Allow para ese principal en la política del bucket de B (y que las SCP de A y las RCP de B no lo impidan).]),
  ([¿Por qué se usa `BoolIfExists` y no `Bool` para denegar acciones sin MFA?], [Porque con access keys de largo plazo la clave `aws:MultiFactorAuthPresent` no existe; con `Bool` la condición no se cumpliría y esas peticiones escaparían del Deny.]),
  ([Quieres que los desarrolladores creen roles para sus Lambdas sin poder convertirse en administradores. ¿Qué mecanismo usas?], [Un permissions boundary obligatorio (condición `iam:PermissionsBoundary` al crear roles), `iam:PassRole` limitado a su ruta y un Deny que impida quitar o editar el boundary.]),
  ([Quieres impedir que cualquier identidad ajena a tu organización acceda a tus buckets, aunque una política de bucket lo permita por error. ¿SCP o RCP?], [Una RCP: limita los recursos de tus cuentas sea quien sea el principal. Las SCP solo afectan a los principals de tus propias cuentas.]),
  ([Recibes «…with an explicit deny in a service control policy». ¿Añadir permisos al rol lo arregla?], [No. El bloqueo está en una SCP de Organizations; ningún permiso en la cuenta puede anular un Deny explícito. Hay que cambiar la SCP o mover la cuenta.]),
)
