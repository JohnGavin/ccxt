# https://github.com/Lisandro79/BeatTheBookie
# https://stackoverflow.com/questions/17666249/how-do-i-import-an-sql-file-using-the-command-line-in-mysql
# use db_name;
# mysql> SET autocommit=0 ; source the_sql_file.sql ; COMMIT ;
mysql –u root –p
mysql –u root –p root –e “show databases;”
SHOW DATABASES;
SHOW SCHEMAS;

SELECT TABLE_NAME, TABLE_ROWS 
FROM `information_schema`.`tables` 
WHERE `table_schema` = 'ccxt_series';
#   'ccxt_series_b';
# 'closing_ccxt';
# 'mysql';
# mysql> SELECT TABLE_NAME, TABLE_ROWS 
#  FROM `information_schema`.`tables` 
#  WHERE `table_schema` =  'ccxt_series';
# +---------------------+------------+
#   | TABLE_NAME          | TABLE_ROWS |
#   +---------------------+------------+
#   | matches             |     960056 |
#   | ccxt_history        |   28447894 |
#   | ccxt_history_series |   74337768 |
#   +---------------------+------------+
#   

if (!requireNamespace('RMySQL')) install.packages("RMySQL")
library(RMySQL)
library(tidyverse)
library(purrr)
library(glue)

## ccxt_series database
mydb = dbConnect(MySQL(), 
  user='root', password='root', 
  dbname= c('ccxt_series'), 
  host='localhost')
on.exit(dbDisconnect(mydb))
dbListTables(mydb)
dbListFields(mydb, 'matches')
dbListFields(mydb, 'ccxt_history')
dbListFields(mydb, 'ccxt_history_series')
# dbListFields(mydb, 'ccxt_stats_per_match_1x2_closing')

## mysql database
# mydb = dbConnect(MySQL(), 
#   user='root', password='root', 
#   dbname= c('mysql'), 
#   host='localhost')
# dbListTables(mydb)
# dbListFields(mydb, 'matches')
# dbListFields(mydb, 'ccxt_history')
# dbListFields(mydb, 'ccxt_history_series')
# # ccxt_stats_per_match_1x2_closing is not relevant.
# # dbListFields(mydb, 'ccxt_stats_per_match_1x2_closing')
# 
# ## closing_ccxt database
# mydb = dbConnect(MySQL(), 
#   user='root', password='root', 
#   dbname= c('closing_ccxt'), 
#   host='localhost')
# # on.exit(disconnect(mydb))
# dbListTables(mydb)
# dbListFields(mydb, 'matches')
# dbListFields(mydb, 'ccxt_history')
# dbListFields(mydb, 'ccxt_history_series')
# dbListFields(mydb, 'ccxt_stats_per_match_1x2_closing')

# dbListFields(mydb, 'user')

mm <- c('Pinnacle Sports', 'bet365')
matches <- dbGetQuery(mydb,
  glue::glue('SELECT  count(*) FROM ccxt_history 
  where bookmaker = "{mm[1]}" ;') ) 
matches
dbListFields(mydb, 'ccxt_history')
dbListFields(mydb, 'matches')
system.time(
  matches <- dbGetQuery(mydb,
  glue::glue('
  select * from matches 
  where ID in 
  ( SELECT ID FROM ccxt_history 
    where bookmaker = "{mm[1]}" )
    and (league like "%Germany%"
      or league like "%England%"
      or league like "%Spain%"
      or league like "%France%"
      or league like "%Italy%"
      )
  ORDER by date, league
  # limit 10
  ') ) %>% 
    tibble() %>% 
    arrange(desc(date)) ->
)
matches %>% nrow
matches %>% write_csv(
  file.path(here::here('data', 'pinnacle_ccxt_ts'), 
    'matches.csv.gz') )

dbListFields(mydb, 'ccxt_history')
dbListFields(mydb, 'ccxt_history_series')
system.time(
  dbGetQuery(mydb,
  glue::glue('
  select * from ccxt_history_series 
  where ccxt_history_id in 
  ( SELECT ID FROM ccxt_history 
    where bookmaker = "{mm[1]}" )
  ORDER by ccxt_datetime
  # limit 10
  ') ) %>% 
  tibble() %>% view
  mutate(ccxt_datetime = lubridate::(ccxt_datetime)) %>% 
  arrange(ccxt_datetime) ->
  ccxt_hist_ts 
)
ccxt_hist_ts %>% nrow
ccxt_hist_ts %>% write_csv(
  file.path(here::here('data', 'pinnacle_ccxt_ts'), 
    'ccxt_history_series.csv.gz') ) 
# and (league like "%Germany%"
#   or league like "%England%"
#   or league like "%Spain%"
#   or league like "%France%"
#   or league like "%Italy%" )

dbListFields(mydb, 'ccxt_stats_per_match_1x2_closing')

chk_ids_unique <- function(df, id)
  # ids in tables are unique
  df %>% 
  group_by({{ id }}) %>% 
  count() %>%
  ungroup() %>% 
  filter(n != 1) %>% 
  nrow() %>% `==`(0) %>% stopifnot
# ids in tables are unique
matches %>% chk_ids_unique(id = ID)
ccxt_hist_ts %>% chk_ids_unique(id = ccxt_history_series_id)

# most match ids in ccxt_hist_ts
matches$ID %>% 
  setdiff(ccxt_hist_ts$ccxt_history_id) %>% 
  length()
nrow(matches)
# but not conversely
ccxt_hist_ts$ccxt_history_id %>% 
  setdiff(matches$ID) %>% 
  length()
nrow(ccxt_hist_ts)

matches %>% 
  right_join(ccxt_hist_ts, by = c(ID = 'ccxt_history_id') ) %>% 
  arrange(desc(date), ccxt_datetime) %>% 
  mutate(date_diff = abs(date - ccxt_datetime) ,
    # mutate(date_diff = difftime(date, ccxt_datetime, 
    #   units = 'days'),
    .after = ccxt_datetime) %>% head()view
  filter(abs() < 1) ->
  ccxt_hist_ts_2

# only keep ccxt ts if we have corr match
matches %>% 
  left_join(ccxt_hist_ts, by = c(ID = 'ccxt_history_id') ) %>% 
  arrange(desc(date), ccxt_datetime) %>% 
  filter(!is.na(result)) ->
  matches_2
matches_2 %>% write_csv(
  file.path(here::here('data', 'pinnacle_ccxt_ts'), 
    'matches_n_ccxt_history.csv.gz') ) 

# dbExecute
# dbClearResult(matches)


(df <- fetch(matches, n= c(5, all = -1)[1]) )

fetch(dbGetQuery(mydb,
  'select count(*) as row_count from ccxt_history' ),
  n= c(100, all = -1)[1])

# 38 mm
system.time(fetch(dbGetQuery(mydb,
  'SELECT count( DISTINCT(bookmaker) ) FROM ccxt_history ;' 
  ), n= c(100, all = -1)[1]))

system.time(fetch(dbGetQuery(mydb,
  'SELECT  DISTINCT(bookmaker) as mm FROM ccxt_history ;' ),
  n= c(100, all = -1)[1]))

fetch(dbGetQuery(mydb,
  'SELECT * FROM ccxt_history' ),
  n= c(100, all = -1)[1]) 


fetch(dbGetQuery(mydb,
  'select * from ccxt_history ;' ),
  n= c(100, all = -1)[1])
'show databases; use closing_ccxt ; show full tables ; USE ccxt_series ; show full tables ; use ccxt_series_b ; show full tables ; ' ),


fetch(dbGetQuery(mydb,
  'show databases; ' ),
  n= c(100, all = -1)[1])
dbListFields(mydb, 'mysql')
dbListFields(mydb, 'ccxt_series')

fetch(dbGetQuery(mydb,
  'use closing_ccxt ; show full tables ' ),
  n= c(100, all = -1)[1])
'show databases; use closing_ccxt ; show full tables ; USE ccxt_series ; show full tables ; use ccxt_series_b ; show full tables ; ' ),

databases <- c('matches', 'ccxt_history', 'ccxt_history_series')
system.time(
  map_dfr(databases,
  ~ fetch(dbGetQuery(mydb, 
    glue::glue("select count(*) as row_count from {.x}") ), 
    n= c(100, all = -1)[1]) ) %>% 
  mutate(databases = databases, .before = 'row_count') ->
  db_count
)
db_count
databases <- c('matches', 'ccxt_history', 'ccxt_history_series')
system.time(
  map_dfr(databases,
    ~ fetch(dbGetQuery(mydb, 
      glue::glue("select count(*) as row_count from {.x}") ), 
      n= c(100, all = -1)[1]) ) %>% 
    mutate(databases = databases, .before = 'row_count') ->
    db_count
)



dbGetQuery(mydb, 'drop table if exists some_table, some_other_table')


select * top from ccxt_history


mydb = dbConnect(MySQL(), 
  user='root', password='root', 
  dbname= c('ccxt_series_b'), 
  host='localhost')

dbListTables(mydb)



