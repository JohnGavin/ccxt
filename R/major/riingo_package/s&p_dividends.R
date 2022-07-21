# https://rviews.rstudio.com/2019/07/09/dividend-sleuthing-with-r/
#   S&P 500 constituents daily prices
#   
# http://www.reproduciblefinance.com/
# https://www.amazon.com/Reproducible-Finance-Portfolio-Analysis-Chapman/dp/1138484032

# install.packages(c('devtools', "pacman", "riingo", "tidyquant"))
# devtools::install_github("DavisVaughan/riingo")
pacman::p_load(tidyverse, tidyquant, riingo)

# alphavantage ----
av_api_key(Sys.getenv("alphavantage_key"))
tq_get_options()



# IB interactive brokers LSE SECTOR ETFs US (invesco/ishares) EU (ishares) ETF ----
# https://docs.google.com/spreadsheets/d/124ho0VDllwSafZuJtEWgUAKt2qQ8Ir-18EsliBHyHfA/edit#gid=0
source('./R/riingo_package/sectors_lse_etf_.R')
sectors_lse_etf_ %>% 
  rename_with(tolower) %>% 
  rename_with(~ 'fund', starts_with('fund')) %>% 
  mutate(provider = fund %>% str_extract('^\\w+')) %>% 
  mutate(fund = fund %>% str_replace('^\\w+', '')) %>% 
  mutate(index = case_when(
    fund %>% tolower() %>% str_detect('s&p') ~ 'S&P',
    fund %>% tolower() %>% str_detect('europe') ~ 'Europe',
    TRUE ~ NA_character_)) %>% 
  mutate(fund = fund %>% str_replace_all('S&P|500|Europe|Select|Sector', '')) %>% 
  mutate(fund = fund %>% str_replace('UCITS ETF$', '')) %>% 
  tibble() ->
  sectors_lse_etf_
(sectors_lse_etf_$symbol == sectors_lse_etf_$symbol_2) %>% all() %>% 
  stopifnot('two symbol columns are _not_ identical' = .)
sectors_lse_etf_ <- sectors_lse_etf_ %>% select(-symbol_2)
sectors_lse_etf_ %>% 
  filter(fund %>% tolower() %>% str_detect('material'))

ish_us_lse_etf = c('ICDU', 'ICSU', 'IESU', 'UIFS', 'IHCU', 'IISU', 'IITU', 'IMSU', 'IUSU')
inv_us_lse_etf = c('XLCP', 'XLYP', 'XLPP', 'XLEP', 'XLFQ', 'XLVP', 'XLIP', 'XLBP', 'XLKQ', 'XLUP')
# 'XREP', Invesco Utilities S&P US Select Sector UCITS ETF
eu_lse_etf = c('ESIS', 'ESIF', 'ESIH', 'ESIN', 'ESIT')
# exclude Europe cos not liquid
lse_etfs <- list(eu_lse_etf, ish_us_lse_etf, inv_us_lse_etf)[2:3]
all_etfs <- sectors_lse_etf_ %>% pull(symbol)
(lse_etfs %>% unlist()) %in% 
  all_etfs %>% all() %>%
  stopifnot('some lse_etf not in sectors_lse_etf_' = .)
# ESIC.LON iShares Msci Europe Consumer Discretionary Sector UCITS ETF
# ESIE.LON iShares MSCI Europe Energy Sector UCITS ETF
# possibly: cos fails if tq_get fails with error?
safely_tq_get <- possibly(tq_get, otherwise = NULL)
all_etfs %>% 
  # FIXME: call frequency is 5 calls per minute and 500 calls per day
  sample(5) %>% 
  paste0('.LON') %>% 
  # www.alphavantage.co standard API call frequency is 5 calls per minute and 500 calls per day.
  sort() %>% 
  # c("FB", "MSFT") %>%
  #   tq_get(get = "alphavantage", av_fun = "TIME_SERIES_INTRADAY", interval = "5min")
  # https://www.alphavantage.co/documentation/ TSCO.LON
  safely_tq_get(., get = "alphavantage", av_fun = 
      # https://www.alphavantage.co/documentation/#daily
      # https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=TSCO.LON&outputsize=full&apikey=demo
      # https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=TSCO.LON&outputsize=full&apikey=demo
      # https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=TSCO.LON&outputsize=full&apikey=demo
      c('TIME_SERIES_DAILY',
        # https://www.alphavantage.co/query?function=TIME_SERIES_WEEKLY&symbol=TSCO.LON&apikey=demo
        # https://www.alphavantage.co/query?function=TIME_SERIES_WEEKLY_ADJUSTED&symbol=TSCO.LON&apikey=demo
        'TIME_SERIES_WEEKLY_ADJUSTED', 'TIME_SERIES_WEEKLY',
        # https://www.alphavantage.co/documentation/#monthlyadj
        # https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY_ADJUSTED&symbol=TSCO.LON&apikey=demo
        # https://www.alphavantage.co/documentation/#intraday
        # function=TIME_SERIES_INTRADAY_EXTENDED 
        # 1min, 5min, 15min, 30min, 60min
        "TIME_SERIES_INTRADAY")[1], 
    # from = , to = 
    show_col_types = FALSE, 
    outputsize='full',
    interval = "5min" # only if TIME_SERIES_INTRADAY
  ) ->
  lse_etf_5_
lse_etf_5_ %>% 
  arrange(desc(timestamp), symbol) %>% 
  mutate(id = symbol %>% str_replace('\\.LON$', ''), .before = symbol) %>% 
  # merge fund name
  select(-symbol) %>% 
  rename(symbol = id) %>% 
  left_join(sectors_lse_etf_, by = 'symbol') %>% 
  relocate(fund, .after = symbol) ->
  lse_etf_5

lse_etf_5 %>%
  filter(timestamp > as_date('2022-01-01'),
    # open > 1e4
    ) %>% 
  arrange(symbol, timestamp) %>% 
  group_by(symbol) %>% 
  # normalise 
  mutate(across(where(is_double) & c(volume), ~ . / head(., 1))) %>% 
  ungroup() %>% 
  # select(volume)
  ggplot(aes(x = timestamp, y = close)) +
  geom_candlestick(
    show.legend = TRUE,
    aes(open = open, high = high, low = low, close = close,
      # alpha = 0.8, linetype = 1
      # group = symbol, 
      size = sqrt(volume)
  )) +
  facet_wrap( ~ fund, scales = "free_y")
  # geom_ma(color = "darkgreen") 
  # coord_x_date(xlim = c("2016-01-01", "2016-12-31"), ylim = c(75, 125)
  # geom_bbands() for adding Bollinger Bands to ggplots
  # coord_x_date() for zooming into specific regions of a plot
  # colour_up = "darkblue", colour_down = "red",
  # fill_up = "darkblue", fill_down = "red",



# ---- 3.0 TECHNICAL INDICATORS ----
# 3.1 SMA
# https://www.alphavantage.co/documentation/#technical-indicators
library(alphavantager)
av_get("MSFT", av_fun = "SMA", interval = "weekly", time_period = 10, series_type = "open")
# ---- 4.0 SECTOR PERFORMANCE ----
# 4.1 Sector Performance
av_get(av_fun = "SECTOR") %>% view()

# crypto_codes <- read_delim(clipboard(), delim = '\t', show_col_types = FALSE)
source('./R/riingo_package/crypto_codes.R')
source('./R/riingo_package/phy_curr_codes.R')
phy_curr_codes %>% filter(`currency code` %in% c('USD', 'GBP'))
crypto_codes %>% filter(`currency code` %in% c('SOL', 'LUNA'))
crypto_codes %>% 
  filter(`currency code` %in% c('SOL', 'LUNA')) %>% 
  pull(`currency code` ) ->
  coins
# https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=USD&to_currency=JPY&apikey=demo
  tq_get(x = "btc/usd", # symbol = coins, market = 'USD',
      get = "alphavantage", 
    av_fun = 'CURRENCY_EXCHANGE_RATE') %>% view

# "btc/usd" %>% 
#   tq_get(get = "alphavantage", # alphavantager
#     # https://www.alphavantage.co/documentation/#currency-daily
#   av_fun = 'CRYPTO_INTRADAY',
#   interval = c('1min', '5min', '15min', '30min', '60min')[2], 
#   outputsize=c('compact', 'full')[1],
#     show_col_types = FALSE) %>% 
#   view
# Tiingo Bitcoin Prices ----
# https://business-science.github.io/tidyquant/reference/tq_get.html
tq_get(c("btcusd", "btceur"),
       get    = "tiingo.crypto",
       from   = "2020-01-01",
       to     = "2020-01-15",
       resample_frequency = "5min")
riingo_crypto_prices(c("btcusd", "btceur"), start_date = "2022-01-01", resample_frequency = "5min")
riingo_crypto_prices("btcusd", raw = TRUE)

# Only use the POLONIEX exchange
riingo_crypto_prices("btcusd", raw = TRUE, exchanges = "POLONIEX")

# Tiingo - Financial API with sub-daily stock data and crypto-currency
# Alpha Vantage - Financial API with sub-daily, ForEx, and crypto-currency data
# https://cran.r-project.org/web/packages/tidyquant/vignettes/TQ01-core-functions-in-tidyquant.html#alpha-vantage-api

# All btc___ crypotcurrency pairs
all_base <- riingo_crypto_prices(
  base_currency = c('sol', "btc")[1], # Instead of ticker
  # Crypto/IEX => min", "hour" or "day
  resample_frequency = c('15min', '1hour', '1day')[1],
  convert_currency	= c('cure', 'USD')[1],
  raw = FALSE
  # , exchanges = c("POLONIEX, GDAX")
  )
all_base$baseCurrency %>% table() %>% sort() %>% tail(10)
all_base$quoteCurrency %>% table() %>% sort() %>% tail(10)

# usethis::edit_r_environ()
Sys.getenv('RIINGO_USERID')
riingo_set_token(Sys.getenv('RIINGO_TOKEN'))

# master list of supported_tickers() 102,841 tickers by exchnage from riingo.
tickers <- supported_tickers() 
tickers %>% pull(exchange) %>% table() # 13 LSE tickers?!
tickers %>% pull(assetType) %>% table() 
etfs <- tickers %>% filter(assetType == 'ETF')
# 13 LSE tickers?!
tickers %>% filter(exchange == 'LSE') %>% view()

riingo_crypto_prices(c("solusd", "lunausd", "btcusd", "btceur")[1:2],
  resample_frequency = "1min",
  exchanges = c("FTX", "POLONIEX")[1]
  ) %>% view

tickers$ticker %>% str_subset(pattern = us_lse_etf %>% paste(collapse = '|'))
eu_lse_etf = c('')
riingo_prices(us_lse_etf)
riingo_meta(us_lse_etf)

riingo_prices(c("AAPL", "MSFT"), "1999-01-01", "2005-01-01", "monthly")
riingo_meta(c("AAPL", "QQQ"))



# USA ONLY - 18 indexes and 3 exchanges
# symbols and various attributes for every stock in an index or exchange. 
tq_index_options()
tq_index( tq_index_options()[4] )
tq_exchange_options() # only 3 US exchanges
nyse <- tq_exchange( tq_exchange_options()[3] )
# nyse$industry %>% table() %>% as_tibble() %>% arrange(desc(n))
nyse %>% count(industry) %>% arrange(desc(n))

tq_get("AAPL", get = "stock.prices", from = "2020-01-01")
quandl_search(query = "Oil", database_code = "NSE", per_page = 3) %>% 
  view
# quandl_search(query = "Oil", database_code = "LSE", per_page = 3)
nyse %>% 
  filter(symbol %>% str_detect('OI'))


test_tickers <- 
  supported_tickers() %>% # 102,841 tickers by exchnage
  select(ticker) %>% 
  pull()

# tickers from the S&P 500. ----
#  tidyquant package has this covered with the tq_index() function.
(sp_500 <- tq_index("SP500") )
sp_500$sector %>% table()

# arrange the sp_500 tickers by the weight column and then slice the top 30
tickers <-
  sp_500 %>% 
  arrange(desc(weight)) %>%
  # We'll run this on the top 30, easily extendable to whole 500
  slice(1:10) %>% 
  filter(symbol %in% test_tickers) %>% 
  pull(symbol)

divs_from_riingo <- 
  tickers %>% 
  riingo_prices(start_date = "2018-01-01", end_date = Sys.Date()-1) %>% 
  arrange(ticker) %>% 
  mutate(date = ymd(date))
divs_from_riingo %>% 
  select(date, ticker, close, divCash) %>% 
  head()

filter to filter(date > "2017-12-31" & divCash > 0) and grab the last dividend paid in 2018.

divs_from_riingo %>% 
  group_by(ticker) %>% 
  filter(date > "2017-12-31" & divCash > 0) %>% 
  slice(n()) %>% 
  ggplot(aes(x = date, y = divCash, color = ticker)) + 
  geom_point() + 
  geom_label(aes(label = ticker)) +
  scale_y_continuous(labels = scales::dollar)  +
  scale_x_date(breaks = scales::pretty_breaks(n = 10)) +
  labs(x = "", y = "div/share", title = "2018 Divs: Top 20 SP 500 companies") +
  theme(legend.position = "none",
    plot.title = element_text(hjust = 0.5)) 
#  total annual yield = sum the total dividends in 2018 / closing price at, say, the first dividend date.


divs_from_riingo %>% 
  group_by(ticker) %>% 
  filter(date > "2017-12-31" & divCash > 0) %>% 
  mutate(year = year(date)) %>% 
  group_by(year, ticker) %>% 
  mutate(div_total = sum(divCash)) %>% 
  slice(1) %>% 
  mutate(div_yield = div_total/close) %>% 
  ggplot(aes(x = date, y = div_yield, color = ticker)) + 
  geom_point() + 
  geom_text(aes(label = ticker), vjust = 0, nudge_y = 0.002) +
  scale_y_continuous(labels = scales::percent, breaks = scales::pretty_breaks(n = 10))  +
  scale_x_date(breaks = scales::pretty_breaks(n = 10)) +
  labs(x = "", y = "yield", title = "2018 Div Yield: Top 30 SP 500 companies") +
  theme(legend.position = "none",
    plot.title = element_text(hjust = 0.5)) 
