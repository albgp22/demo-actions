# Antena para la terraza (CQ WW DX SSB 2027): opciones con datos verificados

Fecha de consulta: **2026-10-20**. Ámbito: monooperador de baja potencia (100 W) en 160, 80, 40, 20, 15 y 10 m, con una sola antena de compromiso en la terraza de un piso de Madrid. Equipo: IC-7300MK2 o FT-710 AESS. Sus acopladores internos solo corrigen hasta ROE ≈ 3:1 (16,7–150 Ω, ver `data/equipment/facts.md`).

Ficheros de este directorio:

- `antenas.csv`: un artículo por fila (84 filas), con precio, tienda y estado de verificación.
- `refs.yml`: 123 referencias Hayagriva con prefijo `ant-`.
- Este documento: resumen por opción, pros y contras, y análisis de la recomendación.

Las citas tienen la forma [@clave](URL).

---

## 0. Método, leyenda y limitaciones

- **Fuentes.** Todo sale de resúmenes de WebSearch: 40 búsquedas, el cupo completo. WebFetch y curl no llegan a estas webs (p. ej. `myantennas.com` da ENOTFOUND), así que **no se ha abierto ninguna página ni ningún PDF directamente**. Las cifras de manuales y hojas de datos son las que citaba el resumen del buscador.
- **verificado = «si»**: el dato aparece en el resumen de un resultado cuya URL es la fuente primaria (fabricante o tienda) y, si hay precio, el precio se ve en esa ficha.
- **verificado = «no»** en estos casos: ficha antigua (indexada hace cientos de días), producto marcado como no disponible, precio que el resumen no ata a una URL concreta, reseña o foro, o ningún dato confirmado.
- **Filas sin precio.** Llevan «si» cuando el estado o las especificaciones salen de la fuente primaria (AH-4 descatalogado, Spiderbeam 12 m XHD). Un `precio_eur` vacío significa siempre que no hay precio verificado.
- **Fecha de los precios.** Son los que mostraba el resumen el 2026-10-20. La fecha real de cada ficha se desconoce y puede ser anterior.
- **`precio_eur`.** Es el precio en euros que muestra la tienda; si la tienda da un rango o un «desde», el mínimo.
  - Si la moneda original es USD o GBP, es una conversión al cambio de referencia del BCE del 19-10-2026: 1 € = 1,1225 USD y 1 € = 0,84205 GBP [@ant-bce-cambio](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html).
  - El PDF diario del 13-10-2026 daba 1,1188 USD y 0,84460 GBP [@ant-bce-eurofxref-pdf](https://www.ecb.europa.eu/stats/shared/pdf/eurofxref.pdf), y el resumen avisaba de una posible incoherencia en la fecha de la página.
  - **La conversión no incluye envío, IVA de importación (21 %), aranceles ni gastos de despacho.**
- **WiMo (Alemania)** muestra los precios con el IVA alemán del 19 %. En todas sus fichas consultadas el cociente bruto/neto es exactamente 1,19. Si a un cliente en España le aplica el IVA español, el precio sería neto × 1,21: se indica como [CÁLCULO] y queda **POR VERIFICAR** en el carrito.
- **Reino Unido** (Ham Radio UK, Radioworld, DX Commander): precios con IVA británico. Comprar desde España es importar, con IVA y despacho a cargo del comprador (importes **POR VERIFICAR**).
- **Leyenda**:
  - [FABRICANTE]: web, ficha o manual del fabricante.
  - [TIENDA]: ficha de tienda.
  - [TERCEROS]: reseña, opinión de usuarios o Wikipedia.
  - [CÁLCULO]: cálculo propio reproducible.
  - **POR VERIFICAR**: dato no confirmado.

---

## 1. Resumen de opciones

| Opción | 160 | 80 | 40 | 20 | 15 | 10 | Coste orientativo (piezas verificadas) |
|---|---|---|---|---|---|---|---|
| **A1.** Hilo vertical en caña + **Icom AH-730** (con IC-7300MK2) | sí (≥ 7 m de hilo) | sí | sí | sí | sí | sí | ≈ 710–760 € [CÁLCULO, §7] |
| **A2.** Hilo + **Yaesu FC-40** (con FT-710) | solo con ≥ 20 m de hilo | sí | sí | sí | sí | sí | ≈ 480–495 € [CÁLCULO, §7] |
| **A3.** Hilo + **LDG RT-100** (cualquier equipo) | rango 1,8–54 MHz; longitud mínima no publicada | sí | sí | sí | sí | sí | ≈ 597 € [CÁLCULO, §7] |
| **B.** EFHW de 40 m (80–10 m) | no | sí | sí | sí | sí | sí | desde 119,79 € más choke y coaxial |
| **B'.** EFHW de 19–20 m (40–10 m) | no | no | sí | sí | sí | sí | ≈ 174 € más importación (MyAntennas) |
| **C.** Vertical comercial | no (ninguna) | según modelo | sí | sí | sí | sí | 158–890 € |
| **D.** Lazo magnético de 100 W | no | solo Midi Loop | sí | sí | según modelo | según modelo | 1.419–1.775 € cada lazo |

Ningún producto resonante verificado cubre 160 m. **Solo el acoplador remoto en la base (opción A) permite trabajar las seis bandas con una sola antena.**

---

## 2. Opción A: hilo vertical en caña de fibra con acoplador remoto en la base

### 2.1 Icom AH-730 (para el IC-7300MK2)

- **Existe** y es el sucesor del AH-4. Icom UK dice que el AH-4 ya no está disponible y recomienda el AH-730 como producto similar [FABRICANTE [@ant-icomuk-ah4](https://icomuk.co.uk/AH-4-automatic-antenna-tuner/4051/981/41/)].
- **Cobertura**: 1,8–54 MHz con un hilo de 7 m o más. Icom afirma que con 7 m o más se puede adaptar en todas las bandas de 160 a 6 m [FABRICANTE [@ant-icomfrance-ah730-doc](https://www.icomfrance.com/uploads/files/produit/doc-AH-730-en.pdf)]. Con el elemento opcional AH-2b (2,5 m) cubre 3,5–54 MHz [FABRICANTE, copia del manual [@ant-icom-ah730-manual-copia](https://www.outbackmarine.com.au/assets/files/Manufacturers/ICOM/ico_AH730_Manual.pdf)].
- **Potencia y funcionamiento** [FABRICANTE [@ant-icomfrance-ah730-doc](https://www.icomfrance.com/uploads/files/produit/doc-AH-730-en.pdf)]:
  - Admite 150 W PEP y 100 W continuos; entrada de 50 Ω con conector SO-239.
  - Sintoniza con 5–15 W (10 W nominales) y se alimenta a 13,8 V desde el transceptor.
  - Tarda 2–3 s de media (15 s como máximo). Guarda 45 memorias, y volver a una frecuencia memorizada lleva ≈ 1 s.
  - Durante la sintonía solo radia 0,3 W. Protección IPX4.
- **Compatibilidad**:
  - Icom Japan lista IC-7760, IC-7610, IC-7300MK2, IC-7100, IC-718 e IC-7300. **El IC-705 no figura.** Usa el cable de control apantallado OPC-1465, el mismo que trae el AH-730 [FABRICANTE [@ant-icomjapan-ah730](https://www.icomjapan.com/lineup/options/AH-730/)].
  - Icom France lo incluye entre los accesorios del IC-7300MK2, con el cable de control de **10 m incluido** [FABRICANTE [@ant-icomfrance-7300mk2](https://www.icomfrance.com/en/produit/IC-7300MK2.php)].
  - WiMo: compatible con los Icom que tienen toma de acoplador de 4 pines [TIENDA [@ant-wimo-ah730](https://www.wimo.com/en/icom-ah-730-automatic-tuner-waterproof-outdoor)].
  - **FT-710**: la lista de compatibilidad solo incluye equipos Icom, así que no cuenta como opción para el Yaesu (deducción de la lista).
  - **IC-705**: no figura en la lista y tiene su propio AH-705 (10 W como máximo, 356,95 € en Astro Radio [TIENDA [@ant-astroradio-ah705](https://www.astroradio.com/p/ah-705/)]). La combinación AH-730 + IC-705 está **POR VERIFICAR** con Icom.
- **Con 100 W**: FB News, la revista de Icom, comenta que el AH-730 puede usarse con un equipo de 100 W como el IC-7300 y que sus 150 W dejan margen incluso para FT8 a 100 W [FABRICANTE (revista) [@ant-fbnews-ah730](https://fbnews.jp/202205/w_technicalsegment/)].
- **Instalación**:
  - Icom exige una **toma de tierra** [FABRICANTE [@ant-icomuk-ah730](https://icomuk.co.uk/AH-730-Automatic-Antenna-Tuner/4051/1480/41/), [@ant-icomjapan-ah730](https://www.icomjapan.com/lineup/options/AH-730/)].
  - El manual se descarga en [@ant-icomjapan-ah730-manual](https://www.icomjapan.com/support/manual/3577/), pero no se pudo leer. Quedan **POR VERIFICAR** cuántos radiales o contrapesos poner y de qué longitud en una terraza, y si hay longitudes de hilo que conviene evitar.
  - Para el AH-705, Icom dice que un hilo largo en el borne GND puede servir de contrapeso [FABRICANTE [@ant-icomuk-ah705-manual](https://icomuk.co.uk/files/icom/PDF/productManual/AH-705_ENG_IM_0.pdf)], pero eso no se ha confirmado para el AH-730.
- **Distancia al equipo**: el cable de control incluido mide 10 m. Si el cuarto queda más lejos de la base, hace falta un cable más largo o un alargador, **POR VERIFICAR** (el resumen no da precio del OPC-1465 suelto).
- **Precio**:
  - WiMo: **498,00 €** con IVA alemán (neto 418,49 €), en stock con envío en 1–2 días. Con IVA español serían 506,37 € [CÁLCULO] [TIENDA [@ant-wimo-ah730](https://www.wimo.com/en/icom-ah-730-automatic-tuner-waterproof-outdoor)].
  - La Tienda del Radioaficionado: 678,21 € (antes 713,90 €). La URL de esa ficha es la del antiguo AH-4 y el mismo importe aparece en otras páginas asociado al AH-4, así que es **no verificado** [@ant-ltdr-ah730](https://www.tutiendaderadio.com/es/home/3893-ah-4-acoplador-de-antena-icom.html).
  - Astro Radio, Proyecto 4, Radiomanía, Aimasstore y Ondamania no mostraron el AH-730 en los resultados.

### 2.2 Icom AH-4

Está descatalogado [FABRICANTE [@ant-icomuk-ah4](https://icomuk.co.uk/AH-4-automatic-antenna-tuner/4051/981/41/)]. Proyecto 4 conserva la ficha (3,5–54 MHz, 120 W), pero sin precio visible en el resumen [TIENDA [@ant-proyecto4-ah4](https://www.proyecto4.com/acopladores-de-antena/3685-acoplador-de-antena-icom-ah-4.html)]. **No cubre 160 m**, así que aunque se encuentre de segunda mano no sirve para este plan.

### 2.3 Yaesu FC-40 (para el FT-710)

- **Compatibilidad**: Yaesu cita el FC-40 entre los accesorios compatibles del FT-710 [FABRICANTE [@ant-yaesu-ft710](https://www.yaesu.com/indexVS.cfm?cmd=DisplayProducts&ProdCatID=102&encProdID=615ADFEAB5EDBC65EBE1D64835F209DB&DivisionID=65&isArchived=0)]. La página de Yaesu UK solo nombra equipos antiguos (FT-950, FT-450, FT-857 y FT-897): su lista es antigua o incompleta [@ant-yaesuuk-fc40](https://www.yaesu.co.uk/fc-40/).
- **Cobertura según el manual**: 1,6–54 MHz con un hilo de **20 m o más** alimentado en un extremo, y 7–54 MHz con el látigo YA-007 de 2,5 m [FABRICANTE [@ant-yaesu-fc40-manual](https://www.yaesu.com/Files/4CB893D7-1018-01AF-FA97E9E9AD48B50C/FC-40_OM_ENG_EAD77X101.pdf)]. Yaesu UK da 1,8–54 MHz con un hilo de más de 66 ft (≈ 20 m).
- **Potencia y funcionamiento**: hasta 100 W, con un máximo de 3 minutos de transmisión continua. Sintoniza con 4–60 W en 8 s como máximo, guarda 200 memorias y es estanco para montaje exterior [FABRICANTE].
- **Precios**:
  - WiMo: 267,80 € con IVA alemán (neto 225,04 €; con IVA español serían 272,30 € [CÁLCULO]) [@ant-wimo-fc40](https://www.wimo.com/en/fc-40).
  - Ondamania: **281,60 €** con IVA, en stock [@ant-ondamania-fc40](https://www.ondamania.com/b2c/producto/yaesufc-40/1/acoplador-automatico-de-antena-yaesu-fc-40-compatible-con-ft-857-ft-897-).
  - La Tienda del Radioaficionado: 305,00 €, consultando disponibilidad [@ant-ltdr-fc40](https://www.tutiendaderadio.com/es/home/3947-acoplador-de-antena-yaesu-fc-40.html).
  - Proyecto 4: 314,60 €, pero una de sus páginas lo da como no disponible, así que es **no verificado** [@ant-proyecto4-fc40](https://www.proyecto4.com/acopladores-de-antena/640-yaesu-fc-40.html).
- **Lo que implica**:
  - Con una caña de 10–12 m en vertical pura, 160 m **no está garantizado**. Para llegar a los 20 m de hilo habría que hacer una L invertida, por ejemplo con unos 8 m de tramo horizontal desde la punta de una caña de 12 m hasta otro punto de la terraza. Es aritmética, no una recomendación del fabricante.
  - El límite de 3 minutos de transmisión continua no debería molestar en SSB, porque los CQ y los intercambios duran segundos [deducción].

### 2.4 LDG RT-100 + RC-100 (universal)

- **Especificaciones** [FABRICANTE [@ant-ldg-rt100](https://www.ldgelectronics.com/rt/rc-100)]:
  - Cobertura 1,8–54 MHz. Adapta 4–800 Ω (16–150 Ω en 6 m) y 16–3200 Ω con el balun 4:1 opcional; según su FAQ, aproximadamente hasta ROE 10:1 [@ant-ldg-support](https://www.ldgelectronics.com/support).
  - Potencia: 125 W de pico en SSB, 100 W en CW, 75 W en FT8 y 50 W en 6 m.
  - Se alimenta (12 V, 500 mA) y se controla **por el propio coaxial** con el RC-100 (bias-T): no necesita cable de control.
  - Más de 2000 memorias. Resistente al agua pero no sumergible. Funciona de −18 a +43 °C.
- **Precio**: 349,99 USD en LDG (≈ 311,80 € [CÁLCULO], sin envío ni impuestos) y **385,00 €** en WiMo con IVA alemán (neto 323,53 €), en stock [TIENDA [@ant-wimo-rt100](https://www.wimo.com/en/rt-100)].
- **Pros**: como no usa la toma de acoplador del equipo, en principio sirve con el FT-710 y con el IC-7300MK2 (deducción a partir de que todo va por el coaxial). Sus 125 W de pico en SSB dan margen con 100 W.
- **Contras**:
  - LDG **no publica longitud mínima de hilo**, así que 160 m con un hilo de 7–12 m queda **POR VERIFICAR**.
  - El límite de +43 °C puede superarse en una terraza de Madrid a pleno sol en verano. No afecta al concurso, que es en octubre, pero sí a una instalación fija.

### 2.5 mAT-TUNER mAT-40

- **Especificaciones** [FABRICANTE [@ant-mat-mat40-manual](http://www.mat-tuner.com/down/mAT-40_Operation_manual_v1_en.pdf), [@ant-mat-mat40](http://www.mat-tuner.com/mAT-40.php)]:
  - Admite 120 W PEP.
  - Cobertura: 1,6–54 MHz según las fichas y 1,8–54 MHz según el manual (versión del 29-08-2025).
  - Hilo mínimo de **2,5 m**, aunque por debajo de esa longitud no se garantiza la adaptación en bandas bajas; para el mejor resultado recomienda **12 m**.
  - Incluye un cable de control de 10 m. El cable para cada marca es opcional: mAT-40-M para Icom con toma de 4 pines y mAT-40-Y para Yaesu.
- **Compatibilidad**: los resultados no nombran ni el FT-710 ni el IC-7300MK2, así que queda **POR VERIFICAR**.
- **Precio**: 298,00 € en WiMo [@ant-wimo-mat40](https://www.wimo.com/en/mat-40), más caro que el FC-40 en la misma tienda, y 199,99 £ (≈ 237,50 € [CÁLCULO], con importación aparte) en Ham Radio UK [@ant-hruk-mat40](https://www.hamradio.co.uk/mat40). Ondamania también lo vende, pero el resumen no muestra el precio [@ant-ondamania-mat40](https://www.ondamania.com/b2c/producto/hr_mat_40/1/acoplador-automatico-de-antena-mat-40-de-1-6-54-mhz-120-w-compatible-kenwood-yaesu-e-icom).

### 2.6 Cañas de fibra para el hilo vertical

| Caña | Extendida / plegada | Peso | Precio | Fuente |
|---|---|---|---|---|
| Spiderbeam 12 m HD (MF12) | 12 m / 1,18 m; base 55 mm, punta 8 mm, 12 tramos | 3,3 kg (ficha); 3,6 kg (campo de peso) | 95,00 € (IVA alemán), envío aparte | [@ant-spiderbeam-12hd](https://shop.spiderbeam.com/en/shop/spiderbeam-12m-fiberglass-pole-hd-1764), [@ant-spiderbeam-12hd-info](https://www.spiderbeam.com/product_info.php?info=p3_Spiderbeam+HD+12m+fiberglass+pole.html) |
| Spiderbeam 12 m HD con abrazaderas (SET1) / con abrazaderas y cinturón de vientos (SET2) / con ojal | 12 m | — | 110,00 € / 118,00 € / 100,00 € | [@ant-spiderbeam-12hd-set1](https://shop.spiderbeam.com/en/shop/package-1-spiderbeam-12m-fiberglass-pole-hd-clamps-kit-1766?category=101), [@ant-spiderbeam-12hd-set2](https://shop.spiderbeam.com/en/shop/package-2-spiderbeam-12m-fiberglass-pole-hd-clamps-guy-belt-1767), [@ant-spiderbeam-12hd-eyelet](https://shop.spiderbeam.com/en/shop/spiderbeam-hd-e-12m-fiberglass-pole-eyelet-version-1765) |
| Spiderbeam 10 m Mini (MM10) | 10 m / 0,72 m | — | 69,00 € | [@ant-spiderbeam-10mini](https://shop.spiderbeam.com/en/shop/spiderbeam-10m-mini-fiberglass-pole-1744) |
| Spiderbeam 7 m (con ojal) | 7 m | — | 55,00 € (**no verificado**: modelo y URL dudosos) | [@ant-spiderbeam-categoria](https://shop.spiderbeam.com/en/shop/category/fiberglass-poles-73) |
| Spiderbeam 12 m XHD | 12 m; punta de 17 mm; hasta 1 kg en la punta | 5,0 kg | sin precio en el resumen | [@ant-spiderbeam-12xhd](https://shop.spiderbeam.com/en/shop/spiderbeam-12m-xhd-pole-2393?page=3&search=12m) |
| Cgantenna 10 m reforzado | 10 m / 1,15 m; 9 tramos | 1,7 kg | **81,07 €** con IVA, envío gratis | [@ant-astroradio-cg10](https://www.astroradio.com/p/mstil_telescpico_de_fibra_de_vidrio_10m/) |
| Cgantenna 12 m | 12 m / 1,13 m; 12 tramos | 1,9 kg | **70,18 €** con IVA, envío gratis; entrega en 2–3 semanas (ficha quizá antigua) | [@ant-astroradio-cg12](https://www.astroradio.com/p/mstil_telescpico_de_fibra_de_vidrio_12m/) |
| DX-Wire GFK-10X / GFK-13X | 10 m / 13,7 m | 3,4 kg (GFK-10X) | 81,35 € / 96,59 € | [@ant-proyecto4-dxwire](https://www.proyecto4.com/mastiles-telescopicos-c-230/marca-dx_wire) (la ficha [@ant-proyecto4-gfk10m](https://www.proyecto4.com/mastiles-telescopicos/1180-mastil-telescopico-dx-wire-fibra-de-vidrio-gfk-10m.html) se titula «GFK-10M»: confirmar el modelo) |
| HARDFIBER10 | 10 m | — | 114,00 € | [@ant-ltdr-hardfiber10](https://www.tutiendaderadio.com/es/home/4569-hardfiber10-mastil-telecopico-10-metros-en-fibra-de-vidrio.html) |
| MFJ-1906H | 13,11 m; pared de 3 mm | 5,9 kg | 278,30 € (existencias: MFJ ya no fabrica) | [@ant-astroradio-mfj1906h](https://www.astroradio.com/en/p/mfj_1906h_mstil_telescpico_de_fibra_de_vidrio_de_10_mts/) |

Spiderbeam dice que su punta de 8 mm aguanta la caña extendida del todo y que en sus pruebas sostuvo en la punta un dipolo en V invertida de 80 m de hilo de 1 mm. La caña estándar no trae herrajes de vientos, que se venden en kits [FABRICANTE [@ant-spiderbeam-12hd-info](https://www.spiderbeam.com/product_info.php?info=p3_Spiderbeam+HD+12m+fiberglass+pole.html)].

### 2.7 Qué longitud de hilo conviene [CÁLCULO]

**Eficiencia en bandas bajas.** El modelo es la función `vertical()` de `scripts/equip_eficiencia.py`, sin modificarla:

- R_rad = 395 (h/λ)², reactancia X = Z₀·cot(βh) y pérdida del acoplador X/Q con Q = 150 (supuesto).
- Hilo de 1 mm de radio. La tabla del capítulo 9 usaba un tubo de 30 mm, por eso sus cifras para 7 m son algo mejores.
- Dos escenarios de pérdidas de tierra: 5 Ω (radiales elevados bien hechos) y 15 Ω.

| Hilo vertical | Tierra | 160 m | 80 m | 40 m |
|---|---|---|---|---|
| 7 m | 5 Ω | 4,1 % (−13,9 dB) | 21,4 % (−6,7 dB) | 60 % (−2,2 dB) |
| 7 m | 15 Ω | 2,6 % (−15,8 dB) | 12,4 % (−9,1 dB) | 39 % (−4,1 dB) |
| 8 m | 5 Ω | 5,7 % (−12,5 dB) | 27,7 % (−5,6 dB) | 68 % (−1,7 dB) |
| 8 m | 15 Ω | 3,6 % (−14,5 dB) | 16,1 % (−7,9 dB) | 46 % (−3,4 dB) |
| 10 m | 5 Ω | 9,8 % (−10,1 dB) | 40,3 % (−3,9 dB) | 80 % (−1,0 dB) |
| 10 m | 15 Ω | 5,9 % (−12,3 dB) | 24,1 % (−6,2 dB) | 59 % (−2,3 dB) |
| 12 m | 5 Ω | 14,8 % (−8,3 dB) | 51,9 % (−2,8 dB) | ≥ λ/4: el modelo no aplica |
| 12 m | 15 Ω | 8,8 % (−10,6 dB) | 32,5 % (−4,9 dB) | — |

**Ángulo de salida en bandas altas.** Monopolo ideal sobre tierra perfecta, con corriente sinusoidal: F(θ) = [cos(kh·cos θ) − cos kh] / sin θ. La tabla da la directividad a 10° de elevación. Como referencia, un monopolo de λ/4 da 5,0 dBi.

| Hilo | 20 m | 15 m | 10 m |
|---|---|---|---|
| 7 m | 5,3 dBi (0,33 λ) | 6,3 dBi (0,50 λ: media onda) | 6,5 dBi (0,67 λ) |
| 8 m | 5,5 dBi (0,38 λ) | 6,9 dBi (0,57 λ) | −0,9 dBi (0,76 λ; lóbulo principal a ≈ 47°) |
| 10 m | 6,1 dBi (0,47 λ: casi media onda) | 4,2 dBi (0,71 λ; nulo hacia 24°) | −7,5 dBi (0,95 λ: casi onda completa; lóbulo a ≈ 35°) |
| 12 m | 6,9 dBi (0,57 λ) | nulo hacia 10° (0,85 λ; lóbulo a ≈ 40°) | −7,3 dBi (1,14 λ; lóbulo a ≈ 27°) |

Qué se deduce:

- Un hilo más largo mejora 160 y 80 m (de 7 a 12 m se ganan unos 5 dB en 160 m), pero **en 15 y 10 m sube el ángulo de salida**, justo cuando más importan los ángulos bajos para el DX.
- Las longitudes de media onda (7,04 m en 15 m; 10,56 m en 20 m; y 10,52 m, una onda completa, en 10 m) dan impedancias muy altas en la base. Que eso dé problemas al AH-730 es un principio general: Icom afirma que adapta todas las bandas con 7 m o más, así que queda **POR VERIFICAR** en su manual.
- No hay una longitud perfecta. Para la guía, una caña de 10–12 m extendida solo hasta la longitud elegida permite probar en la terraza, mirando la ROE en la pantalla del equipo.
- El tejado, la barandilla y el hormigón no están modelados. Las cifras sirven para comparar longitudes, no son valores absolutos.

### 2.8 Pros y contras en una terraza de Madrid con 100 W

- **Pros**:
  - Es la única opción verificada para las seis bandas con una sola antena.
  - Ocupa una caña de 1,1–1,2 m plegada más los radiales.
  - Cambia de banda en ≈ 1 s desde memoria (AH-730), algo útil en búsqueda y llamada y en los cambios de banda del concurso.
  - Las potencias nominales cubren los 100 W en SSB: AH-730 150 W PEP, RT-100 125 W, FC-40 100 W.
- **Contras**:
  - Muy poca eficiencia en 160 m (3–15 %) y moderada en 80 m, según la tierra o los radiales (Icom exige tierra).
  - Una caña de 10–12 m se ve y recibe viento: necesita vientos o abrazaderas (kits Spiderbeam) y, posiblemente, permiso de la comunidad (ver `data/legal/`).
  - El cable de control del AH-730 mide 10 m.
  - El radiador queda cerca de personas y viviendas: hay que revisar las distancias de exposición de `data/legal/rf_exposure_distances.csv` y el riesgo de interferencias.

---

## 3. Opción B: EFHW multibanda (media onda alimentada en un extremo)

### 3.1 MyAntennas (EE. UU.)

| Modelo | Bandas | Potencia | Longitud | Precio (fabricante) |
|---|---|---|---|---|
| EFHW-8010 | 80/40/30/20/17/15/12/10 m, sin acoplador | 1 kW ICAS en voz; 250 W en digitales | ≈ 39,6 m (130 ft) | 214,99–249,99 USD (≈ 191,53–222,71 €) [@ant-myantennas-efhw8010](https://myantennas.com/wp/product/efhw-8010/) |
| EFHW-8010-LP | 80–10 m | 250 W ICAS | no consta | 149,00–183,99 USD [@ant-myantennas-efhw8010lp](https://myantennas.com/wp/product/efhw-8010-lp/) |
| EFHW-4010 | 40/20/15/10 m | 1 kW ICAS; 250 W en digitales | ≈ 19,2 m (63 ft) | 194,99–229,99 USD (≈ 173,71 €) [@ant-myantennas-efhw4010](https://myantennas.com/wp/product/efhw-4010/) |
| EFHW-4010-LP | 40/20/15/10 m | 250 W ICAS | no consta | 139,00–173,99 USD [@ant-myantennas-efhw4010lp](https://myantennas.com/wp/product/efhw-4010-lp/) |
| EFHW-4010-P (kit portátil) | 40/20/15/10 m | 200 W ICAS; 100 W en digitales | no consta | 119,99 USD [@ant-myantennas-efhw4010p](https://myantennas.com/wp/product/efhw-4010p/) |
| EFHW-4010-1K-ICAS | 40/20/15/10 m | 1 kW ICAS | no consta | 118,99–143,49 USD (30 % de descuento) [@ant-myantennas-efhw4010-1k](https://myantennas.com/wp/product/efhw-4010-1k-icas/) |

- La página de categoría muestra otros importes (EFHW-8010 a 204,99–239,99 USD) [@ant-myantennas-categoria](https://myantennas.com/wp/product-category/antennas/efhw-multi-band/).
- Hay variantes de 2 kW de otros modelos: EFHW-7510-2K-Plus [@ant-myantennas-efhw7510-2k](https://myantennas.com/wp/product/efhw-7510-2k-plus/) y MEF-130-2K-Plus [@ant-myantennas-mef130](https://myantennas.com/wp/product/mef-130-2k-plus/). Una «EFHW-8010-2K+» a 294,99 USD solo apareció en un anuncio de eBay que no se pudo identificar entre los resultados: **no verificado**.
- **No hay precio en la UE**: hay que importar desde EE. UU. (envío, IVA y despacho **POR VERIFICAR**).

**Instalación según el fabricante** [FABRICANTE [@ant-myantennas-manual](https://myantennas.com/wp/wp-content/uploads/2021/08/Installation-Manual-EFHW-antennas.pdf), [@ant-myantennas-manual-8010-1k](https://myantennas.com/wp/wp-content/uploads/2015/11/Manual-EFHW-8010-1K.pdf)]:

- **Altura mínima**: 20 ft (≈ 6 m) en todos los puntos para la 8010 y 10 ft (≈ 3 m) para la 4010. Lo mismo vale en L o en U invertidas, con el tramo vertical empezando al menos a 1 m del suelo.
- **Contrapeso**: según el fabricante no hace falta ningún «rabillo» colgando del borne de tierra. Recomienda conectar a tierra ese borne, junto al SO-239, o, si el cable de tierra fuera largo, poner a tierra el coaxial en la estación.
- **Coaxial como contrapeso** (modelo EFLW-3K): funciona sin radiales si el coaxial mide al menos 25 ft (≈ 7,6 m) [@ant-myantennas-eflw3k](https://myantennas.com/wp/product/eflw-3k/).
- **Choke**: el modelo MEF-130-2K-Plus se vende «sin tierra ni contrapeso», solo con un choke de 7 ferritas de pinza en el cuarto [@ant-myantennas-mef130](https://myantennas.com/wp/product/mef-130-2k-plus/).
- **Opiniones de usuarios** en la web del fabricante [TERCEROS]: un comprador de la 4010 no lograba ajustar 10 m hasta que puso un choke en el punto de alimentación. La ficha de la 4010-P recomienda poner a tierra el coaxial donde entra en la vivienda, para descargar la estática.

### 3.2 EFHW en tiendas españolas y de la UE

| Antena | Bandas | Potencia | Longitud | Precio | Fuente |
|---|---|---|---|---|---|
| Dxpatrol END-FEED 10 m a 80 m | 80–10 m | 1000 W SSB/CW; 250 W FT8/RTTY | 40 m | **119,79 €**, envío gratis | [@ant-astroradio-dxpatrol-endfeed](https://www.astroradio.com/p/antena-end-feed-10m-a-80m/) |
| Momobeam EF1080 | 80/40/20/15/10 m | 300 W | no consta | 229,90 €, envío gratis (otra página: 164,56 €) | [@ant-astroradio-ef1080](https://www.astroradio.com/p/antena-endfeed-ef1080-10-15-20-40-80-300w/) |
| Momobeam EF1080C | 80/40/20/15/10 m | 1 kW | no consta | 329,12 € | [@ant-astroradio-ef1080c](https://www.astroradio.com/p/antena-endfeed-ef1080c-10-15-20-40-80-1kw/) |
| Dxpatrol EZWIRE | bandas **POR VERIFICAR** | 500 W (1 kW en la versión 1KW) | 16 m | 93,17 € | [@ant-astroradio-ezwire](https://www.astroradio.com/p/antena-ezwire/) |
| WiMo EFHW (hasta 1 kW) | 80/40/20/15/10 m, versión acortada | 1 kW PEP | 23 m | 99–266 € (**no verificado**: ficha de hace ~900 días) | [@ant-wimo-efhw](https://www.wimo.com/en/wimo-end-fed-wire-antenna) |
| Chameleon LEFS 8010 | 80–10 m | 500 W SSB; 150 W digitales | 680 g | 266,40 € (**no verificado**: posible ficha antigua) | [@ant-wimo-lefs8010](https://www.wimo.com/en/chameleon-lefs-8010) |
| HyEndFed de 8 y de 5 bandas | 80–10 m | — | — | 209 € / 189 €: WiMo las marca **no disponibles** | [@ant-wimo-hyendfed-8band](https://www.wimo.com/en/11345-8al), [@ant-wimo-hyendfed-5band](https://www.wimo.com/en/11345-84251) |
| CG-Antenna BL-49 (unun 1:49 para una EFHW propia) | 1,8–30 MHz | 1000 W PEP | — | 109,00 € (IVA alemán) | [@ant-wimo-bl49](https://www.wimo.com/en/bl-49) |

Más datos de las EFHW de tienda:

- **Dxpatrol** [TIENDA]: según la ficha, la toma de tierra es opcional y mejora la eficiencia en las bandas bajas, y la caja del balun es resistente al agua.
- **Momobeam EF1080** [TIENDA]: se monta en horizontal, en L invertida o inclinada.
- **HyEndFed** (Países Bajos): su web no dio precios de las multibanda en los resultados; solo una monobanda HP de 80 m (2000 W) a 386,79 USD [@ant-hyendfed-web](https://hyendfed.com/antenna/multiband_100_watt/product/detail/119/www.hyendfed.com). Precio y disponibilidad actuales: **POR VERIFICAR** ([@ant-wimo-hyendfed-marca](https://www.wimo.com/en/brand/hyendfed)).
- **Passion Radio**: no se encontró ninguna EFHW de 80–10 m para 100–200 W.

Alternativas de hilo que no son EFHW:

- **D-Original DX-W-8010** (Windom): 80/40/20/17/12/10 m, 200 W, 42 m, balun 1:6. 117,50 € con IVA en Ondamania [@ant-ondamania-dxw8010](https://www.ondamania.com/b2c/producto/d_original_dx_w_1080/1/dipolo-de-hf-de-10-a-80-metros-d-original-dx-w-8010).
- **Diamond W8010** (dipolo con trampas): 80/40/20/15/10 m, 1,2 kW PEP. 175,00 € sin IVA en Passion Radio [@ant-passionradio-w8010](https://www.passion-radio.com/long-wire/w8010-113.html). Con IVA español del 21 % serían 211,75 € [CÁLCULO].
- Las dos se alimentan lejos del extremo y necesitan dos apoyos alejados.

### 3.3 Pros y contras en la terraza

- **Pros**:
  - Barata: desde 119,79 € en España.
  - No necesita acoplador externo: resuena en los armónicos, y el acoplador interno corrige las pequeñas desadaptaciones.
  - Con 100 W en SSB va sobrada de potencia (1 kW ICAS o 1000 W SSB; las LP admiten 250 W).
  - Eficiente si el hilo queda alto y despejado.
- **Contras**:
  - **No cubre 160 m.** Para 80 m necesita **≈ 40 m de hilo**, que casi nunca caben en una terraza. La de 40–10 m necesita ≈ 19–20 m.
  - Altura mínima de 6 m (8010) o 3 m (4010) según el fabricante.
  - El punto de alimentación queda en la terraza, junto a la vivienda, y la malla del coaxial forma parte del sistema: hace falta un choke y hay riesgo de RF en el cuarto y en los vecinos.

---

## 4. Opción C: verticales comerciales

- **Hy-Gain AV-640**:
  - 40/30/20/17/15/12/10/6 m; 1500 W (portadora continua 2 min); 25,5 ft (≈ 7,8 m) [FABRICANTE [@ant-hygain-av640](http://www.hy-gain.com/Product.php?productid=av-640), manual [@ant-wimo-av640-manual](https://www.wimo.com/media/manuals/MFJ/11284_AV-640_Vertikalantenne_Vertical-antenna.pdf)].
  - Precio: 449,95 USD en el fabricante; 749,95 £ (≈ 890,62 €) en Radioworld UK [@ant-radioworld-av640](https://www.radioworld.co.uk/amateur_radio_antenna/hf_base/hf-vertical-antenna/hy-gain-patriot-vertical-hf-antenna--av-640); 839,90 € en WiMo, marcada **no disponible** [@ant-wimo-av640](https://www.wimo.com/en/av-640).
  - **No cubre 80 ni 160 m.** Fabricación detenida: ver §5.3.
- **Hustler 5-BTV / 6-BTV** (verticales con trampas):
  - 5-BTV: 80/40/20/15/10 m, justo las cinco bandas altas del plan. 6-BTV: añade 30 m y la ficha la da para 1 kW.
  - Altura de ≈ 24 ft (5-BTV) y ≈ 25 ft (6-BTV) según el manual [@ant-dxe-btv-manual](https://static.dxengineering.com/global/images/instructions/dxe-btv-inst-ins_oh.pdf). Ham Radio UK da 7,3 m para la 6-BTV.
  - **Radiales: como mínimo 20 de 20 ft (≈ 6 m)**, según la guía de Hustler y DXE. En 80 m es estrecha.
  - Precios de la 5-BTV: 459,98 USD en DXE [@ant-dxe-5btv](https://www.dxengineering.com/parts/hsr-5btv); 359,95 £ (≈ 427,47 €) en Ham Radio UK [@ant-hruk-5btv](https://www.hamradio.co.uk/hustler-5-btv-pd-2795).
  - Precios de la 6-BTV: 349,99 £ en oferta (normal 399,95 £) en Ham Radio UK [@ant-hruk-6btv](https://www.hamradio.co.uk/6-btv); 499,98 USD en DXE [@ant-dxe-6btv](https://www.dxengineering.com/parts/hsr-6btv).
  - WiMo: serie BTV «desde» 403,00 €, sin decir qué modelo [@ant-wimo-btv](https://www.wimo.com/en/hustler-btv-vertical-multiband-antennas).
  - Veinte radiales de 6 m no caben en casi ninguna terraza. La alternativa con radiales elevados está **POR VERIFICAR** en el manual. No cubre 160 m.
- **DX Commander** (Reino Unido; precios en libras, con importación aparte):
  - Classic (40–2 m; 6, 4 y 2 m no garantizadas): 299 £ [@ant-dxc-classic](https://dxcommander.com/product/dx-commander-classic-multi-band-antenna/).
  - Classic + 80 m: 339 £ (lista 359 £). Hace 80 m como L invertida de ≈ 19,5 m e incluye la caña de 10 m y 100 m de hilo [@ant-dxc-classic80](https://dxcommander.com/product/classic-80m-kit/).
  - Expedition (40–6 m): 299 £ [@ant-dxc-expedition](https://dxcommander.com/product/dx-commander-expedition-kit/).
  - Radiales: **POR VERIFICAR**. Ningún modelo cubre 160 m.
- **Verticales de banda ancha sin radiales**:
  - **D-Original OUT-250B**: 3,5–57 MHz en TX; 250 W SSB (otra ficha dice 200 W); 7,13 m; 3 kg; ROE < 1,5. **158,00 €** con IVA en Ondamania [@ant-ondamania-out250b](https://www.ondamania.com/b2c/producto/d.originalout-250b/1/antena-d-original-out-250b-antena-vertical-de-hf-10-80-m-6-m). En La Tienda del Radioaficionado, 179 €, **no verificado** [@ant-ltdr-out250b](https://www.tutiendaderadio.com/es/home/4294-doriginal-out-250-b-antena-vertical-en-aluminio-de-35-57-mhz-altura-713-m.html). Hay versión de fibra OUT-250F (7,16 m) sin precio [@ant-ondamania-out250f](https://www.ondamania.com/b2c/producto/out-250-f/1/d-original-out-250f-antena-vertical-de-fibra-de-vidrio-fiberglass-de-3-5-a-57-mhz-con-7-16-mts).
  - **Comet CHA-250B**: según el resumen (especificaciones del fabricante y ficha de Radioworld), la familia da 3,5–57 MHz en TX y 2–90 MHz en RX, 250 W SSB, 23 ft 5 in (≈ 7,1 m), 7 lb 1 oz (≈ 3,2 kg), viento de 67 mph y sin radiales [@ant-radioworld-cha250b](https://www.radioworld.co.uk/comet_cha250b). A la venta aparecen la CHA-250BXII (349,96 £ en Ham Radio UK [@ant-hruk-cha250bxii](https://www.hamradio.co.uk/comet-cha-250bxii-hf-multiband-vertical-antenna-pd-14136)) y la CHA-250HD (PVP de 499,95 USD; 250 W SSB, 75 W en digitales; Comet la presenta como diseño actualizado de la CHA-250B [@ant-comet-cha250hd](https://www.cometantenna.com/product/comet_cha_250hd/)). La CHA-250B original solo aparece a 299,95 £ en una reseña sin fecha, **no verificado** [@ant-hruk-cha250b-review](https://www.hamradio.co.uk/userfiles/file/Comet-CHA250B-Review.pdf).
  - **Diamond BB7V**: 2–30 MHz (WiMo la titula 1,8–30 MHz); 250 W PEP; ≈ 6,7 m; necesita acoplador. 335,90 € en WiMo [@ant-wimo-bb7v](https://www.wimo.com/en/bb-7v); 299,95 £ en Ham Radio UK [@ant-hruk-bb7v](https://www.hamradio.co.uk/diamond-bb7v-pd-2520); 349,00 £ más envío en Radioworld [@ant-radioworld-bb7v](https://www.radioworld.co.uk/diamond-bb7v-hf-wideband-ground-plane-antenna-2---30mhz). Diamond indica conector M-J [@ant-diamond-bb7v](https://www.diamond-ant.co.jp/english/amateur/antenna/ante_2base/ante_base8.html).
  - **Eficiencia** [CÁLCULO cualitativo, no es un dato del fabricante]: un monopolo de 7 m tiene en 3,7 MHz una R_rad de solo ≈ 3 Ω (fórmula de §2.7). Para mostrar ≈ 50 Ω con ROE ≤ 1,5 entre 3,5 y 57 MHz sin sintonizar nada, casi toda la potencia en 80 m tiene que disiparse en la red de carga o terminación. Cabe esperar una eficiencia baja en 80 m. Ningún fabricante publica la cifra: **POR VERIFICAR** con mediciones.
- **Moonraker GPA-80** (80–6 m): 124,95 € en Ondamania [@ant-ondamania-gpa80](https://www.ondamania.com/b2c/producto/moonraker_gpa80/1/antena-vertical-de-hf-moonraker-gpa-80). El resumen solo da precio y bandas.

**Pros y contras en la terraza**:

- Las de banda ancha son las más cómodas: sin radiales, sin acoplador externo (OUT-250B y CHA-250) y a partir de 158 €. A cambio, previsiblemente rinden poco en 80 m y **ninguna da 160 m**.
- Las resonantes (Hustler, DX Commander) necesitan radiales que no caben en una terraza.
- La AV-640 no cubre las bandas bajas y su fabricación está detenida.

---

## 5. Opción D: lazos magnéticos

### 5.1 Ciro Mazzoni (para 100 W)

Precios en WiMo, con IVA alemán [@ant-wimo-ciromazzoni](https://www.wimo.com/en/brand/ciro-mazzoni):

- **Baby Loop**: 40–10 m (6,6–29,7 MHz), con control automático. **1.599,00 €**, en stock.
- **Stealth Loop**: 40–10 m, con ATU 2. **1.419,00 €**, disponible a partir del 15-10-2026.
- **Midi Loop**: 80–20 m, con unidad de control ATU 2.0. **1.775,00 €**.

En Ham Radio UK:

- Baby Loop: 1.699,96 £ (en otra página, 1.649,95 £) [@ant-hruk-babyloop](https://www.hamradio.co.uk/ciro-mazzoni-baby-loop-latest-version-pd-5797). Según su ficha admite 450 W hasta 21 MHz y 1 kW de 22 a 29,8 MHz.
- Midi Loop: 1.749,95 £, cobertura continua de 3,5 a 14,5 MHz [@ant-hruk-midiloop](https://www.hamradio.co.uk/ciro-mazzoni-midi-loop-new-version-pd-5798).
- Stealth Loop: 1.549,96 £ [@ant-hruk-stealthloop](https://www.hamradio.co.uk/stealth-loop).

Ningún lazo cubre 160 m. Para 80–10 m harían falta dos (Midi + Baby, unos 3.374 € en WiMo [CÁLCULO]) y seguiría faltando 160 m. Las estimaciones del capítulo 9 (`data/equipment/eficiencia_antenas.csv`) ya daban a un lazo de 1 m solo un 0,17 % de eficiencia en 160 m y un 1,9 % en 80 m.

### 5.2 Chameleon F-Loop

- **F-Loop 3.0**: admite **25 W en SSB** (intermitente) y 10 W continuos, o 60 W en SSB con el Power Compensator opcional [@ant-chameleon-floop3](https://chameleonantenna.com/products/cha-f-loop-3-0).
- Su precio era de 500–650 USD, pero el fabricante lo da por **descatalogado** [@ant-chameleon-loops-kb](https://chameleonantenna.com/pages/ckb-portable-magnetic-loop-systems), y WiMo lo marca no disponible (675,90 €) [@ant-wimo-floop](https://www.wimo.com/en/f-loop).
- Una ficha anuncia un F-Loop 4.0 para finales de 2026 (no verificado). **No sirve con 100 W.**

### 5.3 MFJ

- El 26-04-2024, MFJ anunció que dejaba de fabricar en Starkville el 17-05-2024. Afecta también a Ameritron, Hy-Gain, Cushcraft, Mirage y Vectronics [@ant-arrl-mfj](https://arrl.org/news/mfj-ceasing-on-site-production).
- WiMo informó de que se seguirían vendiendo las existencias y de que las reparaciones y los repuestos continuarían [@ant-wimo-mfj](https://www.wimo.com/en/blog/post/news-mfj-stops-production).
- Según Wikipedia, ITU Corporation (Linton, Indiana) anunció el 15-04-2026 la compra de las marcas Hy-Gain y Cushcraft, entre otras, con la producción prevista para finales de 2026 [TERCEROS [@ant-wikipedia-mfj](https://en.wikipedia.org/wiki/MFJ_Enterprises)]. Es una fuente única, **no verificada**.
- Los lazos MFJ, por tanto, solo se encuentran como existencias o de segunda mano.

**Pros y contras de los lazos en la terraza**: caben en cualquier sitio, pero cuestan entre 1.400 y 1.800 € cada uno, no dan 160 m, son estrechos (hay que resintonizar a menudo) y con 100 W el condensador soporta varios kV. **No se recomiendan para este plan.**

---

## 6. Choke de modo común y coaxial

### 6.1 Choke

- **K9YC** [@ant-k9yc-cookbook](http://k9yc.com/2018Cookbook.pdf), ver también [@ant-k9yc-rfi-ham](http://www.audiosystemsgroup.com/RFI-Ham.pdf):
  - Pide al menos 5 kΩ de impedancia de modo común en el punto de alimentación de toda antena de transmisión.
  - Su recetario de 2018 ya no incluye RG-8, RG-213, RG-11 ni RG-6: los chokes salen más pesados, caros y con más pérdida, y las vueltas son difíciles de repetir.
  - Usa RG-400 o hilo de teflón del n.º 12. El resumen citaba para 160–80 m dos chokes de 17 vueltas de RG-400 en serie (≈ 12 kΩ) y para 30–20 m dos de 10 vueltas (≈ 7 kΩ). La tabla extraída estaba desordenada: **comprobar en el PDF**.
  - El recetario usa un toroide «grande» de mezcla 31. Que sea del tamaño del FT-240 está **POR VERIFICAR**.
- **Para fabricarlo uno mismo**: toroide **FT-240-31** a **10,29 €** con IVA en Astro Radio, en stock. Mide 61,0 × 35,5 mm, y la ficha dice que el material 31 sirve para chokes de modo común de 1 a 50 MHz [@ant-astroradio-ft240-31](https://www.astroradio.com/p/toroide-de-ferrita-ft-240-31/). El RG-400 y los conectores no se han buscado.
- **Chokes hechos**:

  | Choke | Cobertura | Potencia | Precio | Comentario |
  |---|---|---|---|---|
  | Balun Designs 1115 | 1–31 MHz | 3 kW | 84,95 USD | ferrita «custom» de Fair-Rite, no dice 31 [@ant-balundesigns-1115](https://www.balundesigns.com/model-1115-1-1-balun-1-5-31-mhz-3kw/) |
  | Balun Designs 1116di | 1–31 MHz, optimizado para bandas bajas | 5 kW | 101,95 USD | [@ant-balundesigns-1116di](https://www.balundesigns.com/model-1116di-1-1-balun-low-band-optimized-1-31-mhz-5kw/) |
  | WiMo 1:1 | 3–50 MHz: **sin 160 m** | 1–4 kW PEP | desde 121,00 € | 30–50 dB de supresión [@ant-wimo-choke11](https://www.wimo.com/en/wimo-1-1-rf-choke) |
  | ASP AS-111500 | 1,8–30 MHz | 1,5 kW PEP | **54,45 €** | [@ant-proyecto4-as111500](https://www.proyecto4.com/balun/3999-balun-asp-11-as-111500.html) |
  | ASP AS-113000 | 1,8–30 MHz | 3 kW PEP | 90,75 € | [@ant-proyecto4-as113000](https://www.proyecto4.com/balun/4603-balun-asp-11-as-113000.html) |
  | Tagra JA-400 | 1,8–30 MHz | 1 kW PEP | 38,35 € | [@ant-ondamania-ja400](https://www.ondamania.com/b2c/producto/02egja400/1/balun-1-1-tagra-ja-400-de-1-8-a-30-mhz) |
  | D-Original BL-1011 | 1–50 MHz | 1 kW | 45,92 € (oferta) | [@ant-ondamania-bl1011](https://www.ondamania.com/b2c/producto/03flbl1011/1/d-original-bl-1011-balun-1-1-1-kw-1-50-mhz) |
  | Proyecto 4 CH-1 | 160–2 m | 1 kW | 36,30 € (**no disponible**) | ≈ 1 kΩ según el vendedor, por debajo de los 5 kΩ de K9YC [@ant-proyecto4-ch1](https://www.proyecto4.com/cables-coaxiales/1040-ch-1.html) |

  Ninguna ficha española publica la impedancia de modo común ni la mezcla de ferrita. Antes de comprar hay que confirmar que es un **balun de corriente** que sirva como aislador de línea, de coaxial a coaxial (**POR VERIFICAR**).

### 6.2 Coaxial

Precios por metro con IVA (la unidad se deduce del importe salvo en el RG-213 de Proyecto 4, donde es explícita):

| Cable | Precio por metro | Pérdida típica según la hoja de SSB | Pérdida de 20 m a 1,85 / 28,5 MHz [CÁLCULO] | Coste de 20 m [CÁLCULO] |
|---|---|---|---|---|
| RG-213 | 3,09 € en Proyecto 4 [@ant-proyecto4-rg213](https://www.proyecto4.com/cables-coaxiales/404-rg-213.html); 3,23 € en La Tienda del Radioaficionado [@ant-ltdr-masvendidos](https://www.tutiendaderadio.com/es/mas-vendidos); 3,40 € en Ondamania [@ant-ondamania-rg213](https://www.ondamania.com/b2c/producto/rg-213u/1/cable-coaxial-rg-213); rollo de 100 m de Messi & Paoloni a 246,84 € en Astro Radio [@ant-astroradio-rg213-100m](https://www.astroradio.com/p/cable_rg213u_plus_100m/) | sin hoja de datos (**POR VERIFICAR**) | — | 61,80 € |
| Aircell 7 | **4,36 €** en Proyecto 4 [@ant-proyecto4-aircell7](https://www.proyecto4.com/cables-coaxiales/779-aircell-7.html); 5,27 € en La Tienda del Radioaficionado | 1,52 / 2,09 / 4,29 dB/100 m a 5 / 10 / 50 MHz [@ant-ssb-aircell7-ds](https://www.ssb.de/media/6070_eng.pdf) | 0,19 / 0,67 dB | 87,20 € |
| Ecoflex 10 | 8,55 € en La Tienda del Radioaficionado; 6,78–7,05 € en Proyecto 4 (ficha «no disponible»: **no verificado**) [@ant-proyecto4-ecoflex10](https://www.proyecto4.com/cables-coaxiales/781-ecoflex-10.html) | 0,76 / 1,14 / 2,66 dB/100 m a 5 / 10 / 50 MHz [@ant-ssb-ecoflex10-ds](https://www.ssb.de/shop/download/Kabel/ENG/6080%20ENG.pdf) | 0,08 / 0,40 dB | 171,00 € |

Las pérdidas a 1,85 y 28,5 MHz se han interpolado en escala log-log entre los puntos de la hoja de datos; por debajo de 5 MHz es una extrapolación. Con tramos de 20 m o menos, la diferencia entre Aircell 7 y Ecoflex 10 es de 0,3 dB en 10 m, nada frente a los 6 dB de una unidad S. **Aircell 7 es la opción razonable**: flexible y a mitad de precio que el Ecoflex 10. Los conectores no se han buscado.

---

## 7. Análisis: qué combinación recomendar

Lo que manda es la lista de bandas: **160 m solo se consigue con un acoplador remoto en la base**. Para el resto, el capítulo 9 de la guía ya dice que conviene volcarse en 40–10 m y tomar 80 y 160 m como un extra.

**Si el equipo es el IC-7300MK2: recomendación principal, A1.**

- Piezas: AH-730, hilo vertical en una caña de 10–12 m (extendida hasta la longitud elegida, §2.7), toma de tierra y radiales, choke en la base y Aircell 7.
- Es la única combinación **oficial** de las verificadas que garantiza 160 m: 7 m de hilo, 150 W PEP y cable de control incluido.
- Coste con piezas verificadas, suponiendo 20 m de coaxial [CÁLCULO]:
  - AH-730 de WiMo, 498,00 €.
  - Caña Cgantenna de 12 m, 70,18 € (o Spiderbeam 12 m HD SET2, 118,00 €).
  - Aircell 7, 20 × 4,36 € = 87,20 €.
  - Choke ASP AS-111500, 54,45 € (tipo POR VERIFICAR), o FT-240-31 a 10,29 € más RG-400.
  - Total: **≈ 710 €**, o **≈ 758 €** con la caña Spiderbeam.
- Sin contar hilo, radiales, conectores, envíos ni el posible alargador del cable de control de 10 m.

**Si el equipo es el FT-710: A2 o A3.**

- **A2. FC-40**: es el acoplador oficial de Yaesu, a 267,80–281,60 €, pero **pide 20 m de hilo para 160 m**, lo que obliga a una L invertida en la terraza. Coste [CÁLCULO]: 267,80 € (WiMo) o 281,60 € (Ondamania), más 70,18 € + 87,20 € + 54,45 € = **≈ 480–494 €**.
- **A3. LDG RT-100**: 385,00 € en WiMo. No necesita cable de control y vale para cualquier equipo, pero la longitud mínima para 160 m no está publicada. Total ≈ **597 €** con las mismas piezas.
- Si 160 m no es imprescindible, el FC-40 con un hilo de 10–12 m debería cubrir 40–10 m (el manual garantiza 7–54 MHz ya con 2,5 m). Con ese hilo, 80 m está **POR VERIFICAR**: el manual solo da los casos de 2,5 m y de 20 m.

**Si todavía no se ha comprado el equipo**, la antena puede inclinar la balanza: IC-7300MK2 + AH-730 es la pareja documentada para 160 m con solo 7 m de hilo.

**Alternativa barata sin 160 m: B.**

- EFHW de 40 m, como la Dxpatrol a 119,79 € (80–10 m, 1 kW), si la terraza permite un hilo inclinado de 40 m a 6 m o más de altura. Con choke y coaxial sale por **≈ 261 €** [CÁLCULO].
- Si no caben 40 m, una EFHW de 40–10 m de ≈ 19–20 m (MyAntennas EFHW-4010, ≈ 174 € más importación) da cuatro de las seis bandas.

**No recomendar**:

- Lazos magnéticos: más de 1.400 € cada uno, sin 160 m y harían falta dos.
- Chameleon F-Loop: admite 25 W.
- Hy-Gain AV-640: sin 80 ni 160 m, fabricación detenida y 840–890 € en Europa.
- Hustler BTV y DX Commander: necesitan radiales en el suelo que no caben, y no dan 160 m.
- Verticales de banda ancha como antena principal: son cómodas, pero rinden previsiblemente poco en 80 m y no dan 160 m.

---

## 8. Lista POR VERIFICAR

1. **AH-730**: radiales o contrapeso en una terraza; longitudes de hilo a evitar; alargador del cable de control de 10 m; precio en tiendas españolas (el de La Tienda del Radioaficionado es ambiguo); compatibilidad con el IC-705.
2. **IVA de WiMo**: si cobra el alemán (19 %) o el español (21 %) a un cliente en España.
3. **Acopladores**: 160 m con el FC-40 y menos de 20 m de hilo; longitud mínima del LDG RT-100; compatibilidad del mAT-40 con el FT-710 y el IC-7300MK2 (cables mAT-40-Y y mAT-40-M).
4. **EFHW**: precio y disponibilidad actuales de HyEndFed; precios actuales de la WiMo EFHW y de la Chameleon LEFS 8010; longitud de la Momobeam EF1080; bandas de la Dxpatrol EZWIRE; costes de importar MyAntennas.
5. **Verticales**: potencia de la Hustler 5-BTV y radiales elevados; radiales del DX Commander y costes de importación desde Reino Unido; si la OUT-250B es el mismo diseño que la CHA-250B; datos de la Moonraker GPA-80; reanudación de la fabricación de Hy-Gain.
6. **Choke**: impedancia de modo común de los baluns ASP, Tagra y D-Original; receta exacta de K9YC (el PDF salió desordenado); precio del RG-400.
7. **Coaxial**: pérdida del RG-213 según su hoja de datos; conectores.
8. **Instalación**: exposición a RF y permisos de la comunidad para una caña de 10–12 m (ver `data/legal/`).

Búsquedas usadas: **40 de 40** (cupo agotado). WebFetch: 1 intento, ENOTFOUND.
