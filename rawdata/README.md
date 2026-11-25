# Original Data:

Files sourced from public access datasets and websites to collect explanatory variables and make the base of the dataset. Data has been collected from the following sources:

- The complete Our World in Data COVID-19 dataset
  - Link: https://github.com/owid/covid-19-data
  - Website: https://ourworldindata.org/
  - Sourced: 2023-02-01
- COVID-19 Data Repository by the Center for Systems Science and Engineering (CSSE) at Johns Hopkins University
  - Link: https://github.com/CSSEGISandData/COVID-19
  - Website: https://systems.jhu.edu/
  - Sourced: 2023-02-01
- Oxford COVID-19 Government Response Tracker
  - Link: https://github.com/OxCGRT/covid-policy-tracker
  - Website: https://www.bsg.ox.ac.uk/research/covid-19-government-response-tracker
  - Sourced: 2023-02-01
- Google Community Mobility Reports
  - Link: https://www.google.com/covid19/mobility/
  - Sourced: 2023-02-15
- Google Dataset Publishing Language
  - Link: https://developers.google.com/public-data
  - Sourced: 2023-02-15
- SeroTracker
  - Link: https://serotracker.com/en/Data
  - Sourced: 2023-02-24
- Variants Data:
  - Contains all publically (GISAID) available data, internal NGDB is scrubbed
  - Pangolin version: 4.2, PUSHER-v1.18.1.1 (for pangolin designations)
  - lineage groupings based on VOC/VOI patterns is crude (see scripts/2_variant_dynamics/VOCVOI_groupingfunction.R for details).