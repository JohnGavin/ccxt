# https://juliasilge.com/blog/giant-pumpkins/

options(tidyverse.quiet = TRUE)
library(tidyverse, warn.conflicts = FALSE)
library(tidymodels)

# pumpkins_raw <- 
#   readr::read_csv(
#     "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-10-19/pumpkins.csv",
#     show_col_types = FALSE)
# 
# pumpkins <-
#   pumpkins_raw %>%
#   separate(id, into = c("year", "type")) %>%
#   mutate(across(c(year, weight_lbs, ott, place), parse_number)) %>%
#   filter(type == "P") %>%
#   select(weight_lbs, year, place, ott, gpc_site, country)
# 
# pumpkins
# pumpkins %>%
#   filter(ott > 20, ott < 1e3) %>%
#   ggplot(aes(ott, weight_lbs, color = place)) +
#   geom_point(alpha = 0.2, size = 1.1) +
#   labs(x = "over-the-top inches", y = "weight (lbs)") +
#   scale_color_viridis_c()
# pumpkins %>%
#   filter(ott > 20, ott < 1e3) %>%
#   ggplot(aes(ott, weight_lbs)) +
#   geom_point(alpha = 0.2, size = 1.1, color = "gray60") +
#   geom_smooth(aes(color = factor(year)),
#     method = lm, formula = y ~ splines::bs(x, 3),
#     se = FALSE, size = 1.5, alpha = 0.6
#   ) +
#   labs(x = "over-the-top inches", y = "weight (lbs)", color = NULL) +
#   scale_color_viridis_d()
# 
# pumpkins %>%
#   mutate(country = 
#       country %>% 
#       fct_lump(n = 10) %>% 
#       fct_reorder(weight_lbs)
#   ) %>%
#   ggplot(aes(country, weight_lbs, color = country)) +
#   geom_boxplot(outlier.colour = NA) +
#   geom_jitter(alpha = 0.1, width = 0.15) +
#   labs(x = NULL, y = "weight (lbs)") +
#   theme(legend.position = "none")

targets::tar_load(ccxt_df)
# ccxt_df %>% glimpse


library(RColorBrewer)
cbf = brewer.pal(8, "RdBu")
ccxt_df %>%
  ggplot(aes(exp_pr, p_l_act_sqrt, 
    shape = p_l_exp_sum_, 
    color = skew_pr_grp,
    group = p_l_exp_sum_, size = p_l_exp_sum_ )) +
  geom_hline(yintercept = 0, alpha = 0.55, size = 0.5) +
  geom_jitter(alpha = 0.2) +
  facet_wrap( ~ hda_ou) +
  scale_colour_manual(values = cbf) + # for line and point colors
  theme(
    panel.background = element_rect(fill = 'grey85') # , colour = NA)
    # , legend.key.size = element_text(size = rel(1.5))
    # , legend.key = element_rect(fill = NULL, colour = cbf)
    , legend.position = c('top', "bottom")[1]
    , legend.title = element_text(face = "bold")
    #, legend.text = element_text(size=8)
    , legend.key.size = unit(3, "line")
    # , legend.key.size = element_text(size = 
    #     # rel(2) # unit(2, 'cm'))
    # , legend.key = element_rect(fill = NULL, colour = cbf)
  ) +
  guides(colour = guide_legend(override.aes = 
      list(size = 3, alpha = 1)),
    direction = "horizontal",
    keyheight = unit(0.03, units = "mm"),
    keywidth = unit(50, units = "mm"),
    title.position = 'top',
    label.position = "bottom")

# ccxt_df %>%
#   # filter(ott > 20, ott < 1e3) %>%
#   ggplot(aes(exp_pr, p_l_act_sqrt, 
#     group = skew_pr, color = skew_pr)) +
#   geom_point(alpha = 0.2, size = 1.1) +
#   facet_grid( ~ hda_ou)
# labs(x = "over-the-top inches", y = "weight (lbs)") +
# scale_color_viridis_c()
# ccxt_df %>% glimpse
ccxt_df %>%
  # filter(ott > 20, ott < 1e3) %>%
  ggplot(aes(exp_pr, p_l_act_sqrt)) +
  geom_point(alpha = 0.2, size = 1.1, color = "gray60") +
  geom_smooth(aes(color = factor(skew_pr_grp)),
    method = lm, formula = y ~ splines::bs(x, 3),
    se = FALSE, size = 1.5, alpha = 0.6
  ) +
  # labs(x = "over-the-top inches", y = "weight (lbs)", color = NULL) +
  scale_color_viridis_d()

ccxt_df %>%
  # TODO: reorder hda_ou by the exp_odd? to see most profitable bet type
  mutate(hda_ou = 
      hda_ou %>% 
      # top ? 3 bet types hda_ou by exp_odd then rest go into other?
      fct_lump(n = 3) %>% 
      fct_reorder(exp_odd),
  ) %>%
  ggplot(aes(hda_ou, exp_odd, color = hda_ou)) +
  geom_boxplot(outlier.colour = NA) +
  geom_jitter(alpha = 0.1, width = 0.15) +
  labs(x = NULL, y = "weight (lbs)") +
  theme(legend.position = "none")


set.seed(123)
pumpkin_split <- ccxt_df %>%
  # filter(ott > 20, ott < 1e3) %>%
  # stratify by our outcome p_l_exp_sum_
  initial_split(strata = p_l_exp_sum_)

pumpkin_train <- training(pumpkin_split)
pumpkin_test <- testing(pumpkin_split)

set.seed(234)
pumpkin_folds <- vfold_cv(pumpkin_train, strata = p_l_exp_sum_)
pumpkin_folds

# create three data preprocessing recipes: 

# WARNING: p_l_act_sqrt FAILS compared to p_l_act ?!
# my_form <- p_l_act_sqrt ~ hda_ou + skew_pr_grp + exp_pr
my_form <- p_l_exp_sum ~ hda_ou + skew_pr_grp + exp_odd

# pumpkin_train %>% glimpse
base_rec <-
  recipe(my_form,
    data = pumpkin_train
  ) #%>%
# 1) only - pools infrequently used factors levels, 
#step_other(country, gpc_site, threshold = 0.02)

ind_rec <-
  base_rec %>%
  # 2) also - creates indicator variables, 
  step_dummy(all_nominal_predictors())

spline_rec <-
  ind_rec %>%
  # 3) also - creates spline terms for over-the-top inches.
  step_bs(exp_odd)

# create three model specifications: 
# a random forest model, 
# a MARS model, and 
# a linear model

rf_spec <-
  rand_forest(trees = 1e3) %>%
  set_mode("regression") %>%
  # set_engine("ranger")
  set_engine("randomForest")
# rand_forest(mode = my_mode,
#   #  Since ranger won’t create indicator values,
#   #  .preds() would be appropriate for mtry for a bagging model
#   #  use an expression with the .preds() descriptor
#   #   to fit a bagging model:
#   mtry = .preds(), trees = num_trees) %>%
#   set_engine("ranger") %>%
#   fit(inpp_my_form, data = ccxt_train)

# randomForest - SLOWER 
#   NA/NaN/Inf in foreign function call (arg 1)
# rand_forest(mode = my_mode,
#   mtry = mtry, trees = num_trees) %>%
#   # argument name ntree
#   set_engine("randomForest") %>%
#   fit(inpp_my_form, data = ccxt_train)

mars_spec <-
  mars() %>%
  set_mode("regression") %>%
  set_engine("earth")

lm_spec <- linear_reg()
# glmn_mod <- 
#   linear_reg(penalty = tune(), mixture = tune()) %>%
#   set_engine("glmnet")
# # Save the assessment set predictions
# ctrl <- control_grid(save_pred = TRUE
#   , parallel_over = "everything",
#   save_workflow = TRUE
# )


# put the preprocessing and models together in a workflow_set().
pumpkin_set <-
  workflow_set(
    list(base_rec, ind_rec, spline_rec),
    list(rf_spec, mars_spec, lm_spec),
    # cross = FALSE - we don’t want every combination of components, 
    # cross = FALSE => only 3 options to try.
    # cross = TRUE  => all  9 options to try.
    cross = FALSE
  )
pumpkin_set


doParallel::registerDoParallel()
set.seed(2021)
system.time(
  workflow_map(
    # fit each model 10 times each
    pumpkin_set,
    # fit candidates to resamples - which performs best.
    "fit_resamples",
    resamples = pumpkin_folds
  ) ->
    pumpkin_wf
) 
# user  system elapsed 
#417.196  43.709 141.485 
pumpkin_wf
pumpkin_wf %>% str(max.level = 2, list.len = 4)

# Evaluate workflow set
# RMSE is in units of the dependent variable (p_l_act_sqrt)
#   lower is better, higher is worse
# rsq is (0,1) - higher is better, lower is worse
autoplot(pumpkin_wf)
# look at spread as well as median
# look at overlap
# 
# linear model with spline feature engineering is a simpler model!

collect_metrics(pumpkin_wf,
  # metrics be summarized over resamples (TRUE) or return the values for each individual resample. 
  summarize = T
)  %>% 
  arrange(.metric, mean) ->
  tmp
tmp %>% 
  view()
(rmse_min <- tmp$wflow_id %>% head(1))
# pumpkin_wf$wflow_id %>% unique
# extract from tune_grid() or tune_bayes()
# show_best(x = pumpkin_wf, metric = "rmse") # , maximize = FALSE
# select_best(pumpkin_wf, metric = "rmse") # , maximize = FALSE
collect_metrics(pumpkin_wf) %>%
  filter(.metric == "rmse") %>%
  mutate(wflow_id = 
    wflow_id %>% fct_reorder(std_err)) %>% # mean
  ggplot(aes(x = wflow_id, y = mean, group = model, col = model)) +
  geom_line() +
  geom_point() # + scale_x_log10()

# Per-resample values
# collect_metrics(pumpkin_wf, summarize = FALSE)
# collect_predictions(pumpkin_wf)

# extract the workflow we want to use and fit it to our training data.
# library(workflows) ; library(parsnip)
# class(pumpkin_wf)
# hardhat::extract_workflow
# extract_workflow .workflow_set
c("recipe_1_rand_forest", "recipe_2_rand_forest",
  "recipe_3_rand_forest",
  "recipe_2_mars", 
  "recipe_3_linear_reg")[1:3] %>% 
map( ~ extract_workflow( pumpkin_wf , .)  %>% fit(pumpkin_train))

final_fit <-
  extract_workflow( pumpkin_wf , 
    rmse_min
    # c("recipe_1_rand_forest", "recipe_2_rand_forest",
    #   "recipe_3_rand_forest",
    #   "recipe_2_mars", 
    #   "recipe_3_linear_reg")[3]
  )  %>%
  fit(pumpkin_train)
final_fit

# object to PREDICT,
#  on the TEST data  

pumpkin_test %>%
  # rename(`random forest` = .pred) %>%
  bind_cols(
    # predict(rf_xy_fit, new_data = ccxt_test[, preds])
    predict(final_fit, new_data = pumpkin_test) %>%
    rename(!! rmse_min := .pred) 
  ) %>% 
  relocate(p_l_act, !! rmse_min, .before = market) %>% 
  arrange(desc(abs(p_l_act))) ->
  tmp
# tmp %>% 
#   mutate(p_l_act_fct = 
#     p_l_act %>% 
#     fct_lump(n = 9) %>% 
#     fct_reorder(recipe_3_rand_forest))
tmp %>% 
  ggplot(aes(p_l_act, recipe_3_rand_forest)) +
  geom_jitter()

# glmn_rec_final <- prep(final_fit, fresh = T, retain = TRUE)
# final_fit %>% prep() %>% juice()
# don't use predict(object$fit) - Use predict() method on object produced by fit
# Get the set of coefficients across penalty values
# reglrzd_regr_tidy_coefs <-
#   broom::tidy(tmp) %>%
#   dplyr::filter(term != "(Intercept)") #
# vip - Variable importance scores - aggregate metrics
#   # caret and vip packages
#   # how much each predictor affected the model results
#   # specific to each model and not all models have ways to measure importance.
#   # look at the absolute value of the regression coefficients (recall that we normalized the predictors
library(vip)
  # vip(final_fit), num_features = 10L,
  #   # Needs to know which coefficients to use
  #   lambda = final_fit$penalty)


# no ranger method for tidy
vignette("available-methods")
# library(dplyr) ; library(tidypredict) ; library(ranger)
class(final_fit)
extract_mold(final_fit) 
final_fit %>% extract_fit_engine() ->
  abc
# tidy(abc)
abc %>% summary() 
# param_est <- coef(model_res)
# class(param_est)


workflows::extract_fit_parsnip(final_fit) %>% class
# workflows::extract_fit_parsnip(final_fit) %>% 
#   tidy()
#  ranger::treeInfo()	
extract_recipe(final_fit) %>% class

workflows::extract_spec_parsnip(final_fit) %>% 
  class()


workflows::extract_spec_parsnip(final_fit) # %>% 
  # ranger::tidypredict_fit()
  # ranger::tidypredict_sql()
  # ranger::parse_model()	
  # broom::tidy()
  # ranger::treeInfo() 

#  examine the model parameters.
tidypredict::tidy(final_fit) %>%
  arrange(-abs(estimate)) %>% 
  view()
