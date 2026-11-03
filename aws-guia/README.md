# Guía visual de AWS (Typst)

Documento en español (219 páginas, más de 100 diagramas) que explica los conceptos esenciales
de Amazon Web Services, desde cero y con un enfoque muy visual. El PDF compilado está en
[`guia-aws.pdf`](guia-aws.pdf).

## Contenido

| # | Capítulo |
|---|----------|
| 1 | Fundamentos de AWS y la nube |
| 2 | IAM (I): identidades — usuarios, grupos, roles y permission sets |
| 3 | IAM (II): permisos — políticas y evaluación |
| 4 | Redes: VPC y conectividad |
| 5 | EC2: cómputo en la nube |
| 6 | Balanceo de carga y Auto Scaling |
| 7 | Contenedores: ECS, Fargate, ECR y EKS |
| 8 | Kubernetes y Amazon EKS |
| 9 | Serverless: Lambda, API Gateway y Step Functions |
| 10 | Almacenamiento: S3 y compañía |
| 11 | Bases de datos |
| 12 | Mensajería e integración: SQS, SNS, EventBridge y Kinesis |
| 13 | CloudFront, Route 53 y el borde de la red |
| 14 | Observabilidad: logging, métricas y auditoría |
| 15 | Seguridad: cifrado con KMS, secretos y protección |
| 16 | Infraestructura como código y DevOps |
| 17 | Costes y optimización |
| 18 | Arquitecturas de referencia |
| A | Glosario |
| B | Chuleta de referencia rápida |

Cada capítulo abre con sus objetivos, combina explicaciones, fichas de servicio, diagramas,
tablas comparativas, ejemplos de código y cajas de consejos, y termina con un resumen y
preguntas de repaso con respuesta.

## Compilar

Requiere [Typst](https://typst.app) 0.13 o superior. Las fuentes (Inter, JetBrains Mono y
DejaVu Sans, con licencias libres) van incluidas en `fonts/`, así que no hace falta instalar nada más
ni descargar paquetes.

```bash
typst compile --font-path fonts main.typ guia-aws.pdf
# o en modo edición continua
typst watch --font-path fonts main.typ guia-aws.pdf
```

## Estructura

- `main.typ` — portada, páginas preliminares, mapa de servicios, índice e inclusión de capítulos.
- `theme.typ` — sistema visual: colores, aperturas de capítulo, cajas, fichas, tablas y diagramas.
- `capitulos/` — un archivo por capítulo y los apéndices.
- `GUIA-ESTILO.md` — convenciones y referencia de componentes para escribir o ampliar capítulos.

Los precios y límites de AWS cambian con frecuencia: los datos reflejan la situación en el
momento de redactar la guía (2026); consulta siempre la documentación oficial.
