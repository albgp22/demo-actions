#import "../plantilla.typ": *
#import "fonetica.typ": deletrear
#import "diagramas.typ": diagrama-escucha

#let capitulo(cfg) = [
= Plan de escucha para este fin de semana <cap-escucha-2026>

Del sábado 24 a las 02:00 (hora de Madrid) al lunes 26 a las 00:59, las bandas estarán llenas. Tu objetivo no es «oír mucho», sino *aprender lo que necesitarás en 2027*: dónde están las estaciones a cada hora, cómo suena un QSO de concurso, qué zonas te costará copiar y cuánto ruido tienes en tu terraza. Las bases no prevén una categoría de escucha (SWL) #pv: lo que hagas es solo práctica.

== Qué receptores usar

/ Receptores web cercanos (España, Portugal): te dan una idea de *lo que oirías desde casa* con una buena antena. Elige un KiwiSDR en la lista pública (#url("http://rx.kiwisdr.com")) o en el mapa (#url("http://map.kiwisdr.com")): ordena por SNR, prefiere los que describen antena exterior y comprueba que haya plaza libre (máximo 4 oyentes por receptor).
/ Receptores lejanos: un KiwiSDR en la costa este de EE. UU., en el Caribe o Sudamérica, en Japón y en Sudáfrica o Australia. Sirven para *oír cómo llega Europa* a esos sitios y cuándo se abre cada trayecto. El WebSDR de la Universidad de Twente (Países Bajos, #url("http://websdr.ewi.utwente.nl:8901/") #pv) admite muchos oyentes a la vez y cubre toda la HF.
/ Tu RTL-SDR V4: lo que *de verdad* se oye desde tu terraza, con tu ruido local. Es la referencia más útil para elegir la antena (apartado siguiente).

#nota[No se ha podido verificar en esta guía ningún KiwiSDR concreto cerca de Madrid ni en las regiones lejanas (los directorios no eran accesibles). Elígelos tú en el mapa el viernes y apúntalos en la hoja del final del capítulo.]

== Recibir HF con tu RTL-SDR Blog V4

- *Cómo recibe HF*: el V4 lleva un conversor interno; por debajo de 28,8 MHz el driver suma 28,8 MHz automáticamente y conmuta la entrada de HF. *No uses el muestreo directo* (es para el V3) @equip-osmocom-tuner @equip-rtlsdrblog-readme.
- *Filtro de onda media*: el V4 tiene filtros de rechazo para onda media, FM y DAB; el de onda media se desactiva por debajo de 2,2 MHz, así que en 160 m las emisoras potentes pueden saturarlo. Baja la ganancia si oyes señales fantasma.
- *Driver*: hace falta librtlsdr 2.0.0 o posterior (o el fork de RTL-SDR Blog). Las versiones nightly de *SDR++ para macOS* (Apple silicon e Intel, macOS 10.15 o posterior) incluyen su propia librtlsdr compilada de la rama actual, así que el V4 debería funcionar sin instalar nada más; compruébalo lanzando la app desde Terminal y buscando `RTL-SDR Blog V4 Detected` #pv. La app no está notarizada: macOS te pedirá autorizarla en Ajustes › Privacidad y seguridad.
- *Antena*: un hilo de varios metros en el exterior, lo más lejos posible de la casa (el ruido doméstico es el enemigo). *Nunca conectes el SDR a una antena por la que transmitas* sin una conmutación protegida: 100 W lo destruyen.

#figure(
  caption: [Ajustes de SDR++ para SSB en HF con el V4 (valores del código de SDR++ y del driver).],
  tabla(
    columns: (auto, auto, 1fr),
    table.header([Ajuste], [Valor], [Motivo]),
    [Fuente], [RTL-SDR], [Módulo `rtl_sdr_source`.],
    [Sample rate], [2,4 MHz (o 1,024 MHz)], [Ves 2 MHz de banda; con menos, gastas menos CPU.],
    [Direct sampling], [*Disabled*], [El V4 usa su conversor de 28,8 MHz.],
    [Bias-T], [Apagado], [Solo con antena activa o preamplificador.],
    [Ganancia], [Manual, AGC del sintonizador apagado], [Empieza a media escala y baja si aparecen fantasmas o intermodulación.],
    [Modo], [LSB en 160/80/40 m; USB en 20/15/10 m], [Convenio de bandas laterales.],
    [Ancho de banda], [2,8 kHz (por defecto)], [Si hay estaciones pegadas, baja a 2,4 kHz.],
  ),
) <tab-sdrpp>

*Desde la Raspberry Pi 5*: si la Pi está cerca de la antena, conecta allí el V4 y escucha desde el Mac por Tailscale con *OpenWebRX+* (navegador, puerto 8073; en sus perfiles de HF pon `direct_sampling=0` para el V4) o con *SDR++ en modo servidor* (`sdrpp --server`, puerto 5259) @equip-owrx-defaults @equip-sdrpp-args. OpenWebRX+ envía audio comprimido y es el más ligero por la red. En la Pi, comprueba que la versión de librtlsdr reconoce el V4 (`rtl_test` debe decir `RTL-SDR Blog V4 Detected`).

#figure(
  diagrama-escucha(),
  kind: image,
  caption: [Escucha remota con tu homelab: el RTL-SDR junto a la antena, en la Pi, y el Mac en cualquier habitación.],
) <fig-escucha>

== Horario de escucha propuesto

Basado en el plan de bandas del capítulo @cap-donde. Recuerda que el domingo a las 01:00 UTC la hora local retrocede una hora.

#tabla(
  columns: (auto, auto, 1fr),
  table.header([UTC], [Madrid], [Qué escuchar y por qué]),
  [sáb 00–02], [sáb 02–04], [*El arranque*: 40 y 80 m llenos de Norteamérica y Europa. Oye cómo trabajan las estaciones grandes los primeros minutos.],
  [sáb 07–10], [sáb 09–12], [*20 m hacia Asia y Japón*, 15 m hacia Asia y África. Practica copiar zonas raras (17–19, 21–28).],
  [sáb 13–17], [sáb 15–19], [*10 y 15 m hacia América*: la franja clave del concurso. Busca la apertura de 10 m a Norteamérica y cuánto dura.],
  [sáb 17–19], [sáb 19–21], [*El ocaso*: línea gris en 40 m (Nueva Zelanda y Alaska hacia las 17:00–17:30 UTC) y la subida de 40 m hacia Asia.],
  [sáb 22–24], [dom 00–02], [*40/80/160 m de noche* hacia Norteamérica. Mide el ruido de tu terraza en las bandas bajas.],
  [dom 01:00], [dom 03:00 → 02:00], [Cambio de hora. En UTC no cambia nada.],
  [dom 13–19], [dom 14–20], [*El domingo por la tarde*: las estaciones grandes buscan QSO nuevos y contestan a todo. Es la hora que mejor simula tu concurso de 2027.],
  [dom 22–24], [dom 23–lun 01], [*El final*: últimos multiplicadores en 40 m y la «sprint» de última hora.],
)

== Ejercicios de copiado

+ *Indicativo + zona, al vuelo.* Sintoniza una estación que tenga un run (muchos QSO seguidos) y apunta durante 10 minutos el indicativo y la zona de *cada* estación que trabaja. Luego compara la zona con el prefijo (@tab-puntos y capítulo @cap-conocimientos): ¿tiene sentido un K5 en zona 4? ¿un VE7 en zona 3?
+ *El pileup.* Busca una estación rara con un pileup grande. Intenta sacar un indicativo completo de entre las voces que llaman. Fíjate en *quién consigue el QSO*: casi siempre el que llama en el momento justo, una vez y con claridad.
+ *Search & pounce simulado.* Recorre 20 m de punta a punta en 15 minutos y apunta cuántas estaciones diferentes oyes y cuántas serían multiplicador. Repite en 15 m y 40 m a otra hora. Así sabrás cuántos QSO por hora puede dar el S&P.
+ *Anota a la sombra (shadow logging).* Abre el logger (SkookumLogger en modo práctica o Not1MM con una base de datos de prueba) y registra como si fueras tú los QSO que oyes de un run. Te entrena las manos, el SCP y la detección de duplicados.
+ *Graba.* Graba una hora de 20 m y otra de 15 m (SDR++ y OpenWebRX+ permiten grabar el audio). En noviembre, repite el ejercicio 1 con la grabación tantas veces como quieras.
+ *Fonética real.* Apunta las palabras no UIT que oigas («Kilowatt», «Japan», «Portugal»…) y cuándo las usan: casi siempre al repetir.

== Qué observar y qué anotar para 2027

#tabla(
  columns: (auto, auto, 1fr, 1fr, 1fr),
  table.header([UTC], [Banda], [Qué oigo (continentes, zonas)], [Señal/ruido en mi terraza], [Notas]),
  ..range(0, 10).map(_ => ([~], [], [], [], [])).flatten(),
)

Al final del fin de semana, responde en una hoja:
- ¿A qué hora abrió y cerró *10 m* hacia Norteamérica? ¿Y 15 m?
- ¿Qué bandas tienen *mucho ruido* en tu terraza? Eso decide qué antena y qué bandas priorizar.
- ¿Qué zonas no has oído nunca? Serán tus multiplicadores difíciles.
- ¿Cuánto dura un QSO típico en un run? ¿Cuántos por hora hace una estación grande y cuántos una pequeña?
- ¿Qué estaciones EA has oído y con qué señal? Compara su soapbox en 3830 cuando lo publiquen.

#truco[Cuando cqww.com publique los logs de 2026, descarga los de las estaciones EA de baja potencia y analízalos con `scripts/hist_analyze_logs.py` (capítulo @cap-historico): verás su ritmo hora a hora frente a lo que tú oíste.]

#fuentes("equip-osmocom-tuner", "equip-rtlsdrblog-readme", "equip-sdrpp-ci", "equip-sdrpp-rtlsrc", "equip-owrx-defaults", "equip-sdrpp-args", "soft-kiwisdr-readme", "rules-cqww-2026")
]
