
# https://github.com/SeleniumHQ/docker-selenium
docker run -d -p 4444:4444 --shm-size="2g" selenium/standalone-firefox:4.1.3-20220405
docker run -d -p 4444:4444 --shm-size="2g" selenium/standalone-chrome:4.1.3-20220405

docker network create grid
docker run -d -p 4442-4444:4442-4444 --net grid --name selenium-hub selenium/hub:4.1.3-20220405
docker run -d --net grid -e SE_EVENT_BUS_HOST=selenium-hub \
--shm-size="2g" \
-e SE_EVENT_BUS_PUBLISH_PORT=4442 \
-e SE_EVENT_BUS_SUBSCRIBE_PORT=4443 \
selenium/node-chrome:4.1.3-20220405
$ docker run -d --net grid -e SE_EVENT_BUS_HOST=selenium-hub \
--shm-size="2g" \
-e SE_EVENT_BUS_PUBLISH_PORT=4442 \
-e SE_EVENT_BUS_SUBSCRIBE_PORT=4443 \
selenium/node-firefox:4.1.3-20220405

# https://stackoverflow.com/questions/42468831/how-to-set-up-rselenium-for-r
# 
library(RSelenium)
# runs a chrome browser, wait for necessary files to download
rD <- rsDriver() 
# If you want a firefox browser use rsDriver(browser = "firefox")
remDr <- rD$client
# no need for remDr$open() browser should already be open
remDr$getStatus()

# recommended way to run RSelenium is via Docker containers however. 
# Instructions for use of Docker with RSelenium can be found at 
# http://rpubs.com/johndharrison/RSelenium-Docker

# run a Selenium server manually. 
# The easiest way to do this is via the wdman package:
# selCommand <- wdman::selenium(
#   jvmargs = c("-Dwebdriver.chrome.verboseLogging=true"), 
#   retcommand = TRUE)
# cat(selCommand)

remDr$navigate("http://www.google.com/ncr")

remDr$navigate(url = c("http://www.bbc.co.uk"))
remDr$getCurrentUrl()
remDr$goBack()
remDr$getCurrentUrl()
remDr$goForward()
remDr$getCurrentUrl()
remDr$refresh()

remDr$navigate("http://www.google.com/ncr")
webElem <- remDr$findElement(using = 'name', value = "q")

