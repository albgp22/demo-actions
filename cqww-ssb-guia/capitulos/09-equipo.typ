#import "../plantilla.typ": *
#import "fonetica.typ": deletrear

#let budget = csv("../data/equipment/budget.csv", row-type: dictionary)
#let ef = csv("../data/equipment/eficiencia_antenas.csv", row-type: dictionary)
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
    [USB al ordenador], [USB-C: 2 puertos COM (CI-V) + audio], [USB-B: CAT + audio + PTT], [micro-USB: 2 COM + audio],
    [Remoto], [LAN integrada (RS-BA1 V2 opcional, sin PC servidor)], [Kit SCU-LAN10 (software de Windows)], [Wi-Fi integrado],
    [Extras], [HDMI, RX ANT, decodificador CW], [Salida DVI-D], [Batería, GPS, Bluetooth],
    [Consumo / peso], [21 A en TX / 4,1 kg], [21 A en TX / 4,5 kg], [< 3 A en TX / 1,1 kg],
    [Precio de referencia], [1.549 € (WiMo, IVA alemán incl., envío aparte; ≈ 1.575 € con el 21 % #pv). Tiendas españolas: 1.549,90–1.571,79 €.], [1.249 € (Passion Radio; el buscador lo marca «sin IVA» #pv). En España, con IVA: 1.189,20 € (Ondamania #pv tras fin de un reembolso); versión Field 1.099 € (La Tienda del Radioaficionado).], [1.349 € (Passion Radio, IVA #pv); 1.249 € con IVA (WiMo, 3-oct-2026); 1.257,19 € (Astro Radio).],
  ),
) <tab-rigs>]

*Valoración para tu caso* (opinión, no dato):

- *Yaesu FT-710*: la mejor relación prestaciones/precio y las mejores medidas de receptor publicadas. Su punto débil es el remoto, que exige el kit SCU-LAN10 y software de Windows.
- *Icom IC-7300MK2*: unos 300–450 € más, pero es el que mejor encaja con tu Mac y tu homelab: un solo cable USB-C para CAT y audio, LAN integrada para operar desde otra habitación o por Tailscale, y salida HDMI para una pantalla grande durante 48 horas. wfview y Hamlib ya lo soportan (dirección CI-V 0xB6); su chip USB en macOS está #pv.
- *Icom IC-705*: magnífico portátil y receptor, pero 10 W con una antena de compromiso es muy poco para el CQ WW SSB. Solo como segundo equipo.

#truco[Elijas el que elijas, la diferencia entre ellos en el concurso es pequeña comparada con la que hay entre una buena y una mala antena. Si dudas, ahorra en la radio y gasta en la antena y los cascos.]

== La antena de la terraza <sec-antena>

Los acopladores internos solo corrigen hasta ROE 3:1: la antena tiene que estar *ya cerca de 50 Ω* en cada banda. Tres opciones habituales:

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

#nota[No se han podido verificar en esta guía modelos comerciales concretos ni sus precios (EFHW de MyAntennas o Chameleon, lazos de Ciro Mazzoni, verticales Diamond, Hy-Gain o Comet), ni las pérdidas de los coaxiales (RG-213, Aircell 7, Ecoflex 10) según sus hojas de datos: #pv. Al elegir, comprueba la potencia admitida *en SSB con ciclo de concurso*, no solo la de pico.]

== Accesorios

- *Cascos con micrófono de pértiga*: cerrados (aíslan del ruido de la casa y no realimentan el micro) y con un micro de respuesta orientada a la voz. Necesitarás un adaptador al conector de micrófono de la radio; el tipo exacto de conector y si el micro electret necesita polarización dependen del modelo #pv.
- *Pedal de PTT*: va a la toma de PTT o SEND de la radio, o al adaptador del casco #pv para cada equipo. Libera las manos para teclear el log.
- *Fuente de alimentación*: 13,8 V y al menos 25 A continuos (mejor 30 A), de bajo ruido de radiofrecuencia: algunas conmutadas meten ruido en HF. Compruébalo escuchando con la fuente encendida y apagada (con batería).
- *Medidor de ROE/vatímetro y carga ficticia* de 100 W: para ajustar sin radiar y medir la potencia real (≤ 100 W en baja potencia). Las radios muestran la ROE en pantalla #pv.
- *Filtro paso bajo* a la salida: reduce armónicos que pueden molestar a la TV de los vecinos; la Orden pide usar los filtros «que sean precisos».

== Cómo no molestar a los vecinos (ni a ti mismo)

Prácticas habituales para evitar interferencias en HF (las guías de referencia son las de la ARRL, la RSGB y la de K9YC sobre RFI y ferritas; sus URL están #pv):

+ *Choke de modo común* (ferrita de mezcla 31) en el punto de alimentación de la antena y otro a la entrada del cuarto.
+ *Antena lo más lejos posible* del cableado de tu casa y de las viviendas vecinas; el coaxial, sin ir en paralelo a cables de red o de TV.
+ *Ferritas en los cables* de USB, audio y alimentación del cuarto, y todo el equipo referido a una misma masa.
+ *Filtro paso bajo* a la salida del transceptor y filtros de red donde haga falta.
+ *Prueba antes del concurso*: con poca potencia y subiendo, con un vecino colaborador, y anota los resultados. Los equipos permiten bajar a 0,6 W (IC-7300MK2) o 5 W (FT-710).
+ *Avisa* a los vecinos del fin de semana del concurso y ofrece ayuda si notan algo.

Recuerda que la responsabilidad legal de eliminar una interferencia es tuya (apartado @sec-licencia-estacion y capítulo @cap-legal).

== Presupuesto

#larga[#figure(
  caption: [Presupuesto con precios vistos el 20 de octubre de 2026. Solo los transceptores tienen precio verificado; el resto, #pv.],
  tabla(
    columns: (auto, 2.4fr, auto, 1.1fr),
    table.header([Opción], [Artículo], [Precio], [Tienda (fecha)]),
    ..("minima", "recomendada").map(op => {
      let filas = budget.filter(r => r.opcion == op)
      let con = filas.filter(r => r.precio_eur != "")
      let sin = filas.filter(r => r.precio_eur == "")
      (
        ..con.map(r => (
          if op == "minima" [mínima] else [recomendada],
          r.articulo,
          [#coma(r.precio_eur) €],
          if r.verificado == "si" [#r.tienda (#r.fecha_precio)] else [#r.tienda #pv],
        )).flatten(),
        if op == "minima" [mínima] else [recomendada],
        [Resto: #sin.map(r => r.articulo).join("; ").],
        [—],
        pv,
      )
    }).flatten(),
  ),
) <tab-presupuesto>]

Con el transceptor como única partida verificada, la estación mínima parte de *1.099 €* (FT-710 Field) y la recomendada de *1.549 €* (IC-7300MK2). El resto del presupuesto queda #pv\; antes de comprar, pide precio en las tiendas españolas e incluye el envío y el IVA del 21 %.

#fuentes("soft-wfview-rig-ic7300mk2", "soft-hamlib-riglist", "equip-icomamerica-7300mk2", "equip-icomamerica-7300mk2-unveil", "equip-icomuk-7300mk2-advanced", "equip-wimo-7300mk2", "equip-yaesu-ft710", "equip-yaesuuk-ft710", "equip-qst-ft710", "equip-manualslib-ft710", "equip-icomamerica-705", "equip-manualslib-ic705-voicetx", "equip-passion-ft710", "equip-passion-ic705", "equip-wimo-ic705", "equip-tutienda-ft710field", "legal-orden-iet-1311-2013")
]
