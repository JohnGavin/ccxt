

# https://community.rstudio.com/t/targets-workflow-management-error-when-repeats-pulling-coefficients-of-tidyverse-framework/83485/4
# combining targets with tidymodels. 
# different ways of managing data and artifacts 
# (e.g. tidymodels workflows and recipes carry 
# the original data along for the ride) 
#  hard to follow the advice at 
#  https://wlandau.github.io/targets-manual/practice.html#targets 
#  The pattern in https://github.com/wlandau/targets-keras 
#  and https://github.com/wlandau/targets-tutorial 
#  is useful to start, but it does not use any cross validation.
# 
# ?workflows::pull_workflow_fit # Extract elements of a workflow
# ?glmnet:::coef.glmnet

library(targets)

tar_script({
  options(tidyverse.quiet = TRUE)
  targets::tar_option_set(packages = c("tidyverse", "tidymodels"),
    format = "qs")
  
  tar_pipeline(
    tar_target(
      glmn_rec,
      recipe(mpg ~ ., data = mtcars) %>%
        step_normalize(all_predictors())
    ),
    tar_target(
      mod,
      linear_reg(penalty = 0.1, mixture = 1) %>% 
        set_engine("glmnet")
    ),
    tar_target(
      glmn_wflow,
      workflow() %>% 
        add_model(mod) %>% 
        add_recipe(glmn_rec)
    ),
    tar_target(
      glmn_fit,
      glmn_wflow %>% 
        fit(data = mtcars)
    ),
    tar_target(
      coeff,
      glmn_fit %>%
        pull_workflow_fit() %>% 
        pluck("fit") %>% 
        glmnet:::coef.glmnet(s = 0.1)
    )
  )
})
tar_make()
