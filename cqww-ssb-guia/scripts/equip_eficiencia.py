#!/usr/bin/env python3
"""Estimaciones de eficiencia para antenas de compromiso en terraza.

Genera data/equipment/eficiencia_antenas.csv con dos familias de casos:

1. Lazo magnetico pequeno (una espira circular, tubo de cobre):
   - Resistencia de radiacion: R_rad = 20*pi^2*(C/lambda)^4  (~197*(C/lambda)^4 ohm)
     equivalente a 31171*(A/lambda^2)^2 (formula clasica de lazo pequeno).
   - Perdidas del conductor por efecto pelicular:
     R_s = sqrt(pi*f*mu0/sigma);  R_cond = C*R_s/(pi*d)
     (se ignora el efecto de proximidad: es una sola espira).
   - Perdidas extra (condensador, uniones, entorno): parametro R_extra.
   - Inductancia de una espira circular: L = mu0*R*(ln(8R/a) - 2)
     con R = radio del lazo y a = radio del conductor.
   - Con 100 W adaptados: I = sqrt(P/R_total); V_C = I*X_L (tension en el condensador);
     Q cargado = X_L/(2*R_total); ancho de banda a -3 dB = f/Q_cargado.
   - Las formulas de lazo pequeno solo son razonables si C/lambda <~ 0.1-0.25:
     la columna 'valido' lo indica.

2. Vertical corta (monopolo, carga en la base con bobina o acoplador):
   - R_rad = 395*(h/lambda)^2 (corriente triangular, sin sombrero capacitivo).
   - Reactancia de entrada aproximada: X = -Z0*cot(beta*h),
     Z0 = 60*(ln(2h/a) - 1) (impedancia caracteristica media del monopolo).
   - Perdida de la bobina/acoplador: R_bobina = |X|/Q (Q supuesto).
   - Perdida de tierra/radiales: R_tierra (escenarios supuestos: 5, 15, 30 ohm).
   - Perdida del conductor: R_s*h/(2*pi*a)/3 (corriente triangular).

Son estimaciones de orden de magnitud con supuestos explicitos, NO mediciones.
Un edificio de hormigon armado, barandillas metalicas y cables cercanos
anaden perdidas y desintonia que aqui no se modelan.

Uso: .venv/bin/python scripts/equip_eficiencia.py
"""

from __future__ import annotations

import csv
import math
from pathlib import Path

C0 = 299_792_458.0  # m/s
MU0 = 4e-7 * math.pi  # H/m
SIGMA_CU = 5.8e7  # S/m (cobre)

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "data" / "equipment" / "eficiencia_antenas.csv"

# Frecuencias representativas de las bandas de concurso (SSB), en MHz
BANDAS = {
    "160m": 1.85,
    "80m": 3.70,
    "40m": 7.10,
    "20m": 14.20,
    "15m": 21.30,
    "10m": 28.50,
}

POTENCIA_W = 100.0


def surface_resistance(f_hz: float, sigma: float = SIGMA_CU) -> float:
    return math.sqrt(math.pi * f_hz * MU0 / sigma)


def db(x: float) -> float:
    return 10.0 * math.log10(x)


def lazo(diam_m: float, tubo_mm: float, f_mhz: float, r_extra: float) -> dict:
    f = f_mhz * 1e6
    lam = C0 / f
    circ = math.pi * diam_m
    c_lam = circ / lam
    r_rad = 20.0 * math.pi**2 * c_lam**4
    d = tubo_mm / 1000.0
    r_cond = circ * surface_resistance(f) / (math.pi * d)
    r_tot = r_rad + r_cond + r_extra
    eta = r_rad / r_tot
    radio = diam_m / 2.0
    a = d / 2.0
    ind = MU0 * radio * (math.log(8.0 * radio / a) - 2.0)
    x_l = 2.0 * math.pi * f * ind
    q_carg = x_l / (2.0 * r_tot)
    bw_khz = f / q_carg / 1e3
    corriente = math.sqrt(POTENCIA_W / r_tot)
    v_cap = corriente * x_l
    if c_lam <= 0.10:
        valido = "si"
    elif c_lam <= 0.25:
        valido = "aprox"
    else:
        valido = "no (lazo ya no es pequeno)"
    return {
        "tipo": "lazo_magnetico",
        "configuracion": f"D={diam_m:g} m, tubo Cu {tubo_mm:g} mm, R_extra={r_extra*1000:g} mOhm",
        "f_mhz": f_mhz,
        "dimension_relativa": round(c_lam, 4),
        "r_rad_ohm": r_rad,
        "r_perdidas_ohm": r_cond + r_extra,
        "eficiencia_pct": 100.0 * eta,
        "perdida_db": -db(eta),
        "unidades_s": -db(eta) / 6.0,
        "bw_3db_khz": bw_khz,
        "v_condensador_kv_100w": v_cap / 1000.0,
        "valido": valido,
    }


def vertical(h_m: float, radio_cond_mm: float, f_mhz: float, q_bobina: float, r_tierra: float) -> dict:
    f = f_mhz * 1e6
    lam = C0 / f
    h_lam = h_m / lam
    a = radio_cond_mm / 1000.0
    beta_h = 2.0 * math.pi * h_lam
    if beta_h >= math.pi / 2.0:
        # Igual o mas larga que lambda/4: el modelo de monopolo corto no aplica
        return {
            "tipo": "vertical_corta",
            "configuracion": f"h={h_m:g} m, Q={q_bobina:g}, R_tierra={r_tierra:g} ohm",
            "f_mhz": f_mhz,
            "dimension_relativa": round(h_lam, 4),
            "r_rad_ohm": "",
            "r_perdidas_ohm": "",
            "eficiencia_pct": "",
            "perdida_db": "",
            "unidades_s": "",
            "bw_3db_khz": "",
            "v_condensador_kv_100w": "",
            "valido": "no (h >= lambda/4: usar modelo de monopolo completo)",
        }
    r_rad = 395.0 * h_lam**2
    z0 = 60.0 * (math.log(2.0 * h_m / a) - 1.0)
    x = z0 / math.tan(beta_h)  # modulo de la reactancia capacitiva
    r_bob = x / q_bobina
    r_cond = surface_resistance(f) * h_m / (2.0 * math.pi * a) / 3.0
    r_perd = r_bob + r_tierra + r_cond
    eta = r_rad / (r_rad + r_perd)
    valido = "si" if h_lam <= 0.1 else "aprox"
    return {
        "tipo": "vertical_corta",
        "configuracion": f"h={h_m:g} m, Q={q_bobina:g}, R_tierra={r_tierra:g} ohm",
        "f_mhz": f_mhz,
        "dimension_relativa": round(h_lam, 4),
        "r_rad_ohm": r_rad,
        "r_perdidas_ohm": r_perd,
        "eficiencia_pct": 100.0 * eta,
        "perdida_db": -db(eta),
        "unidades_s": -db(eta) / 6.0,
        "bw_3db_khz": "",
        "v_condensador_kv_100w": "",
        "valido": valido,
    }


def fmt(v):
    if isinstance(v, float):
        if v == 0:
            return "0"
        if abs(v) < 0.01:
            return f"{v:.2e}"
        return f"{v:.3g}" if abs(v) < 100 else f"{v:.0f}"
    return v


def main() -> None:
    filas: list[dict] = []
    # Lazos: 0,8 / 1,0 / 1,5 m con tubo de 22 mm; dos escenarios de perdidas extra
    for diam in (0.8, 1.0, 1.5):
        for r_extra in (0.0, 0.010):
            for banda, f in BANDAS.items():
                fila = lazo(diam, 22.0, f, r_extra)
                fila["banda"] = banda
                filas.append(fila)
    # Verticales de 5 y 7 m (tubo de 30 mm de diametro -> radio 15 mm)
    for h in (5.0, 7.0):
        for r_t in (5.0, 15.0, 30.0):
            for banda in ("160m", "80m", "40m"):
                fila = vertical(h, 15.0, BANDAS[banda], 150.0, r_t)
                fila["banda"] = banda
                filas.append(fila)

    campos = [
        "tipo", "configuracion", "banda", "f_mhz", "dimension_relativa",
        "r_rad_ohm", "r_perdidas_ohm", "eficiencia_pct", "perdida_db",
        "unidades_s", "bw_3db_khz", "v_condensador_kv_100w", "valido",
    ]
    OUT.parent.mkdir(parents=True, exist_ok=True)
    with OUT.open("w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=campos)
        w.writeheader()
        for fila in filas:
            w.writerow({k: fmt(fila.get(k, "")) for k in campos})

    # Resumen legible en consola
    print(f"Escrito {OUT.relative_to(ROOT)} ({len(filas)} filas)\n")
    print("Lazo D=1 m, tubo 22 mm, sin perdidas extra (100 W):")
    for fila in filas:
        if fila["tipo"] == "lazo_magnetico" and fila["configuracion"].startswith("D=1 m") and "R_extra=0 " in fila["configuracion"]:
            print(f"  {fila['banda']:>4}: eta={fila['eficiencia_pct']:.3g}%  ({-fila['perdida_db']:.1f} dB, "
                  f"{fila['unidades_s']:.1f} S)  BW-3dB={fila['bw_3db_khz']:.3g} kHz  Vc={fila['v_condensador_kv_100w']:.2g} kV  valido={fila['valido']}")
    print("\nVertical 7 m, Q bobina 150, R_tierra 15 ohm:")
    for fila in filas:
        if fila["tipo"] == "vertical_corta" and fila["configuracion"] == "h=7 m, Q=150, R_tierra=15 ohm":
            if fila["eficiencia_pct"] == "":
                print(f"  {fila['banda']:>4}: {fila['valido']}")
            else:
                print(f"  {fila['banda']:>4}: eta={fila['eficiencia_pct']:.3g}%  ({-fila['perdida_db']:.1f} dB, {fila['unidades_s']:.1f} S)")


if __name__ == "__main__":
    main()
