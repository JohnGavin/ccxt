
# retrieving a daily snapshot of my account for months
#   https://datawookie.dev/blog/2021/10/binance-tracking-total-account-balance/
# retrieving a daily/hourly snapshot of orderbook for months
#   Currently only on Futures
#     Tick-level orderbook (T_Depth): Since July 2020, all symbols and pairs.
#     https://www.binance.com/en/landing/data
# https://developers.shrimpy.io/pricing
#   1-min orderbook snapshots across _exchanges_
#   $0.20 per 1k 1-min snapshots => 80c per coin per day
#     => top 10 coins for a year for 3 exchange ~ 10k USD
#     https://developers.shrimpy.io/pricing
#     https://docs.ftx.com/#get-orderbook
#       https://docs.ftx.com/#get-future-stats
#     
#   https://help.shrimpy.io/hc/en-us/articles/1260803096650-Historical-Cryptocurrency-Market-Data-API-Trade-Data-and-Order-Book-Snapshots
#   https://blog.shrimpy.io/blog/historical-crypto-exchange-order-book-snapshots
#   https://api.tiingo.com/documentation/crypto
# 
# coins have moved a lot lately, 
#   big spikes in volume or open interest or liquidations, etc
#   ???
# social media, and we have alerts for e.g. whenever Elon Musk tweets.



# 200 tradable coins and over 300 tradable pairs. 
# BTC, ETH, LTC, BNB, MKR
# US stocks like AMZN, SPY, APPL, TSLA NFLX, FB, 

# devtools::install_github("andreskull/rFTX", 
# force = TRUE, build_vignettes = TRUE)
#   vignette("rFTX-Functionality", package = 'rFTX')
pacman::p_load(rFTX, tidyverse, digest, lubridate, logging, 
  httr, janitor)

ftx_coin_markets(key=FTX_key, secret=FTX_secret) ->
  tmp
if (! tmp$success) message(tmp$failure_reason)
tmp %>% 
  `[[`('data') %>% 
  janitor::clean_names() ->
  tmp
tmp %>% filter(name %>% duplicated) %>% nrow() %>% `==`(0) %>% 
  stopifnot('duplicate underlying when no dups expected' = .)
tmp %>% filter(!enabled) %>% nrow() %>% `==`(0) %>% 
  stopifnot('some coins are not enabled - why?' = .)
tmp %>% filter(post_only) %>% nrow() %>% `==`(0) %>% 
  stopifnot('some coins are post_only - why?' = .)
# TODO: get trading access to equities, commodities, FX 
#   (spot and futures) ~100 underlyings
tmp %>% filter(restricted) %>% pull(name) %>% sort()
inpp <- list(volume_usd24h_m = 50)
tmp %>% 
  mutate(volume_usd24h_m = (volume_usd24h / 1e6) %>% round(0)) %>% 
  # restrict to 10 USD volume 
  filter(volume_usd24h_m > inpp$volume_usd24h_m) %>% 
  select(!matches('increment|min_provide_size')) %>%  
  select(-any_of(c('enabled', 'post_only', 'restricted'))) %>% 
  relocate(type, tokenized_equity, quote_currency, 
    underlying, base_currency, high_leverage_fee_exempt, 
    volume_usd24h_m, everything()) %>% 
  arrange(type, tokenized_equity, quote_currency, 
    underlying, base_currency, high_leverage_fee_exempt) %>% 
  group_by(type, tokenized_equity, 
    high_leverage_fee_exempt) %>% 
  arrange(desc(volume_usd24h_m)) %>% 
  select(name, volume_usd24h_m, type, tokenized_equity, 
    underlying, base_currency, high_leverage_fee_exempt) ->
  coins
coins %>% glimpse()
tmp %>% glimpse()
coins_name <- coins %>% pull(name) %>% structure(., names = .)
inpp <- list(depth = 10)
coins_name %>% 
  # head(2) %>% 
  imap(~ ftx_orderbook(key=FTX_key, secret=FTX_secret, 
    market = ., depth = inpp$depth)) ->
  coins_bo
coins_bo %>% 
  map( ~ if (!.$success) .$failure_reason else NULL) %>% 
  purrr::compact() %>% 
  length() %>% `==`(0) %>% 
  stopifnot('failed to get orderbook for some coins' = .)
coins_bo %>% 
  map( ~ if (.$success) .$data else NULL) %>% 
  purrr::compact() %>% 
  enframe() %>% 
  rename(coin = name) %>% 
  unnest(col = value) %>% 
  group_by(coin, name) %>% 
  summarize(bo_bal_usd = 
    # NB:have to convert to USD to compare between coins
    # NB: NOT per average level in case we dont have 10 levels for all coins
    #   cos we care about total USD value per coin, not per orderbook level
    sum(price * size) # / n() # / sum(price)
    # sum(size) 
    , .groups = 'drop') %>% 
  pivot_wider(id_cols = coin, names_from = name, 
    values_from = bo_bal_usd) %>% 
  group_by(coin) %>% 
  summarize(bo_imbal_usd = bids - asks, .groups = 'drop') %>% 
  arrange(desc(bo_imbal_usd)) ->
  coins_bo_imbal_usd
coins_bo_imbal_usd

FTX_key <- Sys.getenv('FTX_key')
FTX_secret <- Sys.getenv('FTX_secret')
FTX_uri_main <- Sys.getenv('FTX_uri_main')
FTX_uri_keep <- Sys.getenv('FTX_uri_keep')
# FTX_key ; FTX_secret ; 
FTX_uri_main ; FTX_uri_keep
ftx_trades(key = "", secret = "", market = "FTM-PERP")

ftx_trades(key = "", secret = "", market = "AAPL/USD")
ftx_spot_lending_history(key=FTX_key, secret=FTX_secret)
ftx_future_funding_rates(key = "", secret = "", markets = c('CRV-PERP','XRP-PERP'))

# account positions and takes subaccount as an optional argument
(main <- ftx_coin_balances(key=FTX_key, secret=FTX_secret, account = c()))
(main2 <- ftx_coin_balances(key=FTX_key, secret=FTX_secret, account = FTX_uri_main))
(keep <- ftx_coin_balances(key=FTX_key, secret=FTX_secret, account = FTX_uri_keep))

ftx_positions(key=FTX_key, secret=FTX_secret, subaccount = '')
ftx_positions(key=FTX_key, secret=FTX_secret, subaccount = FTX_uri_main)
ftx_positions(key=FTX_key, secret=FTX_secret, subaccount = FTX_uri_keep)


# markets on FTX: spot, perpetual futures, expiring futures, 
#   and MOVE contracts. https://help.ftx.com/hc/en-us/articles/360033136331-MOVE-contracts
#   MOVE contracts represent the absolute value of the amount a product moves in a period of time. So if a daily BTC moves $125 from the beginning to end of a day, the BTC-MOVE contract will expire to $125 whether BTC went up or down. ... Getting short MOVE contracts means you will win if BTC is relatively stable
#   like futures;  instead of expiring to the price of a token, 
#     they expire to the amount its price moved.  
#     leveraged long/short MOVE contracts using collateral.
# For futures that expired in 2019, like so: BTC-20190628 or BTC-MOVE-20190923. 
# MOVE contracts are a type of futures that have an expiration date
#   make profits solely from the volatility of BTC, no matter the direction of the move
ftx_coin_markets(key = "", secret = "")
ftx_coin_markets(key=FTX_key, secret=FTX_secret) %>% glimpse()
# Leveraged Tokens 
# requests.get('https://ftx.com/api/lt/tokens').json()

ftx_trades(key=FTX_key, secret=FTX_secret, 
  market='SOL-PERP', start_time = NA, end_time = NA) %>% 
  `[[`('data') %>% 
  # FIXME: timestamp is the current time?
  arrange(desc(time)) %>% 
  view()

ftx_orderbook(key=FTX_key, secret=FTX_secret, market = 'SOL-PERP', depth = 10)

# prices of expired futures. Start and end time arguments are optional
ftx_historical_prices(key=FTX_key, secret=FTX_secret, market = 'SOL-PERP',
    resolution = 14400, start_time = NA, end_time = NA)
# expired futures
# futures_exp = requests.get('https://ftx.com/api/expired_futures').json()
# futures_exp = pd.DataFrame(futures_exp['result'])\
#  .set_index(futures_exp['description'], inplace=True).head().T

# futures on FTX: perpetual, expiring, and MOVE. 
# e.g. BTC-PERP, BTC-0626, and BTC-MOVE-1005. 
# For futures prepend to the date, like so: BTC-20190628
ftx_future_markets(key=FTX_key, secret=FTX_secret, market = 'SOL-PERP')
# stats on futures such as volume which is quantity traded in the last 24 hours
ftx_future_stat(key=FTX_key, secret=FTX_secret, market = 'SOL-PERP') 
# funding rates of futures.
ftx_future_funding_rates(key=FTX_key, secret=FTX_secret, market = 'SOL-PERP'
  # , start_time= '', end_time = ''
  )
# TODO: To get the Index Weights of a Future with the FTX API do the following:
# requests.get('https://ftx.com/api/indexes/ALT/weights').json()



# account or subaccount / open orders + their statuses (accepted but not processed yet), open, or closed (filled or cancelled).
ftx_open_orders(key=FTX_key, secret=FTX_secret, 
  subaccount=FTX_uri_keep, market = 'SOL-PERP')
ftx_open_orders(key=FTX_key, secret=FTX_secret, 
  subaccount='', market = 'SOL-PERP')

# history of orders for the account or subaccount if specified.
ftx_orders_history(key=FTX_key, secret=FTX_secret, 
  subaccount=FTX_uri_keep, market = 'SOL-PERP')
ftx_orders_history(key=FTX_key, secret=FTX_secret, 
  subaccount='', market = 'SOL-PERP')


## market fills ----
# The markets argument can take in more than one value. 
# Fills generated by Converts will show up as 'type': 'otc'.
ftx_order_fills(key=FTX_key, secret=FTX_secret, 
  subaccount=FTX_uri_keep, market = 'SOL-PERP'
  # , start_time=NA, end_time=NA
  )

# funding payments for futures.
ftx_funding_payments(key=FTX_key, secret=FTX_secret, 
  subaccount=FTX_uri_keep
  # , start_time = NA, end_time = NA
)

# lending history for coins in rate and size. 
ftx_spot_lending_history(key=FTX_key, secret=FTX_secret
  # , start_time=NA, end_time=NA
)
# estimated hourly borrow rate for the next spot margin cycle and the hourly borrow rate in the previous spot margin cycle for coins.
ftx_spot_margin_borrow_rates(key=FTX_key, secret=FTX_secret, 
  subaccount=FTX_uri_keep)
# coin borrow history for the user.
ftx_my_spot_borrow_history(key=FTX_key, secret=FTX_secret, 
  subaccount=FTX_uri_keep
  # , start_time, end_time
)



## Orders ----
# status of orders such as new (accepted but not processed yet), open, or closed (filled or cancelled).
ftx_order_status(key=FTX_key, secret=FTX_secret, 
  subaccount='', order_id)
# status of orders using the client ID instead of the order ID.
ftx_order_status_clientid(key=FTX_key, secret=FTX_secret, 
  subaccount='', client_id)
# queues an order for cancellation.
ftx_cancel_order(key, secret, subaccount, order_id)
# queues an order for cancellation using the client ID instead of the order ID.
ftx_cancel_order_clientid(key, secret, subaccount, client_id)

# places an order based on the information provided. Market, side, price, type and size are required arguments. It returns information on the order along with their statuses such as new (accepted but not processed yet), open, or closed (filled or cancelled).
ftx_place_order(key, secret, subaccount, market=NA, side=NA, price=NA, type=NA, size=NA, 
  reduceOnly=FALSE, ioc=FALSE, postOnly=FALSE, clientId=NA)
# modifies an order based on size and price. Either price or size must be specified. The order's queue priority will be reset, and the order ID of the modified order will be different from that of the original order. Also, this is implemented as cancelling and replacing your order. There's a chance that the order meant to be cancelled gets filled and its replacement still gets placed.
ftx_modify_order(key, secret, subaccount, order_id, size, price)
# modifies an order using the client ID instead of the order ID. 
ftx_modify_order_clientid(key, secret, subaccount, client_id, size, price)



# https://algotrading101.com/learn/ftx-api-guide/
# API has a “nonce” feature (ts)
#   a number that must not be repeated and 
#   must be increased between order requests. 
#   prevents  hackers who have captured our previous request 
#     to simply replay that request?
#     
# market – the thing you want to buy or sell (e.g. BTC/USD or XRP-PERP)
# side – buy or sell
# price – pass “null” if you want to do a market order
# type – limit or market
# size – the amount you want to buy
# reduceOnly – optional
# ioc – optional
# postOnly – optional
# clientId – optional
