# https://rstudio.github.io/vetiver-r/articles/vetiver.html

library(parsnip)
library(recipes)
library(workflows)
data(bivariate, package = "modeldata")
bivariate_train

bivariate_train %>% 
  recipe(Class ~ ., data = .) %>%
  step_BoxCox(all_predictors())%>%
  step_normalize(all_predictors()) ->
  biv_rec

svm_spec <-
  svm_linear(mode = "classification") %>%
  set_engine("LiblineaR")

svm_spec %>% 
  workflow(biv_rec, .) %>%
  fit(sample_frac(bivariate_train, 0.7)) ->
  svm_fit 
  
library(vetiver)
v <- vetiver_model(svm_fit, "biv_svm")
v

library(pins)
model_board <- board_temp(versioned = TRUE)
model_board %>% vetiver_pin_write(v)

svm_spec %>% 
  workflow(biv_rec, .) %>%
  fit(sample_frac(bivariate_train, 0.7)) -> 
  svm_fit
  
v <- vetiver_model(svm_fit, "biv_svm")
model_board %>% vetiver_pin_write(v)

model_board %>% pin_versions("biv_svm")

# create Plumber router, 
#  add a POST endpoint for making predictions.
library(plumber)
pr() %>%
  vetiver_api(v)
# start a server using this object, pipe (%>%) to pr_run(port = 8088) 

vetiver_write_plumber(model_board, "biv_svm")

library(vetiver)
endpoint <- vetiver_endpoint("http://127.0.0.1:8088/predict")
endpoint

data(bivariate, package = "modeldata")
predict(endpoint, bivariate_test)
