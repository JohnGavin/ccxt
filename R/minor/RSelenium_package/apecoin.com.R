library(httr)
library(rvest)
library(purrr)
library(dplyr)

apecoin.com <- 'https://apecoin.com/claim'

url_get <- GET(apecoin.com)

Eruptions <- url_get %>%
  read_html() %>%
  html_nodes(".td8") %>%
  html_text()
Eruptions

library(RSelenium)
library(rvest)

# https://cran.r-project.org/web/packages/RSelenium/readme/README.html
# 
## Terminal command to start selenium (on ubuntu)
## cd ~/selenium && java -jar selenium-server-standalone-2.48.2.jar
url <- apecoin.com # "http://olx.pl/oferta/pokoj-1-os-bielany-encyklopedyczna-CID3-IDdX6wf.html#c1c0e14c53"

vignette(package = "RSelenium")

# RSelenium::startServer()
# remDr <- remoteDriver() # browserName = "phantomjs")
# 
# https://cran.r-project.org/web/packages/RSelenium/vignettes/docker.html
# sudo docker run -d -p 4444:4444 selenium/standalone-edge
remDr <- remoteDriver(
  remoteServerAddr = "localhost", 
  # remoteServerAddr = "192.168.99.100",
  port = 4444L)
remDr$open()

remDr$navigate("http://www.google.com/ncr")
remDr$getTitle()

remDr$navigate(apecoin.com)
remDr$getTitle()

# css <- ".cpointer:nth-child(1)"  ## couldn't get this to work
xp <- "//div[@class='contactbox-indent rel brkword']"
webElem <- remDr$findElement(using = 'xpath', xp)

# webElem <- remDr$findElement(using = 'css selector', css)
webElem$clickElement()

## the page source now includes the clicked element
page_source <- remDr$getPageSource()[[1]]
pos <- regexpr('class=\\"xx-large', page_source)

## you could write a more intelligent regex, but this works for now
phone_number <- substr(page_source, pos + 11, pos + 21)
phone_number
# "503 155 744"


//*[contains(concat( " ", @class, " " ), concat( " ", "btn-small", " " ))] |
  //*+[contains(concat( " ", @class, " " ), concat( " ", "last\:border-b-0", " " ))]
//*[contains(concat( " ", @class, " " ), concat( " ", "last\:border-b-0", " " ))]
//*[contains(concat( " ", @class, " " ), concat( " ", "focus\:outline-none", " " ))]

//*+[contains(concat( " ", @class, " " ), concat( " ", "last\:border-b-0", " " ))]
//*[contains(concat( " ", @class, " " ), concat( " ", "last\:border-b-0", " " ))]
//*[contains(concat( " ", @class, " " ), concat( " ", "btn-small", " " ))] | 
  //*+[contains(concat( " ", @class, " " ), concat( " ", "last\:border-b-0", " " ))]
//*[contains(concat( " ", @class, " " ), concat( " ", "last\:border-b-0", " " ))]
//*[contains(concat( " ", @class, " " ), concat( " ", "focus\:outline-none", " " ))]

//*[contains(concat( " ", @class, " " ), concat( " ", "focus\:outline-none", " " ))]
//*[contains(concat( " ", @class, " " ), concat( " ", "btn-small", " " ))]

//*[contains(concat( " ", @class, " " ), concat( " ", "focus\:outline-none", " " ))]
//*[contains(concat( " ", @class, " " ), concat( " ", "btn-small", " " ))] | //*[contains(concat( " ", @class, " " ), concat( " ", "focus\:outline-none", " " ))]