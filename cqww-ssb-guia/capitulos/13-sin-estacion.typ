#import "../plantilla.typ": *
#import "fonetica.typ": deletrear

#let capitulo(cfg) = [
= Participar sin estación propia <cap-sin-estacion>

Mientras no tengas la licencia de estación fija (capítulo @cap-legal) o una antena decente, hay tres caminos para estar en el CQ WW.

== Como operador invitado en un multioperador

Un radioclub o un grupo de amigos monta una estación con varios operadores por turnos. Es la mejor escuela: aprendes con veteranos, ves una estación de verdad y el concurso se cubre las 48 horas. Las categorías multioperador del CQ WW 2026 son:

#tabla(
  columns: (auto, 1fr),
  table.header([Categoría], [Regla principal (bases 2026)]),
  [Multi-Single], [Una señal en una banda en cada periodo de 10 minutos (estación de *run*), más una segunda señal en otra banda *solo* para trabajar multiplicadores nuevos, que no puede llamar CQ. Alta (1500 W) o baja (100 W) potencia.],
  [Multi-Two], [Hasta dos señales a la vez, en bandas distintas; cada una, máximo 8 cambios de banda por hora.],
  [Multi-Multi], [Las seis bandas a la vez, una señal por banda.],
  [Multi-Distributed], [Hasta seis señales, una por banda, desde estaciones en sitios distintos, todo dentro de la misma entidad DXCC y zona CQ. Sustituyó a la categoría Explorer en 2025.],
)

En multioperador se permite el cluster. En España, una *estación colectiva* solo la pueden tener las asociaciones reconocidas, con su propio indicativo y bajo la responsabilidad de su junta directiva (Orden IET/1311/2013, art. 18); para concursos pueden pedir a la Jefatura Provincial prefijos especiales (ED, EE, EF, EG, EH, AM, AN, AO) por evento (arts. 27 y 28) @legal-orden-iet-1311-2013. Los indicativos de radioclub suelen llevar sufijos que empiezan por RC o RK, y los de asociaciones, por UR (art. 27): es una pista para reconocerlos.

*Etiqueta del invitado*: acepta las normas de la estación (turnos, categoría, potencia, bandas, uso del cluster) y no cambies configuraciones sin permiso; aprende antes el logger y los mensajes; identifícate siempre con el indicativo de la estación; registra cada QSO tal cual y avisa de errores o averías; ayuda a montar y desmontar, comparte gastos si es costumbre y no publiques resultados en nombre de la estación sin permiso del responsable.

== Con una estación portátil o móvil

La autorización de radioaficionado ampara las estaciones *móviles y portátiles* sin licencia de estación fija (art. 5.3 de la Orden; art. 26 del RD 123/2017) @legal-rd-123-2017. Un transceptor de 100 W (o el IC-705) con una antena de hilo en un sitio despejado puede rendir más que la terraza. Para el CQ WW, toda la estación tiene que estar dentro de un círculo de 500 m de diámetro, con las antenas conectadas por cable. Si llevas una estación *fija* a otro sitio temporalmente (estación *portable*), hay que notificarlo a la Jefatura con 5 días de antelación salvo usos de hasta 15 días seguidos (art. 17.1).

== Por operación remota

Las bases del CQ WW permiten la operación remota *si todos los transmisores, receptores y antenas están en un único emplazamiento*, y la estación cumple su licencia, la licencia del operador y los límites de la categoría; *los receptores remotos fuera de ese emplazamiento están prohibidos* @rules-cqww-2026. Para ti caben dos casos:

- *Tu propia estación a distancia* (por ejemplo, el IC-7300MK2 en casa operado desde otra habitación o por Tailscale con wfview): sigue siendo tu estación, en tu QTH, con tu licencia de estación.
- *La estación de otra persona o de un club* operada por internet: las bases lo admiten con esas condiciones, pero la Orden IET/1311/2013 no regula expresamente con qué indicativo ni con qué requisitos puede operarse a distancia la estación de otro titular (solo define la «estación fija remota» y exige al titular que garantice el uso legal también en su interconexión con otras redes). Antes de hacerlo, *consulta a la Jefatura Provincial o a URE* #pv.

#importante[En operación remota, el país y la zona son los del *emplazamiento de la estación*, no los tuyos: si operas una estación en otro país, necesitas un indicativo válido allí y cuentas como estación de ese país.]

#fuentes("rules-cqww-2026", "legal-orden-iet-1311-2013", "legal-rd-123-2017", "know-boe-iet1311")
]
