# Data for Lecture 1

`data.xlsx` contains quarterly U.S. macroeconomic time series (1954Q3-2023Q2) from **FRED, Federal Reserve Bank of St. Louis** (<https://fred.stlouisfed.org>).
`data_figures.m` reads the file, computes the second moments shown on the slides and exports the
figures to `../latex/figures/` (Matlab R2020a or newer with the Econometrics Toolbox).

| Column | FRED series | Description | Unit |
|---|---|---|---|
| `real_gdp` | `GDPC1` | Real gross domestic product, SAAR | bn. chained 2012 $ |
| `nom_gdp` | `GDP` | Gross domestic product, SAAR | bn. $ |
| `real_inv` | `GPDIC1` | Real gross private domestic investment, SAAR | bn. chained 2012 $ |
| `gov_exp` | `GCEC1` | Real government consumption expenditures and gross investment, SAAR | bn. chained 2012 $ |
| `pot_gdp` | `GDPPOT` | Real potential GDP (CBO) | bn. chained 2012 $ |
| `gdp_gap` | `GDPC1`, `GDPPOT` | Output gap, `100*(GDPC1-GDPPOT)/GDPPOT` | percent |
| `un_rate` | `UNRATE` | Unemployment rate, seasonally adjusted (quarterly average) | percent |
| `fed_funds` | `DFF` | Effective federal funds rate (quarterly average) | percent |
| `nber_recession` | `USRECD` | NBER-based recession indicator (quarterly) | 0/1 |
| `infl_exp_mich` | `MICH` | University of Michigan: inflation expectation (quarterly average, from 1978) | percent |
| `nairu` | `NROU` | Noncyclical rate of unemployment (CBO), quarterly | percent |
| `core_pce` | `BPCCRO1Q156NBEA` | PCE price index excluding food and energy (BEA), percent change from a year ago, quarterly, seasonally adjusted (from 1960) | percent |

Quarterly values of monthly and daily series are FRED's quarterly averages.

## Vintages

All columns up to `infl_exp_mich` were downloaded in October 2023. `nairu` and `core_pce` were added on
22 October 2026 (FRED data updated 27 February 2026 and 30 September 2026); both series were cut to
the sample of the other columns. The unemployment gap used in the figures is `un_rate - nairu`.
`core_pce` is not available before 1960. Later vintages of `NROU` differ slightly from earlier ones.

## Terms of use

FRED data are provided by the Federal Reserve Bank of St. Louis; the underlying series belong to
their original sources (BEA, BLS, CBO, NBER, Federal Reserve Board, University of Michigan Surveys
of Consumers). They are included for teaching and research purposes with attribution and are not covered
by the licenses of this repository. Please cite the FRED series and the original sources when reusing them.
