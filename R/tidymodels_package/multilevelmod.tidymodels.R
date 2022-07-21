
# https://multilevelmod.tidymodels.org/articles/multilevelmod.html

library(tidymodels)
library(multilevelmod)

tidymodels_prefer()
theme_set(theme_bw())

data(sleepstudy, package = "lme4")

sleepstudy %>% 
  ggplot(aes(x = Days, y = Reaction)) + 
  geom_point() + 
  geom_line() +
  facet_wrap(~ Subject) 

new_subject <- tibble(
  Days = 0:9, 
  Subject = "one"
)

# install.packages("gee")
gee_spec <- 
  linear_reg() %>% 
  set_engine("gee", corstr = "exchangeable")

gee_fit <- 
  gee_spec %>% 
  fit(Reaction ~ Days + id_var(Subject), data = sleepstudy)
## Beginning Cgee S-function, @(#) geeformula.q 4.13 98/01/27
## running glm to get initial regression estimate
gee_fit

predict(gee_fit, new_subject %>% select(Days)) %>% 
  bind_cols(new_subject)



library(nlme) # <- Only need to load this to get cor*() functions

gls_spec <- 
  linear_reg() %>% 
  set_engine("gls", correlation = corCompSymm(form = ~ 1 | Subject))

gls_fit <- 
  gls_spec %>% 
  fit(Reaction ~ Days, data = sleepstudy)

gls_fit


predict(gls_fit, new_subject %>% select(Days)) %>% 
  bind_cols(new_subject)


# Linear mixed effects via lme
# https://multilevelmod.tidymodels.org/articles/multilevelmod.html#linear-mixed-effects-via-lme

lme_spec <- 
  linear_reg() %>% 
  # random effects are specified in an argument called random. 
  # This can be passed via set_engine().
  set_engine("lme", random = ~ 1 | Subject)

lme_fit <- 
  lme_spec %>% 
  # formula specified for fit() should only include the fixed effects for the model.
  fit(Reaction ~ Days, data = sleepstudy)
lme_fit
predict(lme_fit, new_subject) %>% 
  bind_cols(new_subject)

predict(lme_fit, sleepstudy %>% filter(Subject == "308"))

lmer_spec <- 
  linear_reg() %>% 
  set_engine("lmer")

lmer_fit <- 
  lmer_spec %>% 
  fit(Reaction ~ Days + (1|Subject), data = sleepstudy)

lmer_fit

# We predict in the same way.
predict(lmer_fit, new_subject) %>% 
  bind_cols(new_subject)

# determine what packages are required for a model, use this function:
required_pkgs(lmer_spec)


## workflow

lmer_wflow <- 
  workflow() %>% 
  # instead of using add_formula(), we suggest using 
  # add_variables(). This passes the columns as-is to the model fitting function.
  add_variables(outcomes = Reaction, predictors = c(Days, Subject)) %>% 
  # To add the random effects formula, use the formula argument of add_model().
  add_model(lmer_spec, formula = Reaction ~ Days + (1|Subject))

lmer_wflow %>% fit(data = sleepstudy)

## recipe
# If using a recipe, make sure that functions like step_dummy() 
# do not convert the column for the 
# independent experimental unit (i.e. subject) to dummy variables. The underlying model fit functions require a single column for these data.

# Using a recipe also offers the opportunity to set a 
# different role for the independent experiment unit, 
# which can come in handy when more complex preprocessing 
# is needed.

rec <- 
  recipe(Reaction ~ Days + Subject, data = sleepstudy) %>%
  add_role(Subject, new_role = "exp_unit") %>%
  step_zv(all_predictors(), -has_role("exp_unit"))

lmer_wflow %>%
  remove_variables() %>%
  add_recipe(rec) %>%
  fit(data = sleepstudy)

lmer_wflow %>% 
  fit(data = sleepstudy) %>% # <- returns a workflow
  extract_fit_engine()       # <- returns the lmer object
