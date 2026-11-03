#import "../theme.typ": *

// ---------------------------------------------------------------------
//  Utilidades locales de este capítulo
// ---------------------------------------------------------------------
#let _m(s, size: 7.4pt) = text(font: "JetBrains Mono", ligatures: false, features: (calt: 0), size: size, s)

// Flecha horizontal hacia la izquierda (etiqueta debajo), para flujos de vuelta
#let _izq(etiqueta: none, largo: 1.4cm, color: rgb("#7A8699")) = box(width: largo, height: 2.6em, {
  place(right + horizon, line(length: largo - 5pt, stroke: 1.2pt + color))
  place(left + horizon, polygon(fill: color, (7pt, 0pt), (0pt, 3.5pt), (7pt, 7pt)))
  if etiqueta != none {
    place(center + bottom, dy: 1pt, box(width: largo + 0.8cm, align(center, {
      set par(justify: false, leading: 0.3em)
      text(6.4pt, fill: color.darken(25%), weight: "medium", etiqueta)
    })))
  }
})

// =====================================================================

#capitulo(text(hyphenate: false)[CloudFront, Route 53 y el borde de la red], color: col.edge,
  subtitulo: [Acerca tu contenido a usuarios de todo el mundo: caché global, seguridad en el borde, código en las edge locations y un DNS gestionado y programable.],
  objetivos: (
    [Entender qué aporta una CDN y cómo funciona la caché de CloudFront],
    [Configurar orígenes, cache behaviors y políticas de caché],
    [Servir un bucket S3 privado con Origin Access Control y HTTPS],
    [Elegir entre CloudFront Functions y Lambda\@Edge],
    [Gestionar zonas, registros y políticas de enrutamiento en Route 53],
    [Distinguir cuándo usar CloudFront y cuándo Global Accelerator],
  ),
  servicios: ("Amazon CloudFront", "Amazon Route 53", "AWS Certificate Manager", "AWS WAF", "AWS Shield", "CloudFront Functions", "Lambda@Edge", "AWS Global Accelerator"))

== ¿Por qué una CDN?

Si tu aplicación vive en `eu-west-1` (Irlanda), un usuario de Madrid la tiene cerca, pero uno de Sídney o de São Paulo paga cientos de milisegundos de latencia en cada ida y vuelta, multiplicados por cada imagen, script o llamada a la API. Una *CDN* (_Content Delivery Network_) resuelve el problema guardando copias del contenido en servidores repartidos por el mundo, cerca de los usuarios. *Amazon CloudFront* es la CDN de AWS y aporta tres cosas:

#tarjetas(columnas: 3,
  tarjeta("Menos latencia", subtitulo: "El contenido, cerca del usuario")[Responde el punto de presencia más cercano; el TLS termina allí y el resto del camino va por la red troncal de AWS.],
  tarjeta("Menos carga en el origen", subtitulo: "Cada acierto, una petición menos")[Cada acierto de caché (_cache hit_) es una petición que tu servidor no procesa: menos coste y más resistencia a los picos.],
  tarjeta("Más seguridad", subtitulo: "El borde como escudo")[Absorbe ataques DDoS (Shield Standard incluido), filtra con AWS WAF y oculta el origen.],
)

La red de CloudFront tiene más de 700 puntos de presencia en más de 50 países. La mayoría son *edge locations*, que atienden a los usuarios; por detrás hay una capa de *Regional Edge Caches* (REC), cachés más grandes compartidas por varias edge locations. Si un objeto cacheable no está en la edge location (_miss_), CloudFront lo busca en su REC y solo si tampoco está allí acude al origen; así, incluso el contenido poco popular se beneficia de la caché. Opcionalmente, *Origin Shield* añade una capa más, centralizada en una región, para reducir todavía más las peticiones al origen.

#diagrama(pie: [Una petición a través de CloudFront: si la edge location tiene el objeto, responde al instante; si no, lo pide a la Regional Edge Cache y, en último término, al origen.])[
  #fila(espacio: 4pt,
    grid(columns: 3, column-gutter: 4pt, row-gutter: 10pt, align: center + horizon,
      actor(etiqueta: "Madrid"), flecha(largo: 1cm), svc("PoP", "Edge location", sub: "MAD", color: col.edge),
      actor(etiqueta: "Lisboa"), flecha(largo: 1cm), svc("PoP", "Edge location", sub: "LIS", color: col.edge),
    ),
    flecha(etiqueta: "miss", largo: 1.3cm),
    svc("REC", "Caché regional", sub: "Regional Edge Cache", color: col.edge),
    flecha(etiqueta: "miss", largo: 1.3cm),
    zona("Origen", color: col.almacenamiento)[#columna(espacio: 4pt,
      svc("S3", "Bucket", color: col.almacenamiento),
      svc("ALB", "API", color: col.balanceo))],
  )
]

== Distribuciones, orígenes y cache behaviors

#ficha("Amazon CloudFront", "Red de distribución de contenidos (CDN) global de AWS",
  ("Ámbito", [Global: una distribución se despliega en toda la red (o en parte, según la _price class_)]),
  ("Protocolos", [HTTP/1.1, HTTP/2 y HTTP/3; IPv4 e IPv6; WebSocket]),
  ("Contenido", [Estático (imágenes, JS, vídeo) y dinámico (APIs, HTML personalizado)]),
  ("Coste", [Por GB servido a los usuarios (varía por zona geográfica) y por peticiones; la transferencia desde orígenes de AWS hasta CloudFront es gratuita]))

La unidad de configuración es la *distribución*: recibe un dominio como `d111111abcdef8.cloudfront.net`, al que puedes añadir tus propios nombres (_alternate domain names_, como `www.ejemplo.com`) con su certificado TLS. Cada distribución tiene uno o varios *orígenes*, de donde CloudFront obtiene el contenido:

- Un *bucket S3* (endpoint REST), protegido con Origin Access Control; o el endpoint de *sitio web estático* de S3, que se trata como origen HTTP personalizado.
- Un *Application Load Balancer*, instancias EC2 o cualquier servidor HTTP (_custom origin_). Con los *VPC origins* (2024), el ALB, el NLB o las instancias pueden estar en subredes privadas, accesibles solo desde CloudFront.
- *API Gateway* y *Lambda function URLs* (estas, también con OAC).

Un *origin group* combina un origen primario y uno secundario: si el primario devuelve ciertos códigos de error (por ejemplo, 500, 502, 503 o 504) o no responde, CloudFront reintenta la petición en el secundario. Funciona con peticiones GET, HEAD y OPTIONS.

Los *cache behaviors* deciden qué hacer con cada petición. Cada uno asocia un patrón de ruta (_path pattern_) con un origen y sus ajustes: protocolos y métodos HTTP permitidos, políticas de caché, compresión, funciones de borde o la obligación de usar URLs firmadas. CloudFront los evalúa en orden y aplica el primero que coincide; el comportamiento por defecto (`*`) recoge el resto.

#diagrama(pie: [Una distribución con tres cache behaviors: cada patrón de ruta va a su origen, con su propia política de caché.])[
  #fila(espacio: 4pt,
    actor(etiqueta: "Usuario"),
    flecha(etiqueta: "HTTPS", largo: 1.2cm),
    svc("CF", "Distribución", sub: "www.ejemplo.com", color: col.edge),
    columna(espacio: 4pt,
      fila(espacio: 4pt, flecha(etiqueta: "/api/*", largo: 2.2cm),
        svc("ALB", "API", sub: "CachingDisabled", color: col.balanceo)),
      fila(espacio: 4pt, flecha(etiqueta: "/img/*", largo: 2.2cm),
        svc("S3", "Imágenes", sub: "CachingOptimized", color: col.almacenamiento)),
      fila(espacio: 4pt, flecha(etiqueta: "* (por defecto)", largo: 2.2cm),
        svc("S3", "Sitio web", sub: "CachingOptimized", color: col.almacenamiento)),
    ),
  )
]

== La caché: cache key, políticas y TTL

Cuando llega una petición, CloudFront calcula su *cache key* (clave de caché) y busca ese objeto. Por defecto, la clave es el dominio más la ruta; puedes añadir cadenas de consulta (_query strings_), cabeceras y cookies. La regla de oro: incluye solo lo que cambia la respuesta. Cada valor extra fragmenta la caché —una cookie de sesión en la clave significa una copia por usuario— y hunde la tasa de aciertos (_cache hit ratio_). La configuración se reparte en tres políticas reutilizables:

#tarjetas(columnas: 3,
  tarjeta("Cache policy", subtitulo: "Qué se cachea y cuánto tiempo")[Los valores que forman la cache key y los TTL mínimo, máximo y por defecto. Gestionadas: _CachingOptimized_, _CachingDisabled_...],
  tarjeta("Origin request policy", subtitulo: "Qué llega al origen")[Valores que se *reenvían* al origen sin entrar en la clave: cabeceras como _User-Agent_ o _CloudFront-Viewer-Country_, cookies o _query strings_.],
  tarjeta("Response headers policy", subtitulo: "Qué cabeceras añadir")[Cabeceras que CloudFront añade o quita en la respuesta: de seguridad (HSTS, _X-Frame-Options_, CSP...), CORS o propias.],
)

El tiempo que un objeto pasa en la caché (*TTL*) lo propone el origen con sus cabeceras y lo acota la cache policy:

- Si el origen envía `Cache-Control: max-age=N` (o `s-maxage=N`, que tiene prioridad en cachés compartidas como CloudFront), el objeto se guarda _N_ segundos, siempre dentro de los TTL mínimo y máximo de la política.
- Si no envía cabeceras de caché, se aplica el TTL por defecto (24 horas en _CachingOptimized_).
- Con `no-cache`, `no-store` o `private`, CloudFront no cachea... siempre que el TTL mínimo sea 0. Si es mayor, cachea durante ese mínimo igualmente: es una sorpresa habitual.

Las cabeceras de la respuesta a `GET /assets/app.3f9a2c.js` te dicen qué ha pasado:

```http
HTTP/2 200
content-type: application/javascript
cache-control: public, max-age=31536000, immutable
age: 5233
x-cache: Hit from cloudfront
via: 1.1 7c5e1b0a2f9d3e4c.cloudfront.net (CloudFront)
x-amz-cf-pop: MAD53-P1
```

`x-cache` indica si fue un acierto (`Hit`), un fallo (`Miss`) o un objeto caducado que se revalidó con el origen (`RefreshHit`); `age`, cuántos segundos lleva el objeto en caché, y `x-amz-cf-pop`, qué edge location respondió.

=== Invalidaciones frente a versionado

#tarjetas(
  tarjeta("Invalidación", color: col.neutro, subtitulo: "Borrar de la caché")[Pides a CloudFront que elimine rutas de todas las edge locations (`/index.html`, `/css/*`). No es instantánea; los primeros 1000 paths de cada mes son gratuitos y después se pagan (un comodín cuenta como un path).],
  tarjeta("Versionado", subtitulo: "Nombres nuevos para contenido nuevo")[Incluyes una huella del contenido en el nombre (`app.3f9a2c.js`) y lo cacheas un año con `immutable`; el HTML, con TTL corto, apunta al fichero nuevo. Nada que invalidar y sin mezclas de versiones.],
)

```bash
aws cloudfront create-invalidation --distribution-id E1A2B3C4D5E6F7 \
  --paths "/index.html" "/css/*"
```

#coste[Pagas por GB servido a los usuarios (más caro en zonas como Sudamérica u Oceanía), por cada 10 000 peticiones y por extras (invalidaciones por encima de las gratuitas, funciones, logs en tiempo real, Origin Shield...). La *price class* (100, 200 o todas las ubicaciones) excluye las zonas más caras a cambio de algo más de latencia allí. Desde noviembre de 2025 existen además planes de *tarifa plana* mensual que agrupan CloudFront, WAF, protección DDoS, DNS de Route 53 y otros servicios, sin cargos por exceso.]

== Seguridad en el borde

=== Origin Access Control: un bucket S3 privado detrás de CloudFront

El patrón más común: el bucket sigue *privado* (Block Public Access activado) y solo CloudFront puede leerlo. Con *Origin Access Control* (OAC), CloudFront firma cada petición al bucket con SigV4 y la bucket policy permite `s3:GetObject` al principal de servicio `cloudfront.amazonaws.com` solo cuando la petición procede de *tu* distribución (condición `AWS:SourceArn`). OAC sustituye al antiguo _Origin Access Identity_ (OAI): admite cifrado SSE-KMS, todas las regiones y peticiones de escritura.

#diagrama(pie: [Origin Access Control: el bucket solo acepta peticiones firmadas por tu distribución; el acceso directo a S3 se rechaza.])[
  #columna(espacio: 6pt,
    fila(espacio: 4pt,
      actor(etiqueta: "Usuario"),
      flecha(etiqueta: "HTTPS", largo: 1.6cm),
      svc("CF", "CloudFront", sub: "OAC firma con SigV4", color: col.edge),
      flecha(etiqueta: "GetObject firmado", largo: 2.4cm),
      zona("Privado", color: col.almacenamiento)[#svc("S3", "mi-sitio-web", sub: "Block Public Access", color: col.almacenamiento)]),
    fila(espacio: 4pt,
      actor(etiqueta: "Usuario"),
      flecha(etiqueta: "URL directa de S3", largo: 3.2cm, color: rgb("#E03131"), punteada: true),
      caja([#no #h(2pt) *403 Access Denied*], color: rgb("#E03131"))),
  )
]

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "SoloDesdeMiDistribucion",
    "Effect": "Allow",
    "Principal": { "Service": "cloudfront.amazonaws.com" },
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::mi-sitio-web/*",
    "Condition": {
      "StringEquals": {
        "AWS:SourceArn":
          "arn:aws:cloudfront::123456789012:distribution/E1A2B3C4D5E6F7"
      }
    }
  }]
}
```

=== HTTPS: certificados y protocolos

Una petición a CloudFront recorre dos tramos cifrados: del usuario a la edge location y de la edge location al origen.

- *Certificado de tu dominio*: emitido por ACM (gratuito y con renovación automática) y obligatoriamente en `us-east-1` (Norte de Virginia), aunque tu aplicación viva en otra región.
- *Viewer protocol policy*: _HTTP and HTTPS_, _Redirect HTTP to HTTPS_ (lo habitual) o _HTTPS only_. Una *security policy* fija la versión mínima de TLS.
- *Origin protocol policy* (orígenes personalizados): _HTTP only_, _HTTPS only_ o _Match viewer_. Con HTTPS, el certificado del origen debe ser válido para su nombre: nada de certificados autofirmados.
- *SNI* (_Server Name Indication_) sirve muchos certificados desde las mismas IPs; es la opción por defecto y gratuita. Las IPs dedicadas, para clientes antiguos sin SNI, se pagan aparte y son caras.

#examen[«Certificado para CloudFront» = ACM en `us-east-1`. En cambio, el certificado de un ALB debe estar en la región del propio ALB.]

=== Signed URLs y signed cookies

Para contenido privado o de pago (cursos, descargas, vídeo), CloudFront puede exigir que cada petición vaya *firmada*. Tu aplicación autentica al usuario y genera la firma con una clave privada cuya clave pública has registrado en un *trusted key group* de la distribución (las antiguas _CloudFront key pairs_ exigían el usuario root: evítalas).

#tabla(("", "Signed URL", "Signed cookies"), columnas: (0.9fr, 1.8fr, 1.8fr),
  [Alcance], [Un fichero por URL], [Muchos ficheros (por ejemplo, `/premium/*`)],
  [Cambia las URLs], [#si #h(2pt) Añade parámetros de firma], [#no],
  [Ideal para], [Una descarga concreta; clientes que no admiten cookies], [Vídeo HLS o DASH con cientos de segmentos; zonas de suscriptores],
  [Política], [_Canned_ (solo caducidad) o _custom_ (comodines, fecha de inicio, rango de IP)], [Las mismas opciones],
)

Una signed URL es la URL normal con tres parámetros añadidos: `Expires` (o `Policy`), `Signature` y `Key-Pair-Id`, el identificador de la clave pública.

#cuidado[No confundas las _signed URLs_ de CloudFront con las _presigned URLs_ de S3: estas dan acceso temporal directo a un objeto de S3, con los permisos de quien las genera, y no pasan por la CDN.]

=== Geo-restricción, WAF y Shield

Con la *geo-restricción* defines una lista de países permitidos o bloqueados para toda la distribución, según la geolocalización de la IP del usuario; los bloqueados reciben un 403. Para reglas más finas (por ruta o combinadas con otras condiciones) usa *AWS WAF*: se asocia a la distribución mediante una _web ACL_ de ámbito CloudFront (gestionada desde `us-east-1`), con reglas gestionadas frente al OWASP Top 10 y a bots, límites de peticiones por IP, listas de IP o coincidencias geográficas. *AWS Shield Standard* protege gratis y automáticamente a todas las distribuciones frente a ataques DDoS de capas 3 y 4; *Shield Advanced*, de pago, añade protección ampliada, un equipo de respuesta y protección de costes. Lo verás con detalle en el capítulo de Seguridad.

#practica(titulo: "Cierra la puerta trasera del origen")[Si tu origen es un ALB público, impide que se pueda saltar CloudFront: en su Security Group permite solo la _managed prefix list_ `com.amazonaws.global.cloudfront.origin-facing` y haz que CloudFront añada una cabecera secreta que el ALB compruebe en sus reglas. Mejor aún: usa VPC origins y deja el ALB en subredes privadas.]

== Código en el borde: CloudFront Functions y Lambda\@Edge

CloudFront puede ejecutar tu código en cuatro momentos del ciclo de una petición, con dos tecnologías distintas:

#diagrama(pie: [Los cuatro eventos en los que puede ejecutarse código. Los eventos de origen solo se disparan cuando hay un fallo de caché.])[
  #grid(columns: 5, column-gutter: 4pt, align: center + horizon,
    grid.cell(rowspan: 2, actor(etiqueta: "Usuario")),
    flecha(etiqueta: "1 · viewer request", largo: 2.8cm),
    grid.cell(rowspan: 2, svc("CF", "CloudFront", sub: "caché", color: col.edge)),
    flecha(etiqueta: "2 · origin request", largo: 2.8cm),
    grid.cell(rowspan: 2, svc("ORIG", "Origen", color: col.almacenamiento)),
    _izq(etiqueta: "4 · viewer response", largo: 2.8cm),
    _izq(etiqueta: "3 · origin response", largo: 2.8cm),
  )
  #v(6pt)
  #fila(espacio: 10pt,
    caja([*CloudFront Functions*: eventos 1 y 4], color: col.edge),
    caja([*Lambda\@Edge*: eventos 1, 2, 3 y 4], color: col.serverless))
]

#tabla(("", "CloudFront Functions", "Lambda@Edge"), columnas: (1.15fr, 1.75fr, 1.75fr), tamano: 8pt,
  [Lenguaje], [JavaScript (entorno ligero)], [Node.js y Python],
  [Dónde se ejecuta], [En las edge locations], [En las Regional Edge Caches],
  [Eventos], [_Viewer request_ y _viewer response_], [Los cuatro],
  [Tiempo máximo], [Menos de 1 ms], [5 s (viewer) y 30 s (origin)],
  [Memoria], [2 MB], [128 MB (viewer); hasta 10~240 MB (origin)],
  [Tamaño del código], [10 KB], [1 MB (viewer) y 50 MB (origin)],
  [Red, ficheros, cuerpo de la petición], no, si,
  [Escala y precio], [Millones de peticiones por segundo; en torno a una sexta parte del precio], [Miles por segundo y región; más caro],
  [Usos típicos], [Redirecciones, reescritura de URL, cabeceras, normalizar la cache key, validar tokens sencillos], [Autenticación contra servicios externos, generar respuestas, elegir el origen dinámicamente],
)

Las funciones de Lambda\@Edge se crean en `us-east-1`, y CloudFront replica una versión numerada por todo el mundo. Las CloudFront Functions pueden leer datos de *CloudFront KeyValueStore*, un almacén clave-valor global muy útil para tablas de redirecciones. Este ejemplo, asociado al evento _viewer request_, añade `index.html` a las rutas de directorio:

```js
// CloudFront Function (viewer request): /docs/ → /docs/index.html
function handler(event) {
  var request = event.request;
  var uri = request.uri;
  if (uri.endsWith('/')) {
    request.uri += 'index.html';
  } else if (!uri.includes('.')) {
    request.uri += '/index.html';
  }
  return request;
}
```

== Logs y métricas

CloudFront publica en CloudWatch (región `us-east-1`) métricas como peticiones, bytes y tasas de error 4xx y 5xx; otras, como la tasa de aciertos de caché, tienen coste adicional. Para el detalle de cada petición están los *standard logs* (IP, ruta, código de estado, edge location, resultado de caché...), que se entregan en S3, CloudWatch Logs o Data Firehose, y los *real-time logs*, que llegan en segundos a Kinesis Data Streams. Más en el capítulo de Observabilidad.

== Patrón: sitio web estático con S3, CloudFront, Route 53 y ACM

Es la arquitectura más rentable para publicar una web estática o una SPA con dominio propio y HTTPS: sin servidores que mantener y con coste casi nulo cuando hay poco tráfico.

#diagrama(pie: [Sitio estático con dominio propio: Route 53 resuelve el nombre, CloudFront sirve por HTTPS con un certificado de ACM y lee el bucket privado mediante OAC.])[
  #grid(columns: 5, column-gutter: 4pt, align: center + horizon,
    [], [], actor(etiqueta: "Navegador"), flecha(etiqueta: "1 · consulta DNS", largo: 2.4cm),
    svc("R53", "Route 53", sub: "alias A y AAAA", color: col.edge),
    [], [], flecha-v(etiqueta: "2 · HTTPS", largo: 0.9cm), [], [],
    svc("ACM", "Certificado", sub: "en us-east-1", color: col.seguridad),
    flecha(etiqueta: "TLS", largo: 1.4cm, punteada: true),
    svc("CF", "CloudFront", sub: "www.ejemplo.com", color: col.edge),
    flecha(etiqueta: "3 · OAC (SigV4)", largo: 2.4cm),
    svc("S3", "Bucket privado", color: col.almacenamiento),
  )
]

#pasos(
  [Crea un bucket privado y sube el sitio: `aws s3 sync ./dist s3://mi-sitio-web --delete`.],
  [Solicita en ACM, en `us-east-1`, un certificado para `www.ejemplo.com` con validación DNS (con Route 53, el registro de validación se crea con un clic).],
  [Crea la distribución: origen S3 con OAC, _default root object_ `index.html`, redirección de HTTP a HTTPS, nombre alternativo y certificado. Añade al bucket la política que te propone CloudFront.],
  [En Route 53, crea registros alias A y AAAA de `www.ejemplo.com` hacia la distribución.],
)

#cuidado[El _default root object_ solo se aplica a la raíz (`/`): `/blog/` no se traduce a `/blog/index.html`. Resuélvelo con una CloudFront Function como la anterior. En aplicaciones de una sola página (SPA), configura respuestas de error personalizadas que devuelvan `/index.html` con código 200 ante un 403 o un 404.]

== Route 53: el DNS gestionado de AWS

*Amazon Route 53* (el nombre viene del puerto 53, el del DNS) hace tres cosas: registra dominios, responde a las consultas DNS de tus zonas y comprueba la salud de tus endpoints para enrutar el tráfico en función de ella.

#ficha("Amazon Route 53", "DNS gestionado, registro de dominios y health checks",
  ("Ámbito", [Global]),
  ("Zonas", [Públicas (Internet) y privadas (asociadas a una o varias VPC)]),
  ("Coste", [Cuota mensual por zona alojada y por millón de consultas (las consultas alias a recursos de AWS son gratuitas), por health check y, si registras dominios, por dominio y año]),
  ("SLA", [100 % de disponibilidad del servicio de DNS]))

=== Zonas alojadas y tipos de registro

Una *hosted zone* contiene los registros de un dominio (`ejemplo.com`) y sus subdominios. Una zona *pública* responde a todo Internet; al crearla, Route 53 le asigna cuatro servidores de nombres (registro NS) que debes configurar en el registrador del dominio. Una zona *privada* solo responde dentro de las VPC asociadas (lo viste en el capítulo de Redes); si usas el mismo nombre en ambas (_split-horizon_), dentro de esas VPC prevalece la privada.

#tabla(("Tipo", "Para qué sirve", "Ejemplo"), columnas: (0.65fr, 2fr, 2.3fr), tamano: 8pt,
  [*A*], [Nombre → dirección IPv4], _m("api.ejemplo.com → 203.0.113.10"),
  [*AAAA*], [Nombre → dirección IPv6], _m("api.ejemplo.com → 2001:db8::10"),
  [*CNAME*], [Nombre → otro nombre (nunca en el apex)], _m("blog.ejemplo.com → mi-blog.example.net"),
  [*Alias*], [Extensión de Route 53: nombre → recurso de AWS, también en el apex], _m("ejemplo.com → d111111abcdef8.cloudfront.net"),
  [*MX*], [Servidores de correo, con prioridad], _m("10 mail.ejemplo.com"),
  [*TXT*], [Texto libre: SPF, verificación de dominio...], _m("\"v=spf1 include:amazonses.com ~all\""),
  [*NS*], [Servidores de nombres de la zona o de un subdominio delegado], _m("ns-123.awsdns-15.com"),
)

=== Registros alias y el apex

El estándar DNS prohíbe un CNAME en el *apex* (la raíz de la zona, `ejemplo.com`), porque allí ya existen los registros SOA y NS y un CNAME no puede convivir con otros registros del mismo nombre. Los registros *alias* resuelven el problema: Route 53 responde directamente con las IPs (A o AAAA) del recurso de destino —una distribución de CloudFront, un balanceador, un bucket configurado como sitio web, un API Gateway, un endpoint de VPC u otro registro de la zona—, sigue sus cambios automáticamente y no cobra las consultas cuando el destino es un recurso de AWS. El TTL lo marca el destino.

#examen[«Apuntar `ejemplo.com` (sin www) a un ALB o a CloudFront» → registro *alias*. CNAME solo para subdominios, y nunca hacia una IP.]

El *TTL* indica a los resolutores cuántos segundos pueden cachear una respuesta: un TTL alto reduce consultas (y coste), pero hace lentos los cambios. Antes de una migración, bájalo con antelación (al menos un TTL antiguo antes), haz el cambio y vuelve a subirlo.

=== Políticas de enrutamiento

#tabla(("Política", "Cómo decide", "Caso de uso"), columnas: (1fr, 2.2fr, 1.8fr), tamano: 8pt,
  [*Simple*], [Devuelve los valores del registro, sin health checks], [Un único recurso],
  [*Weighted*], [Reparte según pesos relativos (por ejemplo, 90/10)], [Despliegues _canary_, pruebas A/B],
  [*Latency*], [La región de AWS con menor latencia para el usuario], [Aplicaciones multirregión],
  [*Failover*], [El primario mientras esté sano; si no, el secundario], [Activo-pasivo, recuperación ante desastres],
  [*Geolocation*], [El país o continente del usuario (con un registro por defecto)], [Contenido localizado, requisitos legales],
  [*Geoproximity*], [La distancia geográfica, ajustable con un _bias_], [Desplazar tráfico entre regiones],
  [*Multivalue answer*], [Hasta 8 registros sanos, elegidos al azar], [Reparto sencillo con health checks],
  [*IP-based*], [Rangos CIDR del cliente (_CIDR collections_)], [Enrutar según el proveedor o la red de origen],
)

=== Health checks y failover

Los *health checks* comprueban un endpoint por HTTP, HTTPS o TCP desde ubicaciones repartidas por el mundo, cada 30 segundos (o cada 10, con coste extra); se considera sano si más del 18 % de los comprobadores lo ven sano. Hay también health checks *calculados*, que combinan otros, y basados en *alarmas de CloudWatch*, para recursos privados que los comprobadores no alcanzan. Con la política _failover_ dan una recuperación ante desastres sencilla:

#diagrama(pie: [Failover con Route 53: mientras el health check del primario sea correcto, las respuestas apuntan a eu-west-1; si falla, a una página de contingencia en otra región.])[
  #fila(espacio: 4pt,
    actor(etiqueta: "Usuario"),
    flecha(etiqueta: "app.ejemplo.com", largo: 2cm),
    svc("R53", "Route 53", sub: "política failover", color: col.edge),
    columna(espacio: 8pt,
      fila(espacio: 4pt, flecha(etiqueta: "primario", largo: 1.8cm),
        zona("eu-west-1", color: col.almacenamiento)[#fila(espacio: 6pt,
          svc("ALB", "Aplicación", color: col.balanceo),
          caja([Health check #si], color: col.almacenamiento))]),
      fila(espacio: 4pt, flecha(etiqueta: "secundario", largo: 1.8cm, punteada: true),
        zona("us-east-1", color: col.neutro)[#svc("S3", "Sitio estático", sub: "contingencia", color: col.almacenamiento)]),
    ),
  )
]

=== Registro de dominios

Route 53 también es *registrador*: compra o transfiere dominios, con renovación automática y protección de los datos de contacto; al registrarlo, crea automáticamente su zona pública. Si el dominio está en otro registrador, basta con apuntar sus servidores de nombres (NS) a los de tu zona. Para más seguridad, activa *DNSSEC*.

== Global Accelerator frente a CloudFront

*AWS Global Accelerator* también usa la red global de AWS, pero no es una CDN: te da dos direcciones IP estáticas _anycast_, anunciadas desde las edge locations. El usuario entra por la más cercana y su tráfico TCP o UDP viaja por la red troncal de AWS hasta el endpoint regional sano más próximo (ALB, NLB, instancias EC2 o Elastic IP).

#tabla(("", "CloudFront", "Global Accelerator"), columnas: (1fr, 1.6fr, 1.6fr), tamano: 8pt,
  [Qué es], [CDN con caché], [Acelerador de red (capa 4), sin caché],
  [Protocolos], [HTTP y HTTPS (también WebSocket)], [TCP y UDP],
  [Punto de entrada], [Un nombre DNS (las IPs cambian)], [Dos IPs estáticas _anycast_],
  [Failover entre regiones], [Origin groups, petición a petición], [Automático en segundos, sin depender de cachés DNS],
  [Casos típicos], [Webs, APIs, vídeo, descargas], [Juegos, VoIP, IoT; clientes que necesitan IPs fijas en listas de permitidos],
  [Facturación], [Por GB y por peticiones], [Cuota por hora + recargo por GB transferido],
)

#examen[IPs fijas, UDP o failover regional en segundos, sin caché → Global Accelerator. Contenido HTTP cacheable, funciones en el borde o WAF → CloudFront.]

#resumen[
- *CloudFront* es la CDN de AWS: más de 700 puntos de presencia y una capa de Regional Edge Caches para reducir la latencia, descargar el origen y proteger la aplicación.
- Una *distribución* combina orígenes (S3, ALB, servidores propios, API Gateway, Lambda function URLs, VPC origins) y *cache behaviors* por patrón de ruta; los *origin groups* aportan failover.
- La *cache key* debe incluir solo lo que cambia la respuesta: *cache policy* (clave y TTL), *origin request policy* (qué se reenvía) y *response headers policy* (cabeceras añadidas).
- El TTL lo propone el origen con `Cache-Control`, dentro de los límites de la política. Versiona los ficheros y reserva las invalidaciones para el HTML.
- *OAC* mantiene privado el bucket S3: la bucket policy autoriza a `cloudfront.amazonaws.com` con la condición `AWS:SourceArn` de tu distribución.
- El certificado de CloudFront va en *ACM de `us-east-1`*; redirige HTTP a HTTPS y usa SNI. Las *signed URLs* protegen ficheros concretos; las *signed cookies*, conjuntos de ficheros.
- *CloudFront Functions* (eventos viewer, submilisegundo, baratas) frente a *Lambda\@Edge* (cuatro eventos, acceso a red, más potente).
- *Route 53*: zonas públicas y privadas, registros *alias* en el apex, TTL, ocho políticas de enrutamiento y health checks para el failover.
- *Global Accelerator*: dos IPs anycast estáticas, TCP y UDP y failover rápido, pero sin caché.
]

#repaso(
  ([Tu certificado de ACM no aparece al configurar la distribución. ¿Por qué?], [Porque no está en `us-east-1`: CloudFront solo usa certificados de ACM de esa región.]),
  ([¿Cómo impides que se acceda a tu bucket S3 sin pasar por CloudFront?], [Con el bucket privado (Block Public Access), OAC en la distribución y una bucket policy que autorice a `cloudfront.amazonaws.com` con la condición `AWS:SourceArn` de tu distribución.]),
  ([Tras un despliegue, los usuarios siguen viendo el CSS antiguo. ¿Qué puedes hacer?], [Invalidar `/css/*` o, mejor, versionar los nombres de fichero para que el HTML apunte a los nuevos.]),
  ([¿Por qué no puedes crear un CNAME para `ejemplo.com` hacia tu distribución?], [Porque el DNS no permite un CNAME en el apex de la zona; usa registros alias A y AAAA.]),
  ([Quieres enviar el 10 % del tráfico a la nueva versión de tu aplicación. ¿Qué política de Route 53 usas?], [Weighted (ponderada), con pesos 90 y 10.]),
  ([Una función debe consultar un servicio externo de autorización antes de ir al origen. ¿CloudFront Functions o Lambda\@Edge?], [Lambda\@Edge: las CloudFront Functions no tienen acceso a red.]),
  ([Un juego multijugador por UDP necesita IPs fijas y un failover rápido entre regiones. ¿CloudFront o Global Accelerator?], [Global Accelerator: ofrece dos IPs anycast estáticas, admite UDP y conmuta entre regiones en segundos; CloudFront solo sirve HTTP y HTTPS.]),
)
