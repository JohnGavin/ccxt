
library(pins)
library(tidyverse)
library(vroom)

# Modern API
# create an explicit board object
board <- board_local()
board %>% 
  pin_write(head(mtcars), "mtcars")
# pin_write(board, head(mtcars), "mtcars")
pin_read(board, "mtcars")
pin_meta(board, "mtcars")
pin_search(board, "mtcars")
# pin_browse(board, "mtcars")
pin_delete(board, "mtcars")

# pin() a url to automatically re-download it when it changes:
# made explicit with the new board_url(), 
# since this returns a path, not a file, 
# you need to use pin_download():
# England Scotland Germany Italy Spain France Netherlands 
# Belgium Portugal Turkey Greece
# urll <- url('https://www.football-data.co.uk/data.php')
# https://www.football-data.co.uk/fixtures.csv
# https://www.football-data.co.uk/new/Latest_Results.csv
# https://www.football-data.co.uk/mmz4281/2122/Latest_Results.csv
# https://www.football-data.co.uk/mmz4281/2122/data.zip
# https://www.football-data.co.uk/mmz4281/2021/data.zip
# https://www.football-data.co.uk/mmz4281/1920/data.zip
# https://www.football-data.co.uk/mmz4281/1819/data.zip
base <- "https://www.football-data.co.uk/"
(fdata <- c(
  fixtures = paste0(base, "fixtures.csv"),
  europe = paste0(base, "mmz4281/2122/Latest_Results.csv"),
  eur_2122 = paste0(base, "mmz4281/2122/data.zip"),
  eur_2021 = paste0(base, "mmz4281/2021/data.zip"),
  eur_1920 = paste0(base, "mmz4281/1920/data.zip"),
  eur_1819 = paste0(base, "mmz4281/1819/data.zip"),
  latest_results = paste0(base, "new/Latest_Results.csv")
))
board_fdata <- board_url(fdata)
# pins 1.0.0 clearly separates the two cases of pin an object and pinning a file,
board_fdata %>% 
  pin_download("eur_2122") ->
  eur_2122_path
board_fdata %>% 
  pin_download("europe") ->
  europe_path
board_fdata %>% 
  pin_download("fixtures") ->
  fixtures_path
board_fdata %>% 
  pin_download("latest_results") ->
  non_europe
read_all_zip <- function(file, ...) {
  filenames <- unzip(file, list = TRUE)$Name
  # vroom(purrr::map(filenames, ~ unz(file, .x)), ...)
  filenames %>% 
    purrr::map(~ unz(file, .x) %>% 
      vroom(show_col_types = FALSE))
}
read_all_zip(eur_2122_path, show_col_types = FALSE) ->
  eur_2122
eur_2122 %>% str(max.level = 1)
eur_2122 %>% map_int(~ ncol(.))
eur_2122 %>% 
  bind_rows() ->
  eur_2122
eur_2122 %>% dim()
eur_2122 %>% sample_n(1e3) %>% view()
eur_2122 %>% names()
# https://rviews.rstudio.com/2019/06/19/a-gentle-intro-to-tidymodels/
# gradient boosted trees (GBT). GBTs work much like random forests, except that they use ‘boosting’ in place of bagging to sample data subsets. Whereas bagging always grants each data point an equal chance of being selected, boosting varies the odds of a data point being chosen depending on whether previous trees were able to handle them correctly. Data misfits are given heavier weights, forcing subsequent trees to give them greater focus. Grapefruit, for instance, would be misclassified as being sweet by a tree that splits on taxonomy, and be given greater weight in subsequent trees so as to rectify the misclassification.
# In comparison to bagging, boosting will produce models that fit more tightly to the shape of the data. We can be confident that Grapefruit will be classified correctly with boosting, but not necessarily with bagging. The closer fit comes at the cost of potential overfitting, however. A boosted tree may incorrectly infer that another fruit with a similar colour and size as grapefruit, such as a cantaloupe, will be bitter. It’s hard to know if the trade is worth making until we apply boosting to real data
# The second lesson is that boosting does more harm than good, at least in the context examined in the paper. Random forest, which uses bagging, outperformed gradient boosted trees. This finding agrees with Marcos de Prado, who argued that bagging generally outperforms boosting in financial contexts where data is very noisy.
# The ensemble model outperformed every base learner, even though by taking their simple average, we let the worst base learner and the best base learner have equal say in the final prediction. An ensemble model can only deliver such improved performance if its base learners contain diverse insights. 
# https://www.econstor.eu/bitstream/10419/130166/1/856307327.pdf
# https://www.enjine.com/blog/paper-review-deep-learning-long-short-term-memory-networks-financial-market-predictions/
# 
vroom(europe_path, show_col_types = FALSE) ->
  europe
vroom(fixtures_path, show_col_types = FALSE) ->
  fixtures
europe %>% 
  count(Date, Div) %>% 
  arrange(desc(Date))
fixtures %>% 
  count(Date, Div) %>% 
  arrange(desc(Date))
# europe %>% View
# fixtures %>% View



board_fdata %>% 
  pin_download("latest_results") %>% 
  pin_read(board_fdata, 'latest_results')
pin_read(board_fdata, "latest_results")

# board_fdata %>% pin_versions("fixtures")
# board_fdata %>% pin_versions("latest_results")
board_fdata %>% 
  pin_browse('fixtures')
board_fdata %>% 
  pin_browse('latest_results')
board_fdata %>% 
  pin_search('fixtures')
board_fdata %>% 
  pin_search('latest_results')
board_fdata %>% 
  pin_meta('fixtures')
board_fdata %>% 
  pin_meta('latest_results')
board_fdata %>% 
  pin_delete('fixtures')
board_fdata %>% 
  pin_delete('latest_results')


base <- "https://raw.githubusercontent.com/rstudio/pins/master/tests/testthat/"
tmp <- c(raw = paste0(base, "pin-files/first.txt") )
tmp
board_github <- board_url(tmp)
board_github %>% 
  pin_download("raw")
#> [1] "~/.cache/pins/url/87473d3442e598f929b65b6630da6fd8/first.txt"
pin_browse(board_github, 'raw')
pin_search(board_github)
pin_meta(board_github, 'raw')
pin_delete(board_github, 'raw')


# board_s3()

  
