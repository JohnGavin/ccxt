# targets in parallel
# RStudio forked processing ('multicore') not supported cos ##unstable##
# parallelly::supportsMulticore() # control forked processing,
# to silence this warning 
# targets::tar_make_clustermq(workers = 2L)


# single report - render it many times over multiple sets of RMarkdown parameters. 
# use tarchetypes::tar_render_rep() and write code to reference or 
# generate a grid of parameters with one row per rendered report 
# and one column per parameter
# remotes::install_github("milesmcbain/fnmate") ;  remotes::install_github("milesmcbain/tflow") ;
options(tidyverse.quiet = TRUE)
library(tidyverse, warn.conflicts = FALSE)
library(lubridate) # tflow/fnmate ####
library(tarchetypes) ;  library(tflow) ; library(fnmate) # tarchetypes does _not_ load targets!

library(targets) ; # tar_make() ----
(nw <- Sys.time()) ; targets::tar_make() ; Sys.time() ; Sys.time() - nw

# cd ~/Documents/GitHub/qc_chai/notebooks && tmux
# R --slave -e "(nw <- Sys.time()) ; targets::tar_make() ; Sys.time() ; Sys.time() - nw"

tar_validate()
(tar_man <- tar_manifest()) # check targets configuration: name command  pattern
cue_by_cue <- tar_sitrep() # Show the cue-by-cue status of each target.
# select cols 
# cue_by_cue %>% select(everything(), ~ any(.))
tar_glimpse() # alt cmd g how targets co-depend - relationships via static code analysis
# tar_manifest(fields = "name") %>% mutate(name %>% str_detect('report') )
tar_network() # vertices / edges of pipeline dependency graph.
tar_poll() # continuously refreshes a text summary of runtime progress in the R console. Run it in a new R session at the project root directory. (Only supported in targets version 0.3.1.9000 and higher.)
tar_visnetwork(targets_only=FALSE, label = c("time", "size", "branches") ) # visualises your pipeline as a graph network
tar_progress_summary()
tar_progress_branches()
tar_progress() # show runtime information at a single moment in time.
# launches an Shiny app that automatically refreshes the graph every few seconds. Try it out in the example below.
tar_watch(seconds = 10, outdated = FALSE, targets_only = TRUE)
tar_watch_ui() 
tar_watch_server() # make this functionality available to other apps through a Shiny module.

tar_workspaces() # List saved target workspaces in _targets/workspaces
tar_workspace(rw_pnl_pd_pm_ph) # environment of failed target command - reproduce error
tar_traceback(intro_rmd) # Get a target's traceback
tar_destroy(destroy = c("workspaces", 'objects')[1]) # remove workspace, When you are done debugging
# (Or, tar_option_set(workspace = c("target1", "target2")) - always save workspaces for specific targets.
# tar_meta(fields = error) %>% na.omit() ; list.files("_targets/workspaces")
# tar_workspace(<<failed target name>>) # environment of failed target command - reproduce error
# tar_undebug() # remove (large) workspace files
# debug() debugonce() undebug() browse() # debugging functions utilities
# https://rstats.wtf/debugging-r-code.html # interactive debugging
# debugonce(<<function>>) Shift+F9 set breakpt == browser(), 'where' stack trace, 's' step into `n` next line, `c` next breakpoint `Q` to exit
# Or debug interactively while `tar_make()`
# tar_option_set(debug = "<<function name>>", cue = tar_cue(mode = "never")) then tar_make(callr_function = NULL) in the pnl console

# tar_option_set(error="workspace") on err: workspace image file in `_targets/workspaces/`.
# (Or, tar_option_set(workspace = c("target1", "target2")) - always save workspaces for specific targets.
tar_meta(fields = c("error", "warnings")) %>% drop_na(warnings) %>% view
tar_meta(fields = c("error", "warnings")) %>% drop_na(error) %>% pull(error)
tar_meta(fields = c("error", "warnings")) %>% drop_na(!any_of(-c())) %>% pull(warnings)
tar_meta(fields = c('name', 'seconds', 'bytes', 'path')) %>% 
  arrange(desc(seconds)) %>% unnest(cols = c(path))
tar_meta(ends_with('fo_main'), fields = c('name', 'seconds', 'bytes', 'path')) %>% t
tar_meta(fields = 'error') %>% na.omit() ; list.files("_targets/workspaces")

tar_progress() # Read the target progress of the latest run of the pipeline.
tar_outdated() # targets to be updated - re-make it
tar_objects() # List saved targets
# tar_undebug() # remove (large) workspace files
tar_prune() # Remove targets that are no longer part of the pipeline.
tar_invalidate(c('epl_xfers_2020')) # Invalidate targets and global objects in the metadata.
tar_delete(c('gg_heatmap_country')) # Delete target return values.
tar_deps({ x <- function() 2-4 }) # detects commands dependencies / to run code analysis & see dependencies

tar_destroy(  destroy = 
		c("all", "meta", # meta invalidates all the targets but keeps the data
			"process", "progress", "objects", 
			"scratch", "workspaces")[1]
) # Start fresh. Destroy some/all of the _targets/ data store in getwd()

tar_deps({ x <- function() 2-4 }) # detects commands dependencies / to run code analysis & see dependencies
# https://books.ropensci.org/targets/practices.html#cleaning-up

# tar_undebug() # remove (large) workspace files
# debug() debugonce() undebug() browse() # debugging functions utilities
# https://rstats.wtf/debugging-r-code.html # interactive debugging
# debugonce(<<function>>) Shift+F9 set breakpt == browser(), 'where' stack trace, 's' step into `n` next line, `c` next breakpoint `Q` to exit
# Or debug interactively while `tar_make()`
# tar_option_set(debug = "<<function name>>", cue = tar_cue(mode = "never")) then tar_make(callr_function = NULL) in the R console

# rmarkdown::render("report.Rmd") ; browseURL("report.Rmd") ; unlink("report.html")



