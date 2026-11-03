#import "../theme.typ": *

// ---------------------------------------------------------------------
//  Utilidades locales del capítulo
// ---------------------------------------------------------------------
#let verde = rgb("#2F9E44")
#let rojo = rgb("#E03131")

// Barra de reparto de tráfico entre versión actual (gris) y nueva (color)
#let barra(p, ancho: 2.1cm) = columna(espacio: 2pt,
  box(width: ancho, height: 0.4cm, radius: 2pt, clip: true, stroke: 0.5pt + gris.lighten(45%), {
    place(left + top, rect(width: 100%, height: 100%, fill: gris-claro))
    if p > 0% { place(right + top, rect(width: p, height: 100%, fill: col.iac)) }
  }),
  text(6.3pt, fill: gris, str(int(p / 1%)) + " % en v2"),
)

// Sección de una plantilla (diagrama de anatomía)
#let seccion(nombre, desc, color: col.iac, obligatoria: false) = block(
  width: 100%, height: 1.6cm, radius: 5pt, clip: true, stroke: 0.7pt + color.lighten(40%), fill: white, {
    block(width: 100%, spacing: 0pt, fill: color, inset: (x: 6pt, y: 4pt), {
      text(7.4pt, weight: "bold", fill: white, font: "JetBrains Mono", nombre)
      if obligatoria { h(1fr); text(6pt, weight: "bold", fill: white, tracking: 0.5pt, "OBLIGATORIA") }
    })
    block(width: 100%, spacing: 0pt, inset: (x: 6pt, y: 4pt), align(left, {
      set par(justify: false, leading: 0.5em)
      text(7.6pt, desc)
    }))
  })

#capitulo("Infraestructura como código y DevOps", color: col.iac,
  subtitulo: [Describe tu infraestructura en ficheros versionados y despliégala con pipelines automáticos, revisables y repetibles.],
  objetivos: (
    [Por qué usar IaC y qué es el drift],
    [Plantillas y funciones de CloudFormation],
    [Change sets, rollback y políticas de borrado],
    [CDK, SAM y Terraform: cuándo usar cada uno],
    [CodePipeline, CodeBuild y CodeDeploy],
    [Rolling, blue/green, canary y feature flags],
  ),
  servicios: ("CloudFormation", "AWS CDK", "AWS SAM", "Terraform", "CodePipeline", "CodeBuild", "CodeDeploy", "AppConfig"))

== Por qué infraestructura como código

Crear recursos haciendo clic en la consola —la llamada _ClickOps_— sirve para aprender, pero no escala: nadie recuerda qué casillas marcó hace seis meses, replicar un entorno en otra región es un proyecto y los cambios se aplican sin revisión. Con *infraestructura como código* (IaC) describes la infraestructura en ficheros de texto, los guardas en Git junto a la aplicación y una herramienta crea, modifica o borra recursos hasta que la cuenta coincide con lo escrito.

Así la infraestructura se vuelve *reproducible* (dev, staging y producción salen de la misma plantilla), *revisable* (antes de aplicar ves qué se creará, cambiará o borrará) y *trazable* (Git guarda quién cambió qué, cuándo y por qué, y permite volver atrás). Y tiene una única fuente de verdad, que destapa el *drift* (deriva): la diferencia entre lo que declara tu código y lo que existe de verdad en la cuenta. Suele nacer de un cambio manual «urgente» que nadie llevó al código, y el siguiente despliegue puede deshacerlo sin avisar.

#diagrama(pie: [Flujo de trabajo con IaC: el repositorio es la fuente de verdad y solo el pipeline modifica las cuentas. Un cambio manual en la consola aparece como _drift_.])[
  #grid(columns: 7, align: center + horizon,
    actor(etiqueta: "Equipo"),
    flecha(etiqueta: "commit", largo: 1.2cm),
    svc("Git", "Repositorio", sub: "GitHub, GitLab…", color: col.neutro),
    flecha(etiqueta: "pull request", largo: 1.6cm),
    svc("CI/CD", "Pipeline", sub: "lint · tests · plan", color: col.iac),
    flecha(etiqueta: "aplica", largo: 1.2cm),
    svc("IaC", "Motor de IaC", sub: [CloudFormation\ o Terraform], color: col.iac),
    [], [], [], [], [], [], flecha-v(largo: 0.6cm),
    grid.cell(colspan: 7, zona("Cuentas AWS · dev, staging, prod", color: col.fundamentos, punteada: false, relleno: white)[
      #fila(espacio: 6pt,
        actor(etiqueta: "Cambio manual", color: rojo),
        flecha(etiqueta: "drift", largo: 1.2cm, color: rojo, punteada: true),
        svc("VPC", "Red", color: col.redes),
        svc("EC2", "Cómputo", color: col.computo),
        svc("RDS", "Datos", color: col.datos),
        svc("S3", "Buckets", color: col.almacenamiento))
    ]),
  )
]

#tarjetas(
  tarjeta("Declarativo", subtitulo: "describes el estado deseado")[«Quiero un bucket versionado». La herramienta calcula qué falta y en qué orden, y es *idempotente*: aplicar dos veces lo mismo no crea nada nuevo. CloudFormation, Terraform y CDK (que solo *genera* una plantilla declarativa).],
  tarjeta("Imperativo", color: col.neutro, subtitulo: "describes los pasos")[«Crea el bucket, luego activa el versionado…». Tú gestionas orden, errores y estado previo. Scripts con AWS CLI o un SDK: útiles para tareas puntuales, frágiles para toda una infraestructura.],
)

== AWS CloudFormation

CloudFormation, el servicio de IaC nativo de AWS, convierte una *plantilla* YAML o JSON en un *stack*: recursos que se crean, actualizan y borran como una unidad, en paralelo cuando se puede y deshaciendo los cambios si algo falla.

#ficha("AWS CloudFormation", "Infraestructura declarativa nativa de AWS",
  ("Unidad", [*Stack*: recursos con un ciclo de vida común, en una cuenta y una región]),
  ("Coste", [Gratuito para los recursos de AWS: pagas lo que crea (las extensiones de terceros, por operación)]),
  ("Extras", [Change sets, drift, StackSets e _IaC generator_ (plantillas a partir de lo ya desplegado)]))

#diagrama(pie: [Secciones de una plantilla de CloudFormation. Solo `Resources` es obligatoria; existen también `Metadata`, `Rules` y `Transform` (macros, como la de SAM).])[
  #grid(columns: (1fr, 1fr, 1fr), column-gutter: 7pt, row-gutter: 7pt,
    seccion("AWSTemplateFormatVersion", [Versión del formato (siempre 2010-09-09) y una descripción opcional.], color: col.neutro),
    seccion("Parameters", [Entradas al crear o actualizar el stack: entorno, tipo de instancia, CIDR…]),
    seccion("Mappings", [Tablas estáticas de búsqueda: valores por región o por entorno.]),
    seccion("Conditions", [Booleanos para crear recursos o fijar propiedades según el caso.]),
    seccion("Resources", [Cada recurso, con su *ID lógico*, su tipo y sus propiedades.], color: col.iac.darken(25%), obligatoria: true),
    seccion("Outputs", [Valores de salida; con `Export`, otros stacks pueden importarlos.]),
  )
]

Esta plantilla crea un bucket y una función Lambda que procesa sus objetos. Es pequeña, pero usa todas las secciones:

```yaml
AWSTemplateFormatVersion: "2010-09-09"
Parameters:
  Entorno: { Type: String, AllowedValues: [dev, prod], Default: dev }
Mappings:
  PorEntorno:
    dev:  { Memoria: 256 }
    prod: { Memoria: 1024 }
Conditions:
  EsProd: !Equals [!Ref Entorno, prod]
Resources:
  Subidas:
    Type: AWS::S3::Bucket
    DeletionPolicy: Retain                  # sobrevive al borrado del stack
    UpdateReplacePolicy: Retain
    Properties:
      VersioningConfiguration:
        Status: !If [EsProd, Enabled, Suspended]
  Procesador:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: !Sub "procesador-${Entorno}-${AWS::Region}"
      Runtime: python3.13
      Handler: index.handler
      MemorySize: !FindInMap [PorEntorno, !Ref Entorno, Memoria]
      Role: !ImportValue base-RolLambdaArn  # exportado por otro stack
      Code:
        ZipFile: "def handler(event, context): print(event)"
Outputs:
  ArnBucket:
    Value: !GetAtt Subidas.Arn
    Export: { Name: !Sub "${AWS::StackName}-ArnBucket" }
```

Las *funciones intrínsecas* calculan valores al desplegar (en YAML, con la forma corta `!Funcion`); los *pseudoparámetros* como `AWS::Region`, `AWS::AccountId` o `AWS::StackName` los rellena CloudFormation y evitan escribir regiones o cuentas a mano:

#tabla(("Función", "Qué devuelve", "Ejemplo"), columnas: (1fr, 2.1fr, 2.3fr), tamano: 8pt,
  [`!Ref`], [Valor de un parámetro o ID físico de un recurso (nombre del bucket, ID de instancia).], [`!Ref Entorno`],
  [`!GetAtt`], [Un atributo del recurso: ARN, nombre DNS, endpoint…], [`!GetAtt Subidas.Arn`],
  [`!Sub`], [Una cadena con las variables `${...}` sustituidas.], [`!Sub "app-${Entorno}"`],
  [`!ImportValue`], [Un valor exportado por otro stack (misma cuenta y región).], [`!ImportValue red-VpcId`],
  [`!FindInMap`, `!If`], [Un valor de `Mappings`; un valor condicional.], [`!If [EsProd, Enabled, Suspended]`],
)

=== Change sets, drift y rollback

En producción no actualices un stack a ciegas: crea antes un *change set*, una vista previa de cada recurso que se añadirá, modificará o eliminará y de si la modificación exige *reemplazarlo* (`Replacement: True`): crear uno nuevo y borrar el antiguo, con el riesgo de perder datos. Pasa, por ejemplo, al cambiar el nombre de un bucket.

#diagrama(pie: [Actualizar un stack con un _change set_: primero ves el impacto y luego decides si lo ejecutas. Si algo falla, CloudFormation vuelve al estado anterior.])[
  #grid(columns: 7, align: center + horizon,
    caja([*Plantilla v2*\ #text(6.5pt, fill: gris)[cambio en Git]], color: col.iac),
    flecha(etiqueta: "change set", largo: 1.5cm),
    caja([*Change set*\ #text(6.5pt, fill: gris)[Add · Modify · Remove\ Replacement: True / False]], color: col.iac),
    flecha(etiqueta: "ejecutar", largo: 1.3cm),
    svc("CFN", "Stack", sub: "UPDATE_IN_PROGRESS", color: col.iac),
    flecha(etiqueta: "éxito", largo: 1.1cm, color: verde),
    caja([UPDATE_COMPLETE], color: verde),
    [], [], [], [], flecha-v(etiqueta: "error", largo: 0.6cm, color: rojo), [], [],
    [], [], [], grid.cell(colspan: 3, caja([*Rollback automático a v1*\ #text(6.5pt, fill: gris)[UPDATE_ROLLBACK_COMPLETE]], color: rojo)), [],
  )
]

Si falla la creación de un stack, CloudFormation borra lo que había creado; si falla una actualización, vuelve a la configuración anterior. Los *rollback triggers* revierten además el despliegue si salta una alarma de CloudWatch. La *detección de drift* compara cada recurso con la plantilla y marca el stack como `IN_SYNC` o `DRIFTED`, con el detalle de cada propiedad cambiada.

=== Políticas de borrado y reemplazo

`DeletionPolicy` decide qué pasa con un recurso al borrar el stack (o quitarlo de la plantilla); `UpdateReplacePolicy`, qué pasa con el recurso *antiguo* cuando una actualización lo reemplaza:

#tabla(("Valor", "Qué hace", "Úsalo en"), columnas: (1.65fr, 2.5fr, 1.6fr), tamano: 8pt,
  [`Delete`], [Borra el recurso. Es el valor por defecto en casi todos los tipos.], [Funciones, roles, Security Groups],
  [`Retain`], [Conserva el recurso, que deja de estar gestionado por el stack.], [Buckets, tablas DynamoDB, claves KMS],
  [`Snapshot`], [Crea una instantánea final y después borra el recurso.], [RDS, Aurora, EBS, ElastiCache],
  [`RetainExceptOnCreate`], [Como `Retain`, salvo si falla la creación inicial: entonces borra y no deja restos.], [Recursos con datos en stacks nuevos],
)

#cuidado[Hay excepciones: en `AWS::RDS::DBCluster` (y en las instancias de RDS que no pertenecen a un clúster) el valor por defecto es `Snapshot`, y un bucket S3 solo se borra si está vacío. En producción, activa además la *protección contra terminación* del stack.]

=== Reutilizar y compartir: nested stacks, exports y StackSets

#tabla(("Mecanismo", "Qué es", "Cuándo usarlo"), columnas: (1.15fr, 2.5fr, 2.2fr), tamano: 8pt,
  [*Nested stacks*], [Un stack padre incluye plantillas hijas (recurso `AWS::CloudFormation::Stack`); se despliegan juntos, como una unidad.], [Reutilizar componentes estándar (un ALB, una VPC tipo) dentro de una aplicación.],
  [*Exports + `!ImportValue`*], [Un stack exporta salidas y otros las importan; no puedes borrar ni cambiar un export mientras alguien lo importe.], [Compartir valores (VPC, subredes) entre stacks de la misma cuenta y región. Menos acoplado: Parameter Store y `{{resolve:ssm:...}}`.],
  [*StackSets*], [Despliega el mismo stack en muchas cuentas y regiones; integrado con Organizations, cubre automáticamente las cuentas nuevas de una OU.], [Línea base de seguridad en toda la organización: roles de auditoría, reglas de Config, alarmas.],
)

== AWS CDK y AWS SAM

El *AWS Cloud Development Kit* (CDK) define la infraestructura con TypeScript, JavaScript, Python, Java, C\# o Go: bucles, funciones, clases, tipos, autocompletado y tests. Por debajo no hay magia: tu programa (una *App* con uno o más *Stacks*) *sintetiza* plantillas de CloudFormation y es CloudFormation quien las despliega, así que heredas change sets, rollback y drift. Es gratuito y de código abierto. Las piezas se llaman *constructs* y tienen tres niveles:

/ L1 (`Cfn*`): equivalen 1:1 a los recursos de CloudFormation (`CfnBucket`, `CfnFunction`…): control total, sin valores por defecto.
/ L2 (curados): los más usados (`s3.Bucket`, `lambda.Function`…), con valores por defecto sensatos y ayudas como `grantRead()`.
/ L3 (patrones): arquitecturas completas; el módulo `ecs_patterns`, por ejemplo, crea un servicio Fargate tras un ALB con clúster, roles y logs.

```typescript
import { App, Stack, Duration, RemovalPolicy } from 'aws-cdk-lib';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as lambda from 'aws-cdk-lib/aws-lambda';

const app = new App();
const stack = new Stack(app, 'Subidas-dev', { env: { region: 'eu-west-1' } });

const bucket = new s3.Bucket(stack, 'Subidas', {
  versioned: true, enforceSSL: true, removalPolicy: RemovalPolicy.RETAIN,
});
const fn = new lambda.Function(stack, 'Procesador', {
  runtime: lambda.Runtime.PYTHON_3_13, handler: 'index.handler',
  code: lambda.Code.fromAsset('lambda'),     // carpeta local → asset en S3
  timeout: Duration.seconds(30),
});
bucket.grantRead(fn);                        // política IAM de mínimo privilegio
```

#diagrama(pie: [Del código al despliegue con CDK. `cdk synth` genera plantilla y _assets_, `cdk diff` compara con lo desplegado y `cdk deploy` sube los _assets_ a los recursos creados por `cdk bootstrap` (una vez por cuenta y región) y lanza el stack.])[
  #fila(
    caja([*app.ts*\ #text(6.5pt, fill: gris)[TypeScript, Python…]], color: col.iac),
    flecha(etiqueta: "cdk synth", largo: 1.5cm),
    caja([*cdk.out\/*\ #text(6.5pt, fill: gris)[plantilla + assets]], color: col.iac),
    flecha(etiqueta: "cdk deploy", largo: 1.6cm),
    svc("CFN", "CloudFormation", sub: "stack", color: col.iac),
    flecha(largo: 1.1cm),
    svc("AWS", "Recursos", color: col.fundamentos),
  )
  #v(4pt)
  #caja([*cdk bootstrap* (stack CDKToolkit, una vez por cuenta y región): bucket de assets, repositorio ECR y roles IAM], color: col.neutro, relleno: gris-claro.lighten(50%))
]

*AWS SAM*, presentado en el capítulo de Serverless, es la otra gran extensión de CloudFormation: una macro (`Transform: AWS::Serverless-2016-10-31`) que expande tipos abreviados como `AWS::Serverless::Function` en función, rol, permisos, API y eventos, con su propia CLI (`sam build`, `sam local invoke`, `sam deploy`).

== Terraform

*Terraform*, de HashiCorp, es la herramienta de IaC más extendida fuera de AWS: con su lenguaje declarativo, *HCL*, y sus *proveedores* gestiona AWS, otras nubes y cientos de servicios con el mismo flujo: `terraform init`, `plan` (qué cambiará) y `apply`.

A diferencia de CloudFormation, Terraform guarda un *fichero de estado* que relaciona cada recurso con su identificador real. Es crítico y puede contener secretos: guárdalo en un *backend remoto* (un bucket S3 versionado, cifrado y restringido) con *bloqueo*, para que dos `apply` simultáneos no lo corrompan. Desde Terraform 1.11 el backend S3 bloquea de forma nativa con `use_lockfile = true`; la tabla de DynamoDB que se usaba antes está marcada como obsoleta.

```hcl
terraform {
  required_providers { aws = { source = "hashicorp/aws", version = "~> 6.0" } }
  backend "s3" {
    bucket       = "miempresa-tfstate"
    key          = "subidas/prod/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true            # bloqueo nativo en S3
  }
}
provider "aws" {
  region = "eu-west-1"
  default_tags { tags = { Proyecto = "subidas" } }   # etiquetas en todo
}
resource "aws_s3_bucket" "subidas" { bucket = "miempresa-subidas-prod" }
```

#block(breakable: false, tabla(("", "CloudFormation", "AWS CDK", "Terraform"), columnas: (1.1fr, 1.3fr, 1.3fr, 1.5fr), tamano: 8pt,
  [*Lenguaje*], [YAML o JSON], [TypeScript, Python, Java, C\#, Go], [HCL],
  [*Estado*], [Lo guarda AWS (el stack)], [Lo guarda AWS (vía CloudFormation)], [Fichero de estado que gestionas tú],
  [*Vista previa*], [Change sets], [`cdk diff`], [`terraform plan`],
  [*Rollback automático*], si, [#si vía CloudFormation], [#no se corrige y se vuelve a aplicar],
  [*Elígelo si…*], [Quieres plantillas sin dependencias externas], [Todo está en AWS y tu equipo programa], [Usas varios proveedores (o *OpenTofu*, su fork abierto desde 2023)],
))

== CI/CD en AWS

La *integración continua* (CI) compila y prueba cada cambio en cuanto llega al repositorio; la *entrega* o *despliegue continuo* (CD) lleva ese artefacto ya probado hasta los entornos sin pasos manuales. AWS ofrece tres piezas gestionadas:

#tarjetas(columnas: 3,
  tarjeta("CodePipeline", subtitulo: "el orquestador")[Etapas (Source → Build → Deploy), aprobaciones manuales y despliegues con CloudFormation, ECS, CodeDeploy o S3.],
  tarjeta("CodeBuild", subtitulo: "compilar y probar")[Contenedores efímeros que ejecutan tu `buildspec.yml` y publican artefactos e informes de tests. Pagas por tiempo de compilación.],
  tarjeta("CodeDeploy", subtitulo: "desplegar con seguridad")[EC2 u on-premises (_in-place_ o blue/green), Lambda y ECS (canary, lineal), con rollback por alarmas.],
)

#let cols-pipe = (0.5cm, 2.2cm, 0.5cm, 2.2cm, 0.5cm, 2.2cm, 0.5cm, 2.2cm, 0.5cm, 2.2cm, 0.5cm)
#let etapa(t, d) = caja(ancho: 2.2cm, [*#t*\ #text(6.2pt, fill: gris)[#d]], color: col.iac)

#diagrama(pie: [Pipeline típico: el código vive en GitHub, CodePipeline orquesta las etapas desde una cuenta de herramientas y despliega en las cuentas de staging y producción asumiendo un rol de despliegue en cada una.])[
  #grid(columns: cols-pipe, align: center + horizon,
    [], caja(ancho: 2.2cm, [*GitHub*\ #text(6.2pt, fill: gris)[push a main]], color: col.neutro), [], [], [], [], [], [], [], [], [],
    [], flecha-v(etiqueta: "CodeConnections", largo: 0.7cm), [], [], [], [], [], [], [], [], [],
  )
  #v(-3pt)
  #zona("CodePipeline · cuenta de herramientas", color: col.iac)[
    #grid(columns: cols-pipe, align: center + horizon,
      [], etapa("Source", "commit en main"), flecha(largo: 0.5cm),
      etapa("Build", "CodeBuild: tests, imagen → ECR"), flecha(largo: 0.5cm),
      etapa("Staging", "despliegue + pruebas"), flecha(largo: 0.5cm),
      etapa("Aprobación", "manual"), flecha(largo: 0.5cm),
      etapa("Producción", "blue/green o canary"), [],
    )
  ]
  #grid(columns: cols-pipe, align: center + horizon,
    [], [], [], [], [], flecha-v(etiqueta: "asume rol", largo: 0.7cm), [], [], [], flecha-v(etiqueta: "asume rol", largo: 0.7cm), [],
    [], [], [],
    grid.cell(colspan: 3, zona("Cuenta staging", color: col.fundamentos, ancho: 100%)[#caja([CloudFormation\ servicio ECS], color: col.contenedores)]),
    [],
    grid.cell(colspan: 3, zona("Cuenta producción", color: col.iam, ancho: 100%)[#caja([CloudFormation\ servicio ECS], color: col.contenedores)]),
    [],
  )
]


#nota(titulo: "¿Dónde vive el código?")[*AWS CodeCommit*, el servicio de repositorios Git de AWS, dejó de aceptar clientes nuevos en julio de 2024 y volvió a abrirse a ellos el 25 de noviembre de 2025. Aun así, lo habitual es usar GitHub, GitLab o Bitbucket conectados a CodePipeline con *AWS CodeConnections* (antes CodeStar Connections), o el CI del propio proveedor. Si usas GitHub Actions, no guardes claves de acceso en el repositorio: federación OIDC con un rol que solo acepte tu repositorio y rama (capítulo «IAM (I): identidades — usuarios, grupos, roles y permission sets»).]

Este `buildspec.yml` ejecuta los tests, construye la imagen, la sube a ECR y genera el `imagedefinitions.json` que consume la acción de despliegue en ECS:

```yaml
version: 0.2
env:
  variables:
    REPO: 111111111111.dkr.ecr.eu-west-1.amazonaws.com/api
phases:
  pre_build:
    commands:
      - npm ci && npm test
      - aws ecr get-login-password | docker login -u AWS --password-stdin ${REPO%/*}
      - TAG=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c1-7)
  build:
    commands:
      - docker build -t $REPO:$TAG . && docker push $REPO:$TAG
  post_build:
    commands:
      - printf '[{"name":"api","imageUri":"%s"}]' $REPO:$TAG > imagedefinitions.json
artifacts:
  files: [imagedefinitions.json]
```

== Estrategias de despliegue

Desplegar es decidir *cómo* pasa el tráfico de la versión actual (v1) a la nueva (v2) y cómo vuelves atrás si algo va mal.

#let nota-est(t) = box(width: 3.3cm, align(left, { set par(justify: false, leading: 0.45em); text(6.8pt, fill: tinta, t) }))
#diagrama(pie: [Reparto del tráfico entre v1 (gris) y v2 (color) a lo largo de un despliegue, con la vuelta atrás y el coste de cada estrategia.])[
  #grid(columns: 6, column-gutter: 8pt, row-gutter: 7pt,
    align: (right + horizon, center + horizon, center + horizon, center + horizon, center + horizon, left + horizon),
    [], text(7pt, weight: "bold", fill: gris)[Paso 1], text(7pt, weight: "bold", fill: gris)[Paso 2],
    text(7pt, weight: "bold", fill: gris)[Paso 3], text(7pt, weight: "bold", fill: gris)[Paso 4], [],
    text(8pt, weight: "bold")[Rolling], barra(25%), barra(50%), barra(75%), barra(100%),
    nota-est[Sustituye instancias o tareas por lotes. Sin coste extra; volver atrás es otra ronda de lotes.],
    text(8pt, weight: "bold")[Blue/green], barra(0%), barra(0%), barra(100%), barra(100%),
    nota-est[v2 completa en paralelo, se prueba y recibe todo el tráfico. Vuelta atrás inmediata; doble capacidad un rato.],
    text(8pt, weight: "bold")[Canary], barra(10%), barra(10%), barra(100%), barra(100%),
    nota-est[Un 10 % a v2, observación y luego el resto (o _lineal_: incrementos iguales). Rollback automático por alarma.],
  )
]

Desplegar *todo a la vez* es lo más simple, pero implica corte y una vuelta atrás lenta; las demás estrategias las ofrecen CodeDeploy, ECS (de forma nativa desde 2025), los alias ponderados de Lambda y los target groups del ALB. Los *feature flags* separan *desplegar* de *lanzar*: el código llega desactivado y lo enciendes por configuración para un porcentaje de usuarios. *AWS AppConfig* los gestiona: valida cada cambio, lo propaga gradualmente con un periodo de observación (_bake time_) y lo revierte si salta una alarma.

== Entornos y buenas prácticas

- *Una cuenta por entorno* (dev, staging, prod), con el pipeline en una cuenta de herramientas que asume roles de despliegue (en CDK, `cdk bootstrap --trust`); la estructura completa, en el capítulo de Arquitecturas de referencia.
- *El mismo artefacto y la misma plantilla en todos los entornos*: solo cambian los parámetros, y los secretos se leen de Secrets Manager o Parameter Store.
- Consola de *solo lectura* en producción, stacks *pequeños y por ciclo de vida*, y el change set o el `plan` revisados en la _pull request_.
- Mínimo privilegio para el pipeline, OIDC en lugar de claves y etiquetas desde el código (lo agradecerá el capítulo de Costes).

#resumen[
- La IaC hace la infraestructura *reproducible, revisable y trazable* y destapa el *drift* de los cambios manuales.
- Una plantilla de CloudFormation tiene `Parameters`, `Mappings`, `Conditions`, `Resources` (la única obligatoria) y `Outputs`; `!Ref`, `!GetAtt`, `!Sub` e `!ImportValue` conectan las piezas.
- Los *change sets* muestran el impacto antes de ejecutar y, si algo falla, hay *rollback*; `DeletionPolicy` y `UpdateReplacePolicy` protegen los datos. *Nested stacks*, *exports* y *StackSets* reutilizan, comparten y llevan stacks a muchas cuentas.
- CDK genera CloudFormation desde código (constructs L1, L2, L3); Terraform gestiona varios proveedores con un *fichero de estado* en S3 con bloqueo (`use_lockfile`).
- CodePipeline orquesta, CodeBuild prueba y CodeDeploy o ECS despliegan (rolling, blue/green, canary); AppConfig da feature flags.
- Una cuenta por entorno, el mismo artefacto en todos, el pipeline asumiendo roles de despliegue y OIDC en lugar de claves de acceso.
]

#repaso(
  ([¿Qué es el drift y cómo lo detectas?], [La diferencia entre el código y la realidad, casi siempre por cambios manuales. Con la detección de drift de CloudFormation o con `terraform plan`.]),
  ([¿Qué diferencia hay entre `!Ref` y `!GetAtt`?], [`!Ref` devuelve un parámetro o el ID físico del recurso (el nombre de un bucket); `!GetAtt`, un atributo como el ARN.]),
  ([¿Cómo evitas perder una base de datos RDS al borrar el stack o al reemplazarla?], [`DeletionPolicy` y `UpdateReplacePolicy` con `Snapshot` o `Retain`, protección contra terminación y revisar `Replacement` en el change set.]),
  ([¿Por qué hay que bloquear el estado de Terraform?], [Para que dos ejecuciones simultáneas no lo corrompan; en AWS, backend S3 con `use_lockfile = true`.]),
  ([¿En qué se diferencian blue/green y canary?], [Blue/green cambia todo el tráfico de una vez a una versión nueva completa (vuelta atrás inmediata); canary envía antes un pequeño porcentaje y observa las alarmas.]),
)
