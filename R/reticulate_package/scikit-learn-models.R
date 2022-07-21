# https://www.johannesbgruber.eu/post/2022-03-29-scikit-learn-models-in-r-with-reticulate/
# install.packages('reticulate')

# CONDA environment inside the working directory ----
# once for a new project
# delete this folder manually later and start from scratch
pyth_str <- '/python-env-test/'
dot_pyth_str <- paste0(".", pyth_str)
if (!dir.exists( dot_pyth_str )) {
  reticulate::conda_create(dot_pyth_str)
}
# This creates a conda environment. 

# VIRTUAL environment ----
# also create a vanilla Python environment with 
# reticulate::virtualenv_create but they are harder to manage.

# RStudio PROJECT ----
# tell RStudio to use this installation of Python rather than a different one it might find somewhere on your computer
# search for a Python installation in your working directory
py_bin <- grep(getwd(), reticulate::conda_list()$python, value = TRUE)
Sys.setenv(RETICULATE_PYTHON = py_bin)
Sys.getenv('RETICULATE_PYTHON')
# make the configuration persistent using an .Rprofile file 
# (for example, with usethis::edit_r_environ()). 

# .Rprofile ----
# new project & .Rprofile
# writeLines(
#   paste0("RETICULATE_PYTHON = ", paste0(getwd(), 
#   paste0(dot_pyth_str, "bin/python") )), 
#   paste0(here::here(), ".Rprofile") )

# Python PACKAGES ----
# reticulate offers two functions: 
# one for packages from Anaconda, 
# one for packages from pip
# conda_install v py_install
# reticulate::conda_install also manages system dependencies
reticulate::conda_install(
  packages = c("scikit-learn", "pandas"),
  envname = dot_pyth_str
)
# Only if packages are not available on conda, I turn to reticulate::py_install
reticulate::py_install(
  packages = c("tmtoolkit", "gensim"),
  envname = dot_pyth_str,
  pip = TRUE
)

# test
library(reticulate)
pd <- import("pandas")
pd$DataFrame(1:5)
# help on a function
py_help(pd$DataFrame)


## Non-Negative Matrix Factorization (NMF) ----
# from scikit-learn for doing topic modelling. 

# preprocessing in Rs quanteda 
library(quanteda)
test_dfm <- c("A", "A", "A B", "B", "B", "C") %>% 
  tokens() %>% 
  dfm()
test_dfm

# scikit-learn to run the model
# dfm with scikit-learn and train a model with two topics:
sklearn <- import("sklearn") # NOT scikit-learn cos of '-'
model <- sklearn$decomposition$NMF(
  n_components = 2L,  # number of topics
  random_state  =  5L # equivalent of seed for reproducibility
)$fit(test_dfm)
# set the parameters inside NMF and then add the data in fit as


# evaluate this model in R ----
beta <- model$components_
colnames(beta) <- featnames(test_dfm)
rownames(beta) <- paste0("topic_", seq_len(nrow(beta)))
beta
gamma <- model$transform(test_dfm)
colnames(gamma) <- paste0("topic_", seq_len(ncol(gamma)))
rownames(gamma) <- paste0("text_", seq_len(nrow(gamma)))
gamma


library(tidyverse)
beta %>% 
  as_tibble(rownames = "topic") %>% 
  pivot_longer(cols = -topic) %>% 
  ggplot(aes(x = value, y = name)) +
  geom_col() +
  facet_wrap(~topic) +
  theme_minimal() +
  labs(x = NULL, y = NULL, title = "Top-features per topic")
