#!/usr/bin/env python3
"""Gera o documento ODT da Lista 2 — Marés Oceânicas IOC 5801"""

from odf.opendocument import OpenDocumentText
from odf.style import Style, TextProperties, ParagraphProperties, GraphicProperties
from odf.text import P, LineBreak
from odf.draw import Frame, Image
from odf.table import Table, TableColumn, TableRow, TableCell, TableHeaderRows
from pathlib import Path

BASE  = Path(r"C:\_STUDIES\USP-IOUSP\Medição, análise, previsão e modelagem do nível do mar\MARÉS OCEÂNICAS\mares_oceanicas\lista-02")
PLOTS = BASE / "plot"
OUT   = BASE / "amaroc_L2_adriano_caversan.odt"

doc = OpenDocumentText()

# ── Estilos de parágrafo ──────────────────────────────────────────────────────

def _ps(name, **pp):
    """Cria estilo de parágrafo com ParagraphProperties."""
    s = Style(name=name, family="paragraph")
    s.addElement(ParagraphProperties(**pp))
    return s

def _pts(name, pp_kw, tp_kw):
    """Cria estilo com ParagraphProperties + TextProperties."""
    s = Style(name=name, family="paragraph")
    s.addElement(ParagraphProperties(**pp_kw))
    s.addElement(TextProperties(**tp_kw))
    return s

s_title = _pts("DocTitle",
               {"textalign": "center", "margintop": "0.8cm", "marginbottom": "0.3cm"},
               {"fontsize": "16pt", "fontweight": "bold"})

s_sub = _pts("DocSub",
             {"textalign": "center", "marginbottom": "0.15cm"},
             {"fontsize": "11pt"})

s_h1 = _pts("QHead",
            {"margintop": "0.6cm", "marginbottom": "0.2cm"},
            {"fontsize": "13pt", "fontweight": "bold", "color": "#1F497D"})

s_h2 = _pts("SubHead",
            {"margintop": "0.3cm", "marginbottom": "0.1cm"},
            {"fontsize": "11pt", "fontweight": "bold"})

s_body = _pts("Body",
              {"marginbottom": "0.2cm", "margintop": "0.05cm", "textindent": "0cm"},
              {"fontsize": "11pt"})

s_cap = _pts("Caption",
             {"textalign": "center", "marginbottom": "0.4cm", "margintop": "0.05cm"},
             {"fontsize": "9pt", "fontstyle": "italic"})

s_tc_hdr = _pts("TCHdr",
                {"marginbottom": "0.05cm", "margintop": "0.05cm"},
                {"fontsize": "10pt", "fontweight": "bold"})

s_tc_cell = _pts("TCCell",
                 {"marginbottom": "0.05cm", "margintop": "0.05cm"},
                 {"fontsize": "10pt"})

for sty in (s_title, s_sub, s_h1, s_h2, s_body, s_cap, s_tc_hdr, s_tc_cell):
    doc.styles.addElement(sty)

# Estilo gráfico para frames de imagem
gs = Style(name="Graphics", family="graphic")
gs.addElement(GraphicProperties(
    marginleft="0cm", marginright="0cm",
    margintop="0.2cm", marginbottom="0cm",
    wrap="none",
    verticalpos="top",
    verticalrel="paragraph",
    horizontalpos="center",
    horizontalrel="paragraph"
))
doc.styles.addElement(gs)

# Estilo automático para tabela
ts = Style(name="TblBdy", family="table")
doc.automaticstyles.addElement(ts)

# ── Helpers ───────────────────────────────────────────────────────────────────

def add_p(text="", style="Body"):
    p = P(stylename=style)
    if text:
        p.addText(text)
    doc.text.addElement(p)

def add_h1(text):
    add_p(text, "QHead")

def add_h2(text):
    add_p(text, "SubHead")

def add_img(fname, width="16cm", height="9cm", caption=""):
    path = PLOTS / fname
    if not path.exists():
        add_p(f"[figura não encontrada: {fname}]", "Caption")
        return
    href = doc.addPicture(str(path))
    frame = Frame(stylename=gs, width=width, height=height,
                  anchortype="paragraph")
    frame.addElement(Image(href=href))
    p_img = P(stylename="Caption")
    p_img.addElement(frame)
    doc.text.addElement(p_img)
    if caption:
        add_p(caption, "Caption")

def add_table(headers, rows):
    tbl = Table(stylename="TblBdy")
    for _ in headers:
        tbl.addElement(TableColumn())
    # cabeçalho
    thr = TableHeaderRows()
    hr  = TableRow()
    for h in headers:
        tc = TableCell(valuetype="string")
        tc.addElement(P(stylename="TCHdr", text=h))
        hr.addElement(tc)
    thr.addElement(hr)
    tbl.addElement(thr)
    # dados
    for row in rows:
        tr = TableRow()
        for cell in row:
            tc = TableCell(valuetype="string")
            tc.addElement(P(stylename="TCCell", text=str(cell)))
            tr.addElement(tc)
        tbl.addElement(tr)
    doc.text.addElement(tbl)
    add_p()  # espaço após tabela

# ── CAPA ─────────────────────────────────────────────────────────────────────
add_p()
add_p("Universidade de São Paulo — Instituto Oceanográfico", "DocSub")
add_p("Programa de Pós-Graduação em Oceanografia / AMAROC", "DocSub")
add_p("Disciplina: IOC 5801 — Análise de Marés Oceânicas", "DocSub")
add_p()
add_p("2ª Lista de Exercícios — 1º Semestre de 2026", "DocTitle")
add_p()
add_p("Aluno: Adriano Caversan", "DocSub")
add_p("Data de entrega: 02 de junho de 2026", "DocSub")
add_p()

# ── Q1 ────────────────────────────────────────────────────────────────────────
add_h1("Questão 1 — Série temporal, análise harmônica e previsão (Cananeia)")
add_p(
    "A série de nível do mar de Cananeia (25°01'S; 47°55'W), ano de 2020, "
    "contém 8784 dados horários. Após a subtração da média (2,1404 m), a análise "
    "harmônica com o pacote t_tide identificou 67 constituintes padrão e utilizou "
    "8783 dos 8784 pontos. A previsão explica 78,5 % da variância original "
    "(var original = 0,14863 m²; var prevista = 0,11668 m²). "
    "A maré em Cananeia é de tipo misto com predomínio semidiurno, dominada pela "
    "componente M2 (A = 0,3596 m, g = 91,17°), seguida de S2 (0,2418 m), K2 (0,0699 m) "
    "e O1 (0,1039 m)."
)
add_img("q01_cananeia_serie.png",        caption="Fig. 1.1 — Série temporal de nível do mar, Cananeia 2020 (média subtraída).")
add_img("q01_cananeia_medido_prev.png",  caption="Fig. 1.2 — Nível medido (azul) e previsão de maré t_tide (vermelho), Cananeia 2020.")
add_img("q01_cananeia_detalhe_jan.png",  caption="Fig. 1.3 — Detalhe de janeiro de 2020: medido vs. previsão.")

# ── Q2 ────────────────────────────────────────────────────────────────────────
add_h1("Questão 2 — Série residual, análise estatística e espectral (Cananeia)")
add_p(
    "O resíduo (medição − previsão) apresenta média praticamente nula, confirmando "
    "ausência de viés. O desvio padrão de 0,1783 m é comparável à amplitude de maré de "
    "componentes climáticas não-harmônicas. A assimetria positiva (0,66) e curtose "
    "elevada (4,10) indicam eventos de surgência por tempestade com magnitudes acima "
    "da média. O espectro de amplitude do resíduo revela energia em períodos de 4–15 dias, "
    "associados a sistemas frontais e anticiclones que transitam pela costa sudeste."
)
add_table(
    ["Estatística", "Valor"],
    [["Média",           "0,0003 m"],
     ["Mediana",         "−0,0170 m"],
     ["Desvio padrão",   "0,1783 m"],
     ["Mínimo",          "−0,6019 m"],
     ["Máximo",          " 0,8614 m"],
     ["Curtose",         "4,0979"],
     ["Assimetria",      "0,6563"]]
)
add_img("q02_cananeia_residual.png",     caption="Fig. 2.1 — Nível do mar (azul) e série residual (vermelho), Cananeia 2020.")
add_img("q02_cananeia_residual_fft.png", caption="Fig. 2.2 — Espectro de amplitude (FFT, janela Hann, eixo 1–30 dias) do resíduo. Picos em ~10 e ~14 dias correspondem a sistemas sinóticos.")

# ── Q3 ────────────────────────────────────────────────────────────────────────
add_h1("Questão 3 — Nível médio do mar: filtro S24S25S25 (Cananeia)")
add_p(
    "O filtro de médias móveis S24S25S25 elimina as componentes de maré (períodos ≤ 24 h) "
    "e revela a variabilidade de baixa frequência. O nível médio horário tem DP = 0,1709 m "
    "(mínimo −0,41 m; máximo +0,49 m). Para a análise espectral, computou-se a média diária "
    "(366 pontos) antes da FFT, reduzindo o número de bins e concentrando a energia nos "
    "períodos de interesse. O espectro mostra dominância de variabilidade sinótica (5–20 dias), "
    "associada a frentes frias e sistemas de alta pressão que afetam a costa sudeste. "
    "O sinal anual (SA = 0,09 m da análise harmônica) não aparece como pico distinto no "
    "FFT por conter apenas 1 ciclo completo na série — limitação inerente ao método para "
    "registros de 1 ano."
)
add_table(
    ["Estatística", "Valor"],
    [["Média",          " 0,0002 m"],
     ["Desvio padrão",  " 0,1709 m"],
     ["Mínimo",         "−0,4064 m"],
     ["Máximo",         " 0,4937 m"],
     ["Curtose",        " 3,1516"],
     ["Assimetria",     " 0,3760"]]
)
add_img("q03_cananeia_nimed.png",     caption="Fig. 3.1 — Nível do mar (azul) e nível médio S24S25S25 (vermelho), Cananeia 2020.")
add_img("q03_cananeia_nimed_fft.png", caption="Fig. 3.2 — Espectro (FFT de média diária, 5–366 dias) do nível médio do mar. Pico sinótico em T ~ 5–20 dias.")

# ── Q4 ────────────────────────────────────────────────────────────────────────
add_h1("Questão 4 — Probabilidades de excedência/não excedência e períodos de retorno (Cananeia)")
add_p(
    "Distribuições normais foram ajustadas ao nível do mar total, à maré prevista e ao "
    "nível médio do mar. Os níveis de retorno mostram que a variabilidade meteorológica "
    "(nível médio) representa ~43 % do nível de retorno de 1 ano, evidenciando a "
    "importância da maré meteorológica nos estudos de eventos extremos em Cananeia. "
    "Os valores abaixo são relativos à média de cada série."
)
add_table(
    ["Série", "T = 0,5 a", "T = 1 a", "T = 2 a", "T = 5 a", "T = 10 a"],
    [["Nível do mar",     "1,35 m", "1,42 m", "1,48 m", "1,58 m", "1,64 m"],
     ["Maré (previsão)",  "1,20 m", "1,26 m", "1,31 m", "1,40 m", "1,46 m"],
     ["Nível médio",      "0,60 m", "0,63 m", "0,66 m", "0,70 m", "0,73 m"]]
)
add_img("q04_excedencia.png",    height="8cm", caption="Fig. 4.1 — Probabilidade de excedência.")
add_img("q04_nao_excedencia.png",height="8cm", caption="Fig. 4.2 — Probabilidade de não excedência.")
add_img("q04_retorno.png",       height="8cm", caption="Fig. 4.3 — Períodos de retorno.")

# ── Q5 ────────────────────────────────────────────────────────────────────────
add_h1("Questão 5 — Amplificação/atenuação e atrasos das componentes O1, K1, M2, S2 entre Cananeia e Ubatuba")
add_p(
    "A análise harmônica foi realizada também para Ubatuba (23°30'S; 45°07'W), que explica "
    "73,2 % da variância. A razão hrel = H_Can/H_Uba > 1 para M2 e S2 indica que Cananeia "
    "amplifica as componentes semidiurnas em relação a Ubatuba — possivelmente devido à "
    "geometria do estuário/baía de Cananeia. Para as componentes diurnas (O1, K1), as "
    "amplitudes são ligeiramente menores em Cananeia. As defasagens positivas (Cananeia "
    "adiantada) indicam que a onda de maré percorre a costa no sentido NE → SW, "
    "atingindo Cananeia antes de Ubatuba."
)
add_table(
    ["Comp.", "H_Can (m)", "g_Can (°)", "H_Uba (m)", "g_Uba (°)", "hrel (Can/Uba)", "Defas. (min)"],
    [["O1", "0,1039", "83,22", "0,1071", "80,71", "0,969", "10,8"],
     ["K1", "0,0575", "140,79", "0,0605", "140,02", "0,951",  "3,1"],
     ["M2", "0,3596", "91,17", "0,3101", "77,84", "1,160", "27,6"],
     ["S2", "0,2418", "97,81", "0,1853", "83,87", "1,305", "27,9"]]
)
add_img("q05_prev_o1.png", height="8cm", caption="Fig. 5.1 — Componente O1: Cananeia (azul) vs. Ubatuba (vermelho). hrel = 0,969; defas. = 10,8 min.")
add_img("q05_prev_k1.png", height="8cm", caption="Fig. 5.2 — Componente K1: Cananeia (azul) vs. Ubatuba (vermelho). hrel = 0,951; defas. = 3,1 min.")
add_img("q05_prev_m2.png", height="8cm", caption="Fig. 5.3 — Componente M2: Cananeia (azul) vs. Ubatuba (vermelho). hrel = 1,160; defas. = 27,6 min.")
add_img("q05_prev_s2.png", height="8cm", caption="Fig. 5.4 — Componente S2: Cananeia (azul) vs. Ubatuba (vermelho). hrel = 1,305; defas. = 27,9 min.")

# ── Q6 ────────────────────────────────────────────────────────────────────────
add_h1("Questão 6 — Comparação do nível médio: Cananeia vs. Ubatuba")
add_p(
    "As séries de nível médio (filtro S24S25S25) de Cananeia e Ubatuba foram comparadas "
    "por plotagem sobrepostas, diagrama de espalhamento e correlação cruzada. O skill score "
    "R² = 0,549 indica correlação moderada entre as duas estações (~250 km de separação), "
    "esperada para sinais de maré meteorológica que têm coerência regional mas também "
    "componentes locais. O viés nulo confirma a adequação da remoção das médias. O RMSE de "
    "0,106 m reflete diferenças na resposta local ao forçamento meteorológico. "
    "A correlação cruzada apresenta pico no lag = −5 h, indicando que Ubatuba lidera "
    "Cananeia em ~5 h no sinal de nível médio — sinal meteorológico propagando-se para SW."
)
add_table(
    ["Parâmetro", "Valor"],
    [["R² (skill score)",  "0,549"],
     ["Viés (Uba − Can)", "0,000 m"],
     ["RMSE",             "0,106 m"]]
)
add_img("q06_nimed_comparacao.png", caption="Fig. 6.1 — Nível médio do mar: Cananeia (azul) vs. Ubatuba (vermelho), 2020.")
add_img("q06_nimed_scatter.png",    height="11cm", caption="Fig. 6.2 — Diagrama de espalhamento do nível médio (linha diagonal = 1:1).")
add_img("q06_nimed_xcorr.png",      caption="Fig. 6.3 — Correlação cruzada (unnormalizada) do nível médio entre Cananeia e Ubatuba.")

# ── Q7 ────────────────────────────────────────────────────────────────────────
add_h1("Questão 7 — Correntes de maré em Santos: séries, análise harmônica e previsão")
add_p(
    "Os dados de correntes na região costeira de Santos (24°01'S; 46°20'W) cobrem "
    "~38,6 dias (1855 amostras a cada 30 min). A análise rotacional (corrente complexa u + iv) "
    "explica 91,5 % da variância sintetizada em EW e 71,5 % em NS. "
    "A análise por mínimos quadrados explica 84,9 % (EW) e 67,7 % (NS). "
    "A componente K1 é a mais energética (semieixo maior = 0,129 m/s), seguida de S2 "
    "(0,062 m/s). M2 tem SNR < 2 e não é significativa estatisticamente. "
    "O maior percentual explicado em EW reflete a propagação preferencial das correntes de "
    "maré ao longo da costa nessa direção."
)
add_img("q07_santos_series.png", height="10cm", caption="Fig. 7.1 — Séries de correntes EW (cima) e NS (baixo), Santos.")
add_img("q07_santos_prev.png",   height="10cm", caption="Fig. 7.2 — Correntes medidas (azul) vs. previsão de maré rotacional (vermelho): EW e NS, Santos.")

# ── Q8 ────────────────────────────────────────────────────────────────────────
add_h1("Questão 8 — Elipses das correntes de maré M2, S2, K1, O1 em Santos")
add_p(
    "As elipses foram construídas combinando as amplitudes e fases das componentes EW e NS. "
    "K1 domina com a maior elipse (H_ew = 0,037 m/s, H_ns = 0,128 m/s, inclinação 223°/283°). "
    "S2 tem a segunda maior elipse (H_ew = 0,016 m/s, H_ns = 0,062 m/s). "
    "M2 e O1 são muito pequenas (< 0,03 m/s em todos os eixos). "
    "A orientação predominante NE-SW das elipses de K1 e S2 é consistente com a geometria "
    "do canal estuarino de Santos/São Vicente."
)
add_table(
    ["Comp.", "H_EW (m/s)", "g_EW (°)", "H_NS (m/s)", "g_NS (°)"],
    [["M2", "0,0095", "43,56", "0,0288", "59,89"],
     ["S2", "0,0159", "62,25", "0,0618", "133,48"],
     ["K1", "0,0369", "223,15", "0,1278", "283,45"],
     ["O1", "0,0207", "334,26", "0,0047", "197,27"]]
)
add_img("q08_elipses.png", height="13cm", caption="Fig. 8.1 — Elipses de correntes de maré para M2, S2, K1 e O1, Santos.")

# ── Q9 ────────────────────────────────────────────────────────────────────────
add_h1("Questão 9 — Resíduos das correntes de maré (Santos)")
add_p(
    "Os resíduos (medição − previsão rotacional) mostram amplitudes muito superiores ao sinal "
    "de maré previsto: DP_EW = 0,139 m/s e DP_NS = 0,205 m/s, com extremos de ±0,36 m/s "
    "em EW e ±0,65 m/s em NS. Isso confirma que as correntes na região costeira de Santos "
    "são dominadas por forçantes não-periódicas: variações de vento, gradiente de pressão "
    "baroclínico e maré meteorológica. Os episódios de correntes mais intensas nos resíduos "
    "coincidem com passagens de frentes frias ao longo da costa sudeste."
)
add_table(
    ["Componente", "Média (m/s)", "DP (m/s)", "Mínimo (m/s)", "Máximo (m/s)"],
    [["EW", "−0,0008", "0,1390", "−0,3609", "0,3733"],
     ["NS", " 0,0017", "0,2045", "−0,6283", "0,6545"]]
)
add_img("q09_residuais.png", height="10cm", caption="Fig. 9.1 — Resíduos de correntes EW (cima) e NS (baixo), Santos.")

# ── Q10 ───────────────────────────────────────────────────────────────────────
add_h1("Questão 10 — Nível do mar vs. temperatura no fundo (Santos)")
add_p(
    "A correlação entre nível do mar e temperatura no fundo em Santos é fraca (r = 0,185; "
    "R² = 0,034), indicando que a temperatura não é primariamente controlada pelo nível. "
    "Contudo, a correlação cruzada apresenta pico de 0,327 com defasagem de −21 h: "
    "a temperatura no fundo lidera o nível por ~21 h. Essa relação pode refletir intrusões "
    "de água fria da plataforma (advecção baroclínica) que elevam o nível local com defasagem "
    "em relação à variação de temperatura no fundo. "
    "Nível: média = 0,00 m; DP = 0,375 m (range: −1,05 a +1,00 m). "
    "Temperatura: média = 23,77 °C; DP = 1,69 °C (range: 20,25–26,85 °C)."
)
add_table(
    ["Parâmetro", "Valor"],
    [["Correlação r (nível vs T)",       "0,185"],
     ["R²",                              "0,034"],
     ["Xcorr máx (normalizada)",         "0,327"],
     ["Defasagem xcorr máx",             "−21 h (T lidera)"],
     ["Nível: DP",                       "0,375 m"],
     ["Temperatura: média / DP",         "23,77 °C / 1,69 °C"]]
)
add_img("q10_series.png",  height="10cm", caption="Fig. 10.1 — Nível do mar (cima) e temperatura no fundo (baixo), Santos.")
add_img("q10_scatter.png", height="11cm", caption="Fig. 10.2 — Diagrama de espalhamento: nível do mar vs. temperatura.")
add_img("q10_xcorr.png",   caption="Fig. 10.3 — Correlação cruzada (normalizada) entre nível do mar e temperatura no fundo.")

# ── Salvar ────────────────────────────────────────────────────────────────────
doc.save(str(OUT))
print(f"OK: {OUT}")
