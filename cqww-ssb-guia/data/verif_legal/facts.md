# Verificación de los datos «POR VERIFICAR» (plan IARU, marco legal y bases del CQ WW)

Fecha de consulta: **2026-10-20**. Claves bibliográficas en `data/verif_legal/refs.yml` (prefijo
`verl-`). Detalle fila a fila en `verificacion.csv` (V01–V28) y en `iaru_r1_ssb_verificado.csv`
(mismas columnas que `data/legal/iaru_r1_ssb.csv`, más `estado`).

## 0. Método y criterio

- Las webs (iaru-r1.org, boe.es, digital.gob.es, cqww.com, madrid.es…) **no son accesibles** desde
  el entorno: WebFetch da `ENOTFOUND` y curl, `403`. Se usó WebSearch, que devuelve resúmenes y
  fragmentos de las páginas, y la réplica `legalize-es` del API del BOE en raw.githubusercontent.com
  (`scripts/legal_fetch_boe.py` explica la ruta), que sí es texto íntegro.
- **38 búsquedas** (4 en modo extendido), dentro del límite de 45. Ninguna dio error de cupo.
- Estados:
  - **confirmado**: el dato aparece en el resumen de un resultado cuya URL es la fuente primaria
    (IARU, BOE, Ministerio, Ayuntamiento, cqww.com) o en el texto del BOE leído en la réplica.
  - **corregido**: la fuente primaria da un valor distinto (se indica el bueno).
  - **sin_confirmar**: sólo en fuentes secundarias (URE), en ninguna fuente o con texto ambiguo.
- Las citas entre comillas son literales según el resumen. Si sólo había paráfrasis, se marca
  «[paráfrasis del resumen]». Los resúmenes pueden contener errores: **antes de publicar, conviene un
  repaso humano** de los PDF citados.

## 1. Plan de bandas HF de la IARU Región 1

### 1.1 Versión vigente

- **Versión de 16 de octubre de 2020, revisada en 2021.** La IARU R1 dice: «After approval by the
  Virtual General Conference in Novi Sad 2020, the modifications of the Region 1 HF band plan became
  effective at 16 October 2020». Y en su aviso de 2021: «The HF band plan in its version of 16
  October 2020 (Virtual General Conference "Novi Sad") including the annex has been revised». El
  plan ocupa 2 páginas y el anexo explicativo otras 2. `verl-iaru-r1-hf-bandplan-revised`
- PDF vigente: <https://www.iaru-r1.org/wp-content/uploads/2021/06/hf_r1_bandplan.pdf>
  (`verl-iaru-r1-hf-bandplan`). Página de descargas: <https://www.iaru-r1.org/on-the-air/band-plans/>.
- No apareció ninguna revisión posterior. Las actas del Comité Ejecutivo de mayo de 2025 hablan de
  propuestas pendientes de ratificar, por ejemplo sobre la voz digital, pero sin un plan nuevo. No
  se pudo abrir la página de descargas para descartarlo del todo.
- **Limitación**: la tabla del PDF de 2021 no salió legible en los resúmenes. Los segmentos se
  contrastaron con el texto de la **edición de 1-6-2016**, ratificada en Landshut 2017 y
  reproducida en el *HF Manager's Handbook V9* (junio de 2018, `verl-iaru-r1-hf-managers-handbook-v9`).
  También con el PDF de 2019, que incluye el historial de cambios (`verl-iaru-r1-hf-bandplan-2019`),
  y con el anexo explicativo (`verl-iaru-r1-hf-bandplan-why`). Los cambios que aparecieron no
  tocan los segmentos de SSB (el historial del PDF no deja claro cuáles son de 2020):
  - se suprime el segmento CW preferente de concursos 7000–7025 kHz;
  - se reordenan los canales FM de 29 MHz;
  - la conferencia de 2020 recomendó quitar el límite de 6 kHz en 29000–29510 kHz (no consta si se
    adoptó).

### 1.2 Resultado fila a fila (`iaru_r1_ssb_verificado.csv`)

62 filas: las 59 originales, con 2 divididas en 5. **47 confirmadas, 5 corregidas y 10 sin
confirmar.**

Segmentos de SSB que usa la guía (capítulo 5): **todos confirmados**.

| Banda | SSB / preferente de concursos | Centros de actividad (dejar libres) |
|---|---|---|
| 160 m | 1843–2000 «todos los modos» (2700 Hz) | QRP CW 1836 |
| 80 m | 3600–3650 y 3700–3800 «SSB contest preferred»; 3650–3700 todos los modos | voz digital 3630; QRP SSB 3690; imagen 3735; **emergencias R1 3760** |
| 40 m | 7060–7100 y 7130–7200 «SSB contest preferred»; 7100–7130 todos los modos | voz digital 7070; QRP SSB 7090; **emergencias R1 7110**; imagen 7165 |
| 20 m | 14125–14300 «SSB contest preferred»; 14300–14350 todos los modos | voz digital 14130; DXpediciones 14195 ± 5; imagen 14230; QRP SSB 14285; **emergencias global 14300** |
| 15 m | 21151–21450 todos los modos (sin segmento de concursos) | voz digital 21180; QRP SSB 21285; imagen 21340; **emergencias global 21360** |
| 10 m | 28320–29000 todos los modos | voz digital 28330; QRP SSB 28360; imagen 28680 |

Citas clave:

- 80 m: «3600 - 3650 · 2700 · All modes, SSB contest preferred, 3630 kHz – Digital Voice Centre of
  Activity» y «3650 - 3700 2700 All modes 3690 kHz - SSB QRP Centre of Activity».
- 20 m: «14130 kHz Digital Voice Centre of Activity; 14195 +/- 5 kHz Priority for DX-peditions;
  14230 kHz Image Centre of Activity; 14285 kHz SSB QRP Centre of Activity; 14300 kHz Global
  Emergency Centre of Activity».
- 15 m: «21151 - 21450 2700 All modes 21180 kHz – Digital Voice Centre of Activity 21285 kHz – SSB
  QRP Centre of Activity 21340 kHz – Image Centre of Activity 21360 kHz – Global Emergency Centre of
  Activity».
- 10 m: «28300 -28320 2700 All modes Digimodes, automatically controlled data stations (unattended)
  … 28320 - 29000 2700 All modes».
- Bandas sin concursos (Handbook V9): «Contests should be restricted to 160, 80, 40, 20, 15 and
  10m».
- Bandas laterales: «Below 10 MHz lower sideband (LSB) is recommended, and above 10 MHz use upper
  sideband». La excepción es 5 MHz, donde se recomienda USB.

### 1.3 Correcciones y matices nuevos

1. **Dial LSB mínimo.** Nota del plan: «(*) Lowest dial setting for LSB Voice mode: 1843, 3603 and
   7053 kHz».
   - En 160 m, el dial de fonía puede ir **desde 1843 kHz**, no desde ≈ 1846 como dice el pie de la
     figura de bandas laterales del capítulo 5. La señal LSB ocupa entonces 1840,3–1842,7 kHz.
   - Con la atribución permanente española, el dial va de **1843 a 1850,0 kHz**.
   - Dejar libre el tramo digital 1840–1843 es una opción prudente, pero no la marca el plan
     [INTERPRETACIÓN].
2. **160 m, 1838–1843 no es un único tramo**:
   - 1838–1840, modos de banda estrecha (500 Hz);
   - 1840–1843, «todos los modos – digimodos» (2700 Hz).
3. **40 m, 7040–7060**:
   - 7040–7047, digimodos estrechos (confirmado);
   - 7047–7050, sin confirmar;
   - **7050–7060** es «todos los modos – digimodos». Según el anexo, «[paráfrasis] if no digimode
     activity takes place the segment of 7050-7060 kHz may be used for SSB». Dial LSB mínimo: 7053.
4. **80 m, 3775–3800**: es SSB preferente de concursos, pero con prioridad intercontinental. Según
   el Handbook, si no hay tráfico DX, los segmentos de concurso no deben incluir 3500–3510 ni
   3775–3800 kHz [paráfrasis]. Para QSO dentro de Europa, quédate en 3700–3775.
5. **20 m, 14190–14200**: el plan sólo dice «Priority for DX-peditions». La guía añade «evitar en
   concursos», que es cortesía y no regla del plan.
6. **Dial en el borde superior**: «On 60m, 20m and higher bands the frequency display must be kept 3
   kHz below the upper band limit». Eso da 14347, 21447 y 29697 kHz, lo que confirma el ≈ 14 347 de
   la guía.
7. **Centros de emergencia**: no son frecuencias exactas, porque «emergency communications may be
   found ±20kHz from these centres».
8. **10 m por encima de 29000**:
   - 29000–29100, todos los modos (6 kHz);
   - 29100–29200, FM símplex;
   - 29200–29300, digimodos automáticos;
   - 29300–29510, satélites: «Member societies should advise operators not to transmit on
     frequencies between 29.3 MHz and 29.51 MHz for terrestrial communication»;
   - 29510–29520, guarda;
   - 29520–29590, entradas de repetidores FM;
   - 29600, llamada FM;
   - 29620–29690, salidas de repetidores FM.

### 1.4 Sin confirmar en el plan

- 80 m: 3570–3600 (sólo se confirma 3570–3580, digimodos de 200 Hz, cambio de 2016) y 3600–3620.
- 30 m: «sin SSB salvo emergencias».
- 20 m: 14000–14060 como «CW contest preferred» (sí la QRS en 14055), 14060–14112 completo y
  14112–14125. El texto del PDF sale fragmentado y una lectura atribuía «contest preferred» a
  14112–14125.
- 40 m: 7047–7050.
- 10 m: 28000–28070, 28070–28190 y el uso «balizas» de 28225–28300.

Ninguno afecta a los segmentos de SSB que recomienda la guía.

## 2. España, 160 m: 1850–2000 kHz

- **Fuente primaria (Ministerio), sin fecha.** La página «Autorización de uso temporal y
  experimental» recoge una resolución que autoriza, «en determinadas condiciones y con carácter
  temporal y experimental», el uso de frecuencias en la banda de 1800 kHz por titulares de
  autorización de radioaficionado. Recoge también una resolución de prórroga («RESOLUTION
  AUTHORIZATION EXTENSION BAND 1800 KHZ RADIO AMATEURS» en la versión inglesa). Los resúmenes no
  muestran fechas. `verl-mtdfp-autorizacion-uso-temporal`
- **Fuente secundaria (URE, 29-12-2025)**, `verl-ure-1850-2000-2026`. La SETID dictó una
  «Resolución por la que se autoriza, con carácter temporal y experimental, la utilización de
  frecuencias en la banda 1850–2000 kHz»:
  - vale para los concursos «entre el 1 de enero y el 31 de diciembre» de 2026;
  - las emisiones deben ajustarse a las características técnicas del Reglamento para 1,8 MHz;
  - «se concede bajo el principio de no interferencia a otros servicios y sin derecho a protección
    frente a posibles interferencias»;
  - y, como en la de 2025, «las emisiones deberán ser suspendidas de manera inmediata» si hay
    perturbaciones.
  - El fundamento es que en años anteriores no hubo interferencias ni reclamaciones. URE ha publicado
    una autorización así cada año, de 2020 a 2026.
- **¿Cubre el CQ WW SSB?**
  - **Sí el de 2026** (24–25 de octubre), según URE.
  - **No el de 2027** (30–31 de octubre): hará falta la resolución de 2027. La de 2026 se conoció a
    finales de diciembre de 2025.
  - Sigue **sin confirmar en fuente primaria** (estado `sin_confirmar`).
- **Potencia: sin confirmar.** El anexo I de la Orden IET/1311/2013 da 1000 W p.c.e. en 1,8 MHz. No
  consta si la resolución aplica la reducción al 50 % de las bandas secundarias. Para 100 W da
  igual.
- Encaje con el CNAF 2026 [BOE]:
  - su DA 2.ª mantiene la habilitación de la SETID para usos temporales o experimentales;
  - RR 5.96 permite atribuir 1850–2000 kHz a aficionados sólo en una lista de países (Alemania,
    Austria, Reino Unido, Suiza…) que **no incluye a España**, con un máximo de 10 W de potencia
    media. Por eso España recurre a resoluciones temporales.
- Dato lateral: según la misma página del Ministerio, la resolución de **5 MHz** autorizaba el uso
  secundario de 5351,5–5366,5 kHz **hasta el 31-12-2017**. No apareció ninguna prórroga (V16).

## 3. CNAF 2026 (Orden TDF/732/2026, BOE-A-2026-15661)

- **Confirmado [BOE, réplica]**: los cuadros nacionales y **todas** las notas UN son imágenes de
  boe.es. Tras el epígrafe «Notas de utilización nacional (UN)» sólo hay enlaces del tipo
  `…/15661_17248986_1.png`, 248 imágenes en total. El estatus primario/secundario nacional **no se
  puede leer**.
- Sí son texto las notas del RR:
  - 5.98: «la banda de frecuencias 1810-1830 kHz está atribuida, a título primario, a los servicios
    fijo y móvil, salvo móvil aeronáutico» en España, entre otros países;
  - 5.100: hace falta consulta previa al norte de 40° N;
  - 5.96: ver §2;
  - 5.92: radiodeterminación en 1850–2160 y 3500–3800 kHz en algunos países de la R1, con 50 W de
    potencia media; se refiere a esas estaciones, no a los aficionados;
  - 5.142: 7200–7300 kHz en la Región 2.
- **Fuente secundaria (URE)**, `verl-ure-bandas-atribuidas` (página de hacia 2024) y
  `verl-ure-cnaf-2026`:

  | Banda (kHz) | Estatus | Potencia |
  |---|---|---|
  | 1810–1830 | secundaria | 500 W |
  | 1830–1850 | primaria | 1000 W |
  | 3500–3800 | primaria, compartida con fijo y móvil salvo móvil aeronáutico | 1000 W |
  | 7000–7200, 14000–14350, 21000–21450 y 28000–29700 | primaria | 1000 W |

  - Según URE, el CNAF 2026 «no cambia las bandas, condiciones de uso ni limitaciones del servicio
    de aficionados respecto a la edición de 2021» [paráfrasis del resumen]. Tampoco cambian las
    notas nacionales ni las del RR que sustentan esas bandas.
  - Todo coincide con `bands_power_es.csv`, pero queda `sin_confirmar` en fuente primaria.
- **Notas UN**: en el CNAF 2021 derogado (notas en texto, BOE-A-2021-21346) las únicas notas UN de
  aficionados son UN-108 (135,7–137,8 kHz), UN-100 (50–52 MHz) y UN-132 (70,150–70,250 MHz).
  **Ninguna para 1,8–29,7 MHz.** La UN-108 dice: «Se autoriza el uso de la banda 135,7 - 137,8 kHz
  para el servicio de aficionados, a título secundario bajo la consideración de uso especial». La
  numeración de 2026 sigue sin confirmar.

## 4. Sede electrónica del Ministerio (2026)

- Ficha informativa: «Radioaficionados (SIA: 151740 - 155085 - 991002 - 991004)»
  (`verl-mtdfp-ficha-radioaficionados`).
- **Procedimiento 147** de la sede, de radioaficionados (`verl-sede-radioaficionados-147`).
  - URL: <https://sedediatid.digital.gob.es/es-es/procedimientoselectronicos/Paginas/detalle-procedimientos.aspx?IdProcedimiento=147>
  - Trámites:
    - nueva autorización, su modificación o cancelación;
    - distintivo temporal;
    - solicitud de licencia de instalación de estación fija;
    - «Modificación o cancelación de licencia de instalación de estación fija de radioaficionado»;
    - autorizaciones especiales;
    - inscripción en exámenes.
  - Acceso con certificado digital o Cl@ve.
  - No apareció el título oficial exacto de la ficha.
- **Procedimiento 34** (`verl-sede-puesta-servicio-34`).
  - URL: <https://sedediatid.digital.gob.es/es-es/procedimientoselectronicos/Paginas/detalle-procedimientos.aspx?IdProcedimiento=34>
  - Trámite: «Presentación de solicitudes de autorización para la puesta en servicio de estaciones
    de radioaficionados y de la licencia de estaciones fijas».
  - Adjuntos:
    - «Solicitud de autorización para la puesta en servicio (adjuntar siempre)»;
    - declaración responsable de características de la instalación, sólo si la hizo el propio
      radioaficionado;
    - boletín de instalación.
  - Además, «Modelo 790 (No aplica a radioafición)»: el pago de la tasa no se aplica a este trámite,
    así que la licencia de estación **no parece llevar tasa** [INTERPRETACIÓN mínima].
  - El SIA 225042 que un resumen atribuía a este trámite no se pudo confirmar.
- **¿Proyecto o memoria firmada por técnico competente?** **No se encontró esa exigencia para
  aficionados** (`sin_confirmar`).
  - La Orden IET/1311/2013 y el RD 2623/1986 no la contienen (texto del BOE, comprobado por
    ausencia). El RD pide una «Memoria descriptiva» (art. 2.2: «La documentación compre [sic] una
    Memoria descriptiva de la estación que desee instalar…») y, para antenas exteriores, plano o
    esquema, cálculos y título de uso.
  - El «proyecto técnico» firmado por técnico competente figura en la página general de la
    Inspección para estaciones radioeléctricas (`verl-mtdfp-autorizaciones-estaciones`), sin
    constancia de que se aplique a los aficionados.
  - Un resumen atribuye a unas instrucciones de la sede pedir planos de situación, planta y alzado
    de la antena y, a un inquilino, permiso del propietario. **Sin confirmar**, y conviene mirarlo:
    choca con la lectura de la Ley 19/1983 de la guía («legitimados para usar»).

## 5. Ayuntamiento de Madrid: ¿declaración responsable?

**Sin confirmar.** No apareció ninguna norma ni trámite municipal específico para antenas de
radioaficionado. Lo verificado:

- **Ley 11/2022 [BOE, consolidada a 28-12-2025]**:
  - La DA 19.ª dice: «En la instalación de estaciones radioeléctricas de radioaficionado se aplicará
    lo establecido en el primer párrafo del artículo 49.9, sin perjuicio de la aplicación de la Ley
    19/1983…».
  - El primer párrafo del art. 49.9 prohíbe exigir licencia salvo en tres casos: bienes de interés
    cultural; más de 300 m², «computándose a tal efecto toda la superficie incluida dentro del
    vallado de la estación o instalación»; o, si son «instalaciones de nueva construcción», impacto
    en espacios naturales protegidos.
  - La sustitución por declaraciones responsables está en un **párrafo posterior** del mismo
    apartado: «Las licencias o autorizaciones previas que, de acuerdo con los párrafos anteriores,
    no puedan ser exigidas, serán sustituidas por declaraciones responsables…». La DA 19.ª no lo
    menciona, así que no está claro que alcance a los aficionados [INTERPRETACIÓN].
- **Ordenanza 6/2022 (OLDRUAM)**, en vigor desde el 17-06-2022: «serán objeto de declaración
  responsable todas las actuaciones urbanísticas que deban ser objeto de intervención municipal y
  no estén incluidas en el control por licencia». No se pudo leer si incluye o excluye estas
  antenas.
- **Protocolo municipal de 2011**, anterior a la Ley 11/2022 y a la OLDRUAM: «La instalación y la
  colocación de antenas o dispositivos de telecomunicaciones de cualquier clase, constituyen actos
  sujetos a licencia urbanística». Probablemente esté superado.
- Recomendación para la guía: mantener el «POR VERIFICAR» y aconsejar una consulta a Urbanismo o a
  la Agencia de Actividades del Ayuntamiento, o a URE.

## 6. Bases del CQ WW 2026 y FAQ

- **CLASSIC** [bases 2026, `verl-cqww-rules-2026`]:
  - Texto: «Classic Operator (CLASSIC): The entrant will use only one radio, no QSO finding
    assistance, and may operate up to 24 of the 48 hours».
  - Si el log tiene más, «only the first 24 hours will be counted for the overlay score». El reloj
    empieza con el primer QSO.
  - «Receiving while transmitting is prohibited. Single Operator Assisted entries are not eligible
    for this category.»
  - Descansos: al menos 60 minutos sin ningún QSO (paráfrasis; la frase literal no salió).
  - FAQ (`verl-cqww-rules-faq`): un descanso son 60 minutos de reloj consecutivos «vacíos». Un QSO a
    las 1359 y el siguiente a las 1459 **no** valen como descanso: sólo hay 59 minutos vacíos.
    Llenar el mapa de banda durante un descanso no va con el espíritu de la categoría.
- **Únicos** (`verl-cqww-publiclcr`, `verl-cqww-blog-lcr-cw-2013`):
  - No apareció ninguna penalización específica.
  - El informe de comprobación incluye la «List of calls that only you worked that were not removed
    from your log (Uniques)». Un único no se elimina por serlo.
  - Según el blog (CW 2013), por experiencia más del 90 % de los únicos son probablemente indicativos
    mal copiados.
  - Las bases tratan como antideportivo «Taking credit for excessive unverifiable QSOs or
    unverifiable multipliers».
- **Informes «UBN» → hoy LCR** (*Log Checking Reports*):
  - Cada participante recibe un enlace privado: «A link to the report is sent by email soon after
    the release of final results for each mode». Llega a la dirección con la que se envió el log.
  - Contenido: resumen por bandas, NIL, busts, únicos no eliminados, multiplicadores y estaciones
    que copiaron mal tu indicativo o intercambio.
  - Se publican los de los mejores: «we are providing the log check reports of world high scoring
    entries» (<https://cqww.com/publiclcr/>).
  - Si el LCR y la base de datos de puntuaciones discrepan, vale la base de datos en línea.
  - El término «UBN» no aparece en las páginas actuales.
- **Super Check Partial: sin confirmar.**
  - Ni las bases 2026 ni la FAQ (en lo devuelto) mencionan SCP ni «call history».
  - La FAQ explica el cambio de 2015: «Now if the technology only provides callsign or multiplier
    information it is considered assistance». Las bases 2026 definen la asistencia como tecnología
    que identifica el indicativo o multiplicador de una señal.
  - Si una base de datos que no depende de la señal recibida cuenta como asistencia es
    interpretación. La guía debería presentarlo así o recomendar preguntar al comité.

## 7. Cambios sugeridos en la guía

No se ha editado nada fuera de `data/verif_legal/`.

1. **Cap. 5, tabla `tab-segmentos`**: quitar el #pv de la columna IARU y citar
   `verl-iaru-r1-hf-bandplan` (versión 16-10-2020, rev. 2021). Añadir en «Ojo»:
   - 80 m: «3775–3800, prioridad DX; sin DX, mejor 3700–3775»;
   - 20 m: 14190–14200 «es prioridad de DXpediciones (cortesía)».
2. **Cap. 5, pie de `fig-banda-lateral`**: «en la fonía de 160 m en España, entre ≈ 1846 y 1850,0»
   → «entre 1843 (dial LSB mínimo del plan IARU) y 1850,0». Si se quiere dejar libre el tramo
   digital 1840–1843, decirlo como consejo propio. Requiere cambiar `scripts/fig_banda_lateral.py`,
   que hoy suma el ancho de banda a 1843.
3. **Cap. 8, fila 1850–2000 de `tab-bandas-es` y error típico**: «Para 2026 hay resolución de la
   SETID (diciembre de 2025) que permite 1850–2000 kHz en los concursos del año, incluido el CQ WW
   SSB del 24–25 de octubre (según URE; fechas sin confirmar en el BOE o en el Ministerio). Para
   2027 habrá que esperar a la resolución de 2027». Mantener: sin protección y cese inmediato si
   hay interferencias.
4. **Cap. 8, sede**: sustituir la nota #pv por los procedimientos 147 y 34 y los adjuntos. Añadir
   que la licencia de estación no parece llevar tasa (modelo 790 «no aplica a radioafición»). Sobre el
   proyecto firmado: «la Orden y el RD no lo exigen; la sede pide declaración responsable si la
   instalación la haces tú» (aún #pv en la sede).
5. **Cap. 8, Madrid**: mantener #pv y explicar la duda (la DA 19.ª sólo remite al primer párrafo
   del art. 49.9).
6. **Cap. 3, CLASSIC**: sustituir «#pv cómo se computan exactamente las 24 horas» por «cuentan las
   primeras 24 horas desde el primer QSO; un descanso son 60 minutos de reloj seguidos sin QSO (1359
   → 1459 no vale)».
7. **Cap. 3 y 10, únicos y UBN**: «los únicos no se eliminan por serlo; tras los resultados, el
   comité envía a cada participante su informe de comprobación (LCR) por correo; los de los mejores
   son públicos». Así sobran los dos #pv de UBN.
8. **Cap. 3, SCP**: mantener #pv, pero cambiar «se usa habitualmente en no asistido» por una
   formulación prudente que cite la frase de la FAQ de 2015.
9. **`fig_segmentos.py`**: si se sustituye `iaru_r1_ssb.csv` por `iaru_r1_ssb_verificado.csv`
   (mismas columnas y misma clasificación de usos, comprobado), el script tratará como «pendientes»
   las filas `corregido`, porque sólo acepta `confirmado`/`verificado`. Las `corregido` ya traen el
   valor bueno.
