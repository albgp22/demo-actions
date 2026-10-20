#import "../plantilla.typ": *
#import "fonetica.typ": deletrear

#let h = json("../data/calc/horarios.json")

#let capitulo(cfg) = [
= Qué es y cuándo se celebra <cap-que-es>

El *CQ World Wide DX Contest* (CQ WW) lo organiza la revista CQ Amateur Radio. Su objetivo es que radioaficionados de todo el mundo contacten con el mayor número posible de estaciones en el mayor número posible de *zonas CQ y países* @rules-cqww-2026. Hay dos fines de semana distintos, con clasificaciones separadas: *SSB* (fonía) en octubre y *CW* (telegrafía) en noviembre.

Para ti, el CQ WW SSB es la mejor escuela posible: durante 48 horas las bandas de 160 a 10 m se llenan de estaciones de todos los continentes que solo quieren un «59 + zona», incluidas expediciones que activan países raros para dar multiplicadores. Aunque no transmitas, escucharlo te enseña propagación, técnica y fonética como ningún otro fin de semana.

== Fechas y horario de 2026

#tabla(
  columns: (auto, 1fr, 1fr),
  table.header([], [UTC], [Hora de Madrid]),
  [Inicio], [sáb 24 oct, 00:00], [sáb 24 oct, *02:00 CEST*],
  [Cambio de hora], [dom 25 oct, 01:00], [dom 25 oct, las 03:00 CEST pasan a ser las 02:00 CET],
  [Fin], [dom 25 oct, 23:59:59], [*lun 26 oct, 00:59:59 CET*],
  [Plazo del log (48 h)], [mar 27 oct, 23:59], [mié 28 oct, 00:59 CET],
)

La regla es fija: el CQ WW SSB es siempre el *último fin de semana completo de octubre* (y el de CW, el último fin de semana completo de noviembre), de las 00:00:00 UTC del sábado a las 23:59:59 UTC del domingo @rules-cqww-home @rules-cqww-2026. Como el cambio de hora europeo es el último domingo de octubre, *el CQ WW SSB siempre incluye el paso de CEST a CET*. En la radio y en el log no cambia nada (todo va en UTC), pero los horarios locales de la tabla de bandas (capítulo @cap-donde) cambian una hora a mitad del concurso.

#figure(
  image("../assets/fin_de_semana_2026.pdf", width: 100%),
  caption: [Las 48 horas del CQ WW SSB 2026 en UTC y en hora de Madrid. Arriba, día, noche y línea gris en Madrid. Las barras marcan cuándo el modelo da cada banda abierta y hacia dónde: en 10, 15 y 20 m, MUF del trayecto corto (modelo IRI vía PyIRI, F10.7 = 120); en 40, 80 y 160 m, noche en todo el trayecto; en 40 m, de día, Europa. Cálculo propio (`scripts/fig_fin_de_semana.py`).],
) <fig-fin-de-semana>

== Próximas ediciones

#tabla(
  columns: (auto, auto, 1fr, 1fr),
  table.header([Edición], [Modo], [UTC], [Hora de Madrid]),
  ..("2026", "2027", "2028").map(y => {
    let s = h.at(y + "-SSB")
    let w = h.at(y + "-CW")
    (
      [*#y*], [SSB], [#s.inicio_utc.slice(0, 16) → #s.fin_utc.slice(0, 16)], [#s.inicio_madrid.replace(":00 C", " C") → #s.fin_madrid],
      [], [CW], [#w.inicio_utc.slice(0, 16) → #w.fin_utc.slice(0, 16)], [#w.inicio_madrid.replace(":00 C", " C") → #w.fin_madrid],
    )
  }).flatten(),
)
Fechas calculadas con `scripts/calc_tiempos.py` aplicando la regla del último fin de semana completo; coinciden con las que publica cqww.com para 2027 y 2028 @rules-cqww-home. Tu primera participación prevista, el *CQ WW SSB 2027*, será del *30 al 31 de octubre de 2027*, y su log habrá que enviarlo antes de las 23:59 UTC del 2 de noviembre si se mantiene el plazo de 48 horas.

#truco[Apunta ya en el calendario el *fin de semana del CQ WW CW (28–29 nov 2026)*: aunque no sepas telegrafía, es una buena ocasión para practicar la escucha de propagación por bandas con el mismo plan del capítulo @cap-escucha-2026.]

#fuentes("rules-cqww-2026", "rules-cqww-home")
]
