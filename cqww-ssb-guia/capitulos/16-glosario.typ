#import "../plantilla.typ": *
#import "fonetica.typ": deletrear

#let refs = yaml("../bib/referencias.yml")
#let enlace(clave, texto) = {
  let r = refs.at(clave, default: none)
  if r == none { return [#texto (#clave)] }
  let u = r.at("url", default: none)
  let u = if type(u) == dictionary { u.value } else { u }
  if u == none { [#texto] } else { [#link(u)[#texto] #cite(label(clave))] }
}

#let capitulo(cfg) = [
= Glosario y enlaces <cap-glosario>

== Glosario

#set terms(separator: [: ], spacing: 0.55em, hanging-indent: 1.2em)
#columns(2, gutter: 14pt)[
  #set text(size: 8.6pt)
  #set par(justify: false)
  / 59: control de señal (legibilidad 5, intensidad 9) que se da por costumbre en todos los QSO de concurso.
  / ALC: control automático de nivel del transmisor; si se dispara, la señal se ensancha y distorsiona.
  / Asistido: categoría en la que se permite cualquier ayuda para encontrar QSO (cluster, decodificadores…).
  / Bust: indicativo o intercambio mal copiado. Si es el indicativo, penaliza.
  / Cabrillo: formato de texto estándar de los logs de concurso.
  / CAT / CI-V: control del transceptor desde el ordenador (CI-V es el protocolo de Icom).
  / Checklog: log enviado solo para ayudar a la comprobación; no puntúa.
  / Cluster (DX cluster): red donde se publican estaciones oídas (*spots*). Usarlo te hace asistido.
  / CTY: fichero de prefijos, entidades, zonas y continentes que usa el logger.
  / DVK / DVR / voice keyer: reproductor de mensajes de voz grabados (en el ordenador o en la radio).
  / DXCC: lista de «entidades» (países) de la ARRL; 340 actuales.
  / Duplicado (dupe): segundo QSO con la misma estación en la misma banda; no suma.
  / EFHW: antena de media onda alimentada en un extremo.
  / F10.7: flujo solar a 10,7 cm; cuanto más alto, mejor van 10 y 15 m.
  / HAREC: certificado armonizado de examen de radioaficionado (CEPT T/R 61-02).
  / Kp / Ap: índices de actividad geomagnética; altos significan bandas perturbadas.
  / Línea gris: franja de crepúsculo entre el día y la noche; favorece las bandas bajas.
  / LSB / USB: banda lateral inferior / superior. LSB por debajo de 10 MHz, USB por encima.
  / MUF: frecuencia máxima utilizable en un trayecto en un momento dado.
  / Multiplicador: zona o país nuevo en una banda; multiplica la suma de puntos.
  / NIL: «not in log»: el QSO no aparece en el log del otro. Penaliza.
  / Overlay: clasificación adicional dentro de monooperador (ROOKIE, YOUTH, CLASSIC).
  / Pileup: muchas estaciones llamando a la vez a la misma.
  / PTT: pulsador de transmisión (en el micro, en un pedal o por CAT).
  / QRZ: «¿quién me llama?»; en concurso, invitación a llamar.
  / Rate: ritmo de QSO por hora.
  / RBN / skimmer: red de receptores que decodifica CW y RTTY y publica lo que oye.
  / Rookie: operador con la primera licencia obtenida hace menos de 3 años.
  / Run: llamar CQ en una frecuencia fija y contestar a quien llame.
  / S&P (search & pounce): recorrer la banda buscando a quien llama CQ.
  / SCP (Super Check Partial): base de indicativos activos que el logger usa para sugerir y comprobar.
  / Soapbox: comentarios del participante; en el log Cabrillo, líneas `SOAPBOX:`.
  / Split: transmitir en una frecuencia y escuchar en otra.
  / UTC: tiempo universal coordinado; la única hora del concurso.
  / WAE: lista de países europeos del DARC; añade IT9, GM/s, JW/b, 4U1V y TA1 al CQ WW.
  / X-QSO: línea del Cabrillo para un QSO que no debe contarte, sin perjudicar al otro.
  / Zona CQ: una de las 40 zonas del mundo del diploma WAZ; Madrid es la 14.
]

== Enlaces

#set text(size: 8.4pt)
#tabla(
  columns: (auto, 1fr),
  table.header([Tema], [Documento (enlace y referencia)]),
  [Bases], [#enlace("rules-cqww-2026", "Bases del CQ WW 2026 (PDF)") · #enlace("rules-cqww-2026-changes", "Cambios de 2026") · #enlace("rules-cqww-faq", "FAQ de las bases") · #enlace("hist-cqww-rules-es-2025", "Bases 2025 en español")],
  [Log], [#enlace("rules-cqww-logcheck", "Subida y comprobación del log") · #enlace("rules-cqww-cabrillo", "Instrucciones Cabrillo del CQ WW") · #enlace("rules-wwrof-cabrillo", "Especificación Cabrillo v3 (WWROF)")],
  [Resultados], [#enlace("hist-cqww-score-db", "Base de datos de puntuaciones") · #enlace("hist-cqww-publiclogs", "Logs públicos") · #enlace("hist-cqww-records", "Récords")],
  [Normativa], [#enlace("legal-orden-iet-1311-2013", "Orden IET/1311/2013") · #enlace("legal-ley-11-2022", "Ley 11/2022") · #enlace("legal-orden-tdf-732-2026", "CNAF 2026") · #enlace("legal-ley-19-1983", "Ley 19/1983") · #enlace("legal-rd-2623-1986", "RD 2623/1986") · #enlace("legal-rd-1066-2001", "RD 1066/2001")],
  [Trámites], [#enlace("legal-mtdfp-radioaficionados-cb27", "Radioaficionados (Ministerio)") · #enlace("legal-mtdfp-examenes", "Exámenes")],
  [Plan de bandas], [#enlace("verl-iaru-r1-hf-bandplan", "Plan de bandas HF de la IARU Región 1 (2020, rev. 2021)")],
  [IC-7300MK2], [#enlace("equip-icomuk-7300mk2-basic", "Manual básico") · #enlace("equip-icomuk-7300mk2-advanced", "Manual avanzado") · #enlace("equip-icomuk-7300mk2-civ", "Guía CI-V")],
  [FT-710], [#enlace("equip-yaesu-ft710", "Página del producto") · #enlace("equip-manualslib-ft710", "Manual") · #enlace("equip-yaesu-ft710-cat", "Manual CAT")],
  [IC-705], [#enlace("equip-icomeurope-705-bro", "Folleto") · #enlace("equip-manualslib-ic705-voicetx", "Manual (memorias de voz)")],
  [Loggers], [#enlace("soft-skookum-home", "SkookumLogger") · #enlace("soft-not1mm-readme", "Not1MM") · #enlace("soft-n1mm-intro", "N1MM Logger+")],
  [Datos], [#enlace("know-cty-ad1c", "Ficheros CTY (AD1C)") · #enlace("soft-scp-home", "Super Check Partial")],
  [Radio y SDR], [#enlace("soft-hamlib-news", "Hamlib") · #enlace("soft-wfview-readme", "wfview") · #enlace("equip-sdrpp-readme", "SDR++") · #enlace("equip-owrx-readme", "OpenWebRX+") · #enlace("equip-rtlsdrblog-readme", "Drivers RTL-SDR Blog") · #enlace("soft-kiwisdr-readme", "KiwiSDR")],
)

#truco[Todas las referencias numeradas de la guía están en la bibliografía del final con su URL y la fecha de consulta (20 de octubre de 2026).]
]
