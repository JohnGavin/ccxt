#!/usr/bin/env Rscript

# https://github.com/MilesMcBain/capsule
# A capsule is an renv. 
# pkgs_R <- "./_targets_packages.R"
# tar_renv(path = pkgs_R) # extras = pkgs,
# capsule::create(pkgs_R) # not needed?
# capsule::run(targets::tar_make()) 
# The full power of renv can always be used to manipulate 
# the lockfile and library if you wish.


# https://ulhpc-tutorials.readthedocs.io/en/latest/maths/R/
# slide 13
# chmod +x run.R
# ./run.R


# # get pkgs from DESCRIPTION
# `%>%` <- magrittr::`%>%` # get( "%>%" )
# remotes::dev_package_deps(dependencies = NA) %>%
# 	dplyr::pull(package) %>% sort() ->
# 	pkgs
# # put pkgs into _targets_packages.R - the defaults
# pkgs_R <- "./packages.R"
# targets::tar_renv(extras = pkgs, path = pkgs_R) #  extras = pkgs,
# # https://github.com/MilesMcBain/capsule  # A capsule is an renv. 
# # devtools::install_github('MilesMcBain/capsule')
# library(capsule) ; capsule::create() # pkgs_R
# Run your targets plan in the capsule:
capsule::run(targets::tar_make()) 
# Source and run a file in the capsule:
#	capsule::run_callr(function() source("./main.R"))
# Render a document in the capsule:
# capsule::run_callr(function() rmarkdown::render("doc/analysis.Rmd"))


# library(devtools) ; devtools::install_github('JaseZiv/worldfootballR') 
# # disable automatic snapshots
# auto.snapshot <- getOption("renv.config.auto.snapshot")
# options(renv.config.auto.snapshot = FALSE)
# initialize a new project (with an empty R library)
# library(renv) ; renv::init(bare = TRUE)



