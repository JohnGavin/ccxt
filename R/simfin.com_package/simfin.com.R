
# https://lukas-r.blog/posts/2021-12-15-apis-and-parameterized-reports/
pacman::p_load(tidyverse, here, 
  simfinapi,  # install.packages("simfinapi")
  httr2,      # communicating with API's through R
  lubridate, gt,
  # if (!require(remotes)) install.packages("remotes")
  # remotes::install_github("jthomasmock/gtExtras")
  gtExtras
)

# NON standard sfa_set_api_key(env_var = 'SIMFIN_API_KEY')
sfa_set_api_key(api_key = Sys.getenv("SIMFIN_API_KEY"))

# Setting theme
# devtools::install_github("MiguelRodo/plotutils")
# plotutils:::set_custom_theme(base_size = 30)


my_apikey <- Sys.getenv("SIMFIN_API_KEY")
base_url <- "https://simfin.com/api/v2/"
endpoint <- "companies/list"
# Create url
url <- paste0(base_url, endpoint, "?api-key=", my_apikey)

# create the request
req <- request(url) |> 
  req_perform()
# Check if it worked
resp_status(req) %>% `==`(200) %>% stopifnot('request fail' = .)

content_json <- resp_body_json(req) 
content_df <- tibble(simfin_id = map_dbl(content_json$data, 1),
  ticker = map_chr(content_json$data, 2))
content_df
