# Drivers of COVID-19 variant wave dynamics: inferring Omicron BA.1 and BA.2 relative wave sizes using global data with genomics

S. Molan<sup>1</sup>, N.K. Smith<sup>2,3</sup>, V. Gandhi<sup>1</sup>, M. Li<sup>4,5</sup>, C. Colijn<sup>1</sup>, C.L. Murall<sup>3</sup>, J.E. Stockdale<sup>1,*</sup>

1. Department of Mathematics, Simon Fraser University
2. Department of Community Health and Epidemiology, Dalhousie University
3. National Microbiology Laboratory Branch, Public Health Agency of Canada
4. Department of Mathematics and Statistics, McMaster University
5. Science Policy Integration Branch, Public Health Agency of Canada

\* Corresponding author: Jessica Stockdale, jessica_stockdale@sfu.ca

## Layout:
- scripts/1_dataset/ : writes masterdata, writes Table S2, and plots Figures S1, S2, and S3
- scripts/2_variant_dynamics/ : performs VOC grouping, wave peaks and relative wave size calculations, plots Figures 1, 2, S5-S9
- scripts/3_model/ : runs the imputation and random forest models
- results/ : saved imputations and model runs (V1_43, V1_OECD, Dynamic_log), each with its results and figures

## How to run:
- R 4.4.2 packages: dplyr, tidyr, tidyverse, readr, ggplot2, ggpubr, ggrepel, patchwork, gridExtra, scales, viridis, magick, mice, randomForest, zoo, reshape2, sf, rnaturalearth, rnaturalearthdata, knitr, rmarkdown, pdftools, plyr, RColorBrewer, lubridate, cowplot, data.table, ggnewscale, DT
- Python 3 with Jupyter packages: pandas, numpy, scipy, matplotlib, seaborn, plotly, requests, beautifulsoup4, unidecode
- Model:
  - Run scripts/2_variant_dynamics/creating_relsize.R
  - Knit scripts/3_model/Final_model.Rmd once per analysis "main", "oecd" and "dynamic", e.g. rmarkdown::render("scripts/3_model/Final_model.Rmd", params = list(analysis = "main")), which takes several hours. Each run saves its .RData in results/V1_43, results/V1_OECD or results/Dynamic_log
  - After all three runs, knit results/V1_43/Results.Rmd, results/V1_OECD/Results.Rmd, and results/Dynamic_log/Results.Rmd, and run results/imputation/imputation_distribution_visualization.R for the figures
- Other figures, listed below, have scripts that run on their own

## Figure to script map:
- Fig 1, 2, S5, S6, S9: scripts/2_variant_dynamics/VOC_plots.Rmd
- Fig 3: results/map/map.Rmd
- Fig 4, 5, 6: results/V1_43/Results.Rmd
- Fig S1, S2, S3: scripts/1_dataset/supplementary_plots.R
- Fig S4: results/imputation/imputation_distribution_visualization.R
- Fig S7, S8: scripts/2_variant_dynamics/gendist_plots.R
- Fig S10, S11, S12: results/V1_OECD/Results.Rmd
- Fig S13, S14, S15: results/Dynamic_log/Results.Rmd
- Table S2: scripts/1_dataset/covid_means_march14.Rmd