#!/usr/bin/env python3
"""Estimación de distancias de seguridad RF para una estación de HF de 100 W PEP en SSB.

Uso:
    python scripts/legal_rf_exposure.py            # imprime la tabla y escribe el CSV
    python scripts/legal_rf_exposure.py --no-csv   # sólo imprime

Qué calcula
-----------
Distancia mínima R (en metros) a la que la densidad de potencia equivalente de onda plana
estimada en campo lejano queda por debajo del nivel de referencia para el PÚBLICO EN GENERAL
del Real Decreto 1066/2001, anexo II, cuadro 2 (valores rms imperturbados):

    1-10 MHz   : E = 87 / sqrt(f) V/m ; H = 0,73 / f A/m          (f en MHz)
    10-400 MHz : E = 28 V/m ; H = 0,073 A/m ; S_eq = 2 W/m^2
    Promedio temporal: cualquier periodo de 6 minutos (100 kHz - 10 GHz), nota 2 del cuadro 2.

Para 1-10 MHz el cuadro no da S_eq; se usa el equivalente de onda plana S = E^2 / 377 ohm.

Fórmula (campo lejano, con reflexión en el suelo, criterio conservador):

    S(R) = P_media * G * F^2 / (4 * pi * R^2)   ->   R = sqrt(P_media * G * F^2 / (4 * pi * S_lim))

Supuestos (TODOS deben citarse junto al resultado; ninguno procede de la normativa española):
  * P_PEP = 100 W a la salida del transceptor; pérdidas de la línea = 0 dB (conservador).
  * Factor de modo SSB (potencia media / PEP durante la locución): 0,2 sin procesador de voz y
    0,4 con procesador/compresión. Valores tomados de la práctica habitual (FCC OET-65
    Suplemento B, tabla 1); son una referencia técnica, no una norma española (POR VERIFICAR
    el valor exacto en el documento original).
  * Factor de tiempo (fracción del periodo de 6 min en transmisión): 1,0 = peor caso
    (llamando CQ sin parar); 0,5 = concurso típico en "run" (mitad del tiempo escuchando).
  * Ganancia de antena: 2,15 dBi (dipolo/V invertida, hilo) y 8 dBi (yagi de 3 elementos,
    sólo 20/15/10 m).
  * Factor de reflexión en el suelo F = 1,6 en campo (F^2 = 2,56 en potencia), criterio
    conservador habitual (FCC OET-65 / UIT-T K.52, POR VERIFICAR).
  * Frecuencia de cálculo: el extremo superior de la banda española (en 1-10 MHz el nivel de
    referencia baja al subir f, así que es el caso más restrictivo).

Limitación importante: en 160, 80 y 40 m (y en 20 m con dipolo) las distancias obtenidas quedan
DENTRO del campo cercano reactivo (R < lambda / 2*pi), donde la fórmula de campo lejano no es válida; allí hay que
evaluar E y H por separado (modelado NEC o medida). Los resultados son orientativos, no un
certificado de cumplimiento.
"""
from __future__ import annotations

import argparse
import csv
import math
from pathlib import Path

C = 299_792_458.0  # m/s
Z0 = 376.73  # ohm, impedancia del espacio libre
GROUND_FIELD_FACTOR = 1.6
PEP_W = 100.0

# Bandas y frecuencia de cálculo (MHz): extremo superior de la banda en España.
# 160 m: 1,850 MHz (atribución permanente 1810-1850 kHz); se añade 2,000 MHz por si se opera
# 1850-2000 kHz al amparo de una autorización temporal (condiciones POR VERIFICAR).
BANDS = [
    ("160 m", 1.850),
    ("160 m (1850-2000 kHz, autorización temporal)", 2.000),
    ("80 m", 3.800),
    ("40 m", 7.200),
    ("20 m", 14.350),
    ("15 m", 21.450),
    ("10 m", 29.700),
]

ANTENNAS = [
    ("dipolo / V invertida", 2.15, None),
    ("yagi 3 elementos", 8.0, {"20 m", "15 m", "10 m"}),
]

SCENARIOS = [
    # nombre, factor de modo, factor de tiempo
    ("SSB con procesador, CQ continuo (peor caso)", 0.4, 1.0),
    ("SSB con procesador, concurso típico (50 % TX)", 0.4, 0.5),
    ("SSB sin procesador, QSO normal (50 % TX)", 0.2, 0.5),
    ("Portadora continua 100 W (sintonía/RTTY/FT8), referencia", 1.0, 1.0),
]

ANEXO_I_IET_1311_W_M2 = 35.0  # 3,5 mW/cm^2 = 35 W/m^2 (Orden IET/1311/2013, anexo I, ap. 3.5)


def reference_levels(f_mhz: float) -> tuple[float, float, float]:
    """Devuelve (E V/m, H A/m, S_eq W/m^2) del RD 1066/2001, anexo II, cuadro 2 (público)."""
    if 1.0 <= f_mhz < 10.0:
        e = 87.0 / math.sqrt(f_mhz)
        h = 0.73 / f_mhz
        s = e * e / Z0  # equivalente de onda plana (el cuadro no lo da en esta gama)
    elif 10.0 <= f_mhz <= 400.0:
        e, h, s = 28.0, 0.073, 2.0
    else:
        raise ValueError(f"frecuencia fuera de la gama tratada: {f_mhz} MHz")
    return e, h, s


def safe_distance_m(p_avg_w: float, gain_dbi: float, s_lim_w_m2: float) -> float:
    g = 10 ** (gain_dbi / 10)
    return math.sqrt(p_avg_w * g * GROUND_FIELD_FACTOR**2 / (4 * math.pi * s_lim_w_m2))


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--no-csv", action="store_true", help="no escribir el CSV")
    ap.add_argument(
        "--out",
        default=str(Path(__file__).resolve().parents[1] / "data" / "legal" / "rf_exposure_distances.csv"),
    )
    args = ap.parse_args()

    rows = []
    for band, f in BANDS:
        e, h, s = reference_levels(f)
        lam = C / (f * 1e6)
        near = lam / (2 * math.pi)
        for ant, gdbi, only in ANTENNAS:
            base_band = band.split(" (")[0]
            if only and base_band not in only:
                continue
            for scen, mode, tfrac in SCENARIOS:
                p_avg = PEP_W * mode * tfrac
                r = safe_distance_m(p_avg, gdbi, s)
                r_anexo = safe_distance_m(p_avg, gdbi, ANEXO_I_IET_1311_W_M2)
                rows.append(
                    {
                        "banda": band,
                        "f_mhz": f"{f:.3f}",
                        "nivel_ref_E_V_m": f"{e:.1f}",
                        "nivel_ref_H_A_m": f"{h:.3f}",
                        "nivel_ref_S_W_m2": f"{s:.2f}",
                        "antena": ant,
                        "ganancia_dbi": f"{gdbi:.2f}",
                        "escenario": scen,
                        "p_media_w": f"{p_avg:.0f}",
                        "distancia_rd1066_m": f"{r:.1f}",
                        "distancia_anexoI_3_5mWcm2_m": f"{r_anexo:.1f}",
                        "campo_cercano_reactivo_m": f"{near:.1f}",
                        "valido_campo_lejano": "no (orientativo)" if r < near else "sí",
                    }
                )

    # Impresión resumida
    hdr = f"{'banda':<46} {'antena':<22} {'escenario':<58} {'Pmed':>5} {'R_RD1066':>9} {'λ/2π':>6}"
    print(hdr)
    print("-" * len(hdr))
    for r in rows:
        print(
            f"{r['banda']:<46} {r['antena']:<22} {r['escenario']:<58} {r['p_media_w']:>5} "
            f"{r['distancia_rd1066_m']:>8} m {r['campo_cercano_reactivo_m']:>5} m"
        )

    if not args.no_csv:
        out = Path(args.out)
        out.parent.mkdir(parents=True, exist_ok=True)
        with out.open("w", newline="", encoding="utf-8") as fh:
            w = csv.DictWriter(fh, fieldnames=list(rows[0].keys()))
            w.writeheader()
            w.writerows(rows)
        print(f"\nCSV escrito en {out}")


if __name__ == "__main__":
    main()
