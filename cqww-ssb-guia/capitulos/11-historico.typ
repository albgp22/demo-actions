#import "../plantilla.typ": *
#import "fonetica.typ": deletrear

#let solar = csv("../data/history/solar.csv", row-type: dictionary)
#let ej = json("../data/calc/ejemplo_puntuacion.json")
#let sd(anio, dia) = solar.filter(r => r.anio == anio and r.nota.starts-with(dia)).first()

#let capitulo(cfg) = [
= Ediciones anteriores <cap-historico>

#nota[Desde el entorno donde se preparó esta guía no se pudo acceder a cqww.com ni a 3830scores.com. Los resultados de este capítulo proceden de resúmenes de buscador de esas páginas y PDF; cada cifra va con su fuente y lo que no se leyó literalmente está marcado. Los datos solares, en cambio, se leyeron directamente del fichero de CelesTrak.]

== Participación y resultados publicados

Hay resultados *finales* (tras la comprobación de logs) de las cuatro últimas ediciones: 2022, 2023, 2024 (PDF de febrero de 2025) y 2025 (PDF de febrero de 2026). En 2024 se recibieron 10.098 logs, la primera vez por encima de 10.000; en 2025, un récord de *10.576 logs* y 5.148.149 QSO, con unos dos tercios de los logs enviados en las primeras 48 horas @hist-cqww-2024-ssb-results @hist-cqww-2025-ssb-results.

== Condiciones de propagación de cada edición

#figure(
  image("../assets/solar_ediciones.pdf", width: 92%),
  caption: [Flujo solar a 10,7 cm y Kp máximo de cada día de concurso (CelesTrak: F10.7 de Penticton, Kp de GFZ, manchas de SILSO) y previsión de la media de octubre de 2026 y 2027 @hist-celestrak-sw-5y. Gráfico propio, `scripts/fig_solar.py`.],
) <fig-solar>

#tabla(
  columns: (auto, auto, auto, auto, 1fr),
  table.header([Edición], [F10.7 sáb/dom], [Manchas (SSN)], [Ap / Kp máx. (sáb · dom)], [Lectura]),
  ..("2022", "2023", "2024", "2025").map(y => {
    let s = sd(y, "sábado")
    let d = sd(y, "domingo")
    (
      strong(y),
      [#calc.round(float(s.f107)) / #calc.round(float(d.f107))],
      [#s.ssn / #d.ssn],
      [#s.a_index / #kp(s.k_max) · #d.a_index / #kp(d.k_max)],
      if y == "2022" [Flujo moderado; sábado geomagnéticamente activo (Ap 25), sin llegar a tormenta.]
      else if y == "2023" [Flujo moderado; noche del sábado al domingo activa (Ap 26).]
      else if y == "2024" [Flujo *muy alto* (el mayor de las cuatro), campo solo inestable: el escenario más favorable para 10 y 15 m.]
      else [Flujo moderado; domingo muy tranquilo (Ap 3).],
    )
  }).flatten(),
)

Ninguna de las cuatro ediciones tuvo tormenta geomagnética (el Kp no llegó a 5). La previsión mensual de CelesTrak (actualizada el 1 de julio de 2026) da para *octubre de 2026* unas 84 manchas y F10.7 ≈ 119, y para *octubre de 2027* unas 57 manchas y F10.7 ≈ 98 #fecha[dato perecedero, 1-jul-2026]. Es decir: este año, condiciones parecidas a 2022, 2023 y 2025; en 2027, peores en 10 m. Las crónicas de los participantes sobre cada fin de semana (soapbox de 3830, boletines ARRL) quedan #pv.

== Puntuaciones de referencia en baja potencia

#tabla(
  columns: (auto, auto, auto, 1fr),
  table.header([Edición], [Categoría], [Estación], [Puntuación final (aprox.)]),
  [2025], [SOAB LP, 1.º mundial], [N1UR (EE. UU.)], [4.985.102 (5.199.480 declarados antes de la comprobación) @verh-cqww-records-zone @verh-cqww-raw-ssb],
  [2025], [SOAB LP, 2.º mundial], [PC0A (Países Bajos)], [2.834.758 @verh-cqww-2025-ssb-results],
  [2024], [SOAB LP, 1.º mundial], [P40W (Aruba, op. W2GD)], [≈ 7,8 M con ≈ 5.000 QSO y 100 W @hist-cqww-2024-ssb-results],
  [2024], [SOAB LP, 1.º de Europa], [UW5Y (Ucrania, op. US2YW)], [3.894.098 y placa @verh-cqww-2024-ssb-results @verh-cqww-2024-ssb-plaques],
  [2023], [SOAB LP, 1.º de Europa], [LY4L (Lituania)], [2.685.798 y placa @verh-cqww-2023-ssb-plaques],
  [2022], [SOAB LP, 1.º mundial], [WP3C (Puerto Rico)], [≈ 4,5 M @verh-cqww-2022-ssb-results],
  [2002], [Récord SOAB LP SSB], [D44TD (Cabo Verde)], [11.199.793 @hist-cqww-records],
  [2025], [Récord ROOKIE LP SSB], [9K2ES (Kuwait)], [3.550.008 @hist-cqww-records-overlay],
)

Estas cifras salen de estaciones en África o el Caribe (3 puntos casi por cada QSO) con antenas grandes y miles de QSO. Desde una terraza en Madrid el juego es otro: la comparación útil es contigo mismo de un año para otro.

== Estaciones españolas

#figure(
  caption: [Resultados finales de estaciones EA encontrados (base de datos de cqww.com, vía resúmenes de buscador). No son necesariamente las mejores EA de cada año.],
  tabla(
    columns: (auto, auto, auto, auto, auto, auto, 1fr),
    table.header([Año], [Indicativo], [Categoría], [Puntos], [QSO], [Zonas/países], [Notas]),
    [2024], [EA8AQV], [SO LOW ALL], [134.384], [312], [46 / 102], [Canarias (África: casi todo a 3 puntos); 14,8 h de operación @hist-cqww-scores-2024-p30.],
    [2023], [EA5JAX], [SO LOW ALL], [21.945], [135], [27 / 78], [22,8 h; esfuerzo modesto @hist-cqww-scores-ea-sl-p14.],
    [2023], [EA1FRY], [SO LOW ALL], [48.918], [—], [—], [Otra referencia de 2023 @verh-cqww-scores-ea-s-p25.],
    [2022], [EA4Z], [monooperador], [47.100], [224], [41 / 116], [Categoría exacta #pv @verh-cqww-2022-ssb-line-scores.],
    [2022], [CR2B (op. EA1BP)], [SO LOW ALL], [2.178.800], [2.636], [95 / 324], [Operador español desde Azores: *1.º de Europa* en baja potencia (placa) @verh-cqww-2022-ssb-results.],
    [2023], [CR2B (op. EA1BP)], [SO LOW ALL], [2.572.485], [—], [—], [2.º de Europa, tras LY4L @verh-cqww-2023-ssb-results.],
    [2024], [ED5D (op. UT5UDX)], [SO asistido ALL], [11.435.580], [—], [—], [*1.º mundial asistido* (placa); para escala @verh-cqww-2024-ssb-plaques.],
    [2024], [EA2W], [SO asistido ALL], [11.059.711], [—], [—], [Placa de Europa asistido (ED5D se lleva la mundial) @verh-cqww-2024-ssb-plaques.],
  ),
) <tab-ea>

Los resultados completos de baja potencia cuadran con la fórmula (908 × 148 = 134.384; 300 × 157 = 47.100; 209 × 105 = 21.945) y dan una idea útil: *con 135–312 QSO se hacen entre 22.000 y 134.000 puntos*. El listado histórico de cqww.com para EA en SO LOW ALL tiene más de 1.400 entradas: hay muchos españoles en tu categoría. No se encontraron rookies EA de 2022–2025 ni los mejores EA, EA6, EA8 y EA9 de cada año: #pv con `scripts/hist_fetch_scores.py`, que descarga los listados y calcula mediana y cuartiles cuando hay acceso a internet. Un detalle para tu overlay: la placa europea *Rookie SSB* del CQ WW la patrocina el EA Contest Club @verh-cqww-plaques.

=== Objetivos para tu primer CQ WW (hipotéticos)

#tabla(
  columns: (1.3fr, auto, auto, auto, auto),
  table.header([Escenario], [QSO], [Puntos (media)], [Zonas + países], [Puntuación]),
  ..ej.hipoteticos.map(h => (h.escenario, str(h.qsos), [#miles(h.puntos_qso) (#redondea(h.puntos_medios, 1))], [#h.zonas + #h.paises], strong(miles(h.total)))).flatten(),
)
Cálculo de `scripts/calc_puntuacion.py`. La media de puntos desde Madrid ronda 2 porque cerca de la mitad de los QSO suelen ser con Europa (1 punto); es un supuesto razonable, no un dato medido.

== Análisis de logs públicos

cqww.com publica en Cabrillo los logs de todas las participaciones salvo los checklogs (sin dirección ni correo), los informes de comprobación de las estaciones con más puntos y una API de puntuaciones @hist-cqww-publiclogs @hist-cqww-publiclcr @hist-cqww-api. *No fue posible descargarlos para esta guía*, así que aquí no hay gráficas de logs reales: no se han sustituido por datos inventados.

El script `scripts/hist_analyze_logs.py` está listo para hacerlo en tu Mac (con internet): descarga los logs de los indicativos que le pidas (o recorre el índice del año), filtra SO LOW (asistido o no, y ROOKIE) y genera, para cada log, QSO por hora y banda, reparto por continentes, multiplicadores acumulados y un resumen con mediana y cuartiles. Ejemplo para las estaciones EA en baja potencia de 2025:

```
.venv/bin/python scripts/hist_analyze_logs.py --download --from-index --year 2025 \
    --index-entities "Spain,Balearic Islands,Canary Islands,Ceuta & Melilla" \
    --category so-low --delay 1.5 --out salida/2025_ea_lp
```

#truco[Mira el reparto por horas de una estación EA de baja potencia parecida a la tuya: verás cuándo hizo los QSO (normalmente, de día en 15/20 m) y qué bandas le dieron más multiplicadores. Es la mejor forma de ajustar el plan del capítulo @cap-donde a la realidad.]

#fuentes("verh-cqww-2025-ssb-results", "verh-cqww-2024-ssb-plaques", "verh-cqww-2022-ssb-line-scores", "hist-cqww-2025-ssb-results", "hist-cqww-2024-ssb-results", "hist-cqww-2023-ssb-results", "hist-cqww-2022-ssb-results", "hist-cqww-records", "hist-cqww-records-overlay", "hist-cqww-scores-2024-p30", "hist-cqww-scores-ea-sl-p14", "hist-celestrak-sw-5y", "hist-pyspaceweather", "hist-cqww-publiclogs", "hist-cqww-api")
]
