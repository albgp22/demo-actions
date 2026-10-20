#import "../plantilla.typ": *
#import "fonetica.typ": deletrear

#let cal = csv("../data/knowledge/contests_calendar.csv", row-type: dictionary)
#let meses = ("ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic")
#let fechas(s) = {
  let m = s.match(regex("(\d{4})-(\d{2})-(\d{2}) (\d{2})(\d{2})Z - (\d{4})-(\d{2})-(\d{2}) (\d{2})(\d{2})Z"))
  if m == none { return s }
  let c = m.captures
  let f(d, mo, h, mi) = [#int(d) #meses.at(int(mo) - 1) #h:#mi]
  [#f(c.at(2), c.at(1), c.at(3), c.at(4)) → #f(c.at(7), c.at(6), c.at(8), c.at(9))]
}

#let capitulo(cfg) = [
= Entrenamiento <cap-entrenamiento>

== Simuladores: lo que hay (y lo que no)

Los simuladores de concurso más conocidos son de *CW*: Morse Runner (VE3NEA) y su edición comunitaria, y RufzXP para copiar indicativos #pv. *No se ha podido verificar ningún simulador de pileups de SSB de uso extendido*, ni un modo simulador en los loggers. La alternativa que sí funciona, y que es gratuita, es entrenar con audio real:

+ *Graba el CQ WW SSB 2026* (capítulo @cap-escucha-2026) y reprodúcelo anotando «a la sombra» en el logger, en una base de datos de prueba. Puedes repetir el mismo fragmento hasta copiarlo entero.
+ *Practica el voice keyer*: graba tus mensajes (apartado @sec-cabrillo y @tab-dvk) y ensaya la secuencia de teclas de S&P y de run hasta que salga sin pensar.
+ *Super Check Partial*: practica teclear indicativos parciales y elegir el correcto de la lista; Not1MM incluye `MASTER.SCP`.
+ *Escucha concursos de CW* aunque no sepas telegrafía: sirve para observar aperturas de banda.

== Concursos para foguearte antes de 2027

#larga[#figure(
  caption: [Calendario orientativo nov 2026 – oct 2027 con contenido de SSB. Las fechas están *calculadas* con la regla habitual de cada concurso y deben confirmarse en sus bases #pv (salvo CQ WW y ARRL 10 m, coherentes con las fechas publicadas). Las URL de bases proceden del paquete Not1MM o son de memoria.],
  tabla(
    columns: (1.55fr, 1.3fr, auto, 1fr),
    table.header([Concurso], [Fechas (UTC)], [Modo], [Por qué]),
    ..cal.filter(r => r.modo.contains("SSB")).map(r => (
      r.concurso.replace(" (OBJETIVO)", "").replace(" (escucha)", ""),
      fechas(r.fechas_utc),
      r.modo,
      if r.concurso.starts-with("ARRL 10") [*Tu primer concurso*: solo 10 m, horas a elegir.]
      else if r.concurso.starts-with("ARRL International DX Contest SSB") [Solo trabajas W/VE: pileups transatlánticos.]
      else if r.concurso.starts-with("CQ WPX Contest SSB") [Como el CQ WW, con número de serie: ritmo y run.]
      else if r.concurso.starts-with("IARU HF") [24 h y zona ITU (37): ensayo de resistencia.]
      else if r.concurso.starts-with("WAE DX Contest SSB") [Solo fuera de Europa: DX puro.]
      else if r.concurso.starts-with("Concurso S.M. El Rey") [Organiza URE: muchos EA, ambiente amable.]
      else if r.concurso.starts-with("CQ WW DX Contest SSB 2027") [*El objetivo.*]
      else if r.concurso.starts-with("CQ WW DX Contest SSB 2026") [Escucha (este fin de semana).]
      else [],
    )).flatten(),
  ),
) <tab-calendario>]

== Preparación mes a mes

#tabla(
  columns: (auto, auto, 1fr),
  table.header([Cuándo], [Objetivo], [Qué hacer]),
  [24–25 oct 2026], [Escuchar], [Plan del capítulo @cap-escucha-2026: grabar, anotar aperturas, medir el ruido de la terraza.],
  [Nov 2026], [Licencia y software], [Examen y autorización (capítulo @cap-legal); instalar y configurar el logger y el voice keyer; escuchar el CQ WW CW (28–29 nov).],
  [12–13 dic 2026], [Primer concurso], [ARRL 10 m, si ya tienes indicativo y estación (aunque sea portátil): pocas horas, solo S&P.],
  [Ene–feb 2027], [Ritmo de S&P], [Concursos europeos de fin de semana (HA DX, UBA, EUDXC, PACC, REF): S&P y tablas de multiplicadores.],
  [Mar 2027], [Pileups y primeros CQ], [ARRL DX SSB, RDXC y CQ WPX SSB: prueba a llamar CQ cuando una banda abra.],
  [Abr–jun 2027], [Consolidar la estación], [Mejorar antena y chokes, pruebas con vecinos; S.M. El Rey de España SSB.],
  [Jul 2027], [Resistencia], [IARU HF: 12–24 horas con descansos programados.],
  [Ago–sep 2027], [Ensayo general], [WAE SSB y All Asian: misma estación, mismo logger y mismos mensajes que en el CQ WW.],
  [Oct 2027], [Puesta a punto], [Bases 2027, CTY y SCP, checklists del capítulo @cap-checklists y *CQ WW SSB 30–31 oct*.],
)

== Para aprender más

- *3830scores.com*: puntuaciones declaradas y crónicas (soapbox) de cada concurso; busca estaciones EA de tu categoría.
- *Contest University* y los seminarios de la *WWROF*: presentaciones y vídeos sobre técnica de concurso #pv.
- *NCJ (National Contest Journal)*: revista de concursos (ncjweb.com).
- Las bases y la FAQ del CQ WW (capítulo @cap-reglas): léelas enteras una vez al año.

#fuentes("know-not1mm-pypi", "know-morserunner", "know-ctu", "know-wwrof", "know-3830", "know-ncj", "know-arrl-10m", "know-arrl-dx", "know-cqwpx-rules", "know-arrl-iaru", "know-darc-wae", "know-ure-rey-ssb")
]
