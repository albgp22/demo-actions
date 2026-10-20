#import "../plantilla.typ": *
#import "fonetica.typ": deletrear
#import "diagramas.typ": diagrama-licencia

#let bandas = csv("../data/legal/bands_power_es.csv", row-type: dictionary)
#let rf = csv("../data/legal/rf_exposure_distances.csv", row-type: dictionary)

#let capitulo(cfg) = [
= Marco legal en España <cap-legal>

Este capítulo resume la normativa vigente a 20 de octubre de 2026, leída en los textos consolidados del BOE. No es asesoramiento jurídico: ante cualquier duda, manda el BOE y lo que te diga la Jefatura Provincial de Inspección de Telecomunicaciones. Las funciones que las normas atribuyen a la antigua SETSI las ejerce hoy la *Secretaría de Estado de Telecomunicaciones e Infraestructuras Digitales* (SETID), del Ministerio para la Transformación Digital y de la Función Pública.

#importante[Para transmitir en el CQ WW 2027 desde tu piso necesitas *dos* cosas: la *autorización de radioaficionado* (con su indicativo) y la *licencia de estación fija* para la instalación de casa. Sin la segunda, la autorización solo te ampara con estaciones *móviles o portátiles*. La licencia de estación tiene un trámite con la comunidad de propietarios de al menos dos meses: empieza con tiempo.]

#figure(
  diagrama-licencia(),
  kind: image,
  caption: [Del examen a transmitir desde casa (Orden IET/1311/2013, RD 2623/1986 y Ley 11/2022; tasas a 20 de octubre de 2026).],
) <fig-licencia>

== Normas que te afectan

#tabla(
  columns: (auto, 1fr),
  table.header([Norma], [Qué regula]),
  [Orden IET/1311/2013 (BOE-A-2013-7624)], [Reglamento de radioaficionados: autorización, examen, indicativos, estaciones, potencias (anexo I). Su texto solo se ha modificado una vez: la Orden IET/614/2015 cambió la disposición adicional segunda (bandas de microondas con autorización especial).],
  [Ley 11/2022, General de Telecomunicaciones], [Marco general, tasas (disposición transitoria 7.ª), infracciones y sanciones; prohíbe exigir licencia municipal a las antenas de aficionado salvo excepciones.],
  [Orden TDF/732/2026 (CNAF)], [Nuevo Cuadro Nacional de Atribución de Frecuencias, en vigor desde el 18 de julio de 2026 (deroga el de 2021). Sus tablas y notas nacionales se publicaron como imágenes, así que el estatus de cada banda no se ha podido leer en el BOE #pv; según URE, no cambia nada para los aficionados respecto al de 2021 @verl-ure-cnaf-2026.],
  [Ley 19/1983 y RD 2623/1986], [Derecho a instalar antenas en el exterior del edificio, seguro, requisitos técnicos y de seguridad.],
  [RD 1066/2001], [Límites de exposición del público a campos electromagnéticos.],
)

== Autorización de radioaficionado e indicativo

+ *Examen* de dos partes (electricidad y radioelectricidad; normativa), con programa según la Recomendación CEPT T/R 61-02. Al aprobar recibes el certificado *HAREC*. Tasa de examen: *23,67 €* #fecha[DT 7.ª Ley 11/2022, a 20-10-2026].
+ *Solicitud de la autorización*, preferentemente por la sede electrónica, con el justificante de la tasa de tramitación: *114,36 €* (exentos: mayores de 65 años, pensionistas públicos y personas con discapacidad ≥ 33 %). Plazo para resolver: seis semanas; si no contestan, se entiende *desestimada*.
+ La resolución te da la *autorización junto con el indicativo*. Es personal, *sin caducidad* (ya no hay que renovarla cada cinco años) y debes comunicar los cambios de domicilio.

*Tu indicativo*: prefijo EA (después EB y EC cuando se agotan las series) + *4* (distrito 4: Madrid, Toledo, Ciudad Real, Cuenca, Guadalajara, Badajoz y Cáceres) + sufijo, normalmente de *tres letras* asignadas por orden alfabético. Es único y no cambia aunque te mudes. Los sufijos de dos y una letra requieren años de antigüedad y un procedimiento por méritos. Para concursos se pueden pedir prefijos especiales temporales (ED, EE, EF, EG, EH, AM, AN, AO) a la Jefatura Provincial.

*En el aire*: identifícate al principio y al final de cada emisión y, en las largas, al menos cada 10 minutos (en un concurso lo haces en cada QSO). *No hay obligación legal de llevar libro de guardia*: el log lo exigen las bases del concurso. La autorización española vale como licencia CEPT (T/R 61-01): en Francia operarías como F/#cfg.indicativo.

#nota[Todo se tramita en la sede electrónica de la SETID, con certificado digital o Cl\@ve: el *procedimiento 147* (autorización, distintivos temporales, licencia de estación fija e inscripción en exámenes) @verl-sede-radioaficionados-147 y el *procedimiento 34* (puesta en servicio de la estación) @verl-sede-puesta-servicio-34. Las convocatorias de examen las fija la SETID por resolución.]

== Licencia de estación fija: lo que necesita tu piso <sec-licencia-estacion>

La Orden exige *licencia para instalar y hacer funcionar cualquier estación fija* (art. 18). Una misma licencia ampara todos los equipos de la estación. El procedimiento (arts. 19–21 de la Orden y RD 2623/1986) es:

+ *Solicitud con memoria técnica.* Si la antena va en el exterior (terraza, azotea), la memoria incluye plano o esquema del mástil o soporte, cálculo de soportes, riostras y anclajes y de la resistencia al viento, el título que te legitima para usar la vivienda (escritura, contrato…) y los datos del propietario o del presidente de la comunidad.
+ *Notificación a la comunidad.* La Administración envía la memoria aceptada al propietario o al presidente, que tiene *dos meses* para alegar; si no contesta, se entiende aceptada.
+ *Montaje.* Por norma general, por un instalador de telecomunicaciones inscrito; la Jefatura puede permitir que hagas tú las instalaciones sencillas.
+ *Seguro de responsabilidad civil* antes de la licencia, con copia para la comunidad. La ley no fija un importe mínimo: debe cubrir «en la cuantía suficiente» los daños posibles.
+ *Comunicación de fin de montaje* en seis semanas; la Jefatura tiene 30 días para verificar y *expedir la licencia*, que es la que te habilita a emitir desde casa.

Si el seguro caduca, la licencia se cancela. Cambiar la antena de sitio exige repetir el trámite. Las estaciones *móviles y portátiles* no necesitan licencia de estación (art. 5.3 de la Orden y art. 26 del RD 123/2017). La Orden y el RD piden una *memoria descriptiva*, no un proyecto firmado por un técnico. En la sede (procedimiento 34) se adjunta la solicitud de puesta en servicio y, según quién monte la instalación, una declaración responsable (si la haces tú) o el boletín del instalador; el modelo 790 de tasa figura como «no aplica a radioafición» @verl-sede-puesta-servicio-34. Si además piden planos o el permiso del propietario #pv.

== Bandas y potencias en HF <sec-bandas-es>

La potencia máxima es de *1000 W PEP* en todas las bandas de HF atribuidas, y la mitad en las atribuidas a título secundario (anexo I). Con 100 W estás muy por debajo en todas. La Orden obliga a usar «como norma general» el *plan de bandas de la IARU para la Región 1* (art. 2.2): capítulo @cap-donde.

#figure(
  caption: [Bandas del CQ WW en España y potencia máxima legal (Orden IET/1311/2013, anexo I; RR del CNAF 2026).],
  tabla(
    columns: (auto, auto, auto, 1fr),
    table.header([Banda], [kHz], [Potencia máx.], [Observaciones]),
    [160 m], [1810–1830], [500 W PEP], [Atribución secundaria en España; al norte de 40° N (Madrid está a 40,4° N) el Reglamento de Radiocomunicaciones pide consulta previa entre administraciones.],
    [160 m], [1830–1850], [1000 W PEP], [Atribución primaria.],
    [160 m], [1850–2000], [—], [*Sin atribución permanente*: solo con una resolución temporal de la SETID. Según URE, la de 2026 (diciembre de 2025) la permite en los concursos del 1 de enero al 31 de diciembre, sin protección y con cese inmediato si hay interferencias: cubre el CQ WW SSB 2026, no el de 2027 @verl-ure-1850-2000-2026. En la web del Ministerio figura sin fechas #pv.],
    [80 m], [3500–3800], [1000 W PEP], [Compartida con los servicios fijo y móvil.],
    [40 m], [7000–7200], [1000 W PEP], [Nada por encima de 7200 kHz.],
    [20 m], [14000–14350], [1000 W PEP], [],
    [15 m], [21000–21450], [1000 W PEP], [],
    [10 m], [28000–29700], [1000 W PEP], [],
  ),
) <tab-bandas-es>

#error-tipico[Llamar en 160 m en SSB por encima de 1850 kHz porque «allí está todo el mundo». Sin una resolución temporal que lo cubra, en España no puedes transmitir entre 1850 y 2000 kHz: para 2027 tendrás que comprobar que la SETID haya dictado la de ese año. Las estaciones de otros países sí pueden: escúchalas allí y llámalas desde tu segmento (*split*).]

== Antenas y comunidad de propietarios

- La *Ley 19/1983* permite a quien esté legitimado para usar un inmueble (propietario o inquilino) y tenga la licencia de estación *instalar antenas en el exterior del edificio*, a su cargo.
- Los *daños* de la instalación son responsabilidad tuya, cubiertos por el seguro obligatorio.
- La comunidad *no puede impedir la antena*, pero sí, por *mayoría simple*, trasladarla a otro sitio igual de útil *a su costa* (art. 545 del Código Civil).
- Si hay obras en el edificio, te pueden obligar a desmontarla temporalmente sin indemnización, con un mes de preaviso (salvo urgencia).
- El *RD 2623/1986* fija requisitos de seguridad: sin peligro ni molestias, anclajes y riostras señalizados en azoteas transitables, *3 m libres sobre el plano de paso*, distancias a líneas eléctricas, buena construcción y mantenimiento.
- *No te pueden exigir licencia municipal* de obras o de actividad (Ley 11/2022, DA 19.ª y art. 49.9), salvo en edificios BIC, instalaciones de más de 300 m² o espacios naturales protegidos. Si el Ayuntamiento de Madrid puede pedir una declaración responsable no está claro: la DA 19.ª solo remite al primer párrafo del art. 49.9, y la sustitución por declaraciones responsables está en otro párrafo @legal-ley-11-2022. Pregunta en Urbanismo o en URE #pv.
- La Ley de Propiedad Horizontal no dice nada de antenas de aficionado: rigen la Ley 19/1983 y el RD 2623/1986.

#truco[Antes de pedir la licencia, habla con el presidente de la comunidad y explícale qué vas a poner (una EFHW de hilo, una vertical pequeña o un lazo apenas se ven), el seguro y el compromiso de resolver cualquier interferencia. Una comunidad informada no suele alegar.]

== Exposición a radiofrecuencia

El *RD 1066/2001* se aplica a todas las estaciones, incluidas las de aficionado, en las zonas donde puedan permanecer habitualmente personas. Niveles de referencia para el público (promedio en 6 minutos): 87/√f V/m entre 1 y 10 MHz (64 V/m en 1,85 MHz; 32 V/m en 7,2 MHz) y 28 V/m (2 W/m²) entre 10 y 400 MHz. La Orden de radioaficionados añade un límite propio de 3,5 mW/cm² (35 W/m²), mucho menos estricto; en zonas de permanencia habitual manda el del RD. No hay estudio ni certificado obligatorio para aficionados, pero superar los límites es una infracción *grave*.

#let fila-rf(b, esc) = rf.filter(r => r.banda == b and r.antena.starts-with("dipolo") and r.escenario.starts-with(esc)).first()
#figure(
  caption: [Distancias orientativas al elemento radiante para cumplir el RD 1066/2001 con 100 W PEP en SSB y un dipolo (cálculo de campo lejano, `scripts/legal_rf_exposure.py`). En 160–20 m caen en el campo cercano: son solo orientativas.],
  tabla(
    columns: (auto, 1fr, 1fr, 1fr),
    table.header([Banda], [Concurso típico (≈ 20 W medios)], [CQ continuo con procesador (≈ 40 W)], [Portadora continua 100 W (sintonía)]),
    ..("160 m", "80 m", "40 m", "20 m", "15 m", "10 m").map(b => (
      b,
      coma(fila-rf(b, "SSB con procesador, concurso").distancia_rd1066_m) + " m",
      coma(fila-rf(b, "SSB con procesador, CQ").distancia_rd1066_m) + " m",
      coma(fila-rf(b, "Portadora").distancia_rd1066_m) + " m",
    )).flatten(),
  ),
) <tab-rf>

En la práctica: elementos radiantes fuera del alcance de las personas (y no menos de 3 m sobre la zona de paso), lejos de ventanas y terrazas vecinas, sintoniza con poca potencia y no dejes a nadie junto a un lazo magnético mientras transmites. Los factores de modo SSB y de reflexión del cálculo proceden de la práctica técnica (FCC OET-65, UIT-T K.52) #pv.

== Interferencias a los vecinos

Si la Inspección comprueba que tu estación interfiere a otro servicio o a la recepción de radio o televisión, *debes dejar de emitir* y adoptar a tu costa medidas técnicas razonables; si persiste, te pueden limitar bandas, potencia u horario (art. 32 de la Orden). La responsabilidad es del titular de la autorización. Producir interferencias es infracción grave, y no atender un requerimiento de cese, muy grave. Las medidas técnicas para evitarlas están en el capítulo @cap-equipo.

#fuentes("legal-orden-iet-1311-2013", "legal-orden-iet-614-2015", "legal-ley-11-2022", "legal-rd-123-2017", "legal-orden-tdf-732-2026", "legal-ley-19-1983", "legal-rd-2623-1986", "legal-codigo-civil", "legal-ley-49-1960-lph", "legal-rd-1066-2001", "legal-orden-cte-23-2002", "legal-cept-tr-61-01", "legal-cept-tr-61-02", "legal-mtdfp-examenes", "legal-mtdfp-res-1850-2000", "verl-ure-1850-2000-2026", "verl-sede-radioaficionados-147", "verl-sede-puesta-servicio-34", "verl-ure-cnaf-2026", "legal-fcc-oet65b", "legal-itu-t-k52")
]
