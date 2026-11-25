# Figs S7 and S8: genetic distance of BA.1 and BA.2 to the lineages circulating in their fitting windows.
# Uses the genetic-distance values the model uses (data/gendist_BA1.csv, data/gendist_BA2.csv), matched to
# countries by name; Puerto Rico removed, as in the model (43 countries). Run from the repo root.
# Output: results/figures/gendist_hist.png (S7) and results/figures/rel_group_scatter.png (S8).

suppressMessages({library(ggplot2); library(dplyr); library(tidyr)})

g <- bind_rows(BA.1 = read.csv("data/gendist_BA1.csv"), BA.2 = read.csv("data/gendist_BA2.csv"), .id = "variant") %>%
  filter(country != "Puerto Rico") %>%
  pivot_wider(names_from = segment, values_from = test_unique_mean)
r <- read.csv("data/relsize_v4.csv") %>% filter(country != "Puerto Rico")
stopifnot(n_distinct(g$country) == 43, setequal(g$country, r$country))

# S7: histogram of the all-genes distance, BA.1 and BA.2
# label every bin that holds one country (bins are (a, a + 0.5], as geom_histogram draws them)
lab7 <- g %>% mutate(bin_mid = ceiling(total * 2) / 2 - 0.25) %>%
  group_by(variant, bin_mid) %>% filter(n() == 1) %>% ungroup()
p7 <- ggplot(g, aes(total)) +
  geom_histogram(binwidth = 0.5, boundary = 0, fill = "grey35") +
  geom_text(data = lab7, aes(x = bin_mid, y = 1.2, label = country), angle = 90, hjust = 0, size = 3.2) +
  facet_wrap(~variant, ncol = 1, scales = "free_y") +
  scale_y_continuous(breaks = function(l) seq(0, floor(l[2]), by = max(1, ceiling(floor(l[2]) / 5)))) +
  labs(x = "Average Genetic Distance", y = "Frequency") +
  theme_bw(base_size = 12) +
  theme(strip.background = element_blank(), strip.text = element_text(hjust = 0, size = 13))
ggsave("results/figures/gendist_hist.png", p7, width = 10, height = 5, dpi = 200)

# S8: BA.2 genetic distance against the relative wave size BA.2/BA.1
s8 <- g %>% filter(variant == "BA.2") %>%
  left_join(r[, c("country", "relsize_BA2")], by = "country") %>%
  mutate(group = cut(relsize_BA2, c(-Inf, 0.05, 0.9, 1.1, Inf), right = FALSE,
                     labels = c("No BA.2 (< 0.05)", "Smaller BA.2 (0.05-0.9)", "Similar (0.9-1.1)", "Larger BA.2 (> 1.1)")))
p8 <- ggplot(s8, aes(relsize_BA2, total, colour = group)) +
  geom_point(size = 2.4) +
  geom_text(data = filter(s8, !grepl("Smaller", group) | total > 22.5), aes(label = country),
            size = 3, vjust = -0.9, show.legend = FALSE) +
  scale_colour_manual(values = c("#d95f02", "#7f7f7f", "#1b9e77", "#7570b3"), name = "BA.2 wave vs BA.1") +
  labs(x = "Relative wave size, BA.2/BA.1", y = "Average genetic distance of BA.2 (all genes)") +
  theme_bw(base_size = 12)
ggsave("results/figures/rel_group_scatter.png", p8, width = 9, height = 5, dpi = 200)
