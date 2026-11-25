##################################################################
#### Script to generate some plots of the data (full dataset) ####
##################################################################

library(tidyverse)
library(ggpubr)
library(viridis)
library(grid)
library(gridExtra) 
library(zoo)
pdf(NULL)

dat <- read_csv(unz("data/covid_processed_v10_march14.zip", "df_ver_10_March_14.csv"))

##### plot proportion of each feature that is missing
missing <- colMeans(is.na(dat))
missing <- sort(missing, decreasing=T)
missing <- as_tibble(missing, rownames="Variable") %>%
  mutate(Variable = factor(Variable, levels = unique(Variable)))

# remove unwanted variables
unwanted <- c("weekly_cases", "Alpha*", "Beta", "Delta*", "Epsilon", "Eta", "Gamma",
              "Iota", "Kappa", "Lambda", "Mu", "ND", "Omicron BA.1*", 
              "Omicron BA.2*", "Omicron BA.2.75*", "Omicron BA.4*", "Omicron BA.5*", 
              "Omicron BQ.*", "Recombinants", "XBB*", "other", "wildtype A*", 
              "wildtype B*", "n", "continent", "Code", "country", "Day")
missing <- missing[! missing$Variable %in% unwanted,]

p1 <- ggplot(missing, aes(Variable, value)) + geom_point() + ylab("Proportion missing") + 
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + xlab("") 
p1

ggsave("results/figures/missing_fulldata.pdf", width = 40, height = 20, units = "cm")




# filter to the 25 OECD countries
oecdCountries <- c("Australia", "Austria", "Belgium", "Canada", "Chile", 
                   "Colombia", "Denmark", "Finland", "France", "Germany", 
                   "Ireland", "Israel", "Italy", "Japan", "Luxembourg", 
                   "Mexico", "Netherlands", "Norway", "Poland", "Portugal", 
                   "Spain", "Sweden", "Switzerland", "United Kingdom", "United States")

datf <- dat %>% filter(country %in% oecdCountries)

##### plot proportion of each feature that is missing
missing2 <- colMeans(is.na(datf))
missing2 <- sort(missing2, decreasing=T)
missing2 <- as_tibble(missing2, rownames="Variable") %>%
  mutate(Variable = factor(Variable, levels = unique(Variable)))

# remove unwanted variables
unwanted <- c("weekly_cases", "Alpha*", "Beta", "Delta*", "Epsilon", "Eta", "Gamma",
              "Iota", "Kappa", "Lambda", "Mu", "ND", "Omicron BA.1*", 
              "Omicron BA.2*", "Omicron BA.2.75*", "Omicron BA.4*", "Omicron BA.5*", 
              "Omicron BQ.*", "Recombinants", "XBB*", "other", "wildtype A*", 
              "wildtype B*", "n", "continent", "Code", "country", "Day")
missing2 <- missing2[! missing2$Variable %in% unwanted,]

p2 <- ggplot(missing2, aes(Variable, value)) + geom_point() + ylab("Proportion missing") + 
  theme_minimal() + ylim(c(0,1)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + xlab("") 
p2

ggsave("results/figures/missing_oecddata.pdf", width = 40, height = 20, units = "cm")


# combine to single 2-panel plot
ggarrange(p1 + rotate(), p2 + rotate(), 
          labels = c("A - all countries", "B - 25 OECD countries"),
          ncol = 2, nrow = 1)

ggsave("results/figures/missing_both.pdf", width = 40, height = 40, units = "cm")



# review some time series etc. 


# serology
serol <- c("Day", "country",
  "Nucleocapsid (N-protein) Adults (18-64 years)"                  
           ,"Nucleocapsid (N-protein) Children and Youth (0-17 years)"       
           ,"Nucleocapsid (N-protein) Multiple groups"                       
           ,"Nucleocapsid (N-protein) Seniors (65+ years)"                   
           ,"Nucleocapsid (N-protein), Spike Adults (18-64 years)"           
           ,"Nucleocapsid (N-protein), Spike Children and Youth (0-17 years)"
           ,"Nucleocapsid (N-protein), Spike Multiple groups"                
           , "Nucleocapsid (N-protein), Spike Seniors (65+ years)"            
           , "Spike Adults (18-64 years)"                                     
           , "Spike Children and Youth (0-17 years)"                          
           , "Spike Multiple groups"                                          
           , "Spike Seniors (65+ years)")

serol_used <- c("Day", "country","Nucleocapsid (N-protein) Multiple groups"                       
           ,"Nucleocapsid (N-protein), Spike Multiple groups"                
           , "Spike Multiple groups")

canser <- datf %>% filter(country=="Canada") 
canser <- canser[,serol_used]
canser <- canser %>% 
  pivot_longer(!(c(Day, country)), names_to = "type", values_to = "value")

s1 <- canser %>% ggplot(aes(Day, value)) + geom_line(aes(color=type), lwd=1.2) +
  theme_minimal() + theme(legend.position="bottom") + 
  ylab("Percent seropositive") + xlab("Date") + labs(color = "Serology category", 
                                                     subtitle="Canada") +
  guides(color=guide_legend(nrow=2, byrow=TRUE)) +
  scale_colour_hue(l = 45)
s1

canser <- datf %>% filter(country=="United States") 
canser <- canser[,serol_used]
canser <- canser %>% 
  pivot_longer(!(c(Day, country)), names_to = "type", values_to = "value")

s2 <- canser %>% ggplot(aes(Day, value)) + geom_line(aes(color=type), lwd=1.2) +
  theme_minimal() + theme(legend.position="bottom") + 
  ylab("Percent seropositive") + xlab("Date") + labs(color = "Serology category", 
                                                     subtitle="United States") +
  guides(color=guide_legend(nrow=2, byrow=TRUE)) +
  scale_colour_hue(l = 45)
s2

canser <- datf %>% filter(country=="Germany") 
canser <- canser[,serol_used]
canser <- canser %>% 
  pivot_longer(!(c(Day, country)), names_to = "type", values_to = "value")

s3 <- canser %>% ggplot(aes(Day, value)) + geom_line(aes(color=type), lwd=1.2) +
  theme_minimal() + theme(legend.position="bottom") + 
  ylab("Percent seropositive") + xlab("Date") + labs(color = "Serology category", 
                                                     subtitle="Germany") +
  guides(color=guide_legend(nrow=2, byrow=TRUE)) +
  scale_colour_hue(l = 45)
s3

canser <- datf %>% filter(country=="Chile") 
canser <- canser[,serol_used]
canser <- canser %>% 
  pivot_longer(!(c(Day, country)), names_to = "type", values_to = "value")

s4 <- canser %>% ggplot(aes(Day, value)) + geom_line(aes(color=type), lwd=1.2) +
  theme_minimal() + theme(legend.position="bottom") + 
  ylab("Percent seropositive") + xlab("Date") + labs(color = "Serology category", 
                                                     subtitle="Chile") +
  guides(color=guide_legend(nrow=2, byrow=TRUE)) +
  scale_colour_hue(l = 45)
s4

# combine to single plot
# deal w single legend
leg <- get_legend(s1)
as_ggplot(leg)

ggarrange(s1 + theme(legend.position='none'), s2+ theme(legend.position='none'), 
          s3+ theme(legend.position='none'), s4+ theme(legend.position='none'), leg,
          ncol = 2, nrow = 3)

blank <- ggplot() + theme_void()
ggarrange(
  ggarrange(s1 + theme(legend.position='none'), s4+ theme(legend.position='none'), blank, nrow = 1,
            widths = c(1, 1, 0), legend = "none"),
  ggarrange(s3 + theme(legend.position='none'), s2+ theme(legend.position='none'), blank, nrow = 1,
            widths = c(1, 1, 0), legend = "none"),
  ggarrange(blank, as_ggplot(leg), blank, nrow = 1,
            widths = c(0.5, 1, 0.5), legend = "none"),
  nrow = 3, heights=c(2,2,1)
)
ggsave("results/figures/serology.pdf", width = 11.05, height = 7.39)


# various for a country

cand <- datf %>% filter(country=="Canada") 

s1 <- cand %>% ggplot(aes(Day, new_cases_smoothed)) + geom_line(lwd=1.2) +
  theme_minimal() + theme(legend.position="bottom") + 
  ylab("New cases, smoothed") + xlab("Date") + labs(title = "Canada", subtitle="New cases, smoothed")
s1

s2 <- cand %>% ggplot(aes(Day, new_deaths_smoothed)) + geom_line(lwd=1.2) +
  theme_minimal() + theme(legend.position="bottom") + 
  ylab("New deaths, smoothed") + xlab("Date") + labs(subtitle="New deaths, smoothed")
s2

temp <- cand
temp$diversity <- na.locf(cand$diversity, na.rm=FALSE)
s3 <- temp %>% ggplot(aes(Day, diversity)) + geom_line(lwd=1.2) +
  theme_minimal() + theme(legend.position="bottom") + 
  ylab("Hill diversity, weekly") + xlab("Date") + labs(subtitle="Diversity")
s3

s4 <- cand %>% ggplot(aes(Day, life_expectancy)) + geom_line(lwd=1.2) +
  theme_minimal() + theme(legend.position="bottom") + 
  ylab("Life expectancy") + xlab("Date") + labs(subtitle="Life expectancy")
s4

s5 <- cand %>% ggplot(aes(Day, new_tests_smoothed)) + geom_line(lwd=1.2) +
  theme_minimal() + theme(legend.position="bottom") + 
  ylab("New tests, smoothed") + xlab("Date") + labs(subtitle="New tests, smoothed")
s5

s6 <- cand %>% ggplot(aes(Day, positive_rate)) + geom_line(lwd=1.2) +
  theme_minimal() + theme(legend.position="bottom") + 
  ylab("Test positive rate") + xlab("Date") + labs(subtitle="Test positive rate")
s6

s7 <- cand %>% ggplot(aes(Day,stringency_index)) + geom_line(lwd=1.2) +
  theme_minimal() + theme(legend.position="bottom") + 
  ylab("Stringency index") + xlab("Date") + labs(subtitle="Stringency index")
s7

s8 <- cand %>% ggplot(aes(Day,transit_stations)) + geom_line(lwd=1.2) +
  theme_minimal() + theme(legend.position="bottom") + 
  ylab("Relative transit station mobility") + xlab("Date") + labs(subtitle="Transit station mobility index")
s8

ggarrange(s1, s2,s5,s6,s3,s4,s7,s8,
          ncol = 2, nrow = 4)
ggsave("results/figures/canada_data.pdf", width = 20, height = 20, units = "cm")





