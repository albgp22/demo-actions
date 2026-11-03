#import "../theme.typ": *

// ---------------------------------------------------------------------
//  Ayudas locales para los diagramas de este capítulo
// ---------------------------------------------------------------------
#let k8s = col.contenedores
#let gf = rgb("#7A8699") // gris de las flechas del tema

// Pod en miniatura. `punteado`: pod que aún no existe; `caido`: pod perdido.
#let pod(t: "pod", color: col.contenedores, ancho: 0.95cm, punteado: false, caido: false) = box(
  width: ancho, height: 0.7cm, radius: 4pt,
  fill: if caido { rgb("#FFF0F0") } else if punteado { white } else { color.lighten(82%) },
  stroke: (
    paint: if caido { rgb("#E03131") } else { color },
    thickness: 1pt,
    dash: if punteado or caido { "dashed" } else { none },
  ),
  align(center + horizon, {
    set par(justify: false, leading: 0.3em)
    text(6.2pt, weight: "bold", fill: if caido { rgb("#C92A2A") } else { color.darken(35%) }, t)
  }),
)

// Componente: nombre en negrita y descripción breve opcional
#let comp(nombre, desc: none, color: col.fundamentos, ancho: 3.1cm) = box(
  width: ancho, fill: white, stroke: 0.9pt + color, radius: 4pt, inset: (x: 4pt, y: 4pt),
  align(center, {
    set par(justify: false, leading: 0.35em)
    text(6.8pt, weight: "bold", fill: tinta, nombre)
    if desc != none { linebreak(); text(5.9pt, fill: gris, desc) }
  }),
)

// Icono pequeño con la etiqueta a la derecha (versión compacta de `svc`)
#let insignia(abbr, texto, color: col.neutro) = box(inset: 1pt, grid(
  columns: 2, column-gutter: 4pt, align: horizon,
  box(width: 0.8cm, height: 0.8cm, radius: 4pt,
    fill: gradient.linear(color.lighten(8%), color.darken(18%), angle: 90deg),
    align(center + horizon, text(6.8pt, weight: "bold", fill: white, abbr))),
  align(left, {
    set par(justify: false, leading: 0.35em)
    text(6.8pt, weight: "semibold", fill: tinta, texto)
  }),
))

// Flecha hacia la izquierda (espejo de `flecha` del tema)
#let flecha-izq(etiqueta: none, largo: 1.4cm, color: gf, punteada: false) = box(
  width: largo, height: 2.6em, {
    let st = (paint: color, thickness: 1.2pt, dash: if punteada { "dashed" } else { none })
    place(right + horizon, line(length: largo - 5pt, stroke: st))
    place(left + horizon, polygon(fill: color, (7pt, 0pt), (0pt, 3.5pt), (7pt, 7pt)))
    if etiqueta != none {
      place(center + top, dy: -1pt, box(width: largo + 0.8cm, align(center, {
        set par(justify: false, leading: 0.3em)
        text(6.4pt, fill: color.darken(25%), weight: "medium", etiqueta)
      })))
    }
  },
)

// Bifurcación: una entrada arriba y dos flechas hacia abajo separadas `sep`
#let bifurca(sep, alto: 0.8cm, color: gf, etiqueta: none) = box(width: sep + 8pt, height: alto, {
  let st = (paint: color, thickness: 1.2pt)
  let cx = (sep + 8pt) / 2
  let ym = alto * 0.4
  place(line(start: (cx, 0pt), end: (cx, ym), stroke: st))
  place(line(start: (4pt, ym), end: (sep + 4pt, ym), stroke: st))
  for x in (4pt, sep + 4pt) {
    place(line(start: (x, ym), end: (x, alto - 6pt), stroke: st))
    place(dx: x - 3.5pt, dy: alto - 7pt, polygon(fill: color, (0pt, 0pt), (7pt, 0pt), (3.5pt, 7pt)))
  }
  if etiqueta != none {
    place(dx: cx + 6pt, dy: -1pt, text(6.4pt, fill: color.darken(25%), weight: "medium", etiqueta))
  }
})

// Nodo de trabajo con sus componentes y sus pods
#let nodo(titulo, pods) = zona(titulo, color: col.computo)[
  #columna(espacio: 3pt,
    fila(espacio: 3pt,
      comp("kubelet", color: col.computo, ancho: 1.3cm),
      comp("kube-proxy", color: col.computo, ancho: 1.3cm),
      comp("containerd", color: col.computo, ancho: 1.3cm)),
    fila(espacio: 3pt, ..pods.map(p => pod(t: p))),
  )
]

#capitulo("Kubernetes y Amazon EKS", color: col.contenedores,
  subtitulo: [Del modelo declarativo de Kubernetes a un clúster gestionado en AWS: pods, servicios, escalado, redes, almacenamiento e identidades.],
  objetivos: (
    [Qué problema resuelve Kubernetes y su modelo declarativo],
    [La arquitectura de un clúster: control plane y nodos],
    [Pods, Deployments, Services y el resto de objetos esenciales],
    [Qué gestiona AWS en EKS y cómo elegir el data plane],
    [Redes, balanceadores y almacenamiento en EKS],
    [IAM en EKS: acceso al clúster y permisos de los pods],
  ),
  servicios: ("Amazon EKS", "EKS Auto Mode", "AWS Fargate", "Amazon EC2", "Elastic Load Balancing", "Amazon EBS", "Amazon EFS"))


== ¿Qué problema resuelve Kubernetes?

En el capítulo de Contenedores (ECS, Fargate y ECR) viste cómo ejecutar aplicaciones en contenedores. Con cientos de ellos repartidos entre decenas de máquinas surgen preguntas difíciles: ¿dónde coloco cada uno?, ¿quién lo reinicia si se cae?, ¿cómo actualizo sin cortar el servicio?, ¿cómo se encuentran entre sí si sus IP cambian? Responderlas es *orquestar*, y *Kubernetes* («timonel» en griego, abreviado *K8s*) es el orquestador de código abierto más extendido: nació en Google a partir de Borg, su sistema interno, se liberó en 2014, lo custodia la Cloud Native Computing Foundation (CNCF) y funciona igual en tu portátil, en tu centro de datos o en cualquier nube. Se encarga de:

- *Planificar*: decide en qué máquina (*nodo*) corre cada contenedor, según los recursos que pide.
- *Autorreparar*: reinicia lo que falla y recrea en otro nodo lo que corría en un nodo caído.
- *Escalar y desplegar sin corte*, con marcha atrás si algo sale mal.
- *Descubrir y balancear*: nombres DNS estables delante de contenedores efímeros.

=== El modelo declarativo y el bucle de reconciliación

Kubernetes es *declarativo*: no le das órdenes («arranca tres contenedores»), sino que describes el resultado («que siempre haya tres copias de esta imagen») en un fichero YAML llamado *manifiesto*. Kubernetes guarda ese *estado deseado* y unos procesos llamados *controladores* lo comparan sin descanso con el *estado actual*; si difieren, actúan para igualarlos. Es el *bucle de reconciliación*.

#analogia[Un termostato. Fijas 21 °C (estado deseado); él mide la temperatura (estado actual) y enciende o apaga la calefacción hasta igualarlas, también cuando alguien abre una ventana. No le dices «enciende la caldera diez minutos», sino el resultado que quieres. Si un nodo muere con un contenedor dentro, Kubernetes «nota el frío» y lo recrea en otro nodo, sin intervención humana.]

#diagrama(pie: [El bucle de reconciliación: el controlador compara sin descanso el estado deseado con el actual y actúa hasta igualarlos.])[
  #fila(espacio: 2pt,
    zona("Estado deseado (etcd)", color: col.fundamentos, punteada: false, relleno: white)[
      #columna(espacio: 5pt,
        fila(espacio: 2pt, actor(etiqueta: "Tú"), flecha(etiqueta: "kubectl apply", largo: 1.45cm),
          box(fill: rgb("#F7F9FC"), stroke: 0.6pt + gris-claro, radius: 3pt, inset: 5pt,
            text(6.6pt, font: "JetBrains Mono", fill: tinta, [kind: Deployment\ replicas: 3]))),
        fila(espacio: 4pt, pod(t: "web"), pod(t: "web"), pod(t: "web")),
        text(6.3pt, fill: gris, [«quiero tres réplicas de web»]),
      )
    ],
    flecha(etiqueta: "lee", largo: 1cm),
    box(width: 3cm, fill: white, stroke: 1.2pt + k8s, radius: 6pt, inset: 7pt, align(center, {
      set par(justify: false, leading: 0.45em)
      text(7.6pt, weight: "bold", fill: k8s.darken(30%), "Controlador")
      v(1pt)
      align(left, text(6.5pt, fill: tinta)[
        *1* · observa el estado actual \
        *2* · compara: 3 deseados, 2 reales \
        *3* · actúa: pide un pod nuevo \
        #text(fill: k8s.darken(20%), weight: "bold")[↻ y vuelta a empezar]
      ])
    })),
    columna(espacio: 0pt,
      flecha(etiqueta: "actúa", largo: 1.25cm),
      flecha-izq(etiqueta: "observa", largo: 1.25cm)),
    zona("Estado actual (nodos)", color: k8s, punteada: false, relleno: white)[
      #columna(espacio: 5pt,
        fila(espacio: 4pt, pod(t: "web"), pod(t: "web"), pod(t: "✘ web", caido: true)),
        fila(espacio: 4pt, text(6.3pt, fill: gris, [nodo caído:]), pod(t: "nuevo", punteado: true)),
        text(6.3pt, fill: gris, [el pod perdido se recrea en otro nodo]),
      )
    ],
  )
]

== Arquitectura de un clúster

Un *clúster* tiene dos partes: el *control plane* (plano de control), el cerebro que guarda el estado y toma las decisiones, y los *nodos* (_worker nodes_), las máquinas (en AWS, instancias EC2) donde corren los contenedores. Sus componentes son estos (figura siguiente):

/ kube-apiserver: la puerta de entrada: expone la API y autentica, autoriza y valida cada petición.
/ etcd: base de datos clave-valor distribuida con todo el estado del clúster; solo el API server accede a ella.
/ kube-scheduler: elige el nodo de cada pod nuevo según sus requests, sus restricciones y el hueco libre.
/ kube-controller-manager: ejecuta los controladores integrados (réplicas, nodos, Jobs...).
/ cloud-controller-manager: integra con la nube: nodos que desaparecen, balanceadores...
/ kubelet: el agente de cada nodo; arranca los contenedores de sus pods y vigila su salud.
/ kube-proxy: programa en cada nodo las reglas de red que hacen funcionar los Services.
/ Container runtime: ejecuta los contenedores; normalmente *containerd*, a través de la interfaz CRI.

#diagrama(pie: [Arquitectura de un clúster. Todos los componentes se comunican a través del API server, y solo él lee y escribe en etcd.])[
  #fila(espacio: 4pt,
    actor(etiqueta: "Tú"),
    flecha(etiqueta: "kubectl (HTTPS)", largo: 1.5cm),
    zona("Control plane", color: col.fundamentos, punteada: false, relleno: white)[
      #fila(espacio: 2pt,
        svc("etcd", "etcd", sub: "el estado del clúster", color: col.datos),
        flecha(doble: true, largo: 0.8cm),
        svc("API", "kube-apiserver", sub: "la puerta de entrada", color: k8s),
        flecha(doble: true, largo: 0.8cm),
        columna(espacio: 3pt,
          comp("kube-scheduler"),
          comp("kube-controller-manager"),
          comp("cloud-controller-manager"),
        ),
      )
    ],
  )
  #flecha-v(etiqueta: "kubelet y kube-proxy ⇄ API server", doble: true, largo: 0.75cm)
  #fila(espacio: 8pt,
    nodo("Nodo 1 · EC2", ("web", "web", "api")),
    nodo("Nodo 2 · EC2", ("web", "api", "logs")),
    nodo("Nodo 3 · EC2", ("api", "db-0", "logs")),
  )
]

== Los objetos fundamentales

Todo en Kubernetes es un *objeto* de la API descrito en YAML, con un tipo (`kind`), unos metadatos (nombre, namespace, labels) y una especificación (`spec`) con el estado deseado. La figura resume cómo se conectan los principales.

#diagrama(pie: [Cómo se relacionan los objetos: el Deployment gestiona un ReplicaSet, que mantiene los pods; el Service los encuentra por su label y el Ingress le envía el tráfico HTTP; la configuración y los volúmenes se montan en los pods.])[
  #zona("Namespace tienda", color: k8s)[
    #grid(columns: 5, align: center + horizon, column-gutter: 3pt,
      svc("ING", "Ingress", sub: "reglas HTTP", color: col.balanceo),
      [],
      fila(espacio: 2pt,
        svc("DEP", "Deployment", sub: "imagen, réplicas, estrategia", color: k8s),
        flecha(etiqueta: "gestiona", largo: 1.1cm),
        svc("RS", "ReplicaSet", sub: "mantiene 3 copias", color: k8s)),
      [], [],
      flecha-v(etiqueta: "enruta a", largo: 0.6cm), [],
      align(right, box(width: 2.6cm, align(center, flecha-v(etiqueta: "crea y vigila", largo: 0.6cm)))),
      [], [],
      svc("SVC", "Service", sub: "IP y DNS estables", color: col.redes),
      flecha(etiqueta: "selector app=web", largo: 1.9cm),
      zona("Pods con label app=web", color: k8s, punteada: false, relleno: white)[
        #fila(espacio: 4pt, pod(t: "web"), pod(t: "web"), pod(t: "web"))
      ],
      flecha-izq(etiqueta: "se montan", largo: 1.2cm),
      columna(espacio: 3pt,
        comp("ConfigMap", desc: "configuración", color: col.iac, ancho: 2.4cm),
        comp("Secret", desc: "contraseñas, tokens", color: col.seguridad, ancho: 2.4cm),
        comp("PVC → PV", desc: "volumen persistente", color: col.almacenamiento, ancho: 2.4cm)),
    )
  ]
]

=== Pods y controladores de carga de trabajo

Un *Pod* es la unidad mínima de despliegue: uno o varios contenedores que comparten IP y volúmenes y corren juntos en un nodo (normalmente uno principal y, a veces, un *sidecar* auxiliar). Los pods son efímeros: si mueren, un controlador crea otros, con otra IP. Por eso se gestionan con estos objetos:

#tabla(("Objeto", "Qué garantiza (y ejemplo típico)"), columnas: (0.9fr, 4.6fr),
  [*Deployment*], [Aplicaciones sin estado, como una API web. Escala y hace *rolling updates*: cambia pods viejos por nuevos poco a poco, sin corte, al ritmo de `maxSurge` y `maxUnavailable` (25 % por defecto), con vuelta atrás. Por debajo gestiona *ReplicaSets*, que mantienen _N_ copias idénticas.],
  [*StatefulSet*], [Pods con identidad estable (`db-0`, `db-1`...), DNS propio y un volumen persistente cada uno, creados en orden: bases de datos, Kafka.],
  [*DaemonSet*], [Un pod en cada nodo (o en los elegidos): agentes de logs y de métricas, el plugin de red.],
  [*Job* / *CronJob*], [Pods que se ejecutan hasta terminar con éxito, con reintentos; el CronJob los lanza con horario cron: migraciones, informes.],
)

=== Services, DNS e Ingress

Un *Service* da a un grupo de pods, elegidos por su *selector* de labels, una IP virtual y un nombre DNS estables, y reparte el tráfico entre los que están listos. Sus tres tipos principales se apilan, cada uno sobre el anterior:

#tarjetas(
  tarjeta("ClusterIP", subtitulo: "Por defecto · solo interno")[IP alcanzable solo dentro del clúster, para que los microservicios se hablen.],
  tarjeta("NodePort", subtitulo: "Un puerto en cada nodo")[Abre un puerto (30000–32767 por defecto) en todos los nodos. Rara vez se usa solo.],
  tarjeta("LoadBalancer", subtitulo: "Balanceador de la nube")[Pide a la nube un balanceador externo; en EKS, un Network Load Balancer.],
)

*CoreDNS*, el DNS interno, registra cada Service como `<servicio>.<namespace>.svc.cluster.local`: desde el namespace `tienda` basta con llamar a `http://pagos`. Un *Ingress* publica varios Services tras un único balanceador con reglas HTTP por host y ruta, que aplica un *Ingress controller* (en EKS, creando un ALB). Su sucesora es la *Gateway API*, más expresiva y orientada a roles (`Gateway` para la infraestructura, `HTTPRoute` para las rutas de cada equipo). La API de Ingress está congelada y en noviembre de 2025 se anunció la retirada del popular controlador ingress-nginx: en diseños nuevos, considera primero Gateway API, que el AWS Load Balancer Controller implementa en sus versiones recientes.

=== Configuración, organización y recursos

/ ConfigMap y Secret: configuración no sensible y sensible (contraseñas, tokens), fuera de la imagen; llegan al pod como variables de entorno o como ficheros.
/ Namespace: partición lógica para equipos o entornos, con sus propios permisos (RBAC) y cuotas. No aísla la red por sí solo.
/ Labels y selectors: etiquetas clave-valor (`app: web`) y consultas sobre ellas, el pegamento de Kubernetes: Services y Deployments encuentran sus pods por selector, nunca por nombre.
/ Requests y limits: las requests son lo reservado (el scheduler busca un nodo con ese hueco); los limits, el máximo: por encima del de CPU se frena al contenedor (_throttling_) y por encima del de memoria se le mata (`OOMKilled`). `250m` es un cuarto de vCPU.

#cuidado[Un Secret solo está codificado en Base64, que *no* es cifrado: quien pueda leerlo con la API lo ve en claro. Restringe su lectura con RBAC y guarda los secretos críticos en AWS Secrets Manager, llevándolos al pod con el Secrets Store CSI Driver o con External Secrets Operator.]

Las *probes* son las comprobaciones de salud que kubelet hace a cada contenedor (por HTTP, TCP, gRPC o con un comando):

#tabla(("Probe", "Pregunta", "Si falla..."), columnas: (0.75fr, 1.4fr, 2.65fr),
  [*startup*], [¿Ha terminado de arrancar?], [Las otras dos esperan a que pase: protege a las aplicaciones lentas en arrancar.],
  [*liveness*], [¿Sigue vivo o se ha colgado?], [kubelet lo reinicia. Que mire solo el propio proceso: si comprueba la base de datos y esta cae, reiniciará todos los pods en bucle.],
  [*readiness*], [¿Puede atender tráfico ahora?], [Se le retira de los Services, sin reiniciarlo, hasta que se recupere.],
)

Para los datos que deben sobrevivir al pod, Kubernetes separa lo que pides de lo que te dan:

/ PersistentVolumeClaim (PVC): la petición: «20 GiB en modo `ReadWriteOnce`» (un nodo; `ReadWriteMany` si son varios).
/ PersistentVolume (PV): el volumen real que la satisface; en AWS, un volumen EBS o un sistema de ficheros EFS.
/ StorageClass: la receta para crear PV bajo demanda (_aprovisionamiento dinámico_): qué driver y con qué parámetros.

== Manos a la obra: YAML, kubectl y Helm

Así se describe una aplicación web: un Deployment con tres réplicas y un Service que las agrupa. Fíjate en cómo las labels conectan ambos objetos.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata: { name: web, namespace: tienda }
spec:
  replicas: 3                       # estado deseado: tres pods
  selector:
    matchLabels: { app: web }       # qué pods gestiona
  template:                         # plantilla de cada pod
    metadata:
      labels: { app: web }          # debe coincidir con el selector
    spec:
      containers:
        - name: web
          image: 123456789012.dkr.ecr.eu-west-1.amazonaws.com/web:1.4.2
          resources:
            requests: { cpu: 250m, memory: 256Mi }   # lo que se reserva
            limits: { memory: 512Mi }                # el máximo
          readinessProbe: { httpGet: { path: /ready, port: 8080 } }
          livenessProbe: { httpGet: { path: /healthz, port: 8080 } }
---
apiVersion: v1
kind: Service
metadata: { name: web, namespace: tienda }
spec:                               # type: ClusterIP, el valor por defecto
  selector: { app: web }            # envía el tráfico a los pods app=web
  ports: [{ port: 80, targetPort: 8080 }]
```

Lo aplicas con `kubectl apply -f web.yaml`. Si cambias la imagen a `web:1.5.0` y vuelves a aplicar, el Deployment crea un ReplicaSet nuevo y hace un rolling update: arranca pods nuevos, espera a que pasen su readiness probe y retira los viejos; `kubectl rollout undo` vuelve atrás. Usa etiquetas de imagen fijas, nunca `latest`. Los comandos que más usarás:

```bash
kubectl get pods -n tienda -o wide        # pods con su nodo y su IP
kubectl describe pod web-7d4b9            # detalle y eventos (¿por qué Pending?)
kubectl logs web-7d4b9 -f                 # logs (--previous: del que se cayó)
kubectl exec -it web-7d4b9 -- sh          # shell dentro del contenedor
kubectl rollout status deploy/web         # progreso de un despliegue
kubectl port-forward svc/web 8080:80      # prueba un Service desde tu equipo
kubectl auth can-i delete pods -n tienda  # ¿me lo permite RBAC?
```

*Helm* es el gestor de paquetes de Kubernetes: un *chart* empaqueta plantillas YAML y un `values.yaml` con sus parámetros; cada instalación es una *release* versionada que puedes actualizar o revertir (`helm upgrade`, `helm rollback`). Así se instala el controlador de balanceadores de la sección de redes:

```bash
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system --set clusterName=prod
```

Completan el kit *Kustomize* (`kubectl apply -k`) y *GitOps*: Argo CD o Flux reconcilian el clúster con un repositorio Git.

== Escalado: pods y nodos

Kubernetes escala en dos niveles: más pods cuando sube la carga y más nodos cuando los pods ya no caben.

/ HorizontalPodAutoscaler (HPA): ajusta las réplicas para mantener una métrica objetivo, como la CPU respecto a las requests (requiere Metrics Server): `kubectl autoscale deployment web --cpu-percent=60 --min=3 --max=20`.
/ VerticalPodAutoscaler (VPA): recalcula las requests de cada pod según su consumo real; no lo combines con un HPA sobre la misma métrica.
/ KEDA: escala por eventos, como los mensajes pendientes en una cola SQS, incluso hasta cero.

Los pods que no caben en ningún nodo quedan en `Pending`: el HPA decide *cuántos* pods; el autoscaler de nodos, *dónde* caben.

#tarjetas(
  tarjeta("Cluster Autoscaler", subtitulo: "El clásico, basado en grupos de nodos")[Sube o baja la capacidad deseada del Auto Scaling group de cada node group. Cada grupo usa tipos de instancia similares: si un pod necesita GPU, debe existir un grupo para ello.],
  tarjeta("Karpenter", color: col.computo, subtitulo: "Nodos a la medida · open source, creado por AWS")[Lanza directamente, sin Auto Scaling groups, las instancias EC2 que mejor encajan con los pods pendientes (On-Demand o Spot) y *consolida* nodos para ahorrar. Es el motor de EKS Auto Mode y la opción recomendable en clústeres nuevos.],
)

== Amazon EKS: Kubernetes gestionado

Operar Kubernetes por tu cuenta obliga a cuidar etcd, la alta disponibilidad del API server, los certificados y las actualizaciones. *Amazon Elastic Kubernetes Service (EKS)* te da un control plane estándar, certificado por la CNCF, en el que tus manifiestos y herramientas funcionan como en cualquier Kubernetes. AWS lo ejecuta en una VPC propia, con al menos dos instancias del API server y tres de etcd en tres AZ, y lo conecta con tus nodos mediante interfaces de red (ENI) en tus subredes; su endpoint puede ser público (restringible por CIDR), privado o ambos.

#ficha("Amazon EKS", "Kubernetes gestionado: AWS opera el control plane y tú decides dónde corren los pods",
  ("Ámbito", [Regional; control plane repartido en tres zonas de disponibilidad]),
  ("AWS gestiona", [El control plane (disponibilidad, escalado y parches), versiones compatibles de los add-ons y, con Fargate o Auto Mode, los nodos]),
  ("Tú gestionas", [Cuándo actualizar; los nodos EC2 (salvo en Auto Mode); aplicaciones, acceso, IAM de los pods, red y costes]),
  ("Facturación", [Por clúster y hora, más el cómputo y los recursos que uses]),
  ("Fuera de AWS", [EKS Anywhere y EKS Hybrid Nodes (nodos propios unidos a un clúster EKS)]))

#coste[Orientativamente, 0,10 USD por clúster y hora en soporte estándar (unos 73 USD al mes) y 0,60 USD/h en soporte extendido; consulta los precios de tu región. Súmale el cómputo (EC2; en Fargate, vCPU y memoria por pod; en Auto Mode, EC2 más un recargo por instancia), balanceadores, volúmenes EBS, NAT Gateway, IPv4 públicas y tráfico entre AZ. Por esa tarifa fija, en entornos pequeños suele salir más barato compartir un clúster con namespaces que tener muchos.]

=== ¿Dónde se ejecutan tus pods? Opciones de data plane

#tabla(("Opción", "Quién opera los nodos", "Escalado de nodos", "DaemonSets", "Pagas", "Encaja si..."),
  columnas: (1.15fr, 2fr, 1.3fr, 0.85fr, 1.05fr, 1.3fr), tamano: 7.9pt,
  [*Managed node groups*], [AWS gestiona el Auto Scaling group y renueva los nodos cuando se lo pides], [Cluster Autoscaler o Karpenter], si, [EC2], [Quieres EC2 con poco esfuerzo],
  [*Nodos autogestionados*], [Tú: grupo, AMI, arranque y parches], [Cluster Autoscaler o Karpenter], si, [EC2], [Necesitas algo muy a medida],
  [*Fargate*], [AWS: cada pod en su propia micro-VM; no ves nodos], [Implícito, pod a pod], no, [vCPU y memoria por pod], [Cargas pequeñas o esporádicas],
  [*Karpenter* (lo instalas tú)], [Tú operas Karpenter; él lanza y retira instancias EC2], [A la medida de los pods pendientes], si, [EC2 (On-Demand o Spot)], [Cargas variadas, Spot],
  [*EKS Auto Mode*], [AWS: nodos, sistema operativo, parches y add-ons clave], [Karpenter gestionado], si, [EC2 + recargo], [EC2 sin operar nodos],
)

#cuidado(titulo: "Fargate en EKS: lo que no puedes hacer")[Los *perfiles de Fargate* (por namespace y labels) deciden qué pods van a Fargate. Como cada pod tiene su propia micro-VM, no hay DaemonSets (los agentes van como sidecar; para logs hay un router integrado basado en Fluent Bit), ni contenedores privilegiados, GPU, `hostNetwork`, volúmenes EBS (sí EFS) o EKS Pod Identity (usa IRSA). Solo admite subredes privadas, y los balanceadores deben apuntar a la IP del pod.]

*EKS Auto Mode* (2024) es lo más «llave en mano» sin renunciar a EC2: un Karpenter gestionado aprovisiona nodos con AMI inmutables basadas en Bottlerocket (sin SSH ni SSM), renovados como máximo cada 21 días, y AWS se ocupa de la red de los pods, el DNS, el almacenamiento en bloque y los balanceadores. Las opciones se combinan: por ejemplo, Fargate para un namespace y Karpenter para el resto.

=== Crear tu primer clúster

La vía más rápida es *eksctl*, la CLI oficial de EKS: a partir de un fichero declarativo crea, con CloudFormation por debajo, la VPC, el clúster, los add-ons y los nodos.

```yaml
# cluster.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata: { name: prod, region: eu-west-1, version: "1.35" }
accessConfig: { authenticationMode: API }   # access entries, sin aws-auth
addons: [{ name: vpc-cni }, { name: coredns }, { name: kube-proxy },
         { name: eks-pod-identity-agent }]  # add-ons gestionados por EKS
managedNodeGroups:                          # nodos en subredes privadas
  - { name: general, instanceTypes: ["m7i.large", "m6i.large"],
      minSize: 2, desiredCapacity: 3, maxSize: 6, privateNetworking: true }
```

```bash
eksctl create cluster -f cluster.yaml     # VPC, clúster, add-ons y nodos
aws eks update-kubeconfig --region eu-west-1 --name prod
kubectl get nodes                         # tres nodos en estado Ready
```

`aws eks update-kubeconfig` añade el clúster a tu `~/.kube/config` (eksctl ya lo hace) para que `kubectl` se autentique con tus credenciales de IAM. Para Auto Mode, cambia `managedNodeGroups` por `autoModeConfig: { enabled: true }`. En producción lo habitual es Terraform (como el módulo `terraform-aws-modules/eks`) o AWS CDK (capítulo de IaC).

== Redes en EKS

=== Amazon VPC CNI: cada pod, una IP de tu VPC

En Kubernetes, un plugin de red (*CNI*, Container Network Interface) da una IP a cada pod. En EKS se usa *Amazon VPC CNI* (el DaemonSet `aws-node`): cada pod recibe una IP *real* de la subred de su nodo, tomada de las IP secundarias de las ENI de la instancia. Sin redes superpuestas (_overlay_) ni encapsulación, los pods son ciudadanos de primera de la VPC: aparecen en los VPC Flow Logs y un ALB o una base de datos los alcanzan directamente.

#cuidado(titulo: "El gran riesgo: quedarte sin IP")[Cada pod consume una IP de la subred, y cada nodo reserva algunas más por adelantado. Una subred /24 (251 IP utilizables) se agota enseguida y los pods nuevos se atascan en `ContainerCreating`. Además, las ENI e IP que admite cada tipo de instancia limitan los pods por nodo (29 en un `m5.large`). Planifica subredes grandes desde el principio.]

/ Prefix delegation: asigna prefijos /28 (16 IP) en vez de IP sueltas: muchos más pods por nodo en instancias Nitro, pero exige bloques /28 libres y contiguos en la subred.
/ Custom networking: los pods toman IP de otras subredes, normalmente de un CIDR secundario como `100.64.0.0/16`, sin gastar direcciones enrutables de tu red (se configura por AZ con `ENIConfig`).
/ IPv6: un clúster IPv6 elimina el problema de raíz, si todo tu entorno lo soporta.

Con *Security Groups for Pods* puedes asignar Security Groups a pods concretos (por ejemplo, que solo los de `pagos` lleguen a RDS). Y como por defecto todos los pods hablan con todos, define *network policies*: firewalls a nivel de pod que fijan, por labels, namespaces o rangos de IP, qué tráfico se acepta. La VPC CNI las aplica de forma nativa si lo activas en el add-on (Calico y Cilium son alternativas); empieza denegándolo todo y abre solo lo necesario.

=== AWS Load Balancer Controller

El *AWS Load Balancer Controller* es otro controlador (otro bucle de reconciliación) que traduce objetos de Kubernetes en los balanceadores del capítulo de Balanceo y Auto Scaling. Un *Ingress* de clase `alb` se convierte en un *Application Load Balancer* con reglas por host y ruta (varios Ingress pueden compartirlo con una *IngressGroup*), y un *Service* `LoadBalancer`, en un *Network Load Balancer*. En modo de destino `ip`, el balanceador envía el tráfico directamente a la IP de cada pod gracias a la VPC CNI (obligatorio en Fargate); en modo `instance`, al NodePort de los nodos, con un salto extra por kube-proxy. Necesita permisos IAM (Pod Identity o IRSA) y localiza las subredes por sus etiquetas: `kubernetes.io/role/elb` en las públicas y `kubernetes.io/role/internal-elb` en las privadas. Sin él, Kubernetes recurre al proveedor heredado, que crea Classic Load Balancers; en Auto Mode ya viene integrado.

#diagrama(pie: [Tráfico de entrada en EKS: el ALB, con nodos en las subredes públicas de dos AZ, envía cada petición directamente a la IP de un pod (modo IP) en las subredes privadas. A la derecha, cómo el controlador crea y mantiene el ALB a partir del Ingress.])[
  #fila(espacio: 8pt,
    columna(espacio: 0pt,
      fila(actor(etiqueta: "Usuarios"), flecha(etiqueta: "HTTPS", largo: 1.3cm), internet()),
      bifurca(5.5cm + 10pt, alto: 0.7cm, etiqueta: "DNS del ALB"),
      zona("VPC 10.0.0.0/16", color: col.redes, punteada: false, relleno: white)[
        #fila(espacio: 10pt,
          ..("a", "b").map(az => zona("AZ " + az, color: col.neutro, ancho: 5.5cm)[
            #zona("Subred pública", color: col.almacenamiento)[
              #insignia("ALB", [Application Load Balancer \ #text(fill: gris, weight: "regular")[nodo en la AZ #az]], color: col.balanceo)
            ]
            #flecha-v(etiqueta: "a la IP del pod", largo: 0.6cm)
            #zona("Privada 10.0." + (if az == "a" { "32" } else { "64" }) + ".0/19 · nodos EC2", color: col.datos)[
              #fila(espacio: 4pt,
                pod(t: "web\n10.0." + (if az == "a" { "32.14" } else { "64.9" }), ancho: 1.35cm),
                pod(t: "web\n10.0." + (if az == "a" { "33.7" } else { "65.21" }), ancho: 1.35cm))
            ]
          ]))
      ],
    ),
    columna(espacio: 2pt,
      caja([Ingress \ `ingressClassName: alb`], color: k8s, ancho: 3cm),
      flecha-v(etiqueta: "observa", largo: 0.7cm, punteada: true),
      insignia("LBC", [AWS Load \ Balancer \ Controller], color: k8s),
      flecha-v(etiqueta: "API de ELB", largo: 0.7cm, punteada: true),
      caja([Crea el ALB, los \ listeners y los \ target groups], color: col.balanceo, ancho: 3cm),
    ),
  )
]

== Almacenamiento en EKS

Los PVC se convierten en almacenamiento de AWS gracias a los drivers *CSI* (Container Storage Interface), que se instalan como add-ons y necesitan permisos IAM:

#tabla(("Driver CSI", "Servicio", "Acceso", "Ámbito", "Úsalo para"), columnas: (1.35fr, 1fr, 1.4fr, 0.95fr, 1.45fr),
  [*EBS CSI driver*], [Amazon EBS (`gp3`, `io2`...)], [`ReadWriteOnce`: un nodo], [Una AZ], [Bases de datos y otros StatefulSets],
  [*EFS CSI driver*], [Amazon EFS], [`ReadWriteMany`: muchos pods y nodos], [Regional (varias AZ)], [Ficheros compartidos; la opción persistente en Fargate],
  [*Mountpoint for Amazon S3 CSI driver*], [Amazon S3], [Lectura masiva y escritura secuencial], [Regional], [Datasets de ML, contenido de solo lectura],
)

#cuidado[Un volumen EBS vive en una sola AZ: si su pod se reprograma en otra, no puede montarlo y queda en `Pending`. Usa una StorageClass con `volumeBindingMode: WaitForFirstConsumer` (el disco se crea en la AZ del pod) y, para alta disponibilidad, replica en la aplicación (una réplica por AZ) o usa EFS. Y ojo con la política `Retain`: conserva el disco al borrar el PVC, y sigue facturando.]

== IAM y EKS: dos direcciones que no debes confundir

En EKS conviven dos sistemas de permisos, IAM y el RBAC de Kubernetes, que se cruzan en dos direcciones opuestas: quién puede usar el clúster (de IAM hacia Kubernetes) y qué pueden hacer los pods en AWS (de Kubernetes hacia IAM).

#diagrama(pie: [Las dos direcciones de IAM en EKS. Arriba, una persona entra al clúster: IAM la identifica y RBAC decide qué puede hacer. Abajo, un pod actúa en AWS con el rol IAM asociado a su ServiceAccount.])[
  #zona("A · ¿Quién puede usar el clúster? (de IAM a Kubernetes)", color: col.iam, punteada: false, relleno: white)[
    #fila(espacio: 2pt,
      actor(etiqueta: "Ana (rol IAM)"),
      flecha(etiqueta: "kubectl + token IAM", largo: 1.9cm),
      svc("EKS", "API server de EKS", sub: "verifica la identidad", color: k8s),
      flecha(etiqueta: "access entry", largo: 1.6cm),
      caja([usuario y grupos \ de Kubernetes], color: col.iam),
      flecha(etiqueta: "RBAC", largo: 1.1cm),
      caja([#si ver pods en «tienda» \ #no borrar pods], color: col.iam),
    )
  ]
  #v(4pt)
  #zona("B · ¿Qué puede hacer el pod en AWS? (de Kubernetes a IAM)", color: k8s, punteada: false, relleno: white)[
    #fila(espacio: 2pt,
      columna(espacio: 2pt, pod(t: "web", ancho: 1.1cm), text(6pt, fill: gris, [ServiceAccount web])),
      flecha(etiqueta: "pide credenciales", largo: 1.9cm),
      svc("POD-ID", "Pod Identity o IRSA", sub: "asocia SA y rol", color: k8s),
      flecha(etiqueta: "asume", largo: 1.1cm),
      svc("IAM", "Rol web-lectura-s3", sub: "credenciales temporales", color: col.iam),
      flecha(etiqueta: "s3:GetObject", largo: 1.6cm),
      svc("S3", "Amazon S3", color: col.almacenamiento),
    )
  ]
]

=== RBAC: los permisos dentro de Kubernetes

Kubernetes autoriza cada petición a su API con *RBAC* (Role-Based Access Control) y cuatro objetos:

#tabla(("", "En un namespace", "En todo el clúster"), columnas: (1.9fr, 1fr, 1fr),
  [*Qué se permite*: reglas con verbos (`get`, `list`, `create`, `delete`...) sobre recursos], [`Role`], [`ClusterRole`],
  [*A quién*: usuarios, grupos o ServiceAccounts], [`RoleBinding`], [`ClusterRoleBinding`],
)

Un RoleBinding puede apuntar a un ClusterRole para concederlo en un solo namespace (así se reutilizan los roles integrados `view`, `edit` y `admin`). RBAC es solo aditivo, sin denegaciones, a diferencia de IAM (capítulo IAM (II)). Y Kubernetes no tiene objetos «usuario»: confía en que alguien externo autentique a quien llama; en EKS, ese alguien es IAM.

=== Dirección A: quién puede usar el clúster

Para cada petición, `kubectl` obtiene con `aws eks get-token` un token firmado con tus credenciales de IAM. EKS verifica tu identidad y busca la *access entry* (entrada de acceso) de tu ARN, que fija con qué usuario y grupos de Kubernetes entras. Los permisos llegan por grupos vinculados con tus RoleBinding o por *access policies* de EKS (`AmazonEKSClusterAdminPolicy`, `AmazonEKSAdminPolicy`, `AmazonEKSEditPolicy`, `AmazonEKSViewPolicy`) asociadas al clúster o a ciertos namespaces con `aws eks associate-access-policy`. Con IAM Identity Center, la entrada apunta al rol que crea el permission set (capítulo IAM (I)).

```bash
# 1) El rol IAM entra al clúster con el grupo de Kubernetes "desarrolladores"
aws eks create-access-entry --cluster-name prod \
  --principal-arn arn:aws:iam::123456789012:role/Desarrolladores \
  --kubernetes-groups desarrolladores
# 2) RBAC: ese grupo puede ver (rol integrado "view") el namespace tienda
kubectl create rolebinding devs-ven-tienda -n tienda \
  --clusterrole=view --group=desarrolladores
```

#cuidado(titulo: "Adiós al ConfigMap aws-auth")[Antes, el acceso se daba editando a mano el ConfigMap `aws-auth` de `kube-system`, y un error de formato podía dejar a todos fuera. Las access entries (2023) lo sustituyen: se gestionan con la API de EKS o tu IaC y quedan en CloudTrail. El clúster admite los modos de autenticación `CONFIG_MAP`, `API_AND_CONFIG_MAP` (para migrar) y `API`, el recomendado. La identidad que crea el clúster recibe acceso de administrador por defecto: no dependas de ella.]

#examen[*Unauthorized* en `kubectl` significa que EKS no te reconoce (falta tu access entry); *Forbidden*, que te reconoce pero RBAC no permite la acción. Los permisos IAM sobre la API de EKS (como `eks:DescribeCluster`) no dan acceso a los objetos de Kubernetes.]

=== Dirección B: qué pueden hacer los pods en AWS

Una aplicación que lee de S3 o escribe en DynamoDB nunca debe usar claves de acceso guardadas en un Secret ni el rol IAM del nodo: este lo heredan todos los pods del nodo, así que un contenedor comprometido tendría los permisos de todos. Lo correcto es asociar un rol IAM a la *ServiceAccount* del pod (su identidad en Kubernetes), de una de estas dos formas:

#tabla(("", "IRSA (IAM Roles for Service Accounts)", "EKS Pod Identity"), columnas: (1.15fr, 1.75fr, 1.75fr), tamano: 8.2pt,
  [*Cómo funciona*], [Proveedor OIDC del clúster en IAM; el SDK canjea el token del pod con `AssumeRoleWithWebIdentity`], [Un agente en cada nodo (add-on) entrega al pod credenciales del rol asociado],
  [*En IAM*], [Proveedor OIDC por clúster; la trust policy nombra clúster, namespace y ServiceAccount], [Trust policy estándar para `pods.eks.amazonaws.com`, igual en todos los clústeres],
  [*En Kubernetes*], [Anotación `eks.amazonaws.com/role-arn` en la ServiceAccount], [Nada: una *asociación* en la API de EKS],
  [*Reutilizar el rol en otro clúster*], [Hay que editar la trust policy], [Directo],
  [*Etiquetas de sesión (ABAC)*], no, si,
  [*Fargate y Kubernetes fuera de EKS*], si, no,
)

#practica[Usa EKS Pod Identity por defecto en nodos EC2 (e IRSA en Fargate), con un rol por aplicación. La asociación se crea con `aws eks create-pod-identity-association` (clúster, namespace, ServiceAccount y rol), y la trust policy del rol solo permite `sts:AssumeRole` y `sts:TagSession` a `pods.eks.amazonaws.com`. Bloquea además el acceso de los pods al servicio de metadatos (IMDS, capítulo de EC2): IMDSv2 con un límite de saltos (_hop limit_) de 1 en los nodos impide que un contenedor obtenga las credenciales del rol del nodo.]

== Operación del clúster

*Add-ons gestionados.* EKS ofrece como add-ons el software que el clúster necesita y que no es tu aplicación: AWS publica versiones probadas y compatibles con cada versión de Kubernetes, con sus parches, y tú decides cuándo instalarlas o actualizarlas. Los imprescindibles son *VPC CNI*, *CoreDNS* y *kube-proxy*; les siguen *EKS Pod Identity Agent*, los drivers CSI (*EBS*, *EFS*, *Mountpoint for S3*) y *CloudWatch Observability*.

*Versiones y actualizaciones.* Kubernetes publica unas tres versiones menores al año; EKS da a cada una un *soporte estándar* de algo más de un año y, después, un *soporte extendido* de aproximadamente otro año, con tarifa más alta. Al agotarse el soporte, EKS actualiza solo el control plane; con la *política de actualización* en `STANDARD`, lo hará al acabar el estándar, sin pasar por el extendido. Mejor adelantarse:

#pasos(
  [*Prepara*: notas de la versión y *EKS Cluster Insights*, que detecta, entre otras cosas, el uso de APIs que desaparecen.],
  [*Control plane*: una versión menor cada vez (de 1.34 a 1.35, nunca directamente a 1.36), sin vuelta atrás.],
  [*Add-ons*: a versiones compatibles con la nueva.],
  [*Nodos*: AMI nueva en los managed node groups; Karpenter reemplaza los desfasados (_drift_); en Fargate, reinicia los pods; Auto Mode lo hace solo. Los nodos pueden ir por detrás del control plane, nunca por delante.],
)

*Observabilidad* (capítulo de Observabilidad). *Container Insights* (CloudWatch, con su add-on) recoge métricas y logs de clúster, nodos, pods y contenedores; *Amazon Managed Service for Prometheus* almacena métricas de Prometheus sin servidores que operar (con un recolector gestionado sin agentes) y *Amazon Managed Grafana* las muestra en paneles; *Fluent Bit*, un DaemonSet ligero, envía los logs a CloudWatch Logs, S3 u OpenSearch. Los *logs del control plane* (API server, auditoría, autenticador, scheduler, controller manager) van a CloudWatch Logs, pero están desactivados por defecto: activa al menos el de auditoría.

*Cifrado de los Secrets con KMS.* Desde marzo de 2025, EKS cifra por defecto todos los datos de la API de Kubernetes, Secrets incluidos, en clústeres 1.28 o posteriores, con *cifrado de sobre* (_envelope encryption_): cada objeto se cifra con una clave de datos protegida por una clave de KMS propiedad de AWS, sin coste adicional. Para controlar tú esa clave (política, rotación, auditoría, revocación), usa una *customer managed key* de KMS (capítulo de Seguridad).

== Buenas prácticas y errores comunes

#tarjetas(columnas: 3,
  tarjeta("Fiabilidad", subtitulo: "Que nada se caiga")[
    - Dos o más réplicas repartidas entre AZ.
    - `PodDisruptionBudget`: renovar nodos no debe tumbar la app.
    - Requests, limits y probes en todo contenedor.
  ],
  tarjeta("Seguridad", color: col.iam, subtitulo: "Mínimo privilegio")[
    - Access entries y RBAC por namespace.
    - Un rol IAM por app (Pod Identity); IMDS bloqueado.
    - Pod Security Standards, network policies y endpoint privado o restringido.
  ],
  tarjeta("Coste y operación", color: col.costes, subtitulo: "Sin sorpresas")[
    - Karpenter o Auto Mode, con Spot y consolidación.
    - Requests ajustadas y ALB compartidos (IngressGroup).
    - Versiones en soporte estándar; todo en Git (IaC y GitOps).
  ],
)

#tabla(("Síntoma", "Causa habitual", "Por dónde empezar"), columnas: (1.05fr, 2.2fr, 1.45fr), tamano: 8.2pt,
  [`Pending`], [Ningún nodo tiene hueco para sus requests o cumple sus afinidades, o su volumen EBS está en otra AZ], [`kubectl describe pod` y el autoscaler de nodos],
  [`ContainerCreating` atascado], [Subred sin IP libres o volumen que no se monta], [Eventos del pod; logs de `aws-node`],
  [`ImagePullBackOff`], [Imagen o etiqueta inexistente, sin permiso en ECR o sin ruta a ECR (subred privada sin NAT ni VPC endpoints)], [`kubectl describe pod`],
  [`CrashLoopBackOff`], [La aplicación termina al arrancar o la liveness probe es demasiado agresiva], [`kubectl logs --previous`],
  [Service sin respuesta], [El selector no coincide con las labels o la readiness probe falla], [`kubectl get endpointslices`],
)

#cuidado[Antes de borrar un clúster, elimina los Ingress y los Services de tipo LoadBalancer. Esos balanceadores los creó un controlador, no tu plantilla: si el clúster desaparece primero, quedan huérfanos, siguen facturando e impiden borrar la VPC.]

#resumen[
- Kubernetes es *declarativo*: describes el estado deseado y los controladores lo reconcilian sin descanso con el actual.
- El *control plane* (API server, etcd, scheduler, controller manager, cloud controller manager) decide; los *nodos* (kubelet, kube-proxy, runtime) ejecutan. Solo el API server habla con etcd.
- *Pods* gestionados por Deployment, StatefulSet, DaemonSet o Job; *Services* con IP y DNS estables por selector; Ingress y Gateway API para HTTP; requests, limits y probes para recursos y salud; PVC, PV y StorageClass para los datos.
- El HPA escala pods; Karpenter (o Cluster Autoscaler), nodos.
- *EKS* opera un control plane multi-AZ por una tarifa por clúster y hora (más cara en soporte extendido); los pods corren en managed node groups, nodos propios, Fargate, Karpenter o *Auto Mode*.
- La *VPC CNI* da a cada pod una IP de la VPC (vigila el agotamiento) y el *AWS Load Balancer Controller* crea ALB y NLB, mejor en modo IP.
- IAM va en dos direcciones: *access entries* + RBAC para entrar al clúster; *Pod Identity* o IRSA para que los pods usen AWS, nunca el rol del nodo. Y actualiza una versión menor cada vez.
]

#repaso(
  ([¿Qué significa que Kubernetes sea declarativo?], [Que describes el estado deseado en lugar de dar órdenes, y los controladores lo comparan sin descanso con el actual para igualarlos: el bucle de reconciliación.]),
  ([Un Deployment tiene `replicas: 3` y se cae el nodo donde corrían dos de sus pods. ¿Qué ocurre?], [El ReplicaSet crea dos pods nuevos y el scheduler los coloca donde haya hueco; si no lo hay, quedan en `Pending` y Karpenter o Cluster Autoscaler añaden nodos.]),
  ([Los pods nuevos se quedan en `ContainerCreating` con errores de asignación de IP, y las subredes son /24. ¿Qué haces?], [Es agotamiento de IP por la VPC CNI: prefix delegation, subredes más grandes, custom networking con un CIDR secundario o un clúster IPv6.]),
  ([Un compañero propone añadir `s3:GetObject` al rol IAM de los nodos para que una aplicación lea de un bucket. ¿Qué propones?], [Un rol de mínimo privilegio asociado a la ServiceAccount de esa aplicación con Pod Identity (IRSA en Fargate): el rol del nodo lo heredarían todos los pods. Y bloquear el IMDS (hop limit de 1).]),
  ([Una desarrolladora con un rol IAM válido recibe *Unauthorized* al ejecutar `kubectl get pods`. ¿Qué falta?], [Su access entry: sin ella, EKS no la reconoce. Después, si no tiene permisos de RBAC o una access policy, el error pasará a ser *Forbidden*.]),
  ([Quieres mover a Fargate un agente de logs que hoy se despliega como DaemonSet. ¿Es posible?], [No como DaemonSet: Fargate ejecuta cada pod en su propia micro-VM y no los admite. Usa su router de logs integrado o el agente como sidecar.]),
  ([Tu clúster está en la versión 1.33 y debes llegar a la 1.35. ¿Cómo lo planificas?], [En dos saltos (1.33 → 1.34 → 1.35), porque EKS sube una versión menor cada vez. En cada uno: Cluster Insights, control plane, add-ons y, por último, nodos.]),
)
