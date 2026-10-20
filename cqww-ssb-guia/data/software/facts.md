# Software y herramientas en línea: hechos comprobados

Tema: registradores, ficheros de datos, CAT, manipulador de voz, cluster,
propagación, receptores remotos, herramientas de cqww.com y homelab.
Caso: operador novel EA en Madrid; Single-Op Low Power, todas las bandas,
overlay ROOKIE, no asistido por defecto. Mac de arquitectura y versión
desconocidas. Homelab con Raspberry Pi 5, Proxmox y Tailscale. Equipos
candidatos: IC-7300MK2, FT-710 AESS e IC-705. Este año solo recepción
(KiwiSDR/WebSDR y RTL-SDR Blog V4 con SDR++).

Fecha de comprobación de todo el fichero: **2026-10-20**.

## Método, límites y leyenda

- Se usó WebSearch hasta agotar el cupo de búsquedas de la sesión, que es
  compartido. Después solo se usaron fuentes primarias accesibles desde el
  entorno:
  - `raw.githubusercontent.com`: README, código y ficheros de datos.
  - PyPI y `files.pythonhosted.org`: metadatos y paquetes. El paquete
    `not1mm-26.10.18` se descargó y se leyó su código.
  - Las fórmulas y *casks* de Homebrew, para versiones actuales de apps de Mac.
- El entorno **no** podía abrir estas webs: n1mmwp.hamdocs.com, k1gq.net,
  country-files.com, supercheckpartial.com, cqww.com, kiwisdr.com, websdr.org,
  voacap.com y rx.linkfanel.net. Sus datos vienen de resúmenes de búsqueda o
  de código de terceros que las cita.
- Etiquetas de cada dato:
  - **[V1]**: fuente primaria leída directamente en esta sesión (código, README
    oficial, JSON de PyPI, fichero de datos).
  - **[V2]**: resumen o cita de WebSearch de la página indicada. No se abrió la
    página completa.
  - **[V3]**: fuente secundaria o de terceros (cask de Homebrew, rastreador de
    apps, foro).
  - **[C]**: calculado o deducido aquí a partir de datos [V1] o [V2].
  - **POR VERIFICAR**: conocimiento previo o dato no confirmado hoy.
- Las claves entre acentos graves (`soft-…`, `equip-…`, `rules-…`, `know-…`)
  son entradas Hayagriva. Las `soft-` están en `data/software/refs.yml`. Las
  `equip-`, `rules-` y `know-` las crearon los capítulos de equipo, de bases
  y de conocimientos, y aquí se reutilizan para no duplicar URL.

## 0. Contexto macOS (octubre de 2026)

- **macOS 27 "Golden Gate"** es la versión actual. Solo se instala en Mac con
  Apple silicon, y ya existe la 27.0.1 [V2, `soft-apple-macos27-compat`,
  `soft-apple-macos27-updates`].
- **macOS 26 Tahoe** es la última versión para Mac Intel, como anunció Apple
  en la WWDC 2025 [V2, `soft-macrumors-rosetta`].
- **Rosetta 2** (traducción de apps Intel) funciona para uso general hasta
  macOS 27 [V2, `soft-apple-rosetta`, `soft-macrumors-rosetta`].
  - Desde macOS 28 (previsto en 2027) solo quedará un subconjunto para juegos
    antiguos.
  - Tahoe 26.4 ya avisa de qué apps dejarán de funcionar
    [V2, `soft-macrumors-tahoe264`].
  - Al pasar a macOS 27, Rosetta no se reinstala sola [V2; la página
    concreta del resumen está **POR VERIFICAR**].
- **Consecuencia [C]**: en un Mac con Apple silicon conviene usar software
  Universal o arm64, porque una app solo-Intel tiene los días contados.
  - SkookumLogger es Universal según un rastreador de terceros [V3].
  - Not1MM usa Python y PyQt6, que publica ruedas `universal2` para macOS
    [V1, `soft-pypi-pyqt6`].
  - SDR++ tiene compilaciones *nightly* para macOS Intel y ARM, según el
    capítulo de equipo (`equip-sdrpp-ci`); no lo comprobé yo.
- **Mac Intel**: macOS 26 Tahoe sigue recibiendo actualizaciones de seguridad.
  Valen Not1MM (ruedas x86_64), SkookumLogger (Universal) y una máquina
  virtual Windows x64; ver §1.2.

## 1. Registradores de concurso

### 1.1 SkookumLogger (K1GQ), nativo de macOS

- **Qué es**: registrador de concursos para macOS, de Bill Myers K1GQ
  [V2, `soft-skookum-home`].
- **Requisito**: "macOS 13.0 (Ventura) or later" según la web del autor
  [V2, `soft-skookum-home`]. Páginas más antiguas (MacHamRadio y softwar.io)
  dicen macOS 10.15. Vale la cifra del autor.
- **Versión**: *Release* 6.0 (13), del 2026-09-05. Hay una beta 6.0 (14) con
  notas del 2026-10-02 [V2, `soft-skookum-downloads`].
  - La beta añade el Tuesday's Telegraph Test, el primer concurso definido en
    un fichero externo de reglas.
  - También abre los ajustes del sintonizador KPA1500.
- **Distribución**: la última versión de la Mac App Store es la 5.1. Las
  posteriores se descargan de k1gq.net y están notarizadas
  [V2, `soft-mhr-skookum-55`].
- **Precio**: gratuito [V2, `soft-eham-skookum`; MacHamRadio: "free of
  charge"].
- **Arquitectura**: Universal (Apple silicon + Intel), firmado y notarizado,
  según Desktop Insights para la v5.5 [V3, `soft-desktopinsights-skookum`].
  - **POR VERIFICAR** en la 6.0. En el Mac: `file
    /Applications/SkookumLogger.app/Contents/MacOS/*` debe mostrar `arm64` y
    `x86_64`.
- **CQ WW**:
  - Ya en 2011 importaba Cabrillo de CQ WW y contaba QSO y multiplicadores por
    banda [V2, `soft-skookum-history13`].
  - Unas notas de 2019 citan concursos *zones-only* "(CQ WW DX)". Se
    atribuyen, según el resumen de búsqueda, a la entrada de la v2.4.7 en
    MacHamRadio [V2, `soft-mhr-skookum-247`].
  - En la 6.0 los concursos se agrupan en ARRL, CQ, Generic y Nontests
    [V2, `soft-skookum-home`].
  - **POR VERIFICAR**: que el selector muestre "CQ WW SSB". No se vio la lista
    completa.
  - Uso real: 15 logs en el CQ WW SSB 2018 (0,18 %) y 14 en 2019 (≈0,2 %). El
    comité no avala ningún programa [V2, `soft-cqww-blog-2018`,
    `soft-cqww-blog-2019`].
- **Voz en SSB**:
  - Manipulador de voz con la síntesis de voz de Apple y Personal Voice
    [V2, `soft-mhr-skookum-51`, `soft-skookum-home`]. La v5.1 añadió un editor
    con voz, tono y velocidad por mensaje.
  - Envío de mensajes en cola y según contexto en SSB, usando el DVR
    (memorias de voz) de la radio [V2, `soft-mhr-skookum-42`].
  - DVR soportado en IC-705, IC-7300, IC-7610, IC-7850 e IC-9700
    [V2, `soft-mhr-skookum-53`].
  - Grabador de audio de QSO, del concurso entero o de fragmentos [V2].
  - **POR VERIFICAR**:
    - si puede reproducir WAV grabados por el operador como mensajes;
    - la versión mínima de macOS para Personal Voice (en macOS apareció con
      Sonoma 14).
- **Radios**:
  - IC-705 desde la 3.1.2, FT-710 desde la 4.2, y DVR del IC-7300 en la 5.3
    [V2].
  - **IC-7300MK2**: no aparece en las notas encontradas. **POR VERIFICAR**.
- **Datos**:
  - Descarga integrada de SCP y `cty.dat` [V2, `soft-skookum-home`].
  - Coincidencia parcial con SCP, con su base Exchange y con una lista de
    *good calls*, desde 3 caracteres [V2, `soft-skookum-scp-help`].
  - Subida automática del Cabrillo para ayudar a SCP [V2].
- **Drivers**: el programa es autocontenido. Solo hacen falta drivers para
  adaptadores USB-serie que macOS no soporte [V2, `soft-skookum-home`].
- **CW**: necesita un WinKeyer o una caja YCCC SO2R. No afecta a SSB [V2].
- **Modo práctica**: existe (las notas de la 5.5 lo citan al probar con logs
  de WRTC 2026). Útil este año, en que solo escuchas [V2,
  `soft-mhr-skookum-55`].
- **Cluster o telnet**: **POR VERIFICAR**. No apareció en los resultados.

### 1.2 N1MM Logger+ (Windows)

- **Plataforma**: Windows 10/11 [V2, `soft-n1mm-intro`; la redacción exacta de
  la lista de versiones admitidas está **POR VERIFICAR**].
  - Es una aplicación de 32 bits en VB.NET con SQLite, que corre en Windows
    de 32 y de 64 bits [V2, `soft-n1mm-tech`].
  - Mínimo orientativo: un núcleo a 1,6 GHz; pantalla de 1024×768 o 1366×768
    [V2, `soft-n1mm-intro`].
- **Precio**: gratuito. **POR VERIFICAR** el texto de la licencia.
- **Versión**: la última actualización es la **1.0.11466, del 2026-10-13**
  [V2, `soft-n1mm-updates`]. La FlexRadio Community también cita esa versión
  [V2].
  - Antes salieron 1.0.11462 (2026-10-06) y 1.0.11455 (2026-09-29).
  - Instalador completo: 1.0.11364 (2026-07-21).
  - Para actualizar basta con instalar la *Latest Update*. Solo hay que
    reinstalar entero si cambian los dos primeros números de la versión
    [V2, `soft-n1mm-install`].
- **Manipulador de voz (DVK) integrado** [V2, `soft-n1mm-fkeys`,
  `soft-n1mm-configurer`, `soft-n1mm-interfacing`]:
  - Los `.wav` van en la carpeta `wav` de los ficheros de usuario (dentro de
    Documentos), con subcarpetas por operador.
  - En la tecla de función se escribe `nombre.wav`.
  - El menú Config → *Logger+ Audio Setup* fija el dispositivo de salida (el
    códec USB de la radio) y el de grabación, normalmente el micrófono.
  - Puede silenciar el micro mientras suena un mensaje.
  - En Windows 10/11 hay que permitir el acceso al micrófono.
  - `LettersFiles` contiene letras y dígitos para "decir" indicativos y
    números.
  - Con DVK externo, las teclas usan `empty.wav`.
  - No se marca "Use Logger+ audio" si se usa el DVR de la radio o un DVK
    externo.
  - Para el DVR del IC-7300 desde N1MM hay una guía de terceros
    [V3, `equip-pe4bas-n1mm`].
- **En un Mac**: no hay versión para macOS. Opciones:
  - **Apple silicon**: solo en máquina virtual con Windows 11 para Arm, porque
    no hay Boot Camp.
    - Microsoft autoriza Parallels Desktop 18, 19 y 20 para Windows 11 Pro y
      Enterprise para Arm en M1, M2 y M3 [V2, `soft-ms-win11-mac`].
    - Parallels actual: 27.0.3. Su *cask* exige arm64 y macOS Sonoma o
      posterior [V3, `soft-brew-parallels`].
    - VMware Fusion Pro es gratuito para uso no comercial desde 2024, y
      descarga Windows on Arm desde la versión 13.5 [V2, `soft-macworld-fusion`].
    - UTM 5.0.8 (QEMU) es gratuito [V3, `soft-brew-utm`].
    - N1MM es x86 y corre emulado en Windows on Arm. No se encontró ninguna
      confirmación de N1MM ni de los drivers USB-serie Arm64 de las radios en
      esa configuración. **POR VERIFICAR**: probarlo semanas antes.
  - **Intel**: Parallels 20.4.2 (su *cask* pide macOS Monterey o posterior,
    sin restricción de arquitectura) [V3, `soft-brew-parallels20`] y
    VirtualBox 7.2.22, con versión Intel y ARM [V3, `soft-brew-virtualbox`].
    Boot Camp con Windows 10: **POR VERIFICAR**.
  - **CrossOver o Wine**: N1MM no los soporta oficialmente.
    - CodeWeavers da a N1MM Logger+ 1.0.4350 "Unrated" en Mac y "Runs Great"
      en Linux, con una valoración antigua [V2, `soft-codeweavers-n1mm`].
    - La instalación es manual y hay que asignar los puertos serie.
    - CrossOver Mac va por la 26.3.0 y es de pago [V3, `soft-brew-crossover`].

### 1.3 Not1MM (K6GTE), multiplataforma

- **Qué es**: Python 3.11+ con PyQt6 y SQLite, licencia GPL-3.0-or-later.
  Apunta sobre todo a Linux y macOS (clasificadores de PyPI "MacOS X" y
  "Linux") [V1, `rules-pypi-not1mm`, `soft-not1mm-readme`].
  - Advierte que **no es N1MM** ni pretende interoperar con él [V1].
- **Versión**: **26.10.18**, subida a PyPI el **2026-10-19** (00:50 UTC)
  [V1, JSON de PyPI].
  - Publica casi cada semana: 26.9.24, 26.9.27, 26.10.1, 26.10.2, 26.10.5,
    26.10.11 y 26.10.18 [V1, `soft-not1mm-changelog`].
  - **Recomendación [C]**: fija la versión antes del concurso con `uvx
    not1mm==26.10.18`, para que no se actualice sola.
- **Instalación**: `uvx not1mm`, pipx o Flatpak (Linux)
  [V1, `soft-not1mm-install`].
  - En macOS instala la dependencia `pyobjc-framework-Cocoa` [V1].
  - PyQt6 6.11.0 tiene ruedas `universal2` para macOS y `manylinux_2_39_aarch64`
    para ARM con Linux, que piden glibc 2.39 o más [V1, `soft-pypi-pyqt6`].
  - **POR VERIFICAR**: una guía paso a paso para macOS. La guía de instalación
    solo detalla Linux.
- **CQ WW SSB**: incluye el plugin "CQ WW SSB", con nombre Cabrillo
  `CQ-WW-SSB` [V1, código `plugins/cq_ww_ssb.py` del paquete,
  `soft-not1mm-wheel`].
  - Intercambio "RS + CQ Zone No.". Multiplicadores: zona y país una vez por
    banda.
  - Cabecera Cabrillo con `CATEGORY-ASSISTED` (`ASSISTED` / `NON-ASSISTED`)
    y `CATEGORY-OVERLAY` (`CLASSIC`, `ROOKIE`, `YOUTH`…).
  - Aparece en la lista de concursos [V1, `soft-not1mm-contests`].
- **Manipulador de voz (WAV)** [V1, `voice_keying.py`, `__main__.py`,
  `fsutils.py` y el paquete `appdata`]:
  - Reproduce WAV con sounddevice/PortAudio en el dispositivo de audio elegido
    y activa el PTT por CAT.
  - Ficheros por operador:
    - macOS: `~/.not1mm/<INDICATIVO>/`;
    - Linux: `~/.local/share/not1mm/<INDICATIVO>/`.
  - Las macros entre corchetes llaman a ficheros: `[cq]` → `cq.wav`.
  - `{MYCALL}` y `{HISCALL}` se deletrean con un fichero por carácter:
    `a.wav`…`z.wav`, `0.wav`…`9.wav` y `space.wav`.
  - Al elegir operador se copian los WAV de ejemplo del paquete, entre ellos
    `k6gte.wav` (el indicativo del autor). Conviene sustituirlos por
    grabaciones propias.
  - **Reproduce siempre a 44 100 Hz** (`sd.default.samplerate = 44100.0`,
    sin usar la frecuencia del fichero).
  - **Consecuencia [C]**: graba los WAV a 44,1 kHz. Un WAV de 48 kHz duraría
    un 8,8 % más y sonaría más grave.
- **Memorias de voz de la radio**: las macros `{VOICE1}`…`{VOICE10}` envían
  `\send_voice_mem n` a rigctld [V1].
  - En la 26.10.18 solo lo implementa el *backend* rigctld, no flrig ni TCI
    [V1].
- **Macros SSB por defecto** (`data/ssbmacros.txt`) [V1]:
  - S&P: F1 `{MYCALL}`, F2 `{SNT} {EXCH}`, F3 `{SENTNR}`, F7 `[roger]`,
    F8 `[73]`, F9 `[again]`, F10 `[yourcall]`, F11 `[mynumber]`,
    F12 `[thankyou]`.
  - RUN: F1 `[cq]`, F2 `{HISCALL}`, F3 `{SNT} {EXCH}`, F4 `[thankyouqrz]`,
    F5 `{MYCALL}`, F6 `{SENTNR}`, F8 `[roger]`, F9 `[again]`,
    F10 `[yourcall]`, F11 `[mynumber]`.
- **CAT**: rigctld (puerto 4532 por defecto), flrig o TCI
  [V1, `soft-not1mm-readme`, `lib/preferences.py`].
  - Problemas conocidos: Hamlib anterior a 4.6.3 fallaba al enviar CW y con la
    velocidad. wfview da problemas con la frecuencia y la CW.
- **Cluster**: ventana de cluster y *bandmap*. Servidor por defecto
  `dxc.nc7j.com:7373`, con filtro `Set DX Filter SpotterCont=NA`
  [V1, `lib/preferences.py`].
  - Para Europa habría que poner `SpotterCont=EU`.
  - Usarlo te hace ASSISTED; ver §5.
- **SCP**: el menú File → **Update MASTER.SCP** descarga
  `https://www.supercheckpartial.com/MASTER.SCP` [V1,
  `lib/super_check_partial.py`, `main.ui`]. La copia incluida es la "Release
  2026.09.25", de 50 009 líneas [V1].
- **CTY**: usa Big CTY de country-files.com, que lee del feed RSS con
  `notctyparser` 26.8.31 y guarda como `cty.json`. Se actualiza a mano con
  el menú File → **Update CTY** [V1, `soft-notctyparser-pypi`, `main.ui`].
- **Subida del log**: el plugin apunta a https://cqww.com/logcheck/ y a las
  bases. Coincide con el capítulo de bases (`rules-cqww-logcheck`) [V1].

### 1.4 Otros programas (una línea cada uno)

| Programa | ¿Concursos? | macOS | Dato verificado | Fuente |
|---|---|---|---|---|
| QLog | Básico: intercambio, números de serie, duplicados y Cabrillo; **no** calcula puntos ni multiplicadores | Sí (DMG de aa5sh) | Linux, Windows y macOS; CAT con Hamlib, flrig, TCI y OmniRig (solo Windows) | [V1, `soft-qlog-readme`] |
| RUMlogNG (DL2RUM) | Libro general (modo concurso **POR VERIFICAR**) | Sí | 6.0 (2026-01-01): soporte básico del IC-7300MK2 y panel con LAN y audio en los dos sentidos. 6.0.2 (2026-01-22). | [V2, `soft-mhr-rumlog-60`, `soft-mhr-rumlog-602`] |
| MacLoggerDX (Dog Park) | No: libro DX y control del equipo | Sí | 6.61 añadió el driver del IC-7300MK2 (entrada del 2026-05-30); la actual es la 6.62. De pago: **POR VERIFICAR** | [V2, `soft-mhr-mldx-661`; V3, `soft-brew-macloggerdx`] |
| SDR-Control for Icom (DL8MRE) | No: control y panorámico | Sí (macOS 14 o posterior según la App Store) | 2.10.3 (entrada del 2026-10-07); soporta el IC-7300MK2 | [V2, `soft-mhr-sdrcontrol-2103`, `equip-sdrcontrol-appstore`] |
| TR4W | Sí | No (Windows) | Gratuito y de código abierto. El repositorio de GitHub está congelado mientras migra a Delphi 12. | [V1, `soft-tr4w-readme`] |
| TLF | Sí (consola) | **POR VERIFICAR** | Registrador de concursos en modo texto para Linux; sirve en la Pi. Desde TLF 1.3.1 lee `cty.dat` CT9 con excepciones `=` | [V1, `soft-tlf-readme`] |
| DXLog.net | Sí | No (Windows) | Versión y licencia **POR VERIFICAR** | — |
| Win-Test | Sí (de pago) | No (Windows) | Versión y precio **POR VERIFICAR** | — |
| Log4OM | No (libro general) | No (Windows) | Versión **POR VERIFICAR** | — |

### 1.5 Recomendación para este operador [C]

**Este año (solo escucha)**:

- Practica con un registrador anotando lo que oigas en KiwiSDR/WebSDR o en el
  RTL-SDR, sin enviar nada.
  - SkookumLogger tiene modo práctica.
  - Not1MM sirve con cualquier CQ WW SSB de prueba.
- El capítulo de bases no encontró ninguna categoría SWL en el CQ WW 2026
  (`rules-cqww-2026`). **POR VERIFICAR**.

**Con equipo propio (p. ej., CQ WW SSB 2027)**:

| Opción | A favor | En contra |
|---|---|---|
| **A. SkookumLogger en el Mac** (recomendada si quieres la experiencia más "Mac") | Nativo y Universal; gratuito; CQ WW; DVR del IC-705/IC-7300 por CAT; voz sintética, incluso tu propia Personal Voice | macOS 13 o posterior; soporte del IC-7300MK2 sin confirmar; pocos usuarios (≈0,2 % de los logs); sin WAV propios confirmados |
| **B. Not1MM en el Mac** (recomendada si quieres WAV con tu voz y la misma herramienta en Mac y Pi) | Gratuito y GPL; DVK con WAV; `NON-ASSISTED` + `ROOKIE` en el Cabrillo; CAT con Hamlib (IC-7300MK2 = modelo 3094); SCP y CTY con un clic desde el menú | Software joven, con versiones semanales (fija la versión); se instala por terminal; necesita rigctld o flrig |
| **C. N1MM+ en una VM Windows en el Mac** | El estándar de facto, con documentación y comunidad enormes | En Apple silicon: Windows 11 Arm, emulación x86 y drivers USB sin confirmar; licencia de Windows; hay que pasar a la VM la radio y su audio USB |
| **D. N1MM+ en una VM de Proxmox por RDP** | El Mac solo hace de terminal | El audio de RX y TX va por RDP o por paso USB, con latencia (ver §9); poco adecuado para un novel en SSB |
| **E. Not1MM en la Raspberry Pi 5 junto a la radio** | La Pi vive en el cuarto de radio; base para una estación remota | El audio remoto tiene el mismo problema; PyQt6 aarch64 pide glibc 2.39 o más (o Flatpak) |

- **Orden sugerido [C]**: B o A para empezar, y C solo si necesitas algo
  propio de N1MM.
- Elige la radio también por el software:
  - IC-7300MK2 e IC-705: CI-V con Hamlib y wfview.
  - FT-710: CAT con Hamlib; wfview la soporta por USB. La radio no tiene LAN:
    el remoto pasa por un servidor wfview o por el SCU-LAN10.

## 2. Ficheros de datos

### 2.1 Ficheros de países CTY (country-files.com, AD1C)

- **Qué son** [V2, `know-cty-ad1c`, `soft-ctyfiles-format`]:
  - listas de entidades (DXCC, más las WAE que cuenta CQ WW), con prefijos,
    zonas CQ e ITU, continente y coordenadas;
  - excepciones por indicativo exacto, marcadas con `=`;
  - formatos para cada programa (CT9 `cty.dat`, WriteLog, Win-Test, XML, Big
    CTY). Las mantiene Jim Reisert AD1C.
- **Nomenclatura**:
  - Cada versión se llama CTY-AANN; 36 corresponde a 2026, según la serie
    CTY-3601 a CTY-3631.
  - Lleva un indicativo ficticio `VERaaaammdd`.
  - El indicativo `VERSION` cae en una entidad distinta en cada versión: si
    tecleas VERSION en el registrador, sabes qué fichero tiene cargado.
  - Ejemplo: CTY-3620, del 03-jun-2026, es VER20260603, con entidad de versión
    Kingdom of Eswatini (3DA) [V2, `soft-cty-3620`].
  - Coincide con el fichero local `data/cty/cty_not1mm.json`, donde VERSION
    lleva a Kingdom of Eswatini [V1].
- **Últimas versiones encontradas** [V2, `soft-ctyannounce-archive`,
  `soft-cty-3630`, `soft-cty-3629`]:
  - **CTY-3631, del 15-sep-2026**: la más reciente hallada; notas no leídas.
  - CTY-3630, del 06-sep-2026.
  - CTY-3629, del 26-ago-2026: VER20260826, entidad de versión Christmas
    Island (VK9X).
  - CTY-3628 (18-ago, entidad 4U1I), CTY-3626 (03-ago) y CTY-3625 (01-ago).
- **POR VERIFICAR**: si ha salido otra versión entre el 15 de septiembre y el
  concurso. Compruébalo el **23-oct-2026**.
- **Cadencia [C]**: unas 31 versiones entre CTY-3601 (03-ene) y CTY-3631
  (15-sep), es decir, una cada 8 o 9 días.
- **Qué fichero usa cada programa**:
  - Not1MM: Big CTY convertido a `cty.json`, con el menú File → Update CTY
    [V1].
  - SkookumLogger: `cty.dat`, con descarga integrada [V2].
  - TLF: `cty.dat` CT9 con excepciones `=` [V1, `soft-tlf-news`].
  - N1MM Logger+: `wl_cty.dat`. **POR VERIFICAR**: es conocimiento previo, no
    se leyó la página de N1MM en country-files.
  - Win-Test: tiene descarga propia [V2]; nombre del fichero **POR VERIFICAR**.
- **Big CTY** es la versión ampliada para el registro diario, no para
  concursos [V2, `soft-ctyfiles-bigcty`].
  - **[C]**: para puntuar en directo da igual, porque el comité recalcula la
    puntuación con sus propias listas.
- **WAE en CQ WW** [V1, `data/cty/cty_tlf.dat` y `cty_not1mm.json`]:
  - Las entidades WAE que no son DXCC llevan asterisco en `cty.dat`, o el
    texto "(not DXCC)" en el JSON.
  - Son seis: \*4U1V (Vienna Intl Ctr), \*GM/s (Shetland), \*IG9 (African
    Italy), \*IT9 (Sicily), \*JW/b (Bear Island) y \*TA1 (European Turkey).
  - **POR VERIFICAR** con el capítulo de bases (`rules-cqww-2026`) que CQ WW
    cuenta la lista DXCC más la WAE.
- **Península [V1]**:
  - EA, zona CQ 14 (EU), lo que da el intercambio "59 14" desde Madrid; EA6,
    zona 14 (EU); EA8, zona 33 (AF); EA9, zona 33 (AF).
  - CT, zona 14 (EU); CT3, zona 33 (AF); CU, zona 14 (EU).
  - Los ficheros de 2020 y 2026 coinciden.
- **Aviso**: `data/cty/cty_tlf.dat` es **VER20200405**, de 2020 [V1]. No sirve
  para el concurso; el JSON de 2026 (VER20260603) es mejor referencia.

### 2.2 Super Check Partial (MASTER.SCP)

- **Qué es**: una base de indicativos activos en concursos que sirve para
  completar y comprobar lo que tecleas. Not1MM la descarga de
  `https://www.supercheckpartial.com/MASTER.SCP` [V1, `soft-scp-home`].
- **Versión**: la copia incluida en Not1MM 26.10.18 dice "Release 2026.09.25",
  "Generated by bb-scp", 50 009 líneas [V1].
  - **POR VERIFICAR**: la versión vigente en la web y su cadencia. Descárgala
    la víspera.
- **Cómo se carga**:
  - SkookumLogger: descarga integrada; también puede subir tu Cabrillo para
    mejorar SCP [V2].
  - Not1MM: menú File → Update MASTER.SCP [V1].
  - N1MM: menú Tools → descargar el último Check Partial (Master.scp).
    **POR VERIFICAR** el texto exacto.
- **¿Es asistencia?**: **POR VERIFICAR** con las bases. La definición de
  asistencia de 2026 (`rules-cqww-2026`) habla de tecnología que identifica la
  señal que estás oyendo; SCP solo compara con lo que tecleas.

## 3. CAT y control del equipo

### 3.1 Datos de los equipos candidatos [V1]

Fuentes: Hamlib `riglist.h`, `rigs/icom/ic7300.c` y `rigs/yaesu/ft710.c`, y
los ficheros de equipo de wfview (`soft-hamlib-riglist`, `soft-hamlib-ic7300c`,
`soft-hamlib-ft710c`, `soft-wfview-rig-ic7300mk2`, `soft-wfview-rig-ic705`,
`soft-wfview-rig-ft710`).

| Equipo | Modelo Hamlib | Estado Hamlib (master) | Dirección CI-V por defecto | Memorias de voz (Hamlib) | Red (fichero wfview) |
|---|---|---|---|---|---|
| IC-7300MK2 | 3094 | BETA | 0xB6 (182) | 8 | LAN Ethernet; sin Wi-Fi |
| IC-705 | 3085 | STABLE (máx. 19 200 baudios en Hamlib) | 0xA4 (164) | 8 | Wi-Fi |
| IC-7300 (referencia) | 3073 | STABLE | 0x94 (148) | 8 | Sin LAN |
| FT-710 | 1049 | STABLE | — (CAT Yaesu en ASCII) | 5 (`PB01;`…`PB05;`) | Sin LAN en wfview |

- El PTT por CAT (`RIG_PTT_RIG`) está declarado para el IC-7300MK2 y el FT-710
  [V1].
- Hamlib 4.7.0 (15-feb-2026) añadió comandos extendidos del IC-7300MK2, así
  que el modelo existe al menos desde esa versión [V1, `soft-hamlib-news`].
- El capítulo de equipo daba la dirección B6h del IC-7300MK2 como "según un
  foro". El código de Hamlib y wfview la confirma [V1].
- Disparo de las memorias de voz [V1]:
  - Icom: CI-V `0x28` ("Transmit Voice Memory Contents") con el canal en BCD;
    0 para.
  - Yaesu: `PB0n;`, con 0 para parar.

### 3.2 Hamlib, rigctld y flrig

- **Hamlib**: la última versión es la **4.7.2, del 2026-06-21** [V1,
  `soft-hamlib-news`]. La fórmula de Homebrew descarga `hamlib-4.7.2.tar.gz`
  [V1, `soft-brew-hamlib`]. Licencia LGPL [V1].
  - La 4.7.1 (15-abr) y la 4.7.2 corrigen cosas del FT-710 [V1].
  - **5.x en desarrollo** (sin publicar): flujo experimental de audio e I/Q
    desde rigctld por UDP [V1].
  - **[C]**: hoy rigctld solo lleva CAT; el audio va por otro camino.
  - En el Mac se instala con `brew install hamlib`, que trae `rigctl` y
    `rigctld`.
  - Puerto por defecto de rigctld: 4532 (el que usa Not1MM) [V1].
- **flrig** (W1HKJ): control de equipo con clases propias, sin Hamlib [V1,
  `soft-flrig-readme`].
  - Va por la 2.0.12, con DMG para macOS [V3, `soft-brew-flrig`].
  - Web: https://www.w1hkj.org/.
  - El espejo de GitHub está desactualizado (2.0.0, de 2023) [V1].

### 3.3 wfview

- **Qué es**: control de Icom, Kenwood y Yaesu modernos para Linux, macOS y
  Windows, con licencia GPLv3. Web: https://wfview.org/ [V1,
  `soft-wfview-readme`].
- **Versión**: el `wfview.pro` del espejo de GitHub define `WFVIEW_VERSION`
  "2.22" [V1, `soft-wfview-pro`]. **POR VERIFICAR**: la fecha de esa versión y
  si las descargas para macOS son arm64 o Universal.
- **Equipos**: tiene ficheros para el IC-7300MK2 (versión 2.21), el IC-705 y
  el FT-710 [V1].
  - El capítulo de equipo marcaba como **POR VERIFICAR** el soporte del
    IC-7300MK2 en wfview: queda resuelto.
  - El IC-7300MK2 admite como fuente de modulación MIC, USB, ACC,
    **"MIC, USB"**, "MIC, ACC" y LAN.
  - El FT-710 usa la librería FT4222 de FTDI "for FT-710 SPI support".
- **Servidor**: el código incluye `icomserver`, `yaesuserver`,
  `kenwoodserver`, `rigctld`, `tciserver` y `tcpserver` [V1, `wfview.pro`].
  - Puede compartir por red una radio conectada por USB y emular rigctld para
    los registradores.
  - Los detalles de configuración y puertos están **POR VERIFICAR** en el
    manual de wfview.org.
- **Raspberry Pi**: "We know about high CPU usage on RPi." [V1,
  `soft-wfview-whatsnew`].
- **Not1MM** avisa de problemas con wfview en la frecuencia y la CW [V1].

### 3.4 USB, drivers y audio en macOS

- SkookumLogger solo pide drivers para adaptadores USB-serie que macOS no
  soporte [V2]. El capítulo de equipo recoge lo mismo sobre el puente Silicon
  Labs del IC-7300 (`equip-silabs-vcp`, `equip-platformio-silabs-mac`).
  - Con el driver integrado sale como `/dev/cu.usbserial-*`; también existe el
    driver VCP de SiLabs.
  - **POR VERIFICAR** el chip USB exacto del IC-7300MK2 y del FT-710.
- **Comprobación práctica [C]**: ejecuta `ls /dev/cu.*` antes y después de
  enchufar la radio.
- **Audio**: los códecs USB de las radios suelen ser USB Audio Class y no
  piden driver en macOS. **POR VERIFICAR** en cada modelo.
  - El registrador reproduce el WAV en ese códec y activa el PTT por CAT.
  - En la radio hay que elegir el USB como fuente de modulación en SSB sin
    modo DATA. En la familia IC-7300, la opción "MIC, USB" existe según
    wfview [V1]. Los nombres exactos de menú están **POR VERIFICAR** en los
    manuales.
- **Icom RS-BA1 V2**: software oficial de control remoto por LAN, solo para
  Windows. Ver capítulo de equipo, claves del IC-7300MK2. Versión y precio
  **POR VERIFICAR**.
- **Yaesu SCU-LAN10**: unidad de red opcional para el FT-710, que pide
  actualizar el firmware de ambos y usa software Windows [capítulo de equipo,
  `equip-kpo-scu-lan10`]. **POR VERIFICAR** su compatibilidad con macOS: no se
  conoce ninguna.

## 4. Manipulador de voz (DVK)

### 4.1 DVK del registrador o memorias de la radio [V1/V2 + C]

| | DVK del registrador (WAV en el ordenador) | Memorias de la radio (DVR) |
|---|---|---|
| Número de mensajes | Ilimitado (un WAV por tecla) | IC-7300, IC-7300MK2 e IC-705: **8**; FT-710: **5** [V1 Hamlib] |
| Duración | Sin límite práctico | IC-7300 e IC-705: 1,5 min por memoria; FT-710: 90 s por memoria, con tarjeta SD (capítulo de equipo, `equip-manualslib-ic7300-voicetx`, `equip-manualslib-ic705-voicetx`, `equip-manualslib-ft710`); IC-7300MK2: **POR VERIFICAR** |
| Deletreo automático del indicativo contrario | Sí: N1MM con `LettersFiles` y Not1MM con un WAV por carácter | No |
| Dependencias | Códec USB de audio, nivel USB MOD y PTT por CAT | Solo CAT (o los botones del panel); suelen ir en tarjeta SD |
| Soporte | N1MM [V2]; Not1MM [V1]; SkookumLogger con voz sintética [V2] | SkookumLogger: DVR del IC-705 e IC-7300 [V2]; Not1MM: `{VOICEn}` por rigctld [V1]; N1MM con el IC-7300 según guía de terceros [V3] |

### 4.2 Mensajes recomendados [C]

El intercambio de CQ WW SSB es RS + zona CQ, y Madrid está en la zona 14
(§2.1). Usa el alfabeto ITU y el inglés. Los QSO entre estaciones del mismo
país valen 0 puntos, aunque cuentan como multiplicador, según la cabecera del
plugin de Not1MM [V1].

En la tabla, EA4XXX es un indicativo de ejemplo.

| Tecla | Modo | Texto grabado | Uso |
|---|---|---|---|
| F1 | RUN | "CQ contest, Echo Alfa Four X-ray X-ray X-ray, EA4XXX, contest" | Llamada; menos de 4 s |
| F2 | RUN y S&P | "Five nine, one four" | Intercambio "59 14" |
| F3 | RUN | "Thank you, EA4XXX, contest" | Cierra el QSO y te identifica |
| F4 | S&P | "Echo Alfa Four X-ray X-ray X-ray" | Tu indicativo, una vez y con fonética |
| F5 | RUN | (lo dices tú en directo, o lo deletrea el registrador) | Indicativo del corresponsal |
| F6 | RUN | "QRZ?" | Tras un *pile-up* confuso |
| F7 | ambos | "Again?" / "Say again?" | Repetición |
| F8 | ambos | "Your call again?" | Indicativo dudoso |
| F9 | ambos | "Your zone?" | Zona dudosa |
| F12 | S&P | "Thank you" | Cierre en S&P |

- Grabación [C]: WAV mono a 44,1 kHz (imprescindible en Not1MM), con el nivel
  normalizado.
  - Ajusta el USB MOD de la radio para que el ALC apenas se mueva.
  - Escucha tus mensajes con un receptor aparte (el RTL-SDR o un KiwiSDR) antes
    del concurso.
- En S&P, los mensajes pregrabados son sobre todo F4 (indicativo) y F2
  (intercambio).

## 5. DX cluster, RBN y alertas

- **Qué es**: una red de nodos (telnet o web) donde los radioaficionados
  publican "spots": indicativo, frecuencia y hora.
- **Efecto en la categoría**: según el capítulo de bases (`rules-cqww-2026`,
  `rules-cqww-faq`) cualquier "QSO finding assistance" te pasa a
  **ASSISTED**. Eso incluye el DX cluster, las webs de spots, el Skimmer y la
  RBN.
  - La FAQ dice: "Do not use any outside tools such as the DX Cluster or RBN
    network to locate new contacts".
  - Se permite el panorámico o la cascada **sin** indicativos.
  - El *self-spotting* está prohibido.
- **[C] Para un SO no asistido**: no abras la ventana de cluster de Not1MM, no
  conectes el telnet del registrador y no tengas webs de spots abiertas.
  Desactiva también las alertas en el móvil.
- **Nodos y webs** (**POR VERIFICAR** las URL; no se pudieron abrir hoy):
  - DX Summit (https://www.dxsummit.fi/, `soft-dxsummit`);
  - DXWatch (https://dxwatch.com/, `soft-dxwatch`);
  - VE7CC CC Cluster / CC User (https://www.ve7cc.net/, `soft-ve7cc`);
  - HamAlert (https://hamalert.org/, `soft-hamalert`), alertas por app o
    correo;
  - nodo telnet `dxc.nc7j.com:7373`, que solo consta como valor por defecto de
    Not1MM [V1]; su disponibilidad está **POR VERIFICAR**.
- **Filtrar SSB**:
  - En nodos AR-Cluster, el filtro por defecto de Not1MM tiene la forma
    `Set DX Filter SpotterCont=NA` [V1]. Para Europa: `SpotterCont=EU`.
  - En DX Spider o CC Cluster, la sintaxis para quedarse con la fonía (p. ej.
    `accept/spots on hf/ssb`) está **POR VERIFICAR**.
- **RBN y Skimmer**: decodifican CW y RTTY, no la voz, así que no hay "skimmer
  de SSB" en la RBN (**POR VERIFICAR** en reversebeacon.net).
  - **[C]**: en SSB el cluster depende de que otros te pongan en la lista.
- **Este año (solo escucha)** [C]: el cluster sirve para encontrar a los
  grandes "run" y aprender cómo se publican.

## 6. Propagación

### 6.1 Predicción

| Herramienta | Tipo | ¿En el Mac? | Dato | Verificación |
|---|---|---|---|---|
| ITURHFProp / P533 (ITU-R WP 3L) | Motor y CLI de la Recomendación ITU-R P.533-14 (ruido P.372-15) | Hay que compilar o usar algo que lo envuelva | Predice frecuencias, señal y fiabilidad en HF | [V1, `soft-iturhf-readme`] |
| Proppy | Web basada en ITURHFProp | Navegador | URL https://soundbytes.asia/proppy/ | **POR VERIFICAR** (`soft-proppy`) |
| VOACAP Online (OH6BG) | Web basada en VOACAP | Navegador | https://www.voacap.com/hf/ | **POR VERIFICAR** (`soft-voacap-online`) |
| voacapl (M0DNS/HZ1JW) | VOACAP portado a Linux (gfortran) | Linux; en Mac **POR VERIFICAR** | Línea de órdenes | [V1, `soft-voacapl-readme`] |
| pythonprop (`voacapgui`) | Interfaz GTK3 para VOACAP | Linux | Mapas y gráficas | [V1, `soft-pythonprop-readme`] |
| HamCAP (VE3NEA) | Windows | Solo en VM | **POR VERIFICAR** | — |
| DR2W | — | — | No identificado en esta sesión: **POR VERIFICAR** | — |

### 6.2 Tiempo real (todo funciona en un navegador del Mac)

Las URL de esta lista están **POR VERIFICAR**; no se pudieron abrir hoy.

- **NOAA SWPC** (https://www.swpc.noaa.gov/, `soft-swpc`): índices Kp y A,
  flujo solar y avisos.
- **HamQSL** (N0NBH; https://www.hamqsl.com/solar.html, `soft-hamqsl`):
  resumen solar y *widget*.
- **PSKReporter** (https://pskreporter.info/pskmap.html, `soft-pskreporter`),
  **WSPRnet** (https://www.wsprnet.org/, `soft-wsprnet`) y **RBN**
  (https://www.reversebeacon.net/, `soft-rbn`): no son SSB, pero dicen qué
  bandas y rutas están abiertas en ese momento.
  - **[C]**: no son asistencia si solo miras la propagación sin buscar
    estaciones concretas. **POR VERIFICAR** con las bases.
  - En duda, úsalos solo antes del concurso.
- El capítulo de historia solar (`data/history/`) y el de MUF
  (`data/knowledge/muf_*.csv`) tienen los datos precalculados del proyecto.

## 7. Receptores remotos (KiwiSDR y WebSDR)

- **KiwiSDR** [V1, `soft-kiwisdr-readme`]:
  - cubre de 10 kHz a 30 MHz, y hasta cuatro oyentes sintonizan cada uno su
    frecuencia;
  - la lista pública es http://rx.kiwisdr.com (`know-kiwisdr-list`) y el
    mapa http://map.kiwisdr.com (`soft-kiwisdr-map`);
  - el repositorio Beagle_SDR_GPS está archivado (última versión v1.711) y
    continúa en uno nuevo llamado "KiwiSDR".
- **WebSDR.org** (directorio de servidores WebSDR, `soft-websdr-org`) y
  **rx.linkfanel.net** (agregador de KiwiSDR y WebSDR, `soft-linkfanel`):
  **POR VERIFICAR**. rx.linkfanel.net ni siquiera resolvía desde el entorno.
- **WebSDR de la Universidad de Twente** (Enschede, Países Bajos):
  http://websdr.ewi.utwente.nl:8901/ (`know-websdr-twente`).
  - Cubre de forma continua más o menos de 0 a 29 MHz y admite muchos oyentes
    a la vez.
  - **POR VERIFICAR**: la URL, los límites exactos de banda y la antena
    (conocimiento previo; el host no era accesible).
  - Está a unos 1 541 km de Madrid por círculo máximo [C].
- **Receptores concretos cerca de Madrid y lejos**: **ninguno se pudo
  verificar hoy** (sin búsquedas y con los directorios bloqueados).
  `receivers.csv` lista solo los directorios, Twente y huecos por región con
  criterios de elección. Rellénalos con el mapa de KiwiSDR.
- **Criterios de elección [C]**:
  - antena exterior descrita en la ficha;
  - SNR alto en la lista;
  - plazas libres (máx. 4);
  - poco ruido local en 40 y 20 m;
  - un receptor en el destino (NA, JA, VK) para oír cómo llega Europa.
- **Regla importante** (capítulo de bases, `rules-cqww-2026`): "Remote
  receivers outside of the station location are not permitted".
  - Con equipo propio no puedes recibir por un KiwiSDR durante el concurso.
  - Sirve antes, para comprobar la propagación, o este año solo como escucha.
- **RTL-SDR Blog V4**:
  - Lo soporta la librería osmocom `rtl-sdr` desde la 2.0.0
    (`equip-osmocom-changelog`), incluido el conmutador del conversor
    ascendente. La 2.0.3 salió el 12-ago-2026 y añade "V4L" [V1].
  - Lo soporta también la versión de RTL-SDR Blog (`equip-rtlsdrblog-readme`)
    [V1].
  - Los paquetes de distribuciones antiguas (librtlsdr 0.6) **no** reconocen
    el V4 [C, por la fecha del changelog].
  - En el Mac, además de SDR++, existe **gqrx 2.17.7** [V3, `soft-brew-gqrx`]:
    - binario arm64 en macOS Sonoma o posterior;
    - en Ventura, binario x86_64 que necesita Rosetta.
    - **POR VERIFICAR** que reconozca el V4.
  - Más detalles en el capítulo de equipo.

## 8. Herramientas de cqww.com

- **Subida del log**: https://cqww.com/logcheck/ ("CQ WW - Cabrillo Log
  Upload"), confirmada por el capítulo de bases (`rules-cqww-logcheck`).
  - Not1MM apunta a la misma página [V1].
  - Desde `logs.htm`: "Logs in Cabrillo format can be uploaded, checked and
    submitted using the Log Check page" (`rules-cqww-logs`). La comprobación
    del Cabrillo va integrada en la subida.
  - Instrucciones de cabecera: https://cqww.com/cabrillo.htm
    (`rules-cqww-cabrillo`).
  - Plazo: 48 h, hasta las 2359 UTC del 27-oct-2026 en SSB (`rules-cqww-2026`).
  - El log se acepta cuando recibes por correo un número de seguimiento.
- **Cabrillo desde el registrador** [V1 para Not1MM; C para el resto]:
  - `CATEGORY-OPERATOR: SINGLE-OP`, `CATEGORY-ASSISTED: NON-ASSISTED`,
    `CATEGORY-BAND: ALL`, `CATEGORY-POWER: LOW`, `CATEGORY-MODE: SSB`,
    `CATEGORY-STATION: FIXED`, `CATEGORY-TRANSMITTER: ONE`,
    `CATEGORY-OVERLAY: ROOKIE` y `LOCATION: DX`. Es lo mismo que la
    plantilla del capítulo de bases.
  - Comprueba la cabecera antes de subir.
  - Ver la plantilla del capítulo de bases:
    `data/rules/cabrillo_template.log`.
- **Validador aparte o "log checker" offline**: **POR VERIFICAR**. No se
  encontró ninguno más allá de la página de subida.
- **Informes UBN** (Unique, Bust, NIL): **POR VERIFICAR**. Tampoco los halló
  el capítulo de bases.

## 9. Encaje en el homelab (Raspberry Pi 5, Proxmox y Tailscale)

### 9.1 Qué correr y dónde [V1 + C]

| Servicio | Dónde | Dato verificado | Comentario [C] |
|---|---|---|---|
| **OpenWebRX+** con el RTL-SDR V4 | Pi 5 (Debian/Ubuntu, imagen para Raspberry Pi o Docker) | 1.2.127, del **2026-10-19**; licencia AGPL-3.0; interfaz web multiusuario (puerto 8073 según el capítulo de equipo) [V1, `equip-owrx-changelog`, `equip-owrx-readme`, `equip-owrx-core`] | Lo mejor para escuchar desde el Mac o el móvil por Tailscale: viaja audio comprimido y cascada, no I/Q. Necesita una librtlsdr con soporte del V4 |
| **SDR++ en modo servidor** | Pi 5 (servidor) y Mac (cliente "SDR++ Server") | `sdrpp -s` (`--server`), dirección por defecto 0.0.0.0 y puerto **5259**; cadena de versión 1.3.0 en master [V1, `equip-sdrpp-args`, `soft-sdrpp-version`] | Cómodo dentro de la LAN; por Tailscale hay que mirar el ancho de banda |
| **rtl_tcp** | Pi 5 | Viene en el paquete rtl-sdr [V1] | Envía I/Q de 8 bits sin comprimir: **38,4 Mbit/s a 2,4 MS/s** (16,4 Mbit/s a 1,024 MS/s) [C]. Solo para la LAN |
| **wfview en modo servidor** | Pi 5 o mini-PC con la radio por USB | Componentes de servidor en el código; aviso de CPU alta en la Pi [V1] | El IC-7300MK2 (LAN) y el IC-705 (Wi-Fi) no necesitan servidor intermedio; el FT-710 sí, por USB |
| **rigctld** (Hamlib 4.7.2) | Pi 5 o Mac | Puerto 4532; solo CAT [V1] | Da CAT remoto por Tailscale; el audio va aparte (el streaming de audio de Hamlib 5.x es experimental y no está publicado) |
| **Cliente de cluster** | Pi o Mac | — | Solo para quien opere ASSISTED; para ti, como práctica fuera del concurso |
| **Not1MM en la Pi** | Pi 5 | Linux es el objetivo principal; las ruedas de PyQt6 para aarch64 piden glibc 2.39 o más [V1] | **POR VERIFICAR** la versión de glibc de tu Raspberry Pi OS (`ldd --version`). Si es antigua, usa paquetes de la distribución o Flatpak |
| **TLF** | Pi 5 | Registrador de concursos en consola [V1] | Alternativa ligera |
| **VM Windows con N1MM** | Proxmox | — | Pasar la radio por USB (CAT y códec) a la VM; el operador entra por RDP. El audio de RX y TX por RDP añade latencia y la redirección de micrófono es poco fiable en SSB. **POR VERIFICAR** la sintaxis de paso USB de tu versión de Proxmox VE |
| **Tailscale** | Mac, Pi y Proxmox | Red privada sobre WireGuard; el demonio corre en Linux, Windows y macOS [V1, `equip-tailscale-readme`]. App de macOS 1.104.1, que pide macOS Ventura o posterior [V3, `soft-brew-tailscale`] | Acceso seguro sin abrir puertos; usa los nombres MagicDNS (**POR VERIFICAR** en tu tailnet) |

### 9.2 Avisos

- **Avisos [C]**:
  - Para operar SSB en serio, ten la radio y los auriculares en la misma sala
    que el registrador, o usa la cadena nativa de la radio (LAN del
    IC-7300MK2 con wfview o RS-BA1).
  - Por RDP, el audio no está pensado para *pile-ups*.
  - Sincroniza el reloj de todos los equipos por NTP: CQ WW cruza logs con
    ±15 minutos (`rules-cqww-logging-time`).
  - El cambio de hora en España cae dentro del concurso (`data/calc/horarios.json`).
    Registra siempre en UTC.

## 10. Resumen de POR VERIFICAR

1. SkookumLogger:
   - "CQ WW SSB" en el selector de la 6.0;
   - soporte del IC-7300MK2;
   - reproducción de WAV propios;
   - cluster;
   - arquitectura de la 6.0;
   - macOS mínimo para Personal Voice.
2. N1MM:
   - funcionamiento en Windows 11 Arm, en Parallels o VMware, con drivers
     USB-serie Arm64;
   - redacción oficial de las versiones de Windows admitidas;
   - fichero CTY (`wl_cty.dat`).
3. Not1MM: guía de instalación en macOS; glibc en Raspberry Pi OS.
4. CTY: si hay versión posterior a CTY-3631 (15-sep-2026) el 23-oct-2026.
   SCP: versión y cadencia en supercheckpartial.com.
5. wfview: fecha de la 2.22, arquitectura de los binarios de macOS y
   configuración del servidor.
6. Chips USB y drivers en macOS del IC-7300MK2 y el FT-710; nombres de menú de
   la fuente de modulación USB; duración de las memorias de voz del
   IC-7300MK2.
7. RS-BA1 V2 y SCU-LAN10: versiones y precios; sin cliente conocido para
   macOS.
8. Todas las URL de §5 y §6.2 (DX Summit, DXWatch, VE7CC, HamAlert, RBN,
   PSKReporter, WSPRnet, SWPC, HamQSL, VOACAP Online y Proppy); HamCAP; DR2W.
9. Receptores: WebSDR.org, rx.linkfanel.net, Twente (URL, bandas y antena) y
   **todos** los receptores concretos de cada región.
10. cqww.com: validador offline e informes UBN.
11. Proxmox VE: versión actual y sintaxis de paso USB. Boot Camp con Windows 10
    en Mac Intel.
