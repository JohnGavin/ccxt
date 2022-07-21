
# TODO: orderbook snapshot history
# - Long worst performer / short best performer
#   - api to ETFs - tiingo? S&P sectors list
#   https://www.sectorspdr.com/sectorspdr/
#   https://www.ssga.com/us/en/institutional/etfs/funds/spdr-sp-500-etf-trust-spy
#   https://quantdare.com/the-risk-of-investing-an-exploration-on-spdr-sector-etfs/
#   

# See also coinmarketcapr package
# https://stackoverflow.com/questions/67343289/troubled-getting-cryptocurrency-data-api-in-r
 

# 
# https://business-science.github.io/riingo/reference/index.html


# https://github.com/business-science/riingo
# quantmod - One of the data sources quantmod can pull from is Tiingo.

pacman::p_load(riingo, tidyverse)
# riingo_set_token() 
riingo_get_token()
# Coerce UTC columns to local time.
# convert_to_local_time()

# A trick to return ALL crypto meta data
# For some reason Descriptions are not returned here
crypto <- riingo_crypto_meta("") %>% 
  janitor::clean_names() %>% 
  arrange(quote_currency)
# Getting foreign exchange rate data
# riingo_fx_prices()
# Forex - Prices
# riingo_fx_quote()
# Quote and Top of Book data for a given forex ticker


str_curr <- '^sol$|^SOL$'
crypto %>% 
  filter(
    quote_currency %>% str_detect(str_curr) |
    base_currency %>% str_detect(str_curr)
    ) ->
  sol
sol %>% 
  mutate(pair = paste0(base_currency, quote_currency)) %>% 
  # sample_n(5) %>% 
  pull(pair) ->
  pairs_sol
pairs_sol %>% 
  riingo_crypto_prices(
    resample_frequency = c("1min", "1hour", "1day")[2] ) %>% 
  arrange(date) ->
  sol_daily
sol_daily %>% glimpse()
sol_daily %>% pull(ticker) %>% table() %>% sort()
sol_daily %>% 
  mutate(day = as.Date(date)) %>% 
  group_by(ticker, day) %>% 
  summarize(
    volume = sum(volume), 
    # n_ = n(), 
    tradesDone_sum = sum(tradesDone),
    # date_min = min(date), 
    # date_max = max(date), 
    close = tail(close, 1), 
    .groups = 'drop'
  ) %>% 
  arrange(desc(
    # volume
    day
  )) %>% 
  view()

riingo_browse_usage()

# latest day's worth
riingo_crypto_latest(
  resample_frequency = "1min"
  # base_currency = NULL,
  # exchanges = NULL,
  # convert_currency = NULL,
  # raw = FALSE
) %>% arrange(desc(date)) %>% view()

# Only use the POLONIEX exchange
riingo_crypto_prices("btcusd", raw = TRUE, exchanges = "POLONIEX")

# All btc___ crypotcurrency pairs
riingo_crypto_prices(base_currency = "btc")


# riingo_crypto_*() functions. 
#  default, 1 year’s if available. 
riingo_crypto_prices( c("btcusd", "btceur") )
# latest day's worth
riingo_crypto_latest('btcusd',
  resample_frequency = "1min"
  # base_currency = NULL,
  # exchanges = NULL,
  # convert_currency = NULL,
  # raw = FALSE
) %>% arrange(desc(date)) %>% view()

riingo_crypto_meta('btcusd')

TOP (top of book) quote data 
riingo_crypto_quote('btcusd') %>% glimpse()



# pull a few days at a time, with the max date of intraday data being about ~4 months back (When the date was April 5, 2018, I could pull intraday data back to December 15, 2017, but only 5000 minutes at a time).
riingo_crypto_prices("btcusd", 
  start_date = Sys.Date() - 5, end_date = Sys.Date(), 
  resample_frequency = "1min")




is_supported_ticker("AAPL")
#> [1] TRUE



# https://api.tiingo.com/products/end-of-day-stock-price-data
tickers <- supported_tickers()
tickers$assetType %>% table()
etfs <- tickers %>% filter(assetType == 'ETF')
etfs$exchange %>% table()

# NO UK/Eur tickers!
etfs$priceCurrency %>% table()
tickers$priceCurrency %>% table()


# SHG/SHE => china
tickers %>% filter(exchange == 'SHG') %>% view()
tickers %>% filter(exchange == 'SHE') %>% view()

# default parameters attempt to get 1 year’s worth of data.
riingo_prices("AAPL")
riingo_prices(c("AAPL", "IBM"), 
  start_date = Sys.Date() - 10, 
  end_date =  Sys.Date(), resample_frequency = "monthly")

# direct feed to the IEX.
# most recent 2000 ticks
# subset the returned range with start_date and end_date, 
# but you cannot request data older than today's date minus 2000 data points.
# Only use start_date/end_date if you set the frequency to hourly.
riingo_iex_prices("AAPL", resample_frequency = "1min")

# IEX is real time quote data
# TOP (top of book) bid and ask prices, along with most recent sale prices.
riingo_iex_quote(c("AAPL", "QQQ"))




# must be signed into the site on the opened browser for most of these functions to work properly, otherwise you will redirected to the sign in page.
riingo_browse_signup()
riingo_browse_token() # This requires that you are signed in on the site once you sign up



# riingo_news(ticker = "AAPL")
# 
# # Filter by either source URL or tag
# riingo_news(ticker = "QQQ", source = "bloomberg.com")
# riingo_news(ticker = "QQQ", tags = "Earnings")
# 
# # A ticker is not required
# riingo_news(tags = "Earnings")
# 
