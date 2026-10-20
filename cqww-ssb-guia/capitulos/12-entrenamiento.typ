#import "../plantilla.typ": *
#import "fonetica.typ": deletrear
#import "diagramas.typ": hoja-de-ruta

#let cal = csv("../data/knowledge/contests_calendar.csv", row-type: dictionary)
#let calv = csv("../data/verif_historia/calendario.csv", row-type: dictionary)
#let tipo-fecha(nombre) = {
  let v = calv.filter(r => r.concurso == nombre)
  if nombre.starts-with("CQ WW DX Contest") { "publicada" } else if v.len() == 0 { "calculada" } else { v.first().tipo }
}
#let marca-fecha(nombre) = {
  let t = tipo-fecha(nombre)
  text(size: 0.85em, fill: if t == "calculada" { c.ambar } else { c.tenue })[ · #if t == "publicada" [publicada] else if t == "regla" [por sus bases] else [calculada]]
}
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

Los simuladores de concurso más conocidos son de *CW*: Morse Runner (VE3NEA) y su edición comunitaria, Morse Runner CE (activa: versión 1.86 del 25 de septiembre de 2026, con CQ WW, WPX, ARRL DX e IARU HF, solo en CW) @verh-mrce-github, y RufzXP para copiar indicativos #pv. *No se ha podido verificar ningún simulador de pileups de SSB de uso extendido*, ni un modo simulador en los loggers. La alternativa que sí funciona, y que es gratuita, es entrenar con audio real:

+ *Graba el CQ WW SSB 2026* (capítulo @cap-escucha-2026) y reprodúcelo anotando «a la sombra» en el logger, en una base de datos de prueba. Puedes repetir el mismo fragmento hasta copiarlo entero.
+ *Practica el voice keyer*: graba tus mensajes (apartado @sec-cabrillo y @tab-dvk) y ensaya la secuencia de teclas de S&P y de run hasta que salga sin pensar.
+ *Super Check Partial*: practica teclear indicativos parciales y elegir el correcto de la lista; Not1MM incluye `MASTER.SCP`.
+ *Escucha concursos de CW* aunque no sepas telegrafía: sirve para observar aperturas de banda.

== Concursos para foguearte antes de 2027

#larga[#figure(
  caption: [Calendario nov 2026 – oct 2027 con contenido de SSB. «Publicada»: fecha anunciada por el organizador; «por sus bases»: calculada con la regla de sus bases vigentes; «calculada»: regla habitual no comprobada en sus bases #pv. Verificación del 20 de octubre de 2026 (`data/verif_historia/calendario.csv`).],
  tabla(
    columns: (1.55fr, 1.3fr, auto, 1fr),
    table.header([Concurso], [Fechas (UTC)], [Modo], [Por qué]),
    ..cal.filter(r => r.modo.contains("SSB")).map(r => (
      r.concurso.replace(" (OBJETIVO)", "").replace(" (escucha)", ""),
      [#fechas(r.fechas_utc)#marca-fecha(r.concurso)],
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

#figure(
  hoja-de-ruta((
    ([24–25 oct 2026], [Escuchar], [Plan del capítulo @cap-escucha-2026: grabar, anotar aperturas, medir el ruido de la terraza.], true),
    ([Nov 2026], [Licencia y software], [Examen y autorización (capítulo @cap-legal); instalar y configurar el logger y el voice keyer; escuchar el CQ WW CW (28–29 nov).], false),
    ([12–13 dic 2026], [Primer concurso], [ARRL 10 m, si ya tienes indicativo y estación (aunque sea portátil): pocas horas, solo S&P.], true),
    ([Ene–feb 2027], [Ritmo de S&P], [Concursos europeos de fin de semana (HA DX, UBA, EUDXC, PACC, REF): S&P y tablas de multiplicadores.], false),
    ([Mar 2027], [Pileups y primeros CQ], [ARRL DX SSB, RDXC y CQ WPX SSB: prueba a llamar CQ cuando una banda abra.], false),
    ([Abr–jun 2027], [Consolidar la estación], [Mejorar antena y chokes, pruebas con vecinos; S.M. El Rey de España SSB.], false),
    ([Jul 2027], [Resistencia], [IARU HF: 12–24 horas con descansos programados.], false),
    ([Ago–sep 2027], [Ensayo general], [WAE SSB y All Asian: misma estación, mismo logger y mismos mensajes que en el CQ WW.], false),
    ([30–31 oct 2027], [CQ WW SSB], [Antes: bases de 2027, CTY y SCP actualizados y las listas del capítulo @cap-checklists.], true),
  )),
  kind: image,
  caption: [Hoja de ruta hasta el CQ WW SSB 2027. Los hitos rellenos son los fines de semana clave.],
) <fig-hoja-ruta>

== Para aprender más

- *3830scores.com*: puntuaciones declaradas y crónicas (soapbox) de cada concurso; busca estaciones EA de tu categoría.
- *Contest University* (#url("https://www.contestuniversity.com/")): jornada anual (la de 2026, el 14 de mayo en Ohio) con vídeos y transparencias en su web @verh-ctu-videos; y los *seminarios web de la WWROF* (#url("https://wwrof.org/")) @verh-wwrof-blog.
- *NCJ (National Contest Journal)*: revista de concursos (ncjweb.com).
- Las bases y la FAQ del CQ WW (capítulo @cap-reglas): léelas enteras una vez al año.

#fuentes("verh-mrce-github", "verh-arrl-contest-calendar", "verh-ure-rey-ssb-bases", "know-not1mm-pypi", "know-morserunner", "know-ctu", "know-wwrof", "know-3830", "know-ncj", "know-arrl-10m", "know-arrl-dx", "know-cqwpx-rules", "know-arrl-iaru", "know-darc-wae", "know-ure-rey-ssb")
]
