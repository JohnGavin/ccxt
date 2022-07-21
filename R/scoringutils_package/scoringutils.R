

# https://arxiv.org/pdf/2205.07090.pdf
# Evaluating Forecasts with scoringutils in R

library(scoringutils)
library(tibble)
example_quantile |>
  na.omit() |>
  glimpse()

check_forecasts(example_quantile)

avail_forecasts(data = example_integer,
  by = c("model", "target_type"))


library(ggplot2)
avail_forecasts(data = example_integer,
  by = c("model", "target_type", "forecast_date")) |>
  plot_avail_forecasts(x = "forecast_date",
    show_numbers = FALSE) +
  facet_wrap(~ target_type) +
  labs(y = "Model", x = "Forecast date")

example_quantile %>%
  make_na(what = "truth",
    target_end_date > "2021-07-15",
    target_end_date <= "2021-05-22") %>%
  make_na(what = "forecast",
    model != "EuroCOVIDhub-ensemble",
    forecast_date != "2021-06-28") %>%
  plot_predictions(x = "target_end_date", by = c("target_type", "location")) +
  aes(colour = model, fill = model) +
  facet_wrap(target_type ~ location, ncol = 4, scales = "free_y") +
  labs(x = "Target end date")

score(example_quantile) |>
  glimpse()

score(example_quantile) |>
  summarise_scores(by = c("model", "target_type")) |>
  glimpse()

score(example_quantile) |>
  summarise_scores(by = c("model", "target_type")) |>
  summarise_scores(fun = signif, digits = 2) |>
  plot_score_table(y = "model", by = "target_type") +
  facet_wrap(~ target_type)

q <- c(0.01, 0.025, seq(0.05, 0.95, 0.05), 0.975, 0.99)
example_integer |>
  sample_to_quantile(quantiles = q) |>
  score() |>
  add_coverage(ranges = c(50, 90), by = c("model", "target_type")) |>
  summarise_scores(by = c("model", "target_type")) |>
  glimpse()

score(example_quantile) |>
  pairwise_comparison(by = c("model", "target_type"),
    baseline = "EuroCOVIDhub-baseline") |>
  glimpse()

score(example_quantile) |>
  pairwise_comparison(by = c("model", "target_type"),
    baseline = "EuroCOVIDhub-baseline") |>
  plot_pairwise_comparison() +
  facet_wrap(~ target_type)

score(example_continuous) |>
  summarise_scores(by = c("model", "location", "target_type")) |>
  plot_heatmap(x = "location", metric = "bias") +
  facet_wrap(~ target_type)

score(example_quantile) |>
  summarise_scores(by = c("model", "target_type")) |>
  plot_wis(relative_contributions = FALSE) +
  facet_wrap(~ target_type,
    scales = "free_x")

example_continuous |>
  pit(by = "model")

example_continuous |>
  pit(by = c("model", "target_type")) |>
  plot_pit() +
  facet_grid(target_type ~ model)


cov_scores <- score(example_quantile) |>
  summarise_scores(by = c("model", "target_type", "range", "quantile"))
plot_interval_coverage(cov_scores) +
  facet_wrap(~ target_type)
plot_quantile_coverage(cov_scores) +
  facet_wrap(~ target_type)

correlations <- example_quantile |>
  score() |>
  summarise_scores() |>
  correlation()
correlations |>
  glimpse()

correlations |>
  plot_correlation()
