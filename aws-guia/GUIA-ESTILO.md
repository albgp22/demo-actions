# Guía de estilo para redactar capítulos

Proyecto: `/home/user/demo-actions/aws-guia/` (Typst 0.13.1, binario en `/usr/local/bin/typst`).

## Estructura

- `theme.typ` — todos los componentes visuales. **No lo modifiques.** Si te falta algo, constrúyelo con los componentes existentes o con Typst nativo dentro de tu capítulo.
- `main.typ` — portada, índice e `#include` de cada capítulo. No lo modifiques.
- `capitulos/NN-nombre.typ` — un archivo por capítulo. Cada archivo empieza así:

```typ
#import "../theme.typ": *

#capitulo("Título del capítulo", color: col.redes,
  subtitulo: [Una frase que resuma el capítulo.],
  objetivos: ([Objetivo 1], [Objetivo 2], [Objetivo 3], [Objetivo 4], [Objetivo 5], [Objetivo 6]),
  servicios: ("Amazon VPC", "AWS Transit Gateway"))

== Primera sección
...
```

- Títulos: `==` sección (numerada, sale en el índice), `===` subsección, `====` párrafo destacado. **Nunca uses `=`** (nivel 1 lo crea `#capitulo`).
- Un capítulo termina SIEMPRE con `#resumen[...]` (lista de 6–10 viñetas) y `#repaso(...)` (5–8 preguntas con respuesta).

## Compilar y comprobar tu capítulo

Crea un envoltorio propio en `scratch/` (no toques los de otros):

```typ
// scratch/test-03.typ
#import "../theme.typ": *
#show: guia
#include "../capitulos/03-redes.typ"
```

```bash
cd /home/user/demo-actions/aws-guia
typst compile --root . --font-path fonts --ignore-system-fonts scratch/test-03.typ scratch/test-03.pdf
pdfinfo scratch/test-03.pdf | grep Pages
# Revisión visual de páginas concretas (PNG de baja resolución):
pdftoppm -r 60 -png -f 3 -l 5 scratch/test-03.pdf scratch/test-03
```

Mira con la herramienta Read los PNG de las páginas con diagramas o tablas: comprueba que nada se sale del margen, que las flechas y etiquetas no se solapan y que no quedan páginas casi vacías por bloques no divisibles. Deben compilar **sin errores ni warnings**.

## Idioma y tono

- Español neutro, tuteando al lector ("puedes", "fíjate"). Didáctico, claro, con ejemplos concretos.
- Los nombres de servicios y términos técnicos se mantienen en inglés cuando es lo habitual (*Security Group*, *bucket*, *listener*, *target group*), explicándolos la primera vez.
- Sin emojis. Usa los símbolos del tema (`si`, `no`, `parcial`) en tablas.
- Precisión técnica ante todo. No inventes cifras. Para precios, da órdenes de magnitud o el modelo de facturación ("se paga por hora y por GB procesado") en lugar de importes exactos, salvo que sean muy estables, y aclara que varían por región. Para límites, usa solo los que conozcas con seguridad; si un límite es ajustable ("soft limit"), dilo.
- Datos recientes a tener en cuenta (correctos a 2025–2026):
  - SQS: tamaño máximo de mensaje 1 MiB (ampliado desde 256 KB en agosto de 2025).
  - S3: consistencia fuerte read-after-write desde 2020; cifrado SSE-S3 por defecto en todos los objetos nuevos (2023); Block Public Access activado y ACL deshabilitadas por defecto en buckets nuevos (2023).
  - Las IPv4 públicas se facturan por hora desde febrero de 2024 (incluidas las de EC2).
  - IAM Identity Center es el antiguo AWS SSO. Organizations tiene SCP y también RCP (Resource Control Policies, 2024).
  - CloudFront: Origin Access Control (OAC) sustituye a OAI.
  - NLB admite Security Groups (desde 2023).
  - Lambda: hasta 15 min, hasta 10 240 MB de memoria, /tmp efímero hasta 10 GB, payload síncrono de 6 MB; SnapStart.
  - Aurora Serverless v2 puede escalar a 0 ACU (2024); existe Aurora DSQL (GA 2025). DynamoDB: ítem máx. 400 KB.
  - Amazon Data Firehose (antes Kinesis Data Firehose); Amazon Managed Service for Apache Flink (antes Kinesis Data Analytics).
  - AWS CodeCommit y Cloud9 cerraron a nuevos clientes en 2024: menciónalo si hablas de ellos.
  - EKS Auto Mode (2024). ECS Service Connect.

## Componentes disponibles (`theme.typ`)

Colores de categoría: `col.fundamentos, col.iam, col.redes, col.computo, col.balanceo, col.contenedores, col.serverless, col.almacenamiento, col.datos, col.integracion, col.edge, col.observabilidad, col.seguridad, col.iac, col.costes, col.arquitectura, col.neutro`. Otros: `marino, gris, acento, tinta`.

### Cajas destacadas (úsalas con generosidad pero sin saturar: 3–6 por sección larga)
```typ
#nota[...]        #consejo[...]       #cuidado[...]
#examen[...]      // trucos típicos de certificación
#coste[...]       // cómo se factura / trampas de coste
#practica[...]    // buena práctica
#analogia[...]    // analogía con el mundo real
#nota(titulo: "Título propio")[...]
```

### Ficha de servicio (al presentar cada servicio principal)
```typ
#ficha("Amazon SQS", "Colas de mensajes totalmente gestionadas",
  ("Tipo", [Serverless, pago por petición]),
  ("Ámbito", [Regional]),
  ("Ideal para", [Desacoplar productores y consumidores]),
  ("Límites clave", [Mensaje de hasta 1 MiB; retención de 1 min a 14 días]))
```

### Cifras destacadas (2–4 tiles)
```typ
#datos(("15 min", [Duración máxima]), ("10 GB", [Memoria máxima]), ("1000", [Concurrencia por defecto]))
```

### Tarjetas en columnas (comparar opciones)
```typ
#tarjetas(
  tarjeta("Standard", subtitulo: "Máximo rendimiento")[Texto o lista...],
  tarjeta("FIFO", color: col.iam, subtitulo: "Orden estricto")[...],
)
#tarjetas(columnas: 3, tarjeta(...)[...], ...)   // varias filas
```

### Tablas
```typ
#tabla(("Característica", "Opción A", "Opción B"), columnas: (1.3fr, 1fr, 1fr),
  [Fila 1], [valor], si,
  [Fila 2], [valor], no)
```
Parámetros opcionales: `color:`, `tamano:` (por defecto 8.6pt; baja a 8pt en tablas densas).

### Pasos numerados
```typ
#pasos([Primer paso...], [Segundo paso...], [Tercero...])
```

### Lista de términos
```typ
/ Término: Definición.
```

### Código
Bloques con lenguaje: ```` ```json ````, ```` ```bash ````, ```` ```yaml ````, ```` ```python ````, ```` ```hcl ````… Mantén las líneas por debajo de ~85 caracteres. Inline: `` `arn:aws:...` ``.

### Diagramas (¡imprescindibles! al menos 2–3 por capítulo)
```typ
#diagrama(pie: [Descripción de la figura.])[
  #fila(actor(), flecha(etiqueta: "HTTPS"), internet(), flecha(),
        svc("ALB", "Application LB", color: col.balanceo))
  #v(6pt)
  #zona("Región eu-west-1", color: col.fundamentos, punteada: false, relleno: white)[
    #zona("VPC 10.0.0.0/16", color: col.redes)[
      #fila(espacio: 10pt,
        zona("Subred pública", color: col.almacenamiento)[ #svc("NAT", "NAT Gateway", color: col.redes) ],
        zona("Subred privada", color: col.datos)[
          #columna(svc("EC2", "App"), flecha-v(etiqueta: "SQL"), svc("RDS", "Base de datos", color: col.datos))
        ])
    ]
  ]
]
```
- `svc(abbr, etiqueta, sub: none, color: ...)` — icono cuadrado con abreviatura (máx. ~5 caracteres, p. ej. "EC2", "S3", "SQS", "λ", "DDB", "CF", "R53", "KMS", "IAM") + etiqueta debajo.
- `actor(etiqueta: "Usuario")`, `internet(etiqueta: "Internet")`, `caja([texto], color: ..., ancho: ...)` (rectángulo genérico con texto).
- `flecha(etiqueta: none, largo: 1.4cm, color: ..., doble: false, punteada: false)` — horizontal. Etiquetas MUY cortas (1–3 palabras) o aumenta `largo`.
- `flecha-v(etiqueta: none, largo: 0.9cm, doble: false, arriba: false, punteada: false)` — vertical; la etiqueta se dibuja a la derecha.
- `fila(espacio: 4pt, ...)` y `columna(espacio: 4pt, ...)` — disposición horizontal/vertical centrada.
- `zona(titulo, color: ..., punteada: true, relleno: auto, ancho: auto)[...]` — agrupación (región, VPC, AZ, subred, cuenta, clúster...). Se pueden anidar.
- `capas(("Texto", color), ...)` — pila de bandas horizontales (modelos en capas).
- Ancho útil de la página ≈ 16.8 cm. Un `svc` ocupa ~2.5 cm. No pongas más de ~6 elementos por `fila` en el nivel superior, menos si están dentro de zonas anidadas. **Verifica visualmente** cada diagrama.
- Cualquier otro gráfico se puede hacer con Typst nativo (`grid`, `rect`, `box`, `place`, `line`, `polygon`, `circle`), siempre sin paquetes externos (no hay acceso a `@preview`).

### Otros
- `pill("texto", color: ...)` — etiqueta redondeada inline.
- `tecla("Ctrl")`.

## Qué hace bueno un capítulo

1. Empieza por el *porqué*: qué problema resuelve el servicio.
2. Conceptos fundamentales con definiciones claras, luego detalles, luego casos de uso.
3. Diagramas de arquitectura, tablas comparativas y fichas de servicio frecuentes: debe ser **visual**.
4. Ejemplos reales: políticas JSON, comandos de AWS CLI, fragmentos de configuración.
5. Buenas prácticas, errores comunes y trampas de coste.
6. Referencias cruzadas a otros capítulos por nombre ("lo veremos en el capítulo de Observabilidad").
7. Evita páginas con media página en blanco: los bloques `diagrama`, `ficha` y `repaso` no se parten; coloca texto que los rodee con criterio.
