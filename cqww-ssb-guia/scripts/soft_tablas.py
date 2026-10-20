#!/usr/bin/env python3
"""Genera data/software/tools.csv y data/software/receivers.csv.

Los datos se comprobaron el 2026-10-20; la columna «verificado» indica cómo:
  V1 = fuente primaria leída en la sesión (código, README, JSON de PyPI)
  V2 = resumen/cita de búsqueda web de la página indicada
  V3 = fuente secundaria (cask/fórmula de Homebrew, rastreador de terceros)
  POR VERIFICAR = no confirmado en la sesión
Uso:  python scripts/soft_tablas.py
"""

import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "data" / "software"

PV = "POR VERIFICAR"

TOOLS_HEADER = [
    "herramienta",
    "uso",
    "plataformas",
    "mac_nativo",
    "version",
    "fecha_version",
    "precio_licencia",
    "url",
    "verificado",
]

TOOLS = [
    # --- Registradores ---
    ["SkookumLogger", "Registrador de concursos (CQ WW; DVR de la radio; voz sintética TTS/Personal Voice)",
     "macOS 13 Ventura o posterior", "si", "6.0 (13); beta 6.0 (14)", "2026-09-05 (beta: notas 2026-10-02)",
     "Gratuito", "https://k1gq.net/SkookumLogger/",
     "V2 búsqueda (k1gq.net, 2026-10-20); binario Universal según tercero (V3)"],
    ["N1MM Logger+", "Registrador de concursos (DVK con WAV integrado)", "Windows 10/11", "vm",
     "1.0.11466 (actualización); instalador completo 1.0.11364", "2026-10-13 (instalador: 2026-07-21)",
     "Gratuito", "https://n1mmwp.hamdocs.com/",
     "V2 búsqueda (listado oficial de actualizaciones, 2026-10-20)"],
    ["Not1MM", "Registrador de concursos (plugin CQ WW SSB; DVK WAV; Cabrillo con ROOKIE y NON-ASSISTED)",
     "Linux, macOS (Python 3.11+, PyQt6)", "si", "26.10.18", "2026-10-19",
     "GPL-3.0-or-later (gratuito)", "https://github.com/mbridak/not1mm",
     "V1 (JSON de PyPI y código del paquete 26.10.18)"],
    ["QLog", "Libro de guardia general con concursos básicos (sin puntuación ni multiplicadores)",
     "Linux, Windows 10/11 64 bits, macOS (DMG de aa5sh)", "si", PV, PV, "Gratuito, código abierto",
     "https://github.com/foldynl/QLog", "V1 README; versión POR VERIFICAR"],
    ["RUMlogNG", "Libro de guardia general para macOS (soporte básico IC-7300MK2, LAN y audio)", "macOS", "si",
     "6.0.2", "2026-01-22", PV,
     "https://machamradio.com/blog/2026/01/22/rumlogng-for-macos-version-6-0-2-released/",
     "V2 búsqueda (MacHamRadio); web oficial POR VERIFICAR"],
    ["MacLoggerDX", "Libro DX y control de equipo (no es registrador de concursos)", "macOS", "si",
     "6.62", "POR VERIFICAR (6.61: entrada del 2026-05-30)", "De pago (POR VERIFICAR)",
     "https://www.dogparksoftware.com/MacLoggerDX.html", "V3 cask de Homebrew; 6.61 por V2"],
    ["SDR-Control for Icom", "Control y panorámico de Icom (soporta IC-7300MK2); no es registrador",
     "macOS 14 o posterior (App Store)", "si", "2.10.3", "2026-10-07", "De pago (POR VERIFICAR)",
     "https://apps.apple.com/app/id1592313285", "V2 búsqueda (MacHamRadio); ficha según capítulo de equipo"],
    ["TR4W", "Registrador de concursos", "Windows", "vm", "POR VERIFICAR (repositorio congelado; migración a Delphi 12)",
     PV, "Gratuito, código abierto", "https://tr4w.net", "V1 README de GitHub"],
    ["TLF", "Registrador de concursos en consola (apto para Raspberry Pi)", "Linux (macOS POR VERIFICAR)", "no",
     PV, PV, "GPL (POR VERIFICAR)", "https://github.com/Tlf/tlf", "V1 README"],
    ["DXLog.net", "Registrador de concursos", "Windows", "vm", PV, PV, "Gratuito (POR VERIFICAR)",
     "https://dxlog.net/", PV],
    ["Win-Test", "Registrador de concursos", "Windows", "vm", PV, PV, "De pago (POR VERIFICAR)",
     "https://www.win-test.com/", PV],
    ["Log4OM", "Libro de guardia general", "Windows", "vm", PV, PV, "Gratuito (POR VERIFICAR)",
     "https://www.log4om.com/", PV],
    # --- CAT / control ---
    ["Hamlib (rigctl/rigctld)", "Librería y demonio CAT (IC-7300MK2=3094, IC-705=3085, FT-710=1049); rigctld en el puerto 4532",
     "Linux, macOS, Windows", "si", "4.7.2", "2026-06-21", "LGPL",
     "https://hamlib.github.io/", "V1 (NEWS, riglist.h y fórmula de Homebrew)"],
    ["flrig", "Control de equipo (CAT) sin Hamlib", "Linux, macOS, Windows", "si", "2.0.12", PV,
     "GPL (POR VERIFICAR)", "https://www.w1hkj.org/", "V3 cask de Homebrew"],
    ["wfview", "Control de Icom/Yaesu/Kenwood; servidor de red; rigctld emulado",
     "Linux, macOS, Windows", "si", "2.22 (cadena en master)", PV, "GPLv3",
     "https://wfview.org/", "V1 código (wfview.pro y rigs/*.rig del espejo de GitHub)"],
    ["Icom RS-BA1 Version 2", "Control remoto oficial de Icom por LAN", "Windows", "vm", PV, PV,
     "De pago (POR VERIFICAR)", "", "POR VERIFICAR (ver capítulo de equipo)"],
    ["Yaesu SCU-LAN10", "Unidad de red para operar el FT-710 en remoto (hardware y software Windows)", "Windows", "no",
     PV, PV, "De pago (POR VERIFICAR)", "", "Capítulo de equipo (equip-kpo-scu-lan10); macOS POR VERIFICAR"],
    # --- SDR / recepción ---
    ["SDR++", "Receptor SDR (RTL-SDR, rtl_tcp, SDR++ Server; servidor rigctl); modo servidor -s, puerto 5259",
     "Windows, Linux, macOS, BSD", "si", "1.3.0 (cadena en master)", PV, "GPL-3.0 (POR VERIFICAR)",
     "https://www.sdrpp.org/", "V1 README y código fuente"],
    ["OpenWebRX+", "Servidor SDR web multiusuario (RTL-SDR V4 en la Pi)",
     "Linux (Debian/Ubuntu, imagen para Raspberry Pi, Docker); cliente en el navegador", "no", "1.2.127", "2026-10-19",
     "AGPL-3.0", "https://github.com/luarvique/openwebrx", "V1 debian/changelog y README"],
    ["rtl-sdr (osmocom)", "Driver librtlsdr y utilidades (rtl_tcp); soporta RTL-SDR Blog V4 desde la 2.0.0",
     "Linux, macOS, Windows", "si", "2.0.3", "2026-08-12", "GPL-2.0 (POR VERIFICAR)",
     "https://osmocom.org/projects/rtl-sdr/wiki", "V1 debian/changelog"],
    ["rtl-sdr-blog", "Driver modificado de RTL-SDR Blog (soporte V4 con R828D)", "Linux, Windows", "no", PV, PV,
     "GPL (POR VERIFICAR)", "https://github.com/rtlsdrblog/rtl-sdr-blog", "V1 README"],
    ["gqrx", "Receptor SDR alternativo", "macOS, Linux", "si", "2.17.7", PV, "GPL-3.0 (POR VERIFICAR)",
     "https://gqrx.dk/", "V3 cask de Homebrew"],
    ["KiwiSDR (red pública)", "Receptores remotos de 10 kHz a 30 MHz (hasta 4 oyentes por receptor)", "Navegador", "si",
     "n/a", "n/a", "Uso gratuito", "http://rx.kiwisdr.com",
     "V1 (enlace del README oficial; página no abierta)"],
    ["WebSDR.org", "Directorio de servidores WebSDR", "Navegador", "si", "n/a", "n/a", "Uso gratuito",
     "http://websdr.org/", PV],
    ["rx.linkfanel.net", "Agregador de listas KiwiSDR y WebSDR", "Navegador", "si", "n/a", "n/a", "Uso gratuito",
     "http://rx.linkfanel.net/", "POR VERIFICAR (no resolvía desde el entorno)"],
    # --- Propagación ---
    ["ITURHFProp / P533", "Motor de predicción HF según ITU-R P.533-14 (ruido P.372-15)",
     "POR VERIFICAR (biblioteca y CLI)", "no", PV, PV, PV,
     "https://github.com/ITU-R-Study-Group-3/ITU-R-HF", "V1 README"],
    ["Proppy", "Predicción web basada en ITURHFProp", "Navegador", "si", "n/a", "n/a", "Gratuito (POR VERIFICAR)",
     "https://soundbytes.asia/proppy/", PV],
    ["VOACAP Online", "Predicción web basada en VOACAP (OH6BG)", "Navegador", "si", "n/a", "n/a",
     "Gratuito (POR VERIFICAR)", "https://www.voacap.com/hf/", PV],
    ["voacapl", "VOACAP portado a Linux (gfortran)", "Linux", "no", PV, PV, PV,
     "https://github.com/jawatson/voacapl", "V1 README"],
    ["pythonprop (voacapgui)", "Interfaz GTK3 para VOACAP", "Linux", "no", PV, PV, "GPL (POR VERIFICAR)",
     "https://github.com/jawatson/pythonprop", "V1 README"],
    ["HamCAP", "Predicción (interfaz para VOACAP)", "Windows", "vm", PV, PV, "Gratuito (POR VERIFICAR)",
     "https://www.dxatlas.com/HamCap/", PV],
    ["DR2W", "Predicción (no identificado en la sesión)", PV, PV, PV, PV, PV, "",
     "POR VERIFICAR (no identificado)"],
    ["NOAA SWPC", "Clima espacial en tiempo real (Kp, flujo, avisos)", "Navegador", "si", "n/a", "n/a",
     "Gratuito", "https://www.swpc.noaa.gov/", PV],
    ["HamQSL solar (N0NBH)", "Resumen solar y widget", "Navegador", "si", "n/a", "n/a", "Gratuito",
     "https://www.hamqsl.com/solar.html", PV],
    ["PSKReporter", "Mapa de recepción de modos digitales (indicador de propagación)", "Navegador", "si",
     "n/a", "n/a", "Gratuito", "https://pskreporter.info/pskmap.html", PV],
    ["WSPRnet", "Red de balizas WSPR (indicador de propagación)", "Navegador", "si", "n/a", "n/a", "Gratuito",
     "https://www.wsprnet.org/", PV],
    ["Reverse Beacon Network", "Skimmers de CW y RTTY (no SSB); indicador de propagación; usarlo en concurso es ASSISTED",
     "Navegador", "si", "n/a", "n/a", "Gratuito", "https://www.reversebeacon.net/", PV],
    # --- Cluster ---
    ["DX Summit", "Cluster web (usarlo en concurso es ASSISTED)", "Navegador", "si", "n/a", "n/a", "Gratuito",
     "https://www.dxsummit.fi/", PV],
    ["DXWatch", "Cluster web (usarlo en concurso es ASSISTED)", "Navegador", "si", "n/a", "n/a", "Gratuito",
     "https://dxwatch.com/", PV],
    ["VE7CC CC Cluster / CC User", "Software de nodo y cliente de cluster (usarlo en concurso es ASSISTED)",
     "Windows (cliente CC User); nodos por telnet", "vm", PV, PV, "Gratuito (POR VERIFICAR)",
     "https://www.ve7cc.net/", PV],
    ["HamAlert", "Alertas de spots en app o correo (usarlo en concurso es ASSISTED)", "Navegador y app", "si", "n/a",
     "n/a", "Gratuito (POR VERIFICAR)", "https://hamalert.org/", PV],
    # --- Datos y cqww.com ---
    ["Country files (CTY, AD1C)", "Ficheros de entidades, zonas y excepciones (cty.dat, wl_cty.dat, Big CTY)", "Datos",
     "si", "CTY-3631", "2026-09-15", "Gratuito", "https://www.country-files.com/",
     "V2 (archivo de la lista CTY-Announce); posterior POR VERIFICAR"],
    ["Super Check Partial (MASTER.SCP)", "Base de indicativos activos en concursos", "Datos", "si",
     "Release 2026.09.25 (copia incluida en Not1MM 26.10.18)", "2026-09-25", "Gratuito",
     "https://www.supercheckpartial.com/", "V1 indirecto (cabecera del fichero incluido en Not1MM)"],
    ["CQ WW Cabrillo Log Upload", "Subida y comprobación del log Cabrillo (plazo de 48 h)", "Navegador", "si",
     "n/a", "n/a", "Gratuito", "https://cqww.com/logcheck/",
     "Capítulo de bases (rules-cqww-logcheck) y V1 (plugin de Not1MM)"],
    # --- Virtualización y red ---
    ["Parallels Desktop", "Máquina virtual Windows 11 para Arm (Apple silicon)",
     "v27: macOS Sonoma o posterior, solo arm64; v20.x también en Intel", "vm", "27.0.3-58680", PV, "De pago",
     "https://www.parallels.com/products/desktop/", "V3 casks de Homebrew; autorización de Microsoft por V2"],
    ["VMware Fusion Pro", "Máquina virtual (Windows on Arm desde la 13.5)", "macOS (Intel y Apple silicon)", "vm",
     PV, PV, "Gratuito para uso no comercial", "", "V2 Macworld (2024); versión POR VERIFICAR"],
    ["UTM", "Máquina virtual (QEMU)", "macOS Monterey o posterior", "vm", "5.0.8", PV,
     "Gratuito, código abierto", "https://mac.getutm.app/", "V3 cask de Homebrew"],
    ["VirtualBox", "Máquina virtual", "macOS Intel y Apple silicon", "vm", "7.2.22", PV, "GPL (POR VERIFICAR)",
     "https://www.virtualbox.org/", "V3 cask de Homebrew"],
    ["CrossOver Mac", "Capa Wine para apps Windows; no es una VM (N1MM figura como Unrated en Mac)", "macOS", "si",
     "26.3.0", PV, "De pago", "https://www.codeweavers.com/products/crossover-mac/",
     "V3 cask de Homebrew; valoración de N1MM por V2"],
    ["Tailscale", "Red privada en malla (WireGuard) para el homelab", "macOS Ventura o posterior, Linux, Windows, iOS, Android",
     "si", "1.104.1 (app de macOS)", PV, "Plan personal gratuito (POR VERIFICAR)", "https://tailscale.com/",
     "V1 README; V3 cask de Homebrew"],
    ["Proxmox VE", "Hipervisor del homelab (VM Windows con N1MM)", "Servidor x86-64", "no", PV, PV,
     "AGPL-3.0 (POR VERIFICAR)", "https://www.proxmox.com/", PV],
]

RX_HEADER = ["nombre", "tipo", "ubicacion", "pais", "bandas", "url", "verificado", "nota"]

SEL = ("Elegir en http://map.kiwisdr.com o http://rx.kiwisdr.com: antena exterior, SNR alto, "
       "plazas libres (máx. 4 oyentes)")

RECEIVERS = [
    ["Lista pública KiwiSDR", "KiwiSDR (directorio)", "Mundial", "—", "10 kHz-30 MHz (hardware KiwiSDR)",
     "http://rx.kiwisdr.com", "sí: enlace oficial en el README del proyecto KiwiSDR (2026-10-20); página no abierta",
     "Ordenar por SNR y filtrar por país"],
    ["Mapa KiwiSDR", "KiwiSDR (directorio)", "Mundial", "—", "10 kHz-30 MHz", "http://map.kiwisdr.com",
     "sí: mismo README; página no abierta", "Útil para elegir por distancia a Madrid"],
    ["rx.linkfanel.net", "KiwiSDR y WebSDR (agregador)", "Mundial", "—", "Según el receptor", "http://rx.linkfanel.net/",
     "POR VERIFICAR (no resolvía desde el entorno)", "Agregador citado en el encargo"],
    ["WebSDR.org", "WebSDR (directorio)", "Mundial", "—", "Según el receptor", "http://websdr.org/",
     "POR VERIFICAR (host bloqueado)", "Directorio de servidores WebSDR"],
    ["University of Twente WebSDR", "WebSDR", "Enschede", "Países Bajos",
     "Aprox. 0-29 MHz continuo (límites exactos POR VERIFICAR)", "http://websdr.ewi.utwente.nl:8901/",
     "POR VERIFICAR (host no accesible; conocimiento previo)",
     "Muchos oyentes a la vez; unos 1 541 km de Madrid por círculo máximo (calculado)"],
    ["Northern Utah WebSDR", "WebSDR", "Norte de Utah", "EE. UU.", "Varios receptores de HF (POR VERIFICAR)",
     "http://sdrutah.org/", "POR VERIFICAR (conocimiento previo)", "Ejemplo de receptor lejano en NA (oeste)"],
    ["(por elegir) KiwiSDR en Madrid o centro peninsular", "KiwiSDR", "Comunidad de Madrid o Castilla", "España",
     "10 kHz-30 MHz", "", "POR VERIFICAR (ninguno verificado hoy)",
     SEL + "; para comparar con tu escucha local"],
    ["(por elegir) KiwiSDR en Portugal", "KiwiSDR", "Lisboa u Oporto", "Portugal", "10 kHz-30 MHz", "",
     "POR VERIFICAR", SEL],
    ["(por elegir) Costa este de Norteamérica", "KiwiSDR o WebSDR", "Distritos W1-W4 o VE1-VE3", "EE. UU. / Canadá",
     "10 kHz-30 MHz", "", "POR VERIFICAR", SEL + "; oír cómo llega Europa a NA en 20, 15 y 10 m"],
    ["(por elegir) Caribe o Sudamérica", "KiwiSDR", "KP4, PJ, PY o LU", "Varios", "10 kHz-30 MHz", "",
     "POR VERIFICAR", SEL],
    ["(por elegir) Japón o Asia", "KiwiSDR", "JA o BV", "Japón / Taiwán", "10 kHz-30 MHz", "", "POR VERIFICAR",
     SEL + "; trayecto largo por el norte"],
    ["(por elegir) África", "KiwiSDR", "ZS, 5Z o EA8 (Canarias)", "Varios", "10 kHz-30 MHz", "", "POR VERIFICAR",
     SEL],
    ["(por elegir) Australia u Oceanía", "KiwiSDR", "VK o ZL", "Australia / Nueva Zelanda", "10 kHz-30 MHz", "",
     "POR VERIFICAR", SEL + "; trayectos de camino corto y largo"],
    ["Tu RTL-SDR Blog V4 (OpenWebRX+ o SDR++ server en la Pi 5)", "Propio (OpenWebRX+/SDR++)",
     "Tu QTH (Madrid)", "España", "HF con conversor ascendente interno; ver capítulo de equipo",
     "", "V1 (soporte V4 en rtl-sdr 2.0.0 o posterior)",
     "Acceso por Tailscale; OpenWebRX+ en el puerto 8073 según el capítulo de equipo"],
]


def write(path: Path, header: list, rows: list) -> None:
    for row in rows:
        if len(row) != len(header):
            raise ValueError(f"{path.name}: fila con {len(row)} columnas: {row[0]}")
    with path.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh, quoting=csv.QUOTE_MINIMAL, lineterminator="\n")
        w.writerow(header)
        w.writerows(rows)
    print(f"{path.relative_to(ROOT)}: {len(rows)} filas")


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    write(OUT / "tools.csv", TOOLS_HEADER, TOOLS)
    write(OUT / "receivers.csv", RX_HEADER, RECEIVERS)
