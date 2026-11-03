# Guía visual de AWS (Typst)

Documento en español que explica los conceptos esenciales de Amazon Web Services:
IAM, redes (VPC), EC2, balanceo y Auto Scaling, contenedores (ECS/EKS), serverless,
S3, bases de datos, mensajería (SQS/SNS/EventBridge/Kinesis), CloudFront y Route 53,
observabilidad, seguridad, IaC, costes y arquitecturas de referencia.

## Compilar

Requiere [Typst](https://typst.app) 0.13 o superior. Las fuentes (Inter, JetBrains Mono,
DejaVu Sans; licencias libres OFL/Bitstream) van incluidas en `fonts/`.

```bash
typst compile --font-path fonts main.typ guia-aws.pdf
# o en modo edición continua
typst watch --font-path fonts main.typ guia-aws.pdf
```

## Estructura

- `main.typ` — portada, páginas preliminares, índice e inclusión de capítulos.
- `theme.typ` — sistema visual: colores, aperturas de capítulo, cajas, fichas, tablas y diagramas.
- `capitulos/` — un archivo por capítulo y los apéndices.
- `GUIA-ESTILO.md` — convenciones y referencia de componentes para escribir capítulos.
