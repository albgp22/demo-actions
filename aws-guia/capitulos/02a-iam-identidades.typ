#import "../theme.typ": *

// =====================================================================
//  Capítulo 2 (I) — IAM: identidades
//  Usuarios, grupos, roles, STS, Identity Center y permission sets
// =====================================================================

// ---- Elementos propios del capítulo -----------------------------------

#let _rojo = rgb("#E03131")
#let _verde = rgb("#2F9E44")
#let _m(t) = text(font: "JetBrains Mono", size: 0.92em, t)

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

// Banda del mapa de IAM
#let _banda(n, titulo, pregunta, c, cuerpo) = grid(
  columns: (3.2cm, 1fr),
  grid.cell(fill: c, inset: (x: 8pt, y: 7pt), align: left + horizon, {
    set par(justify: false, leading: 0.4em)
    set text(hyphenate: false)
    text(6.5pt, weight: "bold", fill: white.transparentize(15%), tracking: 1pt, "PASO " + str(n))
    linebreak()
    text(10pt, weight: "bold", fill: white, titulo)
    linebreak()
    text(7.2pt, fill: white, pregunta)
  }),
  grid.cell(fill: c.lighten(91%), inset: (x: 6pt, y: 7pt), align: center + horizon, cuerpo),
)
#let _bajada(t) = align(left, pad(left: 1.45cm, flecha-v(etiqueta: t, largo: 0.62cm)))

// Diagrama de secuencia (líneas de vida y mensajes)
#let _secuencia(ancho, alto, actores, mensajes, nota-ancho: 4.6cm) = box(width: ancho, height: alto, {
  let cab = 0.8cm
  let gf = rgb("#5C6878")
  for (x, t, c) in actores {
    place(top + left, dx: x - 1.45cm, box(width: 2.9cm, height: cab, fill: c, radius: 4pt,
      align(center + horizon, text(7.4pt, weight: "bold", fill: white, t))))
    place(top + left, dx: x - 0.4pt, dy: cab, line(start: (0pt, 0pt), end: (0pt, alto - cab),
      stroke: (paint: c.lighten(30%), thickness: 0.8pt, dash: "dashed")))
  }
  for (x0, x1, y, et, punteada) in mensajes {
    if x0 == x1 {
      place(top + left, dx: x0 - nota-ancho / 2, dy: y - 0.3cm, box(width: nota-ancho, fill: white,
        stroke: 0.7pt + col.iam.lighten(40%), radius: 3pt, inset: (x: 5pt, y: 4pt),
        align(center, { set par(justify: false, leading: 0.4em); text(6.7pt, fill: tinta, et) })))
    } else {
      let izq = calc.min(x0, x1)
      let der = calc.max(x0, x1)
      let st = (paint: gf, thickness: 1pt, dash: if punteada { "dashed" } else { none })
      if x1 > x0 {
        place(top + left, dx: izq, dy: y, line(length: der - izq - 6pt, stroke: st))
        place(top + left, dx: der - 7pt, dy: y - 3.5pt, polygon(fill: gf, (0pt, 0pt), (7pt, 3.5pt), (0pt, 7pt)))
      } else {
        place(top + left, dx: izq + 6pt, dy: y, line(length: der - izq - 6pt, stroke: st))
        place(top + left, dx: izq, dy: y - 3.5pt, polygon(fill: gf, (7pt, 0pt), (0pt, 3.5pt), (7pt, 7pt)))
      }
      place(top + left, dx: izq + 4pt, dy: y - 0.86cm, box(width: der - izq - 8pt, height: 0.82cm,
        align(center + bottom, box(fill: fondo-suave, inset: (x: 3pt, y: 1.5pt), {
          set par(justify: false, leading: 0.35em)
          text(6.8pt, weight: "medium", fill: tinta, et)
        }))))
    }
  }
})

// Escenario resuelto
#let _escenario(n, titulo, solucion, cuerpo) = block(width: 100%, breakable: true,
  above: 1.1em, below: 1.1em, stroke: 0.8pt + col.iam.lighten(60%), radius: 7pt, clip: true, {
    block(width: 100%, spacing: 0pt, sticky: true, fill: col.iam.lighten(91%), inset: (x: 10pt, y: 6pt),
      grid(columns: (auto, 1fr, auto), column-gutter: 8pt, align: horizon,
        box(fill: col.iam, radius: 3pt, inset: (x: 5pt, y: 3pt),
          text(7.3pt, weight: "bold", fill: white, tracking: 0.5pt, "ESCENARIO " + str(n))),
        text(9.5pt, weight: "bold", fill: col.iam.darken(30%), titulo),
        pill(solucion, color: col.iam)))
    block(width: 100%, spacing: 0pt, inset: (x: 10pt, y: 8pt), {
      set text(9.2pt)
      cuerpo
    })
  })

// Pregunta frecuente
#let _faq(p, r) = block(breakable: false, below: 8pt, grid(columns: (auto, 1fr), column-gutter: 6pt,
  box(fill: col.iam, radius: 3pt, inset: (x: 4pt, y: 2pt), text(8pt, weight: "bold", fill: white, "?")),
  {
    set par(justify: false)
    text(9pt, weight: "bold", fill: marino, p)
    linebreak()
    text(8.6pt, r)
  }))

// =====================================================================

#capitulo("IAM (I): identidades — usuarios, grupos, roles y permission sets", color: col.iam,
  subtitulo: [Quién es quién en AWS y cómo consigue cada identidad sus credenciales: el mapa que necesitas antes de escribir una sola política.],
  objetivos: (
    [Un modelo mental de cómo encajan todas las piezas de IAM],
    [Qué es (y qué no es) un usuario, un grupo y un rol],
    [Cómo funcionan AssumeRole y las credenciales temporales de STS],
    [IAM Identity Center, permission sets y asignaciones],
    [Federación: SAML, OIDC, GitHub Actions y Cognito],
    [Qué identidad usar en cada escenario real],
  ),
  servicios: ("AWS IAM", "AWS STS", "IAM Identity Center", "AWS Organizations", "Amazon Cognito", "IAM Roles Anywhere"))

== El mapa de IAM antes de los detalles

Cada vez que alguien hace algo en AWS —un clic en la consola, un comando de la CLI, una llamada desde el código de una aplicación— envía una *petición a una API*. Y cada petición tiene que responder a dos preguntas: *¿quién eres?* (autenticación) y *¿puedes hacer esto?* (autorización). *AWS Identity and Access Management* (IAM) es el servicio que gestiona ambas cosas para todas tus cuentas y servicios.

IAM tiene fama de difícil porque mezcla muchas piezas con nombres parecidos: usuarios, grupos, roles, políticas, permission sets, STS… La forma de no perderse es tener primero el mapa completo. Toda petición recorre siempre los mismos cuatro pasos:

#diagrama(pie: [El recorrido de cualquier petición en AWS. Este capítulo trata los pasos 1 y 2 (quién eres y con qué credenciales); el siguiente, el paso 3 (qué puedes hacer).])[
  #_banda(1, "Identidad", "¿Quién eres?", col.iam, fila(espacio: 5pt,
    caja([*Usuario IAM* \ persona o app con credenciales propias], ancho: 2.8cm, color: col.iam),
    caja([*Rol IAM* \ identidad que se «asume»], ancho: 2.8cm, color: col.iam),
    caja([*Usuario de Identity Center* \ empleado de tu empresa], ancho: 2.8cm, color: col.iam),
    caja([*Identidad externa* \ IdP, GitHub, Cognito…], ancho: 2.8cm, color: col.iam)))
  #_bajada[se autentica y obtiene…]
  #_banda(2, "Credenciales", "¿Con qué lo demuestras?", col.fundamentos, fila(espacio: 5pt,
    caja([*Contraseña + MFA* \ para la consola], ancho: 3.1cm, color: col.fundamentos),
    caja([*Access keys de largo plazo* \ (AKIA…) · no caducan], ancho: 3.3cm, color: _rojo),
    caja([*Credenciales temporales de STS* \ (ASIA… + token) · caducan], ancho: 4.4cm, color: _verde)))
  #_bajada[firma cada petición con ellas]
  #_banda(3, "Políticas", "¿Qué puedes hacer?", col.datos, fila(espacio: 5pt,
    caja([*Políticas de identidad* \ en el usuario, grupo o rol], ancho: 3.5cm, color: col.datos),
    caja([*Políticas de recurso* \ en el bucket, la cola, la clave…], ancho: 3.5cm, color: col.datos),
    caja([*Límites* \ SCP, RCP, boundary, sesión], ancho: 3.5cm, color: col.datos)))
  #_bajada[AWS decide: Allow o Deny]
  #_banda(4, "Recurso", "¿Sobre qué?", col.almacenamiento, fila(espacio: 5pt,
    caja([Bucket S3], ancho: 2.5cm, color: col.almacenamiento),
    caja([Tabla DynamoDB], ancho: 2.5cm, color: col.almacenamiento),
    caja([Cola SQS], ancho: 2.5cm, color: col.almacenamiento),
    caja([Instancia EC2], ancho: 2.5cm, color: col.almacenamiento)))
]

Fíjate en el color de las credenciales: la gran idea de IAM moderno es que *casi nadie debería tener credenciales permanentes*. Las personas entran con su identidad corporativa y reciben credenciales temporales; las aplicaciones usan roles, que también producen credenciales temporales. Las access keys de largo plazo son el último recurso.

=== La analogía que nos acompañará: un edificio de oficinas

Imagina que tu cuenta AWS es un edificio de oficinas de una gran empresa con varias sedes. Usaremos esta imagen en los dos capítulos de IAM:

#tabla(("En nuestro edificio…", "…en AWS es"), columnas: (2.4fr, 1fr),
  [El edificio, con sus salas, sus equipos y su propia contabilidad], [Una *cuenta AWS*],
  [La llave maestra del propietario: abre todo y nadie puede restringirla], [El *usuario root*],
  [Un empleado con su tarjeta de acceso personal y permanente], [Un *usuario IAM*],
  [Un departamento: los permisos se dan al departamento y los heredan sus miembros], [Un *grupo IAM*],
  [Una acreditación temporal (el chaleco de «Mantenimiento», el pase de auditor) que se pone quien esté autorizado y que caduca], [Un *rol IAM*],
  [La lista de quién puede recoger cada acreditación], [La *trust policy* del rol],
  [El mostrador de seguridad que comprueba quién eres y te entrega la acreditación con su hora de caducidad], [*AWS STS*],
  [Lo que permite hacer cada tarjeta o acreditación], [Las *políticas de permisos*],
  [El departamento central de RR. HH. del grupo, que da de alta a cada persona una sola vez para todas las sedes], [*IAM Identity Center*],
  [La plantilla de acreditación («Desarrollador», «Auditor») que RR. HH. reparte a varias sedes], [Un *permission set*],
  [El cartel en la puerta de una sala: «solo personal de Contabilidad»], [Una *política de recurso*],
  [Las normas del grupo empresarial que ningún edificio puede saltarse], [Las *SCP* de Organizations])

#cuidado(titulo: "Dónde deja de funcionar la analogía")[
- En AWS no se enseña la tarjeta solo al entrar: *cada petición* se autentica y se autoriza por separado, miles de veces por segundo.
- Las acreditaciones (roles) se las «ponen» sobre todo *programas*: una instancia EC2, una función Lambda, un pipeline de despliegue.
- Un departamento (grupo) no es una persona: no puede entrar en ningún sitio ni ponerse una acreditación.
- Ponerte una acreditación no suma permisos a tu tarjeta: mientras la llevas, *solo vale la acreditación*.
- Una prohibición explícita gana siempre, aunque otra norma lo permita (capítulo siguiente).
]

== Principals, autenticación y autorización

Un *principal* es quien hace una petición a AWS: una persona o una aplicación que actúa con una identidad. Conviene distinguir dos cosas que se confunden a menudo: las *identidades* que creas en IAM y a las que adjuntas permisos (usuarios, grupos y roles) y el *principal* que firma cada petición: el usuario root, un usuario IAM, una *sesión* de un rol, una identidad federada o un servicio de AWS que actúa en tu nombre. La sutileza importa: un grupo es una identidad (le adjuntas políticas), pero *nunca firma una petición*; y un rol tampoco firma nada por sí mismo: lo hace una *sesión del rol*, que nace cuando alguien lo asume.

#block(breakable: false, tarjetas(
  tarjeta("Autenticación", color: col.iam, subtitulo: "¿Quién eres?")[Demostrar la identidad: contraseña y MFA en la consola; en la CLI y los SDK, una *firma criptográfica* (Signature Version 4) que se calcula con la clave secreta y acompaña a cada petición. La clave secreta nunca viaja.],
  tarjeta("Autorización", color: col.datos, subtitulo: "¿Puedes hacer esto?")[AWS reúne el *contexto de la petición* —principal, acción (`s3:GetObject`), recurso (su ARN) y datos del entorno (IP, hora, región, etiquetas)— y lo evalúa contra las políticas que aplican.],
))

Cada principal tiene un ARN, y aprender a leerlos te ahorrará muchos quebraderos de cabeza al revisar errores o registros de CloudTrail:

#tabla(("Principal", "ARN de ejemplo"), columnas: (1fr, 3.2fr),
  [Usuario root], [`arn:aws:iam::111122223333:root`],
  [Usuario IAM], [`arn:aws:iam::111122223333:user/ana`],
  [Rol IAM], [`arn:aws:iam::111122223333:role/app-web`],
  [Sesión de un rol], [`arn:aws:sts::111122223333:assumed-role/app-web/i-0a1b2c3d4e5f67890`],
  [Servicio de AWS], [`ec2.amazonaws.com` (solo dentro de políticas, como principal de servicio)])

El comando más útil de toda la CLI es el que te dice con qué identidad estás trabajando. Fíjate en que, tras asumir un rol, el ARN es de tipo `assumed-role` y termina con el *nombre de sesión*, que permite saber quién o qué asumió el rol:

```bash
$ aws sts get-caller-identity
{
    "UserId": "AROA3XFRBF23EXAMPLE:ana",
    "Account": "222222222222",
    "Arn": "arn:aws:sts::222222222222:assumed-role/Desarrollador/ana"
}
```

== El usuario root: la llave maestra

El *usuario root* nace con la cuenta, entra con el correo y la contraseña del registro y tiene acceso total, incluida la facturación. No es un usuario IAM y las políticas de IAM no pueden limitarlo en su cuenta (solo las SCP de Organizations, en cuentas miembro). Como viste en el capítulo de Fundamentos, se protege con MFA, sin access keys, y se usa únicamente para las pocas tareas que lo exigen. Todo lo demás se hace con las identidades de este capítulo.

#analogia(titulo: "En nuestro edificio")[La llave maestra se guarda en la caja fuerte del propietario. Nadie va a trabajar cada día con ella colgada del cuello.]

== Usuarios IAM

#_concepto("Usuario IAM", "una identidad permanente dentro de una cuenta",
  [Una identidad con *credenciales de largo plazo* en una sola cuenta: contraseña para la consola y/o hasta dos access keys para la API.],
  [No es una persona de tu directorio corporativo ni sirve en otras cuentas: existe solo donde lo creas. Tampoco es el usuario root.],
  [Hoy, casos excepcionales: acceso de emergencia (_break-glass_), herramientas de terceros que no admiten roles ni federación, o cuentas aisladas sin Identity Center.],
  [El usuario `emergencia-admin`, con MFA en una llave física guardada bajo llave, para cuando falla el proveedor de identidad corporativo.],
  [Un usuario compartido por varias personas, o access keys copiadas en el código, en un fichero `.env` o en un repositorio Git.])

Un usuario IAM puede tener tres tipos de credenciales:

#tabla(("Credencial", "Para qué sirve", "Lo que debes saber"), columnas: (1fr, 1.4fr, 2.3fr),
  [*Contraseña*], [Entrar en la consola], [Aplica una política de contraseñas en la cuenta y combínala siempre con MFA.],
  [*MFA*], [Segundo factor al iniciar sesión], [App de autenticación (TOTP), llave FIDO2 o _passkey_; hasta 8 dispositivos por usuario. Puedes exigirla con políticas.],
  [*Access keys*], [Firmar peticiones desde la CLI, los SDK o la API], [Un ID (empieza por `AKIA`) y una clave secreta. *No caducan*: si se filtran, cualquiera actúa como ese usuario hasta que las desactives. Máximo dos por usuario, para poder rotarlas.])

#cuidado(titulo: "Por qué evitar las access keys")[Las claves permanentes acaban en sitios donde no deberían: el código, una imagen de contenedor, un portátil robado, un repositorio público. Bots automatizados rastrean GitHub en busca de claves y pueden usarlas en minutos (lo típico: lanzar instancias para minar criptomonedas). AWS también rastrea los repositorios públicos y puede aplicar una política de cuarentena al usuario afectado, pero no cuentes con llegar a tiempo. En la sección de escenarios verás la alternativa sin claves para cada caso; si aun así necesitas una, rótala, limita sus permisos y vigila su último uso (`aws iam get-access-key-last-used`).]

#analogia(titulo: "En nuestro edificio")[Un usuario IAM es un empleado con tarjeta personal y permanente para *una* sede. Funciona, pero si tiene que trabajar en diez sedes necesita diez tarjetas, y cuando se va de la empresa hay que acordarse de anular las diez.]

== Grupos IAM

#_concepto("Grupo IAM", "un conjunto de usuarios IAM que comparten permisos",
  [Una colección de usuarios IAM de una cuenta a la que adjuntas políticas; sus miembros heredan esos permisos.],
  [*No es un principal*: no tiene credenciales, no inicia sesión, no puede asumir roles ni aparecer como `Principal` en una política. No contiene otros grupos y no es un grupo de Identity Center.],
  [Gestionar permisos por función en vez de usuario a usuario: altas, bajas y cambios de puesto son meter o sacar a alguien del grupo.],
  [El grupo `Auditores` con la política gestionada `SecurityAudit`: cuando llega un auditor nuevo, basta con añadirlo.],
  [Adjuntar políticas a cada usuario por separado, o intentar nombrar un grupo en la política de un bucket (no funciona: no es un principal).])

¿Y si un usuario está en varios grupos? Sus permisos son la *unión* de todo lo que permiten sus políticas propias y las de todos sus grupos (un usuario puede pertenecer a 10 grupos como máximo, y los grupos no se anidan). La excepción es la prohibición explícita: un `Deny` en cualquiera de esas políticas gana siempre.

#diagrama(pie: [Ana hereda los permisos de sus dos grupos, pero el Deny de su política propia anula una parte de lo que le da el grupo Desarrolladores.])[
  #fila(espacio: 8pt,
    columna(espacio: 5pt,
      zona("Grupo Desarrolladores", color: col.iam)[#caja([Allow ec2:\*], ancho: 3.6cm, color: _verde)],
      zona("Grupo Soporte", color: col.iam)[#caja([Allow support:\*], ancho: 3.6cm, color: _verde)],
      zona("Política propia de Ana", color: col.iam)[#caja([Deny ec2:TerminateInstances], ancho: 3.6cm, color: _rojo)]),
    flecha(largo: 1.3cm),
    actor(etiqueta: "Ana", color: col.iam),
    flecha(etiqueta: "resultado", largo: 1.5cm),
    caja([*Permisos efectivos de Ana* \ todo EC2 salvo terminar instancias \ + todo AWS Support], ancho: 4.4cm, color: col.fundamentos),
  )
]

== Roles IAM: identidades que se asumen

Los roles son la pieza más importante de IAM y la que más cuesta entender al principio. La clave es esta: un rol *no es de nadie*. Es un conjunto de permisos con una lista de quién puede usarlo; quien está en la lista lo *asume* durante un tiempo y recibe credenciales temporales.

#_concepto("Rol IAM", "una identidad sin credenciales propias que se «asume»",
  [Una identidad con permisos pero *sin contraseña ni access keys*; quien autorice su trust policy la asume y recibe credenciales temporales de STS.],
  [No es un usuario, no pertenece a una persona concreta y *no suma* permisos: mientras lo usas tienes los del rol, no los tuyos. No es un grupo.],
  [Dar permisos a servicios (EC2, Lambda, ECS), acceder a otras cuentas, federar identidades externas y elevar privilegios de forma puntual y auditada.],
  [El rol `app-web`, que asumen las instancias EC2 de la web para leer el bucket de imágenes.],
  [Confundir sus dos políticas, o crear un usuario con access keys para una aplicación que podría usar un rol.])

=== Las dos caras de un rol

Todo rol tiene dos políticas que responden a preguntas distintas. La *trust policy* (política de confianza) dice *quién puede asumirlo*: es una política de recurso adjunta al propio rol y su elemento clave es `Principal`. La *permissions policy* (una o varias políticas de identidad) dice *qué puede hacer* quien lo asume.

#diagrama(pie: [La trust policy controla la entrada al rol; la permissions policy, lo que se puede hacer una vez dentro.])[
  #fila(espacio: 5pt,
    zona("Trust policy", color: col.datos)[
      #text(7pt, fill: gris)[¿Quién puede asumirlo?]
      #v(1pt)
      #columna(espacio: 4pt,
        caja([*Un servicio* \ ec2.amazonaws.com], ancho: 3.3cm, color: col.datos),
        caja([*Otra cuenta* \ 111111111111], ancho: 3.3cm, color: col.datos),
        caja([*Identidades federadas* \ SAML u OIDC], ancho: 3.3cm, color: col.datos))
    ],
    flecha(etiqueta: "lo asume", largo: 1.5cm),
    svc("ROL", "Rol app-web", sub: "sin contraseña ni claves", color: col.iam),
    flecha(etiqueta: "y entonces puede", largo: 1.5cm),
    zona("Permissions policy", color: col.almacenamiento)[
      #text(7pt, fill: gris)[¿Qué puede hacer?]
      #v(1pt)
      #columna(espacio: 4pt,
        caja([Leer objetos del \ bucket fotos], ancho: 3.3cm, color: col.almacenamiento),
        caja([Escribir en la tabla \ DynamoDB pedidos], ancho: 3.3cm, color: col.almacenamiento),
        caja([Nada más \ (deny implícito)], ancho: 3.3cm, color: col.almacenamiento))
    ],
  )
]

#grid(columns: (1fr, 1fr), column-gutter: 10pt,
  [
    #text(8.5pt, weight: "bold", fill: col.datos.darken(10%))[Trust policy: la asumen las instancias EC2]
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]
}
```
  ],
  [
    #text(8.5pt, weight: "bold", fill: _verde.darken(10%))[Permissions policy: lo que puede hacer]
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:GetObject"],
    "Resource":
      "arn:aws:s3:::fotos/*"
  }]
}
```
  ],
)

#analogia(titulo: "En nuestro edificio")[El rol es el chaleco de «Mantenimiento» colgado en el mostrador de seguridad. La trust policy es la lista pegada al lado: «pueden recogerlo los técnicos de la contrata X». La permissions policy es lo que abre el chaleco: el cuarto de calderas, no la sala de dirección.]

=== AssumeRole paso a paso

Asumir un rol es una conversación con *AWS STS* (_Security Token Service_), el servicio que emite credenciales temporales:

#pasos(
  [El principal (un usuario, un servicio, otra cuenta) llama a `sts:AssumeRole` con el ARN del rol y un *nombre de sesión*. Si es una identidad de IAM, necesita además que su propia política le permita `sts:AssumeRole` sobre ese rol.],
  [STS comprueba la *trust policy*: ¿aparece quien llama como principal de confianza? ¿Se cumplen las condiciones (MFA, External ID, etiquetas…)?],
  [Si todo encaja, STS devuelve *credenciales temporales*: `AccessKeyId` (empieza por `ASIA`), `SecretAccessKey`, `SessionToken` y `Expiration`.],
  [El principal firma sus peticiones con ellas. Para AWS ahora es la sesión `assumed-role/NombreDelRol/NombreDeSesion`.],
  [Cada petición se autoriza con la *permissions policy* del rol (y los límites que apliquen). Al caducar, se vuelve a asumir el rol; los SDK lo hacen solos.],
)

#diagrama(pie: [AssumeRole visto como una secuencia de mensajes. Las credenciales temporales sustituyen a cualquier clave permanente.])[
  #_secuencia(15cm, 6.5cm,
    ((1.7cm, "Principal (tu app)", col.computo), (7.3cm, "AWS STS", col.iam), (12.8cm, "Amazon S3", col.almacenamiento)),
    (
      (1.7cm, 7.3cm, 1.5cm, [1 · #_m("sts:AssumeRole") (ARN del rol, nombre de sesión)], false),
      (7.3cm, 7.3cm, 2.1cm, [2 · ¿La trust policy confía en quien llama? ¿Se cumplen sus condiciones?], false),
      (7.3cm, 1.7cm, 3.55cm, [3 · AccessKeyId (ASIA…), SecretAccessKey, SessionToken, Expiration], true),
      (1.7cm, 12.8cm, 4.55cm, [4 · #_m("s3:GetObject") firmado con las credenciales temporales], false),
      (12.8cm, 12.8cm, 5.15cm, [5 · IAM evalúa la permissions policy del rol], false),
      (12.8cm, 1.7cm, 6.1cm, [6 · El objeto… o #_m("AccessDenied")], true),
    ))
]

En la CLI rara vez llamarás a `assume-role` a mano: basta con describir el rol en un perfil de `~/.aws/config` y la CLI lo asume (y renueva) por ti.

```toml
# ~/.aws/config: al usar --profile prod, la CLI asume el rol con las credenciales de "dev"
[profile prod]
role_arn       = arn:aws:iam::222222222222:role/Despliegue
source_profile = dev
mfa_serial     = arn:aws:iam::111111111111:mfa/ana   # pide el código MFA
```

=== Cuánto duran las sesiones y el encadenamiento de roles

Una sesión de `AssumeRole` dura *una hora* por defecto. Quien llama puede pedir entre 15 minutos y la duración máxima configurada en el rol (`MaxSessionDuration`), que puede llegar a 12 horas. Si con las credenciales de un rol asumes otro, haces *encadenamiento de roles* (_role chaining_): es legítimo —por ejemplo, desde una cuenta central de automatización—, pero esa segunda sesión dura como máximo una hora, se pida lo que se pida.

#cuidado[Un proceso largo (una migración de varias horas) que se apoya en roles encadenados fallará con credenciales caducadas al cabo de una hora. Diseña esos procesos para renovar credenciales, o asume el rol directamente desde la identidad de origen.]

=== Perfiles de instancia: cómo recibe EC2 su rol

Una instancia EC2 no puede «asumir» nada por sí misma: el rol se le entrega dentro de un *perfil de instancia* (_instance profile_), un contenedor que admite un único rol. Si creas el rol de EC2 desde la consola, el perfil se crea solo con el mismo nombre; con la CLI o con IaC son dos recursos distintos. Dentro de la instancia, el SDK obtiene las credenciales temporales del servicio de metadatos (IMDS, en `169.254.169.254`) y las renueva automáticamente antes de que caduquen. Usa siempre *IMDSv2*, que exige un token de sesión y protege frente a ataques de falsificación de peticiones del lado del servidor (SSRF).

```bash
aws iam create-instance-profile --instance-profile-name app-web
aws iam add-role-to-instance-profile --instance-profile-name app-web --role-name app-web
aws ec2 associate-iam-instance-profile --instance-id i-0a1b2c3d4e5f67890 \
  --iam-instance-profile Name=app-web
```

=== Roles de servicio y roles vinculados a servicios

#tabla(("", "Rol de servicio", "Rol vinculado a un servicio"), columnas: (1fr, 2fr, 2fr),
  [*Qué es*], [Un rol normal que creas tú para que un servicio actúe en tu nombre], [Un rol predefinido que crea y gestiona el propio servicio],
  [*Ejemplos*], [Rol de ejecución de una Lambda, _task role_ de ECS, rol de una instancia EC2], [`AWSServiceRoleForAutoScaling`, `AWSServiceRoleForECS`],
  [*Permisos*], [Los decides tú (mínimo privilegio)], [Los define AWS; no puedes editarlos],
  [*Borrado*], [Cuando quieras], [Solo cuando el servicio ya no lo usa],
  [*Detalles*], [Su trust policy nombra al servicio (`lambda.amazonaws.com`)], [Ruta `/aws-service-role/`; las SCP no lo restringen])

Para entregar un rol a un servicio —lanzar una instancia con un perfil, crear una Lambda con su rol de ejecución— necesitas el permiso `iam:PassRole` sobre ese rol. Sin esa barrera, cualquiera que pudiera crear una Lambda podría darle un rol de administrador y escalar privilegios a través de ella. En el capítulo siguiente verás cómo acotarlo.

=== Terceros y el External ID: el problema del «confused deputy»

Muchos proveedores (herramientas de costes, de seguridad, de monitorización) acceden a tu cuenta asumiendo un rol que tú creas y que confía en *su* cuenta. El riesgo se llama *confused deputy* (el «ayudante confundido»): un cliente malicioso del mismo proveedor le da *el ARN de tu rol* como si fuera el suyo, y el proveedor, que sí tiene permiso para asumirlo, acaba trabajando con tu cuenta en nombre del atacante.

#diagrama(pie: [Sin External ID, el proveedor podría asumir tu rol por encargo de otro cliente. Con él, la trust policy solo acepta el identificador que el proveedor generó para ti.])[
  #fila(espacio: 5pt,
    zona("Atacante", color: _rojo)[#actor(etiqueta: "Otro cliente", color: _rojo)],
    flecha(etiqueta: "1 · «mi rol es este ARN»", largo: 2.3cm, color: _rojo),
    zona("Proveedor SaaS", color: col.neutro)[#svc("SaaS", "Servicio de auditoría", sub: "cuenta 999999999999", color: col.neutro)],
    flecha(etiqueta: "2 · AssumeRole + ID ajeno", largo: 2.3cm),
    zona("Tu cuenta", color: col.iam)[#columna(svc("ROL", "Rol auditor-saas", sub: "exige su External ID", color: col.iam), text(8.5pt, weight: "bold", fill: _rojo)[#no denegado])],
  )
]

La defensa es el *External ID*: el proveedor genera un identificador único para cada cliente y lo envía siempre al asumir el rol; tu trust policy lo exige con una condición. El atacante no puede hacer que el proveedor use *tu* identificador, así que la petición se deniega:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"AWS": "arn:aws:iam::999999999999:root"},
    "Action": "sts:AssumeRole",
    "Condition": {"StringEquals": {"sts:ExternalId": "7f3a9c1e-cliente-1234"}}
  }]
}
```

#nota[En `Principal`, `arn:aws:iam::999999999999:root` significa «la cuenta 999999999999», no su usuario root: delegas en esa cuenta, y son sus administradores quienes deciden qué identidades suyas pueden asumir tu rol. Para los servicios de AWS que actúan en tu nombre existe un problema análogo, que se resuelve con las condiciones `aws:SourceArn` y `aws:SourceAccount` (capítulo siguiente).]

== Varias cuentas: AWS Organizations en dos minutos

Las organizaciones bien gestionadas no meten todo en una cuenta: separan producción, desarrollo, seguridad o cada equipo en *cuentas distintas*, porque una cuenta es la frontera de aislamiento más fuerte que existe en AWS. *AWS Organizations* las agrupa bajo una *cuenta de gestión* (_management account_), que paga la factura consolidada y gobierna a las *cuentas miembro*, organizadas en *unidades organizativas* (OU) como «Producción» o «Sandbox». Las políticas de la organización (SCP y RCP) se verán en el capítulo siguiente; aquí importa una consecuencia: con varias cuentas, crear usuarios IAM en cada una se vuelve inmanejable. Para eso existe IAM Identity Center.

== IAM Identity Center y los permission sets

*IAM Identity Center* (antes AWS Single Sign-On) es la forma recomendada de dar acceso a las *personas* de tu organización a todas tus cuentas AWS (y a aplicaciones). Cada persona tiene una única identidad, con MFA, y desde un *portal de acceso* elige a qué cuenta entrar y con qué perfil, siempre con credenciales temporales. Se habilita normalmente en la cuenta de gestión de Organizations (o en una cuenta de administración delegada). Sus piezas:

/ Fuente de identidad: dónde viven las personas. Puede ser el directorio propio de Identity Center, un Active Directory (AWS Managed Microsoft AD o el tuyo a través de AD Connector) o un proveedor externo como Microsoft Entra ID, Okta o Google Workspace, conectado por SAML 2.0 y con *SCIM* para sincronizar automáticamente usuarios y grupos. Solo puede haber una a la vez.
/ Usuarios y grupos: las personas y sus agrupaciones (normalmente los mismos grupos que ya tienes en tu directorio corporativo).
/ Permission sets: plantillas de permisos que defines una vez.
/ Asignaciones: la combinación *quién + qué + dónde*: un usuario o grupo, un permission set y una cuenta AWS.
/ Portal de acceso: la web (`https://d-xxxxxxxxxx.awsapps.com/start` o un alias propio) donde cada persona ve las cuentas y perfiles que tiene asignados.

#_concepto("Usuario / grupo de Identity Center", "las personas de tu organización",
  [Una persona del almacén de identidades de Identity Center (creada allí o sincronizada desde tu IdP), y los grupos que las reúnen para asignarles acceso.],
  [No es un usuario IAM: no existe en ninguna cuenta, no tiene access keys permanentes ni le adjuntas políticas de IAM. Sus grupos *no* son grupos de IAM.],
  [Dar a cada empleado una única identidad con la que entra, con MFA, en todas las cuentas y aplicaciones que se le asignen.],
  [Ana entra en el portal con su cuenta corporativa de Microsoft Entra ID y ve las cuentas `dev` y `prod`.],
  [Crear además un usuario IAM para la misma persona «por si acaso», o dar de alta personas a mano cuando tu IdP puede sincronizarlas por SCIM.])

#_concepto("Permission set", "una plantilla de permisos para muchas cuentas",
  [Una plantilla definida en Identity Center con políticas gestionadas (de AWS o tuyas), una política inline opcional, un permissions boundary opcional y la duración de la sesión (de 1 a 12 horas).],
  [No es un rol ni una política que se adjunte: por sí mismo no concede nada hasta que lo *asignas* a una cuenta. No es un principal.],
  [Definir perfiles —«Desarrollador», «SoloLectura», «Administrador»— una sola vez y desplegarlos en tantas cuentas como necesites.],
  [`PowerUser` = política gestionada `PowerUserAccess` + sesión de 8 horas, asignado al grupo `Developers` en las cuentas `dev` y `test`.],
  [Editar a mano el rol que genera en cada cuenta (Identity Center lo sobrescribe), o usar una política propia que no existe con ese nombre en alguna cuenta asignada.])

=== Qué ocurre por debajo

Aquí está la pieza que lo conecta todo: cuando asignas un permission set a una cuenta, Identity Center *crea en esa cuenta un rol IAM* llamado `AWSReservedSSO_<NombreDelPermissionSet>_<sufijo>`, con las políticas del permission set y una trust policy que solo confía en Identity Center. Cuando Ana elige «cuenta dev → PowerUser» en el portal, en realidad *asume ese rol*. Si cambias el permission set, Identity Center actualiza el rol en todas las cuentas asignadas. Un permission set asignado a veinte cuentas son veinte roles, uno por cuenta.

#diagrama(pie: [De la persona al recurso: Ana pertenece al grupo Developers, que tiene asignado el permission set PowerUser en la cuenta dev. Identity Center ha creado allí el rol que Ana asume al entrar.])[
  #zona("IAM Identity Center", color: col.iam, punteada: false, relleno: white)[
    #fila(espacio: 4pt,
      actor(etiqueta: "Ana", color: col.iam),
      flecha(etiqueta: "miembro de", largo: 1.6cm),
      caja([*Grupo* \ Developers], ancho: 2.4cm, color: col.iam),
      flecha(etiqueta: "asignación", largo: 1.6cm),
      caja([*Permission set* PowerUser \ en la cuenta dev], ancho: 3.6cm, color: col.iam),
    )
  ]
  #flecha-v(etiqueta: [crea el rol en la cuenta; Ana lo asume desde el portal], largo: 0.95cm)
  #zona("Cuenta dev · 222222222222", color: col.fundamentos, punteada: false, relleno: white)[
    #fila(espacio: 4pt,
      caja([*Rol IAM* \ AWSReservedSSO\_PowerUser\_1a2b3c…], ancho: 4.6cm, color: col.fundamentos),
      flecha(etiqueta: "credenciales temporales", largo: 2.4cm),
      svc("S3", "Bucket de la cuenta dev", color: col.almacenamiento),
    )
  ]
]

Así es una jornada de Ana:

#pasos(
  [Abre el portal de acceso y se autentica en el IdP corporativo, con MFA.],
  [El portal le muestra las cuentas y permission sets que tiene asignados, directamente o a través de sus grupos.],
  [Elige «dev → PowerUser»: Identity Center la federa en esa cuenta asumiendo el rol `AWSReservedSSO_PowerUser_…`.],
  [Trabaja en la consola o en la CLI con credenciales temporales que caducan según la duración de sesión del permission set. En CloudTrail queda como `assumed-role/AWSReservedSSO_PowerUser_…/ana`.],
)

Desde la CLI, la configuración se hace una vez con `aws configure sso`, que crea un perfil como este; después, cada día basta con `aws sso login`:

```toml
[profile dev-poweruser]
sso_session    = empresa
sso_account_id = 222222222222
sso_role_name  = PowerUser          # el nombre del permission set
region         = eu-west-1

[sso-session empresa]
sso_start_url           = https://d-1234567890.awsapps.com/start
sso_region              = eu-west-1
sso_registration_scopes = sso:account:access
```

```bash
aws sso login --profile dev-poweruser    # abre el navegador para autenticarte
aws s3 ls --profile dev-poweruser        # credenciales temporales, renovadas solas
```

#tabla(("", "Grupo IAM", "Grupo de Identity Center"), columnas: (1fr, 2fr, 2fr),
  [*Dónde vive*], [En una cuenta AWS concreta], [En el almacén de identidades de Identity Center (o sincronizado desde tu IdP)],
  [*Miembros*], [Usuarios IAM de esa cuenta], [Usuarios de Identity Center],
  [*Cómo da permisos*], [Políticas de IAM adjuntas al grupo], [Asignaciones: grupo + permission set + cuenta],
  [*Alcance*], [Una sola cuenta], [Todas las cuentas de la organización que asignes])

#analogia(titulo: "En nuestro edificio")[Identity Center es el departamento central de RR. HH. del grupo empresarial: da de alta a Ana una sola vez y decide en qué sedes puede trabajar. El permission set es la plantilla de acreditación «Desarrollador» que RR. HH. envía a cada sede, donde se convierte en un chaleco concreto colgado en su mostrador (el rol `AWSReservedSSO_…`).]

== Otras formas de federación

La *federación* consiste en que AWS confíe en un proveedor de identidad externo: las identidades viven fuera y, tras autenticarse allí, reciben credenciales temporales de AWS asumiendo un rol. Identity Center es la federación recomendada para empleados, pero hay otros casos:

#tabla(("Mecanismo", "Para quién", "Cómo obtiene las credenciales"), columnas: (1.3fr, 1.5fr, 2.2fr),
  [*IAM Identity Center*], [Empleados, en muchas cuentas], [Portal o CLI → asume el rol `AWSReservedSSO_…` de cada cuenta],
  [*Federación SAML 2.0 directa con IAM*], [Empleados en una cuenta (enfoque heredado)], [El IdP entrega una aserción SAML → `AssumeRoleWithSAML`],
  [*Proveedor OIDC en IAM*], [Cargas externas: GitHub Actions, GitLab, Kubernetes…], [Un token OIDC (JWT) firmado por el emisor → `AssumeRoleWithWebIdentity`],
  [*Amazon Cognito*], [Usuarios finales de tus aplicaciones], [Un _user pool_ autentica y emite tokens; un _identity pool_ los canjea por credenciales de un rol limitado],
  [*IAM Roles Anywhere*], [Servidores y cargas fuera de AWS], [Un certificado X.509 de tu PKI de confianza → credenciales temporales de un rol])

== Todas las piezas de un vistazo

#tabla(("Pieza", "¿Es principal?", "Credenciales", "¿Puede ir en «Principal»?", "Quién la usa", "Cuándo usarla"),
  columnas: (1.15fr, 0.85fr, 1.35fr, 0.95fr, 1.35fr, 1.6fr), tamano: 7.8pt,
  [*Usuario IAM*], [#si Sí], [Permanentes: contraseña y/o access keys], [#si Sí, su ARN], [Una persona o app concreta, en una cuenta], [Excepciones: acceso de emergencia, herramientas sin soporte de roles],
  [*Grupo IAM*], [#no No], [Ninguna], [#no No], [Agrupa usuarios IAM para adjuntarles políticas], [Organizar los permisos de los usuarios IAM que queden],
  [*Rol IAM*], [#si Sí, a través de sus sesiones], [Temporales, para quien lo asume], [#si Sí, el ARN del rol], [Servicios, otras cuentas, identidades federadas], [Siempre que puedas: cargas de trabajo, acceso entre cuentas, federación],
  [*Usuario / grupo de Identity Center*], [#parcial Actúa mediante un rol], [Temporales, del rol de cada cuenta], [#no No (aparece el rol)], [Las personas de la organización], [Acceso humano a la consola y la CLI en todas las cuentas],
  [*Permission set*], [#no No], [Ninguna: es una plantilla], [#no No], [Administradores de Identity Center], [Definir perfiles una vez y desplegarlos en muchas cuentas],
  [*Política*], [#no No], [Ninguna], [#no No (la contiene)], [Se adjunta a identidades o recursos], [Siempre: es lo que concede o limita permisos (capítulo siguiente)])

== ¿Qué uso cuando…? Nueve escenarios resueltos

#_escenario(1, [Una persona de tu empresa entra en la consola], "IAM Identity Center")[
  #align(center, fila(espacio: 4pt,
    actor(etiqueta: "Empleada", color: col.iam),
    flecha(etiqueta: "login + MFA", largo: 1.5cm),
    svc("IdP", "Entra ID, Okta…", sub: "fuente de identidad", color: col.neutro),
    flecha(etiqueta: "SAML", largo: 1.3cm),
    svc("IIC", "IAM Identity Center", sub: "portal de acceso", color: col.iam),
    flecha(etiqueta: "asume", largo: 1.3cm),
    caja([Rol AWSReservedSSO\_… \ de la cuenta elegida], ancho: 3.3cm, color: col.fundamentos)))
  Crea (o sincroniza por SCIM) a la persona y sus grupos en Identity Center, define permission sets y asigna *grupos*, no personas sueltas. *Evita:* un usuario IAM por persona y por cuenta.
]

#_escenario(2, [Una aplicación en EC2 lee objetos de S3], "Rol + perfil de instancia")[
  #align(center, fila(espacio: 4pt,
    svc("ROL", "Rol app-web", sub: "trust: ec2.amazonaws.com", color: col.iam),
    flecha(etiqueta: "perfil de instancia", largo: 2cm),
    svc("EC2", "Instancia", sub: "el SDK lee IMDSv2", color: col.computo),
    flecha(etiqueta: "GetObject firmado", largo: 2cm),
    svc("S3", "Bucket fotos", color: col.almacenamiento)))
  El rol permite `s3:GetObject` sobre `arn:aws:s3:::fotos/*`; el código no contiene ninguna clave: el SDK encuentra solo las credenciales. *Evita:* access keys en ficheros de la instancia, en variables de entorno o en la AMI.
]

#_escenario(3, [Una función Lambda escribe en DynamoDB], "Rol de ejecución")[
  #align(center, fila(espacio: 4pt,
    svc("ROL", "Rol de ejecución", sub: "trust: lambda.amazonaws.com", color: col.iam),
    flecha(etiqueta: "lo asume Lambda", largo: 2cm),
    svc("λ", "Función alta-pedido", color: col.serverless),
    flecha(etiqueta: "PutItem", largo: 1.6cm),
    svc("DDB", "Tabla pedidos", color: col.datos)))
  El rol de ejecución lleva `dynamodb:PutItem` sobre esa tabla y los permisos para escribir sus logs. Quién puede *invocar* la función es otra cosa: lo decide su política de recurso (capítulo de Serverless).
]

#_escenario(4, [Un task de ECS lee un secreto de Secrets Manager], "Task role / execution role")[
  #align(center, fila(espacio: 6pt,
    columna(espacio: 3pt,
      svc("ROL", "Task execution role", sub: "el agente: imagen de ECR, logs, secretos inyectados", color: col.iam),
      svc("ROL", "Task role", sub: "tu código, vía SDK", color: col.iam)),
    flecha(largo: 1.2cm),
    svc("ECS", "Tarea ECS", color: col.contenedores),
    flecha(etiqueta: "GetSecretValue", largo: 2cm),
    svc("SM", "Secrets Manager", color: col.seguridad)))
  Una tarea de ECS tiene *dos* roles, ambos con trust en `ecs-tasks.amazonaws.com`. Si el secreto se inyecta como variable de entorno (sección `secrets` de la definición de tarea), quien lo lee es el agente: el permiso va en el *execution role*. Si tu código lo pide en tiempo de ejecución con el SDK, va en el *task role*. Confundirlos es un error muy común.
]

#_escenario(5, [GitHub Actions despliega en AWS sin access keys], "Federación OIDC")[
  #align(center, fila(espacio: 4pt,
    svc("GH", "GitHub Actions", sub: "permiso id-token: write", color: col.neutro),
    flecha(etiqueta: "token OIDC (JWT)", largo: 2cm),
    svc("STS", "AWS STS", sub: "AssumeRoleWithWebIdentity", color: col.iam),
    flecha(etiqueta: "credenciales temporales", largo: 2.3cm),
    svc("ROL", "Rol github-deploy", sub: "solo tu repositorio y rama", color: col.iam)))
  Registra en IAM el proveedor OIDC `token.actions.githubusercontent.com` y crea un rol cuya trust policy acepte solo los tokens de *tu* repositorio y rama. Sin la condición sobre `sub`, cualquier repositorio de GitHub podría asumir el rol.
]

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated":
        "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {"token.actions.githubusercontent.com:aud": "sts.amazonaws.com"},
      "StringLike": {"token.actions.githubusercontent.com:sub": "repo:mi-org/web:ref:refs/heads/main"}
    }
  }]
}
```

```yaml
permissions:
  id-token: write        # permite al job pedir el token OIDC
  contents: read
steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::123456789012:role/github-deploy
      aws-region: eu-west-1
  - run: aws s3 sync ./dist s3://mi-web-estatica
```

#_escenario(6, [La cuenta A lee un bucket de la cuenta B], "Política de recurso o rol en B")[
  #align(center, columna(espacio: 6pt,
    fila(espacio: 4pt, text(7.5pt, weight: "bold", fill: gris)[Opción 1],
      zona("Cuenta A", color: col.iam)[#svc("ROL", "Rol analitica", color: col.iam)],
      flecha(etiqueta: "GetObject", largo: 1.6cm),
      zona("Cuenta B", color: col.fundamentos)[#svc("S3", "Bucket datos-b", sub: "su política permite al rol de A", color: col.almacenamiento)]),
    fila(espacio: 4pt, text(7.5pt, weight: "bold", fill: gris)[Opción 2],
      zona("Cuenta A", color: col.iam)[#svc("ROL", "Rol analitica", color: col.iam)],
      flecha(etiqueta: "AssumeRole", largo: 1.6cm),
      zona("Cuenta B", color: col.fundamentos)[#fila(espacio: 4pt,
        svc("ROL", "Rol lector-b", sub: "trust: cuenta A", color: col.iam),
        flecha(etiqueta: "GetObject", largo: 1.4cm),
        svc("S3", "Bucket datos-b", color: col.almacenamiento))]),
  ))
  *Opción 1:* la política del bucket en B permite el acceso al rol de A, y la política de identidad del rol en A permite `s3:GetObject` sobre ese bucket: entre cuentas hacen falta *los dos permisos*. *Opción 2:* A asume un rol de B y trabaja «dentro» de B; útil cuando hay que tocar muchos recursos. Recuerda que, con un rol, A deja de tener sus propios permisos durante la sesión.
]

#_escenario(7, [Un proveedor SaaS externo audita tu cuenta], "Rol con External ID")[
  #pasos(
    [El proveedor te da su número de cuenta y un *External ID* único para ti.],
    [Creas un rol cuya trust policy confía en la cuenta del proveedor *y* exige ese External ID (como en la sección del _confused deputy_).],
    [Le adjuntas solo lo necesario: por ejemplo, la política gestionada `SecurityAudit` o `ReadOnlyAccess`.],
    [Entregas al proveedor el ARN del rol. Puedes revocar el acceso en cualquier momento borrando el rol o cambiando su trust policy.],
  )
]

#_escenario(8, [Los usuarios finales de tu app móvil], "Amazon Cognito")[
  #align(center, fila(espacio: 4pt,
    actor(etiqueta: "Cliente de la app", color: col.neutro),
    flecha(etiqueta: "registro y login", largo: 1.8cm),
    svc("UP", "Cognito user pool", sub: "emite tokens JWT", color: col.iam),
    flecha(etiqueta: "token", largo: 1.3cm),
    svc("IDP", "Cognito identity pool", sub: "canjea el token", color: col.iam),
    flecha(etiqueta: "rol limitado", largo: 1.6cm),
    svc("S3", "Su carpeta en S3", color: col.almacenamiento)))
  Tus clientes no son empleados: no van en IAM ni en Identity Center. Un *user pool* de Cognito gestiona el registro, el inicio de sesión y la MFA; si la app necesita llamar directamente a servicios de AWS, un *identity pool* canjea el token por credenciales temporales de un rol muy limitado. A menudo basta con que tu API (por ejemplo, API Gateway) valide el token.
]

#_escenario(9, [La AWS CLI en tu portátil], "aws configure sso")[
  Configura un perfil de Identity Center con `aws configure sso` y, cada día, `aws sso login`: la CLI guarda credenciales temporales en caché y las renueva mientras dure la sesión. *Evita* `aws configure` con access keys permanentes guardadas en `~/.aws/credentials`. Si tu organización aún no usa Identity Center, la segunda mejor opción es un usuario IAM *sin permisos propios* salvo asumir roles, con MFA exigida, y perfiles con `role_arn` y `mfa_serial` como el que viste en la sección de AssumeRole.
]

== Preguntas frecuentes y confusiones típicas

#grid(columns: (1fr, 1fr), column-gutter: 14pt,
  [
    #_faq([¿Un grupo puede asumir un rol o aparecer como `Principal`?], [No. Un grupo no es un principal. Para que sus miembros asuman un rol, adjunta al grupo una política que permita `sts:AssumeRole` sobre él, y haz que la trust policy del rol confíe en la cuenta (o en esos usuarios).])
    #_faq([¿Un rol tiene contraseña o access keys?], [No. Solo produce credenciales temporales para quien lo asume.])
    #_faq([¿Qué diferencia hay entre un rol y un permission set?], [El permission set es la plantilla que defines en Identity Center; el rol es lo que Identity Center crea a partir de ella en cada cuenta asignada (`AWSReservedSSO_…`).])
    #_faq([¿Por qué no usar usuarios IAM para las personas?], [Porque tienen credenciales permanentes, se multiplican por cada cuenta y hay que darlos de baja uno a uno. Con Identity Center hay una identidad por persona, MFA centralizada y credenciales temporales.])
    #_faq([¿Si asumo un rol, conservo mis permisos?], [No. Durante la sesión solo tienes los del rol. Para volver a los tuyos, sales del rol.])
    #_faq([¿Las access keys caducan?], [No, a menos que las desactives o las borres. Las credenciales temporales de STS sí caducan.])
  ],
  [
    #_faq([¿Qué es el usuario root y cuándo lo uso?], [La identidad con la que se creó la cuenta, con acceso total. Solo para las pocas tareas que lo exigen (cambiar el correo de la cuenta, cerrarla…); protégelo con MFA y sin access keys.])
    #_faq([¿Se pueden anidar grupos de IAM?], [No. Un usuario puede estar en hasta 10 grupos, pero un grupo no puede contener otros grupos.])
    #_faq([¿Qué pasa si un usuario está en dos grupos?], [Recibe la unión de los permisos de ambos (y de sus políticas propias); si alguna política deniega explícitamente una acción, el Deny gana.])
    #_faq([¿Qué es un ARN `assumed-role`?], [El de una sesión de rol: `arn:aws:sts::cuenta:assumed-role/rol/sesión`. Es lo que verás en errores y en CloudTrail; el nombre de sesión identifica quién asumió el rol.])
    #_faq([¿Cognito sirve para los empleados?], [No es su propósito: Cognito es para los clientes de tus aplicaciones. Para empleados, Identity Center.])
    #_faq([¿Los cambios en IAM son inmediatos?], [IAM es globalmente *eventualmente consistente*: un cambio puede tardar unos segundos en propagarse. No lo pongas en el camino crítico de tu aplicación.])
  ],
)

#resumen[
- Toda petición recorre cuatro pasos: identidad → credenciales → políticas → recurso. Este capítulo cubre los dos primeros.
- Un principal es quien firma una petición. Usuarios, grupos y roles son identidades; los grupos nunca firman nada y los roles actúan a través de sesiones.
- Los usuarios IAM tienen credenciales permanentes (contraseña, access keys `AKIA…`): resérvalos para casos excepcionales.
- Los grupos IAM reparten políticas entre usuarios IAM; no son principals, no se anidan y no son grupos de Identity Center.
- Un rol no tiene credenciales propias: su trust policy dice quién puede asumirlo y su permissions policy, qué puede hacer. STS entrega credenciales temporales (`ASIA…` + token + caducidad).
- EC2 recibe su rol mediante un perfil de instancia; Lambda y ECS, mediante roles de ejecución y _task roles_. Entregar un rol a un servicio exige `iam:PassRole`.
- El External ID protege los roles para terceros frente al _confused deputy_.
- IAM Identity Center da a cada persona una identidad única; un permission set es una plantilla que se convierte en un rol `AWSReservedSSO_…` en cada cuenta asignada.
- Para cargas externas, federación OIDC (GitHub Actions) o IAM Roles Anywhere; para clientes de tus apps, Amazon Cognito.
]

#repaso(
  ([¿Por qué un grupo IAM no puede aparecer como `Principal` en la política de un bucket?], [Porque no es un principal: no se autentica ni firma peticiones. Solo sirve para adjuntar políticas a sus usuarios.]),
  ([¿Qué dos políticas tiene un rol y qué pregunta responde cada una?], [La trust policy (¿quién puede asumirlo?) y la permissions policy (¿qué puede hacer quien lo asume?).]),
  ([Tu equipo copia access keys en un servidor EC2 para que la aplicación lea de S3. ¿Qué propones?], [Un rol con permiso de lectura sobre ese bucket, entregado a la instancia con un perfil de instancia; el SDK obtiene credenciales temporales del IMDS y se eliminan las claves.]),
  ([Ana tiene asignado el permission set `ReadOnly` en las cuentas `dev` y `prod`. ¿Cuántos roles ha creado Identity Center y cómo se llaman?], [Dos, uno en cada cuenta, con nombres del tipo `AWSReservedSSO_ReadOnly_<sufijo>`. Ana asume el de la cuenta que elige en el portal.]),
  ([Un job de ECS falla al arrancar porque no puede leer el secreto que se inyecta como variable de entorno, aunque el _task role_ tiene permiso. ¿Qué pasa?], [Los secretos inyectados por la definición de tarea los lee el agente de ECS, que usa el _task execution role_: el permiso `secretsmanager:GetSecretValue` debe estar en ese rol.]),
  ([Un proveedor de monitorización necesita acceso de lectura a tu cuenta. ¿Cómo lo configuras de forma segura?], [Con un rol que confíe en la cuenta del proveedor, exija su External ID en una condición y tenga solo permisos de lectura; le das el ARN del rol, nunca access keys.]),
  ([Un script que encadena dos roles falla siempre al cabo de una hora. ¿Por qué?], [Porque en el encadenamiento de roles la segunda sesión dura como máximo una hora, aunque el rol permita más; hay que renovar credenciales o asumir el rol directamente.]),
  ([¿Qué identidad deben usar los clientes de tu app móvil para subir fotos a S3?], [Ninguna de IAM ni de Identity Center: un user pool de Cognito para autenticarse y, si acceden directamente a S3, un identity pool que entregue credenciales temporales de un rol limitado a su carpeta.]),
)
