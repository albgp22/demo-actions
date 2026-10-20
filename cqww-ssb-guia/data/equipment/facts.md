# Equipo de estación para el CQ WW DX SSB: datos verificados

Fecha de consulta: **2026-10-20**. Ámbito: monooperador Low Power (≤100 W), 160–10 m, piso con terraza en Madrid, ordenador Mac y homelab (Raspberry Pi 5, Proxmox, Tailscale).

## 0. Método, leyenda y limitaciones

Leyenda de verificación (aparece al final de cada dato):

- **[OFICIAL]**: dato del fabricante (página de producto, folleto o manual). En este entorno los dominios de fabricantes y tiendas están bloqueados para la descarga directa, así que estos datos salen de los extractos que devuelve el buscador sobre esas páginas oficiales.
- **[LEÍDO]**: fuente primaria descargada y leída directamente (código fuente y README en `raw.githubusercontent.com`).
- **[TERCEROS]**: revisión, foro, blog o ficha de tienda.
- **[CÁLCULO]**: cálculo propio reproducible con `scripts/equip_eficiencia.py` o `scripts/equip_build.py`.
- **POR VERIFICAR**: dato no confirmado. No debe usarse como definitivo.

Las claves `@equip-…` remiten a `data/equipment/refs.yml` (Hayagriva). Los datos tabulados están en `rigs.csv`, `budget.csv` y `eficiencia_antenas.csv`, que genera `scripts/equip_build.py` / `scripts/equip_eficiencia.py`.

> **Limitación importante.** El cupo de búsquedas web de este turno (200, compartido por todos los agentes) se agotó a mitad de la investigación. Las secciones 1 (transceptores) y 6 (RTL-SDR) están completas. La 5 (presupuesto) es parcial. Las secciones 2 (antenas comerciales), 3 (accesorios) y 4 (RFI) no se pudieron contrastar con fuentes y quedan como lista de comprobación marcada **POR VERIFICAR**. No se han inventado modelos, especificaciones ni precios.

---

## 1. Transceptores

### 1.1 Icom IC-7300MK2

**Fechas**

- Se anunció en la JARL Ham Fair 2025 (23–24 de agosto de 2025), con primeras entregas previstas para finales de 2025. [TERCEROS @equip-qrper-7300mk2]
- Icom America publicó la nota de lanzamiento en diciembre de 2025. [OFICIAL @equip-icomamerica-7300mk2-launch]
- Icom Europe anunció la salida en Europa para diciembre de 2025, con un precio objetivo de unos 1.299 € sin IVA y la advertencia de que podía cambiar (aviso del 19-12-2025 reproducido por RigReference). [TERCEROS que reproduce OFICIAL @equip-rigreference-news]
- Los 70 MHz solo vienen en la versión europea. [OFICIAL @equip-icomamerica-7300mk2-unveil]

**Qué cambia respecto al IC-7300**

- **Salida HDMI**, la primera en un HF/50 MHz de Icom. Lleva frecuencia, espectro, cascada y menús a un monitor externo, y puede sacar el audio por los altavoces del monitor. [OFICIAL @equip-icomamerica-7300mk2, @equip-icomamerica-7300mk2-unveil]
- **USB tipo C** con dos puertos COM virtuales más audio. Permite usar dos programas a la vez (por ejemplo FT8 y el de registro) con un solo cable. [OFICIAL @equip-icomamerica-7300mk2-unveil]
- **LAN integrada** para control remoto con el RS-BA1 opcional, sin PC servidor. [OFICIAL @equip-icomamerica-7300mk2-unveil] Según WiMo, el RS-BA1 Version 2 se vende aparte e incluye encendido y apagado remotos. Hace falta conexión de red y alimentación de CC permanente. [TERCEROS @equip-wimo-7300mk2]
- **Conector de antena de recepción separado (RX ANT)** y **decodificador de CW integrado**. [OFICIAL @equip-icomamerica-7300mk2-unveil; TERCEROS @equip-wimo-blog-7300mk2]
- **Receptor**: RMDR de unos 105 dB a 2 kHz de separación (valor típico) y ruido de fase de transmisión unos 12 dB mejor a 1 kHz. [OFICIAL @equip-icomamerica-7300mk2] WiMo da unos 97 dB en el IC-7300 frente a unos 105 dB en el MK2, y −139 dBc/Hz a 1 kHz. [TERCEROS @equip-wimo-blog-7300mk2] Otra comparativa habla de una mejora de solo 8 dB. Las fichas de tienda avisan de que eran cifras preliminares.
- El consumo en recepción en espera es aproximadamente un 23 % menor. [TERCEROS @equip-wimo-blog-7300mk2]
- Banda de 5 MHz en la versión europea: la mencionan el anuncio de Icom America y WiMo, pero no se ha contrastado. **POR VERIFICAR** en las especificaciones finales. No afecta al CQ WW, que no usa 60 m.

**Especificaciones clave** [OFICIAL @equip-icomamerica-7300mk2, @equip-icomuk-7300mk2-basic]

- **Potencia** en HF/50 MHz: 0,6–100 W en SSB, CW, FM y RTTY, y 0,125–25 W en AM. En 70 MHz: 0,3–50 W (AM 0,075–12,5 W).
- **Acoplador interno**: adapta de 16,7 a 150 Ω desbalanceados (ROE ≤3:1). Tarda 2–3 s de media y 15 s como máximo. El extracto indica 1,8–70 MHz de cobertura: **POR VERIFICAR** en el manual.
- **Alimentación**: 13,8 V CC ±15 %. Consume 21 A en transmisión y unos 0,7 A en recepción en espera. El manual pide una fuente de al menos 21 A y muestra fusibles de 25 A.
- **Peso**: unos 4,1 kg (el IC-7300 pesa unos 4,2 kg).
- **Memorias**: 101 (99 normales y 2 de límites de exploración).
- **Receptor**: SDR de muestreo directo de RF (la nota de prensa lo titula *"RF Direct Sampling"*), con FI de 12 kHz. [OFICIAL @equip-icomamerica-7300mk2-launch]
- **Mediciones independientes**: no se ha encontrado ninguna revisión de laboratorio de QST ni de Sherwood para el MK2. Un blog (Ham Radio Therapy, abril de 2026) publica 87 dB de margen dinámico de 3.er orden a 2 kHz para el MK2, frente a 94–97 dB del IC-7300, lo que contradice a Icom. Es un dato de un solo medidor, no contrastado. [TERCEROS @equip-hamradiotherapy-7300mk2] **POR VERIFICAR.**

**Memorias de voz** (el "voice keyer" del concurso)

- Tiene 8 memorias de voz, T1–T8. Se graban en la tarjeta SD como WAV y pueden transmitirse en repetición. [OFICIAL @equip-icomuk-7300mk2-advanced]
- Tarjetas admitidas: SD hasta 2 GB, SDHC hasta 32 GB y SDXC hasta 256 GB. [OFICIAL @equip-icomuk-7300mk2-advanced]
- **Duración por memoria**: los manuales del IC-7300 y del IC-705 indican hasta 1,5 min. [TERCEROS-manual @equip-manualslib-ic7300-voicetx, @equip-manualslib-ic705-voicetx] Para el MK2: **POR VERIFICAR** (es probable que sea igual).
- **Disparo desde el programa de concurso por CAT**: en el IC-7300 se usa el comando CI-V 0x28 (`FE FE 94 E0 28 00 0n FD`, con n = 1–8 para T1–T8 y 00 para detener). [TERCEROS @equip-pe4bas-n1mm] En el MK2 hay que sustituir 94 por la dirección CI-V del equipo (ver más abajo).

**CW** (no es necesario para SSB)

- Manipulador con memorias M1–M8 de 70 caracteres cada una, con número de serie de concurso. [TERCEROS @equip-cw599-7300mk2]
- Decodificador de CW integrado. [OFICIAL]

**CAT / CI-V y USB en macOS**

- Usa el protocolo CI-V de Icom, y la guía de referencia CI-V oficial del MK2 está publicada. [OFICIAL @equip-icomuk-7300mk2-civ]
- **Dirección CI-V por defecto**: B6h según un foro (el IC-7300 usaba 94h). Un usuario que había copiado 94h tuvo fallos de CAT hasta restaurar el valor por defecto y elegir el perfil "MK2" en su programa. [TERCEROS @equip-worldradioleague-civ] **POR VERIFICAR** en la guía oficial o en el menú SET > Connectors > CI-V.
- **Chip USB del MK2 en macOS**: no confirmado, **POR VERIFICAR**. Como referencia, el IC-7300 original usa un puente USB-UART de Silicon Labs. macOS trae un driver de Apple para esos chips (el puerto aparece como `/dev/cu.usbserial-…`), y también existe el driver VCP de Silicon Labs (v6.0.3, del 30-05-2025). Con los dos drivers instalados pueden entrar en conflicto. [TERCEROS @equip-platformio-silabs-mac, @equip-digirig-mac; OFICIAL @equip-silabs-vcp]

**Operación remota**

- El RS-BA1 V2 es, según conocimiento previo del investigador, software para Windows. No se ha confirmado en esta sesión: **POR VERIFICAR** en la ficha oficial.
- En Mac, la app SDR Control declara que admite el IC-7300 MK2 y requiere macOS 14 o superior; su precio está **POR VERIFICAR**. [TERCEROS @equip-sdrcontrol-appstore]
- wfview, de código abierto, controla los Icom modernos por USB o por red. En macOS ofrece un pseudoterminal y un servidor compatible con rigctld para otros programas. [TERCEROS @equip-machamradio-wfview] Su soporte concreto del MK2 está **POR VERIFICAR**.
- Los puertos y el protocolo de la LAN del MK2 (para llegar a ellos por Tailscale) están **POR VERIFICAR**.

**Funciones de concurso aún no confirmadas para el MK2**: split, RIT/⊿TX, registros de banda y doble escucha (el IC-7300 tiene un solo receptor). **POR VERIFICAR** en el manual avanzado.

**Precios** (vistos el 2026-10-20 en resultados de búsqueda; la antigüedad real de cada ficha puede ser mayor)

| Tienda | Precio | IVA y envío | Notas |
|---|---|---|---|
| WiMo | 1.549,00 € | IVA alemán del 19 % incluido (neto 1.301,68 €); envío aparte | Verificado también por el usuario. "En stock, envío en 1–2 días". [@equip-wimo-7300mk2] |
| Radiomanía | 1.549,90 € | IVA y entrega incluidos | [@equip-radiomania-7300mk2] |
| La Tienda del Radioaficionado | 1.568,00 € | Impuestos incluidos | [@equip-tutienda-7300mk2] |
| Ondamania | 1.569,00 € (1.574,95 € con funda) | IVA incluido | Garantía de 3 años. [@equip-ondamania-7300mk2] |
| Astro Radio | 1.571,79 € | IVA del 21 % incluido; envío gratis en la península | −2 % por transferencia (≈1.540,35 €). [@equip-astroradio-7300mk2] |
| Proyecto 4 | 1.571,79 € | IVA incluido | En reserva. [@equip-proyecto4-7300mk2] |

- **POR VERIFICAR**: WiMo muestra el precio con IVA alemán. Si al enviar a España aplica el 21 %, el total serían unos 1.575,03 € más envío. [CÁLCULO 1.301,68 × 1,21] Su web dice que para la UE se aplican "precios brutos", pero no aclara qué tipo de IVA.
- Una ficha de WiMo en inglés lleva en el título "with free LC-7300 and RS-BA1". La promoción no está confirmada: **POR VERIFICAR**.

**Para un piso en Madrid**

- A favor:
  - 100 W con acoplador interno.
  - Un solo cable USB-C para CAT y audio.
  - LAN para operar desde otra habitación o desde fuera de casa (encaja con el homelab).
  - HDMI para una pantalla grande durante 48 horas de concurso.
  - RX ANT para un receptor auxiliar.
- En contra:
  - Es el más caro de los tres.
  - El acoplador solo corrige hasta 3:1, así que no sirve para un hilo largo sin transformador.
  - El software oficial de remoto (RS-BA1) sería solo para Windows (**POR VERIFICAR**).

### 1.2 Yaesu FT-710 AESS

**Especificaciones**

- **Potencia**: 5–100 W (AM 5–25 W de portadora). [OFICIAL @equip-yaesu-ft710]
- **Receptor**: recibe de 30 kHz a 75 MHz con el "mismo convertidor A/D de alta resolución y FPGA que los SDR de gama alta de Yaesu". [OFICIAL @equip-yaesu-ft710] El tipo de muestreo (directo o no) está **POR VERIFICAR**.
- **Laboratorio de la ARRL** (QST, agosto de 2023; 14 MHz, sin preamplificador, filtro de 500 Hz) [TERCEROS @equip-qst-ft710]:
  - RMDR de 120/117/116 dB a 20/5/2 kHz.
  - Margen dinámico de intermodulación de 3.er orden: 106 dB, tanto a 20 kHz como a 2 kHz.
  - Margen dinámico de bloqueo: 128 dB.
  - El resumen de la misma revista da 106 dB de RMDR a 2 kHz en 20 m y 99 dB en 80 m. Esa discrepancia con la tabla no se ha podido aclarar.
  - Yaesu declara RMDR ≥113 dB, BDR ≥127 dB e IMDR3 ≥102 dB (14 MHz, 2 kHz). [OFICIAL @equip-yaesu-ft710]
- **Acoplador interno**: 16,7–150 Ω (ROE 3:1) de 1,8 a 30 MHz y 25–100 Ω en 50 MHz. [TERCEROS @equip-qst-ft710] Guarda 100 memorias de sintonía. [TERCEROS-tienda]
- **Alimentación**: 13,8 V CC ±15 %. Consume 1,8 A en recepción sin señal, 2,2 A con señal y 21 A al transmitir con 100 W. [OFICIAL @equip-yaesuuk-ft710] QST midió unos 18,2 A típicos a 100 W, aunque el extracto de la tabla es parcialmente ilegible. [TERCEROS @equip-qst-ft710]
- **Peso y tamaño**: 4,5 kg y 239 × 80 × 247 mm. [OFICIAL @equip-yaesu-ft710, vía extracto] **POR VERIFICAR** si el peso incluye algún accesorio.
- **Estabilidad**: ±0,5 ppm. [OFICIAL @equip-yaesuuk-ft710]

**Memorias de voz y CW**

- Tiene 5 memorias de voz, de 90 s como máximo cada una, y necesita una tarjeta SD. Se graba desde [FUNC] → [MEM] → 1–5 → PTT, y también puede grabar el audio recibido. [TERCEROS-manual @equip-manualslib-ft710]
- Los mensajes de CW se manejan desde el panel o desde el teclado opcional FH-2, que va a la toma REM/ALC. Si esa toma lleva el cable de ALC de un amplificador, el FH-2 no puede conectarse. [TERCEROS-manual @equip-manualslib-ft710]

**Conectividad, CAT y remoto**

- **Puertos**: USB tipo B (CAT, audio de entrada y salida, control de transmisión), USB tipo A (SCU-LAN10 o teclado USB), salida DVI-D para monitor y ranura SD (ajustes, memorias, capturas y firmware). [OFICIAL @equip-yaesuuk-ft710]
- **CAT**: comandos ASCII de Yaesu, descritos en el *FT-710 CAT Operation Reference Manual*. [OFICIAL @equip-yaesu-ft710-cat]
- **Driver**: en otros modelos Yaesu indica instalar el driver de puerto COM virtual antes de conectar el USB (instrucción para Windows). [OFICIAL @equip-yaesu-ftdx10-cat] Esos modelos presentan un puerto *Enhanced* (CAT) y otro *Standard* (PTT y CW). Para el FT-710: **POR VERIFICAR**.
- **macOS**: en un Yaesu de la misma familia se usa el driver CP210x (VCP) y el dispositivo de audio "USB Audio CODEC" del equipo. [TERCEROS @equip-micropipes-ftdx3000-mac] Para el FT-710: **POR VERIFICAR**.
- **Remoto**: el SCU-LAN10 funciona con el FT-710 tras actualizar el firmware de los dos aparatos. Va al equipo por USB y al router por Ethernet, y usa software gratuito para Windows. [TERCEROS @equip-kpo-scu-lan10, @equip-wimo-scu-lan10]
- **Conclusión de QST**: ofrece "prestaciones que rivalizan con equipos más caros". La primera unidad tenía componentes defectuosos en la unidad SDR y, una vez reparada, cumplió especificaciones. Recomiendan mantener el tiempo de subida de CW en 4 ms. [TERCEROS @equip-qst-ft710]

**Precios** (vistos el 2026-10-20)

- **Passion Radio**: 1.249,00 €, cifra verificada por el usuario. [@equip-passion-ft710] El extracto del buscador la etiqueta como "tax excl."/"HT", así que está **POR VERIFICAR** si incluye IVA. Sin IVA, con el 21 % serían 1.511,29 € y con el 20 % francés 1.498,80 €. [CÁLCULO]
- **Tiendas españolas**:
  - Ondamania: 1.189,20 € con IVA. El anuncio citaba un reembolso de 200 € ya caducado, así que el precio está **POR VERIFICAR**. [@equip-ondamania-ft710aess]
  - Aimasstore: 1.098,68 €, entrega en 7–10 días. [@equip-aimasstore-ft710]
  - Ebainet: 1.245,00 €.
  - Radiomanía: 1.169,90 €, sin stock.
  - Astro Radio: 1.199 €, pero el resultado es antiguo y no fiable.
- **Versión Field** (sin altavoz SP-40): La Tienda del Radioaficionado 1.099,00 € con IVA [@equip-tutienda-ft710field], Ondamania 1.119,95 €, Ebainet 1.155 € y Radiomanía 1.189 €.
- El reembolso de Yaesu de 200 € (del 10-04-2026 al 30-09-2026) ya ha terminado. [TERCEROS @equip-passion-ft710]

**Para un piso en Madrid**

- A favor:
  - Es el más barato con 100 W y acoplador interno.
  - Su receptor tiene muy buenas medidas de la ARRL.
  - Memorias de voz de 90 s.
  - Salida DVI-D.
  - La versión Field es más compacta.
- En contra:
  - El remoto por LAN exige el SCU-LAN10 y software de Windows.
  - El altavoz SP-40 ocupa sitio (la versión Field no lo lleva).
  - La toma REM no admite a la vez el FH-2 y la ALC de un amplificador.

### 1.3 Icom IC-705

**Especificaciones**

- **Potencia**: 0,1–10 W con 13,8 V y 0,1–5 W con la batería de 7,4 V; en AM, 0,025–2,5 W. [OFICIAL @equip-icomamerica-705, @equip-icomeurope-705-bro]
- **Receptor**: muestreo directo de RF por debajo de 25 MHz y conversión descendente con muestreo de FI a partir de 25 MHz. Recibe de 0,030 a 199,999 MHz y de 400 a 470 MHz. [OFICIAL @equip-icomeurope-705-bro]
- **Alimentación**: 13,8 V CC ±15 % externa, o batería de 7,4 V (BP-272; en las páginas europeas, BP-307). Consume menos de 3 A al transmitir con 10 W. [OFICIAL @equip-icomamerica-705, @equip-icomeurope-705-bro]
- **Peso**: 1,1 kg con la BP-272. [OFICIAL @equip-icomamerica-705]
- **Conectividad**: micro-USB con dos puertos COM (CI-V) y audio, que además carga la batería; Wi-Fi y Bluetooth integrados; GPS y microSD. [OFICIAL @equip-icomjapan-705]
- **Sin acoplador interno**. El opcional AH-705 cubre 3,5–54 MHz con un hilo de 7 m o más, o 1,8–54 MHz con 30 m o más. Su precisión de sintonía es <2:1, admite como máximo 10 W y guarda 45 memorias. [OFICIAL @equip-icomamerica-ah705] Cuesta 339,00 € con IVA en WiMo. [TIENDA @equip-wimo-ah705]
- **Memorias de voz**: 8 (T1–T8), de hasta 1,5 min cada una, en microSD. [TERCEROS-manual @equip-manualslib-ic705-voicetx]
- **macOS**: no necesita driver en versiones recientes. [TERCEROS @equip-treerocket-705mac] El control por Wi-Fi desde un Mac con wfview está documentado por terceros. [TERCEROS @equip-m0aws-705]
- **Mediciones**: Sherwood lo ha medido según el índice N9EWO, pero la cifra está **POR VERIFICAR**. [TERCEROS @equip-n9ewo-sherwood] La dirección CI-V por defecto también está **POR VERIFICAR**.

**Precios** (vistos el 2026-10-20)

- **Passion Radio**: 1.349,00 €, con un descuento de 200 € sobre 1.549 €. Es la cifra verificada por el usuario, pero la etiqueta de IVA es ambigua: **POR VERIFICAR**. [@equip-passion-ic705]
- **WiMo**: 1.249,00 € con IVA alemán (ficha del 03-10-2026, precio de referencia 1.495 €; ese mismo valor es el mínimo de los últimos 30 días). [@equip-wimo-ic705]
- **Astro Radio**: 1.257,19 € con IVA del 21 % (ficha de unos 64 días de antigüedad; −2 % por transferencia). [@equip-astroradio-ic705]

**Para un piso en Madrid**

- A favor:
  - Ligero y con batería.
  - Wi-Fi integrado.
  - Muy buen equipo portátil y receptor.
- En contra:
  - Con 10 W y una antena de compromiso es muy difícil hacerse oír en el CQ WW SSB. Seguiría en Low Power; la categoría QRP del CQ WW (≤5 W) debe confirmarse en el capítulo de reglas.
  - No tiene acoplador interno.
  - Para llegar a 100 W necesitaría un amplificador.

### 1.4 Comparativa resumida

| | IC-7300MK2 | FT-710 AESS | IC-705 |
|---|---|---|---|
| Potencia máxima (mínima) | 100 W (0,6 W) | 100 W (5 W) | 10 W (0,1 W) |
| Receptor | SDR de muestreo directo de RF | SDR con ADC y FPGA (tipo POR VERIFICAR) | Muestreo directo por debajo de 25 MHz |
| Cifras de receptor | Icom: RMDR ≈105 dB a 2 kHz | ARRL: RMDR 116 dB y DR3 106 dB a 2 kHz | POR VERIFICAR |
| Acoplador interno | Sí, 16,7–150 Ω (≤3:1) | Sí, 16,7–150 Ω (3:1) | No (AH-705 aparte, ≤10 W) |
| Memorias de voz | 8 en SD (duración POR VERIFICAR) | 5 × 90 s en SD | 8 × 1,5 min en microSD |
| USB con CAT y audio | USB-C, 2 COM + audio | USB-B (CAT, audio y TX) | micro-USB, 2 COM + audio |
| Remoto | LAN integrada (RS-BA1 V2) | SCU-LAN10 (Windows) | Wi-Fi integrado |
| Salida de vídeo | HDMI | DVI-D | — |
| Consumo en TX | 21 A | 21 A | <3 A |
| Peso | 4,1 kg | 4,5 kg | 1,1 kg |
| Precio verificado por el usuario | 1.549 € (WiMo) | 1.249 € (Passion Radio, IVA POR VERIFICAR) | 1.349 € (Passion Radio, IVA POR VERIFICAR) |
| Precio más bajo con IVA visto | 1.549 € (WiMo; Radiomanía 1.549,90 € con envío) | 1.099 € (versión Field, La Tienda del Radioaficionado) | 1.249 € (WiMo) |

**Valoración** (opinión del investigador, no un dato): para el CQ WW SSB en monooperador Low Power desde un piso conviene un equipo de 100 W con acoplador.

- **FT-710 (Field o AESS)**: la mejor relación entre precio y prestaciones, con las mejores cifras de receptor publicadas.
- **IC-7300MK2**: cuesta unos 450 € más y encaja mejor con el homelab y el Mac (LAN integrada, USB-C único, HDMI).
- **IC-705**: solo si se prioriza el uso portátil o la escucha.

---

## 2. Antenas para la terraza (PARCIAL)

### 2.1 Lo que se ha podido establecer

- **El acoplador no sustituye a la antena.** Los acopladores internos del IC-7300MK2 y del FT-710 solo adaptan 16,7–150 Ω (ROE ≤3:1). [OFICIAL] La antena tiene que presentar ya una impedancia cercana a 50 Ω en cada banda que se use: una media onda alimentada en punta (EFHW) con su transformador, un lazo resonante, o una vertical con acoplador remoto en la base. El AH-705 del IC-705 está pensado para hilo largo y admite como máximo 10 W. [OFICIAL @equip-icomamerica-ah705]
- **Expectativas realistas para antenas pequeñas.** [CÁLCULO `scripts/equip_eficiencia.py` → `eficiencia_antenas.csv`] Son fórmulas clásicas con supuestos explícitos, no mediciones:
  - Lazo pequeño: resistencia de radiación R_rad = 20π²(C/λ)⁴ y pérdidas por efecto pelicular en el tubo de cobre.
  - Vertical corta: R_rad = 395(h/λ)², con bobina de Q = 150 y una resistencia de tierra o radiales supuesta.

  | Antena (supuestos) | 160 m | 80 m | 40 m | 20 m |
  |---|---|---|---|---|
  | Lazo magnético de 1 m de diámetro, tubo de 22 mm, sin pérdidas extra | 0,17 % (−27,6 dB) | 1,9 % (−17,2 dB) | 16 % (−7,9 dB) | 68 % (−1,6 dB) |
  | El mismo lazo con 10 mΩ extra (condensador y uniones) | 0,11 % (−29,7 dB) | 1,3 % (−18,7 dB) | 13 % (−9,0 dB) | 64 % (−2,0 dB) |
  | Ancho de banda a −3 dB del lazo de 1 m | ≈2,1 kHz | ≈3,0 kHz | ≈4,9 kHz | ≈18 kHz |
  | Tensión en el condensador del lazo de 1 m con 100 W | ≈2,2 kV | ≈3,7 kV | ≈5,6 kV | ≈5,8 kV |
  | Vertical de 7 m con 15 Ω de pérdidas de tierra | 3,1 % (−15,2 dB) | 13,5 % (−8,7 dB) | 40 % (−4,0 dB) | (≈λ/4: otro modelo) |
  | Vertical de 7 m con 5 Ω (radiales elevados bien hechos) | 5,2 % (−12,8 dB) | 25 % (−6,0 dB) | 63 % (−2,0 dB) | — |

- **Qué significa en la práctica.** Una S-unidad son unos 6 dB.
  - En 160 y 80 m, un lazo de 1 m queda unas 3–5 S-unidades por debajo de una antena eficiente.
  - Su ancho de banda de 2–5 kHz en 160–40 m obliga a resintonizar cada pocos kHz cuando se buscan estaciones por la banda (búsqueda y llamada).
  - Con 100 W, el condensador soporta varios kV. Hace falta un condensador de vacío o de gran separación, y el lazo debe quedar fuera del alcance de las personas.
  - En una vertical corta, la calidad de los radiales o contraantenas manda.
- **Límites del modelo.**
  - Las fórmulas de lazo pequeño solo valen si C/λ ≲ 0,1–0,25 (columna `valido` del CSV).
  - El hormigón armado, las barandillas y los cables cercanos añaden pérdidas y desintonía que no se modelan.
  - Falta citar una fuente reputada para estas fórmulas (por ejemplo, el *ARRL Antenna Book* o el *Antenna Theory* de Balanis): **POR VERIFICAR**.

### 2.2 Pendiente de verificar (sin datos en esta sesión)

- **Modelos comerciales mencionados en el encargo**: EFHW tipo 8010 y 4010 (MyAntennas y otros), Chameleon, lazos de Ciro Mazzoni, MFJ, Diamond BB7V y verticales Hy-Gain y Comet. Para cada uno hay que comprobar bandas cubiertas, potencia admitida en SSB con el ciclo de trabajo de un concurso, precio en tiendas de la UE y disponibilidad. **POR VERIFICAR.**
- **Coaxial**: pérdida a 28 MHz (y a 1,8 MHz) del RG-213, el Aircell 7 y el Ecoflex 10, según sus hojas de datos. **POR VERIFICAR.** Las cifras de pérdida no se han calculado porque no se pudieron leer las hojas de datos.
- **Chokes de modo común con ferrita de mezcla 31**: número de vueltas, núcleo e impedancia en 1,8–30 MHz. Fuentes por consultar: K9YC y Fair-Rite. **POR VERIFICAR.**
- **Protección contra rayos y puesta a tierra en la terraza** (normativa, comunidad de propietarios): **POR VERIFICAR**. Parte de esto puede corresponder al capítulo legal.

---

## 3. Accesorios de operación (PARCIAL)

### 3.1 Requisitos que se deducen de datos verificados

- **Fuente de alimentación.** El IC-7300MK2 y el FT-710 piden 13,8 V y 21 A en transmisión. [OFICIAL] Conviene una fuente de 25–30 A continuos, que deje margen para transmitir horas de SSB con ciclo de concurso. El IC-705 consume menos de 3 A. Los modelos y precios concretos (Alinco DM-330MW, Diamond, Manson) están **POR VERIFICAR**, igual que su nivel de ruido de RF.
- **Memorias de voz.** Los tres equipos llevan grabador de voz integrado, así que no hace falta un "voice keyer" externo: 8 memorias de unos 1,5 min en Icom (duración del MK2 POR VERIFICAR) y 5 de 90 s en Yaesu. [OFICIAL/TERCEROS-manual] Basta con comprar una tarjeta SD (o microSD para el IC-705).
- **Teclados de memorias.**
  - FT-710: teclado FH-2 en la toma REM. [TERCEROS-manual]
  - Icom: el buscador mostró en WiMo un "Memory keyboard for IC-705" y un "teclado de memorias para Icom de 8 teclas" (Chelegance). Su existencia solo consta por el título del resultado.
  - Precios y compatibilidad con el IC-7300MK2: **POR VERIFICAR**.

### 3.2 Pendiente de verificar

- **Auriculares con micrófono de pértiga** para SSB de concurso (los citados en el encargo: Heil Pro 7 o Pro Set Elite, Yamaha CM500, opciones de Sennheiser o Beyerdynamic), con precio. También el adaptador necesario: hay que confirmar el tipo de conector de micrófono del IC-7300MK2 y del FT-710 y si el micrófono electret necesita polarización. **POR VERIFICAR.**
- **Pedal de PTT** (Heil FS-2/FS-3 u otros) y la toma del equipo donde se conecta (PTT, ACC o jack del micrófono). **POR VERIFICAR.**
- **Medidor de ROE/vatímetro, carga ficticia de 100 W y filtro paso bajo**: modelos y precios. **POR VERIFICAR.** Los tres equipos muestran la ROE en pantalla según la práctica habitual, pero hay que confirmarlo en cada manual.

---

## 4. RFI y vecinos (PENDIENTE DE FUENTES)

Lo que sigue son prácticas habituales que deben contrastarse con fuentes reputadas antes de publicarlas. Fuentes candidatas, cuyas URL no se han verificado en esta sesión:

- ARRL, *Radio Frequency Interference (RFI)*: `https://www.arrl.org/radio-frequency-interference-rfi`
- RSGB EMC: `https://rsgb.org/main/technical/emc/`
- K9YC, *A Ham's Guide to RFI, Ferrites, Baluns, and Audio Interfacing*: `http://k9yc.com/RFI-Ham.pdf`

Medidas habituales (todas **POR VERIFICAR** con esas fuentes):

1. Colocar un choke de modo común en el punto de alimentación y otro a la entrada del cuarto. En HF se suele usar ferrita de mezcla 31.
2. Poner la antena lo más lejos posible del cableado de la vivienda y de las viviendas vecinas, y no tender el coaxial en paralelo a los cables de red ni de TV.
3. Poner ferritas en los cables de red, USB y audio del cuarto, y referir todo el equipo a un mismo punto de masa.
4. Instalar un filtro paso bajo a la salida del transceptor y filtros de red donde haga falta.
5. Probar con poca potencia y con un vecino colaborador antes del concurso, llevando un registro de las pruebas. Los equipos permiten bajar a 0,6 W (IC-7300MK2) o 5 W (FT-710). [OFICIAL]
6. Avisar a los vecinos antes del fin de semana del concurso y ofrecer ayuda o filtros si aparece algún problema.

Específico de cada tipo de antena:

- **EFHW**: el exterior de la malla del coaxial suele hacer de contraantena. Las corrientes de modo común pueden llevar "RF en el cuarto" (micrófono, USB, audio del Mac). Las soluciones típicas son un choke y una contraantena corta, según las instrucciones del fabricante de la antena. **POR VERIFICAR.**
- **Lazo magnético**: tiene varios kV en el condensador con 100 W [CÁLCULO] y un campo cercano intenso. Debe quedar fuera del alcance de las personas y lejos de los balcones vecinos. La normativa española de exposición a RF está **POR VERIFICAR** (capítulo legal).

---

## 5. Presupuesto (PARCIAL)

`budget.csv` incluye una sola opción por categoría y nivel, para que se pueda sumar. Las alternativas están en las secciones 1 y 3.

| Nivel | Subtotal con precio verificado | Qué incluye | Partidas sin precio (POR VERIFICAR) |
|---|---|---|---|
| Mínima | **1.099,00 €** con IVA | Yaesu FT-710 Field (La Tienda del Radioaficionado) | 7: fuente de 25 A o más, EFHW, coaxial RG-213, choke, tarjeta SD, micrófono (confirmar si viene incluido), RTL-SDR V4 y antena de hilo |
| Recomendada | **1.549,00 €** con IVA alemán | Icom IC-7300MK2 (WiMo, envío aparte) | 11: fuente de 30 A, EFHW y vertical corta o acoplador remoto, coaxial de baja pérdida, 2 chokes, auriculares con micrófono y adaptador, pedal de PTT, medidor de ROE, carga ficticia, filtro paso bajo, tarjeta SD, RTL-SDR V4 |

- RS-BA1 V2 (opcional): 121,00 € con IVA en una tienda española que el resultado no identifica. **POR VERIFICAR**, por eso no se suma.
- **Plazos**: WiMo indicaba "en stock, envío en 1–2 días" para el IC-7300MK2 y el IC-705; Aimasstore, 7–10 días para el FT-710. [TERCEROS-tienda]
- **IVA**: los precios españoles incluyen el 21 %. Los de WiMo incluyen el 19 % alemán (ver la nota de la sección 1.1). Los de Passion Radio aparecen como "HT" en el extracto (**POR VERIFICAR**).

---

## 6. Escucha de HF con el RTL-SDR Blog V4

### 6.1 Cómo recibe HF el V4 [LEÍDO]

- **Conversor ascendente automático.** Si se sintoniza por debajo de 28,8 MHz, el driver suma 28,8 MHz a la frecuencia ("upconvert"). No hay que configurar ningún desplazamiento en el programa. [@equip-osmocom-tuner, @equip-rtlsdrblog-readme]
- **Entradas conmutadas por banda.** El driver elige la entrada del sintonizador según la frecuencia: HF por debajo de 28,8 MHz, VHF hasta 250 MHz y UHF por encima. En los lotes nuevos también conmuta el conversor por GPIO, y en HF puentea el filtro de seguimiento para reducir pérdidas. [@equip-osmocom-tuner]
- **Detalle útil en 10 m.** El cambio de entrada a 28,8 MHz cae dentro de la banda de 10 m. La parte SSB habitual, por debajo de 28,8 MHz, va por la entrada de HF.
- **Filtros de rechazo (notch) integrados.** Están activos salvo cuando se sintoniza dentro de su banda: ≤2,2 MHz (onda media), 85–112 MHz (FM) y 172–242 MHz (DAB). [@equip-osmocom-tuner] Desde 80 m hacia arriba el filtro de onda media está activo. En 160 m (1,8–2,0 MHz) está desactivado, así que las emisoras potentes de onda media pueden saturar el receptor más fácilmente.
- **Muestreo directo desactivado.** El V4 no usa muestreo directo para HF. El cambio automático a muestreo directo del driver de RTL-SDR Blog solo se aplica a sintonizadores R820T, como el del V3. [@equip-rtlsdrblog-librtlsdr]
- **Cobertura declarada** por el fabricante (500 kHz – 1,766 GHz): **POR VERIFICAR**, porque `rtl-sdr.com` no es accesible desde aquí.
- **Antena.** Hace falta una antena de HF exterior (un hilo, o la antena de la estación con conmutación protegida; ver 6.5). Sobre la necesidad de preamplificador no hay dato verificado: en 160–40 m suele sobrar señal y ruido, pero está **POR VERIFICAR**.

### 6.2 Drivers [LEÍDO]

- **Versión mínima.** El driver oficial de Osmocom admite el V4 desde la **versión 2.0.0 (3-11-2023)** ("add rtl-sdr blog v4 support", "add blog v4 upconverter gpio switch"). Al iniciarse escribe `RTL-SDR Blog V4 Detected`. La versión 2.0.3 (12-08-2026) añade el V4L. [@equip-osmocom-changelog, @equip-osmocom-librtlsdr]
- **El fork de RTL-SDR Blog** (`rtl-sdr-blog`) también lo admite e incluye instrucciones de instalación [@equip-rtlsdrblog-readme]:
  - **Linux**: purgar `^librtlsdr`, compilar con CMake, instalar las reglas udev y poner en la lista negra `dvb_usb_rtl28xxu`. Hay una alternativa en paquetes `.deb` con `dpkg-buildpackage`.
  - **macOS**: `brew uninstall rtl-sdr`, instalar `cmake libusb pkgconfig`, compilar y `sudo make install`. El README usa `LIBRARY_PATH=/usr/local/lib`, que es la ruta de Homebrew en Intel. En Apple Silicon Homebrew instala en `/opt/homebrew`; la CI de SDR++ obtiene la ruta con `pkg-config --libs-only-L libusb-1.0`. [@equip-sdrpp-ci]
- **Aviso sobre el bias-T** (README): no activarlo con una antena en cortocircuito de continua sin un preamplificador intercalado. Esto incluye muchos balunes 9:1 para hilo largo, cuyo bobinado cortocircuita la continua; esta deducción es del investigador.

### 6.3 SDR++ en el Mac [LEÍDO]

- **Descarga.** El README remite a la compilación nightly de macOS. Para descargar los artefactos de GitHub hay que tener sesión iniciada. [@equip-sdrpp-readme]
- **Hay versión nativa para Apple Silicon y para Intel.** La CI publica `sdrpp_macos_arm` (en `macos-15`) y `sdrpp_macos_intel` (en `macos-15-intel`), y el mínimo de sistema es macOS 10.15 (`CMAKE_OSX_DEPLOYMENT_TARGET=10.15`). [@equip-sdrpp-ci]
- **El V4 funciona sin instalar nada más** (deducido de los scripts):
  - La CI compila `librtlsdr` desde la rama maestra de Osmocom, que admite el V4.
  - El script de empaquetado copia dentro de la app todas las bibliotecas dinámicas de las que depende.
  - Por tanto, el V4 debería funcionar con la app nightly sin Homebrew.
  - Para comprobarlo, se lanza `/Applications/SDR++.app/Contents/MacOS/sdrpp` desde Terminal y se busca `RTL-SDR Blog V4 Detected`. **POR VERIFICAR** en la práctica.
  [@equip-sdrpp-ci, @equip-sdrpp-bundle]
- **Firma.** La app solo lleva firma ad hoc (`codesign -s -`) y no está notarizada. Es de esperar que Gatekeeper la bloquee al abrirla por primera vez; se autoriza en Ajustes > Privacidad y seguridad. Esto es una deducción del comportamiento habitual de macOS. [@equip-sdrpp-bundle]
- La configuración se guarda en `~/Library/Application Support/sdrpp`. La versión en `Info.plist` es la 1.2.1. [@equip-sdrpp-args, @equip-sdrpp-bundle]

### 6.4 Ajustes de SDR++ para SSB en HF

| Ajuste | Valor | Motivo y verificación |
|---|---|---|
| Fuente | RTL-SDR | Módulo `rtl_sdr_source`. [LEÍDO @equip-sdrpp-rtlsrc] |
| Sample rate | 2,4 MHz (valor por defecto) o 1,024 MHz para gastar menos CPU | Lista del código: 0,25 a 3,2 MHz. [LEÍDO @equip-sdrpp-rtlsrc] |
| Direct Sampling | **Disabled** | El V4 usa el conversor de 28,8 MHz. Las opciones son Disabled, I branch y Q branch. [LEÍDO @equip-sdrpp-rtlsrc, @equip-osmocom-tuner] |
| Bias-T | Desactivado (salvo antena activa o preamplificador) | Ver el aviso de 6.2. [LEÍDO @equip-rtlsdrblog-readme] |
| Ganancia | Manual, con el AGC del sintonizador y el del RTL desactivados. Empezar en un valor medio y bajar si aparecen señales fantasma o intermodulación | Recomendación de práctica habitual; **POR VERIFICAR** con una fuente |
| PPM | 0, y corregir si se ve desplazamiento sobre una frecuencia conocida | Recomendación de práctica habitual |
| Modo | LSB en 160, 80 y 40 m; USB en 20, 15 y 10 m | Convención indicada en el encargo |
| Ancho de banda | 2,8 kHz (por defecto; mínimo 500 Hz). Paso de sintonía de 100 Hz | [LEÍDO @equip-sdrpp-usbdemod] |
| AGC del demodulador | Ataque 50 y caída 5 (por defecto) | [LEÍDO @equip-sdrpp-usbdemod] |

### 6.5 Antena para el SDR y seguridad

- **Nunca hay que conectar el RTL-SDR a la antena con la que se transmite sin una conmutación de recepción y transmisión protegida.** 100 W en la entrada del SDR lo destruyen (regla general de seguridad). Las opciones son una antena de recepción separada o una conmutación con secuenciador. El IC-7300MK2 tiene conectores RX ANT, pero no se ha verificado si su salida queda aislada al transmitir: **POR VERIFICAR** en el manual antes de colgar ahí el SDR.

### 6.6 V4 en la Raspberry Pi 5 y escucha desde el Mac por Tailscale

**A) Modo servidor de SDR++** [LEÍDO]

- **En la Pi**: `sdrpp --server`, que por defecto escucha en la dirección `0.0.0.0` y el puerto `5259` (opciones `-s`, `-a` y `-p`). [@equip-sdrpp-args] La CI publica paquetes `.deb` para Debian bookworm y trixie en aarch64. [@equip-sdrpp-ci] Esos paquetes enlazan con el `librtlsdr-dev` de la distribución [@equip-sdrpp-debbuild], así que hay que comprobar que la versión del sistema es la 2.0.0 o posterior (por ejemplo, `rtl_test` debe mostrar `RTL-SDR Blog V4 Detected`). Si no lo es, se compilan los `.deb` del fork con `dpkg-buildpackage`, el método del README, que sustituye el paquete sin romper dependencias. La versión de `librtlsdr` en Raspberry Pi OS está **POR VERIFICAR**.
- **En el Mac**: se elige la fuente "SDR++ Server", con el nombre o IP de Tailscale de la Pi y el puerto 5259. Se puede escoger el tipo de muestra (Int8, Int16 por defecto, o Float32) y activar la compresión. [@equip-sdrpp-serversrc] Por Tailscale conviene usar Int8, compresión y una tasa de muestreo baja.

**B) OpenWebRX+** (versión 1.2.127 del 19-10-2026) [LEÍDO]

- Es un receptor web multiusuario: se escucha desde el navegador del Mac o del móvil. [@equip-owrx-readme, @equip-owrx-changelog]
- Puerto web por defecto: **8073**. [@equip-owrx-core]
- Por defecto comprime el audio y la cascada en ADPCM, así que gasta mucho menos ancho de banda que enviar IQ en bruto. [@equip-owrx-defaults]
- **Importante para el V4**: los perfiles por defecto de 40, 80 y 160 m usan `direct_sampling=2` (rama Q), que está pensado para el V3. Con un V4 hay que poner `direct_sampling=0` en esos perfiles. [@equip-owrx-defaults]
- Se instala desde el repositorio de paquetes o con imágenes de disco precompiladas. [@equip-owrx-readme] La compatibilidad concreta de esas imágenes con la Pi 5 está **POR VERIFICAR**.

**C) rtl_tcp** (IQ en bruto)

- Envía 2 bytes por muestra, lo que da unos 32,8 Mbit/s a 2,048 MS/s, 16,4 Mbit/s a 1,024 MS/s y 4 Mbit/s a 250 kS/s. [CÁLCULO] Sirve en la red local, pero pesa demasiado por Internet.

**Tailscale**

- Crea una red privada WireGuard entre la Pi y el Mac. [LEÍDO @equip-tailscale-readme]
- No hay que abrir puertos en el router; se usa la IP o el nombre de Tailscale de la Pi. Los detalles concretos (MagicDNS, listas de control de acceso) están **POR VERIFICAR**, porque `tailscale.com` no es accesible desde aquí.
- No hay que exponer OpenWebRX+ ni el servidor de SDR++ a Internet.
- **Proxmox**: se podría pasar el dongle USB a una máquina virtual, pero es más sencillo usar directamente la Pi 5, que puede estar cerca de la antena. Es una sugerencia, no un dato verificado.

---

## 7. Lista consolidada POR VERIFICAR

1. **IC-7300MK2**:
   - Duración de cada memoria de voz T1–T8.
   - Dirección CI-V B6h.
   - Chip USB y driver en macOS.
   - Split, RIT/⊿TX y registros de banda.
   - Soporte de wfview.
   - Puertos de la LAN.
   - Banda de 5 MHz y cobertura del acoplador.
   - Cifras independientes de receptor.
   - IVA que aplica WiMo en envíos a España (≈1.575 € si es el 21 %).
   - Promoción "LC-7300 + RS-BA1 gratis".
2. **FT-710**:
   - Si el precio de Passion Radio (1.249 €) incluye IVA.
   - Tipo de muestreo.
   - Peso exacto.
   - Puertos USB en macOS.
   - Split, CLAR y registros de banda.
   - Micrófono incluido.
   - Precio actual en Ondamania después del cashback.
3. **IC-705**:
   - IVA del precio de Passion Radio (1.349 €).
   - Dirección CI-V.
   - Cifras de Sherwood.
4. **Antenas**: modelos comerciales, potencia admitida en SSB, precios y una fuente reputada para las fórmulas de eficiencia.
5. **Coaxial y chokes**: pérdidas según hoja de datos (RG-213, Aircell 7, Ecoflex 10) y diseño de chokes con ferrita de mezcla 31.
6. **Accesorios**:
   - Auriculares, adaptadores y conectores de micrófono.
   - Pedal de PTT.
   - Fuentes de 30 A.
   - Medidor de ROE, carga ficticia y filtro paso bajo.
   - Teclados de memorias Icom.
   - Precio de SDR Control.
   - Tienda y precio del RS-BA1 V2 (121 €).
7. **RFI**: contrastar las medidas de la sección 4 con ARRL, RSGB y K9YC, y revisar la normativa de exposición a RF.
8. **SDR**:
   - Cobertura de frecuencias del V4.
   - Que el V4 funcione con la app nightly de SDR++ en el Mac.
   - Versión de `librtlsdr` en Raspberry Pi OS.
   - Imágenes de OpenWebRX+ para la Pi 5.
   - Detalles de Tailscale.
   - Aislamiento del RX ANT del IC-7300MK2.
