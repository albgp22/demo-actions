# Verificación de equipo, software y receptores (datos «POR VERIFICAR»)

Fecha de consulta: **20-oct-2026**. Encargo: comprobar o corregir los datos marcados `#pv` en los
capítulos 06 (escucha), 09 (equipo) y 10 (herramientas), y los «POR VERIFICAR» correspondientes de
`data/equipment/facts.md` y `data/software/facts.md`. No se ha tocado ningún fichero existente.

Ficheros de este directorio:

- `verificacion.csv`: 24 afirmaciones de la guía con su estado (6 confirmadas, 6 corregidas y 12 sin confirmar).
- `precios.csv`: 47 filas de precios de accesorios (38 con tienda y precio claros y 9 sin confirmar o no encontrados).
- `receptores.csv`: 38 filas (4 directorios, 33 receptores KiwiSDR o WebSDR y una fila «ninguno encontrado» para el Caribe).
- `refs.yml`: 96 referencias Hayagriva con prefijo `vere-`. Se ha comprobado que Typst las lee.

## Método y límites

- **39 búsquedas** con WebSearch (el máximo era 40 y el cupo es compartido). WebFetch y curl no llegan a
  ninguno de los sitios útiles (ENOTFOUND o 403: icomeurope.com, yaesu.com, kiwisdr.com, websdr.org,
  country-files.com, voacap.com, tiendas…). Solo responde GitHub, y su API de búsqueda está restringida en esta
  sesión. **Ninguna página se ha abierto**: todo sale de los resúmenes del buscador.
- **Criterio de estado.**
  - *confirmado*: el dato aparece en el resumen de un resultado cuya URL es la fuente primaria (fabricante,
    desarrollador, sitio oficial o tienda con el precio a la vista).
  - *corregido*: una fuente primaria contradice o precisa lo que dice la guía o sus ficheros de datos.
  - *sin_confirmar*: solo hay foros, terceros o memoria, o no hay nada.
  - En las afirmaciones mixtas manda la parte no confirmada, y el detalle va en `dato_verificado`.
- **Citas.** Son las que devuelve el buscador. Cuando el texto es del resumen y no de la página, va marcado
  `[resumen]`.
- **Precios.** `fecha_precio` es el día en que se vieron en el buscador (20-oct-2026). No se sabe cuándo se
  actualizó cada ficha: el propio buscador avisa de que algunas tienen meses. Las tiendas españolas incluyen el
  21 % de IVA; en WiMo el IVA es el alemán (19 %) y el envío va aparte.
- **Aviso sobre WiMo.** En dos resúmenes el buscador presentó el precio neto como si fueran gastos de envío.
  Por ejemplo, el Heil FS-3 sale a «39,90 € con IVA, más 33,53 € de envío», pero 33,53 = 39,90 / 1,19 es el
  precio sin IVA. En `precios.csv` está corregido.

## Resumen

| Asunto | Estado | Dato verificado |
|---|---|---|
| Duración de cada memoria de voz T1–T8 del IC-7300MK2 | sin_confirmar | Confirmados 8 canales, en WAV en la SD y por CI-V 01–08; la duración no aparece |
| Chip/driver USB del IC-7300MK2 en macOS | sin_confirmar | Chip no hallado. Confirmado: el driver USB de Icom que incluye el MK2 es solo para Windows 10/11, **sin Windows on ARM**; no hay versión para Mac |
| RS-BA1 V2 en macOS | sin_confirmar | Todas las fuentes citan solo Windows; ninguna menciona macOS |
| Chip USB del FT-710 | confirmado | Silicon Labs CP210x (dos puertos COM: Enhanced y Standard) |
| Driver y audio USB del FT-710 en macOS | sin_confirmar | Solo indicios de foros con otros Yaesu |
| SkookumLogger 6.0: CQ WW SSB e IC-7300MK2 | sin_confirmar | No aparecen de forma explícita |
| N1MM Logger+ en Windows 11 para Arm | sin_confirmar | Solo foro: funciona «con batalla»; los drivers serie son el problema; sin soporte oficial |
| Drivers USB de las radios en Windows on ARM | **corregido** | El driver de Icom excluye Windows on ARM |
| Último CTY | sin_confirmar | No se halla nada posterior a CTY-3631 (15-sep); lo último indexado es CTY-3630 (06-sep) |
| websdr.org | confirmado | Sitio oficial del proyecto WebSDR |
| WebSDR de Twente | confirmado | http://websdr.ewi.utwente.nl:8901/ (más versión móvil) |
| VOACAP Online | confirmado | En voacap.com (manual oficial); la ruta `/hf/` solo la citan terceros |
| Proppy | **corregido** | RSGB: rsgb.org/proppy (no soundbytes.asia) |
| HamCAP solo para Windows | confirmado | Guía de HamCAP en voacap.com |
| KiwiSDR concretos | **corregido** | Hay receptores en los listados públicos (`receptores.csv`); ninguno en Madrid ni en el Caribe |
| Precios de accesorios | **corregido** | Ya hay precios con tienda y URL (`precios.csv`) |
| Surecom SW-102 para HF | **corregido** | Es de VHF/UHF (125–525 MHz) |
| Carga ficticia «de 100 W» | **corregido** | Las encontradas solo aguantan 100 W de forma intermitente |

## 1. Icom IC-7300MK2 y Yaesu FT-710

### 1.1 Memorias de voz del IC-7300MK2 (sin confirmar)

- **Confirmado** en los manuales:
  - Hay 8 memorias, T1–T8: «"T1" ~ "T8" is displayed while using the Voice TX» (manual básico, `vere-icom-7300mk2-basic`).
  - Se guardan en la SD como WAV: «The recorded voice audio data for the Voice TX function in the "wav" format» (manual avanzado, carpeta VoiceTx, `vere-icom-7300mk2-advanced`).
  - Se disparan por CI-V: «01 ~ 08 Starts a Voice TX memory transmission. (01=T1 ~ 08=T8)» (`vere-icom-7300mk2-civ`).
- **No confirmada** la duración máxima de cada memoria. Se hicieron 3 búsquedas (una en japonés, en icom.co.jp)
  y ninguna la da. Hay que dejar el `#pv`; el 1,5 min es el dato del IC-7300.

### 1.2 USB del IC-7300MK2 en macOS (sin confirmar, con un dato nuevo)

- **Confirmado** (`vere-icom-usbdriver`): la página «USB Driver Download» de Icom America ofrece un driver Icom
  (v1.70, actualizado el 13-nov-2025) que incluye el IC-7300MK2, para «OS Windows® 10, and Windows® 11 (Except
  for Windows on ARM.)». No hay versión para macOS.
- **No confirmado**: qué chip lleva y si macOS lo reconoce sin driver. El IC-7300 original aparece en un Mac con
  Sequoia como puerto Silicon Labs, `/dev/tty.usbserial-…`, según un foro que el resumen no identifica. Del MK2
  no hay ningún dato.
- **Comprobación práctica**: `ls /dev/cu.*` antes y después de enchufar la radio.

### 1.3 RS-BA1 V2 (sin confirmar)

- Ninguna fuente menciona macOS. WiMo lista Windows 7, 8 y 10 («Please note the omission of support for older
  OSs like Windows XP and WIndows Vista»); otra web poco fiable da Windows 11/10/8.1.
- La página de Icom America no da la lista de sistemas en el resumen y advierte que los requisitos pueden
  variar (`vere-icom-rsba1v2`). El resumen de su descarga, la v2.60, no menciona el MK2.
- En el Mac, SDR-Control declara soporte del «7300 MK2» (`vere-sdrcontrol-appstore`). wfview ya consta en la
  guía.

### 1.4 Yaesu FT-710

- **Chip USB: confirmado.** El manual de Yaesu «Virtual COM Port Driver Installation Manual» (rev. 2202-D,
  `vere-yaesu-vcp-manual`) indica para el FT-710 el «Silicon Labs CP210x Universal Windows Driver»
  (Windows 10/11).
  - Cita: «The FT-710 contains two virtual COM ports, an Enhanced COM Port and a Standard COM Port». El
    Enhanced sirve para el CAT y el Standard para TX y modos digitales.
  - El número exacto de pieza no aparece.
  - La página del FT-710 ofrece el «FT-710 USB Driver Virtual COM Port Driver (Windows 11/10)».
- **macOS y audio: sin confirmar.** Yaesu solo documenta Windows, y Silicon Labs publica un driver VCP para Mac
  (`vere-silabs-vcp`). Indicios de foros:
  - FTDX-3000 en OS X: aparecen «CP2105 Dual USB to UART Bridge» y «USB Audio CODEC», y hubo que instalar a
    mano el driver CP210x (`vere-micropipes-ftdx3000`).
  - FTDX10: «the sound card in the FTDX10 is supported natively by MacOS 11.6.2 (Big Sur) without the need for
    the Silicon Labs driver» (foro; el resumen no da la URL exacta).
  - FT-891 en un Mac M1 con Sequoia: hubo que instalar el CP210x y autorizar su extensión del sistema
    (`vere-digirig-ft891-mac`).
  - FT-710 en Macs M1: el CAT funciona, pero hay errores de audio intermitentes en WSJT-X (`vere-reddit-wsjtx`).

## 2. Loggers

### 2.1 SkookumLogger (sin confirmar)

- La web de K1GQ agrupa los concursos en «CQ Contests», pero el resumen no lista cuáles son
  (`vere-k1gq-skookum`).
- Las notas recientes citan un nuevo «CQ WW CW default log» y otras antiguas, el CQ WW RTTY. Ningún resultado
  nombra el «CQ WW SSB».
- La búsqueda «SkookumLogger IC-7300MK2» no da ninguna coincidencia.
  - La v5.1 trajo «new code for all supported ICOM radios, dropping 746Pro, 756, 9100» (`vere-mhr-skookum-51`).
  - La v5.3 añadió el IC-705 y el IC-7850, por serie o por LAN UDP (`vere-mhr-skookum-53`).
- Siguen pendientes los dos `#pv`: el CQ WW SSB en el selector y el soporte del IC-7300MK2.

### 2.2 N1MM Logger+ en Windows 11 para Arm

- **Sin confirmar.** La documentación oficial no dice nada en el resumen (`vere-n1mm-install`). En el grupo
  oficial de soporte (groups.io, 2021–2024):
  - Un usuario lo usa en Windows 11 ARM con Parallels en un M1 Max: «it was a battle to get it working and there
    are still a few rough edges» (`vere-n1mm-parallels`).
  - El escollo son los puertos serie. FTDI tiene driver ARM64; com0com y vspMgr no funcionan en ARM; la
    alternativa es el CAT por TCP (`vere-n1mm-arm64`).
  - Un moderador: «We won't do anything to prevent it, but we do not have time to support other operating
    systems».
- **Corregido** (drivers USB): el driver USB de Icom que cubre el IC-7300MK2 excluye Windows on ARM (§1.2).
  - En una VM de Windows 11 para Arm, el USB del MK2 se queda sin driver oficial. Habría que llegar a la radio
    por red, pero esa vía no se ha comprobado.
  - Del FT-710 (CP210x) no se ha comprobado si hay driver ARM64.

## 3. Ficheros CTY (sin confirmar)

- Dos búsquedas nuevas no encuentran nada posterior a CTY-3631 (15-sep-2026), que solo había hallado el agente
  anterior.
- Lo último que tiene indexado el buscador es «[CTY-Announce] CTY-3630 Country Files - 06 September 2026»
  (`vere-cty-3630-announce`, `vere-cty-3630-tlf`).
- Con una versión cada 8–9 días es probable que haya alguna más nueva, pero no se ha podido ver. Conviene
  mantener el `#pv` y la recomendación de comprobarlo el 23-oct. Se puede mirar en country-files.com o en su
  feed RSS (https://www.country-files.com/feed/, citado en un resumen), o tecleando `VERSION` en el logger.

## 4. Directorios y herramientas web

- **websdr.org (confirmado).** Es el sitio oficial del proyecto WebSDR: hay resultados de sus páginas
  «background information» y «Frequently Asked Questions» (`vere-websdr-org-background`, `vere-websdr-org-faq`).
  - Según el resumen de la FAQ, el autor ha dejado de distribuir el software de forma provisional.
  - Que la portada tenga «a long list of WebSDRs» y un mapa lo dice Essex Ham, un tercero
    (`vere-essexham-websdr`).
- **WebSDR de la Universidad de Twente (confirmado).** Hay resultados del propio servidor: «Wide-band WebSDR in
  JO32KF - Universiteit Twente» (http://websdr.ewi.utwente.nl:8901/websdr.html) y enlaces del tipo
  `http://websdr.ewi.utwente.nl:8901/?tune=6070am`.
  - Versión móvil: http://etgd-websdr.ewi.utwente.nl:8901/m.html.
  - Está en el radioclub ETGD y la pueden sintonizar varias personas a la vez («Several people can tune it at
    once» [resumen]).
  - El rango exacto de frecuencias no aparece en los resúmenes: la frase «cubre toda la HF» queda sin
    confirmar.
- **VOACAP Online (confirmado el sitio).** El «VOACAP Online User’s Manual» está en voacap.com
  (`vere-voacap-manual`).
  - El manual describe Point-to-Point, Best FREQ y Full Analysis, el camino corto y el largo, y una opción
    ITURHFProp (UIT-R P.533) además de VOACAP. Es decir, también hay P.533 en el navegador.
  - La ruta concreta https://www.voacap.com/hf/ solo la citan terceros.
  - La RSGB tiene una variante RadCom en voacap.com/radcom/ (`vere-rsgb-radcom-voacap`).
- **Proppy (corregido).** La RSGB dice: «The tool is the work of programmer and PSC member James Watson, HZ1JW,
  and can be found at rsgb.org/proppy» (`vere-rsgb-proppy`).
  - Está basado en ITURHFProp, que es el software de la UIT para la P.533 (`vere-itu-iturhfprop`).
  - La dirección soundbytes.asia/proppy de `data/software/facts.md` no aparece en ningún resultado.
  - No se ve la fecha de la noticia ni se ha comprobado que el sitio siga en línea.
- **HamCAP (confirmado).** Su guía en voacap.com lo describe como «freeware Windows front end for VOACAP»
  [resumen], que necesita VOACAP instalado aparte (`vere-voacap-hamcap`).

## 5. Receptores KiwiSDR (detalle en `receptores.csv`)

**La disponibilidad cambia a diario.** Los receptores salen de resúmenes de los listados públicos
(kiwisdr.com/php/update.php, kiwisdr.com/.public, rx-tx.info y receiverbook.de), no de las páginas abiertas. El
buscador avisa de que algunas páginas de rx-tx.info tienen unos 531 días. Hay que comprobar cada uno en
http://rx.kiwisdr.com antes de usarlo. Que esa es la lista oficial lo confirma kiwisdr.com: «List/map of
receivers: rx.kiwisdr.com».

- **Cerca de Madrid.** No hay ninguno en Madrid, Toledo, Guadalajara ni Segovia. La única entrada de Madrid es un
  WebSDR, «WEB-SDR en Madrid - Spain REM-ESP», sin URL visible. Con URL (distancias por círculo máximo, cálculo
  propio):
  - EA5RQ en Llíria (Valencia), http://ea5rq.ddns.net:8075/, a unos 278 km.
  - EA5JGN en Hondón de los Frailes (Alicante), http://ei2hh.proxy.kiwisdr.com:8073/, a unos 336 km.
  - EC2AQW en Arano (Navarra), http://21959.proxy.kiwisdr.com:8073/, a unos 344 km.
  - Sin URL: Utiel, Vitoria-Gasteiz, Cardedeu y Barcelona (EA3HRU).
  - En Portugal: Flores (Azores), http://22561.proxy.kiwisdr.com:8073/.
- **Costa este de EE. UU.**
  - Massachusetts: AG1LE en Lexington y otro en Avon.
  - Nueva Jersey: NJ2US en Cape May y K2RH en Barnegat.
  - Virginia: WF4V en Lorton, Alexandria y Roanoke.
  - Carolina del Norte: Apex y W4GUZ en Bakersville.
  - Florida: Citrus County y Crawfordville.
- **Caribe:** ninguno encontrado.
- **Sudamérica:**
  - LU4AA, del Radio Club Argentino, en el Instituto Argentino de Radioastronomía:
    http://lu4aa.proxy.kiwisdr.com:8073/.
  - CX8BIT en Montevideo: http://cx8bit.proxy.kiwisdr.com:8073/. Es un resultado de la propia página del
    receptor.
  - XQ4KTM en San Carlos (Chile).
  - PT2FHC en Brasília, sin URL.
- **Australia:** el del AREG en Kapunda (Australia Meridional), http://kiwisdr.areg.org.au:8073/. Hay más sin
  URL: VK2KTJ, Mango Hill, Blackheath, Maranup, Mount Barker, Melbourne y Ballarat.
- **Japón:** solo nombres, sin URL: JH1HZB en Inzai (Chiba), uno en Edogawa-ku (Tokio) y otros en Nagano, Osaka
  y Hokkaido. Uno de Osaka (jq3jpn.tplinkdns.com:4400) aparece citado en kiwisdr.com/info, pero sin contexto.
- **Sudáfrica:** Gqeberha y Centurion, sin URL confirmada.
- **Formato de las URL.** Según kiwisdr.com/info, «For KiwiSDR 2 the proxy service is enabled by default and can
  be used to directly access the Kiwi: 2xxxx.proxy.kiwisdr.com», donde 2xxxx es el número de serie.
- **Número de oyentes.** rx-tx.info dice que uno de los KiwiSDR japoneses admite hasta ocho oyentes, así que
  «máximo 4» puede no valer para todos. Más prudente: «normalmente 4».

## 6. Precios de accesorios (detalle en `precios.csv`)

| Partida | Mejor precio con IVA visto (tienda) | Observaciones |
|---|---|---|
| Fuente conmutada de 30 A | 68,40 € Telecom RPS-1230-SWM (Ondamania); 85,00 € en La Tienda del Radioaficionado | Se anuncia con «30 A máx.»: la corriente continua y el ruido de RF no constan. Daiwa SS-330W: 179 € (Radiomanía), no disponible. Alinco DM-330MVE 118,52 € y DM-430E (25 A continuos) 119 €, de tienda no explícita. Diamond GZV-4000 y Alinco DM-330MW: no aparecen |
| Cascos con micro de pértiga | Heil Pro Set Elite IC 216,59 € y Pro 7 IC 318,23 € (Astro Radio) | Pro 7: 329,90–340 € según la tienda. Hay versiones «IC» con cápsula electret para Icom. Yamaha CM500: solo Amazon.es a 223,22 €, con ficha contradictoria (no fiable) |
| Adaptador de cascos a Icom de 8 pines | Heil AD-1-I 29,02 € (Proyecto 4); AD-1 30,25 € (Astro Radio) | Según WiMo, los adaptadores para micros dinámicos llevan condensador de aislamiento |
| Pedal de PTT | Heil FS-3 36,30 € (Astro Radio); 39,90 € en WiMo | El FS-2 está descatalogado |
| Medidor de ROE/vatímetro de HF | Diamond SX-200 83,95 € (Ondamania; otra ficha a 78,70 €, agotada); Daiwa CN-901HP desde 205,50 € | **El Surecom SW-102 es de VHF/UHF (125–525 MHz): no sirve para HF** |
| Carga ficticia | D-Original AV-DL-200-M 66,40 € (Ondamania): 35 W continuos, 200 W de pico | La «100 W» de Passion Radio (69 € sin IVA) aguanta 20 W continuos. La única de más potencia es la Zetagi DL-61 (1 kW, 176,95 €), de tienda no explícita |
| Filtro paso bajo HF | Antennas Amplifiers LPF30-2000: 275 € en WiMo (IVA alemán), el único en stock | MFJ-704 (161 €) y Remo LPF-1 (169 €) ya no están disponibles. Comet CF-30MR y Daiwa LF-30A no aparecen |
| Tarjeta SD | SanDisk Ultra SDHC de 32 GB: 23,41 € (Fnac) y 23,99 € (PcComponentes) | microSDHC con adaptador: 16,99 € (PcComponentes) |

**Suma orientativa [cálculo].** Se toma la opción más barata con tienda clara de cada partida: RPS-1230-SWM,
Pro Set Elite IC, FS-3, SX-200 a 83,95 €, AV-DL-200-M, LPF30-2000 y SDHC de 32 GB. Salen **770,05 €**, o
**495,05 €** sin el filtro paso bajo. No incluye el adaptador de cascos (≈29–30 €), el envío, el choke, el
coaxial ni la antena, que investiga otro agente.

## 7. Sugerencias para la guía (no aplicadas)

- **Cap. 06**
  - Sustituir la nota «No se ha podido verificar … ningún KiwiSDR concreto» por 2 o 3 ejemplos de
    `receptores.csv` (Llíria, Lexington o Cape May, Montevideo, Kapunda), con el aviso de que cambian a diario.
  - Quitar el `#pv` de la URL de Twente y añadir la versión móvil.
  - Cambiar «máximo 4 oyentes» por «normalmente 4».
- **Cap. 09**
  - Mantener el `#pv` de la duración de las memorias del MK2.
  - Precisar el USB del MK2: el driver de Icom es solo para Windows (sin ARM); en macOS no hay driver
    oficial y el chip sigue sin confirmar.
  - Rellenar las partidas de accesorios del presupuesto con `precios.csv`.
  - Avisar de que el SW-102 no sirve para HF y de que una carga «de 100 W» puede serlo solo en intermitente.
  - Mencionar las versiones «IC» de Heil y el adaptador AD-1-I.
- **Cap. 10**
  - FT-710: el chip es Silicon Labs CP210x; en macOS el driver y el audio siguen sin confirmar.
  - N1MM en Windows 11 para Arm: añadir que el driver USB de Icom excluye Windows on ARM.
  - websdr.org: confirmado.
  - VOACAP Online está en voacap.com y además ofrece ITURHFProp.
  - Proppy está en rsgb.org/proppy.
  - Los `#pv` de SkookumLogger y del CTY se mantienen.

## 8. Registro de búsquedas (39 de 40)

1. IC-7300MK2: voice TX T1–T8, tiempo de grabación → sin duración.
2. Driver USB del IC-7300MK2 en macOS → driver Icom v1.70, Windows 10/11 sin ARM.
3. Requisitos de sistema del RS-BA1 V2 → solo Windows (WiMo).
4. FT-710: driver CP210x y códec de audio en Mac → foros con otros Yaesu.
5. FT-710: manual del driver de puerto COM virtual (dominios de Yaesu) → Silicon Labs CP210x, dos puertos.
6. IC-7300MK2: «voice TX» (dominios de Icom) → manuales y CI-V; sin duración.
7. SkookumLogger + IC-7300MK2 → sin coincidencias.
8. SkookumLogger: concursos y radios (k1gq.net, machamradio.com) → «CQ Contests»; CQ WW SSB no explícito.
9. N1MM en Windows on ARM con Parallels (hamdocs, groups.io) → solo foro.
10. CTY-3634/3635/3636 → nada; lo último es CTY-3630.
11. CTY-3632/3633/3634 → nada.
12. WebSDR de Twente → solo terceros.
13. Directorio websdr.org → terceros (Essex Ham, Receiverbook).
14. VOACAP Online y Proppy → ARRL y RSGB; sin voacap.com.
15. Proppy e ITURHFProp → RSGB: rsgb.org/proppy.
16. KiwiSDR en Madrid → nada.
17. Listas públicas de KiwiSDR (España, Japón, Australia, Sudáfrica, Brasil) → nombres sin URL.
18. KiwiSDR en España y Portugal → Llíria, Hondón, Arano y Azores, con URL.
19. KiwiSDR en Madrid y alrededores (IN80) → ninguno; Utiel, Vitoria, Cardedeu; un WebSDR en Madrid.
20. KiwiSDR en la costa este de EE. UU. → 12 receptores con URL.
21. KiwiSDR en el Caribe y Sudamérica → LU4AA, CX8BIT y XQ4KTM.
22. KiwiSDR en Japón, Sudáfrica y Australia → sin URL.
23. Fuentes de 30 A (tiendas españolas) → RPS-1230-SWM, Sadelta, Jetfon y Alinco.
24. SS-330W, GZV-4000 y DM-330MW → SS-330W en Radiomanía.
25. Heil Pro 7 y Pro Set Elite → Astro Radio, Radiomanía, WiMo y Proyecto 4.
26. Yamaha CM500 → solo Amazon.es (ficha dudosa).
27. Pedales Heil FS-3 y FS-2 → Astro Radio, WiMo y Proyecto 4.
28. CN-901HP, SW-102 y SX-200 → precios; el SW-102 es de VHF/UHF.
29. Carga ficticia de 100 W → Passion Radio (20 W continuos).
30. Filtros paso bajo de HF → WiMo.
31. Tarjeta SDHC de 32 GB → Fnac y PcComponentes.
32. KiwiSDR de 0–30 MHz (proxy.kiwisdr.com) → páginas genéricas.
33. «Japan/South Africa/Australia - KiwiSDR» → Kapunda (AREG), con URL.
34. IC-7300MK2: memoria de voz, en japonés (icom.co.jp) → sin dato.
35. Carga artificial de 100 W (tiendas españolas) → AV-DL-200-M, DL-50A y Zetagi.
36. Adaptadores Heil AD-1-I y CC-1-I → precios y compatibilidad.
37. IC-7300MK2 en Mac: puerto USB → nada del MK2.
38. Twente, websdr.org y VOACAP (dominios oficiales) → Twente y websdr.org confirmados.
39. VOACAP Online (voacap.com) → manual oficial y guía de HamCAP.
