

system.time(
  source(here::here('R', 'tar_plans', 'plan_preamble.R'),
    local = TRUE) )

source(here::here('R', 'tar_plans', 'tar_plan_ccxt.R'), local = TRUE)
# source(here::here('R', 'tar_plans', 'plan_calibrate_act_v_exp.R'), local = TRUE)
# source(here::here('R', 'tar_plans', 'plan_fbref_get_data.R'), local = TRUE)

# plans ----
list2(
  plan_ccxt
  # plan_random_forrest ,
	# , plan_fbref_get_data
)[[1]]

