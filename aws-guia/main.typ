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
    text(13pt, fill: white.transparentize(15%),
      [Los conceptos esenciales para diseñar, construir y operar en la nube: de IAM y las redes a los contenedores, las bases de datos, la mensajería y la entrega de contenido.])
    v(22pt)
    let temas = ("IAM", "VPC", "EC2", "ELB", "ECS", "Lambda", "S3", "RDS", "DynamoDB", "SQS", "SNS", "CloudFront", "CloudWatch", "KMS", "CloudFormation")
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

  Esta guía recorre los servicios y conceptos de AWS que aparecen una y otra vez en cualquier proyecto real: identidad y permisos, redes, cómputo, contenedores y Kubernetes, *serverless*, almacenamiento, bases de datos, mensajería, entrega de contenido, observabilidad, seguridad y cifrado, infraestructura como código y costes. Cada capítulo empieza por el *porqué* de cada servicio, construye los conceptos paso a paso y termina con un resumen y preguntas de repaso.

  Puedes leerla de principio a fin —el orden está pensado para que cada capítulo se apoye en los anteriores— o saltar directamente al servicio que necesites. Los capítulos de *Fundamentos*, *IAM* y *Redes* son la base de todo lo demás: si eres nuevo en AWS, empieza por ellos. IAM ocupa dos capítulos a propósito: el primero responde a *quién* (usuarios, grupos, roles y *permission sets*) y el segundo a *qué puede hacer* (políticas y evaluación de permisos). Es el tema que más dudas genera y el que más conviene dominar.

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
  - Los nombres de servicios y la terminología técnica se mantienen en inglés, como los verás en la consola y la documentación (*bucket*, *Security Group*, *listener*…), explicados la primera vez que aparecen.
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
  AWS ofrece más de doscientos servicios, pero la inmensa mayoría de arquitecturas se construyen con un núcleo reducido. Este mapa agrupa los que trata esta guía por categoría; el color de cada categoría es el mismo que verás en los capítulos y en los diagramas.
  #v(8pt)
  #let cat(nombre, color, servicios) = block(
    width: 100%, radius: 7pt, clip: true, stroke: 0.8pt + color.lighten(50%), breakable: false,
    {
      block(width: 100%, spacing: 0pt, fill: gradient.linear(color, color.darken(25%)), inset: (x: 10pt, y: 7pt),
        text(9pt, weight: "bold", fill: white, upper(nombre)))
      block(width: 100%, spacing: 0pt, inset: (x: 10pt, y: 8pt), fill: color.lighten(95%), {
        set par(justify: false, leading: 0.5em)
        for (s, d) in servicios {
          block(below: 5pt, [#text(8.4pt, weight: "bold", fill: color.darken(20%), s) #h(2pt) #text(7.6pt, fill: gris, d)])
        }
      })
    },
  )
  #grid(columns: (1fr, 1fr, 1fr), column-gutter: 8pt, row-gutter: 8pt,
    cat("Identidad y gobierno", col.iam, (("IAM", "usuarios, roles, políticas"), ("IAM Identity Center", "acceso centralizado"), ("Organizations", "multi-cuenta, SCP"), ("STS", "credenciales temporales"))),
    cat("Redes", col.redes, (("VPC", "red privada virtual"), ("Transit Gateway", "hub de redes"), ("PrivateLink", "servicios privados"), ("VPN / Direct Connect", "conexión híbrida"))),
    cat("Cómputo", col.computo, (("EC2", "máquinas virtuales"), ("EBS / EFS", "discos y ficheros"), ("Auto Scaling", "elasticidad"), ("Systems Manager", "operación de flotas"))),
    cat("Balanceo", col.balanceo, (("ALB", "capa 7, HTTP/HTTPS"), ("NLB", "capa 4, TCP/UDP"), ("GWLB", "appliances de red"), ("ACM", "certificados TLS"))),
    cat("Contenedores", col.contenedores, (("ECS", "orquestador de AWS"), ("Fargate", "contenedores sin servidores"), ("ECR", "registro de imágenes"), ("EKS", "Kubernetes gestionado"))),
    cat("Serverless", col.serverless, (("Lambda", "funciones bajo demanda"), ("API Gateway", "APIs gestionadas"), ("Step Functions", "orquestación"), ("App Runner", "web apps gestionadas"))),
    cat("Almacenamiento", col.almacenamiento, (("S3", "almacenamiento de objetos"), ("S3 Glacier", "archivo"), ("FSx", "sistemas de ficheros"), ("AWS Backup", "copias centralizadas"))),
    cat("Bases de datos", col.datos, (("RDS / Aurora", "relacionales"), ("DynamoDB", "clave-valor NoSQL"), ("ElastiCache", "caché en memoria"), ("Redshift", "data warehouse"))),
    cat("Integración", col.integracion, (("SQS", "colas"), ("SNS", "pub/sub"), ("EventBridge", "bus de eventos"), ("Kinesis", "streaming"))),
    cat("Edge y DNS", col.edge, (("CloudFront", "CDN global"), ("Route 53", "DNS gestionado"), ("Global Accelerator", "red global de AWS"), ("Lambda@Edge", "código en el borde"))),
    cat("Observabilidad", col.observabilidad, (("CloudWatch", "métricas, logs, alarmas"), ("CloudTrail", "auditoría de API"), ("X-Ray", "trazas distribuidas"), ("AWS Config", "estado y cumplimiento"))),
    cat("Seguridad", col.seguridad, (("KMS", "claves de cifrado"), ("Secrets Manager", "secretos"), ("WAF / Shield", "protección web"), ("GuardDuty", "detección de amenazas"))),
  )
  #v(4pt)
  #grid(columns: (1fr, 1fr), column-gutter: 8pt,
    cat("Infraestructura como código", col.iac, (("CloudFormation", "plantillas declarativas"), ("CDK", "IaC con lenguajes de programación"), ("CodePipeline / CodeBuild", "CI/CD"))),
    cat("Costes", col.costes, (("Cost Explorer", "análisis de gasto"), ("Budgets", "presupuestos y alertas"), ("Savings Plans", "descuentos por compromiso"))),
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
