#import "../plantilla.typ": *
#import "fonetica.typ": deletrear

#let cabrillo(cfg) = (
  "START-OF-LOG: 3.0",
  "CONTEST: CQ-WW-SSB",
  "CALLSIGN: " + cfg.indicativo,
  "LOCATION: DX",
  "CATEGORY-OPERATOR: " + cfg.cab-operator,
  "CATEGORY-ASSISTED: " + cfg.cab-assisted,
  "CATEGORY-BAND: " + cfg.cab-band,
  "CATEGORY-MODE: SSB",
  "CATEGORY-POWER: " + cfg.cab-power,
  "CATEGORY-STATION: FIXED",
  "CATEGORY-TRANSMITTER: ONE",
  "CATEGORY-OVERLAY: " + cfg.cab-overlay,
  "CLAIMED-SCORE: 0",
  "CREATED-BY: (programa de log y versión)",
  "EMAIL: " + cfg.email,
  "GRID-LOCATOR: " + cfg.locator,
  "NAME: " + cfg.nombre,
  "ADDRESS: (calle y número)",
  "ADDRESS-CITY: " + cfg.qth,
  "ADDRESS-COUNTRY: Spain",
  "OPERATORS: " + cfg.indicativo,
  "SOAPBOX: ROOKIE overlay - date first licensed: " + cfg.fecha-licencia,
  "SOAPBOX: 100 W, wire antenna on a terrace in " + cfg.qth + ".",
  "QSO: 14250 PH 2027-10-30 0830 " + cfg.indicativo + "        59  14     EA8ZZZ        59  33",
  "END-OF-LOG:",
).join("\n")

#let capitulo(cfg) = [
= Herramientas de software <cap-herramientas>

== Antes de nada: qué Mac tienes

Desde aquí no se ha podido ver tu Mac. Compruébalo en Terminal: `sw_vers` (versión de macOS) y `uname -m` (`arm64` = Apple silicon; `x86_64` = Intel). Importa porque *macOS 27 solo se instala en Apple silicon*, *macOS 26 Tahoe es la última versión para Intel* y *Rosetta 2* (que ejecuta apps de Intel en Apple silicon) funcionará para uso general solo hasta macOS 27 @soft-apple-macos27-compat @soft-macrumors-rosetta. Elige software *Universal o arm64*.

== El logger: qué funciona en tu Mac

#tabla(
  columns: (auto, 1.3fr, 1.2fr),
  table.header([Opción], [A favor], [En contra]),
  [*A. SkookumLogger* (K1GQ), nativo], [Gratuito, Universal según terceros, CQ WW, memorias de voz de la radio por CAT (DVR del IC-705 e IC-7300), voz sintética (incluso tu Personal Voice), modo práctica. Versión *6.0 (13)* del 5-sep-2026 (beta 6.0 (14), 2-oct-2026); pide *macOS 13* o posterior @soft-skookum-home @soft-skookum-downloads.], [Pocos usuarios (unos 15 logs al año en el CQ WW SSB 2018–2019). #pv que el selector muestre «CQ WW SSB» en la 6.0, el soporte del IC-7300MK2 y que reproduzca WAV grabados por ti.],
  [*B. Not1MM* (K6GTE), multiplataforma], [Gratuito (GPL), plugin «CQ WW SSB» con `NON-ASSISTED` y `ROOKIE` en el Cabrillo, voice keyer con *WAV de tu voz*, SCP y CTY desde el menú, CAT por Hamlib (rigctld) o flrig. Corre en el Mac y en la Pi. Versión *26.10.18* (19-oct-2026) @rules-pypi-not1mm @soft-not1mm-readme.], [Software joven con versiones casi semanales: *fija la versión* antes del concurso (`uvx not1mm==26.10.18`). Se instala por terminal. Guía paso a paso para macOS #pv.],
  [C. N1MM Logger+ en una VM Windows], [El estándar de facto, enorme comunidad y documentación; DVK con WAV integrado. Versión 1.0.11466 (13-oct-2026) @soft-n1mm-updates.], [Solo Windows. En Apple silicon exige Windows 11 para Arm (Parallels, VMware Fusion o UTM) con N1MM emulado (x86): en los foros funciona, pero sin soporte oficial #pv, y el driver USB de Icom excluye expresamente Windows en Arm @vere-icom-usbdriver. Hay que pasar a la VM el CAT y el audio USB.],
  [D. N1MM en una VM de Proxmox por RDP], [El Mac solo es el terminal.], [El audio de SSB por RDP añade latencia y la redirección del micro no es fiable: *no recomendable* para un novel.],
  [E. Not1MM en la Raspberry Pi 5 junto a la radio], [Base para una estación remota.], [El mismo problema de audio remoto; las ruedas de PyQt6 para la Pi piden glibc 2.39 o más (o Flatpak).],
)

*Recomendación*: empieza por *B (Not1MM)* si quieres grabar tus propios mensajes y usar lo mismo en el Mac y en la Pi, o por *A (SkookumLogger)* si prefieres una app nativa de Mac. Deja *C* para cuando necesites algo propio de N1MM. Otros programas para Mac, como QLog (concursos básicos, sin puntos ni multiplicadores), RUMlogNG, MacLoggerDX o SDR-Control, son libros de guardia o control de radio, no loggers de concurso.

=== Puesta en marcha de Not1MM en el Mac (resumen)

```
brew install uv hamlib                 # uv (gestor de Python) y Hamlib 4.7.2 (rigctl/rigctld)
ls /dev/cu.*                           # antes y después de enchufar la radio: localiza su puerto
rigctld -m 3094 -r /dev/cu.usbserial-XXXX &   # 3094 = IC-7300MK2 (3085 = IC-705, 1049 = FT-710)
uvx not1mm==26.10.18                   # arranca Not1MM fijando la versión
```
En Not1MM: elige el concurso *CQ WW SSB*, pon tu indicativo, zona #cfg.zona-cq, categoría y overlay, y en la configuración de CAT, *rigctld* en `localhost:4532`. Actualiza *File → Update CTY* y *File → Update MASTER.SCP*. La velocidad del puerto y los menús de la radio (fuente de modulación USB) dependen del modelo #pv.

== Ficheros CTY y Super Check Partial

/ CTY (country-files.com, AD1C): lista de entidades DXCC y WAE con sus prefijos, zonas, continente y excepciones por indicativo. Es lo que permite al logger decirte si un QSO es multiplicador y cuántos puntos vale. Las versiones se llaman CTY-AANN; la más reciente encontrada es *CTY-3631, del 15-sep-2026*, y salen cada 8–9 días de media @soft-ctyannounce-archive. Teclear `VERSION` en el logger te dice qué fichero tienes cargado. #pv si hay una más nueva: compruébalo el 23 de octubre.
/ Super Check Partial (MASTER.SCP): base de indicativos activos en concursos; mientras tecleas, te propone los que encajan y te avisa de errores. La copia incluida en Not1MM es la «Release 2026.09.25» (50.009 indicativos) @soft-scp-home. Descárgala la víspera.

#importante[Actualiza CTY y SCP *la víspera* del concurso, no durante. Y recuerda: el SCP te ayuda a teclear, pero nunca registres un indicativo que no has oído.]

== Control CAT

#tabla(
  columns: (auto, auto, auto, auto, 1fr),
  table.header([Radio], [Hamlib], [CI-V], [Memorias de voz], [Red]),
  [IC-7300MK2], [3094 (beta)], [0xB6], [8], [LAN Ethernet (wfview y RS-BA1)],
  [IC-705], [3085 (estable)], [0xA4], [8], [Wi-Fi],
  [FT-710], [1049 (estable)], [— (CAT Yaesu ASCII)], [5], [Sin LAN (SCU-LAN10 aparte)],
)
Datos leídos en el código de Hamlib y wfview @soft-hamlib-riglist @soft-wfview-rig-ic7300mk2. *wfview* (GPLv3, para macOS, Linux y Windows) controla las tres y puede hacer de servidor de red y de emulador de rigctld para el logger @soft-wfview-readme. *flrig* es la alternativa sin Hamlib. En macOS, los chips USB-serie habituales funcionan con el driver de Apple (el puerto aparece como `/dev/cu.usbserial-…`). El FT-710 usa un Silicon Labs CP210x con dos puertos COM, Enhanced (CAT) y Standard @vere-yaesu-vcp-manual; Icom solo publica driver USB para Windows 10/11, sin Arm ni macOS @vere-icom-usbdriver, y el chip del IC-7300MK2 no se ha confirmado. Que los dos funcionen en el Mac sin driver propio está #pv: si el MK2 no aparece por USB, wfview puede usar su LAN.

== Voice keyer: tu voz, grabada

Hay dos maneras de reproducir mensajes: el *DVK del logger* (WAV en el Mac, que suenan por el códec USB de la radio) o las *memorias de voz de la radio* (8 en los Icom, 5 en el FT-710), disparadas por CAT. El DVK del logger no tiene límite de mensajes y puede deletrear el indicativo del corresponsal; las memorias de la radio no dependen del audio del ordenador.

#figure(
  caption: [Mensajes recomendados (en Not1MM, un WAV por tecla). Graba en WAV mono a *44,1 kHz*: Not1MM reproduce siempre a 44.100 Hz, y un WAV de 48 kHz sonaría un 9 % más lento y grave.],
  tabla(
    columns: (auto, auto, 1fr),
    table.header([Tecla], [Uso], [Texto]),
    [F1], [run], dice("CQ contest, " + deletrear(cfg.indicativo) + ", contest"),
    [F2], [run y S&P], dice("five nine one four"),
    [F3], [run], dice("thank you, " + deletrear(cfg.indicativo)),
    [F4], [S&P], dice(deletrear(cfg.indicativo)),
    [F7], [ambos], dice("again?"),
    [F8], [ambos], dice("your call again?"),
    [F9], [ambos], dice("your zone?"),
    [F12], [S&P], dice("thank you"),
  ),
) <tab-dvk>

Ajusta el nivel de USB MOD de la radio para que la ALC apenas se mueva, y escucha tus mensajes en un receptor aparte (el RTL-SDR o un KiwiSDR) antes del concurso.

== DX cluster: solo en asistido

El *DX cluster* es una red de nodos (telnet o web) donde se publican *spots*: indicativo, frecuencia y hora. Usarlo para encontrar QSO te pasa a la categoría *asistida*; el *self-spotting* está prohibido en cualquier categoría. Las redes de skimmers (RBN) decodifican CW y RTTY, no voz. Webs y nodos conocidos: DX Summit, DXWatch, VE7CC (CC Cluster), HamAlert; Not1MM trae por defecto el nodo `dxc.nc7j.com:7373` (URL y disponibilidad #pv). *Este año, como oyente, sí puedes usarlo* para encontrar las estaciones grandes y ver cómo se anuncian.

== Predicción y estado de la propagación

- *Predicción*: VOACAP Online (OH6BG, #url("https://www.voacap.com/"), que también ofrece ITURHFProp) y Proppy de la RSGB (#url("https://rsgb.org/proppy")) en el navegador @vere-voacap-manual @vere-rsgb-proppy; ITURHFProp (motor de la Recomendación UIT-R P.533) en línea de órdenes @soft-iturhf-readme. HamCAP es solo para Windows.
- *Tiempo real*: NOAA SWPC (índices Kp y A, flujo solar, avisos), HamQSL (resumen solar), y PSKReporter, WSPRnet y RBN como indicadores indirectos de qué rutas están abiertas. Úsalos *antes* del concurso; durante, mirar la propagación general sin buscar estaciones concretas no debería considerarse asistencia, pero las bases no lo aclaran #pv.
- El plan del capítulo @cap-donde ya incorpora un modelo de MUF calculado para estas fechas.

== Receptores web y SDR

Los receptores KiwiSDR (10 kHz–30 MHz, normalmente cuatro oyentes por receptor) se eligen en la lista pública #url("http://rx.kiwisdr.com") o en el mapa #url("http://map.kiwisdr.com") @soft-kiwisdr-readme; el directorio de WebSDR está en #url("http://websdr.org/") @vere-websdr-org-background. Durante tu participación no puedes usar receptores fuera de tu estación (bases); antes y como escucha, sí. Detalles prácticos en el capítulo @cap-escucha-2026.

== El comprobador de logs de cqww.com

La página de subida #url("https://cqww.com/logcheck/") comprueba el Cabrillo *antes* de enviarlo y te avisa de errores de cabecera o de formato; el log queda aceptado cuando recibes el correo con el número de seguimiento @rules-cqww-logcheck @rules-cqww-logs. Tras los resultados, cada participante recibe por correo el enlace a su *informe de comprobación* (LCR: resumen por bandas, NIL, busts, únicos y quién copió mal tu indicativo), y se publican los de las estaciones con más puntos @hist-cqww-publiclcr @hist-cqww-publiclcr.

== Plantilla Cabrillo para tu categoría <sec-cabrillo>

Generada con las variables del principio de `main.typ` (indicativo, locator, categoría, overlay, fecha de licencia). El logger crea el fichero completo; esta plantilla sirve para revisar la cabecera antes de subirla. El ejemplo de línea QSO usa un indicativo ficticio.

#raw(cabrillo(cfg), block: true)

#error-tipico[Olvidar la línea `SOAPBOX:` con la fecha de la primera licencia. Sin ella no entras en la clasificación ROOKIE.]

== Tu homelab

#tabla(
  columns: (auto, auto, 1fr),
  table.header([Servicio], [Dónde], [Para qué y cómo]),
  [*OpenWebRX+* 1.2.127 con el RTL-SDR V4], [Raspberry Pi 5], [Receptor web multiusuario en el puerto 8073; escuchas desde el Mac o el móvil por Tailscale (viaja audio comprimido, no I/Q). Con el V4, pon `direct_sampling=0` en los perfiles de HF @equip-owrx-defaults.],
  [*SDR++ en modo servidor*], [Pi 5 → Mac], [`sdrpp --server` (puerto 5259); en el Mac, fuente «SDR++ Server» con la IP de Tailscale, muestras Int8 y compresión @equip-sdrpp-args.],
  [*wfview* servidor], [Pi 5 o mini-PC], [Comparte por red una radio conectada por USB (el FT-710) y emula rigctld; el IC-7300MK2 y el IC-705 ya tienen red propia. Aviso de consumo alto de CPU en la Pi @soft-wfview-whatsnew.],
  [*rigctld*], [Pi 5 o Mac], [CAT remoto por Tailscale (puerto 4532); el audio va aparte.],
  [VM Windows con N1MM], [Proxmox], [Posible, pero el audio por RDP no sirve para un pileup.],
  [*Tailscale*], [Todo], [Red privada sobre WireGuard: no abras puertos a internet. App de macOS 1.104.1 (Ventura o posterior) @soft-brew-tailscale.],
)

#importante[Para operar SSB en serio, ten la radio, los cascos y el logger en la misma habitación (o usa la cadena nativa: LAN del IC-7300MK2 con wfview). Sincroniza por NTP el reloj de todos los equipos: el CQ WW cruza los logs con un margen de ±15 minutos.]

#fuentes("soft-skookum-home", "soft-skookum-downloads", "rules-pypi-not1mm", "soft-not1mm-readme", "soft-n1mm-updates", "soft-hamlib-riglist", "soft-wfview-readme", "soft-ctyannounce-archive", "soft-scp-home", "soft-iturhf-readme", "soft-kiwisdr-readme", "rules-cqww-logcheck", "rules-cqww-cabrillo", "equip-owrx-defaults", "equip-sdrpp-args", "soft-brew-tailscale")
]
