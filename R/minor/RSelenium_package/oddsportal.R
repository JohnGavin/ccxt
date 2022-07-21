
# https://stackoverflow.com/questions/55731769/undefined-error-in-httr-call-httr-output-recv-failure-connection-was-reset
library(wdman)
library(RSelenium)
library(rvest)
library(data.table)

# https://github.com/SeleniumHQ/docker-selenium
pjs <- wdman::phantomjs(port=8912L)

eCap <- list(phantomjs.page.settings.userAgent 
  = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:29.0) Gecko/20120101 Firefox/29.0", phantomjs.page.settings.loadImages = FALSE, phantomjs.phantom.cookiesEnabled = FALSE, phantomjs.phantom.javascriptEnabled = TRUE)


remDr<-remoteDriver(port=8912L, browser="phantomjs", extraCapabilities = eCap)

remDr$open()

#login form
remDr$navigate('https://apecoin.com/claim')
# remDr$navigate("https://www.oddsportal.com/login")
# 
# https://apecoin.com/claim
# //*[contains(concat( " ", @class, " " ), concat( " ", "text-warn", " " ))]
# 
# //*[contains(concat( " ", @class, " " ), concat( " ", "focus\:outline-none", " " ))]
# //*[contains(concat( " ", @class, " " ), concat( " ", "focus\:outline-none", " " ))]
# 
# //*[contains(concat( " ", @class, " " ), concat( " ", "focus\:outline-none", " " ))]
# //*[contains(concat( " ", @class, " " ), concat( " ", "btn-small", " " ))] | //*[contains(concat( " ", @class, " " ), concat( " ", "focus\:outline-none", " " ))]
# //*[contains(concat( " ", @class, " " ), concat( " ", "focus\:outline-none", " " ))]
remDr$findElement('name', 'btn-small')$clickElement()
remDr$findElement(using = 'css selector', "#")$sendKeysToElement(list("1"))
remDr$findElement(using = 'css selector', "#login-username1")$sendKeysToElement(list("*****"))
remDr$findElement(using = 'css selector', "#login-password1")$sendKeysToElement(list("*****"))
remDr$findElement(using = 'css selector', '#col-content > div:nth-child(3) > div > form > div:nth-child(3) > button')$clickElement()

# loop through 10 000 urls and save page source to file[i]
while(i<=10000){
  remDr$navigate(DT$links[i])
  file[i]<-remDr$getPageSource()[[1]]
  i<-i+1
}
