# https://shiny.rstudio.com/articles/overview.html

# # get shiny, DBI, dplyr and dbplyr from CRAN
# install.packages("shiny")
# install.packages("DBI")
# install.packages("dplyr")
# install.packages("dbplyr")
# # get pool from GitHub, since it's not yet on CRAN
# devtools::install_github("rstudio/pool")

library(pool)
library(dplyr)

my_db <- dbPool(
  RMySQL::MySQL(), 
  dbname = "shinydemo",
  host = "shiny-demo.csa7qlmguqrf.us-east-1.rds.amazonaws.com",
  username = "guest",
  password = "guest"
)

my_db %>% 
  tbl("City") %>% 
  # first 5 rows
  head(5)

# non-shiny non-pool connection
conn <- dbConnect(
  drv = RMySQL::MySQL(),
  dbname = "shinydemo",
  host = "shiny-demo.csa7qlmguqrf.us-east-1.rds.amazonaws.com",
  username = "guest",
  password = "guest")
rs <- dbSendQuery(conn, "SELECT * FROM City LIMIT 5;")
dbFetch(rs)
dbClearResult(rs)
dbDisconnect(conn)

# OR
conn <- dbConnect(
  drv = RMySQL::MySQL(),
  dbname = "shinydemo",
  host = "shiny-demo.csa7qlmguqrf.us-east-1.rds.amazonaws.com",
  username = "guest",
  password = "guest")
dbGetQuery(conn, "SELECT * FROM City LIMIT 5;")
dbDisconnect(conn)



# https://shiny.rstudio.com/articles/pool-basics.html
# give you an idle connection that it previously fetched from the database or, 
# if it has no free connections, fetch one
# never have to create or close connections directly: 
# the pool knows when it should grow, 
#   shrink or keep steady. 
# You only need to close the pool when you’re done
# you don’t leak connections if you use a pool, 
#   if you forget to close it, you leak the pool itself
library(shiny)
library(DBI)
library(pool)

pool <- dbPool(
  drv = RMySQL::MySQL(),
  dbname = "shinydemo",
  host = "shiny-demo.csa7qlmguqrf.us-east-1.rds.amazonaws.com",
  username = "guest",
  password = "guest"
)

ui <- fluidPage(
  textInput("ID", "Enter your ID:", "5"),
  tableOutput("tbl"),
  numericInput("nrows", "How many cities to show?", 10),
  plotOutput("popPlot")
)

server <- function(input, output, session) {
  output$tbl <- renderTable({
    sql <- "SELECT * FROM City WHERE ID = ?id;"
    query <- sqlInterpolate(pool, sql, id = input$ID)
    dbGetQuery(pool, query)
  })
  output$popPlot <- renderPlot({
    query <- paste0("SELECT * FROM City LIMIT ",
      as.integer(input$nrows)[1], ";")
    df <- dbGetQuery(pool, query)
    pop <- df$Population
    names(pop) <- df$Name
    barplot(pop)
  })
}

shinyApp(ui, server)
