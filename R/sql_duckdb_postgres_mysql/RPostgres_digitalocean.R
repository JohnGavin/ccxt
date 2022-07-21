
pacman::p_load(DBI, RPostgres, golem)

con <- DBI::dbConnect(RPostgres::Postgres(),
  host   = "db-postgresql-lon1-28083-do-user-964184-0.b.db.ondigitalocean.com",
  dbname = "defaultdb",
  user      = "doadmin",
  password  = "mWK6DspvifrJ7d0X",
  # sslmode = require
  port     = 25060)
DBI::dbListTables(con)

df <- data.frame(x = 1, y = "a", z = as.Date("2022-01-01"))
DBI::dbCreateTable(con, name = "my_data", fields = head(df, 0))
DBI::dbListTables(con)
DBI::dbReadTable(con, "my_data")


con_lite <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
df <- data.frame(x = 1, y = "a", z = as.Date("2022-01-01"))
DBI::dbCreateTable(con_lite, name = "my_data", fields = head(df, 0))
DBI::dbListTables(con_lite)
DBI::dbReadTable(con_lite, "my_data")

db_con <- function(prod = golem::app_prod()) {
  
  if (prod) {
    
    con <- DBI::dbConnect(RPostgres::Postgres(),
      host   = "abc.b.db.ondigitalocean.com",
      dbname = "db",
      user      = "db",
      password  = Sys.getenv("DB_PASS"),
      port     = 25060)
    
  } else {
    
    stopifnot( require("RSQLite", quietly = TRUE) )
    con <- DBI::dbConnect(SQLite(), ":memory:")
    df <- data.frame(x = 1, y = "a", z = as.Date("2022-01-01"))
    DBI::dbWriteTable(con, "my_data", df)
    
  }
  
  return(con)
  
}
con <- db_con()
tbl_init <- DBI::dbReadTable(con, "my_data")
DBI::dbListTables(con)
DBI::dbReadTable(con, "my_data")
