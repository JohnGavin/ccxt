



# https://orchid00.github.io/actions_sandbox/index.html#what-are-github-actions
# usethis::use_github_action_check_release()
# usethis::use_github_action_check_full()
# https://ryo-n7.github.io/2021-09-23-CanPL-GoogleDrive-GithubActions-Tutorial/

# https://github.com/ThinkR-open/attachment/blob/master/dev/dev_history.R

# TODO:
# https://github.com/wlandau/targets-minimal/blob/targets-runs/.github/workflows/targets.yaml

# https://docs.ropensci.org/targets/reference/tar_github_actions.html
# tar_github_actions() Write the .github/workflows/targets.yaml workflow file and commit this file to Git.
#   upload the results to the targets-runs branch of your repository. 
#   Subsequent runs should add new commits but not necessarily rerun targets.

# renv::init(bare = TRUE) to avoid copying unneeded dependencies from the main R lib
# remotes::dev_package_deps(dependencies = TRUE) %>% renv::install() # scrape deps from DESCRIPTION file

# https://wlandau.github.io/targets/reference/index.html  ----
# targets::tar_renv(extras = character(0)) # write _packages.R file to expose hidden dependencies.
# tar_edit() - edit _this_ (_targets.R) file in proj folder
# tar_knit()	Run a dependency-aware knitr report.
# tar_change()	Always run a target when a custom object changes.
# tar_force()	Always run a target when a custom condition is true.
# tar_suppress()	Never run a target when a custom condition is true.
#
# Write a _targets.R script to the current working directory.
#   tar_script({ tar_pipeline(...) )
# _targets.R - must always be named _targets.R, in the project root ----



# # 1. Load packages ----
# # options(tidyverse.quiet = TRUE) # not needed cos suppressPackageStartupMessages
options(tidyverse.quiet = TRUE)
options(warnPartialMatchArgs = FALSE)

# WARNING:
# Error : `fn` must be an R function, not a primitive function
# Error : callr subprocess failed: `fn` must be an R function, not a primitive function
# Visit https://books.ropensci.org/targets/debugging.html for debugging advice.
# load_library_description_deps <-
#   'https://raw.githubusercontent.com/JohnGavin/jg_utils/main/R/load_library_description_deps.R'
# source(load_library_description_deps)
# pkgs <- load_library_description_deps()

# get package names from DESCRIPTION file in current working directory. 
`%>%` <- magrittr::`%>%`
remotes::dev_package_deps(dependencies = TRUE) %>% 
  dplyr::pull(package) %>% 
  stringr::str_replace_all("'", '') %>% 
  stringr::str_replace_all("\\\"", '') %>% 
  unique() ->
  pkgs
# WARNING: purrr::walk/base::lapply(pkgs, library ... FAILS targets
# https://github.com/rstudio/renv/issues/143
# pkgs %>% stringr::str_subset('plyr')
suppressMessages(suppressPackageStartupMessages({
  # WARNING: tidymodels import plyr so it MUST be after dplyr
  base::sapply( 
    c('plyr', pkgs) %>% 
    setdiff('dplyr') %>% 
    c(., 'dplyr')
    , 
  library, 
  character.only = TRUE, quiet = TRUE,
  logical.return = TRUE, warn.conflicts = FALSE) #  %>% print()
  # purrr::walk(pkgs, library, character.only = TRUE, warn.conflicts = TRUE, quietly = TRUE)
  # renv::install('pacman') ;library(pacman) ; p_load(pkgs)
}))
rm(list = c("%>%"))

# WARNING: tidymodels import plyr so plyr MUST be after dplyr
# # # Error : `fn` must be an R function, not a primitive function
# It is caused by the search order of pacakges
#   e.g. tidymodels uses lots of packages that eventually use plyr
#   so ensure plyr is behind dplyr on the search list.
# Error : `fn` must be an R function, not a primitive function
# Error : callr subprocess failed: `fn` must be an R function, not a primitive function
# Visit https://books.ropensci.org/targets/debugging.html for debugging advice.
srch <- search()
srch[srch %>% str_detect('plyr') %>% which()]
(
  srch %>% str_detect('package:dplyr') %>% which() < 
  srch %>% str_detect('package:plyr') %>% which()
) %>% stopifnot('plan_preamble.R: dplyr must be before plyr' = .)

# srch %>% str_detect('package:targets') %>% which()


# https://stackoverflow.com/questions/43829125/r-portfolioanalytics-error-on-create-efficientfrontier
# library(renv) ; # ----
# renv::install(pkgs) ; .libPaths()
# renv::use_python() # https://blog.rstudio.com/2019/11/06/renv-project-environments-for-r/#Integration_with_Python
# py_install(py_pkgs)
# renv::snapshot(packages = c(pkgs, py_pkgs), prompt = TRUE) # WARNING: 'packages' is critical
# renv::history()
# renv::revert() to pull out an old version of renv.lock based on the previously-discovered commit, and then use renv::restore() to restore your library from that state.



# 2. Options: tar_option_set() defaults for targets-specific settings ----
#     such as the names of required packages.
# To deploy targets to PARALLEL jobs when running tar_make_clustermq().
# #   Even if you have no specific options to set,
# #   call tar_option_set() to register the proper environment.
# # ending with a call to tar_pipeline().

# # tar_option_set() # set packages globally for all subsequent targets you define.
targets::tar_option_set(
  tidy_eval = TRUE,
  # on err, find workspace image file in `_targets/workspaces/`.
  workspace_on_error = TRUE # error="workspace" 
)
# renv::status() not working with pkgs?!
targets::tar_option_set(
  # https://books.ropensci.org/targets/practices.html#loading-and-configuring-r-packages
  # # tar_option_set() # set packages globally for all subsequent targets you define.
  # straightforward to load the R packages that your targets need in order to run.
  # Name the required packages using the packages argument 
  # before running each target. 
  packages = pkgs # base::setdiff(pkgs, y = c("")), # exclude some packages?
  # https://books.ropensci.org/targets/practices.html#packages-based-invalidation
  # imports = c("package1", "package2") tells targets to 
  # dive into the environments of package1 and package2 and 
  # reproducibly track all the objects it finds. 
  # For example, if you define a function f() in package1, 
  # then you should see a function node for f() in the graph 
  # produced by tar_visnetwork(targets_only = FALSE), 
  # and targets downstream of f() will invalidate if you install 
  # an update to package1 with a new version of f().
  # ?tar_option_set
  # tar_option_set(imports = c("p1", "p2")), then the 
  # objects in p1 override the objects in p2 
  # if there are name conflicts. Similarly, objects in 
  # tar_option_get("envir") override everything in 
  # tar_option_get("imports"
  , imports = c('ccxt') # , pkgs[!is.na(pkgs)])[2] # pkgs
) 
# # tar_option_reset() # Reset all target options you previously chose

# tar_option_set ----
# #   Even if you have no specific options to set,
# #   call tar_option_set() to register the proper environment.
#
# https://books.ropensci.org/targets/practices.html#dependencies
# You should only set envir if you write your own package to 
# contain your whole data analysis project
# (other Functions and objects from packages are ignored 
#  unless you supply a package environment to the envir argument of tar_option_set())
# WARNING: to make gg_lvls depend on changes in gg_bumps function
# 	via the top level lst_gg_bumps_lvls function
targets::tar_option_set(envir = getNamespace("ccxt"))
# # tar_option_set(envir = environment())


# 3. Globals: load custom functions and global objects into memory. ----
# #   calls to source() defining user-defined functions
# fs::dir_ls('R', regexp = "\\.R$") %>%
#   # exclude plans_*.R and zzz*.R
#   str_subset("[.]*zzz|plan[.]*", negate = TRUE) %>%
#   walk(source) -> tmp

# https://github.com/r-lib/testthat/issues/1144
# switch import::from -> import::here
# 	no item called "imports" on the search list
# import::here(here, here)
# WARNING: import::from(dplyr) does NOT put dplyr ahead of plyr
# import::here(dplyr, summarize, count, rename, mutate)
# 
# '::' or ':::' import not declared from: ‘ellipsis’
#import::here(ellipsis)
#import::here(ellipsis, `::`, `:::`)


# https://books.ropensci.org/targets/practices.html#packages-based-invalidation
# devtools::install() # Fully install with install.packages() or equivalent. 
# devtools::load_all() # is NOT sufficient 
# because it does not make the packages available to _parallel_ workers.
devtools::load_all() # Shift-Command-0 load functions in 📂 R/ into memory
devtools::document() # Shift-Command-9  build and add documentation
# devtools::check() # SLOOOW build package locally and check


# # use local multicore computing when running tar_make_clustermq().
# options(clustermq.scheduler = c("multisession", 'multicore')[1] )
# parallelly::supportsMulticore() # not inside Rstudio
# future::plan(future::multisession) # or multisession / multicore
# vignette("DEoptimPortfolioOptimization", package= 'DEoptim') 
# require(doParallel) ; registerDoParallel()


# local functions ----
# print_and_return <- function(x) print(x)
# iters = c("vector", "list", "group")

# board ----
# create a new local board - tar_url() ----
# create_board = create_board_fun() 

