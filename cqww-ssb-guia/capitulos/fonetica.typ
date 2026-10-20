// Alfabeto fonético del Reglamento de Radiocomunicaciones de la UIT
// (apéndice 14) y cifras como se dicen en inglés en los concursos.
#let letras = (
  A: "Alfa", B: "Bravo", C: "Charlie", D: "Delta", E: "Echo", F: "Foxtrot",
  G: "Golf", H: "Hotel", I: "India", J: "Juliett", K: "Kilo", L: "Lima",
  M: "Mike", N: "November", O: "Oscar", P: "Papa", Q: "Quebec", R: "Romeo",
  S: "Sierra", T: "Tango", U: "Uniform", V: "Victor", W: "Whiskey",
  X: "X-ray", Y: "Yankee", Z: "Zulu",
)
#let cifras = (
  "0": "Zero", "1": "One", "2": "Two", "3": "Three", "4": "Four",
  "5": "Five", "6": "Six", "7": "Seven", "8": "Eight", "9": "Nine",
)

// Deletrea un indicativo: "EA4XXX" → "Echo Alfa Four X-ray X-ray X-ray"
#let deletrear(indicativo) = upper(indicativo).clusters().map(ch => {
  if ch == "/" { "Stroke" } else { letras.at(ch, default: cifras.at(ch, default: ch)) }
}).join(" ")
