#import "../plantilla.typ": *
#import "fonetica.typ": deletrear
#import "diagramas.typ": diagrama-estacion

#let budget = csv("../data/equipment/budget.csv", row-type: dictionary)
#let ef = csv("../data/equipment/eficiencia_antenas.csv", row-type: dictionary)
#let lh = csv("../data/antenas/longitud_hilo.csv", row-type: dictionary)
#let lhv(h, banda, campo, tierra: "") = {
  let r = lh.filter(r => r.hilo_m == str(h) and r.banda == banda and r.tierra_ohm == tierra)
  if r.len() == 0 { "—" } else { coma(r.first().at(campo)).replace("-", "−") }
}
#let total(op) = budget.filter(r => r.opcion == op and r.precio_eur != "").map(r => float(r.precio_eur)).sum()
#let efv(cfgtxt, banda) = {
  let r = ef.filter(r => r.configuracion == cfgtxt and r.banda == banda)
  if r.len() == 0 { "—" } else {
    let p = float(r.first().eficiencia_pct)
    let d = if p < 1 { 2 } else if p < 10 { 1 } else { 0 }
    [#redondea(p, d) % (−#redondea(r.first().perdida_db, 1) dB)]
  }
}

#let capitulo(cfg) = [
= Equipo <cap-equipo>

== La estación mínima viable desde un piso

#figure(
  diagrama-estacion(),
  kind: image,
  caption: [Esquema de la estación: la RF va por el coaxial (con un choke en cada extremo) y todo lo demás llega al transceptor por cables cortos.],
) <fig-estacion>

#tabla(
  columns: (auto, 1fr),
  table.header([Elemento], [Qué necesitas y por qué]),
  [Transceptor], [100 W en 160–10 m con *acoplador interno* (ajusta pequeñas desadaptaciones en cada banda) y *memorias de voz* para el CQ y el indicativo.],
  [Antena], [La mejor que quepa en la terraza para 40–10 m; 80 y 160 m son un extra (apartado @sec-antena).],
  [Coaxial y choke], [Coaxial de 50 Ω de baja pérdida y un *choke de modo común* en la antena para que la RF no vuelva al cuarto por la malla.],
  [Fuente], [13,8 V con margen sobre los 21 A que piden los equipos de 100 W al transmitir.],
  [Audio], [Cascos cerrados con micrófono de pértiga y *pedal de PTT*: tras 48 horas, las manos libres y la voz descansada valen puntos.],
  [Ordenador], [Tu Mac con un logger de concursos, control CAT y voice keyer (capítulo @cap-herramientas).],
  [Escucha], [El RTL-SDR V4 y los receptores web para comprobar cómo te oyen y practicar (capítulo @cap-escucha-2026).],
)

== Los tres transceptores comparados

#larga[#figure(
  caption: [Comparativa (datos del fabricante salvo indicación; precios vistos el 20 de octubre de 2026).],
  tabla(
    columns: (auto, 1fr, 1fr, 1fr),
    table.header([], [Icom IC-7300MK2], [Yaesu FT-710 AESS], [Icom IC-705]),
    [Potencia], [0,6–100 W], [5–100 W], [0,1–10 W (5 W con batería)],
    [Receptor], [SDR de muestreo directo de RF; RMDR ≈ 105 dB a 2 kHz según Icom (sin medida independiente)], [SDR con ADC y FPGA; laboratorio ARRL (QST, ago 2023): RMDR 116 dB y DR3 106 dB a 2 kHz], [Muestreo directo por debajo de 25 MHz],
    [Acoplador interno], [Sí, 16,7–150 Ω (ROE ≤ 3:1)], [Sí, 16,7–150 Ω (ROE ≤ 3:1)], [No (AH-705 aparte, ≤ 10 W, para hilo largo)],
    [Memorias de voz (TX)], [8 (T1–T8) en SD; duración #pv (1,5 min en el IC-7300)], [5 × 90 s en SD], [8 × 1,5 min en microSD],
    [USB al ordenador], [USB-C: 2 puertos COM (CI-V) + audio; el driver de Icom es solo para Windows @vere-icom-usbdriver], [USB-B: CAT + audio + PTT; chip Silicon Labs CP210x con 2 puertos COM @vere-yaesu-vcp-manual], [micro-USB: 2 COM + audio],
    [Remoto], [LAN integrada (wfview en el Mac; el RS-BA1 V2 de Icom es solo para Windows @vere-wimo-rsba1v2)], [Kit SCU-LAN10 (software de Windows)], [Wi-Fi integrado],
    [Extras], [HDMI, RX ANT, decodificador CW], [Salida DVI-D], [Batería, GPS, Bluetooth],
    [Consumo / peso], [21 A en TX / 4,1 kg], [21 A en TX / 4,5 kg], [< 3 A en TX / 1,1 kg],
    [Precio de referencia], [1.549 € (WiMo, IVA alemán incl., envío aparte; ≈ 1.575 € con el 21 % #pv). Tiendas españolas: 1.549,90–1.571,79 €.], [1.249 € (Passion Radio; el buscador lo marca «sin IVA» #pv). En España, con IVA: 1.189,20 € (Ondamania #pv tras fin de un reembolso); versión Field 1.099 € (La Tienda del Radioaficionado).], [1.349 € (Passion Radio, IVA #pv); 1.249 € con IVA (WiMo, 3-oct-2026); 1.257,19 € (Astro Radio).],
  ),
) <tab-rigs>]

*Valoración para tu caso* (opinión, no dato):

- *Yaesu FT-710*: la mejor relación prestaciones/precio y las mejores medidas de receptor publicadas. Su punto débil es el remoto, que exige el kit SCU-LAN10 y software de Windows.
- *Icom IC-7300MK2*: unos 300–450 € más, pero es el que mejor encaja con tu Mac y tu homelab: un solo cable USB-C para CAT y audio, LAN integrada para operar desde otra habitación o por Tailscale, y salida HDMI para una pantalla grande durante 48 horas. wfview y Hamlib ya lo soportan (dirección CI-V 0xB6). Icom solo publica driver USB para Windows, así que si funciona por USB en macOS sin driver está #pv; si no, wfview puede controlarlo por la LAN.
- *Icom IC-705*: magnífico portátil y receptor, pero 10 W con una antena de compromiso es muy poco para el CQ WW SSB. Solo como segundo equipo.

#truco[Elijas el que elijas, la diferencia entre ellos en el concurso es pequeña comparada con la que hay entre una buena y una mala antena. Si dudas, ahorra en la radio y gasta en la antena y los cascos.]

== La antena de la terraza <sec-antena>

Los acopladores internos solo corrigen hasta ROE 3:1: la antena tiene que estar *ya cerca de 50 Ω* en cada banda. Tres opciones habituales (@fig-antenas):

#figure(
  image("../assets/antenas_terraza.pdf", width: 100%),
  caption: [Tres antenas para una terraza, a escala aproximada (el hilo de la EFHW está cortado porque no cabe): EFHW con transformador 49:1, vertical corta de ≈ 7 m con acoplador remoto y radiales, y lazo magnético de 1–1,5 m. Ilustración propia (`scripts/fig_antenas.py`).],
) <fig-antenas>

/ EFHW multibanda: un hilo de media onda alimentado en un extremo con un transformador (típicamente 49:1). Un hilo de unos 20 m resuena en 40 m y en sus armónicos (20, 15 y 10 m); uno de unos 40 m añade 80 m. Es la que más rinde por euro si la terraza permite tender el hilo inclinado hacia un punto alto. Inconveniente: la malla del coaxial forma parte del sistema y es fácil tener *RF en el cuarto*; hace falta un choke de modo común (y a menudo un contrapeso corto, según el fabricante).
/ Vertical corta: un radiador de unos 7 m con acoplador remoto en la base y radiales elevados. Ocupa poco suelo, pero sin buenos radiales pierde mucho en las bandas bajas.
/ Lazo magnético: un aro de 1–1,5 m con un condensador variable. Cabe en cualquier terraza y recibe con poco ruido, pero en 160–40 m es estrechísimo (hay que resintonizar cada pocos kHz en S&P) y con 100 W el condensador soporta varios kilovoltios.

#figure(
  caption: [Eficiencia estimada de antenas pequeñas con fórmulas clásicas (`scripts/equip_eficiencia.py`): resistencia de radiación del lazo pequeño y de la vertical corta frente a sus pérdidas. Una unidad S son unos 6 dB. No incluye el efecto del hormigón ni de las barandillas.],
  tabla(
    columns: (1.6fr, 1fr, 1fr, 1fr, 1fr),
    table.header([Antena (supuestos)], [160 m], [80 m], [40 m], [20 m]),
    [Lazo de 1 m, tubo de cobre de 22 mm], efv("D=1 m, tubo Cu 22 mm, R_extra=0 mOhm", "160m"), efv("D=1 m, tubo Cu 22 mm, R_extra=0 mOhm", "80m"), efv("D=1 m, tubo Cu 22 mm, R_extra=0 mOhm", "40m"), efv("D=1 m, tubo Cu 22 mm, R_extra=0 mOhm", "20m"),
    [Lazo de 1,5 m, tubo de cobre de 22 mm], efv("D=1.5 m, tubo Cu 22 mm, R_extra=0 mOhm", "160m"), efv("D=1.5 m, tubo Cu 22 mm, R_extra=0 mOhm", "80m"), efv("D=1.5 m, tubo Cu 22 mm, R_extra=0 mOhm", "40m"), efv("D=1.5 m, tubo Cu 22 mm, R_extra=0 mOhm", "20m"),
    [Vertical de 7 m, 15 Ω de pérdidas de tierra], [3,1 % (−15,2 dB)], [13,5 % (−8,7 dB)], [40 % (−4,0 dB)], [≈ λ/4 (otro modelo)],
    [Vertical de 7 m, 5 Ω (radiales elevados)], [5,2 % (−12,8 dB)], [25 % (−6,0 dB)], [63 % (−2,0 dB)], [—],
  ),
) <tab-eficiencia>

La conclusión práctica: *en 40–10 m cualquiera de las tres funciona* razonablemente; *en 80 y 160 m solo una EFHW larga o una vertical con buenos radiales* te darán QSO lejanos. Para el CQ WW eso significa concentrar tu esfuerzo en 40–10 m y tomar 80/160 m como una bonificación.

=== Qué antena comprar <sec-antena-compra>

Solo un *acoplador remoto en la base* de un hilo vertical da las seis bandas con una sola antena: ninguna antena resonante de las que se venden en España o en la UE cubre 160 m. Opciones con precio comprobado el 20 de octubre de 2026 (con IVA; WiMo, con el alemán del 19 % y sin envío):

#figure(
  caption: [Antenas para la terraza con datos del fabricante y precios de tienda (`data/antenas/antenas.csv`). Los totales suman una caña de 12 m (70,18 €), 20 m de Aircell 7 (87,20 €) y un choke (54,45 €).],
  tabla(
    columns: (1.45fr, auto, 2.2fr, 1.3fr),
    table.header([Opción], [Bandas], [Qué es], [Precio]),
    [*A1. Hilo vertical + Icom AH-730* (con el IC-7300MK2)], [160–10 m], [Acoplador estanco en la base: 1,8–54 MHz con 7 m de hilo o más, 150 W PEP y 100 W continuos, cable de control de 10 m. Icom pide toma de tierra (cuántos radiales en una terraza, #pv) @ant-icomfrance-ah730-doc @ant-icomjapan-ah730.], [498 € (WiMo) @ant-wimo-ah730; total ≈ 710~€],
    [*A2. Hilo + Yaesu FC-40* (con el FT-710)], [160 m con 20 m de hilo], [Acoplador estanco de 100 W; para 160 m pide 20 m de hilo o más: L invertida desde la punta de la caña @ant-yaesu-fc40-manual.], [281,60 € (Ondamania) @ant-ondamania-fc40; total ≈ 494~€],
    [*A3. Hilo + LDG RT-100* (con cualquier equipo)], [1,8–54 MHz; 160 m #pv], [Se alimenta y se controla por el propio coaxial; 125 W de pico en SSB; LDG no publica la longitud mínima de hilo @ant-ldg-rt100.], [385 € (WiMo) @ant-wimo-rt100; total ≈ 597~€],
    [*B. EFHW de 40 m* (Dxpatrol 80–10 m)], [80–10 m], [Hilo de 40 m tendido o inclinado, 1000 W en SSB; choke en el punto de alimentación @ant-astroradio-dxpatrol-endfeed.], [119,79 € (Astro Radio); con choke y coaxial ≈ 261~€],
    [*B'. EFHW de 20 m* (MyAntennas EFHW-4010)], [40–10 m], [≈ 19,2 m de hilo, 1 kW ICAS; se compra en EE. UU. @ant-myantennas-efhw4010.], [194,99 USD más envío e IVA de importación],
  ),
) <tab-antenas>

#importante[*Recomendación para tu terraza*: con el IC-7300MK2, un *Icom AH-730* en la base de un hilo vertical de unos 7 m sujeto a una caña de fibra de 12 m, con radiales sobre la terraza y un choke en cada extremo del coaxial. Es la única combinación documentada que da las seis bandas del CQ WW con solo 7 m de hilo, vuelve a una banda memorizada en ≈ 1 s y no se ve más que una caña: unos *710 €* con caña, coaxial y choke (498 € el acoplador). Con el FT-710, el *Yaesu FC-40* con una L invertida de al menos 20 m de hilo (unos *494 €*). Si no puedes poner la caña pero sí tender 40 m de hilo, la *EFHW de 40 m* (≈ 261~€), renunciando a 160 m.]

*Qué longitud de hilo.* Un hilo más largo mejora las bandas bajas y empeora las altas (`scripts/ant_longitud_hilo.py`, con 5 Ω de pérdidas de tierra):

- *160 m*: la eficiencia pasa del #lhv(7, "160 m", "eficiencia_pct", tierra: "5") % con 7 m al #lhv(12, "160 m", "eficiencia_pct", tierra: "5") % con 12 m (unos 5 dB más); *80 m*, del #lhv(7, "80 m", "eficiencia_pct", tierra: "5") % al #lhv(12, "80 m", "eficiencia_pct", tierra: "5") %.
- *10 m*: a 10° de elevación, 7 m de hilo dan #lhv(7, "10 m", "directividad_10deg_dbi") dBi; con 10 m, #lhv(10, "10 m", "directividad_10deg_dbi") dBi, porque el lóbulo principal sube a #lhv(10, "10 m", "lobulo_deg")°.

Para el CQ WW, donde 20, 15 y 10 m dan la mayoría de los QSO, *unos 7 m* son el mejor compromiso. Si vas a por 160 y 80 m, alarga con un tramo horizontal (L invertida) y acepta perder algo en 10 m. Prueba con la caña extendida a distintas longitudes mirando la ROE en la pantalla.

*Coaxial y choke.* Con 20 m de cable, el Aircell 7 pierde 0,67 dB en 10 m y el Ecoflex 10, 0,40 dB, según sus hojas de datos @ant-ssb-aircell7-ds @ant-ssb-ecoflex10-ds: la diferencia no se nota y el Aircell 7 cuesta la mitad (4,36 €/m @ant-proyecto4-aircell7). Para el choke, K9YC pide al menos 5 kΩ de impedancia de modo común en el punto de alimentación @ant-k9yc-cookbook; las tiendas españolas no publican la de sus baluns 1:1 #pv, y con un toroide FT-240-31 (10,29 € @ant-astroradio-ft240-31) puedes hacerte uno.

*Lo que no te recomiendo*: los lazos magnéticos de 100 W (Ciro Mazzoni, 1.419–1.775 € cada uno y sin 160 m @ant-wimo-ciromazzoni), el Chameleon F-Loop (25 W @ant-chameleon-floop3), la Hy-Gain AV-640 (sin 80 ni 160 m, y MFJ dejó de fabricar en mayo de 2024 @ant-arrl-mfj) y las verticales con trampas tipo Hustler BTV, que piden 20 radiales de 6 m @ant-dxe-btv-manual.

== Accesorios

- *Cascos con micrófono de pértiga*: cerrados (aíslan del ruido de la casa y no realimentan el micro) y con un micro de respuesta orientada a la voz. Por ejemplo, los Heil Pro Set Elite IC (versión para Icom, 216,59 €) con el adaptador AD-1-I al conector de 8 pines (29,02 €) @vere-astro-proset-elite-ic @vere-proyecto4-heil; el adaptador para el FT-710 está #pv.
- *Pedal de PTT*: libera las manos para teclear el log. El Heil FS-3 (36,30 €) lleva clavija de 6,3 mm y se conecta a los adaptadores AD-1 y CC-1 de Heil @vere-astro-fs3 @vere-wimo-fs3.
- *Fuente de alimentación*: 13,8 V y al menos 25 A continuos (mejor 30 A), de bajo ruido de radiofrecuencia: algunas conmutadas meten ruido en HF. Las hay desde 68,40 € @vere-ondamania-rps1230swm; compruébalo escuchando con la fuente encendida y apagada (con batería).
- *Medidor de ROE/vatímetro y carga ficticia*: para ajustar sin radiar y medir la potencia real (≤ 100 W en baja potencia). Un medidor de HF como el Diamond SX-200 (1,8–200 MHz, 83,95 €) @vere-ondamania-sx200; *ojo*: el Surecom SW-102, muy vendido, es de VHF/UHF @vere-ondamania-sw102. Las cargas «de 100 W» baratas aguantan 20–35 W continuos @vere-passion-dummy100 @vere-ondamania-avdl200m: a 100 W, solo pasadas cortas.
- *Filtro paso bajo* a la salida: reduce armónicos que pueden molestar a la TV de los vecinos; la Orden pide usar los filtros «que sean precisos».

== Cómo no molestar a los vecinos (ni a ti mismo)

Prácticas habituales para evitar interferencias en HF (las guías de referencia son las de la ARRL, la RSGB y el recetario de K9YC sobre RFI y ferritas @ant-k9yc-cookbook):

+ *Choke de modo común* (ferrita de mezcla 31) en el punto de alimentación de la antena y otro a la entrada del cuarto.
+ *Antena lo más lejos posible* del cableado de tu casa y de las viviendas vecinas; el coaxial, sin ir en paralelo a cables de red o de TV.
+ *Ferritas en los cables* de USB, audio y alimentación del cuarto, y todo el equipo referido a una misma masa.
+ *Filtro paso bajo* a la salida del transceptor y filtros de red donde haga falta.
+ *Prueba antes del concurso*: con poca potencia y subiendo, con un vecino colaborador, y anota los resultados. Los equipos permiten bajar a 0,6 W (IC-7300MK2) o 5 W (FT-710).
+ *Avisa* a los vecinos del fin de semana del concurso y ofrece ayuda si notan algo.

Recuerda que la responsabilidad legal de eliminar una interferencia es tuya (apartado @sec-licencia-estacion y capítulo @cap-legal).

== Presupuesto

#larga[#figure(
  caption: [Presupuesto con precios vistos el 20 de octubre de 2026, con IVA (WiMo y Spiderbeam, con el alemán y sin envío). Datos en `data/equipment/budget.csv`.],
  tabla(
    columns: (3fr, auto, 0.85fr),
    table.header([Artículo], [Precio], [Tienda]),
    ..(
      ("minima", [Estación mínima: FT-710 con EFHW de 40 m (sin 160 m)]),
      ("recomendada", [Estación recomendada: IC-7300MK2 con AH-730 (las seis bandas)]),
      ("opcional", [Opcionales]),
    ).map(((op, titulo)) => (
      table.cell(colspan: 3, fill: c.azul-claro)[#text(weight: "semibold", fill: c.azul-noche)[#titulo]],
      ..budget.filter(r => r.opcion == op).map(r => (
        [#r.articulo#if r.notas not in ("", "POR VERIFICAR") [ #text(fill: c.tinta2, size: 0.9em)[(#r.notas)]]],
        align(right, if r.precio_eur == "" { pv } else if float(r.precio_eur) == 0 [—] else [#euros(r.precio_eur) €]),
        if r.verificado == "si" and r.tienda != "—" [#r.tienda] else [—],
      )).flatten(),
      [*Total*#if op != "opcional" [ #text(fill: c.tinta2, size: 0.9em)[(sin hilo, radiales, conectores ni envíos)]]],
      align(right)[*#euros(total(op)) €*],
      [],
    )).flatten(),
  ),
) <tab-presupuesto>]

La estación mínima sale por unos *#miles(total("minima")) €* y la recomendada por unos *#miles(total("recomendada")) €*, más hilo, radiales, conectores y envíos; los opcionales suman #miles(total("opcional")) €. Casi toda la diferencia está en el transceptor y en el acoplador remoto. Antes de comprar, confirma el precio final con envío e IVA del 21 %: WiMo y Spiderbeam muestran el IVA alemán.

#fuentes("ant-wimo-ah730", "ant-icomfrance-ah730-doc", "ant-ondamania-fc40", "ant-wimo-rt100", "ant-astroradio-dxpatrol-endfeed", "ant-proyecto4-aircell7", "ant-proyecto4-as111500", "ant-spiderbeam-12hd-set2", "ant-astroradio-cg12", "vere-radiomania-ss330w", "vere-astro-proset-elite-ic", "vere-fnac-sdhc32", "vere-wimo-lpf30-2000", "soft-wfview-rig-ic7300mk2", "soft-hamlib-riglist", "equip-icomamerica-7300mk2", "equip-icomamerica-7300mk2-unveil", "equip-icomuk-7300mk2-advanced", "equip-wimo-7300mk2", "equip-yaesu-ft710", "equip-yaesuuk-ft710", "equip-qst-ft710", "equip-manualslib-ft710", "equip-icomamerica-705", "equip-manualslib-ic705-voicetx", "equip-passion-ft710", "equip-passion-ic705", "equip-wimo-ic705", "equip-tutienda-ft710field", "legal-orden-iet-1311-2013")
]
