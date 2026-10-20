#import "../plantilla.typ": *
#import "fonetica.typ": deletrear

#let puntos = csv("../data/calc/puntos_desde_madrid.csv", row-type: dictionary)
#let ej = json("../data/calc/ejemplo_puntuacion.json")
#let es = (
  "Spain": "España", "Fed. Rep. of Germany": "Alemania", "United States": "EE. UU.",
  "Canary Islands": "Canarias", "Japan": "Japón", "Brazil": "Brasil",
  "Balearic Islands": "Baleares", "Portugal": "Portugal", "Morocco": "Marruecos",
)

#let capitulo(cfg) = [
= Las reglas que importan <cap-reglas>

Resumen de las bases 2026 (PDF fechado el 5 de septiembre de 2026) y de la entrada «2026 Rule Changes» del blog de cqww.com @rules-cqww-2026 @rules-cqww-2026-changes. Si algo de aquí no cuadra con las bases, *mandan las bases*. Las de 2027 saldrán hacia septiembre de 2027: repasa los cambios entonces.

#importante[*Novedades de 2026 que debes conocer:* el log se envía en *48 horas* (antes, 5 días); la penalización por un indicativo mal copiado o un NIL es *2 veces* los puntos del QSO (la FAQ todavía dice 3×, pero está desactualizada); un humano debe iniciar siempre los cambios de frecuencia, las llamadas y el registro de QSO (se prohíben los «robots»); y la grabación de audio es obligatoria para quien opte al top 5 mundial, continental o de EE. UU.]

== Bandas y límites de la Región 1 <sec-bandas>

Solo seis bandas: *160, 80, 40, 20, 15 y 10 m*. Nada de WARC (30, 17, 12 m) ni 6 m. Las bases recomiendan con fuerza respetar los planes de banda; lo obligatorio son los límites de tu licencia (transmitir fuera de ellos es conducta antideportiva).

Para estaciones de la Región 1 de la UIT, como EA, las bases añaden dos límites:

- *En 40 m no se puede transmitir por encima de 7200 kHz* durante el concurso de SSB.
- *No se puede transmitir por debajo de 1810 kHz* durante el concurso.

#error-tipico[En LSB tu señal ocupa unos 2,7 kHz *por debajo* de la frecuencia que marca la radio. En 40 m, si sintonizas 7199 kHz, toda tu señal queda por debajo de 7200, pero no te acerques al límite inferior de tu segmento. Escuchar por encima de 7200 kHz (estaciones americanas en *split*) sí está permitido; lo prohibido es transmitir.]

== Intercambio

En SSB: *RS + zona CQ del transmisor*, por ejemplo «59 05». Desde #cfg.qth envías #dice("five nine one four") (59 14). EA6 da también zona 14; EA8 y EA9, zona 33. El control casi siempre es 59; lo que hay que copiar bien es la zona.

== Puntos por QSO <sec-puntos>

- Otro continente: *3 puntos*.
- Mismo continente, otro país: *1 punto* (excepción solo para Norteamérica: 2 puntos entre países distintos de NA; no te afecta).
- Mismo país: *0 puntos*, pero el QSO cuenta para multiplicador de zona y de país.

Cada estación se puede trabajar una vez en cada banda. Vista desde #cfg.qth (Europa, zona #cfg.zona-cq):

#larga[#figure(
  caption: [Puntos por QSO desde EA4 (Madrid). Continente y zona por defecto según el fichero CTY VER20260603; calculado con `scripts/calc_puntos.py`.],
  tabla(
    columns: (auto, auto, auto, auto, auto, 1fr),
    table.header([Prefijo], [Entidad], [Cont.], [Zona], [Puntos], [Ojo]),
    ..puntos.map(r => (
      r.prefijo, r.entidad, r.continente, r.zona_cq_tipica,
      if r.puntos == "3" { strong(r.puntos) } else { r.puntos },
      r.nota,
    )).flatten(),
  ),
) <tab-puntos>]

== Multiplicadores y puntuación final

- *Zonas*: cada zona CQ distinta (de 40) en cada banda es un multiplicador.
- *Países*: cada entidad distinta de la lista DXCC + lista WAE + IG9/IH9 en cada banda es un multiplicador (apartado @sec-paises). Tu propio país también cuenta.
- Las estaciones marítimo-móviles (/MM) solo cuentan como zona.

#align(center)[#block(fill: c.cab, inset: 8pt, radius: 3pt)[*Puntuación = (suma de puntos por QSO) × (zonas + países)*, sumando zonas y países de las seis bandas.]]

Como zonas y países se cuentan *por banda*, el mismo K1 que te da zona 5 y EE. UU. en 20 m te los vuelve a dar en 15 m. Por eso cambiar de banda para buscar multiplicadores suele rendir más que repetir QSO en la misma (capítulo @cap-donde).

=== Ejemplo de cálculo

Un mini-log de 12 QSO con indicativos ficticios (cálculo con `scripts/calc_puntuacion.py`):

#figure(
  caption: [Ejemplo: cada fila suma puntos y, si es nueva en esa banda, zona o país.],
  tabla(
    columns: (auto, auto, auto, auto, auto, auto, 1fr),
    table.header([\#], [Banda], [Indicativo], [Zona], [Entidad], [Puntos], [Multiplicador nuevo]),
    ..ej.mini_log.filas.enumerate().map(((i, r)) => (
      str(i + 1), str(r.banda) + " m", raw(r.indicativo), str(r.zona),
      es.at(r.entidad, default: r.entidad), str(r.puntos), r.nuevo,
    )).flatten(),
  ),
) <tab-ejemplo>

Resultado: #ej.mini_log.qsos_validos QSO válidos (uno es duplicado), *#ej.mini_log.puntos_qso puntos* × (#ej.mini_log.zonas zonas + #ej.mini_log.paises países) = *#ej.mini_log.total*.

Si el QSO con JA1ZZZ hubiera sido un *bust*, se eliminaría (pierdes sus 3 puntos, la zona 25 y el país Japón en 20 m) y además te restarían 2 × 3 = 6 puntos: (#ej.mini_log_con_bust.puntos_qso − #ej.mini_log_con_bust.penalizacion_puntos) × (#ej.mini_log_con_bust.zonas + #ej.mini_log_con_bust.paises) = *#ej.mini_log_con_bust.total_con_penalizacion*. Un solo error se ha llevado el 44 % de la puntuación. En un log real el efecto es menor, pero la lección es la misma: *mejor preguntar que registrar algo dudoso*.

== Categorías y overlays

#tabla(
  columns: (auto, 1fr),
  table.header([Categoría], [Qué es]),
  [*Single Operator* (SO)], [Una persona hace todo (operar y registrar). Sin límite de horas ni de cambios de banda; *una sola señal transmitida* a la vez; *prohibida cualquier ayuda para encontrar QSO*. Todas las bandas o monobanda. Potencia: *High* ≤ 1500 W, *Low* ≤ 100 W, *QRP* ≤ 5 W.],
  [*Single Operator Assisted* (SOA)], [Igual, pero se permite la ayuda para encontrar QSO (cluster, etc.). Mismos niveles de potencia.],
  [Multi-Single, Multi-Two, Multi-Multi, Multi-Distributed], [Varios operadores, con límites de señales y de cambios de banda distintos (capítulo @cap-sin-estacion). La categoría Explorer se eliminó en 2025.],
  [*Checklog*], [Envías el log solo para ayudar a verificar; no puntúa ni se publica.],
)

Los *overlays* son una clasificación adicional para un Single Operator. Solo se admite uno por log:

- *ROOKIE*: operador con la *primera licencia obtenida hace menos de 3 años* antes de la fecha del concurso. Hay que indicar la *fecha de la primera licencia en el SOAPBOX* del log. Para el CQ WW SSB 2027 (30 de octubre de 2027) tu primera licencia tiene que ser posterior al 30 de octubre de 2024: si la obtienes en 2026, cumples en 2027 y en 2028. Cuenta la primera licencia (si tuviste una que caducó, ya no eres rookie). Los ganadores anteriores de rookie no optan a placa.
- *YOUTH*: 25 años o menos; año de nacimiento en el SOAPBOX.
- *CLASSIC*: una sola radio, sin asistencia, máximo 24 de las 48 horas, con descansos de 60 minutos o más. #pv cómo se computan exactamente las 24 horas.

== Qué cuenta como asistencia

Las bases de 2026 hablan de *QSO finding assistance*: cualquier tecnología o fuente que te dé el indicativo o te identifique un multiplicador. Ejemplos de las bases: el DX cluster y las webs de *spots*, los decodificadores (de CW y cualquier otro que muestre indicativos), CW Skimmer y la Reverse Beacon Network, y los acuerdos con otras personas para que te avisen. Según la FAQ, en monooperador *tú y solo tú* localizas (sintonizas) e identificas (copias) cada indicativo del log.

Sí puedes usar, sin dejar de ser no asistido, el *panorámico o la cascada* de la radio o del SDR, siempre que no muestre indicativos (lo dice la FAQ). El *Super Check Partial* del logger (capítulo @cap-herramientas) se usa habitualmente en no asistido porque no te dice quién está en el aire, solo qué indicativos existen; las bases no lo mencionan expresamente #pv.

#error-tipico[Dejar abierta en el Mac una ventana de cluster o de una web de spots «solo para mirar». Si la usas para encontrar estaciones, eres asistido. Si quieres competir como no asistido, ciérrala.]

== Prohibiciones y reglas generales

- *Autoanunciarse* en el cluster o pedir que te anuncien está prohibido, también en asistido. En 2025 hubo descalificaciones por esto.
- *Concertar o confirmar QSO por medios que no sean la radio* (teléfono, chat, redes sociales, correo) durante o después del concurso.
- *Corregir el log después* con bases de datos, grabaciones o correos. Solo vale lo que copiaste en el aire.
- Un humano inicia *siempre* el cambio de frecuencia, la llamada y el registro de cada QSO.
- Toda la estación (transmisores, receptores, amplificadores) dentro de un círculo de *500 m de diámetro*; las antenas, conectadas por línea de transmisión. Los *receptores remotos* fuera del emplazamiento están prohibidos (no puedes usar un WebSDR para copiar durante tu participación).
- La *operación remota* se permite si todos los equipos y antenas están en un único emplazamiento y se cumplen la licencia de la estación, la del operador y los límites de la categoría (capítulo @cap-sin-estacion).
- Señales con *ancho de banda excesivo* (salpicaduras por exceso de procesador o de ALC) o armónicos.
- Hacer *más de tres QSO seguidos sin dar tu indicativo* cuando llamas CQ.
- La potencia se mide a la salida del amplificador activo (sin amplificador lineal, entendemos que es la salida del transceptor).

== El log: Cabrillo y en 48 horas <sec-log>

- *Formato Cabrillo* (v3). En la cabecera, `CONTEST: CQ-WW-SSB` (sin el año), las categorías y `CATEGORY-OVERLAY: ROOKIE`; fuera de EE. UU., `LOCATION: DX`. En las líneas de QSO, el modo es `PH`. Plantilla en el apartado @sec-cabrillo.
- *Solo por la web*, en #url("https://cqww.com/logcheck/"): la página comprueba el fichero antes de enviarlo. No se acepta el correo electrónico.
- *Plazo de 48 horas*: para 2026, hasta las *23:59 UTC del 27 de octubre* (miércoles 28 a las 00:59 en Madrid). Para 2027, si se mantiene la regla, hasta las 23:59 UTC del 2 de noviembre de 2027 #pv.
- Recibirás un *correo con número de seguimiento*: hasta que llega, el log no está aceptado.
- Un log enviado fuera de plazo (o reenviado tras el plazo) es *late log*: puede salir en los resultados, pero sin premio ni certificado.
- Lo que pongas en la cabecera es como se clasifica tu participación. Si un QSO no debe contar (por ejemplo, fuera de tu licencia), no lo borres: márcalo como `X-QSO:` para que el otro no salga perjudicado.

== Penalizaciones <sec-penalizaciones>

#tabla(
  columns: (1fr, 1.3fr),
  table.header([Caso], [Consecuencia (bases 2026)]),
  [Duplicado], [Se elimina, *sin penalización*.],
  [Intercambio mal copiado (zona errónea)], [Se elimina, *sin penalización*.],
  [Indicativo mal copiado (*bust*) o QSO que no está en el log del otro (*NIL*)], [Se elimina y se *restan 2 veces sus puntos*.],
  [Diferencia de hora con el log del otro], [Se tolera ±15 minutos: sincroniza el reloj del ordenador.],
  [Conducta antideportiva (apartado anterior)], [Reclasificación o descalificación; 5 días para recurrir.],
)

Las bases 2026 no mencionan una penalización específica por los QSO «únicos» (indicativos que no aparecen en ningún otro log), pero acumular QSO o multiplicadores no verificables es conducta antideportiva. #pv cómo trata el comité los únicos y si publica informes UBN.

#fuentes("rules-cqww-2026", "rules-cqww-2026-changes", "rules-cqww-faq", "rules-cqww-logcheck", "rules-cqww-cabrillo", "rules-cqww-logging-time", "rules-cqww-results-2025-ssb", "rules-cqww-2025-changes", "own-cty-not1mm")
]
