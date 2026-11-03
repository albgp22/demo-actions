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
  grid.cell(fill: c, inset: (x: 8pt, y: 5.5pt), align: left + horizon, {
    set par(justify: false, leading: 0.4em)
    set text(hyphenate: false)
    text(6.5pt, weight: "bold", fill: white.transparentize(15%), tracking: 1pt, "PASO " + str(n))
    linebreak()
    text(10pt, weight: "bold", fill: white, titulo)
    linebreak()
    text(7.2pt, fill: white, pregunta)
  }),
  grid.cell(fill: c.lighten(91%), inset: (x: 6pt, y: 5.5pt), align: center + horizon, cuerpo),
)
#let _bajada(t) = align(left, pad(left: 1.45cm, flecha-v(etiqueta: t, largo: 0.5cm)))

// Flecha hacia la izquierda (el tema solo trae flechas hacia la derecha o dobles)
#let _flecha-izq(etiqueta: none, largo: 1.4cm, color: rgb("#7A8699")) = box(width: largo, height: 2.6em, {
  place(left + horizon, dx: 5pt, line(length: largo - 5pt, stroke: 1.2pt + color))
  place(left + horizon, polygon(fill: color, (7pt, 0pt), (0pt, 3.5pt), (7pt, 7pt)))
  if etiqueta != none {
    place(center + top, dy: -1pt, box(width: largo + 0.8cm, align(center, {
      set par(justify: false, leading: 0.3em)
      text(6.4pt, fill: color.darken(25%), weight: "medium", etiqueta)
    })))
  }
})

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

// Mini-diagrama centrado y sin guionado (para los escenarios)
#let _mini(cuerpo) = align(center, text(hyphenate: false, cuerpo))

// =====================================================================

#show figure.where(kind: "diagrama"): set text(hyphenate: false)

#capitulo("IAM (I): identidades — usuarios, grupos, roles y permission sets", color: col.iam,
  subtitulo: [Quién es quién en AWS y cómo consigue cada identidad sus credenciales: el mapa que necesitas antes de escribir una sola política.],
  objetivos: (
    [Un modelo mental de cómo encajan todas las piezas de IAM],
    [Qué es (y qué no es) un usuario, un grupo y un rol],
    [AssumeRole, STS y cómo reciben sus credenciales EC2, Lambda o un pipeline],
    [IAM Identity Center, permission sets y qué pasa al entrar por el portal],
    [Federación: SAML, OIDC, GitHub Actions y Cognito],
    [Qué identidad usar en cada escenario real],
  ),
  servicios: ("AWS IAM", "AWS STS", "IAM Identity Center", "AWS Organizations", "Amazon Cognito", "IAM Roles Anywhere"))

== El mapa de IAM antes de los detalles

Cada vez que alguien hace algo en AWS —un clic en la consola, un comando de la CLI, una llamada desde una aplicación— envía una *petición a una API*, y AWS debe responder a dos preguntas: *¿quién eres?* (autenticación) y *¿puedes hacer esto?* (autorización). *AWS Identity and Access Management* (IAM) gestiona ambas. Tiene fama de difícil porque mezcla piezas con nombres parecidos —usuarios, grupos, roles, políticas, permission sets, STS—, así que empecemos por el mapa completo. Toda petición recorre los mismos cuatro pasos:

#diagrama(pie: [El recorrido de cualquier petición en AWS. Este capítulo trata los pasos 1 y 2 (quién eres y con qué credenciales); el siguiente, el paso 3 (qué puedes hacer).])[
  #_banda(1, "Identidad", "¿Quién eres?", col.iam, fila(espacio: 5pt,
    caja([*Usuario IAM* \ persona o app con credenciales propias], ancho: 2.8cm, color: col.iam),
    caja([*Rol IAM* \ identidad que se «asume»], ancho: 2.8cm, color: col.iam),
    caja([*Usuario de Identity Center* \ empleado de tu empresa], ancho: 2.8cm, color: col.iam),
    caja([*Identidad externa* \ IdP corporativo, GitHub, Cognito…], ancho: 2.8cm, color: col.iam)))
  #_bajada[se autentica y obtiene…]
  #_banda(2, "Credenciales", "¿Con qué lo demuestras?", col.fundamentos, fila(espacio: 5pt,
    caja([*Contraseña + MFA* \ para la consola], ancho: 3.1cm, color: col.fundamentos),
    caja([*Access keys de largo plazo* \ (AKIA…) · no caducan], ancho: 3.3cm, color: _rojo),
    caja([*Credenciales temporales de STS* \ (ASIA… + token) · caducan], ancho: 4.4cm, color: _verde)))
  #_bajada[firma cada petición con ellas]
  #_banda(3, "Políticas", "¿Qué puedes hacer?", col.datos, fila(espacio: 5pt,
    caja([*Políticas de identidad* \ en el usuario, grupo o rol], ancho: 3.5cm, color: col.datos),
    caja([*Políticas de recurso* \ en el bucket, la cola, la clave…], ancho: 3.5cm, color: col.datos),
    caja([*Límites* \ techos que solo recortan], ancho: 3.5cm, color: col.datos)))
  #_bajada[AWS decide: Allow o Deny]
  #_banda(4, "Recurso", "¿Sobre qué?", col.almacenamiento, fila(espacio: 5pt,
    caja([Bucket S3], ancho: 2.5cm, color: col.almacenamiento),
    caja([Tabla DynamoDB], ancho: 2.5cm, color: col.almacenamiento),
    caja([Cola SQS], ancho: 2.5cm, color: col.almacenamiento),
    caja([Instancia EC2], ancho: 2.5cm, color: col.almacenamiento)))
]

Fíjate en el color de las credenciales: la gran idea de IAM moderno es que *casi nadie debería tener credenciales permanentes*. Las personas entran con la identidad que ya tienen en su empresa, gestionada por un *proveedor de identidad* (IdP, _identity provider_, como Microsoft Entra ID u Okta), y reciben credenciales temporales; las aplicaciones usan roles, que también las producen. Quien fabrica esas credenciales temporales es *AWS STS* (_Security Token Service_). Las access keys de largo plazo son el último recurso.

¿Y los grupos y los permission sets del título? No aparecen en el paso 1 porque *nunca hacen peticiones*: son formas de *repartir políticas*. Un grupo IAM las reparte entre los usuarios IAM de una cuenta; un permission set, entre las cuentas de una organización, donde se convierte en un rol.

=== La analogía que nos acompañará: un edificio de oficinas

Imagina una gran empresa con varias sedes: cada sede es una cuenta AWS, y la empresa entera, tu organización. Usaremos esta imagen en los dos capítulos de IAM:

#tabla(("En nuestro edificio…", "…en AWS es"), columnas: (2.8fr, 1fr),
  [Una sede, con sus salas y su propia contabilidad], [Una *cuenta AWS*],
  [La llave maestra de la sede: abre todo, sin restricciones internas], [El *usuario root*],
  [Un empleado con tarjeta personal y permanente, válida en una sola sede], [Un *usuario IAM*],
  [Un departamento: sus miembros reciben los accesos del departamento], [Un *grupo IAM*],
  [Una acreditación de «Mantenimiento»: se recoge en el mostrador y caduca], [Un *rol IAM*],
  [La lista, junto al mostrador, de quién puede recoger esa acreditación], [Su *trust policy*],
  [Las puertas que abre esa acreditación], [Su *permissions policy*],
  [El vigilante que comprueba la lista y entrega la acreditación], [*AWS STS*],
  [El RR. HH. central: un alta por persona, válida para todas las sedes], [*IAM Identity Center*],
  [El modelo de acreditación «Desarrollador» o «Auditor», definido una vez], [Un *permission set*],
  [La orden «Ana recoge la acreditación Desarrollador en la sede dev»], [Una *asignación*])

En el capítulo siguiente completaremos el edificio con los carteles de las puertas (políticas de recurso) y las normas de la empresa que ninguna sede puede saltarse (SCP).

#cuidado(titulo: "Dónde deja de funcionar la analogía")[
- En AWS no se enseña la tarjeta solo al entrar: *cada petición* se autentica y se autoriza por separado.
- Las acreditaciones (roles) las recogen sobre todo *programas*: instancias EC2, funciones Lambda, pipelines.
- Un departamento (grupo) no es una persona: no entra en ningún sitio ni recoge acreditaciones.
- Recoger una acreditación no suma permisos a tu tarjeta: mientras actúas con ella, *solo cuenta ella*.
- En un edificio puedes pasear por los pasillos; en AWS, todo lo que no está permitido expresamente está prohibido.
]

== Principals, autenticación y autorización

La *autenticación* demuestra quién eres: en la consola, con contraseña y MFA; en la CLI y los SDK, con una *firma criptográfica* (Signature Version 4) que se calcula con tu clave secreta sin que esta viaje nunca por la red. Puede hacerla el propio AWS o un IdP externo en el que AWS confía: eso es la *federación*, que verás más adelante. La *autorización* llega después: AWS reúne el *contexto de la petición* —quién la hace, la acción (`s3:GetObject`), el recurso (su ARN) y datos del entorno (IP, hora, región, etiquetas)— y lo evalúa contra las políticas que aplican.

Ese «quién» se llama *principal*: la entidad que firma una petición concreta. No lo confundas con las *identidades* que creas en IAM para adjuntarles permisos (usuarios, grupos y roles), porque no coinciden una a una:

#tabla(("Pieza", "¿Quién firma sus peticiones?", "ARN que verás en errores y en CloudTrail"), columnas: (0.85fr, 1.35fr, 2.4fr), tamano: 8.2pt,
  [*Usuario root*], [Él mismo (evítalo en el día a día)], [`arn:aws:iam::111122223333:root`],
  [*Usuario IAM*], [El propio usuario, con su contraseña o sus access keys], [`arn:aws:iam::111122223333:user/ana`],
  [*Grupo IAM*], [*Nadie*: solo reparte políticas entre sus miembros], [Tiene ARN (`…:group/Auditores`), pero nunca firma],
  [*Rol IAM*], [Nunca él: firma una *sesión del rol*, es decir, quien lo asumió], [El rol: `arn:aws:iam::111122223333:role/app-web`],
  [*Sesión de un rol*], [Quien asumió el rol, con credenciales temporales], [`arn:aws:sts::…:assumed-role/app-web/i-0a1b…`],
  [*Servicio de AWS*], [El servicio, cuando actúa en tu nombre], [Un nombre de servicio, como `ec2.amazonaws.com`])

El *usuario root* es un caso aparte: nace con la cuenta, tiene acceso total y las políticas de IAM no pueden limitarlo (solo las SCP, en las cuentas miembro de una organización). Es la llave maestra que se guarda en la caja fuerte; ya viste en el capítulo de Fundamentos cómo protegerlo.

El comando más útil de toda la CLI es el que te dice con qué identidad estás trabajando. Tras asumir un rol, el ARN es de tipo `assumed-role` y termina con el *nombre de sesión*, que permite saber quién o qué asumió el rol:

```bash
$ aws sts get-caller-identity
{
    "UserId": "AROA3XFRBF23EXAMPLE:ana",
    "Account": "222222222222",
    "Arn": "arn:aws:sts::222222222222:assumed-role/Desarrollador/ana"
}
```

== Usuarios IAM

#_concepto("Usuario IAM", "una identidad permanente dentro de una cuenta",
  [Una identidad con *credenciales de largo plazo* en una sola cuenta: contraseña para la consola y/o hasta dos access keys para la API.],
  [No es una persona de tu directorio corporativo: existe solo en la cuenta donde lo creas (para trabajar en otra, tendría que asumir un rol allí). Tampoco es el usuario root.],
  [Hoy, casos excepcionales: acceso de emergencia (_break-glass_), herramientas de terceros que no admiten roles ni federación, o cuentas aisladas sin Identity Center.],
  [El usuario `emergencia-admin`, con MFA en una llave física guardada en una caja fuerte, para cuando falla el proveedor de identidad corporativo.],
  [Un usuario compartido por varias personas, o access keys copiadas en el código, en un fichero `.env` o en un repositorio Git.])

En nuestro edificio, es un empleado con tarjeta permanente para *una* sede: si trabaja en diez, necesita diez tarjetas, y al irse hay que anular las diez. Sus credenciales:

#tabla(("Credencial", "Para qué sirve", "Lo que debes saber"), columnas: (1fr, 1.4fr, 2.3fr),
  [*Contraseña y MFA*], [Entrar en la consola], [Aplica una política de contraseñas y añade siempre MFA: app TOTP, llave FIDO2 o _passkey_ (hasta 8 dispositivos por usuario).],
  [*Access keys*], [Firmar peticiones desde la CLI, los SDK o la API], [Un ID (`AKIA…`) y una clave secreta. *No caducan*: si se filtran, cualquiera actúa como ese usuario hasta que las desactives. Máximo dos por usuario, para rotarlas.])

#cuidado(titulo: "Por qué evitar las access keys")[Acaban donde no deben —el código, una imagen de contenedor, un repositorio público— y hay bots que las rastrean y las usan en minutos (típicamente, para minar criptomonedas). Al final del capítulo verás la alternativa sin claves para cada caso; si aun así necesitas una, rótala y vigila su último uso (`aws iam get-access-key-last-used`).]

== Grupos IAM

#_concepto("Grupo IAM", "un conjunto de usuarios IAM que comparten permisos",
  [Una colección de usuarios IAM de una cuenta a la que adjuntas políticas; sus miembros heredan esos permisos.],
  [*No es un principal*: sin credenciales, no inicia sesión, no asume roles ni aparece como `Principal`. No contiene otros grupos ni es un grupo de Identity Center.],
  [Gestionar permisos por función en vez de usuario a usuario: altas, bajas y cambios de puesto son meter o sacar a alguien del grupo.],
  [El grupo `Auditores` con la política gestionada `SecurityAudit`: cuando llega un auditor nuevo, basta con añadirlo.],
  [Adjuntar políticas a cada usuario por separado, o intentar nombrar un grupo en la política de un bucket (no funciona: no es un principal).])

¿Y si un usuario está en varios grupos (hasta 10)? Sus permisos son la *unión* de lo que permiten sus políticas propias y las de todos sus grupos, salvo lo que prohíba explícitamente alguna: un `Deny` gana siempre. En el ejemplo, `ec2:*` significa «todas las acciones de EC2»:

#diagrama(pie: [Ana hereda los permisos de sus dos grupos, pero el Deny de su política propia anula una parte de lo que le da el grupo Desarrolladores.])[
  #fila(espacio: 6pt,
    zona("Grupo Desarrolladores", color: col.iam)[#caja([Allow ec2:\*], ancho: 3.9cm, color: _verde)],
    zona("Grupo Soporte", color: col.iam)[#caja([Allow support:\*], ancho: 3.9cm, color: _verde)],
    zona("Política propia de Ana", color: col.iam)[#caja([Deny ec2:TerminateInstances], ancho: 4.2cm, color: _rojo)])
  #v(2pt)
  #fila(espacio: 8pt, actor(etiqueta: "Ana", color: col.iam), flecha(etiqueta: "resultado", largo: 1.6cm),
    caja([*Permisos efectivos de Ana:* todo EC2 salvo terminar instancias, más todo AWS Support], ancho: 8.4cm, color: col.fundamentos))
]

== Roles IAM: identidades que se asumen

Los roles son la pieza más importante de IAM y la que más cuesta entender al principio. Nacen de un problema: una instancia EC2, una función Lambda, un pipeline o una persona que entra en otra cuenta necesitan permisos, pero no deberían guardar credenciales permanentes. La solución es una identidad que *no es de nadie*: un conjunto de permisos con una lista de quién puede usarlo. *Asumir* un rol es pedirle a AWS credenciales temporales que actúan como ese rol; mientras las usas, tienes los permisos del rol, no los tuyos.

#_concepto("Rol IAM", "una identidad sin credenciales propias que se «asume»",
  [Una identidad con permisos pero *sin contraseña ni access keys*; quien autorice su trust policy la asume y recibe credenciales temporales de STS.],
  [No es un usuario, no pertenece a una persona concreta y *no suma* permisos: mientras lo usas tienes los del rol, no los tuyos. No es un grupo.],
  [Dar permisos a servicios (EC2, Lambda, ECS), acceder a otras cuentas, federar identidades externas y elevar privilegios de forma puntual y auditada.],
  [El rol `app-web`, que asumen las instancias EC2 de la web para leer el bucket de imágenes.],
  [Confundir sus dos políticas, o crear un usuario con access keys para una aplicación que podría usar un rol.])

=== Las dos caras de un rol

Todo rol tiene dos políticas que responden a preguntas distintas. La *trust policy* (política de confianza) dice *quién puede asumirlo*: es una política de recurso —va pegada al propio rol, como la lista junto al mostrador— y por eso nombra a quién se aplica en su elemento `Principal`. La *permissions policy* (una o varias políticas de identidad) dice *qué puede hacer* quien lo asume.

#diagrama(pie: [La trust policy controla la entrada al rol; la permissions policy, lo que se puede hacer una vez dentro. A la izquierda, ejemplos de quién puede figurar en una trust policy.])[
  #fila(espacio: 5pt,
    zona("Trust policy", color: col.datos)[
      #text(7pt, fill: gris)[¿Quién puede asumirlo?]
      #v(1pt)
      #columna(espacio: 4pt,
        caja([*Un servicio* \ ec2.amazonaws.com], ancho: 3.4cm, color: col.datos),
        caja([*Otra cuenta* \ 111111111111], ancho: 3.4cm, color: col.datos),
        caja([*Identidades federadas* \ SAML u OIDC], ancho: 3.4cm, color: col.datos))
    ],
    flecha(etiqueta: "lo asume", largo: 1.4cm),
    svc("ROL", "Rol app-web", sub: "sin contraseña ni claves", color: col.iam),
    flecha(etiqueta: "puede", largo: 1.4cm),
    zona("Permissions policy", color: col.almacenamiento)[
      #text(7pt, fill: gris)[¿Qué puede hacer?]
      #v(1pt)
      #columna(espacio: 4pt,
        caja([Leer objetos del \ bucket fotos], ancho: 3.4cm, color: col.almacenamiento),
        caja([Escribir en la tabla \ DynamoDB pedidos], ancho: 3.4cm, color: col.almacenamiento),
        caja([Nada más \ (deny implícito)], ancho: 3.4cm, color: col.almacenamiento))
    ],
  )
]

Aún no hace falta que domines la sintaxis JSON, que es el tema del capítulo siguiente. Fíjate solo en que la trust policy nombra un `Principal` y la acción `sts:AssumeRole`, y la permissions policy, acciones y recursos:

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

#analogia(titulo: "En nuestro edificio")[El rol es la acreditación de «Mantenimiento» que espera en el mostrador. La trust policy es la lista pegada al lado: «pueden recogerla los técnicos de la contrata X». La permissions policy, las puertas que abre: el cuarto de calderas, no la sala de dirección. Y STS es el vigilante que comprueba la lista, te entrega la acreditación y anota su hora de caducidad.]

=== AssumeRole paso a paso

Asumir un rol es una conversación con STS. Los números de la figura corresponden a estos pasos:

#pasos(
  [El principal llama a `sts:AssumeRole` con el ARN del rol y un *nombre de sesión* que elige él.],
  [STS comprueba la *trust policy*: ¿confía en quien llama? ¿Se cumplen sus condiciones (MFA, External ID…)?],
  [Si todo encaja, STS devuelve *credenciales temporales*: `AccessKeyId` (empieza por `ASIA`), `SecretAccessKey`, `SessionToken` y `Expiration`.],
  [El principal firma sus peticiones con ellas. Para AWS ahora es la sesión `assumed-role/NombreDelRol/NombreDeSesion`.],
  [Cada petición se autoriza con la *permissions policy* del rol (y los límites que apliquen). Al caducar, se vuelve a asumir el rol; los SDK lo hacen solos.],
)

#diagrama(pie: [AssumeRole visto como una secuencia de mensajes. Las credenciales temporales sustituyen a cualquier clave permanente.])[
  #_secuencia(15cm, 6.05cm,
    ((1.7cm, "Principal (tu app)", col.computo), (7.3cm, "AWS STS", col.iam), (12.8cm, "Amazon S3", col.almacenamiento)),
    (
      (1.7cm, 7.3cm, 1.5cm, [1 · #_m("sts:AssumeRole") (ARN del rol, nombre de sesión)], false),
      (7.3cm, 7.3cm, 2.05cm, [2 · ¿La trust policy confía en quien llama? ¿Se cumplen sus condiciones?], false),
      (7.3cm, 1.7cm, 3.4cm, [3 · AccessKeyId (ASIA…), SecretAccessKey, SessionToken, Expiration], true),
      (1.7cm, 12.8cm, 4.3cm, [4 · #_m("s3:GetObject") firmado con las credenciales temporales], false),
      (12.8cm, 12.8cm, 4.85cm, [5 · IAM evalúa la permissions policy del rol], false),
      (12.8cm, 1.7cm, 5.7cm, [El objeto… o #_m("AccessDenied")], true),
    ))
]

¿Necesita quien llama un permiso propio para pedir el rol? Si ambos están en la misma cuenta y la trust policy lo nombra directamente a él, basta con ella. Si la trust policy confía en una cuenta entera (`…:root`) o el rol está en otra cuenta, la política de identidad de quien llama debe permitirle además `sts:AssumeRole` sobre ese rol: hacen falta los dos permisos, como verás en el capítulo siguiente.

En la CLI rara vez llamarás a `assume-role` a mano: basta con describir el rol en un perfil de `~/.aws/config` y la CLI lo asume (y renueva) por ti. Sin Identity Center, este es el patrón menos malo para tu portátil: un usuario IAM con MFA que solo puede asumir roles, nunca access keys de administrador en `~/.aws/credentials`. Escribe los comentarios en su propia línea: al final de un valor se leerían como parte de él.

```ini
# Con --profile prod, la CLI asume el rol usando las credenciales del perfil dev
[profile prod]
role_arn       = arn:aws:iam::222222222222:role/Despliegue
source_profile = dev
# Pide el código del dispositivo MFA de Ana
mfa_serial     = arn:aws:iam::111111111111:mfa/ana
```

=== Cuánto duran las sesiones y el encadenamiento de roles

Una sesión de `AssumeRole` dura *una hora* por defecto. Quien llama puede pedir entre 15 minutos y la duración máxima configurada en el rol (`MaxSessionDuration`), que puede llegar a 12 horas. Si con las credenciales de un rol asumes otro, haces *encadenamiento de roles* (_role chaining_): es legítimo —por ejemplo, desde una cuenta central de automatización—, pero esa segunda sesión dura como máximo una hora, se pida lo que se pida. *Error típico:* un proceso de varias horas basado en roles encadenados que falla al cabo de una hora con credenciales caducadas.

=== Roles para servicios: cómo llegan las credenciales a tu código

Cuando quien asume el rol es un servicio de AWS (EC2, Lambda, ECS…), el patrón es siempre el mismo:

#pasos(
  [*Creas el rol*: su trust policy confía en el servicio (`ec2.amazonaws.com`, `lambda.amazonaws.com`…) y su permissions policy da lo que necesita tu código.],
  [*Se lo entregas* al configurar el recurso (lanzar la instancia, crear la función). Para eso necesitas el permiso `iam:PassRole` sobre ese rol: sin esa barrera, quien pudiera crear una Lambda podría darle un rol de administrador y escalar privilegios a través de ella.],
  [*El servicio asume el rol por ti*, deja las credenciales temporales donde los SDK saben buscarlas y las renueva antes de que caduquen.],
  [*Tu código no contiene claves*: el SDK recorre su _cadena de proveedores de credenciales_ (variables de entorno, perfiles de `~/.aws`, endpoint del contenedor, servicio de metadatos…) y usa las primeras que encuentra.],
)

#tabla(("Quién", "Cómo recibe el rol", "Dónde encuentra el SDK las credenciales"), columnas: (1.15fr, 1.6fr, 2.45fr), tamano: 8.2pt,
  [*Instancia EC2*], [Un *perfil de instancia* (_instance profile_) con un único rol; la consola lo crea por ti], [En el servicio de metadatos (IMDS), siempre con IMDSv2 (capítulo de EC2)],
  [*Función Lambda*], [Su *rol de ejecución*], [En variables de entorno de la función (`AWS_ACCESS_KEY_ID`, `AWS_SESSION_TOKEN`…)],
  [*Tarea de ECS*], [Su _task role_ (el agente usa el _task execution role_)], [En un endpoint de credenciales de la tarea (capítulo de Contenedores)],
  [*Pod de EKS*], [EKS Pod Identity o IRSA], [Del agente de Pod Identity o canjeando el token del pod (capítulo de Kubernetes y Amazon EKS)],
  [*CodePipeline, CodeBuild*], [Su *rol de servicio*], [El servicio lo asume en cada ejecución; para desplegar en otra cuenta, asume allí un rol (capítulo de Infraestructura como código y DevOps)],
  [*GitHub Actions u otro CI*], [Federación OIDC (escenario 5)], [Canjea el token OIDC del job con `AssumeRoleWithWebIdentity`],
  [*Servidor fuera de AWS*], [IAM Roles Anywhere], [Canjea un certificado X.509 de tu PKI por credenciales temporales])

=== Roles de servicio y roles vinculados a servicios

#tabla(("", "Rol de servicio", "Rol vinculado a un servicio"), columnas: (1fr, 2fr, 2fr),
  [*Qué es*], [Un rol normal que creas tú para que un servicio actúe en tu nombre], [Un rol predefinido que crea y gestiona el propio servicio],
  [*Ejemplos*], [Rol de ejecución de una Lambda, _task role_ de ECS, rol de una instancia EC2], [`AWSServiceRoleForAutoScaling`, `AWSServiceRoleForECS`],
  [*Permisos*], [Los decides tú; su trust policy nombra al servicio (`lambda.amazonaws.com`)], [Los define AWS y no puedes editarlos; las SCP no lo restringen],
  [*Borrado*], [Cuando quieras], [Solo cuando el servicio ya no lo usa])

=== Terceros y el External ID: el problema del «confused deputy»

Muchos proveedores (herramientas de costes, de seguridad, de monitorización) acceden a tu cuenta asumiendo un rol que tú creas y que confía en *su* cuenta. El riesgo se llama *confused deputy* (el «ayudante confundido»): un cliente malicioso del mismo proveedor le da *el ARN de tu rol* como si fuera el suyo, y el proveedor, que sí tiene permiso para asumirlo, acaba trabajando con tu cuenta en nombre del atacante.

#diagrama(pie: [Sin External ID, el proveedor podría asumir tu rol por encargo de otro cliente. Con él, tu trust policy solo acepta el identificador que el proveedor generó para ti, y la petición hecha por encargo del atacante llega con el suyo.])[
  #fila(espacio: 5pt,
    zona("Atacante", color: _rojo, ancho: 3.3cm)[#actor(etiqueta: "Otro cliente", color: _rojo)],
    flecha(etiqueta: "1 · le da tu ARN", largo: 2cm, color: _rojo),
    zona("Proveedor SaaS", color: col.neutro, ancho: 3.3cm)[#svc("SaaS", "Servicio de auditoría", sub: "cuenta 999999999999", color: col.neutro)],
    columna(espacio: 0pt, flecha(etiqueta: "2 · AssumeRole", largo: 2.6cm),
      box(width: 2.6cm, align(center, text(6.2pt, fill: gris)[con el External ID \ del atacante]))),
    zona("Tu cuenta", color: col.iam, ancho: 3.3cm)[#columna(svc("ROL", "Rol auditor-saas", sub: "exige tu External ID", color: col.iam), text(8.5pt, weight: "bold", fill: _rojo)[#no denegado])],
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

#nota[En `Principal`, `arn:aws:iam::999999999999:root` significa «la cuenta 999999999999», no su usuario root: delegas en esa cuenta y sus administradores deciden quién puede asumir tu rol.]

== IAM Identity Center y los permission sets

Las organizaciones bien gestionadas separan producción, desarrollo o cada equipo en *cuentas distintas*, la frontera de aislamiento más fuerte de AWS. Las agrupan con *AWS Organizations* bajo una *cuenta de administración* (_management account_), que paga la factura y fija normas comunes (lo verás en el capítulo siguiente). Con veinte cuentas, dar a cada persona un usuario IAM en cada una significa veinte contraseñas, veinte juegos de claves permanentes y veinte bajas cuando alguien se va.

*IAM Identity Center* (antes AWS Single Sign-On) resuelve este problema: es la forma recomendada de dar acceso a las *personas* de tu organización a todas tus cuentas AWS (y a aplicaciones). Cada persona tiene una única identidad, con MFA, y desde un *portal de acceso* elige a qué cuenta entrar y con qué perfil, siempre con credenciales temporales. Se habilita en la cuenta de administración de la organización, y su gestión puede delegarse en una cuenta miembro. Sus piezas:

/ Fuente de identidad: dónde viven las personas: el directorio propio de Identity Center, un Active Directory o un IdP externo como Microsoft Entra ID, Okta o Google Workspace, conectado por SAML 2.0 y con *SCIM* para sincronizar usuarios y grupos automáticamente. Solo puede haber una a la vez.
/ Usuarios y grupos: las personas y sus agrupaciones (normalmente los mismos grupos que ya tienes en tu directorio corporativo).
/ Permission sets: plantillas de permisos que defines una vez.
/ Asignaciones: la combinación *quién + qué + dónde*: un usuario o grupo, un permission set y una cuenta AWS. Sin asignación, un permission set no concede nada.
/ Portal de acceso: la web (`https://d-xxxxxxxxxx.awsapps.com/start` o un alias propio) donde cada persona ve las cuentas y perfiles que tiene asignados.

#_concepto("Usuario / grupo de Identity Center", "las personas de tu organización",
  [Una persona del almacén de identidades de Identity Center (creada allí o sincronizada desde tu IdP), y los grupos que las reúnen para asignarles acceso.],
  [No es un usuario IAM: no existe en ninguna cuenta, no tiene access keys permanentes ni le adjuntas políticas de IAM. Sus grupos *no* son grupos de IAM.],
  [Dar a cada empleado una única identidad con la que entra, con MFA, en todas las cuentas y aplicaciones que se le asignen.],
  [Ana entra en el portal con su cuenta corporativa de Microsoft Entra ID y ve las cuentas `dev` y `prod`.],
  [Crear además un usuario IAM para la misma persona «por si acaso», o dar de alta personas a mano cuando tu IdP puede sincronizarlas por SCIM.])

Como los nombres se parecen tanto, conviene poner frente a frente las dos familias de usuarios y grupos:

#tabla(("", "Usuarios y grupos IAM", "Usuarios y grupos de Identity Center"), columnas: (1fr, 2fr, 2fr),
  [*Dónde viven*], [Dentro de una cuenta AWS concreta], [En Identity Center (creados allí o sincronizados desde tu IdP por SCIM)],
  [*Credenciales*], [Permanentes: contraseña y access keys], [Ninguna permanente en AWS: tras iniciar sesión, las temporales del rol de cada cuenta],
  [*Cómo reciben permisos*], [Políticas de IAM adjuntas al usuario o a sus grupos], [Asignaciones: usuario o grupo + permission set + cuenta],
  [*Alcance*], [Una sola cuenta], [Todas las cuentas de la organización que asignes],
  [*Altas y bajas*], [Cuenta por cuenta], [Una vez, en tu directorio corporativo])

#_concepto("Permission set", "una plantilla de permisos para muchas cuentas",
  [Una plantilla definida en Identity Center con políticas gestionadas (de AWS o tuyas), una política inline opcional, un permissions boundary opcional y la duración de la sesión (de 1 a 12 horas).],
  [No es un rol ni una política que se adjunte: por sí mismo no concede nada hasta que lo *asignas* a una cuenta. No es un principal.],
  [Definir perfiles —«Desarrollador», «SoloLectura», «Administrador»— una sola vez y desplegarlos en tantas cuentas como necesites.],
  [`PowerUser` = política gestionada `PowerUserAccess` + sesión de 8 horas, asignado al grupo `Developers` en las cuentas `dev` y `test`.],
  [Tocar a mano el rol que genera en cada cuenta (lo gestiona Identity Center), o usar una política propia que no existe con ese nombre en alguna cuenta asignada.])

=== Qué pasa por debajo cuando entras por el portal

Aquí está la pieza que lo conecta todo. Cuando asignas un permission set a una cuenta, Identity Center crea en esa cuenta un *rol IAM* llamado `AWSReservedSSO_<PermissionSet>_<sufijo>`, con las políticas del permission set, y un proveedor SAML (`AWSSSO_…_DO_NOT_DELETE`, uno por cuenta), que es el único en el que confía la trust policy del rol: ese rol solo puede asumirse a través de Identity Center. Hay *un rol por permission set y cuenta*, no por persona: si cincuenta personas tienen `PowerUser` en dev, todas asumen el mismo rol y CloudTrail las distingue por el nombre de sesión. Si cambias el permission set, Identity Center actualiza el rol en todas las cuentas asignadas.

#diagrama(pie: [De la persona al recurso. Ana pertenece al grupo Developers, que tiene asignado el permission set PowerUser en la cuenta dev. Al hacer la asignación, Identity Center creó en esa cuenta un proveedor SAML y el rol AWSReservedSSO\_PowerUser\_…, que solo confía en ese proveedor.])[
  #columna(espacio: 0pt, zona("IAM Identity Center", color: col.iam, punteada: false, relleno: white)[
    #fila(espacio: 4pt,
      actor(etiqueta: "Ana", color: col.iam),
      flecha(etiqueta: "miembro de", largo: 1.6cm),
      caja([*Grupo* \ Developers], ancho: 2.4cm, color: col.iam),
      flecha(etiqueta: "asignación", largo: 1.6cm),
      caja([*Permission set* \ PowerUser en la cuenta dev], ancho: 3.9cm, color: col.iam),
    )
  ],
  flecha-v(etiqueta: [crea en la cuenta el proveedor y el rol; Ana asume el rol desde el portal], largo: 1cm),
  zona("Cuenta dev · 222222222222", color: col.fundamentos, punteada: false, relleno: white)[
    #fila(espacio: 4pt,
      caja([*Proveedor SAML* \ AWSSSO\_…\_DO\_NOT\_DELETE], ancho: 3.6cm, color: col.fundamentos),
      flecha(etiqueta: "puede asumir", largo: 1.6cm),
      caja([*Rol IAM* \ AWSReservedSSO\_PowerUser\_…], ancho: 4.8cm, color: col.fundamentos),
      flecha(etiqueta: "credenciales", largo: 1.8cm),
      svc("S3", "Bucket de la cuenta dev", color: col.almacenamiento),
    )
  ])
]

Así es una jornada de Ana:

#pasos(
  [Abre el portal de acceso y se autentica en la fuente de identidad (su IdP corporativo), con MFA. Empieza su *sesión del portal*.],
  [El portal le muestra las cuentas y permission sets que tiene asignados, directamente o a través de sus grupos.],
  [Elige «dev → PowerUser». Mediante una federación SAML (`AssumeRoleWithSAML`) con el proveedor que creó en la cuenta dev, Identity Center le consigue credenciales temporales del rol `AWSReservedSSO_PowerUser_…`, y la consola se abre en esa cuenta.],
  [Trabaja como la sesión `assumed-role/AWSReservedSSO_PowerUser_…/ana`, con los permisos del permission set. Esas credenciales caducan según la duración de sesión del permission set; mientras siga abierta su sesión del portal, obtiene otras sin volver a autenticarse.],
)

En la CLI ocurre lo mismo. La configuración se hace una vez con `aws configure sso`, que crea un perfil como este; después, cada día, `aws sso login --profile dev-poweruser` abre el navegador para autenticarte y guarda un token en caché (`~/.aws/sso/cache`). Con él, la CLI pide al portal las credenciales temporales del rol de esa cuenta y las renueva sola:

```ini
[profile dev-poweruser]
sso_session    = empresa
sso_account_id = 222222222222
# El nombre del permission set
sso_role_name  = PowerUser

[sso-session empresa]
sso_start_url           = https://d-1234567890.awsapps.com/start
sso_region              = eu-west-1
sso_registration_scopes = sso:account:access
```

#analogia(titulo: "En nuestro edificio")[Identity Center es el RR. HH. central de la empresa: da de alta a Ana una sola vez y decide en qué sedes trabaja. El permission set es el modelo de acreditación «Desarrollador»; la asignación, la orden «Ana puede recoger esa acreditación en la sede dev». Con esa orden, RR. HH. deja en el mostrador de la sede dev una acreditación concreta —el rol `AWSReservedSSO_…`—, y Ana la recoge cada mañana desde el portal.]

== Otras formas de federación

La *federación* consiste en que AWS confíe en un proveedor de identidad externo: las identidades viven fuera y, tras autenticarse allí, reciben credenciales temporales de AWS asumiendo un rol. El IdP se lo comunica a AWS con un protocolo estándar: *SAML 2.0* (aserciones en XML, típico de los directorios corporativos) u *OIDC* (_OpenID Connect_, tokens JSON firmados llamados JWT, típico de plataformas como GitHub o Kubernetes). Identity Center es la federación recomendada para empleados, pero hay otros casos:

#tabla(("Mecanismo", "Para quién", "Cómo obtiene las credenciales"), columnas: (1.3fr, 1.5fr, 2.2fr),
  [*IAM Identity Center*], [Empleados, en muchas cuentas], [Portal o CLI → asume el rol `AWSReservedSSO_…` de cada cuenta],
  [*SAML 2.0 directo con IAM*], [Empleados en una cuenta (opción heredada)], [Aserción SAML del IdP → `AssumeRoleWithSAML`],
  [*Proveedor OIDC en IAM*], [Cargas externas: GitHub Actions, GitLab, Kubernetes…], [Token OIDC (JWT) → `AssumeRoleWithWebIdentity`],
  [*Amazon Cognito*], [Usuarios finales de tus aplicaciones], [Un _user pool_ autentica; un _identity pool_ canjea el token por credenciales de un rol limitado],
  [*IAM Roles Anywhere*], [Servidores y cargas fuera de AWS], [Un certificado X.509 de tu PKI de confianza → credenciales temporales de un rol])

== Todas las piezas de un vistazo

Qué es cada pieza, cuándo usarla y con qué se confunde más a menudo:

#tabla(("Pieza", "Qué es", "Credenciales", "Úsala para…", "No la confundas con…"),
  columnas: (1.05fr, 1.8fr, 1.3fr, 1.3fr, 1.75fr), tamano: 7.8pt,
  [*Usuario IAM*], [Identidad permanente de una persona o app, en una sola cuenta], [Permanentes: contraseña y access keys (`AKIA…`)], [Solo excepciones: emergencia, herramientas sin roles], [Un usuario de Identity Center: fuera de las cuentas y sin claves permanentes],
  [*Grupo IAM*], [Conjunto de usuarios IAM de una cuenta; no firma peticiones], [Ninguna], [Repartir políticas entre usuarios IAM], [Un grupo de Identity Center, que recibe asignaciones en muchas cuentas],
  [*Rol IAM*], [Identidad sin credenciales propias que se asume; actúa mediante sesiones], [Temporales (`ASIA…`), para quien lo asume], [Servicios, otras cuentas, federación], [Un usuario: el rol no es de nadie y sus credenciales caducan],
  [*Trust policy*], [La política de recurso de un rol: quién puede asumirlo], [—], [Todo rol tiene una], [La permissions policy: qué puede hacer quien lo asume],
  [*Usuario de Identity Center*], [Una persona de tu organización, con una sola identidad para todo], [Ninguna propia: las temporales del rol de cada cuenta], [Acceso de personas a todas las cuentas], [Un usuario IAM (ver arriba)],
  [*Grupo de Identity Center*], [Conjunto de usuarios de Identity Center, a menudo sincronizado desde tu IdP], [Ninguna], [Asignar permission sets por equipos], [Un grupo IAM (ver arriba)],
  [*Permission set*], [Plantilla de permisos de Identity Center; no concede nada hasta que se asigna], [Ninguna], [Definir perfiles una vez para muchas cuentas], [El rol `AWSReservedSSO_…` que crea en cada cuenta asignada: el que se asume])

== Preguntas frecuentes

#grid(columns: (1fr, 1fr), column-gutter: 14pt,
  [
    #_faq([¿Un grupo puede asumir un rol o aparecer como `Principal`?], [No: no es un principal. Para que sus miembros asuman un rol, adjunta al grupo una política que permita `sts:AssumeRole` sobre él y haz que la trust policy confíe en la cuenta.])
    #_faq([¿Necesito AWS Organizations para usar Identity Center?], [Para dar acceso a cuentas AWS, sí: se habilita en la cuenta de administración de la organización. Sin Organizations solo puede dar acceso a aplicaciones.])
  ],
  [
    #_faq([¿Por qué el portal no me pide la contraseña cada hora?], [Hay dos relojes: la sesión del portal (por defecto, 8 horas) y las credenciales de cada rol (la duración del permission set). Mientras la primera siga abierta, obtienes credenciales nuevas sin volver a autenticarte.])
    #_faq([¿Cómo nombro el rol de un permission set en una política de recurso?], [Su ARN lleva una ruta (`…/aws-reserved/sso.amazonaws.com/…`) y un sufijo aleatorio que cambia si se recrea: en vez de copiarlo, usa la condición `aws:PrincipalArn` con comodines (capítulo siguiente).])
  ],
)

== ¿Qué uso cuando…? Ocho escenarios resueltos

#_escenario(1, [Una persona de tu empresa entra en la consola], "IAM Identity Center")[
  #_mini(fila(espacio: 4pt,
    actor(etiqueta: "Empleada", color: col.iam),
    flecha(etiqueta: "login + MFA", largo: 1.5cm),
    svc("IdP", "Entra ID, Okta…", sub: "fuente de identidad", color: col.neutro),
    flecha(etiqueta: "SAML", largo: 1.3cm),
    svc("IIC", "IAM Identity Center", sub: "portal de acceso", color: col.iam),
    flecha(etiqueta: "asume", largo: 1.3cm),
    caja([Rol AWSReservedSSO\_… \ de la cuenta elegida], ancho: 3.3cm, color: col.fundamentos)))
  Personas y grupos en Identity Center (sincronizados por SCIM), permission sets y asignaciones a *grupos*. *Evita:* un usuario IAM por persona y por cuenta.
]

#_escenario(2, [Una aplicación en EC2 lee objetos de S3], "Rol + perfil de instancia")[
  #_mini(fila(espacio: 4pt,
    svc("ROL", "Rol app-web", sub: "trust: ec2.amazonaws.com", color: col.iam),
    flecha(etiqueta: "perfil de instancia", largo: 2cm),
    svc("EC2", "Instancia", sub: "el SDK lee IMDSv2", color: col.computo),
    flecha(etiqueta: "GetObject firmado", largo: 2cm),
    svc("S3", "Bucket fotos", color: col.almacenamiento)))
  El rol permite `s3:GetObject` sobre `arn:aws:s3:::fotos/*` y el código no contiene claves: el SDK las encuentra solo. *Evita:* access keys en la instancia, en variables de entorno o en la AMI.
]

#_escenario(3, [Una función Lambda escribe en DynamoDB], "Rol de ejecución")[
  #_mini(fila(espacio: 4pt,
    svc("ROL", "Rol de ejecución", sub: "trust: lambda.amazonaws.com", color: col.iam),
    flecha(etiqueta: "lo asume Lambda", largo: 2cm),
    svc("λ", "Función alta-pedido", color: col.serverless),
    flecha(etiqueta: "PutItem", largo: 1.6cm),
    svc("DDB", "Tabla pedidos", color: col.datos)))
  El rol de ejecución lleva `dynamodb:PutItem` sobre la tabla y permisos para escribir logs; Lambda lo asume y pasa las credenciales a tu código en variables de entorno. Quién puede *invocar* la función lo decide otra cosa: su política de recurso (capítulo de Serverless).
]

#_escenario(4, [Una tarea de ECS lee un secreto de Secrets Manager], "Task role / execution role")[
  #_mini(fila(espacio: 4pt,
    svc("ROL", "Task execution role", sub: "agente: ECR, logs, secretos", color: col.iam),
    text(12pt, weight: "bold", fill: gris)[+],
    svc("ROL", "Task role", sub: "tu código (SDK)", color: col.iam),
    flecha(largo: 1.2cm),
    svc("ECS", "Tarea ECS", color: col.contenedores),
    flecha(etiqueta: "GetSecretValue", largo: 2cm),
    svc("SM", "Secrets Manager", color: col.seguridad)))
  Una tarea tiene *dos* roles: el _execution role_, con el que ECS la prepara (imagen, logs y secretos que se inyectan como variables de entorno), y el _task role_, el de tu código. Si tu código pide el secreto con el SDK, el permiso va en el task role; si se inyecta desde la definición de tarea, en el execution role. Los detalles, en el capítulo de Contenedores.
]

#_escenario(5, [GitHub Actions despliega en AWS sin access keys], "Federación OIDC")[
  #_mini(fila(espacio: 4pt,
    svc("GH", "GitHub Actions", sub: "permiso id-token: write", color: col.neutro),
    columna(espacio: 0pt,
      flecha(etiqueta: "1 · token OIDC (JWT)", largo: 2.5cm),
      _flecha-izq(etiqueta: "3 · credenciales del rol", largo: 2.5cm)),
    svc("STS", "AWS STS", sub: "AssumeRoleWithWebIdentity", color: col.iam),
    flecha(etiqueta: "2 · ¿lo admite su trust policy?", largo: 2.9cm, punteada: true),
    svc("ROL", "Rol github-deploy", sub: "solo tu repositorio y rama", color: col.iam)))
  Registra en IAM el proveedor OIDC `token.actions.githubusercontent.com` y crea un rol que acepte solo los tokens de *tu* repositorio y rama: sin la condición sobre `sub`, cualquier repositorio de GitHub podría asumirlo.

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Federated":
      "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"},
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"},
      "StringLike": {
        "token.actions.githubusercontent.com:sub": "repo:org/web:ref:refs/heads/main"}
    }
  }]
}
```

  En el workflow, el job declara el permiso para pedir el token y asume el rol:

```yaml
permissions:
  id-token: write        # permite al job pedir el token OIDC
steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::123456789012:role/github-deploy
      aws-region: eu-west-1
  - run: aws s3 sync ./dist s3://mi-web-estatica
```
]

#_escenario(6, [La cuenta A lee un bucket de la cuenta B], "Política de recurso o rol en B")[
  #_mini(fila(espacio: 4pt,
      zona("Cuenta A", color: col.iam)[#svc("ROL", "Rol analitica", sub: "puede sts:AssumeRole sobre lector-b", color: col.iam)],
      flecha(etiqueta: "AssumeRole", largo: 1.6cm),
      zona("Cuenta B · 222222222222", color: col.fundamentos)[#fila(espacio: 4pt,
        svc("ROL", "Rol lector-b", sub: "trust: cuenta A", color: col.iam),
        flecha(etiqueta: "GetObject", largo: 1.4cm),
        svc("S3", "Bucket datos-b", color: col.almacenamiento))]))
  Hay dos caminos. *Con un rol en B* (el del diagrama): A asume `lector-b` y trabaja «dentro» de B, sin sus propios permisos durante la sesión; útil si hay que tocar muchos recursos. *Con una política de recurso*: la política del bucket permite el acceso al rol de A y la política de identidad de ese rol permite `s3:GetObject` sobre el bucket; entre cuentas hacen falta *los dos permisos* (lo verás con detalle en el capítulo siguiente).
]

#_escenario(7, [Un proveedor SaaS externo audita tu cuenta], "Rol con External ID")[
  Un rol cuya trust policy confía en la cuenta del proveedor *y* exige el External ID que te ha dado (sección del _confused deputy_), con solo los permisos necesarios, como la política gestionada `SecurityAudit`. Entregas al proveedor el ARN del rol, nunca access keys, y revocas el acceso cuando quieras borrando el rol o cambiando su trust policy.
]

#_escenario(8, [Los usuarios finales de tu app móvil], "Amazon Cognito")[
  #_mini(fila(espacio: 4pt,
    actor(etiqueta: "Cliente de la app", color: col.neutro),
    flecha(etiqueta: "registro y login", largo: 1.8cm),
    svc("UP", "Cognito user pool", sub: "emite tokens JWT", color: col.iam),
    flecha(etiqueta: "token", largo: 1.3cm),
    svc("IDP", "Cognito identity pool", sub: "canjea el token", color: col.iam),
    flecha(etiqueta: "rol limitado", largo: 1.6cm),
    svc("S3", "Su carpeta en S3", color: col.almacenamiento)))
  Tus clientes no son empleados: ni IAM ni Identity Center. Un *user pool* de Cognito gestiona registro, inicio de sesión y MFA; si la app debe llamar directamente a AWS, un *identity pool* canjea el token por credenciales temporales de un rol muy limitado. A menudo basta con que tu API valide el token.
]

#resumen[
- Toda petición recorre cuatro pasos: identidad → credenciales → políticas → recurso. Los grupos y los permission sets no hacen peticiones: reparten políticas.
- Un principal es quien firma una petición: un usuario, una sesión de rol, el root o un servicio. Los grupos nunca firman nada; los roles, a través de sus sesiones.
- Los usuarios IAM tienen credenciales permanentes (contraseña, access keys `AKIA…`): resérvalos para casos excepcionales.
- Un rol no tiene credenciales propias: su trust policy dice quién puede asumirlo y su permissions policy, qué puede hacer. STS entrega credenciales temporales (`ASIA…` + token + caducidad).
- Los servicios asumen su rol por ti (perfil de instancia en EC2, rol de ejecución en Lambda, task role en ECS) y dejan las credenciales donde el SDK las busca; entregar un rol exige `iam:PassRole`. El External ID protege los roles para terceros.
- IAM Identity Center da a cada persona una identidad única. Una asignación (usuario o grupo + permission set + cuenta) crea en esa cuenta un rol `AWSReservedSSO_…`, uno por permission set y cuenta, que la persona asume desde el portal o con `aws sso login`.
- Federación: SAML con los IdP corporativos, OIDC con cargas externas como GitHub Actions, IAM Roles Anywhere para servidores fuera de AWS y Amazon Cognito para los clientes de tus apps.
]

#repaso(
  ([¿Por qué un grupo IAM no puede aparecer como `Principal` en la política de un bucket?], [Porque no es un principal: no se autentica ni firma peticiones. Solo sirve para adjuntar políticas a sus usuarios.]),
  ([¿Qué dos políticas tiene un rol y qué pregunta responde cada una?], [La trust policy (¿quién puede asumirlo?) y la permissions policy (¿qué puede hacer quien lo asume?).]),
  ([Tu equipo copia access keys en un servidor EC2 para que la aplicación lea de S3. ¿Qué propones?], [Un rol con lectura sobre ese bucket, entregado con un perfil de instancia; el SDK toma credenciales temporales del IMDS y las claves desaparecen.]),
  ([¿Cómo obtiene sus permisos una función Lambda y dónde los encuentra su código?], [Lambda asume el rol de ejecución de la función y le pasa las credenciales temporales en variables de entorno; el SDK las encuentra solo, sin claves en el código.]),
  ([Ana tiene asignado el permission set `ReadOnly` en las cuentas `dev` y `prod`, y Luis, el mismo en `dev`. ¿Cuántos roles ha creado Identity Center?], [Dos, uno por cuenta (`AWSReservedSSO_ReadOnly_<sufijo>`): hay un rol por permission set y cuenta, no por persona. Ana y Luis asumen el mismo rol en `dev` y CloudTrail los distingue por el nombre de sesión.]),
  ([¿Qué ocurre por debajo cuando Ana elige «dev → PowerUser» en el portal?], [Identity Center le obtiene credenciales temporales del rol `AWSReservedSSO_PowerUser_…` que creó en la cuenta dev, mediante una federación SAML con el proveedor que también creó allí. Ana trabaja como la sesión `assumed-role/AWSReservedSSO_PowerUser_…/ana`, con los permisos del permission set, hasta que caducan.]),
  ([Un workflow de GitHub Actions debe desplegar en tu cuenta. ¿Cómo se autentica sin guardar access keys?], [Con federación OIDC: registras en IAM el proveedor `token.actions.githubusercontent.com` y creas un rol cuya trust policy solo acepta los tokens de tu repositorio y rama (condición sobre `sub`). El job lo asume con `AssumeRoleWithWebIdentity`.]),
)
