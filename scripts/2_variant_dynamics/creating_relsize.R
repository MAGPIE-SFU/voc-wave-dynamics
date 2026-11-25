# Replicating Vibhuti's variables (created from my data) to avoid having to remerge any time my data changes

# I think I just create mult, then find max mult for Delta, BA.1, and BA.2

library("tidyverse")

load("data/VOC_global_v4.RData")
load("data/fitting_dates.Rmd")
BA1BA2 <- read.csv("data/42countriesBA1BA2_March_14.csv")

my_regions <- unique(BA1BA2$country)
my_regions <- append(my_regions, c("India", "Singapore", "USA")) 

voc_df <- gisaid_data_w %>% 
  group_by(week,VOC,location) %>% 
  mutate(prop_voc = sum(proportion,na.rm=TRUE),
            n_voc = sum(n, na.rm=TRUE)) %>% 
  filter(!VOC=="ND") %>% 
  full_join(owid_data_w) %>% 
  mutate(mult = weekly_cases*prop_voc)

delta_max <- voc_df %>% 
  filter(VOC=="Delta*") %>% 
  group_by(location) %>% 
  summarize(delta_max = max(mult))

BA1_max <- voc_df %>% 
  filter(VOC=="Omicron BA.1*") %>% 
  group_by(location) %>% 
  summarize(BA1_max = max(mult), BA1_peak = week[match(max(mult), mult)])

relsize <- voc_df %>% 
  filter(VOC=="Omicron BA.2*") %>% 
  group_by(location) %>% 
  summarize(BA2_max = max(mult)) %>% 
  full_join(BA1_max) %>% 
  full_join(delta_max) %>% 
  mutate(relsize_BA1 = round(BA1_max/delta_max, 3),
         relsize_BA2 = round(BA2_max/BA1_max, 3)) %>% 
  filter(location %in% my_regions) %>% 
  left_join(distinct(ungroup(fitting_dates))) %>% 
  mutate(relsize_dynamic = ifelse(BA2_end <= BA1_peak, round(BA2_max/delta_max, 3), relsize_BA2)) %>%
  select(-c(delta_max, BA1_max, BA2_max, BA1_peak))

save(relsize, file = "data/relsize_v4.RData")
write.csv(rename(relsize, country = location), "data/relsize_v4.csv", row.names = FALSE)