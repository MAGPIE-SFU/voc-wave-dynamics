# Generated Data:

Data Files that have been generated after using the scripts.
 
Latest version of the main data is contained in the covid_processed_v10_march14.zip, which holds the master dataset df_ver_10_March_14.csv. Data dictionary for this dataset can be found in Documentation_Ver_10.0.pdf. This dataset can be transformed, filtered or sliced to perform analysis. 

Files, in the order they are used:

- `voc_emergence.RData`: global emergence date of each VOC / Nextstrain clade, estimated by time to most recent common ancestor (tMRCA; https://academic.oup.com/ve/article/4/1/vex042/4794731). The Omicron BA.1 date is from Viana et al. 2022 (https://pubmed.ncbi.nlm.nih.gov/35042229/). Read by `scripts/2_variant_dynamics/makedata_global.R`. Columns:
  - `VOC`: VOC grouping
  - `clade`: Nextstrain clade
  - `global_emerg`: inferred date of global emergence
  - `ci_low`, `ci_high`: 95% CI
- `VOC_global_v4.RData`: the variant-dynamics data: daily and weekly OWID cases, weekly GISAID variant counts per country, diversity, VOC timing and wave metrics. Read by `VOC_plots.Rmd` and `creating_relsize.R`.
- `VOC_global.RData`: an earlier version of `VOC_global_v4.RData` (OWID pull of 2023-05-06, GISAID to 2023-04-23, 241 places), without diversity or VOC timing. Read by `scripts/3_model/Dataset42_create.Rmd`, which reproduces `Dates_42countriesDeltaBA1.csv`.
- `wave_metrics.csv`, `diversity_df.csv`: csv copies of the wave metrics and diversity tables in `VOC_global_v4.RData`. Read by `Final_model.Rmd` and `VOC_plots.Rmd`.
- `42countriesBA1BA2_March_14.csv`, `42countriesDeltaBA1_March_14.csv`: the earlier 42-country tables. Their fitting windows were chosen by `scripts/3_model/Dataset42_create.Rmd`; the script that joined them with the master dataset is not included. The BA1BA2 table is read by `VOC_plots.Rmd` and `creating_relsize.R`.
- `fitting_dates.Rmd`: the weekly fitting-window dates per country. Despite the `.Rmd` name it is an R data file; open it with `load()`. Written by `VOC_plots.Rmd`, read by `creating_relsize.R`.
- `BA1_pull_dates.RData`, `BA2_pull_dates.RData`: first week and end date of each country's BA.1 and BA.2 fitting window. Written and read by `VOC_plots.Rmd`.
- `relsize_v4.csv` (same data in `relsize_v4.RData`): the response variables, the relative wave sizes BA.1/Delta, BA.2/BA.1 and `relsize_dynamic`, with the fitting-window dates. Written by `creating_relsize.R`, read by `Final_model.Rmd` and `gendist_plots.R`.
- `sel_coef.csv` (same values in `sel_coef_fit.RData`): selection coefficient % per day of BA.1 and BA.2 relative to the other lineages, with 95% CI, per country. Read by `Final_model.Rmd`.
- `gendist_BA1.csv`, `gendist_BA2.csv` (same values in `fitting_window_gendist.RData`): mean genetic distance of BA.1 and BA.2 to the lineages circulating in each country's fitting window, S gene and all genes. Read by `Final_model.Rmd` and `gendist_plots.R`.
- `44countriesDeltaBA1_May_07.csv`, `44countriesBA1BA2_May_07.csv`: the model input tables, 44 countries × the 5 weeks of each fitting window, taken from the master dataset. Read by `Final_model.Rmd`.
- `42_countries.csv`: the list of 42 countries (one column, `Country`). Read by `Final_model.Rmd` and `results/map/map.Rmd`.