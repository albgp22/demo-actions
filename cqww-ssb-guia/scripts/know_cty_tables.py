#!/usr/bin/env python3
"""Deriva tablas de conocimiento de concurso a partir del fichero CTY (JSON).

Entrada : data/cty/cty_not1mm.json  (AD1C country files, empaquetado por Not1MM;
          clave 'version' = fecha de la versión del CTY, p. ej. 20260603)
Salidas : data/knowledge/wae.csv
          data/knowledge/cq_zones.csv               (zona, descripcion, fuente)
          data/knowledge/cq_zones_entidades.csv     (detalle por zona)
          data/knowledge/continentes_trampa.csv     (entidades con continente/zona
                                                      poco intuitivos desde Madrid)
          data/knowledge/cty_resumen.txt            (recuento DXCC/WAE)

Convenciones del CTY: 'long' es positiva hacia el OESTE (convención cty.dat);
'exact_match' = True indica indicativo completo (no prefijo).
Las entidades WAE que no son DXCC llevan '(not DXCC)' en el nombre.

Uso:  python3 scripts/know_cty_tables.py [ruta_proyecto]
"""
import collections
import csv
import json
import pathlib
import sys

ROOT = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path(__file__).resolve().parents[1]
CTY = ROOT / "data" / "cty" / "cty_not1mm.json"
OUT = ROOT / "data" / "knowledge"
OUT.mkdir(parents=True, exist_ok=True)

# Nombres de las 40 zonas CQ tal como se suelen citar en la lista CQ WAZ.
# FUENTE: conocimiento previo, contrastado (40/40) con data/geo/cqzones.geojson
# (HB9HIL, hamradio-zones-geojson). La lista oficial CQ WAZ no se pudo consultar
# en esta sesión -> POR VERIFICAR contra cq-amateur-radio.com. Nombres ES: traducción propia.
ZONE_NAMES = {
    1: ("Northwestern Zone of North America", "Noroeste de Norteamérica"),
    2: ("Northeastern Zone of North America", "Noreste de Norteamérica"),
    3: ("Western Zone of North America", "Oeste de Norteamérica"),
    4: ("Central Zone of North America", "Centro de Norteamérica"),
    5: ("Eastern Zone of North America", "Este de Norteamérica"),
    6: ("Southern Zone of North America", "Sur de Norteamérica"),
    7: ("Central American Zone", "Centroamérica"),
    8: ("West Indies Zone", "Antillas / Caribe"),
    9: ("Northern Zone of South America", "Norte de Sudamérica"),
    10: ("Western Zone of South America", "Oeste de Sudamérica"),
    11: ("Central Zone of South America", "Centro de Sudamérica"),
    12: ("Southwest Zone of South America", "Suroeste de Sudamérica"),
    13: ("Southeast Zone of South America", "Sureste de Sudamérica"),
    14: ("Western Zone of Europe", "Europa occidental"),
    15: ("Central European Zone", "Europa central"),
    16: ("Eastern Zone of Europe", "Europa oriental"),
    17: ("Western Zone of Siberia", "Siberia occidental / Asia central"),
    18: ("Central Siberian Zone", "Siberia central"),
    19: ("Eastern Siberian Zone", "Siberia oriental"),
    20: ("Balkan Zone", "Balcanes / Mediterráneo oriental"),
    21: ("Southwestern Zone of Asia", "Suroeste de Asia (Oriente Medio)"),
    22: ("Southern Zone of Asia", "Sur de Asia (subcontinente indio)"),
    23: ("Central Zone of Asia", "Asia central (Mongolia, oeste de China)"),
    24: ("Eastern Zone of Asia", "Este de Asia (China oriental)"),
    25: ("Japanese Zone", "Japón y Corea"),
    26: ("Southeastern Zone of Asia", "Sudeste asiático continental"),
    27: ("Philippine Zone", "Filipinas y Micronesia occidental"),
    28: ("Indonesian Zone", "Indonesia y alrededores"),
    29: ("Western Zone of Australia", "Australia occidental"),
    30: ("Eastern Zone of Australia", "Australia oriental"),
    31: ("Central Pacific Zone", "Pacífico central"),
    32: ("New Zealand Zone", "Nueva Zelanda y Pacífico sur"),
    33: ("Northwestern Zone of Africa", "Noroeste de África"),
    34: ("Northeastern Zone of Africa", "Noreste de África"),
    35: ("Central Zone of Africa", "África occidental/central"),
    36: ("Equatorial Zone of Africa", "África ecuatorial"),
    37: ("Eastern Zone of Africa", "África oriental"),
    38: ("South African Zone", "África austral"),
    39: ("Madagascar Zone", "Madagascar y océano Índico sur"),
    40: ("North Atlantic Zone", "Atlántico norte / Ártico"),
}

# Notas didácticas (desde Madrid) para entidades "trampa". Los datos de
# continente/zona se leen SIEMPRE del CTY; las notas solo explican.
TRICKY = [
    ("EA", "Referencia: Madrid/península = EU, zona CQ 14, zona ITU 37."),
    ("EA6", "Baleares: EU, misma zona 14 que la península."),
    ("EA8", "Canarias: cuenta como ÁFRICA (AF), zona 33. QSO EA->EA8 = otro continente."),
    ("EA9", "Ceuta y Melilla: ÁFRICA (AF), zona 33."),
    ("CT", "Portugal continental: EU, zona 14."),
    ("CT3", "Madeira: ÁFRICA (AF), zona 33."),
    ("CU", "Azores: EUROPA (EU), zona 14, pese a estar en mitad del Atlántico."),
    ("ZB", "Gibraltar: EU, zona 14."),
    ("C3", "Andorra: EU, zona 14."),
    ("CN", "Marruecos: AF, zona 33 (vecino inmediato, contacto de 3 puntos)."),
    ("IG9", "Italia africana (Lampedusa/Pantelleria): entidad WAE, AF, zona 33."),
    ("IT9", "Sicilia: entidad WAE (no DXCC), EU, zona 15."),
    ("9H", "Malta: EU, zona 15."),
    ("3V", "Túnez: AF, zona 33."),
    ("SU", "Egipto: AF, zona 34."),
    ("4X", "Israel: ASIA (AS), zona 20."),
    ("5B", "Chipre: ASIA (AS), zona 20."),
    ("ZC4", "Bases británicas de Chipre: AS, zona 20."),
    ("TA", "Turquía asiática: AS, zona 20."),
    ("TA1", "Turquía europea: entidad WAE, EU, zona 20 (misma zona que TA)."),
    ("SV/a", "Monte Athos: EU, zona 20."),
    ("4L", "Georgia: AS, zona 21."),
    ("UA", "Rusia europea: EU; zona 16 por defecto, pero algunos prefijos (p. ej. R1I, R8F/R9F, R8G/R9G, R8X/R9X) son zona 17."),
    ("UA2", "Kaliningrado: EU, zona 15."),
    ("UA9", "Rusia asiática: AS; zonas 16 a 19 y 23 según la región (ver detalle)."),
    ("UN", "Kazajistán: AS, zona 17."),
    ("R1FJ", "Tierra de Francisco José: EU, zona 40."),
    ("JW", "Svalbard: EU, zona 40."),
    ("JW/b", "Isla del Oso: entidad WAE, EU, zona 40 (identificada por indicativo exacto)."),
    ("JX", "Jan Mayen: EU, zona 40."),
    ("TF", "Islandia: EU, zona 40."),
    ("OX", "Groenlandia: NORTEAMÉRICA (NA), zona 40."),
    ("4U1I", "Sede de la UIT (Ginebra): entidad DXCC propia, EU, zona 14."),
    ("4U1V", "Centro Internacional de Viena: entidad WAE (no DXCC), EU, zona 15."),
    ("4U1U", "Sede de la ONU (Nueva York): entidad DXCC propia, NA, zona 5."),
    ("1A", "Orden de Malta (Roma): entidad DXCC propia, EU, zona 15."),
    ("VP8", "Malvinas: SA, zona 13."),
    ("ZS", "Sudáfrica: AF, zona 38."),
    ("D4", "Cabo Verde: AF, zona 35."),
    ("K", "EE. UU.: NA; zonas 3, 4 y 5 según el estado (zona por defecto en CTY: 5)."),
    ("VE", "Canadá: NA; zonas 1 a 5 según la provincia."),
    ("VK", "Australia: OC; zonas 29 y 30."),
    ("BY", "China: AS; zonas 23 y 24."),
]


def main():
    data = json.loads(CTY.read_text(encoding="utf-8"))
    version = data.pop("version", "?")
    by_entity = collections.defaultdict(list)
    for key, v in data.items():
        by_entity[v["primary_pfx"]].append((key, v))

    entities = {}
    for pfx, items in by_entity.items():
        # registro "base": el propio prefijo primario si existe; si no, el primero
        base = next((v for k, v in items if k == pfx), items[0][1])
        entities[pfx] = base

    wae_only = {p: v for p, v in entities.items() if "(not DXCC)" in v["entity"]}
    dxcc = {p: v for p, v in entities.items() if "(not DXCC)" not in v["entity"]}

    # ---- zonas presentes por entidad (prefijos no exactos; las WAE de indicativo
    #      exacto se añaden con su zona base)
    zone_ents = collections.defaultdict(set)
    ent_zones = collections.defaultdict(set)
    zone_pfx = collections.defaultdict(list)   # (entidad, zona) -> prefijos
    for pfx, items in by_entity.items():
        non_exact = [(k, v) for k, v in items if not v["exact_match"]]
        src = non_exact if non_exact else [(pfx, entities[pfx])]
        for k, v in src:
            zone_ents[v["cq"]].add(pfx)
            ent_zones[pfx].add(v["cq"])
            zone_pfx[(pfx, v["cq"])].append(k)

    # ---- resumen
    lines = [
        f"CTY version: {version}",
        f"Entidades (prefijos primarios) en CTY: {len(entities)}",
        f"  - DXCC: {len(dxcc)}",
        f"  - Solo WAE (no DXCC): {len(wae_only)} -> {', '.join(sorted(wae_only))}",
    ]
    cont_count = collections.Counter(v["continent"] for v in dxcc.values())
    lines.append("Entidades DXCC por continente (CTY): " + ", ".join(f"{c}={n}" for c, n in sorted(cont_count.items())))
    (OUT / "cty_resumen.txt").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines))

    # ---- wae.csv
    dxcc_parent = {  # relación DXCC de las entidades WAE (conocimiento previo, coherente con CTY)
        "IT9": "Italia (I)", "IG9": "Italia (I)", "GM/s": "Escocia (GM)",
        "JW/b": "Svalbard (JW)", "4U1V": "Austria (OE)", "TA1": "Turquía (TA)",
    }
    with open(OUT / "wae.csv", "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(["prefijo", "entidad", "continente", "zona_cq", "nota"])
        for pfx in sorted(wae_only):
            items = by_entity[pfx]
            pref = sorted(k for k, v in items if not v["exact_match"])
            n_exact = sum(1 for k, v in items if v["exact_match"])
            v = entities[pfx]
            if pref:
                ident = "prefijos " + " ".join(pref[:16]) + (" ..." if len(pref) > 16 else "")
            else:
                ident = "solo por indicativo exacto"
            ident += f"; {n_exact} indicativos exactos en CTY"
            nota = (f"En DXCC cuenta como {dxcc_parent.get(pfx, '?')}; en CQ WW es multiplicador de país propio. "
                    f"Zona ITU {v['itu']}. Identificación CTY: {ident}. Fuente: CTY VER{version}.")
            w.writerow([pfx, v["entity"].replace(" (not DXCC)", ""), v["continent"], v["cq"], nota])

    # ---- contraste de nombres de zona con el GeoJSON de HB9HIL (si está en el proyecto)
    geo_path = ROOT / "data" / "geo" / "cqzones.geojson"
    geo_names = {}
    if geo_path.exists():
        g = json.loads(geo_path.read_text(encoding="utf-8"))
        geo_names = {f["properties"]["cq_zone_number"]: f["properties"]["cq_zone_name"] for f in g["features"]}
    n_match = sum(1 for z, (en, _) in ZONE_NAMES.items() if geo_names.get(z, "").lower() == en.lower())
    print(f"Nombres de zona que coinciden con cqzones.geojson (HB9HIL): {n_match}/40")

    # ---- cq_zones.csv y detalle
    with open(OUT / "cq_zones.csv", "w", newline="", encoding="utf-8") as fh, \
         open(OUT / "cq_zones_entidades.csv", "w", newline="", encoding="utf-8") as fh2:
        w = csv.writer(fh)
        w2 = csv.writer(fh2)
        w.writerow(["zona", "descripcion", "fuente"])
        w2.writerow(["zona", "nombre_en", "nombre_es", "n_entidades", "entidades_completas", "entidades_parciales"])
        for z in range(1, 41):
            en, es = ZONE_NAMES[z]
            ents = sorted(zone_ents.get(z, set()))
            full = [p for p in ents if ent_zones[p] == {z}]
            partial = [p for p in ents if ent_zones[p] != {z}]

            def fmt(p):
                name = entities[p]["entity"].replace(" (not DXCC)", "*")
                return f"{p} ({name})"
            sample = ", ".join(fmt(p) for p in full[:12]) + (f" (+{len(full) - 12} más)" if len(full) > 12 else "")

            def fmt_part(p):
                ks = sorted(zone_pfx[(p, z)], key=lambda s: (len(s), s))[:4]
                return f"{p} ({entities[p]['entity']}; p. ej. {'/'.join(ks)})"
            part = "; ".join(fmt_part(p) for p in partial)
            desc = f"{es} [{en}]."
            if full:
                desc += f" Entidades: {sample}."
            if part:
                desc += f" Parcialmente: {part}."
            same = geo_names.get(z, "").lower() == en.lower()
            fuente = (f"Entidades y zonas: CTY VER{version} (cty_not1mm.json, AD1C/Not1MM). Nombre EN: "
                      + ("coincide con data/geo/cqzones.geojson (HB9HIL)" if same else "NO coincide con cqzones.geojson")
                      + "; lista oficial CQ WAZ no consultada (POR VERIFICAR). Nombre ES: traducción propia")
            w.writerow([z, desc, fuente])
            w2.writerow([z, en, es, len(ents), " ".join(full), " ".join(partial)])

    # ---- continentes_trampa.csv
    with open(OUT / "continentes_trampa.csv", "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(["prefijo", "entidad", "continente", "zona_cq", "zona_itu", "zonas_cq_todas", "nota"])
        for pfx, nota in TRICKY:
            if pfx not in entities:
                print("AVISO: no encontrado en CTY", pfx)
                continue
            v = entities[pfx]
            zs = " ".join(str(z) for z in sorted(ent_zones[pfx]))
            w.writerow([pfx, v["entity"].replace(" (not DXCC)", " (WAE)"), v["continent"], v["cq"], v["itu"], zs, nota])

    # ---- detalle de Rusia por zona (prefijos no exactos)
    det = collections.defaultdict(list)
    for pfx in ("UA", "UA9"):
        for k, v in by_entity[pfx]:
            if not v["exact_match"]:
                det[(entities[pfx]["entity"], v["continent"], v["cq"])].append(k)
    with open(OUT / "rusia_zonas.csv", "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(["entidad", "continente", "zona_cq", "n_prefijos", "ejemplos_prefijos"])
        for (e, c, z), ks in sorted(det.items(), key=lambda t: (t[0][0], t[0][2])):
            w.writerow([e, c, z, len(ks), " ".join(sorted(ks)[:25])])


if __name__ == "__main__":
    main()
