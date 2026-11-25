# Data licences and attribution

The code in this repository (`scripts/`, the `.R` and `.Rmd` files in `results/`) is under the MIT licence in
`LICENSE`. The MIT licence does not cover the data files or the paper. Third-party data keep the licence of their
source, listed below. Files we derived from them (`data/`, `results/`) carry the same terms as their inputs.

Checked against each source on 2026-11-15.

| Source | Licence / terms | Files in this repository | Cite |
|---|---|---|---|
| Our World in Data, COVID-19 dataset (github.com/owid/covid-19-data) | CC BY 4.0 for data produced by OWID; third-party series keep their original licence | `rawdata/owid-covid-data.csv`, `rawdata/covid-vaccination-doses-per-capita.csv`, `rawdata/covid-vaccine-by-age.csv`, `rawdata/covid-vaccine-doses-by-manufacturer.csv` | Mathieu et al. 2021, *Nat Hum Behav*, doi:10.1038/s41562-021-01122-8; Hasell et al. 2020, *Sci Data*, doi:10.1038/s41597-020-00688-8 |
| Johns Hopkins University CSSE COVID-19 Data Repository (github.com/CSSEGISandData/COVID-19), via OWID | CC BY 4.0 | case and death columns of `rawdata/owid-covid-data.csv` | Dong, Du, Gardner 2020, *Lancet Infect Dis* 20(5):533-534, doi:10.1016/S1473-3099(20)30120-1 |
| Oxford COVID-19 Government Response Tracker (github.com/OxCGRT/covid-policy-dataset), via OWID | CC BY 4.0 | `rawdata/covid-contact-tracing.csv`, `covid-vaccination-policy.csv`, `internal-movement-covid.csv`, `international-travel-covid.csv`, `school-closures-covid.csv`, `stay-at-home-covid.csv`, `workplace-closures-covid.csv`; stringency columns of `owid-covid-data.csv` | Hale et al. 2021, *Nat Hum Behav*, doi:10.1038/s41562-021-01079-8 |
| Google COVID-19 Community Mobility Reports (google.com/covid19/mobility), via OWID | Google Terms of Service (required to download or use the data) | `rawdata/change-visitors-grocery-stores.csv`, `change-visitors-parks-covid.csv`, `change-visitors-retail-recreation.csv`, `changes-residential-duration-covid.csv`, `visitors-transit-covid.csv`, `workplace-visitors-covid.csv` | Google LLC, COVID-19 Community Mobility Reports |
| SeroTracker (github.com/serotracker/sars-cov-2-data) | No licence stated by the source | `rawdata/serotracker.csv` | Arora et al. 2021, *Lancet Infect Dis* 21(4):e75-e76 |
| Google Dataset Publishing Language, `countries.csv` (developers.google.com/public-data/docs/canonical/countries_csv) | CC BY 4.0 (page footer, checked 2026-11-17) | `rawdata/countries_lat_lon.csv`, `rawdata/lat_lon_data.csv` | Google, Dataset Publishing Language, countries.csv |
| GISAID EpiCoV (gisaid.org) | GISAID Database Access Agreement: GISAID data may not be distributed outside the GISAID community; data contributors must be acknowledged | weekly lineage counts `rawdata/variants/gisaid_byweek_external.RData`, `data/VOC_global_v4.RData`, and the summaries built from them in `data/` | Khare et al. 2021, *China CDC Weekly* 3(49):1049; EPI_SET doi:10.55876/gis8.241023pk |

## GISAID acknowledgement

The SARS-CoV-2 sequences used in this study are listed in GISAID EPI_SET doi:10.55876/gis8.241023pk. We gratefully acknowledge all data contributors, including the Authors and their
Originating laboratories responsible for obtaining the specimens, and their submitting laboratories for generating
the genetic sequence and metadata and sharing via the GISAID Initiative, on which this research is based.

## Paper

`paper/COVID_19_variant_waves__PHAC_magpie_.pdf` is the authors' manuscript as prepared for double-anonymized review
(title page, then the anonymized text; the data statement omits the repository link, and there are no acknowledgements
or funding sections). It is not the journal's typeset version. It is not under the MIT licence; its copyright stays
with the authors or the publisher.
