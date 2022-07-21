# https://oliviergimenez.github.io/tidyverse-tips/

pacman::p_load(tidyverse)

theme_set(theme_light())
data("starwars")
starwars_raw <- starwars

starwars <- starwars_raw %>%
  select(name, gender, species, mass, height)
starwars %>% 
  count(name, sort = TRUE) # does a character appear only once
starwars %>% 
  count(gender, sort = TRUE) # 
starwars %>% 
  filter(!is.na(gender)) %>% # filter out missing values
  count(gender, sort = TRUE)

# When wt = mass is used, we compute sum(mass) for each species, otherwise we compute the number of rows in each species:

starwars %>%
  count(species, wt = mass)
starwars %>%
  count(species)
# add the counts to your tibble by using add_count(). Check out the n column:
starwars %>%
  add_count(species, wt = mass)

starwars %>% 
  filter(species %in% c('Aleena','Droid')) %>%
  count(species, gender)

starwars %>% 
  filter(species %in% c('Aleena','Droid')) %>%
  count(species, gender) %>%
  complete(species, gender)
starwars %>% 
  filter(species %in% c('Aleena','Droid')) %>%
  count(species, gender) %>%
  complete(species, gender, fill = list(n = 0))


starwars %>%
  summarize(across(where(is.numeric), 
    list(mean = ~mean(.x, na.rm = TRUE), 
      sd = ~sd(.x, na.rm = TRUE))))


starwars %>%
  count(height_classes = 10 * (height %/% 10), 
    name = "class_size")

starwars %>%
  filter(!is.na(species)) %>%
  count(species = fct_lump(f = species, n = 3))


starwars %>%
  lm(mass ~ height, data = .) %>%
  anova()


starwars %>%
  lm(mass ~ height, data = .) %>%
  broom::tidy()

# summary statistics with function glance(), including the $R^2$ and the AIC:
starwars %>%
  lm(mass ~ height, data = .) %>%
  broom::glance()

starwars %>%
  mutate(human = if_else(species == 'Human', 1, 0)) %>%
  glm(human ~ height, data = ., family = "binomial") %>%
  summary()
# fitted values and residuals with the function augment():

starwars %>%
  mutate(human = if_else(species == 'Human', 1, 0)) %>%
  glm(human ~ height, data = ., family = "binomial") %>%
  broom::augment()

parse_number("1,234,567.78")
parse_number("$1000")
parse_number(c("1,234,567.78", "$1000"))

starwars %>%
  filter(!is.na(species)) %>%
  count(species = fct_lump(species, 3)) %>%
  ggplot(aes(x = n, y = species)) + 
  geom_col()
starwars %>%
  filter(!is.na(species)) %>%
  count(species = fct_lump(species, 3)) %>%
  mutate(species = fct_reorder(species, n)) %>%
  ggplot(aes(x = n, y = species)) + 
  geom_col()

starwars %>%
  filter(!is.na(species)) %>%
  count(species = fct_lump(species, 5),
    gender) %>%
  mutate(species = fct_reorder(species, n)) %>%
  ggplot(aes(x = n, y = species)) + 
  geom_col() +
  facet_wrap(vars(gender))
# tidytext package. This is the function reorder_within() which works with scale_y_reordered:
library(tidytext)
starwars %>%
  filter(!is.na(species)) %>%
  count(species = fct_lump(species, 5),
    gender) %>%
  mutate(species = reorder_within(species, n, gender)) %>%
  ggplot(aes(x = n, y = species)) + 
  geom_col() +
  scale_y_reordered() + 
  facet_wrap(vars(gender))
