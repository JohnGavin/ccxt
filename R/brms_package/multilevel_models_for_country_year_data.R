
# https://www.andrewheiss.com/blog/2021/12/01/multilevel-models-panel-data-guide/#other-ways-of-dealing-with-time
# 
# multilevel models for country-year data,
# multilevel models
# mixed effect models, 
# random effect models, 
# hierarchical models
# lme4 is what you use for frequentist, non-Bayesian multilevel models with R

# time-series cross-sectional (TSCS) data
# country-level panel data 
#   where each row is a country in a specific year
# Countries are repeated longitudinally over time, 
#   time itself influences changes in the outcome variable.
#   
# pp_check() check any of the Bayesian model diagnostics 
# 
# https://stats.stackexchange.com/questions/13166/rs-lmer-cheat-sheet

# install.packages(c("tidyverse", "gapminder", "brms", "tidybayes", "broom", "broom.mixed"))
# install.packages(c("emmeans", "ggh4x", "ggrepel", "ggdist", "scales", "patchwork", "ggokabeito"))
library(tidyverse)    # ggplot, dplyr, %>%, and friends
library(gapminder)    # Country-year panel data from the Gapminder Project
library(brms)         # Bayesian modeling through Stan
library(tidybayes)    # Manipulate Stan objects in a tidy way
library(broom)        # Convert model objects to data frames
library(broom.mixed)  # Convert brms model objects to data frames
library(emmeans)      # Calculate marginal effects in even fancier ways
library(ggh4x)        # For nested facets in ggplot
library(ggrepel)      # For nice non-overlapping labels in ggplot
library(ggdist)       # For distribution-related ggplot geoms
library(scales)       # For formatting numbers with comma(), dollar(), etc.
library(patchwork)    # For combining plots
library(ggokabeito)   # Colorblind-friendly color palette

bayes_seed <- 1234
set.seed(bayes_seed)
options(mc.cores = 4,  # Use 4 cores
  brms.backend = "cmdstanr")

# Custom ggplot theme to make pretty plots
# Get Barlow Semi Condensed at https://fonts.google.com/specimen/Barlow+Semi+Condensed
theme_clean <- function() {
  #  theme_minimal( # base_family = "Barlow Semi Condensed") +
    theme(panel.grid.minor = element_blank(),
      plot.background = element_rect(fill = "white", color = NA),
      plot.title = element_text(face = "bold"),
      axis.title = element_text(face = "bold"),
      strip.text = element_text(face = "bold", size = rel(0.8), hjust = 0),
      strip.background = element_rect(fill = "grey80", color = NA),
      legend.title = element_text(face = "bold"))
  
}
# Make labels use Barlow by default
family <- "Barlow Semi Condensed"
update_geom_defaults("label_repel", 
  list( # family = "Barlow Semi Condensed",
    fontface = "bold"))
update_geom_defaults("label", 
  list( # family = "Barlow Semi Condensed",
    fontface = "bold"))
nested_settings <- strip_nested(
  text_x = list(element_text( # family = "Barlow Semi Condensed Black", 
    face = "plain"), NULL),
  background_x = list(element_rect(fill = "grey92"), NULL),
  by_layer_x = TRUE)





# Little dataset of 8 countries (2 for each of the 4 continents in the data)
# that are good examples of different trends and intercepts
countries <- tribble(
  ~country,       ~continent,
  "Egypt",        "Africa",
  "Sierra Leone", "Africa",
  "Pakistan",     "Asia",
  "Yemen, Rep.",  "Asia",
  "Bolivia",      "Americas",
  "Canada",       "Americas",
  "Italy",        "Europe",
  "Portugal",     "Europe"
)

# Clean up the gapminder data a little
gapminder <- gapminder::gapminder %>%
  # Remove Oceania since there are only two countries there and we want bigger
  # continent clusters
  filter(continent != "Oceania") %>%
  # Scale down GDP per capita so it's more interpretable ("a $1,000 increase in
  # GDP" vs. "a $1 increase in GDP")
  # Also log it
  mutate(gdpPercap_1000 = gdpPercap / 1000,
    gdpPercap_log = log(gdpPercap)) %>% 
  mutate(across(starts_with("gdp"), list("z" = ~scale(.)))) %>% 
  # Make year centered on 1952 (so we're counting the years since 1952). This
  # (1) helps with interpretability, since the intercept will show the average
  # at 1952 instead of the average at 0 CE, and (2) helps with estimation speed
  # since brms/Stan likes to work with small numbers
  mutate(year_orig = year,
    year = year - 1952) %>% 
  # Indicator for the 8 countries we're focusing on
  mutate(highlight = country %in% countries$country)

# Extract rows for the example countries
original_points <- gapminder %>% 
  filter(country %in% countries$country) %>% 
  # Use real years
  mutate(year = year_orig)


# life expectancy ~ continent + country + time 
ggplot(gapminder, aes(x = year_orig, y = lifeExp, 
  group = country, color = continent)) +
  geom_line(aes(size = highlight)) +
  geom_smooth(method = "lm", aes(color = NULL, group = NULL), 
    color = "grey60", size = 1, linetype = "21",
    se = FALSE, show.legend = FALSE) +
  geom_label_repel(data = filter(gapminder, year == 0, highlight == TRUE), 
    aes(label = country), direction = "y", size = 3, seed = 1234, 
    show.legend = FALSE) +
  annotate(geom = "label", label = "Global trend", x = 1952, y = 50,
    size = 3, color = "grey60") +
  scale_size_manual(values = c(0.075, 1), guide = "none") +
  scale_color_okabe_ito(order = c(2, 3, 6, 1)) +
  labs(x = NULL, y = "Life expectancy", color = "Continent") +
  theme_clean() +
  theme(legend.position = "bottom")




library(cmdstanr)
# full file path to the CmdStan installation
# tmp <- file.path(.libPaths(), 'cmdstanr')
# Sys.setenv('CMDSTAN' =  tmp)
# Sys.getenv('CMDSTAN')
# set_cmdstan_path(path = tmp)

## Regular regression ----
model_boring <- brm(
  bf(lifeExp ~ year),
  data = gapminder,
  chains = 4, seed = bayes_seed
)
## Start sampling
tidy(model_boring)
# When year is zero, or in 1952, the average life expectancy is 50.25 years, 
#  it increases by 0.33 years each year after that