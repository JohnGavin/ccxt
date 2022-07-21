# https://cran.r-project.org/web/packages/coinmarketcapr/readme/README.html

# - COMMON RISK FACTORS IN CRYPTOCURRENCY
# - long-short strategy based on the difference between the fifth and the first quintiles
# - 9/25 price & market information factors: market capitalization, price, and maximum price; one-, two-, three-, and four-week momentum; dollar volume; and standard deviation of dollar volume
# - == market, size & momentum factors
# - 4 groups: size, momentum, volume, and volatility
# - momentum significantly better among larger coins
# - opposite to equity market where momentum works better for smaller stocks
# - [Coinmarketcap.com](http://coinmarketcap.com/)
# - >$1m 109 coins in 2014 - 1,583 in 2018
# - 200 major exchanges, ohlcv + market cap
# - winsorize all non-return variables by the 1st and 99th percentiles each week.


library(coinmarketcapr)
#get the global market cap details and assign it to a dataframe
(latest_marketcap <- get_global_marketcap('EUR'))

#get the global market cap details and assign it to a dataframe
all_coins <- get_crypto_listings()

  
  
  