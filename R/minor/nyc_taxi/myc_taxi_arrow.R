library(arrow, warn.conflicts = FALSE)
library(dplyr, warn.conflicts = FALSE)
pacman::p_load(tictoc)

arrow::InMemoryDataset$create(mtcars) %>%
  filter(mpg < 30) %>%
  arrow::to_duckdb() %>% # oneliner to move into duckdb
  group_by(cyl) %>%
  summarize(mean_mpg = mean(mpg, na.rm = TRUE))

# copy one year
# system.time( arrow::copy_files("s3://ursa-labs-taxi-data/2019/01", "nyc-taxi") )
tic()
ds <- open_dataset("nyc-taxi") # , partitioning = c("year", "month"))
toc() # just to show that this is a fast process

# # https://arrow.apache.org/docs/r/articles/dataset.html
# bucket <- "https://ursa-labs-taxi-data.s3.us-east-2.amazonaws.com"
# for (year in 2019:2019) {
#   months <- 
#     if (year == 2019)
#     # We only have through June 2019 there
#     5:6 else 1:12
#   for (month in sprintf("%02d", months)) {
#     dir.create(file.path("nyc-taxi", year, month), recursive = TRUE)
#     try(download.file(
#       paste(bucket, year, month, "data.parquet", sep = "/"),
#       file.path("nyc-taxi", year, month, "data.parquet"),
#       mode = "wb"
#     ), silent = FALSE)
#   }
# }
# copy _all_ of the data - slooow
# arrow::arrow_with_s3()
# setwd("/Volumes/mock-external/")
# system.time(arrow::copy_files("s3://ursa-labs-taxi-data", "nyc-taxi"))
# warning that downloads 37Gb of data!



# in addition to the columns present in every file, there are also columns year and month even though they are not present in the files themselves.
ds$files
ds$filesystem

tic()
full_collect <- summarise(ds, n = n()) %>% 
  collect() %>% 
  pull(n)
n_rows <- scales::unit_format(unit = "billion", scale = 1e-9, 
  accuracy = 0.01)(full_collect)
glue::glue("There are approximately {n_rows} rows!")
toc() # wow that's fast.


system.time(
  ds %>%
    filter(total_amount > 100) %>% # , year == 2019) %>%
    select(tip_amount, total_amount, passenger_count) %>%
    mutate(tip_pct = 100 * tip_amount / total_amount) %>%
    group_by(passenger_count) %>%
    collect() %>%
    summarise(
      median_tip_pct = median(tip_pct),
      n = n()
    ) %>%
    print())

fs::dir_ls("nyc-taxi/", recurse = TRUE) %>%  
  stringr::str_subset("parquet", negate = TRUE) %>% 
  stringr::str_subset("\\/20[0-9]+\\/") %T>% 
  {cat("There are", length(.), "files\n")} %>% return()

tic()
ds %>%
  filter(total_amount > 100) %>% # , year == 2015) %>%
  select(tip_amount, total_amount, passenger_count) %>%
  # calculate a new column, on disk!
  mutate(tip_pct = 100 * tip_amount / total_amount) %>%
  group_by(passenger_count) %>%
  summarise(
    mean_tip_pct = mean(tip_pct),
    n = n()
  ) %>%
  collect() %>%
  print()
toc()

tic()
ds %>% 
  select(passenger_count, total_amount) %>% 
  filter(between(passenger_count, 0, 6)) %>% 
  group_by(passenger_count) %>% 
  summarise(
    n = n(),
    mean_total = mean(total_amount, na.rm = TRUE)
  ) %>% 
  collect() %>% # pull into memory!
  arrange(desc(passenger_count))
toc()

tic()
ds %>%
  filter(total_amount > 100) %>% #, year == 2015) %>%
  select(tip_amount, total_amount, passenger_count) %>%
  # use arrow to populate directly into a duckdb
  arrow::to_duckdb() %>% 
  group_by(passenger_count) %>%  # group_by mutate!
  mutate(tip_pct = 100 * tip_amount / total_amount) %>%
  filter(tip_pct >= 25) %>% 
  summarise(n = n()) %>% collect()
toc()

# https://jthomasmock.github.io/bigger-data/#78
# PINS
# https://arrow.apache.org/docs/r/articles/fs.html
bucket <- s3_bucket("ursa-labs-taxi-data")
# df <- read_parquet(bucket$path("2019/06/data.parquet"))
june2019 <- bucket$cd("2009/01")
system.time(df <- read_parquet(june2019$path("data.parquet")))
bucket$ls()
# SubTreeFileSystem can also be made from a URI:
june2019_2 <- SubTreeFileSystem$create(
  "s3://ursa-labs-taxi-data/2009/01")
identical(june2019, june2019_2)

# https://duckdb.org/2021/12/03/duck-arrow.html
# Gets Database Connection
con <- dbConnect(duckdb::duckdb())
# We can use the same function as before to register our arrow dataset
duckdb::duckdb_register_arrow(con, "nyc", june2019)


# Processing data in batches
# dataset is much larger than memory. You can use map_batches on a dataset query to process it batch-by-batch.
sampled_data <- ds %>%
  # filter(year == 2019) %>%
  select(tip_amount, total_amount, passenger_count) %>%
  map_batches(~ sample_frac(as.data.frame(.), 1e-4)) %>%
  mutate(tip_pct = tip_amount / total_amount)
str(sampled_data)

# aggregate summary statistics over a dataset 
# by computing partial results for each batch and 
# then aggregating those partial results. 
# fit a model to the sample data and then use map_batches 
# to compute the MSE on the full dataset.
model <- lm(tip_pct ~ total_amount + passenger_count, data = sampled_data)

ds %>%
  filter(year == 2019) %>%
  select(tip_amount, total_amount, passenger_count) %>%
  mutate(tip_pct = tip_amount / total_amount) %>%
  map_batches(function(batch) {
    batch %>%
      as.data.frame() %>%
      mutate(pred_tip_pct = predict(model, newdata = .)) %>%
      filter(!is.nan(tip_pct)) %>%
      summarize(sse_partial = sum((pred_tip_pct - tip_pct)^2), n_partial = n())
  }) %>%
  summarize(mse = sum(sse_partial) / sum(n_partial)) %>%
  pull(mse)


pacman::p_load(aws.s3)
aws.s3::save_object(
  object='yellow_tripdata_2015-01.csv',
  bucket='nyc-tlc/trip+data',
  file='/Users/jbg/Downloads/yellow_tripdata_2015-01.csv'
)

