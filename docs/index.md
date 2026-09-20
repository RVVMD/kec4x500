<style>
.wy-nav-content { max-width: 900px; }
.wy-table-responsive { text-align: center; }
.wy-table-responsive > table,
.rst-content table { display: inline-table !important; width: auto !important; margin: 1em auto !important; }
table th, table td { text-align: center; }
.rst-content img { display: block; margin: 1.5em auto 0.5em; max-width: 100%; height: auto; }
.rst-content p > em:only-child { display: block; text-align: center; margin-top: 0; }
.rst-content div.arithmatex { overflow-x: auto; overflow-y: hidden; }
</style>

<script>
window.MathJax = {
  tex: {
    inlineMath: [["\\(", "\\)"]],
    displayMath: [["\\[", "\\]"]],
    processEscapes: true,
    processEnvironments: true
  },
  options: {
    ignoreHtmlClass: ".*|",
    processHtmlClass: "arithmatex"
  }
};
</script>
<script src="js/tex-mml-svg.js" id="MathJax-script"></script>

# Проектирование электрической части КЭС

```python exec="on" session="model"
from decimal import ROUND_HALF_UP, Decimal

# генератор
p_nom_g = 500                   # мощность, МВт
u_nom_g = 20                    # напряжение, кВ
cosf_g = 0.85
xd2_g = 0.242                   # сопротивление, о.е.
r_g = 0.00114                   # сопротивление, Ом
n_g = 4

# свои нужды
pmax_pust = 7                   # нагрузка, %
u_nom_sn = 6                    # напряжение, кВ
cosf_sn = 0.85

# шины 500 кВ
u_nom_ruvn = 500                # напряжение, кВ
s_nom_s1 = 7000                 # мощность С1, МВА
x_s1 = 1.3                      # сопротивление С1, о.е.
p_avrez_s1 = 600                # резерв С1, МВт
s_nom_s2 = 8500                 # мощность С2, МВА
x_s2 = 0.9                      # сопротивление С2, о.е.
p_avrez_s2 = 810                # резерв С2, МВт
l_ruvn = [500, 800, 600, 700]   # длины линий, км

# шины 220 кВ
u_nom_rusn = 220                # напряжение, кВ
p_ng_rusn = 460                 # нагрузка, МВт
cosf_ng_rusn = 0.85
l_rusn = [500, 800, 600, 700]   # длины линий, км

# графики
d_zim = 215                     # зимних дней
d_let = 150                     # летних дней
load_rusn_zim = [70, 70, 70, 70, 80, 80, 80, 80, 100, 100, 100, 80]
load_rusn_let = [50, 50, 50, 50, 60, 60, 60, 60, 70, 70, 70, 70]
load_gen_zim = [80, 80, 80, 100, 100, 100, 100, 100, 100, 100, 100, 80]
load_gen_let = [76] * 12

# прочее
k_per = 1
n_ts = 2
n_g_rusn_var1 = 0
n_g_rusn_var2 = 1

# капиталовложения
k_bt_500 = 585                  # блочный трансформатор 500 кВ, тыс. у.е.
k_bt_220 = 450                  # блочный трансформатор 220 кВ, тыс. у.е.
k_at_var1 = 600                 # автотрансформатор вар. 1, тыс. у.е.
k_at_unit = 292                 # однофазный автотрансформатор, тыс. у.е.
k_q_500 = 170                   # ячейка 500 кВ, тыс. у.е.
k_q_220 = 100                   # ячейка 220 кВ, тыс. у.е.

# издержки
ko_220 = 2.9                    # обслуживание, %
ka_220 = 2                      # амортизация, %

# потери
phh_bt_500 = 420                # х.х. блочного 500 кВ, кВт
phh_bt_220 = 345                # х.х. блочного 220 кВ, кВт
phh_at_var1 = 220               # х.х. автотрансформатора вар. 1, кВт
phh_at_unit = 125               # х.х. однофазного, кВт
pkz_bt_500 = 1210               # к.з. блочного 500 кВ, кВт
pkz_bt_220 = 1300               # к.з. блочного 220 кВ, кВт
pkz_at_var1 = 1050              # к.з. автотрансформатора вар. 1, кВт
pkz_at_unit = 470               # к.з. однофазного, кВт
s_nom_bt_500 = 630              # блочный трансформатор 500 кВ, МВА

# число с запятой
def dec(value, digits=None, sig=None):
	d = Decimal(str(value))
	if digits is not None:
		d = d.quantize(Decimal(1).scaleb(-digits), rounding=ROUND_HALF_UP)
	elif sig is not None and d != 0:
		d = d.quantize(Decimal(1).scaleb(d.adjusted() - sig + 1), rounding=ROUND_HALF_UP)
	text = format(d, "f")
	if "." in text:
		text = text.rstrip("0").rstrip(".")
	return text.replace(".", "{,}")


# столбик чисел
def col(values):
	return r" \\ ".join(str(v) for v in values)


# 3 значащие цифры
def sf(value, n=3):
	d = Decimal(str(value))
	if d == 0:
		return "0"
	exp = d.adjusted()
	q = d.quantize(Decimal(1).scaleb(exp - n + 1), rounding=ROUND_HALF_UP)
	text = format(q, "f")
	if "." in text:
		text = text.rstrip("0").rstrip(".")
	return text.replace(".", "{,}")


p_two_gen = p_nom_g * 2
snb_tb_norm = (p_nom_g - p_nom_g * pmax_pust / 100) / (cosf_g * k_per)
snb_tb_rem = p_nom_g / (cosf_g * k_per)
snb_tb_max = max(snb_tb_norm, snb_tb_rem)
ssn = p_nom_g * pmax_pust / 100
p_per_ts = [p_ng_rusn - n * p_nom_g for n in range(4)]

# мощности нагрузок
s_ng_rusn_zim = [p * p_ng_rusn / (100 * cosf_ng_rusn) for p in load_rusn_zim]
s_ng_rusn_let = [p * p_ng_rusn / (100 * cosf_ng_rusn) for p in load_rusn_let]
s_ng_g_zim = [p * p_nom_g / (100 * cosf_g) for p in load_gen_zim]
s_ng_g_let = [p * p_nom_g / (100 * cosf_g) for p in load_gen_let]

# перетоки через трансформаторы связи
s_per_ts_zim_var1 = [n_g_rusn_var1 * (a - ssn) - b for a, b in zip(s_ng_g_zim, s_ng_rusn_zim)]
s_per_ts_let_var1 = [n_g_rusn_var1 * (a - ssn) - b for a, b in zip(s_ng_g_let, s_ng_rusn_let)]
s_per_ts_zim_var2 = [n_g_rusn_var2 * (a - ssn) - b for a, b in zip(s_ng_g_zim, s_ng_rusn_zim)]
s_per_ts_let_var2 = [n_g_rusn_var2 * (a - ssn) - b for a, b in zip(s_ng_g_let, s_ng_rusn_let)]

# автотрансформаторы
snb = abs(s_per_ts_zim_var1[10])
snb_nt = snb / n_ts
snom_at_var1 = 400
h_stroke = 16
s_one = (sum(v ** 2 * 2 for v in s_per_ts_zim_var1[:4]) / 8) ** 0.5
s_two = (sum(v ** 2 * 2 for v in s_per_ts_zim_var1[4:]) / h_stroke) ** 0.5
k_one = s_one / snom_at_var1
k_two_stroke = s_two / snom_at_var1
k_max = snb / snom_at_var1
k_two = k_max * 0.9
h_coef = k_two_stroke ** 2 * h_stroke / (0.9 * k_max) ** 2
k_dop_sist_per = 1.23
k_dop_av_per = 1.5

# капиталовложения
k_at_var2 = 3 * k_at_unit
k_var1 = 4 * k_bt_500 + 6 * k_q_500 + 2 * k_at_var1 + 2 * k_q_220
k_var2 = 3 * k_bt_500 + 5 * k_q_500 + 2 * k_at_var2 + 1 * k_bt_220 + 3 * k_q_220

# издержки на обслуживание и амортизацию
i_o_a_var1 = k_var1 * (ko_220 + ka_220) / 100
i_o_a_var2 = k_var2 * (ko_220 + ka_220) / 100

# потери
g_p_ng_g_zim = [p * p_nom_g / 100 for p in load_gen_zim]
g_p_ng_g_let = [p * p_nom_g / 100 for p in load_gen_let]
tnb = (sum(v * 2 for v in g_p_ng_g_zim) * d_zim + sum(v * 2 for v in g_p_ng_g_let) * d_let) / p_nom_g
tau = tnb / 3 + 2 * tnb ** 2 / (3 * 8760)
phh_at_var2 = 3 * phh_at_unit
pkz_at_var2 = 3 * pkz_at_unit
whh_var1 = 4 * phh_bt_500 * tnb + 2 * phh_at_var1 * 8760
whh_var2 = 3 * phh_bt_500 * tnb + 1 * phh_bt_220 * tnb + 2 * phh_at_var2 * 8760
wkz_bt_500_var1 = (sum((v / s_nom_bt_500) ** 2 * 2 for v in s_ng_g_zim) * d_zim
	+ sum((v / s_nom_bt_500) ** 2 * 2 for v in s_ng_g_let) * d_let) * 4 * pkz_bt_500
wkz_bt_220_var1 = 0

TEX = {
	"PnomG": str(p_nom_g),
	"UnomG": str(u_nom_g),
	"CosfG": dec(cosf_g, 2),
	"XdG": dec(xd2_g, 3),
	"RG": dec(r_g, 5),
	"Ng": str(n_g),
	"PmaxPust": str(pmax_pust),
	"UnomSN": str(u_nom_sn),
	"CosfSN": dec(cosf_sn, 2),
	"UnomRUVN": str(u_nom_ruvn),
	"SnomSOne": str(s_nom_s1),
	"XsOne": dec(x_s1, 1),
	"PavrezSOne": str(p_avrez_s1),
	"SnomSTwo": str(s_nom_s2),
	"XsTwo": dec(x_s2, 1),
	"PavrezSTwo": str(p_avrez_s2),
	"LRuvnOne": str(l_ruvn[0]),
	"LRuvnTwo": str(l_ruvn[1]),
	"LRuvnThree": str(l_ruvn[2]),
	"LRuvnFour": str(l_ruvn[3]),
	"UnomRUSN": str(u_nom_rusn),
	"PngRUSN": str(p_ng_rusn),
	"CosfNGRUSN": dec(cosf_ng_rusn, 2),
	"LRusnOne": str(l_rusn[0]),
	"LRusnTwo": str(l_rusn[1]),
	"LRusnThree": str(l_rusn[2]),
	"LRusnFour": str(l_rusn[3]),
	"DZim": str(d_zim),
	"DLet": str(d_let),
	"LoadRusnZim": col(load_rusn_zim),
	"LoadRusnLet": col(load_rusn_let),
	"LoadGenZim": col(load_gen_zim),
	"LoadGenLet": col(load_gen_let),
	"Kper": str(k_per),
	"PTwoGen": str(p_two_gen),
	"SBlTrNorm": sf(snb_tb_norm),
	"SBlTrRem": sf(snb_tb_rem),
	"SBlTrMax": sf(snb_tb_max),
	"NTS": str(n_ts),
	"PPerTsZero": str(p_per_ts[0]),
	"PPerTsOne": str(p_per_ts[1]),
	"PPerTsTwo": str(p_per_ts[2]),
	"PPerTsThree": str(p_per_ts[3]),
	"NGRusnVarOne": str(n_g_rusn_var1),
	"NGRusnVarTwo": str(n_g_rusn_var2),
	"SSN": str(int(ssn)),
	"ZimPerTsVarOneTen": sf(s_per_ts_zim_var1[10]),
	"SPerTsLow": sf(s_ng_rusn_zim[0]),
	"SPerTsMid": sf(s_ng_rusn_zim[4]),
	"SPerTsHigh": sf(s_ng_rusn_zim[8]),
	"Snb": sf(snb),
	"SnbNt": sf(snb_nt),
	"SnomATVarOne": str(snom_at_var1),
	"HStroke": str(h_stroke),
	"SOne": sf(s_one),
	"STwoPrime": sf(s_two),
	"KOne": sf(k_one),
	"KTwoPrime": sf(k_two_stroke),
	"KMax": sf(k_max),
	"KTwo": sf(k_two),
	"HCoef": sf(h_coef),
	"KDopSistPer": dec(k_dop_sist_per, 2),
	"KDopAvPer": dec(k_dop_av_per, 1),
	"KbtRUVN": str(k_bt_500),
	"KbtRUSN": str(k_bt_220),
	"KatVarOne": str(k_at_var1),
	"KatVarTwo": str(k_at_var2),
	"KqRUVN": str(k_q_500),
	"KqRUSN": str(k_q_220),
	"KVarOne": sf(k_var1),
	"KVarTwo": sf(k_var2),
	"KoRUSN": dec(ko_220, 1),
	"KaRUSN": str(ka_220),
	"IoAVarOne": sf(i_o_a_var1),
	"IoAVarTwo": sf(i_o_a_var2),
	"Tnb": dec(tnb / 1000, 2) + r"\cdot10^3",
	"TauValue": dec(tau / 1000, 2) + r"\cdot10^3",
	"PhhBtRUVN": str(phh_bt_500),
	"PhhBtRUSN": str(phh_bt_220),
	"PhhAtVarOne": str(phh_at_var1),
	"PhhAtVarTwo": str(phh_at_var2),
	"PkzBtRUVN": str(pkz_bt_500),
	"PkzBtRUSN": str(pkz_bt_220),
	"PkzAtVarOne": str(pkz_at_var1),
	"PkzAtVarTwo": str(pkz_at_var2),
	"WhhVarOne": dec(whh_var1 / 10**7, 2) + r"\cdot10^7",
	"WhhVarTwo": dec(whh_var2 / 10**7, 2) + r"\cdot10^7",
	"WkzBtRUVNVarOne": dec(wkz_bt_500_var1 / 10**7, 2) + r"\cdot10^7",
	"WkzBtRUSNVarOne": str(wkz_bt_220_var1),
	"SumPZim": sf(sum(g_p_ng_g_zim)),
	"SumPLet": sf(sum(g_p_ng_g_let)),
	"SngGZimLow": sf(s_ng_g_zim[0]),
	"SngGZimHigh": sf(s_ng_g_zim[3]),
	"SngGLet": sf(s_ng_g_let[0]),
}

print(r"\(" + "".join(r"\def\%s{%s}" % (k, v) for k, v in TEX.items()) + r"\)")
```

## Исходные данные

### Генераторы

| Тип | $P_{\text{ном}}$, МВт | $U_{\text{ном}}$, кВ | $\cos\varphi_{\text{ном}}$ | $X''_d$, о.е. | $R_{\text{ст}}$, Ом | Кол-во |
| :--: | :--: | :--: | :--: | :--: | :--: | :--: |
| ТВВ-500-2ЕУ3 | $\PnomG$ | $\UnomG$ | $\CosfG$ | $\XdG$ | $\RG$ | $\Ng$ |

### Собственные нужды

| $P_{\text{max}}/P_{\text{уст}}$, % | $U_{\text{ном}}$, кВ | $\cos\varphi_{\text{ном}}$ |
| :--: | :--: | :--: |
| $\PmaxPust$ | $\UnomSN$ | $\CosfSN$ |

### Высшее напряжение (РУВН)

| $U_{\text{ном}}$, кВ | Система | $S_{\text{ном}}$, МВА | $x_{\text{с}}$, о.е. | $P_{\text{ав.рез}}$, МВт |
| :--: | :--: | :--: | :--: | :--: |
| $\UnomRUVN$ | С1 | $\SnomSOne$ | $\XsOne$ | $\PavrezSOne$ |
| $\UnomRUVN$ | С2 | $\SnomSTwo$ | $\XsTwo$ | $\PavrezSTwo$ |

| $l_1$, км | $l_2$, км | $l_3$, км | $l_4$, км |
| :--: | :--: | :--: | :--: |
| $\LRuvnOne$ | $\LRuvnTwo$ | $\LRuvnThree$ | $\LRuvnFour$ |

![Исходная схема](assets/img/scheme-vn.png)

*Рис. 1. Исходная схема*

### Среднее напряжение (РУСН)

| $U_{\text{ном}}$, кВ | $P_{\text{нг.max}}$, МВт | $\cos\varphi_{\text{ном}}$ |
| :--: | :--: | :--: |
| $\UnomRUSN$ | $\PngRUSN$ | $\CosfNGRUSN$ |

| $l_1$, км | $l_2$, км | $l_3$, км | $l_4$, км |
| :--: | :--: | :--: | :--: |
| $\LRusnOne$ | $\LRusnTwo$ | $\LRusnThree$ | $\LRusnFour$ |

![Схема сети среднего напряжения](assets/img/scheme-rusn.png)

*Рис. 2. Схема сети среднего напряжения*

### Графики нагрузки

| $d_{\text{зим}}$, дней | $d_{\text{лет}}$, дней |
| :--: | :--: |
| $\DZim$ | $\DLet$ |

![Суточные графики нагрузки РУСН](assets/img/load-rusn.svg)

*Рис. 3. Суточные графики нагрузки РУСН*

$$
P^{\text{зим.}}_{\text{нг.РУСН}},\ \% =
\begin{pmatrix}
\LoadRusnZim
\end{pmatrix}
\qquad
P^{\text{лет.}}_{\text{нг.РУСН}},\ \% =
\begin{pmatrix}
\LoadRusnLet
\end{pmatrix}
$$

![Суточные графики нагрузки генераторов](assets/img/load-gen.svg)

*Рис. 4. Суточные графики нагрузки генераторов*

$$
P^{\text{зим.}}_{\text{нг.г}},\ \% =
\begin{pmatrix}
\LoadGenZim
\end{pmatrix}
\qquad
P^{\text{лет.}}_{\text{нг.г}},\ \% =
\begin{pmatrix}
\LoadGenLet
\end{pmatrix}
$$

## Глава 1. Выбор структурной схемы

### Проверка укрупнённых блоков

$$
P_{\text{ном.г}} \cdot 2 = \PnomG \cdot 2 = 1 \times 10^3\ \text{МВт}
$$

$$
P_{\text{ав.рез.с1}} = \PavrezSOne\ \text{МВт}; \qquad
P_{\text{ав.рез.с2}} = \PavrezSTwo\ \text{МВт}
$$

Применять укрупнённые и объединённые блоки нельзя.

### Выбор мощности блочных трансформаторов

$$
S_{\text{бл.тр.норм}} = \frac{P_{\text{ном.г}} - P_{\text{ном.г}} \cdot \dfrac{P_{\text{max.пуск.СН}}}{100}}{\cos\varphi_{\text{г}} \cdot K_{\text{пер}}}
= \frac{\PnomG - \PnomG \cdot \dfrac{\PmaxPust}{100}}{\CosfG \cdot \Kper}
= \SBlTrNorm\ \text{МВА}
$$

Ремонтный и послеаварийный режим:

$$
S_{\text{бл.тр.рем}} = \frac{P_{\text{ном.г}}}{\cos\varphi_{\text{г}} \cdot K_{\text{пер}}}
= \frac{\PnomG}{\CosfG \cdot \Kper}
= \SBlTrRem\ \text{МВА}
$$

Мощность блочного трансформатора принимается не менее

$$
\max\left(S_{\text{бл.тр.норм}};\ S_{\text{бл.тр.рем}}\right)
= \max\left(\SBlTrNorm;\ \SBlTrRem\right) = \SBlTrMax\ \text{МВА}
$$

Согласно СТО РАО ЕЭС 2007, недопустимо применять один трансформатор связи,
поэтому принимаем $n_{\text{тс}} = \NTS$.

### Выбор числа генераторов, подключаемых к РУСН

Переток через трансформаторы связи при $n_{\text{г.СН}}$ генераторах на РУСН:

$$
P_{\text{пер.тс}} = P_{\text{нг.РУСН}} - n_{\text{г.СН}} \cdot P_{\text{ном.г}}
$$

| $n_{\text{г.СН}}$, шт. | 0 | 1 | 2 | 3 |
| :--: | :--: | :--: | :--: | :--: |
| $P_{\text{пер.тс}}$, МВт | $\PPerTsZero$ | $\PPerTsOne$ | $\PPerTsTwo$ | $\PPerTsThree$ |

$$
n_{\text{г.РУСН.вар1}} = \NGRusnVarOne; \qquad n_{\text{г.РУСН.вар2}} = \NGRusnVarTwo
$$

### Перетоки мощности через трансформаторы связи

Мощности нагрузок:

$$
S^{\text{зим.}}_{\text{нг.РУСН}} = \frac{P^{\text{зим.}}_{\text{нг.РУСН}} \cdot P_{\text{нг.РУСН}}}{\cos\varphi_{\text{нг.РУСН}} \cdot 100};
\qquad
S^{\text{лет.}}_{\text{нг.РУСН}} = \frac{P^{\text{лет.}}_{\text{нг.РУСН}} \cdot P_{\text{нг.РУСН}}}{\cos\varphi_{\text{нг.РУСН}} \cdot 100}
$$

$$
S^{\text{зим.}}_{\text{нг.г}} = \frac{P^{\text{зим.}}_{\text{нг.г}} \cdot P_{\text{ном.г}}}{\cos\varphi_{\text{г}} \cdot 100};
\qquad
S^{\text{лет.}}_{\text{нг.г}} = \frac{P^{\text{лет.}}_{\text{нг.г}} \cdot P_{\text{ном.г}}}{\cos\varphi_{\text{г}} \cdot 100}
$$

![Мощности нагрузки генераторов](assets/img/power-gen.svg)

*Рис. 5. Мощности нагрузки генераторов*

![Мощности нагрузки РУСН](assets/img/power-rusn.svg)

*Рис. 6. Мощности нагрузки РУСН*

Мощность собственных нужд:

$$
S_{\text{сн}} = P_{\text{ном.г}} \cdot \frac{P_{\text{max.пуск.СН}}}{100}
= \PnomG \cdot \frac{\PmaxPust}{100} = \SSN\ \text{МВА}
$$

Перетоки через трансформаторы связи:

$$
S^{\text{зим.}}_{\text{пер.тс.вар1}} = n_{\text{г.РУСН.вар1}} \cdot \left(S^{\text{зим.}}_{\text{нг.г}} - S_{\text{сн}}\right) - S^{\text{зим.}}_{\text{нг.РУСН}}
$$

$$
S^{\text{лет.}}_{\text{пер.тс.вар1}} = n_{\text{г.РУСН.вар1}} \cdot \left(S^{\text{лет.}}_{\text{нг.г}} - S_{\text{сн}}\right) - S^{\text{лет.}}_{\text{нг.РУСН}}
$$

$$
S^{\text{зим.}}_{\text{пер.тс.вар2}} = n_{\text{г.РУСН.вар2}} \cdot \left(S^{\text{зим.}}_{\text{нг.г}} - S_{\text{сн}}\right) - S^{\text{зим.}}_{\text{нг.РУСН}}
$$

$$
S^{\text{лет.}}_{\text{пер.тс.вар2}} = n_{\text{г.РУСН.вар2}} \cdot \left(S^{\text{лет.}}_{\text{нг.г}} - S_{\text{сн}}\right) - S^{\text{лет.}}_{\text{нг.РУСН}}
$$

![Переток мощности через трансформаторы связи, вариант 1](assets/img/perets-var1.svg)

*Рис. 7. Переток мощности через трансформаторы связи, вариант 1*

![Переток мощности через трансформаторы связи, вариант 2](assets/img/perets-var2.svg)

*Рис. 8. Переток мощности через трансформаторы связи, вариант 2*

### Выбор автотрансформаторов связи

Для варианта 2 (1 генератор на РУСН) окончательно выбираем группу из трёх
однофазных автотрансформаторов АОДЦТН-267000/500/220.

Для варианта 1 (0 генераторов на РУСН) в нормальном режиме наибольший переток
определяется по зимнему графику:

$$
S_{\text{нб}} = \left| \left( S^{\text{зим.}}_{\text{пер.тс.вар1}} \right)_{10} \right|
= \left| \ZimPerTsVarOneTen \right| = \Snb\ \text{МВА}
$$

Мощность автотрансформатора принимается не менее

$$
S_{\text{ном.АТ.вар1}} \ge \frac{S_{\text{нб}}}{n_{\text{т}}}
= \frac{\Snb}{\NTS} = \SnbNt\ \text{МВА};
\qquad S_{\text{ном.АТ.вар1}} = \SnomATVarOne\ \text{МВА}
$$

Приведённое число часов $h' = \HStroke$.

Эквивалентные ступени графика:

$$
S_1 = \sqrt{\frac{\sum\limits_{t=0}^{3}
\left[ \left( S^{\text{зим.}}_{\text{пер.тс.вар1}} \right)_t^2 \cdot 2 \right]}{8}}
= \sqrt{\frac{4 \cdot \SPerTsLow^2 \cdot 2}{8}}
= \SOne\ \text{МВА}
$$

$$
S'_2 = \sqrt{\frac{\sum\limits_{t=4}^{11}
\left[ \left( S^{\text{зим.}}_{\text{пер.тс.вар1}} \right)_t^2 \cdot 2 \right]}{h'}}
= \sqrt{\frac{\left(5 \cdot \SPerTsMid^2 + 3 \cdot \SPerTsHigh^2\right) \cdot 2}{\HStroke}}
= \STwoPrime\ \text{МВА}
$$

Коэффициенты начальной нагрузки:

$$
K_1 = \frac{S_1}{S_{\text{ном.АТ.вар1}}}
= \frac{\SOne}{\SnomATVarOne} = \KOne
$$

$$
K'_2 = \frac{S'_2}{S_{\text{ном.АТ.вар1}}}
= \frac{\STwoPrime}{\SnomATVarOne} = \KTwoPrime
$$

$$
K_{\max} = \frac{S_{\text{нб}}}{S_{\text{ном.АТ.вар1}}}
= \frac{\Snb}{\SnomATVarOne} = \KMax
$$

$$
K_2 = K_{\max} \cdot 0{,}9 = \KMax \cdot 0{,}9 = \KTwo
$$

$$
h = \frac{(K'_2)^2 \cdot h'}{(0{,}9 \cdot K_{\max})^2}
= \frac{(\KTwoPrime)^2 \cdot \HStroke}{(0{,}9 \cdot \KMax)^2} = \HCoef
$$

Допустимые коэффициенты перегрузки:

$$
K^{\text{сист.пер}}_{2\text{доп}} = \KDopSistPer; \qquad K^{\text{ав.пер}}_{2\text{доп}} = \KDopAvPer
$$

Окончательно выбираем АТДЦТН-400000/500/220.

### Капиталовложения

| Обозначение | Значение, тыс. у.е. |
| :--: | :--: |
| $K_{\text{бл.500}}$ | $\KbtRUVN$ |
| $K_{\text{бл.220}}$ | $\KbtRUSN$ |
| $K_{\text{ат.вар1}}$ | $\KatVarOne$ |
| $K_{\text{ат.вар2}}$ | $\KatVarTwo$ |
| $K_{\text{q.500}}$ | $\KqRUVN$ |
| $K_{\text{q.220}}$ | $\KqRUSN$ |

Вариант 1 (0 генераторов на РУСН):

$$
K_{\text{вар1}} = 4 \cdot \KbtRUVN + 6 \cdot \KqRUVN + 2 \cdot \KatVarOne + 2 \cdot \KqRUSN
= \KVarOne\ \text{тыс. у.е.}
$$

Вариант 2 (1 генератор на РУСН):

$$
K_{\text{вар2}} = 3 \cdot \KbtRUVN + 5 \cdot \KqRUVN + 2 \cdot \KatVarTwo
+ 1 \cdot \KbtRUSN + 3 \cdot \KqRUSN
= \KVarTwo\ \text{тыс. у.е.}
$$

### Издержки на обслуживание и амортизацию

$$
K_{\text{о.220}} = \KoRUSN\ \%; \qquad K_{\text{а.220}} = \KaRUSN\ \%
$$

$$
\text{И}_{\text{о.а.вар1}} = K_{\text{вар1}} \cdot \frac{K_{\text{о.220}} + K_{\text{а.220}}}{100}
= \KVarOne \cdot \frac{\KoRUSN + \KaRUSN}{100} = \IoAVarOne\ \text{тыс. у.е./год}
$$

$$
\text{И}_{\text{о.а.вар2}} = K_{\text{вар2}} \cdot \frac{K_{\text{о.220}} + K_{\text{а.220}}}{100}
= \KVarTwo \cdot \frac{\KoRUSN + \KaRUSN}{100} = \IoAVarTwo\ \text{тыс. у.е./год}
$$

### Издержки, связанные с потерями

$$
P^{\text{зим.}}_{\text{нг.г}} = \frac{P^{\text{зим.}}_{\text{нг.г}},\ \%}{100} \cdot P_{\text{ном.г}}
= \frac{P^{\text{зим.}}_{\text{нг.г}},\ \%}{100} \cdot \PnomG
$$

$$
P^{\text{лет.}}_{\text{нг.г}} = \frac{P^{\text{лет.}}_{\text{нг.г}},\ \%}{100} \cdot P_{\text{ном.г}}
= \frac{P^{\text{лет.}}_{\text{нг.г}},\ \%}{100} \cdot \PnomG
$$

$$
\begin{multline}
T_{\text{max}} = \frac{\sum\limits_{t=0}^{11}
\left[\left(P^{\text{зим.}}_{\text{нг.г}}\right)_t \cdot 2\right] \cdot d_{\text{зим}}
+ \sum\limits_{t=0}^{11}
\left[\left(P^{\text{лет.}}_{\text{нг.г}}\right)_t \cdot 2\right] \cdot d_{\text{лет}}}{P_{\text{ном.г}}} = \\
= \frac{\SumPZim \cdot 2 \cdot \DZim + \SumPLet \cdot 2 \cdot \DLet}{\PnomG}
= \Tnb\ \text{ч}
\end{multline}
$$

$$
\begin{multline}
\tau = \frac{1}{3} \cdot T_{\text{max}} + \frac{2}{3} \cdot T_{\text{max}}^2 \cdot \frac{1}{8760} = \\
= \frac{1}{3} \cdot \left(\Tnb\right) + \frac{2}{3} \cdot \left(\Tnb\right)^2 \cdot \frac{1}{8760}
= \TauValue\ \text{ч}
\end{multline}
$$

$$
\Delta P^{\text{бл.500}}_{\text{х}} = \PhhBtRUVN; \quad
\Delta P^{\text{бл.220}}_{\text{х}} = \PhhBtRUSN; \quad
\Delta P^{\text{АТ.вар1}}_{\text{х}} = \PhhAtVarOne; \quad
\Delta P^{\text{АТ.вар2}}_{\text{х}} = \PhhAtVarTwo\ \text{кВт}
$$

$$
\Delta P^{\text{бл.500}}_{\text{к}} = \PkzBtRUVN; \quad
\Delta P^{\text{бл.220}}_{\text{к}} = \PkzBtRUSN; \quad
\Delta P^{\text{АТ.вар1}}_{\text{к}} = \PkzAtVarOne; \quad
\Delta P^{\text{АТ.вар2}}_{\text{к}} = \PkzAtVarTwo\ \text{кВт}
$$

$$
\begin{multline}
\Delta W^{\text{вар1}}_{\text{х}} = 4 \cdot \Delta P^{\text{бл.500}}_{\text{х}} \cdot T_{\text{max}}
+ 2 \cdot \Delta P^{\text{АТ.вар1}}_{\text{х}} \cdot 8760 = \\
= 4 \cdot \PhhBtRUVN \cdot \Tnb + 2 \cdot \PhhAtVarOne \cdot 8760
= \WhhVarOne\ \text{кВт}\cdot\text{ч}
\end{multline}
$$

$$
\begin{multline}
\Delta W^{\text{вар2}}_{\text{х}} = 3 \cdot \Delta P^{\text{бл.500}}_{\text{х}} \cdot T_{\text{max}}
+ 1 \cdot \Delta P^{\text{бл.220}}_{\text{х}} \cdot T_{\text{max}}
+ 2 \cdot \Delta P^{\text{АТ.вар2}}_{\text{х}} \cdot 8760 = \\
= 3 \cdot \PhhBtRUVN \cdot \Tnb + 1 \cdot \PhhBtRUSN \cdot \Tnb
+ 2 \cdot \PhhAtVarTwo \cdot 8760
= \WhhVarTwo\ \text{кВт}\cdot\text{ч}
\end{multline}
$$

$$
\begin{multline}
\Delta W^{\text{вар1}}_{\text{к.з.бл.500}} = \left[
\sum\limits_{t=0}^{11}
\left[\left(\frac{S^{\text{зим.}}_{\text{нг.г}}}{630}\right)_t^2 \cdot 2\right] \cdot d_{\text{зим}}
+ \sum\limits_{t=0}^{11}
\left[\left(\frac{S^{\text{лет.}}_{\text{нг.г}}}{630}\right)_t^2 \cdot 2\right] \cdot d_{\text{лет}}
\right] \cdot 4 \cdot \PkzBtRUVN = \\
= \left[
\left(4 \cdot \left(\frac{\SngGZimLow}{630}\right)^2
+ 8 \cdot \left(\frac{\SngGZimHigh}{630}\right)^2\right) \cdot 2 \cdot \DZim
+ 12 \cdot \left(\frac{\SngGLet}{630}\right)^2 \cdot 2 \cdot \DLet
\right] \cdot 4 \cdot \PkzBtRUVN
= \WkzBtRUVNVarOne\ \text{кВт}\cdot\text{ч}
\end{multline}
$$

$$
\Delta W^{\text{вар1}}_{\text{к.з.бл.220}} = \WkzBtRUSNVarOne\ \text{кВт}\cdot\text{ч}
$$
