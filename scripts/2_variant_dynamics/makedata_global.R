# Load libraries ###############################################################
listlibraries <- c(
  "plyr", "tidyverse",
  "scales", "RColorBrewer", "lubridate", "vctrs", "slider", "tsibble", "vegan"
)

invisible(lapply(listlibraries, library, character.only = TRUE))

source("scripts/2_variant_dynamics/find_peaks.R")
source("scripts/2_variant_dynamics/find_valleys.R")
source("scripts/2_variant_dynamics/VOCVOI_groupingfunction.R")

# OWID #########################################################################

# Download OWID data
#owid_data <- read_csv("https://covid.ourworldindata.org/data/owid-covid-data.csv")
load("rawdata/OWID_COVID_2023-05-06.RData") # loading last pull rather than getting a new pull

# Keep select variables
colnames(owid_data)

owid_data_d <- owid_data %>%
  select(location, date, new_cases, new_cases_smoothed, new_deaths, new_deaths_smoothed, icu_patients, hosp_patients, new_tests, stringency_index) %>%
  mutate(location = recode(location, "United States" = "USA"))

# Was having trouble down the line with the peak function, saying NA/NAN argument.
# Identify locations to drop from global analysis based on total case counts:
low_cases <- owid_data_d %>%
  group_by(location) %>%
  summarise(sum_cases = sum(new_cases, na.rm = TRUE)) %>%
  filter(sum_cases < 100)

# Create vector of locations to drop
drop_locations <- low_cases$location

# Remove identified locations
owid_data_d <- owid_data_d %>%
  filter(!location %in% drop_locations)

# Define as time series object grouped by location
owid_data_d <- tsibble(owid_data_d, key = location, index = date)


# Check for missing values
which(is.na(owid_data_d$new_cases))
which(is.na(owid_data_d$new_cases_smoothed))

# More missing in the 7-day rolling average which is interesting (new_cases_smoothed). Compute my own to compare:

owid_data_d <- owid_data_d %>%
  group_by(location) %>% # group by location
  mutate( # create new columns
    new_cases_7ra = slide_dbl(
      new_cases, # calculate on new_cases
      .f = ~ mean(.x, na.rm = TRUE), # function is mean() with missing values removed
      .before = 6
    ) # window is the row and 6 prior row
  )

# Check for missing in the new rolling average:
which(is.na(owid_data_d$new_cases_7ra))

# No missing values now, but values look identical to the provided column. Let's use my version

###  Repeating for deaths:

owid_data_d <- owid_data_d %>%
  group_by(location) %>% # group by location
  mutate( # create new columns
    new_deaths_7ra = slide_dbl(
      new_deaths, # calculate on new_cases
      .f = ~ mean(.x, na.rm = TRUE), # function is mean() with missing values removed
      .before = 6
    ) # window is the row and 6 prior row
  )

which(is.na(owid_data_d$new_deaths_7ra)) # Looks better, keep these.

# Drop old smoothed vars:
owid_data_d <- owid_data_d %>%
  select(!c(new_cases_smoothed, new_deaths_smoothed))

# Create a weekly owid_data_d df (original is daily)
owid_data_w <- owid_data_d %>%
  index_by(week = ~ floor_date(., unit = "week")) %>%
  summarise(
    weekly_cases = sum(new_cases, na.rm = TRUE),
    weekly_deaths = sum(new_deaths, na.rm = TRUE),
    weekly_tests = sum(new_tests, na.rm = TRUE),
    weekly_hosp = mean(hosp_patients, na.rm = TRUE),
    weekly_icu = mean(icu_patients, na.rm = TRUE),
    stringency_index = mean(stringency_index, na.rm = TRUE)
  ) %>% 
  mutate(stringency_index = if_else(is.nan(stringency_index), 0, stringency_index),
         weekly_hosp = if_else(is.nan(weekly_hosp), 0, weekly_hosp),
         weekly_icu = if_else(is.nan(weekly_icu), 0, weekly_icu),
         )
  

# Drop last week (last week includes NA days so returns an artificial 0 for the week, leading to an erroneous final valley)
owid_data_w <- owid_data_w %>%
  group_by(location) %>%
  slice(-n())

# GISAID #######################################################################

load("rawdata/variants/external_gisaid_byweek_2023-05-04_conserv.RData") # load GISAID weekly

# first sequence is dated March 2019 - remove
dfglobalweekly <- dfglobalweekly[-1,]

# create world voc df
voc_global_sum <- dfglobalweekly %>%
  select(week, n, pango_lineage) %>% # remove country
  group_by(pango_lineage, week) %>% # perform operations on unique combinations of week and pango_lineage
  mutate(n = sum(n)) %>% # sum pango_lineage by week (global)
  distinct() %>% # remove duplicate rows
  group_by(week) %>% # perform operations by week
  mutate(
    freq = prop.table(n), # get proportion of pango_lineage per week
    country = "World", # add country identifier
    n_seq_perwk = sum(n) # get total sequences per week
  ) 

# apply VOC grouping function:
voc_global_sum$VOC <- rep("other", length(voc_global_sum$pango_lineage))
for (row in 1:nrow(VOCVOI)) {
  name <- VOCVOI[row, "name"]
  pattern <- gsub("\\.", ".", VOCVOI[row, "pattern"])
  voc_global_sum$VOC[grepl(pattern, voc_global_sum$pango_lineage)] <- name
}

# combine with per country df
dfglobalweekly <- bind_rows(dfglobalweekly, voc_global_sum)

# renaming vars

gisaid_data_w <- dfglobalweekly %>%
  rename(
    location = country, # to match owid_data_d grouping variable
    proportion = freq
  ) # rename to proportion

# Had some problems down the line when using pango_lineage to get diversity esimates
# Check for and change empty characters in pango_lineage:
which(!nzchar(gisaid_data_w$pango_lineage)) # returns indexs where pango_lineage = ""
print(gisaid_data_w$pango_lineage[47710]) # printing example to confirm

gisaid_data_w <- gisaid_data_w %>%
  filter(!pango_lineage == "", # remove empty pangos
         !VOC == "Unassigned") %>% # remove unassigned VOCs
  group_by(week, location) %>% 
  mutate(proportion = prop.table(n), # recalculate proportions and total sequences after removals
         n_seq_perwk = sum(n)) %>% 
  ungroup

# repeating above code to check it worked:
which(!nzchar(gisaid_data_w$pango_lineage)) # returns indexs where pango_lineage = ""

# Make region vector to use as subset identifier for executing for loops
region <- intersect(owid_data_w$location, gisaid_data_w$location) # this creates a vector of common locations bewteen the two dfs

# fill out missing weeks for complete time series (needed for vd plots)
gisaid_data_w <- gisaid_data_w %>%
  ungroup() %>% # needed to ungroup as using the grouped_df was causing an error
  complete(location, week = seq(min(week), max(week), by = "1 week"), fill = list(n = 0, proportion = 0, VOC = "ND", pango_lineage = "ND", n_seq_perwk = 0))

## Create weekly diversity df ##################################################

# Widen data so we have different lineages in columns, and a single row for each location*date
voc_wide <- gisaid_data_w %>% 
  select(location, week, pango_lineage, n) %>% 
  pivot_wider(names_from = pango_lineage, values_from = n, values_fill = 0)

# subet to pango lineages only
pango_only <- voc_wide %>% 
  select(-location, -week)

# create diversity df and merge with voc_wide
diversity_df <- pango_only %>% 
  mutate(richness = specnumber(pango_only),
         diversity = exp(diversity(pango_only))) %>% 
  select(richness, diversity) %>% 
  bind_cols(voc_wide) %>% 
  select(location, week, richness, diversity) 

# add weekly cases from owid

owid_cases_w <- owid_data_w %>% 
  select(location, week, weekly_cases)

diversity_df <- merge(diversity_df, owid_cases_w, by = c("location", "week"))

# Create sequencing effort variable
weekly_seq <- gisaid_data_w %>% 
  distinct(week, location, n_seq_perwk)

diversity_df <- merge(diversity_df, weekly_seq, all.x = TRUE) %>% 
  mutate(sequenc_eff = round((n_seq_perwk/weekly_cases), 2)) %>% 
  mutate(sequenc_eff = if_else(is.nan(sequenc_eff), 0, sequenc_eff)) %>%  # note, sequencing effort is set to zero until both case and sequence data is available
  select(location, week, weekly_cases, n_seq_perwk, sequenc_eff, richness, diversity) %>% 
  mutate(richness = if_else(n_seq_perwk == 0, NA, richness),
         diversity = if_else(n_seq_perwk == 0, NA, diversity))

# Make wave metrics df #########################################################

wave_metrics <- data.frame()

for (location in region) {
  # Subset data by region
  region_data <- owid_data_w[owid_data_w$location == location, ]

  # Make a standalone daily cases object in the global environment:
  cases <- region_data$weekly_cases

  # Apply functions to find peaks and valleys
  peaks <- find_peaks(cases, tolerance = 4)
  valleys <- find_valleys(cases, peaks)

  # Create df with only peaks
  peaks_only <- region_data[peaks, ]

  # Add peak number

  peaks_only <- peaks_only %>%
    mutate(wave_n = row_number())

  # Create df with valleys
  valleys_only <- region_data[valleys, ]

  # Create peak time metrics

  peaks_only <- peaks_only %>%
    mutate(
      wave_start = valleys_only$week[-nrow(valleys_only)],
      wave_end = valleys_only$week[-1],
      wave_length_w = as.numeric(difftime(wave_end, wave_start, units = "weeks")),
    )

  # Create total cases in each peak window:
  interval_sum <- c()
  for (i in 1:(length(valleys) - 1)) { # iterate over each consecutive valley

    window <- region_data[valleys[i]:valleys[i + 1], ] # set window from index i to i+1 in valleys

    window_i_total <- sum(window$weekly_cases)

    interval_sum <- c(interval_sum, window_i_total)
  }

  # Add to peak_only df

  peaks_only <- peaks_only %>%
    mutate(
      total_cases = interval_sum
    )

  # append results to df
  wave_metrics <- bind_rows(wave_metrics, peaks_only)
}

# Create voc wave metrics df ###################################################

# Make wave metrics df
wave_voc <- data.frame()

for (location in region) {
  # Subset data by region
  region_data <- owid_data_w[owid_data_w$location == location, ]
  region_lin <- gisaid_data_w[gisaid_data_w$location == location, ]

  # Make a standalone daily cases object in the global environment:
  cases <- region_data$weekly_cases

  # Apply functions to find peaks and valleys
  peaks <- find_peaks(cases, tolerance = 4)
  valleys <- find_valleys(cases, peaks)

  # First widen lineage data so there is one row for each date (to allow for indexing by valleys)
  voc_wide <- region_lin %>%
    select(location, week, proportion, VOC) %>%
    pivot_wider(names_from = VOC, values_from = proportion, values_fn = sum)

  # Merge with region_data for prop
  region_data_m <- merge(region_data, voc_wide, by = c("week", "location"), all.x = TRUE)
  region_data_m <- as_tibble(region_data_m) %>%
    mutate_at(vars(-week), ~ ifelse(is.na(.), 0, .))
  
  # create version with prop*case (for determining cases attributable to vocs per wave)
  region_data_mult <- region_data_m %>% 
    mutate_at(vars(10:(ncol(region_data_m))), ~ . *weekly_cases)

  # create VOC label vector (country specific)
  region_lin$VOC_f <- as.factor(region_lin$VOC) # create factor var to see categories
  vocs <- levels(region_lin$VOC_f) # assign categories to a vector

  # create df:

  for (i in 1:(length(valleys) - 1)) { # iterate over each consecutive valley
    # finding VOC peak proportion date
    window <- region_data_m[valleys[i]:valleys[i + 1], ] # set window from index i to i+1 in valleys (prop)
    voc_max <- sapply(window[, c(vocs)], max) # finds the max proportion for each VOC in the wave
    voc_max_index <- sapply(window[, c(vocs)], which.max) # finds the index of the max values for each VOC
    voc_max_date <- window$week[voc_max_index] # find the dates at those indexes

    # finding attributable VOC case proportion for wave
    window2 <- region_data_mult[valleys[i]:valleys[i + 1], ] # set window from index i to i+1 in valleys (n)
    voc_sum <- sapply(window2[, c(vocs)], sum) # finds the sum of attributable cases for each VOC in the wave
    voc_total <- sum(voc_sum) # determine attributable cases
    voc_prop <- voc_sum / voc_total # calculate VOC proportion for wave

    voc_max_df <- data.frame(VOC = names(voc_max), proportion = voc_prop) %>% # convert max to df
      cbind(voc_max_date) %>% # append date column
      arrange(desc(proportion)) %>% # sort in descending order
      slice(1:5) %>% # keep only the top 5
      mutate(
        top_voc = row_number(),
        top_date = row_number(),
        top_proportion = row_number()
      ) %>% # create name columns for pivot_wider
      pivot_wider(names_from = c(top_voc, top_proportion, top_date), values_from = c(VOC, proportion, voc_max_date)) %>%
      rename_with(~ substr(., 1, nchar(.) - 4)) # fix names by removing last 4 characters

    wave_voc <- bind_rows(wave_voc, voc_max_df)
  }
}

# Create voc diversity wave metrics df#########################################

# Make wave metrics df
wave_diversity <- data.frame()

for (location in region) {
  # Subset data by region
  region_data <- owid_data_w[owid_data_w$location == location, ]
  region_lin <- gisaid_data_w[gisaid_data_w$location == location, ]

  # Make a standalone daily cases object in the global environment:
  cases <- region_data$weekly_cases

  # Apply functions to find peaks and valleys
  peaks <- find_peaks(cases, tolerance = 4)
  valleys <- find_valleys(cases, peaks)

  # First widen lineage data so there is one row for each date (to allow for indexing by valleys)
  voc_wide <- region_lin %>%
    select(location, week, n, pango_lineage) %>%
    pivot_wider(names_from = pango_lineage, values_from = n, values_fill = 0)

  ## Merge with region_data for n
  region_data_m <- merge(region_data, voc_wide, by = c("week", "location"), all.x = TRUE) # this keeps the indexes identical for cases and lineages
  region_data_m <- as_tibble(region_data_m) %>%
    mutate_at(vars(-week, -location), ~ ifelse(is.na(.), 0, .))

  # create VOC label vector (country specific)
  region_lin$pango_f <- as.factor(region_lin$pango_lineage) # create factor var to see categories
  pango <- levels(region_lin$pango_f) # assign categories to a vector

  # create df:

  for (i in 1:(length(valleys) - 1)) { # iterate over each consecutive valley
    # finding VOC peak proportion date
    window <- region_data_m[valleys[i]:valleys[i + 1], ] # set window from index i to i+1 in valleys (prop)
    voc_sum <- sapply(window[, c(pango)], sum) # finds the sum of each pango lineage in the wave
    voc_sum_wave <- as_tibble_row(voc_sum)

    # create diversity df and merge with voc_wide
    pango_diversity <- voc_sum_wave %>%
      mutate(
        richness = specnumber(voc_sum_wave),
        diversity = exp(diversity(voc_sum_wave)) # note, adding exp() converts Shannon Index to Hill Diversity, which can be interpreted as the effective number of species
      ) %>%
      select(richness, diversity) %>% 
      mutate(diversity = if_else(richness == 0, NA, diversity))

    wave_diversity <- bind_rows(wave_diversity, pango_diversity) # append to wave_diversity
  }
}

# Combine dfs ##################################################################

wave_metrics <- cbind(wave_metrics, wave_voc, wave_diversity)

# Arrange table:
wave_metrics <- wave_metrics %>%
  rename(
    wave_peak = week,
    peak_weekly_cases = weekly_cases
  ) %>% 
  mutate( # Remove VOC name and peak date when prop=0, round proportions
    VOC_1 = if_else(proportion_1 == 0, NA, VOC_1),
    VOC_2 = if_else(proportion_2 == 0, NA, VOC_2),
    VOC_3 = if_else(proportion_3 == 0, NA, VOC_3),
    VOC_4 = if_else(proportion_4 == 0, NA, VOC_4),
    VOC_5 = if_else(proportion_5 == 0, NA, VOC_5),
    voc_max_date_1 = if_else(proportion_1 == 0, NA, voc_max_date_1),
    voc_max_date_2 = if_else(proportion_2 == 0, NA, voc_max_date_2),
    voc_max_date_3 = if_else(proportion_3 == 0, NA, voc_max_date_3),
    voc_max_date_4 = if_else(proportion_4 == 0, NA, voc_max_date_4),
    voc_max_date_5 = if_else(proportion_5 == 0, NA, voc_max_date_5),
    proportion_1 = if_else(proportion_1 == 0, NA, proportion_1),
    proportion_2 = if_else(proportion_2 == 0, NA, proportion_2),
    proportion_3 = if_else(proportion_3 == 0, NA, proportion_3),
    proportion_4 = if_else(proportion_4 == 0, NA, proportion_4),
    proportion_5 = if_else(proportion_5 == 0, NA, proportion_5),
    proportion_1 = round(proportion_1, 2),
    proportion_2 = round(proportion_2, 2),
    proportion_3 = round(proportion_3, 2),
    proportion_4 = round(proportion_4, 2),
    proportion_5 = round(proportion_5, 2),
    diversity = round(diversity, 2)
  ) %>% 
  mutate(avg_weekly_cases = round((total_cases/wave_length_w), 2), # add average weekly cases and VOC1_lag
         VOC1_lag = if_else(!is.na(VOC_1), as.numeric(difftime(voc_max_date_1, wave_peak, units = "weeks")), NA)) %>% 
  select(location, wave_n, wave_start, wave_peak, wave_end, wave_length_w, peak_weekly_cases, avg_weekly_cases, total_cases, richness, diversity, VOC_1, proportion_1, voc_max_date_1, VOC1_lag, VOC_2, proportion_2, voc_max_date_2, VOC_3, proportion_3, voc_max_date_3, VOC_4, proportion_4, voc_max_date_4, VOC_5, proportion_5, voc_max_date_5)

# Create VOC timing df #########################################################
voc_weekly <- gisaid_data_w %>%
  select(!pango_lineage) %>%
  aggregate(cbind(
    n, proportion
  ) ~ location + week + VOC, FUN = sum) # sums each column in cbind() by unique combinations of location, week and voc

# Max VOC Proportion (weekly)
voc_peak_date <- voc_weekly %>%
  group_by(location, VOC) %>%
  summarise(max_proportion = max(proportion))%>%
  rename(proportion = max_proportion) %>%
  merge(voc_weekly, by = c("location", "VOC", "proportion"), all.x = TRUE) %>%
  select(location, week, VOC, proportion) %>%
  rename(max_proportion = proportion) %>%
  group_by(location, VOC) %>% # this keeps only the earliest week so there is one row per voc per location (previously some VOCs like delta had several maximums a 1.0)
  filter(week == min(week))

# create first emergence df
first_emerg <- gisaid_data_w %>%
  group_by(location, VOC) %>%
  filter(week == min(week)) %>%
  distinct(week, location, VOC) %>%
  ungroup() %>%
  rename(local_emerg = week)

# merge dfs

voc_timing <- merge(voc_peak_date, first_emerg, by = c("location", "VOC")) %>%
  rename(peak_week = week) %>%
  mutate(time_to_peak_local = as.numeric(difftime(peak_week, local_emerg, units = "weeks"))) %>%
  select(location, VOC, local_emerg, peak_week, max_proportion, time_to_peak_local)%>% 
  filter(!VOC %in% c("ND", "other", "Recombinants"))

load("data/voc_emergence.RData")
voc_timing <- merge(voc_timing, emergence) %>% 
  mutate(time_to_peak_global = as.numeric(difftime(peak_week, global_emerg, units = "weeks")),
         time_to_local_emerg = as.numeric(difftime(local_emerg, global_emerg, units = "weeks"))) %>% 
  select(location, VOC, local_emerg, global_emerg, time_to_local_emerg, peak_week, max_proportion, time_to_peak_local, time_to_peak_global)%>%
  mutate(time_to_local_emerg = ceiling(time_to_local_emerg),
         time_to_peak_global = ceiling(time_to_peak_global))

# Save data ####################################################################

# Saving copy of OWID data (time stamped, in case we lose access)
date <- Sys.Date()
file_name <- paste0("rawdata/OWID_COVID_", date, ".RData")
save(owid_data, file = file_name)

# Saving global working data
save(owid_data_d, owid_data_w, gisaid_data_w, diversity_df, voc_timing, region, pal, wave_metrics, file = "data/VOC_global_v3.RData")

# Author/Date ##################################################################
# Nathan K Smith
# May 2023
