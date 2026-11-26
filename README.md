# Drivers of COVID-19 variant wave dynamics: inferring Omicron BA.1 and BA.2 relative wave sizes using global data with genomics

S. Molan<sup>1</sup>, N.K. Smith<sup>2,3</sup>, V. Gandhi<sup>1</sup>, M. Li<sup>4,5</sup>, C. Colijn<sup>1</sup>, C.L. Murall<sup>3</sup>, J.E. Stockdale<sup>1,*</sup>

1. Department of Mathematics, Simon Fraser University
2. Department of Community Health and Epidemiology, Dalhousie University
3. National Microbiology Laboratory Branch, Public Health Agency of Canada
4. Department of Mathematics and Statistics, McMaster University
5. Science Policy Integration Branch, Public Health Agency of Canada

\* Corresponding author: Jessica Stockdale, jessica_stockdale@sfu.ca

## Layout:
- rawdata/ : the public data as downloaded including: OWID, JHU, Oxford policy tracker, Google Mobility, SeroTracker, and GISAID
- data/ : the curated data from rawdata/
  - the master dataset df_ver_10 (covid_processed_v10_march14.zip, which holds df_ver_10_March_14.csv) with Documentation_Ver_10.0.pdf
  - the model inputs 44countriesDeltaBA1_May_07.csv and 44countriesBA1BA2_May_07.csv along with sel_coef.csv, gendist_BA1.csv, gendist_BA2.csv, wave_metrics.csv, diversity_df.csv, and VOC_global_v4.RData
  - the response variables relsize_v4.csv
- scripts/1_dataset/ : writes masterdata, writes Table S2, and plots Figures S1, S2, and S3
- scripts/2_variant_dynamics/ : performs VOC grouping, wave peaks and relative wave size calculations, plots Figures 1, 2, S5-S9
  - VOCVOI_groupingfunction.R groups Pango lineages into the VOC and VOI groups; find_peaks.R and find_valleys.R find wave peaks and troughs; catHeader.R makes the tabbed headers in VOC_plots.Rmd
  - makedata_global.R is a record of how VOC_global_v3.RData, an earlier version of VOC_global_v4.RData, was built from OWID and GISAID. Its inputs rawdata/OWID_COVID_2023-05-06.RData and rawdata/variants/external_gisaid_byweek_2023-05-04_conserv.RData are not included, so it does not run here. rawdata/variants/gisaid_byweek_external.RData is a different, earlier GISAID pull (2023-03-30)
- scripts/3_model/ : runs the imputation and random forest models
  - Dataset42_create.Rmd is a record of how the fitting windows of the earlier 42-country tables were chosen: for each country, the first week in which Omicron BA.1 was over 10% of sequences, and the four weeks before it (written to data/Dates_42countriesDeltaBA1.csv). Its input data/VOC_global.RData, an earlier version of VOC_global_v4.RData is included, run from its folder and the script reproduces the dates of the 42 countries tables.
- results/ : saved imputations and model runs (V1_43, V1_OECD, Dynamic_log), each with its results and figures. This folder also includes figures/ , tables/ , map/ , and imputation/

## How to run:
- R 4.4.2; Python 3 with Jupyter
- R packages: dplyr, tidyr, tidyverse, readr, ggplot2, ggpubr, ggrepel, patchwork, gridExtra, scales, viridis, magick, mice, randomForest, zoo, reshape2, sf, rnaturalearth, rnaturalearthdata, knitr, rmarkdown, pdftools, plyr, RColorBrewer, lubridate, cowplot, data.table, ggnewscale, DT
- Python packages: pandas, numpy, scipy, matplotlib, seaborn, plotly, requests, beautifulsoup4, unidecode
- Run .R scripts from the repository root and knit .Rmd files from their own folder. Exception: run results/imputation/imputation_distribution_visualization.R from results/imputation/
- Master dataset: a record of how df_ver_10 was built. The model starts from df_ver_10 and does not need these steps. The notebooks in scripts/1_dataset/ ran in this order. Diversity and GISAID cannot be rerun because input spreadsheets are not included.
  - merge_owid_policy_vaccination_mobility
  - serology_from_serotracker
  - add_serology
  - Diversity and GISAID
  - merge_gisaid_diversity
  - LOCF
- Model:
  - Run scripts/2_variant_dynamics/creating_relsize.R
  - Knit scripts/3_model/Final_model.Rmd once per analysis "main", "oecd" and "dynamic", e.g. rmarkdown::render("scripts/3_model/Final_model.Rmd", params = list(analysis = "main")), which takes several hours. Each run saves its .RData in results/V1_43, results/V1_OECD or results/Dynamic_log.
  - After all three runs, knit results/V1_43/Results.Rmd, results/V1_OECD/Results.Rmd, and results/Dynamic_log/Results.Rmd, and run results/imputation/imputation_distribution_visualization.R for the figures.
- Other figures, listed below, have scripts that run on their own. 

## Figure to script map:
- Fig 1, 2, S5, S6, S9: scripts/2_variant_dynamics/VOC_plots.Rmd
- Fig 3: results/map/map.Rmd
- Fig 4, 5, 6: results/V1_43/Results.Rmd
- Fig S1, S2, S3: scripts/1_dataset/supplementary_plots.R
- Fig S4: results/imputation/imputation_distribution_visualization.R
- Fig S7, S8: scripts/2_variant_dynamics/gendist_plots.R
- Fig S10, S11, S12: results/V1_OECD/Results.Rmd
- Fig S13, S14, S15: results/Dynamic_log/Results.Rmd
- Table S1: the country lists in data/42_countries.csv plus India and Singapore, without Puerto Rico (43 countries); the OECD list in the "Filter for OECD" chunk of scripts/3_model/Final_model.Rmd
- Table S2: scripts/1_dataset/covid_means_march14.Rmd
- Table S3: the data categories were assigned by hand for the paper