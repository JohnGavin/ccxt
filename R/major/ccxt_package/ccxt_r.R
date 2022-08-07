

# https://github.com/ccxt/ccxt/wiki/Manual#instantiation


pacman::p_load(reticulate, tidyverse, lubridate)



# Public APIs include the following:
# order books ??? snapshots??
# market data
# instruments/trading pairs
# price feeds (exchange rates)
# trade history
# tickers
# OHLC(V) for charting
# other public endpoints




# Perputals on FTX?
tickers %>% names() %>% str_subset('USD:USD$')
tickers[['ZECBULL/USD']] %>% str(max.level = 2)
tickers$'ZECBULL/USD'$info %>% str(max.level = 2)
tickers %>% # head(2) %>% 
  map_df(~ .[names(.) != 'info'] ) %>% 
  type.convert(as.is = TRUE) %>% 
  mutate(datetime = datetime %>% as_datetime() ) ->
  info_tckrs_ftx

# FIXME: function to map from timestamp to datetime
info_tckrs_ftx$datetime[1:2]
info_tckrs_ftx$timestamp[1:2] # -1202095978

# Perputals on Binance
tickers_not_info_binance$symbol %>% str_subset('PERP')

# FTX v Binance for bucketed data
info_tckrs_ftx %>% names()
info_tckrs_ftx_binance %>% names()
tickers_not_info %>% names()
tickers_not_info_binance %>% names()

# https://github.com/ccxt/ccxt/wiki/Manual#ohlcv-candlestick-charts ----



tmp <- ftx$fetch_ohlcv(
  c("SOL/USDT", "LTC/USDT", "BTC/USD")[1], 
  '1d'
)
tmp[[1]]
tmp <- tmp %>% tibble(nm = .) %>% unnest_wider(nm)
# https://github.com/ccxt/ccxt/wiki/Manual#ohlcv-structure
# sorted in ascending (historical/chronological) order, oldest candle first
# 1504541580000, // UTC timestamp in milliseconds, integer
# 4235.4,        // (O)pen price, float
# 4240.6,        // (H)ighest price, float
# 4230.0,        // (L)owest price, float
# 4230.7,        // (C)losing price, float
# 37.72941911    // (V)olume (in terms of the base currency), float
names(tmp) <- c('date', 'open', 'high', 'low', 'close', 'volume')
# https://github.com/ccxt/ccxt/wiki/Manual#order-book
#   UTC timestamp in milliseconds since 1 Jan 1970 00:00:00.
# ohlc = [ [x[0] / 1000] + x[1:] 
#   for x in ftx.fetch_ohlcv("BTC/USD", '1d')[-60:] ]
tmp %>% tail(60) %>% mutate(date = date %>% as_datetime())

# https://github.com/ccxt/ccxt/wiki/Manual#querying-orders
# fetchOrder (id, symbol = undefined, params = {})
# fetchOpenOrders (symbol = undefined, since = undefined, limit = undefined, params = {})
# fetchClosedOrders (symbol = undefined, since = undefined, limit = undefined, params = {})

# fetching currently-open orders.
ftx_has[['fetchOpenOrders']]
# list of all orders
ftx_has[['fetchOrders']]
ftx_has[['fetchOpenOrders']]
ftx_has[['fetchMyTrades']]
ftx_has[['fetchTrades']]

# private resting orders
ftx$fetchOpenOrders()  %>% str(max.level = 2)
# default set is exchange-specific
# trades or recent orders starting from the date of listing a pair on the exchange,
# other exchanges will return a reduced set of trades or orders (like, last 24 hours, last 100 trades, first 100 orders, etc
# since and limit is exchange-specific. However, most exchanges do provide at least some alternative for "pagination" and "scrolling" which can be overrided with extra params argument
# fetchOrders (symbol = undefined, since = undefined, limit = undefined, params = {})
# ftx$fetchOrders() %>% str(max.level = 1)
ftx$fetchOrders(symbol = 'SOL/USD:USD', since = 1) %>% 
  str(max.level = 2)
# https://github.com/ccxt/ccxt/wiki/Manual#order-structure
ftx$fetchTrades('sol/usd') %>% str(max.level = 1)


# Liquidation price
# https://github.com/ccxt/ccxt/wiki/Manual#liquidation-price
# It is the price at which the 
# initialMargin + unrealized = collateral = maintenanceMargin. 
# The price has gone in the opposite direction of your position 
#   to the point where the is only maintenanceMargin collateral left 
#   and if it goes any further the position will have negative collateral.



# Some exchanges will provide the order history, 
#   other exchanges will not. 

# https://github.com/ccxt/ccxt/wiki/Manual#market-depth
# Some exchanges accept a dictionary of extra parameters to the 
# fetchOrderBook () / fetch_order_book () function. 
# All extra params are exchange-specific (non-unified). You will need to consult exchanges docs if you want to override a particular param, like the depth of the order book. 
#   limited count of returned orders or a desired level of aggregation (aka market depth) 
#   by specifying an limit argument and exchange-specific extra params like so:
# return up to ten bidasks on each side of the order book stack
# limit = 10
# ccxt.cex().fetch_order_book('BTC/USD', limit)
# ftx$fetch_order_book('BTC/USD', limit)

# fetchTicker to serve statistical data, treat it as "live 24h OHLCV".
# historical mark, index, and premium index prices, add one of 'price': 'mark', 'price': 'index', 'price': 'premiumIndex' respectively to the params-overrides of fetchOHLCV. There are also convenience methods fetchMarkPriceOHLCV, fetchIndexPriceOHLCV, and fetchPremiumIndexOHLCV that obtain the mark, index and premiumIndex historical prices and volumes
# fetchTicker (symbol[, params = {}]), symbol is required, params are optional
# fetchTickers ([symbols = undefined[, params = {}]]), both arguments optional

# If you need a unified way to access bids and asks 
# use fetchL[123]OrderBook family instead.



# plt.xticks([x[0] for x in ohlc[::2]], [datetime.utcfromtimestamp(x[0]).strftime("%m/%d") for x in ohlc[::2]])
# mpf.candlestick_ohlc(ax, ohlc, width=0.7, colorup='g', colordown='r')
# ax.grid()
# fig.autofmt_xdate()


ftx$fetch_balance() %>% enframe() -> tmp
tmp %>% str(max.level = 4)
# tmp$value[tmp$name == 'info']
# tmp$value[[1]][2]$result
tmp$name %>% duplicated() %>% sum() %>% `==`(0) %>% 
  stopifnot('balance names are not unique?' = .)
tmp %>% map_df(~ unlist(.) %>% bind_rows()) %>% 
  type.convert(as.is=T) %>% view()
ftx$fetch_order_book(ftx$symbols[1]) %>% enframe()
ftx$fetch_ticker('SOL/USD') %>% enframe()
trds <- ftx$fetch_trades(c('SOL/USDT', 'LTC/USDT')[1] )
# trds %>% str(max.level = 1)
trds %>% map_df(~ unlist(.) %>% bind_rows()) %>% 
  type.convert(as.is=T) ->
  trds
trds %>% select(datetime:cost)

# https://github.com/ccxt/ccxt/blob/master/examples/py/ftx-set-leverage.py
# see https://docs.ftx.com/#change-account-leverage for more details
# response = ftx$private_post_account_leverage({
#   'leverage': 10,
# })



# sell one ฿ for market price and receive $ right now
# print(exmo.id, exmo.create_market_sell_order('BTC/USD', 1))
# 
# limit buy BTC/EUR, you pay €2500 and receive ฿1  when the order is closed
# print(exmo.id, exmo.create_limit_buy_order('BTC/EUR', 1, 2500.00))
# 
# pass/redefine custom exchange-specific order params: type, amount, price, flags, etc...
# kraken.create_market_buy_order('BTC/USD', 1, {'trading_agreement': 'agree'})


exchange_id = 'binance'




ccxt$ftx$alias
ccxt$ftx$set_markets(ftx, markets = 'sol')

ccxt$binance$commonCurrencies
# ccxt$binance$common_currency_code(currency = 'btc')
ccxt$binance$fetch_funding_fees()



# TODO: move to python 3.9 # ----
# Python 3.7.7 (/Users/jbg/Library/r-miniconda/envs/r-reticulate/bin/python)
import ccxt
from pprint import pprint as pp
ccxt.exchanges # print a list of all available exchange classes
# library supports concurrent asynchronous mode with asyncio and async/await in Python 3.5.3+
  
# link against the asynchronous version of ccxt
import ccxt.async_support as ccxt 

hitbtc_markets = hitbtc.load_markets()

print(hitbtc.id, hitbtc_markets)
print(bitmex.id, bitmex.load_markets())
print(huobipro.id, huobipro.load_markets())

print(hitbtc.fetch_order_book(hitbtc.symbols[0]))
print(bitmex.fetch_ticker('BTC/USD'))
print(huobipro.fetch_trades('LTC/USDT'))

print(exmo.fetch_balance())

# sell one ฿ for market price and receive $ right now
print(exmo.id, exmo.create_market_sell_order('BTC/USD', 1))

# limit buy BTC/EUR, you pay €2500 and receive ฿1  when the order is closed
print(exmo.id, exmo.create_limit_buy_order('BTC/EUR', 1, 2500.00))

# pass/redefine custom exchange-specific order params: type, amount, price, flags, etc...
kraken.create_market_buy_order('BTC/USD', 1, {'trading_agreement': 'agree'})
