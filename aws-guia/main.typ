// =====================================================================
//  Guía visual de AWS — documento principal
//  Compilar:  typst compile --font-path fonts main.typ guia-aws.pdf
// =====================================================================
#import "theme.typ": *

#show: guia

// ---------------------------------------------------------------------
//  Portada
// ---------------------------------------------------------------------
#page(margin: 0pt, header: none, footer: none, fill: marino, {
  // Mosaico decorativo
  let paleta = (col.iam, col.redes, col.computo, col.balanceo, col.contenedores, col.serverless,
    col.almacenamiento, col.datos, col.integracion, col.edge, col.observabilidad, col.iac)
  let lado = 30pt
  let sep = 7pt
  place(top + right, dx: -1.2cm, dy: 1.6cm, box(width: 9 * (lado + sep), height: 10 * (lado + sep), {
    for f in range(10) {
      for k in range(9) {
        let h = calc.rem(f * 17 + k * 29 + f * k * 7, 23)
        // Diagonal: más densidad arriba a la derecha
        if h + k * 2 - f > 9 {
          let c = paleta.at(calc.rem(f * 5 + k * 3, paleta.len()))
          let alpha = if calc.rem(h, 3) == 0 { 0% } else if calc.rem(h, 3) == 1 { 45% } else { 75% }
          place(dx: k * (lado + sep), dy: f * (lado + sep),
            rect(width: lado, height: lado, radius: 6pt, fill: c.transparentize(alpha)))
        }
      }
    }
  }))

  // Texto principal
  place(bottom + left, dx: 2.2cm, dy: -2.6cm, block(width: 15.5cm, {
    box(fill: acento, inset: (x: 8pt, y: 4pt), radius: 3pt,
      text(8.5pt, weight: "bold", fill: marino, tracking: 2pt, "EDICIÓN 2026"))
    v(18pt)
    text(15pt, weight: "medium", fill: white.transparentize(25%), tracking: 1pt, "GUÍA VISUAL DE")
    v(-6pt)
    text(96pt, weight: "black", fill: white, "AWS")
    v(-30pt)
    text(30pt, weight: "bold", fill: white, "Amazon Web Services")
    v(8pt)
    box(width: 2cm, height: 4pt, radius: 2pt, fill: acento)
    v(10pt)
    set par(justify: false)
    text(13pt, fill: white.transparentize(15%), hyphenate: false,
      [Los conceptos esenciales para diseñar, construir y operar en la nube: de IAM y las redes a los contenedores y Kubernetes, las bases de datos, la mensajería, el cifrado y la entrega de contenido.])
    v(22pt)
    let temas = ("IAM", "VPC", "EC2", "ELB", "ECS", "EKS", "Lambda", "S3", "RDS", "DynamoDB", "SQS", "SNS", "CloudFront", "CloudWatch", "KMS", "CloudFormation")
    temas.map(t => box(stroke: 0.8pt + white.transparentize(60%), radius: 10pt, inset: (x: 7pt, y: 3.5pt),
      text(8pt, weight: "semibold", fill: white.transparentize(10%), t))).join(h(5pt))
  }))
})

// ---------------------------------------------------------------------
//  Páginas preliminares
// ---------------------------------------------------------------------
#set page(numbering: "i")
#counter(page).update(1)

#page(header: none)[
  #block(below: 1.2em, {
    text(9pt, weight: "bold", fill: acento, tracking: 3pt, "ANTES DE EMPEZAR")
    v(-2pt)
    text(30pt, weight: "extrabold", fill: marino, "Cómo leer esta guía")
  })

  Esta guía recorre los servicios y conceptos de AWS que aparecen una y otra vez en cualquier proyecto real: identidad y permisos, redes, cómputo, contenedores y Kubernetes, _serverless_, almacenamiento, bases de datos, mensajería, entrega de contenido, observabilidad, seguridad y cifrado, infraestructura como código y costes. Cada capítulo parte del _porqué_ de sus servicios, construye los conceptos paso a paso y termina con un resumen y preguntas de repaso; el último, _Arquitecturas de referencia_, junta todas las piezas en diseños completos.

  Puedes leerla de principio a fin —el orden está pensado para que cada capítulo se apoye en los anteriores— o saltar directamente al servicio que necesites. Los capítulos de _Fundamentos_, _IAM_ y _Redes_ son la base de todo lo demás: si eres nuevo en AWS, empieza por ellos. IAM ocupa dos capítulos a propósito: el primero responde a _quién_ (usuarios, grupos, roles y _permission sets_) y el segundo a _qué puede hacer_ (políticas y evaluación de permisos). Es el tema que más dudas genera y el que más conviene dominar. También tienen espacio propio _Kubernetes y Amazon EKS_, justo después de _Contenedores_, y el cifrado con KMS, que ocupa la primera mitad de _Seguridad_. Al final, el _Glosario_ y la _Chuleta de referencia rápida_ reúnen términos, cifras clave y comandos para consultar en cualquier momento.

  #v(4pt)
  #text(11pt, weight: "bold", fill: marino, "Cajas que encontrarás a lo largo del texto")
  #v(2pt)
  #grid(columns: (1fr, 1fr), column-gutter: 10pt,
    [
      #nota[Aclaraciones y matices que conviene conocer.]
      #consejo[Atajos y recomendaciones prácticas del día a día.]
      #cuidado[Errores habituales y comportamientos que sorprenden.]
      #analogia[Comparaciones con el mundo real para fijar conceptos.]
    ],
    [
      #examen[Ideas que se repiten en las certificaciones de AWS (Cloud Practitioner, Solutions Architect, Developer, SysOps).]
      #coste[Cómo se factura un servicio y dónde se esconden los sobrecostes.]
      #practica[Recomendaciones alineadas con el AWS Well-Architected Framework.]
    ],
  )

  #text(11pt, weight: "bold", fill: marino, "Convenciones")
  - Los nombres de servicios y la terminología técnica se mantienen en inglés, como los verás en la consola y la documentación (_bucket_, _Security Group_, _listener_…), explicados la primera vez que aparecen.
  - Los comandos usan la AWS CLI v2 (`aws ...`). Los identificadores como `123456789012` o `mi-bucket` son ejemplos.
  - Los precios y límites cambian con frecuencia y dependen de la región: tómalos como orientación y consulta siempre la documentación oficial y la calculadora de precios de AWS.
]

// Mapa de servicios
#page(header: none)[
  #block(below: 1.2em, {
    text(9pt, weight: "bold", fill: acento, tracking: 3pt, "PANORAMA")
    v(-2pt)
    text(30pt, weight: "extrabold", fill: marino, "Mapa de servicios")
  })
  AWS ofrece más de doscientos servicios, pero la inmensa mayoría de arquitecturas se construyen con un núcleo reducido. Este mapa agrupa por categoría los que trata esta guía, en el mismo orden que los capítulos; el color de cada categoría es el que verás en su capítulo y en los diagramas.
  #v(8pt)
  #let cat(nombre, color, servicios, alto: auto) = block(
    width: 100%, height: alto, radius: 7pt, clip: true, stroke: 0.8pt + color.lighten(50%), breakable: false,
    fill: color.lighten(95%),
    {
      set par(justify: false)
      set text(hyphenate: false)
      block(width: 100%, spacing: 0pt, fill: gradient.linear(color, color.darken(25%)), inset: (x: 10pt, y: 7pt),
        text(9pt, weight: "bold", fill: white, upper(nombre)))
      block(width: 100%, spacing: 0pt, inset: (x: 10pt, y: 8pt), {
        set par(leading: 0.5em)
        for (s, d) in servicios {
          block(below: 5pt, [#text(8.4pt, weight: "bold", fill: color.darken(20%), s) #h(2pt) #text(7.6pt, fill: gris, d)])
        }
      })
    },
  )
  // Una fila de categorías: todas las cajas toman la altura de la más alta
  #let fila-cats(..cs) = layout(size => {
    let xs = cs.pos()
    let w = (size.width - (xs.len() - 1) * 8pt) / xs.len()
    let h = calc.max(..xs.map(c => measure(block(width: w, cat(..c))).height))
    block(above: 0pt, below: 8pt, grid(columns: (1fr,) * xs.len(), column-gutter: 8pt, ..xs.map(c => cat(..c, alto: h))))
  })
  #fila-cats(
    ("Identidad y gobierno", col.iam, (("IAM", "usuarios, roles, políticas"), ("IAM Identity Center", "acceso centralizado"), ("Organizations", "multicuenta, SCP"), ("STS", "credenciales temporales"))),
    ("Redes", col.redes, (("VPC", "red privada virtual"), ("Transit Gateway", "hub de redes"), ("PrivateLink", "servicios privados"), ("VPN / Direct Connect", "conexión híbrida"))),
    ("Cómputo", col.computo, (("EC2", "máquinas virtuales"), ("EBS / EFS", "discos y ficheros"), ("EC2 Image Builder", "AMI doradas"), ("Systems Manager", "operación de flotas"))),
  )
  #fila-cats(
    ("Balanceo y escalado", col.balanceo, (("ALB", "capa 7, HTTP/HTTPS"), ("NLB", "capa 4, TCP/UDP"), ("GWLB", "appliances de red"), ("Auto Scaling", "elasticidad"))),
    ("Contenedores", col.contenedores, (("ECS", "orquestador de AWS"), ("Fargate", "sin servidores"), ("ECR", "registro de imágenes"), ("App Runner", "web apps gestionadas"))),
    ("Kubernetes", col.contenedores, (("EKS", "Kubernetes gestionado"), ("EKS Auto Mode", "nodos gestionados"), ("Karpenter", "autoescalado de nodos"), ("EKS Pod Identity", "roles IAM para pods"))),
  )
  #fila-cats(
    ("Serverless", col.serverless, (("Lambda", "funciones bajo demanda"), ("API Gateway", "API gestionadas"), ("Step Functions", "orquestación"), ("SAM", "despliegue serverless"))),
    ("Almacenamiento", col.almacenamiento, (("S3", "almacenamiento de objetos"), ("S3 Glacier", "archivo"), ("FSx", "sistemas de ficheros"), ("AWS Backup", "copias centralizadas"))),
    ("Bases de datos", col.datos, (("RDS / Aurora", "relacionales"), ("DynamoDB", "clave-valor NoSQL"), ("ElastiCache", "caché en memoria"), ("Redshift", "data warehouse"))),
  )
  #fila-cats(
    ("Integración", col.integracion, (("SQS", "colas"), ("SNS", "pub/sub"), ("EventBridge", "bus de eventos"), ("Kinesis", "streaming"))),
    ("Edge y DNS", col.edge, (("CloudFront", "CDN global"), ("Route 53", "DNS gestionado"), ("Global Accelerator", "red global de AWS"), ("Lambda@Edge", "código en el borde"))),
    ("Observabilidad", col.observabilidad, (("CloudWatch", "métricas, logs, alarmas"), ("CloudTrail", "auditoría de API"), ("X-Ray", "trazas distribuidas"), ("AWS Config", "estado y cumplimiento"))),
  )
  #fila-cats(
    ("Seguridad", col.seguridad, (("KMS", "claves de cifrado"), ("Secrets Manager", "secretos"), ("ACM", "certificados TLS"), ("WAF / Shield", "protección web"), ("GuardDuty", "detección de amenazas"))),
    ("IaC y DevOps", col.iac, (("CloudFormation", "plantillas declarativas"), ("CDK", "IaC programable"), ("Terraform", "IaC multiproveedor"), ("CodePipeline / CodeBuild", "CI/CD"))),
    ("Costes", col.costes, (("Cost Explorer", "análisis de gasto"), ("Budgets", "presupuestos y alertas"), ("Savings Plans", "descuentos por compromiso"), ("Compute Optimizer", "ajuste de tamaño"))),
  )
]

#indice()

// ---------------------------------------------------------------------
//  Capítulos
// ---------------------------------------------------------------------
#set page(numbering: "1")
#counter(page).update(1)

#include "capitulos/01-fundamentos.typ"
#include "capitulos/02a-iam-identidades.typ"
#include "capitulos/02b-iam-permisos.typ"
#include "capitulos/03-redes.typ"
#include "capitulos/04-ec2.typ"
#include "capitulos/05-balanceo.typ"
#include "capitulos/06-contenedores.typ"
#include "capitulos/06b-kubernetes.typ"
#include "capitulos/07-serverless.typ"
#include "capitulos/08-almacenamiento.typ"
#include "capitulos/09-bases-datos.typ"
#include "capitulos/10-mensajeria.typ"
#include "capitulos/11-cloudfront.typ"
#include "capitulos/12-observabilidad.typ"
#include "capitulos/13-seguridad.typ"
#include "capitulos/14-iac.typ"
#include "capitulos/15-costes.typ"
#include "capitulos/16-arquitecturas.typ"

// ---------------------------------------------------------------------
//  Apéndices
// ---------------------------------------------------------------------
#include "capitulos/A-glosario.typ"
#include "capitulos/B-chuleta.typ"
