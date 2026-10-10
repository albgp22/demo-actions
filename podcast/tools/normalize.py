"""Normalizador de texto español para síntesis de voz (TTS).

Convierte el guion legible (con símbolos, unidades, siglas y fórmulas) en texto
"hablado": números y unidades en palabras, siglas deletreadas, fórmulas leídas.
"""
import re
from num2words import num2words

# ----------------------------------------------------------------- números
def _int_words(n: int, masc_before_noun: bool = False) -> str:
    w = num2words(n, lang="es")
    if masc_before_noun:
        # uno -> un, veintiuno -> veintiún, treinta y uno -> treinta y un
        w = re.sub(r"\bveintiuno\b", "veintiún", w)
        w = re.sub(r"\buno\b", "un", w)
    return w


def number_words(txt: str, before_noun: bool = False) -> str:
    """'12' -> 'doce'; '1,5' -> 'uno coma cinco'; '0,05' -> 'cero coma cero cinco'."""
    txt = txt.replace(".", "") if re.fullmatch(r"\d{1,3}(\.\d{3})+", txt) else txt
    if "," in txt:
        ent, dec = txt.split(",", 1)
        if len(dec) <= 2 and dec[0] != "0":  # 4,12 -> "cuatro coma doce"
            dec_words = _int_words(int(dec))
        else:  # 0,05 -> "cero coma cero cinco"; 7,050 -> dígito a dígito
            dec_words = " ".join(num2words(int(d), lang="es") if d != "0" else "cero" for d in dec)
        return f"{_int_words(int(ent))} coma {dec_words}"
    return _int_words(int(txt), before_noun)


# ---------------------------------------------------------------- unidades
# símbolo -> (singular, plural)
UNITS = {
    "GHz": ("gigahercio", "gigahercios"), "MHz": ("megahercio", "megahercios"),
    "kHz": ("kilohercio", "kilohercios"), "Hz": ("hercio", "hercios"),
    "MΩ": ("megaohmio", "megaohmios"), "kΩ": ("kiloohmio", "kiloohmios"),
    "Ω": ("ohmio", "ohmios"),
    "kV": ("kilovoltio", "kilovoltios"), "mV": ("milivoltio", "milivoltios"),
    "µV": ("microvoltio", "microvoltios"), "V": ("voltio", "voltios"),
    "mA": ("miliamperio", "miliamperios"), "µA": ("microamperio", "microamperios"),
    "A": ("amperio", "amperios"),
    "kW": ("kilovatio", "kilovatios"), "mW": ("milivatio", "milivatios"),
    "W": ("vatio", "vatios"),
    "µF": ("microfaradio", "microfaradios"), "nF": ("nanofaradio", "nanofaradios"),
    "pF": ("picofaradio", "picofaradios"), "F": ("faradio", "faradios"),
    "mH": ("milihenrio", "milihenrios"), "µH": ("microhenrio", "microhenrios"),
    "H": ("henrio", "henrios"),
    "dBi": ("decibelio isótropo", "decibelios isótropos"),
    "dBd": ("decibelio sobre dipolo", "decibelios sobre dipolo"),
    "dBm": ("decibelio sobre un milivatio", "decibelios sobre un milivatio"),
    "dBW": ("decibelio sobre un vatio", "decibelios sobre un vatio"),
    "dB": ("decibelio", "decibelios"),
    "km": ("kilómetro", "kilómetros"), "cm": ("centímetro", "centímetros"),
    "mm": ("milímetro", "milímetros"), "m": ("metro", "metros"),
    "ms": ("milisegundo", "milisegundos"), "µs": ("microsegundo", "microsegundos"),
    "s": ("segundo", "segundos"),
    "V/m": ("voltio por metro", "voltios por metro"),
    "ºC": ("grado centígrado", "grados centígrados"),
}
_unit_alt = "|".join(sorted((re.escape(u) for u in UNITS), key=len, reverse=True))
_UNIT_RE = re.compile(rf"(?<![\w.])(\d+(?:[.,]\d+)?)\s*({_unit_alt})(?![\wΩµ])")


def _unit_sub(m: re.Match) -> str:
    num, unit = m.group(1), m.group(2)
    sing, plur = UNITS[unit]
    is_one = num == "1"
    words = number_words(num, before_noun=True)
    if is_one:
        return f"un {sing}"
    # decimales o cualquier otro número -> plural ("uno coma cinco voltios")
    if "," in num:
        words = number_words(num)
    return f"{words} {plur}"


# ------------------------------------------------------------------ siglas
LETTERS = {
    "A": "a", "B": "be", "C": "ce", "D": "de", "E": "e", "F": "efe", "G": "ge",
    "H": "hache", "I": "i", "J": "jota", "K": "ka", "L": "ele", "M": "eme",
    "N": "ene", "O": "o", "P": "pe", "Q": "cu", "R": "erre", "S": "ese",
    "T": "te", "U": "u", "V": "uve", "W": "uve doble", "X": "equis",
    "Y": "i griega", "Z": "zeta",
}

# palabras/siglas -> pronunciación (sensible a mayúsculas, con límites de palabra)
WORDS = {
    "ROE": "erre o e", "SSB": "ese ese be", "BLU": "be ele u", "FM": "efe eme",
    "AM": "a eme", "CW": "ce uve doble", "QSO": "cu ese o", "CQ": "ce cu",
    "PTT": "pe te te", "VFO": "uve efe o", "UHF": "u hache efe",
    "VHF": "uve hache efe", "SHF": "ese hache efe", "HF": "hache efe",
    "MF": "eme efe", "LF": "ele efe", "RF": "erre efe", "AF": "a efe",
    "FI": "efe i", "URE": "u erre e", "UIT": "u i te", "CEPT": "sept",
    "HAREC": "járek", "IARU": "i a erre u", "CNAF": "ce ene a efe",
    "NPN": "ene pe ene", "PNP": "pe ene pe", "PLL": "pe ele ele",
    "FET": "fet", "MOSFET": "mósfet", "LED": "led", "TVI": "te uve i",
    "DX": "de equis", "QRP": "cu erre pe", "QRM": "cu erre eme",
    "QRN": "cu erre ene", "QRZ": "cu erre zeta", "QSL": "cu ese ele",
    "QTH": "cu te hache", "QRT": "cu erre te", "QRV": "cu erre uve",
    "QSY": "cu ese i griega", "QRA": "cu erre a", "QRK": "cu erre ka",
    "QRO": "cu erre o", "QSB": "cu ese be", "QRX": "cu erre equis",
    "QRG": "cu erre ge", "QSA": "cu ese a", "QTR": "cu te erre",
    "CTCSS": "ce te ce ese ese", "RIT": "erre i te", "NF": "ene efe",
    "CA": "ce a", "CC": "ce ce", "AC": "a ce", "DC": "de ce",
    "PEP": "pep", "RMS": "erre eme ese", "EA": "e a", "EB": "e be",
    "EC": "e ce", "ED": "e de", "EE": "e e", "EF": "e efe", "EG": "e ge",
    "EH": "e hache", "ECO": "eco", "OSCAR": "óscar", "IC": "i ce",
    "CEM": "ce e eme", "EMC": "e eme ce", "BOE": "boe", "IEEE": "i triple e",
    "ITU": "i te u", "NTSC": "ene te ese ce", "WSPR": "wisper", "FT8": "efe te ocho",
    "SDR": "ese de erre", "PWM": "pe uve doble eme", "VOX": "vox",
    "SOS": "ese o ese", "ERC": "e erre ce", "REC": "rec", "COAX": "coax",
    "SWR": "ese uve doble erre", "OM": "o eme", "XYL": "equis i griega ele",
    "YL": "i griega ele", "CB": "ce be", "PMR": "pe eme erre",
    "TOR": "tor", "ADN": "a de ene", "TDMA": "te de eme a", "GPS": "ge pe ese",
    "USB": "u ese be", "LSB": "ele ese be", "RTTY": "erre te te i griega",
    "APRS": "a pe erre ese", "DMR": "de eme erre", "TETRA": "tétra",
    "Yagi": "yagui", "X-ray": "equis rei", "Mike": "Maik", "Quebec": "Kebek",
    "Oscar": "Óscar", "Mayday": "Meidéi", "RST": "erre ese te", "Pan-pan": "Pan, pan", "EIRP": "e i erre pe", "ERP": "e erre pe", "quad": "cuad",
    "stub": "estab", "stubs": "estabs", "dBW": "decibelios vatio", "Schottky": "Shótqui", "balun": "balún", "Balun": "Balún", "Ohm": "Om",
    "Kirchhoff": "Kirchof", "Maxwell": "Máxuel", "Colpitts": "Kólpits",
    "Hartley": "Jártli", "Faraday": "Farádei", "Zener": "Zéner",
    "Appleton": "Apelton", "Heaviside": "Jevisaid", "Morse": "Mórse",
    "Marconi": "Marcóni", "Hertz": "Herz", "Gaussiana": "gausiana",
    "Wi-Fi": "guaifai", "Bluetooth": "blutuz", "smartphone": "esmartfon",
    "squelch": "eskuelch", "software": "sófguer", "hardware": "járguer",
    "WhatsApp": "guasap", "Telegram": "Telegrám", "Internet": "Internet",
    "echolink": "ecolinc", "EchoLink": "Ecolinc", "D-STAR": "di estar",
    "C4FM": "ce cuatro efe eme", "CEPT.": "sept.", "MUF": "muf", "LUF": "luf",
    "IET": "i e te", "TDF": "te de efe", "ITC": "i te ce", "ETD": "e te de",
    "CTE": "ce te e", "ECO": "eco", "FEDI-EA": "fedi e a", "JPIT": "jota pe i te",
    "HAREC": "járek", "LGT": "ele ge te", "ICAO": "icao", "MHz.": "megahercios.",
}
_word_alt = "|".join(sorted((re.escape(w) for w in WORDS), key=len, reverse=True))
_WORD_RE = re.compile(rf"(?<![\w-])({_word_alt})(?![\w-])")


# ----------------------------------------------------------------- fórmulas
FORMULA_TOKENS = {
    "≈": "aproximadamente igual a", "≥": "mayor o igual que", "≤": "menor o igual que",
    "=": "igual a", "·": "por", "×": "por", "*": "por", "÷": "entre", "/": "entre",
    "+": "más", "−": "menos", "–": "menos", "-": "menos", "²": "al cuadrado",
    "³": "al cubo", "√": "raíz cuadrada de", "π": "pi", "λ": "landa", "Ω": "ohmios",
    "θ": "teta", "α": "alfa", "φ": "fi", "ω": "omega", "β": "beta", "τ": "tau", "Δ": "delta", "ρ": "rho", "η": "eta",
    "%": "por ciento", "^": "elevado a", "_": "sub", ":": "a", "(": "", ")": "",
    "[": "", "]": "", ",": "",
    "log": "logaritmo decimal de", "dB": "decibelios", "sen": "seno", "cos": "coseno",
    "tan": "tangente", "arctan": "arcotangente", "Hz": "hercios", "ln": "logaritmo neperiano de",
}
_FTOK = re.compile(r"\d+(?:,\d+)?|[λπβτΔρηθαφω]|[A-Za-z]+|[≈≥≤=·×*÷/+−–\-²³√()\[\]:_%Ω^,]")


def speak_formula(f: str) -> str:
    out = []
    prev_num = None
    for m in _FTOK.finditer(f):
        t = m.group(0)
        if prev_num is not None and t in UNITS:
            sing, plur = UNITS[t]
            out.append(sing if prev_num == "1" else plur)
            prev_num = None
            continue
        prev_num = t if re.fullmatch(r"\d+(?:,\d+)?", t) else None
        if t in FORMULA_TOKENS:
            out.append(FORMULA_TOKENS[t])
        elif re.fullmatch(r"\d+(?:,\d+)?", t):
            out.append(number_words(t))
        else:
            out.append(" ".join(LETTERS.get(c.upper(), c) for c in t))
    return re.sub(r"\s+", " ", " ".join(out)).strip()


_CALL_RE = re.compile(r"(?<![A-Za-z0-9])([A-Z]{1,2}\d[A-Z]{1,4})(?![A-Za-z0-9])")


def speak_callsign(m: re.Match) -> str:
    out = []
    for c in m.group(1):
        out.append(number_words(c) if c.isdigit() else LETTERS[c])
    return " ".join(out)


# ------------------------------------------------------------------- global
def normalize(text: str) -> str:
    # recomendaciones CEPT tipo T/R 61-01
    text = re.sub(r"\bT/R (\d+)-0(\d)\b", r"te erre \1 cero \2", text)
    # abreviaturas con puntos
    text = re.sub(r"\bp\.i\.r\.e\b\.?", "pe i erre e", text)
    text = re.sub(r"\bp\.r\.a\b\.?", "pe erre a", text)
    text = re.sub(r"\bp\.c\.e\b\.?", "pe ce e", text)
    # referencias normativas tipo IET/1311/2013
    text = re.sub(r"\b([A-Z]{2,4})/(\d{1,4})/(\d{4})\b", r"\1 barra \2 barra \3", text)
    # fórmulas entre acentos graves
    text = re.sub(r"`([^`]+)`", lambda m: " " + speak_formula(m.group(1)) + " ", text)
    # relaciones tipo 1,5:1  ->  uno coma cinco a uno
    text = re.sub(
        r"(\d+(?:,\d+)?):(\d+)",
        lambda m: f"{number_words(m.group(1))} a {number_words(m.group(2))}",
        text,
    )
    text = _UNIT_RE.sub(_unit_sub, text)
    text = _CALL_RE.sub(speak_callsign, text)
    text = re.sub(r"(\d+)\s*%", lambda m: f"{number_words(m.group(1))} por ciento", text)
    text = _WORD_RE.sub(lambda m: WORDS[m.group(1)], text)
    text = re.sub(r"\bQ\b", "cu", text)
    text = re.sub(r"(?<![\d/])(\d{1,4})/(\d{4})(?!\d)",
                  lambda m: f"{number_words(m.group(1))} barra {number_words(m.group(2))}", text)
    text = re.sub(r"\b[Cc]apas? ([DEF])([12])?\b",
                  lambda m: m.group(0)[: m.start(1) - m.start(0)] + {"D": "de", "E": "e", "F": "efe"}[m.group(1)]
                  + (" " + number_words(m.group(2)) if m.group(2) else ""), text)
    # números sueltos restantes
    text = re.sub(r"\d+(?:,\d+)?", lambda m: number_words(m.group(0)), text)
    # limpieza
    text = text.replace("…", "...").replace("«", "").replace("»", "").replace("—", ", ")
    text = re.sub(r"[*_#]+", "", text)
    text = re.sub(r"\s+", " ", text).strip()
    return re.sub(r"\s+([,.;:?!])", r"\1", text)


if __name__ == "__main__":
    tests = [
        "Con 12 V y 4 Ω circulan 3 A, es decir `I = V / R`.",
        "La banda de 40 m va de 7 a 7,2 MHz y la de 2 m de 144 a 146 MHz.",
        "Una ROE de 1,5:1 es aceptable; con 100 W, la potencia reflejada es mínima.",
        "Un condensador de 100 pF y una bobina de 2,5 µH: `f = 1 / (2 π √(L C))`.",
        "21 metros, 31 vatios, 1 kHz, 101 MHz y 0,05 A. 20 dB equivalen a x100. El año 2022.",
        "Una antena Yagi de 3 dBi sobre el balun; la licencia HAREC es de la CEPT; EA4ABC.",
    ]
    for t in tests:
        print(t, "\n  ->", normalize(t))
