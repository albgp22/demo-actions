// Chuleta de una página para imprimir.
// Compilar: typst compile --font-path fonts chuleta.typ chuleta.pdf
#import "main.typ": cfg
#import "plantilla.typ": *
#import "capitulos/anexo-chuleta.typ": chuleta

#set document(title: "Chuleta CQ WW DX SSB", author: cfg.indicativo)
#set text(lang: "es", region: "ES", font: "Inter", size: 7.2pt, fill: c.tinta)
#set page(paper: "a4", margin: (x: 1.0cm, y: 0.9cm))
#chuleta(cfg)
