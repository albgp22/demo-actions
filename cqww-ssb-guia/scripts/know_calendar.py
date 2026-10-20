#!/usr/bin/env python3
"""Calendario de concursos de calentamiento (nov 2026 - oct 2027) con contenido SSB.

Las fechas se CALCULAN a partir de la regla de calendario de cada concurso
(p. ej. "último fin de semana completo de octubre"). Las reglas proceden de
conocimiento previo y NO pudieron contrastarse con las bases oficiales en esta
sesión (cupo de búsquedas agotado): la columna 'verificado' lo indica.
Las URL de bases marcadas "Not1MM" se han leído en el paquete Not1MM 26.10.18
(PyPI, publicado 2026-10-19; cabeceras de los plugins de concursos).

Salida: data/knowledge/contests_calendar.csv
Uso:    python3 scripts/know_calendar.py [ruta_proyecto]
"""
import calendar
import csv
import datetime as dt
import pathlib
import sys

ROOT = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / "data" / "knowledge"
OUT.mkdir(parents=True, exist_ok=True)


def full_weekends(year, month):
    """Sábados cuyo domingo siguiente cae en el mismo mes (fines de semana completos)."""
    res = []
    for day in range(1, calendar.monthrange(year, month)[1] + 1):
        d = dt.date(year, month, day)
        if d.weekday() == 5 and (d + dt.timedelta(days=1)).month == month:
            res.append(d)
    return res


def nth_full_weekend(year, month, n):
    w = full_weekends(year, month)
    return w[n - 1] if n > 0 else w[n]


def nth_saturday(year, month, n):
    sats = [dt.date(year, month, d) for d in range(1, calendar.monthrange(year, month)[1] + 1)
            if dt.date(year, month, d).weekday() == 5]
    return sats[n - 1] if n > 0 else sats[n]


NOT1MM = "URL leída en Not1MM 26.10.18 (PyPI 2026-10-19)"
MEMURL = "URL de memoria (POR VERIFICAR)"
MEMRULE = "regla de fecha de memoria, POR VERIFICAR en bases"

# (concurso, año, mes, n (fin de semana completo; -1 = último), hora_ini, hora_fin, offset_fin_días,
#  modo, bandas, organizador, url, nota_url, nota_extra)
# hora_fin con offset en días respecto al sábado; "fri" para concursos que empiezan el viernes.
C = []


def add(name, date_sat, start, end_day_offset, end, modo, bandas, org, url, url_note, extra, start_day_offset=0):
    s = date_sat + dt.timedelta(days=start_day_offset)
    e = date_sat + dt.timedelta(days=end_day_offset)
    fechas = f"{s.isoformat()} {start}Z - {e.isoformat()} {end}Z"
    C.append([name, fechas, modo, bandas, org, url, f"{extra}; {url_note}"])


# --- otoño 2026 -----------------------------------------------------------
add("CQ WW DX Contest SSB 2026 (escucha)", nth_full_weekend(2026, 10, -1), "0000", 1, "2359",
    "SSB", "160-80-40-20-15-10", "CQ Magazine", "https://www.cqww.com/rules.htm", NOT1MM,
    "Último fin de semana completo de octubre (" + MEMRULE + "); coincide con el plan del autor (24-25 oct)")
add("JIDX Phone 2026", nth_full_weekend(2026, 11, 2), "0700", 1, "1300",
    "SSB", "160-80-40-20-15-10", "JIDX / JARL", "http://www.jidx.org/jidxrule-e.html",
    NOT1MM + " (página de bases JIDX, plugin CW)",
    "2º fin de semana completo de noviembre (" + MEMRULE + "); DX solo trabaja JA")
add("LZ DX Contest 2026", nth_full_weekend(2026, 11, 3), "1200", 1, "1200",
    "CW+SSB", "160-80-40-20-15-10", "BFRA (Bulgaria)", "https://lzdx.bfra.bg/rulesen.html", NOT1MM,
    "3er fin de semana completo de noviembre (" + MEMRULE + ")")
add("CQ WW DX Contest CW 2026 (escucha)", nth_full_weekend(2026, 11, -1), "0000", 1, "2359",
    "CW", "160-80-40-20-15-10", "CQ Magazine", "https://www.cqww.com/rules.htm", NOT1MM,
    "Último fin de semana completo de noviembre (" + MEMRULE + ")")
add("ARRL 10-Meter Contest 2026", nth_full_weekend(2026, 12, 2), "0000", 1, "2359",
    "CW+SSB", "10", "ARRL", "http://www.arrl.org/10-meter", NOT1MM,
    "2º fin de semana completo de diciembre (" + MEMRULE + "); máx. 36 h de operación (Not1MM); coincide con el plan del autor (12-13 dic)")
add("Stew Perry Topband Distance Challenge 2026", nth_saturday(2026, 12, 4), "1500", 1, "1500",
    "CW (solo)", "160", "BARC / Stew Perry", "http://www.kkn.net/stew/", NOT1MM,
    "Fecha muy dudosa: supuesto 4º sábado de diciembre - POR VERIFICAR; solo CW, útil solo para escuchar")
# --- invierno 2027 ---------------------------------------------------------
add("HA DX Contest 2027", nth_full_weekend(2027, 1, 3), "1200", 1, "1159",
    "CW+SSB", "160-80-40-20-15-10", "MRASZ (Hungría)", "https://ha-dx.com/en/contest-rules", NOT1MM,
    "3er fin de semana completo de enero (" + MEMRULE + "); Not1MM lo marca 'Active historically, but unconfirmed'")
add("UBA DX Contest SSB 2027", nth_full_weekend(2027, 1, -1), "1300", 1, "1300",
    "SSB", "80-40-20-15-10 (POR VERIFICAR)", "UBA (Bélgica)", "https://www.uba.be/", MEMURL,
    "Último fin de semana completo de enero (" + MEMRULE + ")")
add("EU DX Contest (EUDXC) 2027", nth_full_weekend(2027, 2, 1), "1200", 1, "1159",
    "CW+SSB", "160-80-40-20-15-10", "EUDXF", "https://www.eudx-contest.com/rules/", NOT1MM,
    "1er fin de semana completo de febrero (" + MEMRULE + "); intercambio UE: RS + región (4 caracteres)")
add("PACC Contest 2027", nth_full_weekend(2027, 2, 2), "1200", 1, "1200",
    "CW+SSB", "160-80-40-20-15-10", "VERON (Países Bajos)", "https://www.veron.nl/", MEMURL,
    "2º fin de semana completo de febrero (" + MEMRULE + "); fuera de PA se trabaja solo PA")
add("ARRL International DX Contest CW 2027 (escucha)", nth_full_weekend(2027, 2, 3), "0000", 1, "2359",
    "CW", "160-80-40-20-15-10", "ARRL", "https://www.arrl.org/arrl-dx", MEMURL,
    "3er fin de semana completo de febrero (" + MEMRULE + ")")
add("CQ 160-Meter Contest SSB 2027", nth_full_weekend(2027, 2, -1), "2200", 1, "2200",
    "SSB", "160", "CQ Magazine", "https://www.cq160.com/rules.htm", MEMURL,
    "Último fin de semana completo de febrero, de viernes 2200Z a domingo 2200Z (" + MEMRULE + ")",
    start_day_offset=-1)
add("REF Contest SSB 2027", nth_full_weekend(2027, 2, -1), "0600", 1, "1800",
    "SSB", "80-40-20-15-10", "REF (Francia)", "https://concours.r-e-f.org/reglements/actuels/reg_cdfhfdx.pdf", NOT1MM,
    "Último fin de semana completo de febrero (" + MEMRULE + "); fuera de F se trabaja solo F")
# --- primavera 2027 --------------------------------------------------------
add("ARRL International DX Contest SSB 2027", nth_full_weekend(2027, 3, 1), "0000", 1, "2359",
    "SSB", "160-80-40-20-15-10", "ARRL", "https://www.arrl.org/arrl-dx", MEMURL,
    "1er fin de semana completo de marzo (" + MEMRULE + "); DX solo trabaja W/VE; DX envía RS + potencia")
add("Russian DX Contest (RDXC) 2027", nth_full_weekend(2027, 3, 3), "1200", 1, "1159",
    "CW+SSB", "160-80-40-20-15-10", "RDXC / SRR", "https://www.rdxc.org/rules_eng", NOT1MM,
    "3er fin de semana completo de marzo (" + MEMRULE + ")")
add("CQ WPX Contest SSB 2027", nth_full_weekend(2027, 3, -1), "0000", 1, "2359",
    "SSB", "160-80-40-20-15-10", "CQ Magazine", "https://www.cqwpx.com/rules.htm", NOT1MM + " (plugin WPX CW)",
    "Último fin de semana completo de marzo (" + MEMRULE + "); intercambio RS + nº de serie")
add("SP DX Contest 2027", nth_full_weekend(2027, 4, 1), "1500", 1, "1500",
    "CW+SSB", "160-80-40-20-15-10", "PZK (Polonia)", "https://spdxcontest.pzk.org.pl/", MEMURL,
    "1er fin de semana completo de abril (" + MEMRULE + "); fuera de SP se trabaja solo SP")
add("Helvetia Contest 2027", nth_full_weekend(2027, 4, -1), "1300", 1, "1259",
    "CW+SSB+Digi", "160-80-40-20-15-10", "USKA (Suiza)",
    "https://www.uska.ch/events/uska-helvetia-contest-concours-helvetia-hf/", NOT1MM,
    "Último fin de semana completo de abril (" + MEMRULE + "); fuera de HB se trabaja solo HB")
add("ARI International DX Contest 2027", nth_full_weekend(2027, 5, 1), "1200", 1, "1159",
    "CW+SSB+RTTY", "80-40-20-15-10", "ARI (Italia)", "https://www.ari.it/", NOT1MM,
    "1er fin de semana completo de mayo (" + MEMRULE + ")")
C.append(["Concurso S.M. El Rey de España SSB 2027", "junio 2027 (fecha exacta POR VERIFICAR)", "SSB",
          "160-80-40-20-15-10", "URE", "https://concursos.ure.es/en/s-m-el-rey-de-espana-ssb/bases/",
          "Fecha no verificada (de memoria: un fin de semana de junio) - POR VERIFICAR; " + NOT1MM +
          "; intercambio EA: RS + provincia, no EA: RS + serie (Not1MM)"])
C.append(["Concurso S.M. El Rey de España CW 2027 (escucha)", "fecha POR VERIFICAR", "CW",
          "160-80-40-20-15-10", "URE", "https://concursos.ure.es/en/s-m-el-rey-de-espana-cw/bases/",
          "Fecha no verificada - POR VERIFICAR; " + NOT1MM])
# --- verano 2027 -----------------------------------------------------------
add("IARU HF World Championship 2027", nth_full_weekend(2027, 7, 2), "1200", 1, "1200",
    "CW+SSB", "160-80-40-20-15-10", "IARU (gestión ARRL)", "https://www.arrl.org/iaru-hf-championship", MEMURL,
    "2º fin de semana completo de julio (" + MEMRULE + "); intercambio RS + zona ITU (EA peninsular: 37)")
add("RSGB IOTA Contest 2027", nth_full_weekend(2027, 7, -1), "1200", 1, "1200",
    "CW+SSB", "80-40-20-15-10", "RSGB", "https://www.rsgbcc.org/hf/rules/2025/riota.shtml",
    NOT1MM + " (bases 2025)", "Último fin de semana completo de julio (" + MEMRULE + ")")
add("European HF Championship (EUHFC) 2027", nth_saturday(2027, 8, 1), "1200", 0, "2359",
    "CW+SSB", "160-80-40-20-15-10", "S5CC (Eslovenia)", "https://euhf.s5cc.eu/", NOT1MM,
    "Not1MM indica 'First Saturday of August, 12:00-24:00 UTC' (fuente secundaria; de memoria podría ser el 2º sábado) - POR VERIFICAR; solo cuentan QSO con Europa")
add("All Asian DX Contest Phone 2027", nth_full_weekend(2027, 9, 1), "0000", 1, "2359",
    "SSB", "160-80-40-20-15-10", "JARL", "https://www.jarl.org/English/4_Library/A-4-3_Contests/aadx_eng.html", NOT1MM,
    "1er fin de semana completo de septiembre (" + MEMRULE + "); fuera de Asia se trabaja solo Asia")
add("IARU Region 1 Field Day SSB 2027", nth_full_weekend(2027, 9, 1), "1300", 1, "1259",
    "SSB", "160-80-40-20-15-10", "IARU R1 (sociedades nacionales; página DARC)",
    "https://www.darc.de/der-club/referate/conteste/iaru-region-1-fieldday/en/", NOT1MM,
    "1er fin de semana completo de septiembre (" + MEMRULE + "); estaciones portables de campo")
add("WAE DX Contest SSB 2027", nth_full_weekend(2027, 9, 2), "0000", 1, "2359",
    "SSB", "80-40-20-15-10", "DARC", "https://www.darc.de/der-club/referate/conteste/wae-dx-contest/", MEMURL,
    "2º fin de semana completo de septiembre (" + MEMRULE + "); europeos solo trabajan fuera de Europa; QTC")
# --- otoño 2027 ------------------------------------------------------------
add("Oceania DX Contest Phone 2027", nth_full_weekend(2027, 10, 1), "0600", 1, "0600",
    "SSB", "160-80-40-20-15-10", "WIA / NZART", "https://www.oceaniadxcontest.com/", NOT1MM,
    "1er fin de semana completo de octubre (" + MEMRULE + "); fuera de OC se trabaja solo OC")
add("Worked All Germany (WAG) 2027", nth_full_weekend(2027, 10, 3), "1500", 1, "1459",
    "CW+SSB", "80-40-20-15-10", "DARC", "https://www.darc.de/der-club/referate/conteste/wag-contest/regeln/", NOT1MM,
    "3er fin de semana completo de octubre (" + MEMRULE + "); fuera de DL se trabaja solo DL")
add("CQ WW DX Contest SSB 2027 (OBJETIVO)", nth_full_weekend(2027, 10, -1), "0000", 1, "2359",
    "SSB", "160-80-40-20-15-10", "CQ Magazine", "https://www.cqww.com/rules.htm", NOT1MM,
    "Último fin de semana completo de octubre (" + MEMRULE + "); coincide con el plan del autor (30-31 oct)")


def main():
    with open(OUT / "contests_calendar.csv", "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(["concurso", "fechas_utc", "modo", "bandas", "organizador", "url_bases", "verificado"])
        for row in C:
            w.writerow(row)
    for row in C:
        print(row[1], "|", row[0])


if __name__ == "__main__":
    main()
