# https://github.com/johndharrison/seleniumPipes
# devtools::install_github("johndharrison/seleniumPipes")
library(seleniumPipes)
library(RSelenium) # start a server with utility function
selServ <- RSelenium::startServer()
remDr <- remoteDr()
remDr %>% go(url = "http://www.google.com")
remDr %>% go(url = "http://www.bbc.com")
remDr %>% back()
remDr %>% forward()
remDr %>% refresh()
remDr %>% go("https://cloud.r-project.org/") %>% getPageSource()
