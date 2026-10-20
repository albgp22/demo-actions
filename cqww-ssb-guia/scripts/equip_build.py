#!/usr/bin/env python3
"""Genera data/equipment/{rigs.csv,budget.csv,refs.yml} a partir de datos verificados.

Fuente unica de verdad para los datos de equipo del manual CQ WW DX SSB.
- Cada fila cita claves de refs.yml (prefijo 'equip-'); el script comprueba que existen.
- Precios: euros, tienda, fecha en que se vio el precio (2026-10-20 salvo que el
  resultado mostrara otra fecha) y si incluye IVA. Lo no confirmado queda vacio y
  marcado como POR VERIFICAR.

Uso: .venv/bin/python scripts/equip_build.py
"""

from __future__ import annotations

import csv
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "data" / "equipment"
HOY = "2026-10-20"

# ---------------------------------------------------------------------------
# Referencias (Hayagriva). 'nota' es interna: no se exporta a refs.yml.
# ---------------------------------------------------------------------------
REFS: dict[str, dict] = {
    # --- Icom IC-7300MK2 ---
    "equip-icomamerica-7300mk2": dict(
        title="IC-7300MK2 (página de producto y especificaciones)",
        author="Icom America", publisher="Icom America",
        url="https://www.icomamerica.com/lineup/products/IC-7300MK2/"),
    "equip-icomamerica-7300mk2-unveil": dict(
        title="Icom Unveils New IC-7300MK2 HF / 50 / (70) MHz Transceiver",
        author="Icom America", publisher="Icom America", date="2025-08",
        url="https://www.icomamerica.com/media_and_promotions/icom_unveils_new_IC7300mk2/"),
    "equip-icomamerica-7300mk2-launch": dict(
        title="Icom Introduces the IC-7300MK2: A New Generation of RF Direct Sampling Performance",
        author="Icom America", publisher="Icom America", date="2025-12",
        url="https://icomamerica.com/media_and_promotions/news/4555/"),
    "equip-qrper-7300mk2": dict(
        title="Icom Announces the IC-7300MK2: Improved Performance and Enhanced Connectivity",
        publisher="QRPer.com", date="2025-08",
        url="https://qrper.com/2025/08/icom-announces-the-ic-7300mk2-improved-performance-and-enhanced-connectivity/"),
    "equip-rigreference-news": dict(
        title="News and press releases (aviso de Icom Europe del 19-12-2025 sobre el IC-7300MK2)",
        publisher="RigReference",
        url="https://rigreference.com/news"),
    "equip-icomuk-7300mk2-advanced": dict(
        title="IC-7300MK2 Advanced Manual",
        author="Icom Inc.", publisher="Icom UK",
        url="https://icomuk.co.uk/files/icom/PDF/advancedManuals/IC-7300MK2_ENG_Advanced_0.pdf"),
    "equip-icomuk-7300mk2-basic": dict(
        title="IC-7300MK2 Basic Manual",
        author="Icom Inc.", publisher="Icom UK",
        url="https://icomuk.co.uk/files/icom/PDF/productManual/IC-7300MK2_ENG_Basic_0.pdf"),
    "equip-icomuk-7300mk2-civ": dict(
        title="IC-7300MK2 CI-V Reference Guide",
        author="Icom Inc.", publisher="Icom UK",
        url="https://icomuk.co.uk/files/icom/PDF/productAdditionalFile/IC-7300MK2_ENG_CI-V_0.pdf"),
    "equip-wimo-7300mk2": dict(
        title="Transceptor HF multimodo Icom IC-7300MK2 (ficha y precio)",
        publisher="WiMo Antennen und Elektronik GmbH",
        url="https://www.wimo.com/es/icom-ic-7300mk2-kw-50-70-mhz-transceiver"),
    "equip-wimo-blog-7300mk2": dict(
        title="Icom IC-7300MK2 vs IC-7300",
        publisher="WiMo (blog)",
        url="https://www.wimo.com/en/blog/post/icom-ic-7300mk2-vs-ic-7300"),
    "equip-worldradioleague-civ": dict(
        title="How to Enable CAT Control on Icom 7300MK2 (hilo de foro)",
        publisher="World Radio League Community",
        url="https://community.worldradioleague.com/t/how-to-enable-cat-control-on-icom-7300mk2/45663"),
    "equip-hamradiotherapy-7300mk2": dict(
        title="ICOM IC-7300MK2 Review: New Features Revealed",
        publisher="Ham Radio Therapy", date="2026-04",
        url="https://hamradiotherapy.com/hf-radio/icom-7300mk2-review/"),
    "equip-manualslib-ic7300-voicetx": dict(
        title="Icom IC-7300 Full Manual, p. 85: Recording a Voice TX memory",
        publisher="ManualsLib",
        url="https://www.manualslib.com/manual/1106166/Icom-Ic-7300.html?page=85"),
    "equip-pe4bas-n1mm": dict(
        title="Using IC-7300 voicekeyer in N1MM+",
        author="PE4BAS", publisher="PE4BAS Amateur Radio Weblog", date="2019-09",
        url="https://pe4bas.blogspot.com/2019/09/using-ic-7300-voicekeyer-in-n1mm.html"),
    "equip-cw599-7300mk2": dict(
        title="IC-7300MK2 CW Setup & Operating Guide",
        publisher="cw599.com",
        url="https://cw599.com/radio-guides/icom-ic-7300mk2/"),
    "equip-astroradio-7300mk2": dict(
        title="ICOM Transceptor IC-7300 MK2 (ficha y precio)",
        publisher="Astro Radio",
        url="https://www.astroradio.com/p/transceptor-ic-7300-mk2/"),
    "equip-radiomania-7300mk2": dict(
        title="Icom IC-7300 MK2 (ficha y precio)",
        publisher="Radiomanía (radiomania.net)",
        url="https://radiomania.net/epages/a460337c-7435-4ca8-a697-f50605a3ed82.sf/es_ES/?ObjectPath=%2FShops%2Fa460337c-7435-4ca8-a697-f50605a3ed82%2FProducts%2F%22IC-7300+MK2%22"),
    "equip-ondamania-7300mk2": dict(
        title="Transceptor HF 50 y 70 MHz Icom IC-7300MK2 (ficha y precio)",
        publisher="Ondamania",
        url="https://www.ondamania.com/b2c/producto/icom_ic7300_mk2/1/icom-ic-7300mk2-transceptor-hf-50-y-70-mhz-con-acoplador-automatico-pantalla-espectro"),
    "equip-proyecto4-7300mk2": dict(
        title="Emisora transceptor HF Icom IC-7300MK2 (ficha y precio)",
        publisher="Proyecto 4",
        url="https://www.proyecto4.com/emisoras-hf-y-multibanda/5018-emisora-transceptor-hf-icom-ic-7300mk2.html"),
    "equip-tutienda-7300mk2": dict(
        title="ICOM IC-7300MK2 (ficha y precio)",
        publisher="La Tienda del Radioaficionado",
        url="https://www.tutiendaderadio.com/es/home/5997-icom-ic-7300mk2.html"),
    "equip-sdrcontrol-appstore": dict(
        title="SDR Control (ficha en la App Store; soporte IC-7300 MK2, Mac con macOS 14 o superior)",
        publisher="Apple App Store",
        url="https://apps.apple.com/app/id1592313285"),
    "equip-machamradio-wfview": dict(
        title="Introducing wfview, a program developed by amateur radio enthusiasts to control modern Icom ham radios",
        publisher="Mac Ham Radio", date="2021-05-24",
        url="https://machamradio.com/blog/2021/05/24/introducing-wfview-a-program-developed-by-amateur-radio-enthusiasts-to-control-modern-icom-ham-radios/"),
    # --- Yaesu FT-710 ---
    "equip-yaesu-ft710": dict(
        title="FT-710 (página de producto y especificaciones)",
        author="Yaesu Musen", publisher="Yaesu USA",
        url="https://www.yaesu.com/product-detail.aspx?Model=FT-710&CatName=HF+Transceiver+-+Amplifier"),
    "equip-yaesuuk-ft710": dict(
        title="FT-710 AESS 100W HF/6M SDR Transceiver",
        publisher="Yaesu UK",
        url="https://www.yaesu.co.uk/ft-710/"),
    "equip-qst-ft710": dict(
        title="Product Review: Yaesu FT-710 AESS MF/HF and 6-Meter Transceiver (QST, agosto 2023)",
        author="ARRL", publisher="ARRL / Yaesu (copia alojada en yaesu.com)", date="2023-08",
        url="https://www.yaesu.com/Files/4CB83B95-1018-01AF-FAD307DB330C321A/QST%20August%202023%20Product%20Review%20Yaesu%20FT-710%20AESS%20MF_HF%20and%206-Meter%20Transceiver.pdf"),
    "equip-yaesu-ft710-cat": dict(
        title="FT-710 CAT Operation Reference Manual",
        author="Yaesu Musen", publisher="Yaesu",
        url="https://www.yaesu.com/Files/4CB893D7-1018-01AF-FA97E9E9AD48B50C/FT-710_CAT_OM_ENG_2306-C.pdf"),
    "equip-manualslib-ft710": dict(
        title="Yaesu FT-710 Operation Manual",
        publisher="ManualsLib",
        url="https://www.manualslib.com/manual/2841126/Yaesu-Ft-710.html"),
    "equip-kpo-scu-lan10": dict(
        title="Yaesu SCU-LAN10 Network Interface",
        publisher="K-PO (distribuidor europeo de Yaesu)",
        url="https://k-po.com/product/yaesu-scu-lan10-network-interface"),
    "equip-wimo-scu-lan10": dict(
        title="SCU-LAN10 Network Interface",
        publisher="WiMo",
        url="https://www.wimo.com/en/scu-lan10"),
    "equip-passion-ft710": dict(
        title="Yaesu FT-710 AESS New HF SDR 100W (ficha y precio)",
        publisher="Passion Radio",
        url="https://www.passion-radio.com/hf-transceiver/ft710-1714.html"),
    "equip-ondamania-ft710aess": dict(
        title="Yaesu FT-710 AESS emisora de HF y 50 MHz con altavoz SP-40 (ficha y precio)",
        publisher="Ondamania",
        url="https://www.ondamania.com/b2c/producto/yaesu_ft710aess/1/yaesu-ft-710-aess-emisora-sdr-de-hf-y-50-mhz-compacta-con-100-w-de-potencia"),
    "equip-tutienda-ft710field": dict(
        title="YAESU FT-710 FIELD emisora transceptor HF y 50 MHz (ficha y precio)",
        publisher="La Tienda del Radioaficionado",
        url="https://www.tutiendaderadio.com/es/home/5711-yaesu-ft-710-field-emisora-transceptor-hf-y-50-mhz.html"),
    "equip-aimasstore-ft710": dict(
        title="YAESU FT-710 emisora HF (ficha y precio)",
        publisher="Aimasstore",
        url="https://aimasstore.com/inicio/151-emisora-hf-ft-710.html"),
    "equip-micropipes-ftdx3000-mac": dict(
        title="Setting up a Yaesu FTDX-3000 with FT8 on OS X",
        publisher="micropipes.com", date="2023-07-10",
        url="https://micropipes.com/2023/07/10/setting-up-Yaesu-FTDX-3000-with-FT8-on-OS-X/"),
    "equip-silabs-vcp": dict(
        title="CP210x USB to UART Bridge VCP Drivers",
        author="Silicon Labs", publisher="Silicon Labs",
        url="https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers"),
    "equip-platformio-silabs-mac": dict(
        title="Apple Silicon M1 Chip not Connecting (hilo de foro sobre drivers SiLabs en macOS)",
        publisher="PlatformIO Community",
        url="https://community.platformio.org/t/apple-silicon-m1-chip-not-connecting/19693"),
    "equip-digirig-mac": dict(
        title="DR-891 w/FT-891 WSJT-X using a Mac M1 w/Sequoia will not work (hilo de foro)",
        publisher="Digirig Forum",
        url="https://forum.digirig.net/t/dr-891-w-ft-891-wsjt-x-using-a-mac-m1-w-sequoia-will-not-work/5764"),
    "equip-yaesu-ftdx10-cat": dict(
        title="FTDX10 CAT Operation Reference Manual (driver de puerto COM virtual)",
        author="Yaesu Musen", publisher="RigPix (copia)",
        url="https://rigpix.com/yaesu/ftdx10_cat_manual.pdf"),
    # --- Icom IC-705 ---
    "equip-icomamerica-705": dict(
        title="IC-705 (página de producto y especificaciones)",
        author="Icom America", publisher="Icom America",
        url="https://www.icomamerica.com/lineup/products/IC-705/"),
    "equip-icomeurope-705-bro": dict(
        title="IC-705 brochure (A4, ENG, 2020-07-31)",
        author="Icom Europe", publisher="Icom Europe", date="2020-07-31",
        url="https://www.icomeurope.com/wp-content/uploads/2020/08/IC-705_BRO_ENG_A4_20200731.pdf"),
    "equip-icomjapan-705": dict(
        title="IC-705 (página de producto)",
        author="Icom Inc.", publisher="Icom Inc.",
        url="https://www.icomjapan.com/lineup/products/IC-705/"),
    "equip-icomamerica-ah705": dict(
        title="AH-705 Automatic Antenna Tuner",
        author="Icom America", publisher="Icom America",
        url="https://icomamerica.com/lineup/options/AH-705"),
    "equip-wimo-ah705": dict(
        title="AH-705 Automatic Tuner for IC-705 (ficha y precio)",
        publisher="WiMo",
        url="https://www.wimo.com/en/ah-705"),
    "equip-manualslib-ic705-voicetx": dict(
        title="Icom IC-705 Advanced Manual, p. 47: Voice TX memory function",
        publisher="ManualsLib",
        url="https://www.manualslib.com/manual/1896763/Icom-Ic-705.html?page=47"),
    "equip-wimo-ic705": dict(
        title="ICOM IC-705 (ficha y precio)",
        publisher="WiMo",
        url="https://www.wimo.com/en/icom-ic-705"),
    "equip-passion-ic705": dict(
        title="ICOM IC-705 SDR QRP transceiver portable (ficha y precio)",
        publisher="Passion Radio",
        url="https://www.passion-radio.com/hf-transceiver/ic705-1109.html"),
    "equip-astroradio-ic705": dict(
        title="ICOM IC-705 Transceptor SDR portable multibanda (ficha y precio)",
        publisher="Astro Radio",
        url="https://www.astroradio.com/p/ic-705-transceptor-sdr-portable-multibanda/"),
    "equip-treerocket-705mac": dict(
        title="Icom IC-705 digi mode setup for Linux/Mac",
        publisher="treerockets blog",
        url="https://treerocket.bearblog.dev/icom-ic-705-digi-mode-setup-for-linux-mac/"),
    "equip-m0aws-705": dict(
        title="Getting FLRig and FLDigi working wirelessly to the IC-705",
        author="M0AWS", publisher="m0aws.co.uk",
        url="https://m0aws.co.uk/?cat=113"),
    # --- Comparativas de receptores ---
    "equip-n9ewo-sherwood": dict(
        title="Sherwood Engineering receiver test data (índice/archivo)",
        author="N9EWO", publisher="qsl.net/n9ewo",
        url="https://www.qsl.net/n9ewo/sherwood.html"),
    # --- RTL-SDR Blog V4 / SDR++ / OpenWebRX+ / Tailscale (fuentes primarias leídas) ---
    "equip-rtlsdrblog-readme": dict(
        title="rtl-sdr-blog: README (versión modificada RTL-SDR Blog, soporte V4)",
        author="RTL-SDR Blog", publisher="GitHub",
        url="https://raw.githubusercontent.com/rtlsdrblog/rtl-sdr-blog/master/README"),
    "equip-rtlsdrblog-librtlsdr": dict(
        title="rtl-sdr-blog: src/librtlsdr.c (muestreo directo automático solo para R820T)",
        author="RTL-SDR Blog", publisher="GitHub",
        url="https://raw.githubusercontent.com/rtlsdrblog/rtl-sdr-blog/master/src/librtlsdr.c"),
    "equip-osmocom-tuner": dict(
        title="osmocom rtl-sdr: src/tuner_r82xx.c (conversor ascendente 28,8 MHz y conmutación de entradas del V4)",
        author="Osmocom", publisher="GitHub",
        url="https://raw.githubusercontent.com/osmocom/rtl-sdr/master/src/tuner_r82xx.c"),
    "equip-osmocom-librtlsdr": dict(
        title="osmocom rtl-sdr: src/librtlsdr.c (detección 'RTL-SDR Blog V4 Detected')",
        author="Osmocom", publisher="GitHub",
        url="https://raw.githubusercontent.com/osmocom/rtl-sdr/master/src/librtlsdr.c"),
    "equip-osmocom-changelog": dict(
        title="osmocom rtl-sdr: debian/changelog (2.0.0 añade soporte RTL-SDR Blog V4)",
        author="Osmocom", publisher="GitHub",
        url="https://raw.githubusercontent.com/osmocom/rtl-sdr/master/debian/changelog"),
    "equip-sdrpp-readme": dict(
        title="SDR++, The bloat-free SDR software: readme",
        author="Alexandre Rouma", publisher="GitHub",
        url="https://raw.githubusercontent.com/AlexandreRouma/SDRPlusPlus/master/readme.md"),
    "equip-sdrpp-ci": dict(
        title="SDR++: .github/workflows/build_all.yml (compilaciones nightly macOS Intel/ARM y Debian aarch64)",
        author="Alexandre Rouma", publisher="GitHub",
        url="https://raw.githubusercontent.com/AlexandreRouma/SDRPlusPlus/master/.github/workflows/build_all.yml"),
    "equip-sdrpp-bundle": dict(
        title="SDR++: macos/bundle_utils.sh (copia de dylibs y firma ad hoc)",
        author="Alexandre Rouma", publisher="GitHub",
        url="https://raw.githubusercontent.com/AlexandreRouma/SDRPlusPlus/master/macos/bundle_utils.sh"),
    "equip-sdrpp-args": dict(
        title="SDR++: core/src/command_args.cpp (modo servidor, puerto 5259)",
        author="Alexandre Rouma", publisher="GitHub",
        url="https://raw.githubusercontent.com/AlexandreRouma/SDRPlusPlus/master/core/src/command_args.cpp"),
    "equip-sdrpp-rtlsrc": dict(
        title="SDR++: source_modules/rtl_sdr_source/src/main.cpp (tasas de muestreo, muestreo directo, ganancia)",
        author="Alexandre Rouma", publisher="GitHub",
        url="https://raw.githubusercontent.com/AlexandreRouma/SDRPlusPlus/master/source_modules/rtl_sdr_source/src/main.cpp"),
    "equip-sdrpp-usbdemod": dict(
        title="SDR++: decoder_modules/radio/src/demodulators/usb.h (ancho por defecto 2800 Hz)",
        author="Alexandre Rouma", publisher="GitHub",
        url="https://raw.githubusercontent.com/AlexandreRouma/SDRPlusPlus/master/decoder_modules/radio/src/demodulators/usb.h"),
    "equip-sdrpp-serversrc": dict(
        title="SDR++: source_modules/sdrpp_server_source/src/main.cpp (cliente del modo servidor)",
        author="Alexandre Rouma", publisher="GitHub",
        url="https://raw.githubusercontent.com/AlexandreRouma/SDRPlusPlus/master/source_modules/sdrpp_server_source/src/main.cpp"),
    "equip-sdrpp-debbuild": dict(
        title="SDR++: docker_builds/debian_bookworm/do_build.sh (enlaza con librtlsdr-dev de la distribución)",
        author="Alexandre Rouma", publisher="GitHub",
        url="https://raw.githubusercontent.com/AlexandreRouma/SDRPlusPlus/master/docker_builds/debian_bookworm/do_build.sh"),
    "equip-owrx-readme": dict(
        title="OpenWebRX+: README",
        author="Marat Fayzullin (luarvique)", publisher="GitHub",
        url="https://raw.githubusercontent.com/luarvique/openwebrx/master/README.md"),
    "equip-owrx-changelog": dict(
        title="OpenWebRX+: debian/changelog (versión 1.2.127, 19-10-2026)",
        author="Marat Fayzullin (luarvique)", publisher="GitHub", date="2026-10-19",
        url="https://raw.githubusercontent.com/luarvique/openwebrx/master/debian/changelog"),
    "equip-owrx-defaults": dict(
        title="OpenWebRX+: owrx/config/defaults.py (perfiles RTL-SDR por defecto)",
        author="Marat Fayzullin (luarvique)", publisher="GitHub",
        url="https://raw.githubusercontent.com/luarvique/openwebrx/master/owrx/config/defaults.py"),
    "equip-owrx-core": dict(
        title="OpenWebRX+: owrx/config/core.py (puerto web 8073)",
        author="Marat Fayzullin (luarvique)", publisher="GitHub",
        url="https://raw.githubusercontent.com/luarvique/openwebrx/master/owrx/config/core.py"),
    "equip-tailscale-readme": dict(
        title="Tailscale: README (Private WireGuard networks made easy)",
        author="Tailscale Inc.", publisher="GitHub",
        url="https://raw.githubusercontent.com/tailscale/tailscale/main/README.md"),
}

# ---------------------------------------------------------------------------
# Transceptores
# ---------------------------------------------------------------------------
RIG_FIELDS = [
    "modelo", "variante", "lanzamiento", "potencia_w", "potencia_max_w", "potencia_min_w",
    "receptor", "rx_datos_clave", "atu", "memorias_voz", "keyer_cw", "funciones_concurso",
    "usb_cat_audio", "usb_macos", "protocolo_cat", "remoto", "salida_video", "alimentacion",
    "consumo_tx_a", "peso_kg", "precio_eur", "iva", "tienda", "fecha_precio", "otros_precios",
    "pros_piso", "contras_piso", "fuente", "por_verificar",
]

RIGS = [
    dict(
        modelo="Icom IC-7300MK2",
        variante="Versión europea (incluye 70 MHz)",
        lanzamiento="Anunciado en la JARL Ham Fair (23-24 ago 2025); venta en Europa desde dic 2025 (precio objetivo Icom Europe ~1.299 € sin IVA)",
        potencia_w="HF/50 MHz: 0,6-100 W (SSB/CW/FM/RTTY), AM 0,125-25 W; 70 MHz: 0,3-50 W (AM 0,075-12,5 W)",
        potencia_max_w=100, potencia_min_w=0.6,
        receptor="SDR de muestreo directo de RF (receptor único); FI 12 kHz",
        rx_datos_clave="Icom (típico): RMDR ~105 dB a 2 kHz (mejora frente al IC-7300: +12 dB según WiMo/Icom, +8 dB según otra fuente); ruido de fase TX -139 dBc/Hz a 1 kHz (preliminar). Sin informe QST/Sherwood localizado; un blog (abr-2026) publica 87 dB DR3 a 2 kHz, no contrastado",
        atu="Interno: 16,7-150 ohm desbalanceado (ROE <=3:1); sintonía 2-3 s típ., 15 s máx.",
        memorias_voz="8 (T1-T8) en tarjeta SD, archivos WAV; duración máxima por memoria POR VERIFICAR (1,5 min en IC-7300 e IC-705)",
        keyer_cw="Manipulador con memorias (M1-M8, 70 caracteres según guía de terceros) y número de serie; decodificador CW integrado (nuevo)",
        funciones_concurso="Espectro y cascada (también por HDMI); 101 memorias; memorias de voz disparables por CAT (comando 0x28 en la serie IC-7300); entrada/salida RX ANT; split, RIT/dTX y registros de banda POR VERIFICAR en el manual del MK2",
        usb_cat_audio="Sí: USB-C con 2 puertos COM virtuales + audio por un solo cable",
        usb_macos="Chip USB del MK2 no confirmado (POR VERIFICAR). El IC-7300 original usa puente Silicon Labs: macOS lo reconoce con su driver integrado (/dev/cu.usbserial-*) o con el driver VCP de SiLabs",
        protocolo_cat="Icom CI-V; dirección por defecto B6h según un foro (IC-7300: 94h) - POR VERIFICAR en la guía CI-V oficial",
        remoto="LAN integrada: RS-BA1 V2 (opcional; que sea solo para Windows es conocimiento previo, POR VERIFICAR) sin PC servidor, con encendido/apagado remoto (requiere red y alimentación CC permanente). En Mac: la app SDR Control declara soporte del IC-7300 MK2 (macOS >=14); soporte de wfview POR VERIFICAR",
        salida_video="HDMI (frecuencia, espectro/cascada, menús; audio al monitor)",
        alimentacion="13,8 V CC +/-15 %; fuente de al menos 21 A (manual)",
        consumo_tx_a=21, peso_kg=4.1,
        precio_eur=1549.00, iva="incluido (IVA alemán 19 %; neto 1.301,68 €); envío aparte",
        tienda="WiMo", fecha_precio=HOY,
        otros_precios="Radiomanía 1.549,90 € (IVA y envío incl.); La Tienda del Radioaficionado 1.568,00 €; Ondamania 1.569,00 €; Astro Radio 1.571,79 € (IVA 21 %, envío gratis península; -2 % por transferencia); Proyecto 4 1.571,79 € (reserva); Moonraker EU 1.558,84 €",
        pros_piso="100 W con ATU interno; un único USB-C para CAT+audio; LAN integrada para operar desde otra habitación o en remoto; HDMI para pantalla grande; RX ANT para un receptor auxiliar",
        contras_piso="El más caro de los tres; el ATU interno solo corrige hasta 3:1 (un hilo largo sin adaptador necesita acoplador externo); el software oficial de remoto (RS-BA1) sería solo para Windows (POR VERIFICAR)",
        fuente="equip-icomamerica-7300mk2;equip-icomamerica-7300mk2-unveil;equip-icomamerica-7300mk2-launch;equip-qrper-7300mk2;equip-rigreference-news;equip-icomuk-7300mk2-advanced;equip-icomuk-7300mk2-basic;equip-wimo-7300mk2;equip-wimo-blog-7300mk2;equip-worldradioleague-civ;equip-hamradiotherapy-7300mk2;equip-cw599-7300mk2;equip-pe4bas-n1mm;equip-sdrcontrol-appstore",
        por_verificar="duración de cada memoria de voz; dirección CI-V B6h; chip USB y driver en macOS; split/RIT/dTX/registros de banda; soporte wfview; IVA que aplica WiMo a envíos a España; cifras independientes de receptor",
    ),
    dict(
        modelo="Yaesu FT-710 AESS",
        variante="AESS (incluye altavoz SP-40); existe la versión Field sin SP-40",
        lanzamiento="En el mercado al menos desde 2023 (revisión QST de agosto de 2023)",
        potencia_w="5-100 W (AM 5-25 W de portadora)",
        potencia_max_w=100, potencia_min_w=5,
        receptor="SDR con ADC de alta resolución y FPGA (según Yaesu, los de sus SDR de gama alta); RX 30 kHz-75 MHz; tipo exacto de muestreo POR VERIFICAR",
        rx_datos_clave="ARRL Lab (QST ago-2023; 14 MHz, sin preamplificador, 500 Hz): RMDR 116 dB a 2 kHz; DR3 106 dB a 2 kHz; BDR 128 dB. Yaesu declara RMDR >=113 dB, BDR >=127 dB, IMDR3 >=102 dB (14 MHz, 2 kHz)",
        atu="Interno: 16,7-150 ohm (ROE 3:1) en 1,8-30 MHz; 25-100 ohm en 50 MHz; 100 memorias de sintonía",
        memorias_voz="5 memorias, máximo 90 s cada una; requiere tarjeta SD",
        keyer_cw="Mensajes CW desde el panel o desde el teclado opcional FH-2 (toma REM/ALC, incompatible a la vez con ALC de amplificador)",
        funciones_concurso="Espectro en pantalla táctil de 4,3\"; memorias de voz y CW manejables con FH-2; split, CLAR y registros de banda POR VERIFICAR en el manual",
        usb_cat_audio="Sí: USB tipo B (CAT, audio de entrada/salida y control de TX); USB tipo A para SCU-LAN10 o teclado",
        usb_macos="En otros Yaesu el USB es un puente Silicon Labs con puertos 'Enhanced' (CAT) y 'Standard' (PTT/CW) más 'USB Audio CODEC'; en macOS aparecen como /dev/cu.usbserial-*; comprobar en el FT-710 (POR VERIFICAR)",
        protocolo_cat="Yaesu CAT (comandos ASCII; 'FT-710 CAT Operation Reference Manual')",
        remoto="SCU-LAN10 opcional (hay que actualizar el firmware de ambos); software de control remoto para Windows",
        salida_video="DVI-D para monitor externo",
        alimentacion="13,8 V CC +/-15 %; RX 1,8 A sin señal / 2,2 A con señal",
        consumo_tx_a=21, peso_kg=4.5,
        precio_eur=1249.00, iva="POR VERIFICAR (el resultado de búsqueda de Passion Radio muestra la etiqueta 'tax excl.'/'HT')",
        tienda="Passion Radio", fecha_precio=HOY,
        otros_precios="Ondamania 1.189,20 € IVA incl.; Aimasstore 1.098,68 €; Ebainet 1.245,00 €; Radiomanía 1.169,90 € (sin stock); rf-market.fr 1.249,00 € TTC; versión Field: La Tienda del Radioaficionado 1.099,00 € IVA incl., Ondamania 1.119,95 €; el reembolso Yaesu de 200 € terminó el 30-09-2026",
        pros_piso="El más barato con 100 W y ATU interno; receptor muy bien medido por la ARRL; memorias de voz largas (90 s); salida DVI-D; versión Field más compacta",
        contras_piso="Remoto por LAN solo con SCU-LAN10 y software Windows; con FH-2 en la toma REM no se puede usar ALC de amplificador en la misma toma",
        fuente="equip-yaesu-ft710;equip-yaesuuk-ft710;equip-qst-ft710;equip-yaesu-ft710-cat;equip-manualslib-ft710;equip-kpo-scu-lan10;equip-wimo-scu-lan10;equip-passion-ft710;equip-ondamania-ft710aess;equip-tutienda-ft710field;equip-aimasstore-ft710;equip-micropipes-ftdx3000-mac;equip-yaesu-ftdx10-cat",
        por_verificar="IVA del precio de Passion Radio; tipo de muestreo; peso exacto; chip USB y puertos en macOS; split/CLAR/registros de banda; micrófono incluido",
    ),
    dict(
        modelo="Icom IC-705",
        variante="Portátil QRP (HF/50/144/430 MHz)",
        lanzamiento="2020 (folleto de Icom Europe de julio de 2020)",
        potencia_w="0,1-10 W con 13,8 V; 0,1-5 W con batería de 7,4 V; AM 0,025-2,5 W",
        potencia_max_w=10, potencia_min_w=0.1,
        receptor="Muestreo directo de RF por debajo de 25 MHz; conversión descendente con muestreo de FI desde 25 MHz; RX 0,030-199,999 MHz y 400-470 MHz",
        rx_datos_clave="Sin cifra oficial de margen dinámico; Sherwood lo ha medido (índice N9EWO): valor POR VERIFICAR",
        atu="No; opcional AH-705 (externo): 3,5-54 MHz con hilo >=7 m, 1,8-54 MHz con hilo >=30 m; precisión <2:1; máx. 10 W",
        memorias_voz="8 (T1-T8), hasta 1,5 min cada una, en microSD",
        keyer_cw="Sí (memorias de manipulador; detalle POR VERIFICAR)",
        funciones_concurso="Espectro y cascada en pantalla táctil de 4,3\"; con 10 W y antena de compromiso es muy difícil competir en SSB",
        usb_cat_audio="Sí: micro-USB con 2 puertos COM (CI-V) + audio; también carga la batería",
        usb_macos="Sin driver en macOS reciente (fuente de terceros)",
        protocolo_cat="Icom CI-V (dirección por defecto POR VERIFICAR)",
        remoto="Wi-Fi y Bluetooth integrados; control por Wi-Fi desde Mac con wfview documentado por terceros (M0AWS)",
        salida_video="No",
        alimentacion="13,8 V CC +/-15 % externa (TX <3 A a 10 W) o batería de 7,4 V (BP-272; BP-307 en UE)",
        consumo_tx_a=3, peso_kg=1.1,
        precio_eur=1349.00, iva="POR VERIFICAR (precio con descuento de 200 €; el resultado muestra etiqueta 'HT')",
        tienda="Passion Radio", fecha_precio=HOY,
        otros_precios="WiMo 1.249,00 € IVA alemán incl. (ficha del 03-10-2026; precio de referencia 1.495 €); Astro Radio 1.257,19 € (IVA 21 % incl.; -2 % por transferencia); Radiomanía 1.299,90 € (sin stock); AH-705 en WiMo 339,00 € IVA incl.",
        pros_piso="Ligero (1,1 kg) y con batería; Wi-Fi; muy bajo consumo; útil como equipo portátil y receptor",
        contras_piso="10 W: categoría Low Power pero en clara desventaja en CQ WW SSB con antena de compromiso; sin ATU interno (AH-705 solo para hilo); para 100 W haría falta un amplificador",
        fuente="equip-icomamerica-705;equip-icomeurope-705-bro;equip-icomjapan-705;equip-icomamerica-ah705;equip-wimo-ah705;equip-manualslib-ic705-voicetx;equip-wimo-ic705;equip-passion-ic705;equip-astroradio-ic705;equip-treerocket-705mac;equip-m0aws-705;equip-n9ewo-sherwood",
        por_verificar="IVA del precio de Passion Radio; dirección CI-V; cifras Sherwood; detalle del manipulador CW",
    ),
]

# ---------------------------------------------------------------------------
# Presupuesto: una opción por categoría y nivel (sin alternativas, para sumar).
# ---------------------------------------------------------------------------
BUDGET_FIELDS = [
    "categoria", "articulo", "opcion", "precio_eur", "tienda", "fecha_precio",
    "fuente_url", "verificado", "iva_incluido", "notas",
]

PV = "POR VERIFICAR: sin precio confirmado en esta sesión (cupo de búsquedas agotado)"

BUDGET = [
    # ---- mínima ----
    dict(categoria="Transceptor", articulo="Yaesu FT-710 Field (100 W, ATU interno; sin altavoz SP-40)", opcion="minima",
         precio_eur=1099.00, tienda="La Tienda del Radioaficionado", fecha_precio=HOY,
         fuente_url=REFS["equip-tutienda-ft710field"]["url"], verificado="si", iva_incluido="si (21 %)",
         notas="Precio visto en resultado de búsqueda; fecha de la ficha desconocida; confirmar stock"),
    dict(categoria="Alimentación", articulo="Fuente 13,8 V CC de al menos 25 A continuos (el equipo pide 21 A en TX)", opcion="minima",
         notas=PV),
    dict(categoria="Antena", articulo="Media onda alimentada en punta (EFHW) multibanda 80/40-10 m apta para 100 W SSB", opcion="minima",
         notas=PV + "; elegir potencia nominal con margen para ciclo de trabajo de concurso"),
    dict(categoria="Cable coaxial", articulo="15-20 m de coaxial de 50 ohm tipo RG-213 con conectores PL-259", opcion="minima",
         notas=PV),
    dict(categoria="Choke de modo común", articulo="Choke de ferrita mezcla 31 en el coaxial (punto de alimentación o entrada al cuarto)", opcion="minima",
         notas=PV),
    dict(categoria="Memorias de voz", articulo="Tarjeta SD para las memorias de voz del equipo", opcion="minima",
         notas=PV),
    dict(categoria="Micrófono", articulo="Micrófono de mano incluido con el equipo (confirmar qué incluye la versión Field)", opcion="minima",
         notas=PV),
    dict(categoria="Escucha SDR", articulo="RTL-SDR Blog V4 + antena de hilo para recepción", opcion="minima",
         notas=PV + "; si ya se tiene, coste 0"),
    # ---- recomendada ----
    dict(categoria="Transceptor", articulo="Icom IC-7300MK2 (100 W, ATU interno, USB-C, LAN, HDMI)", opcion="recomendada",
         precio_eur=1549.00, tienda="WiMo", fecha_precio=HOY,
         fuente_url=REFS["equip-wimo-7300mk2"]["url"], verificado="si", iva_incluido="si (IVA alemán 19 %; envío aparte)",
         notas="Precio verificado por el usuario el 2026-10-20; si WiMo aplica IVA español (21 %) sería ~1.575 € (POR VERIFICAR). Alternativa: Radiomanía 1.549,90 € con IVA y envío incluidos"),
    dict(categoria="Alimentación", articulo="Fuente 13,8 V CC de 30 A de bajo ruido de RF", opcion="recomendada",
         notas=PV),
    dict(categoria="Antena", articulo="EFHW multibanda para 100 W SSB + opción vertical corta con radiales y acoplador remoto para 160/80 m", opcion="recomendada",
         notas=PV),
    dict(categoria="Cable coaxial", articulo="15-20 m de coaxial de baja pérdida (tipo Ecoflex 10 o Aircell 7) con conectores", opcion="recomendada",
         notas=PV),
    dict(categoria="Choke de modo común", articulo="Dos chokes de ferrita mezcla 31 (punto de alimentación y entrada al cuarto)", opcion="recomendada",
         notas=PV),
    dict(categoria="Auriculares", articulo="Auriculares cerrados con micrófono de pértiga + adaptador al conector de micrófono del equipo", opcion="recomendada",
         notas=PV),
    dict(categoria="PTT", articulo="Pedal de PTT", opcion="recomendada",
         notas=PV),
    dict(categoria="Medida", articulo="Medidor de ROE/vatímetro de paso para HF", opcion="recomendada",
         notas=PV + "; los equipos muestran ROE en pantalla (comprobar en manual)"),
    dict(categoria="Medida", articulo="Carga ficticia de 50 ohm para 100 W", opcion="recomendada",
         notas=PV),
    dict(categoria="Filtrado", articulo="Filtro paso bajo HF para 100 W (ayuda frente a interferencias en TV/radio de vecinos)", opcion="recomendada",
         notas=PV),
    dict(categoria="Memorias de voz", articulo="Tarjeta SD para las memorias de voz del equipo", opcion="recomendada",
         notas=PV),
    dict(categoria="Escucha SDR", articulo="RTL-SDR Blog V4 + antena de hilo para recepción (servidor en la Raspberry Pi 5)", opcion="recomendada",
         notas=PV + "; si ya se tiene, coste 0"),
    dict(categoria="Control remoto", articulo="Icom RS-BA1 Version 2 (opcional; software de control remoto, plataforma POR VERIFICAR)", opcion="recomendada",
         precio_eur=121.00, tienda="tienda española no identificada en el resultado", fecha_precio=HOY,
         fuente_url="", verificado="no", iva_incluido="si",
         notas="POR VERIFICAR: el resultado de búsqueda no identifica la tienda; en Mac hay alternativas (SDR Control; wfview POR VERIFICAR)"),
]


def check_refs(text: str) -> list[str]:
    missing = []
    for key in [k for k in text.split(";") if k]:
        if key not in REFS:
            missing.append(key)
    return missing


def write_csv(path: Path, fields: list[str], rows: list[dict]) -> None:
    with path.open("w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=fields)
        w.writeheader()
        for row in rows:
            out = {}
            for f in fields:
                v = row.get(f, "")
                if isinstance(v, float):
                    v = f"{v:.2f}" if f == "precio_eur" else f"{v:g}"
                out[f] = v
            w.writerow(out)


def write_refs(path: Path) -> None:
    doc = {}
    for key in sorted(REFS):
        r = REFS[key]
        entry = {"type": "web", "title": r["title"]}
        if "author" in r:
            entry["author"] = r["author"]
        if "publisher" in r:
            entry["publisher"] = r["publisher"]
        if "date" in r:
            entry["date"] = r["date"]
        entry["url"] = {"value": r["url"], "date": HOY}
        doc[key] = entry
    header = (
        "# Referencias Hayagriva para el capítulo de equipo (prefijo equip-).\n"
        "# url.date = fecha de consulta. Generado por scripts/equip_build.py\n"
    )
    body = yaml.safe_dump(doc, allow_unicode=True, sort_keys=False, width=1000)
    path.write_text(header + body, encoding="utf-8")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    problems = []
    for rig in RIGS:
        problems += [f"{rig['modelo']}: {k}" for k in check_refs(rig["fuente"])]
        assert set(rig) <= set(RIG_FIELDS), set(rig) - set(RIG_FIELDS)
    for row in BUDGET:
        assert row["opcion"] in ("minima", "recomendada"), row
        row.setdefault("verificado", "no")
        assert set(row) <= set(BUDGET_FIELDS), set(row) - set(BUDGET_FIELDS)
    if problems:
        raise SystemExit("Claves de referencia inexistentes: " + ", ".join(problems))

    write_csv(OUT_DIR / "rigs.csv", RIG_FIELDS, RIGS)
    write_csv(OUT_DIR / "budget.csv", BUDGET_FIELDS, BUDGET)
    write_refs(OUT_DIR / "refs.yml")

    # Comprobación de ida y vuelta del YAML
    loaded = yaml.safe_load((OUT_DIR / "refs.yml").read_text(encoding="utf-8"))
    assert all(k.startswith("equip-") for k in loaded)
    assert all(v["type"] == "web" and "value" in v["url"] for v in loaded.values())

    for opcion in ("minima", "recomendada"):
        filas = [r for r in BUDGET if r["opcion"] == opcion]
        ver = [r for r in filas if r.get("verificado") == "si" and r.get("precio_eur")]
        total_ver = sum(r["precio_eur"] for r in ver)
        sin_precio = [r["categoria"] for r in filas if not r.get("precio_eur")]
        print(f"{opcion}: {len(filas)} partidas; subtotal verificado {total_ver:.2f} € "
              f"({len(ver)} partidas); sin precio: {len(sin_precio)} -> {', '.join(sin_precio)}")
    # Cálculos de IVA hipotéticos (no son precios publicados)
    neto_wimo = 1549.00 / 1.19
    print(f"WiMo IC-7300MK2 neto {neto_wimo:.2f} € -> con IVA ES 21 %: {neto_wimo*1.21:.2f} €")
    for nombre, ht in (("FT-710 AESS Passion Radio", 1249.00), ("IC-705 Passion Radio", 1349.00)):
        print(f"{nombre}: si {ht:.2f} € fuera sin IVA -> +21 % = {ht*1.21:.2f} €; +20 % (FR) = {ht*1.20:.2f} €")
    print(f"refs.yml: {len(loaded)} entradas")


if __name__ == "__main__":
    main()
