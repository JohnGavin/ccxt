# https://www.andrewheiss.com/blog/2022/05/09/hurdle-lognormal-gaussian-brms/

library(brms)
library(gapminder)

model_gdp_hurdle <- brm(
  bf(gdpPercap ~ lifeExp,
    hu ~ 1),
  data = gapminder,
  family = hurdle_lognormal(),
  # chains = CHAINS, iter = ITER, 
  #   warmup = WARMUP, seed = BAYES_SEED,
  silent = 2
)

tidy(model_gdp_hurdle)

hu_intercept <- tidy(model_gdp_hurdle) |> 
  filter(term == "hu_(Intercept)") |> 
  pull(estimate)

# Logit scale intercept
hu_intercept
## b_hu_Intercept 
##          -2.13

# Transformed to a probability/proportion
plogis(hu_intercept)

gapminder |> 
  count(is_zero) |> 
  mutate(prop = n / sum(n))
## # A tibble: 2 × 3
##   is_zero     n  prop
##   <lgl>   <int> <dbl>
## 1 FALSE    1502 0.894
## 2 TRUE      178 0.106


# Exponential
pp_check(model_gdp_hurdle)

# Logged
pred <- posterior_predict(model_gdp_hurdle)
bayesplot::ppc_dens_overlay(y = log1p(gapminder$gdpPercap), 
  yrep = log1p(pred[1:10,]))

pred_gdp_hurdle <- model_gdp_hurdle |> 
  predicted_draws(newdata = tibble(lifeExp = 60)) |>
  mutate(is_zero = .prediction == 0,
    .prediction = ifelse(is_zero, .prediction - 0.1, .prediction))

ggplot(pred_gdp_hurdle, aes(x = .prediction)) +
  geom_histogram(aes(fill = is_zero), binwidth = 2500, 
    boundary = 0, color = "white") +
  geom_vline(xintercept = 0) + 
  scale_x_continuous(labels = label_dollar(scale_cut = cut_short_scale())) +
  scale_fill_manual(values = c(clrs[4], clrs[1]), 
    guide = guide_legend(reverse = TRUE)) +
  labs(x = "GDP per capita", y = "Count", fill = "Is zero?",
    title = "Predicted GDP per capita from hurdle model") +
  coord_cartesian(xlim = c(-2500, 75000)) +
  theme_nice() +
  theme(legend.position = "bottom")


model_gdp_hurdle_life <- brm(
  bf(gdpPercap ~ lifeExp,
    hu ~ lifeExp),
  data = gapminder,
  family = hurdle_lognormal(),
  chains = CHAINS, iter = ITER, warmup = WARMUP, seed = BAYES_SEED,
  silent = 2
)
tidy(model_gdp_hurdle_life)

hurdle_intercept <- tidy(model_gdp_hurdle_life) |> 
  filter(term == "hu_(Intercept)") |> 
  pull(estimate)

hurdle_lifeexp <- tidy(model_gdp_hurdle_life) |> 
  filter(term == "hu_lifeExp") |> 
  pull(estimate)

plogis(hurdle_intercept + hurdle_lifeexp) - plogis(hurdle_intercept)
## b_hu_Intercept 
##       -0.00408

conditional_effects(model_gdp_hurdle_life)
conditional_effects(model_gdp_hurdle_life, dpar = "hu")

# This will return the coefficient for lifeExp for the non-zero part. 
model_gdp_hurdle_life |> 
  emtrends(~ lifeExp, var = "lifeExp", dpar = "mu")

model_gdp_hurdle_life |> 
  emtrends(~ lifeExp, var = "lifeExp", dpar = "mu",
    at = list(lifeExp = seq(30, 80, 10)))
##  lifeExp lifeExp.trend lower.HPD upper.HPD
##       30        0.0784    0.0756    0.0815
##       40        0.0784    0.0756    0.0815
##       50        0.0784    0.0756    0.0815
##       60        0.0784    0.0756    0.0815
##       70        0.0784    0.0756    0.0815
##       80        0.0784    0.0756    0.0815
## 
## Point estimate displayed: median 
## HPD interval probability: 0.95

model_gdp_hurdle_life |> 
  emtrends(~ lifeExp, var = "lifeExp", dpar = "mu",
    at = list(lifeExp = seq(30, 80, 10)),
    epred = TRUE)
model_gdp_hurdle_life |> 
  emtrends(~ lifeExp, var = "lifeExp", dpar = "mu",
    at = list(lifeExp = seq(30, 80, 1)),
    epred = TRUE) |> 
  gather_emmeans_draws() |> 
  ggplot(aes(x = lifeExp, y = .value)) +
  stat_lineribbon(size = 1, color = clrs[1]) +
  scale_fill_manual(values = colorspace::lighten(clrs[1], c(0.95, 0.7, 0.4))) +
  scale_y_continuous(labels = label_dollar()) +
  labs(x = "Life expectancy", y = "Value of lifeExp coefficient\n(marginal effect)",
    fill = "Credible interval",
    title = "Marginal effect of life expectancy on GDP per capita") +
  theme_nice() +
  theme(legend.position = "bottom")
