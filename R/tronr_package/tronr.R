



# https://www.trongrid.io/
# 
# https://github.com/next-game-solutions/tronr
# public API that powers the Tronscan website. 
#   considerably slower than the TronGrid API, which is the recommended tool for use cases that require a computationally efficient and robust mechanism to extract large amounts of data from the TRON blockchain
#   tronr is not intended for the development of high-load analytical applications.

# devtools::install_github("next-game-solutions/tronr")

pacman::p_load(tronr, dplyr, ggplot2)

# https://towardsdatascience.com/a-day-in-the-life-of-a-blockchain-eb352980ee16
#   28,730 blocks generated on the TRON blockchain on 2 July 2021
#   blocks contained a total of 7,819,547 transactions

block_data <- get_block_info(
  latest = FALSE, block_number = "31570498"
)
glimpse(block_data)
block_data %>% select(tx) %>% unnest(cols = tx) %>% view()

# new block every 3 seconds
# Blocks are akin to pages in a ledger




# Current price of TRX expressed in USD, EUR and BTC (Bitcoin):
get_current_trx_price(vs_currencies = c("usd", "eur", "btc"))

# TRX market data 
(min_timestamp <- (Sys.Date() - 100) %>% to_unix_timestamp())
#> [1] "1577836800000"
(max_timestamp = Sys.time() %>% to_unix_timestamp())
#> [1] "1588287600000"

price_history <- get_trx_market_data_for_time_range(
  vs_currency = "usd",
  min_timestamp = min_timestamp,
  max_timestamp = max_timestamp
) %>% 
  arrange(desc(timestamp))
price_history

price_history %>% 
  ggplot(aes(timestamp, price)) +
  geom_line() +
  theme_minimal()

# Information on the latest block on the chain:
get_block_info(latest = TRUE) %>% 
  glimpse()
