#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(ggplot2)
})

out_dir <- "."

safe_numeric_vars <- function(df, exclude = character(0)) {
  keep <- names(df)[vapply(df, is.numeric, logical(1))]
  setdiff(keep, exclude)
}

e <- new.env()
load("../V1_43/V1_43.RData", envir = e)
imputed_list <- lapply(e$BA1BA2, function(df) { 
  names(df) <- make.names(names(df))
  df
})

original <- imputed_list[[1]]
for (v in names(original)[vapply(original, is.numeric, logical(1))]) {
  vals <- sapply(imputed_list, function(d) d[[v]])
  original[[v]][apply(vals, 1, function(r) length(unique(r)) > 1)] <- NA
}

original_reduced <- original %>% select(any_of(unique(c("country", "Day", names(original)))))

numeric_vars <- safe_numeric_vars(original_reduced, exclude = c("Day"))
missing_counts <- sapply(numeric_vars, function(v) sum(is.na(original_reduced[[v]])))
missing_counts <- sort(missing_counts, decreasing = TRUE)
missing_vars <- names(missing_counts[missing_counts > 0])

if (length(missing_vars) == 0) {
  stop("No missing values found in shared numeric variables.")
}

density_vars <- head(missing_vars, 12)

# Overlaid density: observed vs all imputations.
obs_density <- original_reduced %>%
  select(any_of(density_vars)) %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "value") %>%
  filter(!is.na(value))

imp_density <- bind_rows(lapply(seq_along(imputed_list), function(i) {
  imputed_list[[i]] %>%
    select(any_of(density_vars)) %>%
    pivot_longer(cols = everything(), names_to = "variable", values_to = "value") %>%
    mutate(imputation = paste0("imp_", i))
}))

pretty_var_label <- function(x) {
  lbl <- gsub("[._]+", " ", x)
  lbl <- gsub("\\s+", " ", lbl)
  lbl <- trimws(lbl)
  lbl <- tolower(lbl)
  lbl <- gsub("\\bhosp\\b", "hospital", lbl)
  paste0(toupper(substr(lbl, 1, 1)), substr(lbl, 2, nchar(lbl)))
}

p_density <- ggplot() +
  geom_density(
    data = imp_density,
    aes(x = value, group = imputation, color = "Imputed"),
    key_glyph = "path",
    linewidth = 0.35,
    alpha = 0.3,
    na.rm = TRUE
  ) +
  geom_density(
    data = obs_density,
    aes(x = value, color = "Observed"),
    key_glyph = "path",
    linewidth = 0.9,
    na.rm = TRUE
  ) +
  scale_color_manual(values = c("Observed" = "#1f2937", "Imputed" = "#86a8c6")) +
  facet_wrap(~variable, scales = "free", ncol = 3, labeller = labeller(variable = pretty_var_label)) +
  labs(
    title = "Observed vs Imputed Density Overlays",
    x = "Value",
    y = "Density",
    color = NULL
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")

ggsave(
  filename = file.path(out_dir, "density_overlay_top_missing.pdf"),
  plot = p_density,
  width = 13,
  height = 10
)

message("Saved outputs to: ", normalizePath(out_dir))
message("Top variables used for density: ", paste(density_vars, collapse = ", "))