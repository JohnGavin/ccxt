pacman::p_load(shiny, pins, arrow, ggplot2, nycflights13, tictoc)
library("dplyr", warn.conflicts = FALSE)

# https://jthomasmock.github.io/bigger-data/#26
con <- DBI::dbConnect(duckdb::duckdb()) # create a temp database in memory
duckdb::duckdb_register(con, "flights", nycflights13::flights)
(flight_tbl <- tbl(con, "flights"))

flight_tbl %>% 
  group_by(dest) %>%
  summarise(delay = mean(dep_time, na.rm = TRUE))

flight_tbl %>% 
  group_by(month, origin) %>% 
  summarise(avg_delay = mean(dep_delay, na.rm = TRUE), .groups = "drop") %>% 
  arrange(desc(avg_delay)) # all on disk still

flight_tbl %>% 
  group_by(origin, month, day) %>% 
  summarise(
    avg_delay = mean(dep_delay, na.rm = T), 
    .groups = "drop"
  ) %>% 
  arrange(desc(avg_delay)) %>% 
  # collect() to bring into R
  collect() %>% 
  # and then it's like any other dataframe!
  ggplot(aes(x = month, y = avg_delay)) +
  geom_boxplot(aes(group = month)) +
  geom_jitter(
    aes(color = origin), 
    alpha = 0.2, width = 0.4) +
  facet_wrap(~origin, ncol = 1)

arrow::InMemoryDataset$create(mtcars) %>%
  filter(mpg < 30) %>%
  arrow::to_duckdb() %>% # oneliner to move into duckdb
  group_by(cyl) %>%
  summarize(mean_mpg = mean(mpg, na.rm = TRUE))

nyc_fares <- fs::dir_info("nyc-taxi", recurse = TRUE) %>%
  filter(type == "file") %>% 
  summarise(n = n(), size = sum(size)) 
glue::glue("There are {nyc_fares$n} files, totaling {nyc_fares$size}!")

# write to disk as "flightDisk", other defaults to in memory
con <- DBI::dbConnect(duckdb::duckdb(), "flightDisk")
duckdb::duckdb_read_csv(conn = con, name = "flightsCSV",  
  files = "flights.csv",
  header = TRUE, delim = ",", na.strings = "NA")


nyc_taxi <- S3FileSystem$create(
  anonymous = TRUE,
  scheme = "https",
  endpoint_override = "sfo3.digitaloceanspaces.com"
)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("NYC Taxi Data"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      sliderInput("year", "Year:",
        min = 2019, max = 2019, value = 2019),
      sliderInput("month", "Month:",
        min = 1, max = 6, value = 1),
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  output$distPlot <- renderPlot({
    y <- input$year
    m <- stringr::str_pad(input$month, 2, "left", "0")
    finp <- glue::glue("nyc-taxi/{y}/{m}/data.parquet")
    # read and count travels per day
    df <- read_parquet(nyc_taxi$path(finp))
    df <- df %>% 
      as_tibble() %>% 
      mutate(date = as.Date(pickup_at)) %>% 
      group_by(date) %>% 
      count()
    
    # draw the histogram
    ggplot(df) +
      geom_col(aes(x = date, y = n)) +
      labs(title = glue::glue("Travels per day {y}-{m}"))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
