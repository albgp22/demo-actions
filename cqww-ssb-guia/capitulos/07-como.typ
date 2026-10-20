#import "../plantilla.typ": *
#import "fonetica.typ": deletrear
#import "diagramas.typ": diagrama-qso

#let capitulo(cfg) = [
= Cómo hacer contactos <cap-como>

En el CQ WW un QSO completo dura entre 5 y 15 segundos. No hay nombre, ni QTH, ni estación: *indicativo, control (59) y zona CQ*. Con 100 W y una antena de terraza, casi todos tus QSO serán en *search & pounce* (S&P): recorres la banda, encuentras a quien llama CQ y le contestas. El *run* (llamar CQ tú y que te contesten) llegará en momentos concretos (apartado @sec-cq).

En los ejemplos, los indicativos de las otras estaciones son ficticios. Tu intercambio es siempre #dice("five nine one four") (59 + zona #cfg.zona-cq).

== Search & pounce, paso a paso <sec-sp>

#figure(
  kind: image,
  placement: bottom,
  caption: [Flujo de un QSO en S&P. En amarillo, los puntos donde decides.],
  block(width: 100%)[
    #set text(size: 8pt)
    #grid(
      columns: (1fr, 3.6em, 0.95fr),
      row-gutter: 3pt,
      paso[*1. Sintoniza* despacio hasta oír a alguien que llama CQ (en 20/15/10 m, USB; en 40/80/160 m, LSB). Espera a oír su indicativo completo.], [], [],
      flecha-abajo, [], [],
      decision[*2. ¿Duplicado?* Teclea el indicativo en el logger: te dirá si ya lo tienes en esta banda y si es multiplicador.], flecha-der(t: "sí"), paso(color: c.tinta2, fondo: rgb("#f3f2ee"))[No llames: un duplicado no suma. Sigue girando el dial.],
      flecha-abajo, [], [],
      paso[*3. Espera tu turno.* Escucha cómo termina el QSO anterior (#dice("thank you"), #dice("QRZ")). Nunca llames encima de otro QSO.], [], [],
      flecha-abajo, [], [],
      paso[*4. Llama una vez* con el indicativo completo y la fonética: #dice(deletrear(cfg.indicativo)).], [], [],
      flecha-abajo, [], [],
      decision[*5. ¿Qué contesta?*], flecha-der(t: "a otro"), paso(color: c.tinta2, fondo: rgb("#f3f2ee"))[Calla y espera al siguiente #dice("QRZ"). Tras 3–4 intentos, apúntalo y vuelve más tarde.],
      flecha-abajo, flecha-der(t: "parcial"), paso(color: c.tinta2, fondo: rgb("#f3f2ee"))[Si dice #dice("the Echo Alfa…?"), repite tu indicativo completo, una o dos veces.],
      paso[*6. Te da el intercambio:* #dice("Echo Alfa Four… five nine zero five"). Comprueba que tu indicativo es correcto y copia su zona.], [], [],
      flecha-abajo, [], [],
      paso[*7. Contesta y confirma:* #dice("Thank you, five nine one four"). Si dijo mal tu indicativo, corrígelo antes de nada (apartado @sec-errores).], [], [],
      flecha-abajo, [], [],
      paso[*8. Registra* cuando oigas su #dice("thank you") o #dice("QRZ") (tecla #tecla("Enter") en el logger) y vuelve al paso 1.], [], [],
    )
  ],
) <fig-flujo-qso>

La @fig-flujo-qso resume la secuencia. Detalles que marcan la diferencia:

- *Escucha antes de llamar.* Diez segundos bastan para saber si la estación te oye (contesta a estaciones de tu zona), si trabaja en *split* (escucha en otra frecuencia; poco habitual en el CQ WW) y cuál es su ritmo.
- *Tu indicativo, entero y una sola vez.* Nada de «Echo Alfa» a medias: obliga al otro a preguntar y te cuesta el turno. No digas su indicativo; ya lo sabe.
- *Fonética estándar y voz clara.* La fonética de la UIT (apartado @sec-fonetica) se entiende en todo el mundo. Habla al ritmo del que llama: si va rápido, sé rápido.
- *El intercambio, mínimo.* #dice("Thank you, five nine one four") o solo #dice("five nine one four"). Nada de #dice("good morning") ni #dice("73") en medio de un pileup.
- *Copia la zona de verdad.* Casi todo el mundo da 59, pero la zona sí cambia: 3, 4 o 5 en EE. UU., 1 a 5 en Canadá, 16 a 19 o 23 en Rusia. Si dudas, pregunta (#dice("zone again?")).

== Guiones de QSO en inglés

#figure(
  diagrama-qso(cfg),
  kind: image,
  caption: [Un QSO de S&P completo, con tiempos orientativos: unos 12 segundos desde que termina su CQ hasta su #dice("QRZ").],
) <fig-secuencia-qso>

=== Run (llamas tú)

#tabla(
  columns: (auto, 1fr),
  table.header([Quién], [Qué se dice]),
  [Tú], dice("CQ contest, " + deletrear(cfg.indicativo) + ", contest"),
  [Él], dice("Delta Lima One Alfa Bravo Charlie"),
  [Tú], dice("Delta Lima One Alfa Bravo Charlie, five nine one four"),
  [Él], dice("Thank you, five nine one four"),
  [Tú], dice("Thank you, " + deletrear(cfg.indicativo)),
)

El último mensaje del run (#dice("thank you") + tu indicativo) hace de #dice("QRZ"): da las gracias, cierra el QSO y anuncia quién eres a quien acabe de llegar. Di tu indicativo en cada QSO, o al menos cada dos.

=== Frases útiles

#tabla(
  columns: (1.15fr, 1fr),
  table.header([Situación], [Frase]),
  [No has copiado su indicativo], dice("Your call again?") + [ o ] + dice("Call again, please"),
  [No has copiado su zona], dice("Zone again?") + [ o ] + dice("Your zone, please?"),
  [Solo copiaste parte (run)], dice("The Kilo One station, again?") + [ o ] + dice("Station ending Charlie, again?"),
  [Ha copiado mal tu indicativo], dice("Correction: " + deletrear(cfg.indicativo) + ", " + deletrear(cfg.indicativo)),
  [Te pide que repitas], dice("Echo Alfa Four… " + "(indicativo completo), five nine one four"),
  [Comprobar si la frecuencia está libre], dice("Is this frequency in use?") + [ (escucha antes 10–20 s)],
  [Hay muchos llamando a la vez (run)], dice("Only the Delta Lima, again") + [ y espera],
  [Necesitas parar], dice("QRT") + [ o simplemente deja de llamar CQ],
)

== Hacerse oír en un pileup con 100 W <sec-pileup>

Con 100 W no ganas a una estación de 1,5 kW con antenas Yagi llamando a la vez. Ganas eligiendo *cuándo* llamas:

+ *Timing.* Llama justo cuando el operador termina (#dice("thank you…")): el primer segundo de silencio es cuando más escucha. Si llamas tarde, te tapan.
+ *Una llamada, limpia.* Si no contesta, deja un hueco: quien llama sin parar se oye peor y molesta. Tras 3–4 intentos sin éxito, sigue buscando y vuelve en 10–15 minutos.
+ *Desplázate un poco.* Llamar 100–200 Hz arriba o abajo de su frecuencia puede ayudar a que tu voz se separe de las demás. Hazlo sin pasarte, para no molestar al QSO de al lado.
+ *Elige el momento.* Los grandes pileups son el sábado por la mañana. El domingo por la tarde las estaciones grandes ya han hecho miles de QSO y buscan cualquier contacto nuevo: es tu mejor momento.
+ *Elige la banda.* Una estación que en 20 m tiene un pileup enorme puede estar sola en 15 o 10 m una hora después.
+ *Audio limpio.* El procesador de voz con moderación (comprobando que el ALC no se dispara), la ganancia de micro bien ajustada y unos cascos con micro de calidad (capítulo @cap-equipo) valen más que cualquier truco.

#truco[Las estaciones que te contestan a la primera son las que *te oyen bien*. Cuando una banda «abre» hacia un continente, aprovecha la primera media hora: hay menos competencia y la señal sube.]

== Corregir errores <sec-errores>

- *Si el otro dice mal tu indicativo*, corrígelo antes de dar el intercambio: #dice("Correction, " + deletrear(cfg.indicativo)). Espera a que lo repita bien. Un QSO con tu indicativo mal copiado no te cuenta, y al otro le cuesta una penalización (capítulo @cap-reglas).
- *Si te equivocas tú al registrar*, corrige el log en el momento: los loggers permiten editar el último QSO. Si ya pasó, corrígelo antes de enviar el log, y solo si estás seguro.
- *Si no estás seguro de su indicativo*, pregunta. Es mejor perder 5 segundos que registrar un indicativo dudoso.

== Duplicados, busts y NIL

/ Duplicado: un segundo QSO con la misma estación en la misma banda. No suma. El logger lo marca; si el otro no te encuentra en su log y te pide repetir, hazlo: es más rápido que discutir.
/ Bust: indicativo o zona mal copiados. Se elimina el QSO y además te penaliza (apartado @sec-penalizaciones).
/ NIL (_not in log_): tú tienes el QSO, pero el otro no. Suele pasar cuando crees que te contestaba a ti y era a otro. Misma penalización que el bust.

#error-tipico[Registrar el QSO cuando la estación ha contestado a «alguien con Echo Alfa…» que no eras tú. Si no oyes *tu indicativo completo*, no hay QSO.]

== Cuándo y dónde llamar CQ <sec-cq>

Con 100 W, el run funciona cuando *tú* eres la señal interesante para alguien: un español en Europa a primera hora, en una banda recién abierta hacia Norteamérica, o el domingo por la tarde.

- *Busca hueco* en la parte alta del segmento de SSB, lejos de las estaciones grandes. Escucha 10–20 segundos y pregunta #dice("Is this frequency in use?") antes de llamar.
- *Haz una prueba de 5 minutos.* Si tras 8–10 CQ nadie contesta, vuelve a S&P. Si contestan, sigue mientras el ritmo compense; si bajas de 1 QSO por minuto, vuelve a S&P.
- *Graba el CQ en el voice keyer* (capítulo @cap-herramientas): llamar CQ cientos de veces a mano agota la voz.
- *Respeta el plan de bandas*: en 40 m, en Región 1 no se puede transmitir en SSB por encima de 7200 kHz (apartado @sec-bandas).

== Etiqueta

- No llames mientras la estación está con otro QSO, ni cuando pide #dice("only the Delta Lima") y no eres tú.
- No sintonices el acoplador sobre una frecuencia ocupada: hazlo en una libre, con poca potencia y deprisa.
- No te anuncies en el DX cluster (prohibido por las bases) ni pidas QSO por otros medios durante el concurso.
- Si alguien llama CQ en «tu» frecuencia, no discutas: muévete. El concurso es largo y la banda es de todos.
- Sé honrado con la categoría: si usas el cluster, eres *asistido*.

#fuentes("rules-cqww-2026")
]
