
# https://medium.com/geekculture/market-data-for-8000-cryptocurrencies-at-your-fingertips-c76d7e8f43ca
# https://towardsdatascience.com/a-day-in-the-life-of-a-blockchain-eb352980ee16
#   managed by a specific smart contract on the Ethereum blockchain. 
#     This contract is stored on a specific address and you can read its code here.
#   Any app connected to Ethereum network can listen to these events and act accordingly. Here is a list of recent Weird Whales events: https://etherscan.io/address/0x96ed81c7f4406eff359e27bff6325dc3c9e042bd#events
# Any app connected to Ethereum network can listen to these events and act accordingly. Here is a list of recent Weird Whales events: https://etherscan.io/address/0x96ed81c7f4406eff359e27bff6325dc3c9e042bd#events
# the Ethereum database is available on Google BigQuery.
# https://cloud.google.com/blog/products/data-analytics/introducing-six-new-cryptocurrencies-in-bigquery-public-datasets-and-how-to-analyze-them
   
# https://towardsdatascience.com/data-science-for-blockchain-understanding-the-current-landscape-c136154c367e
#   Option 2 — Use blockchain-specific API or ETL tool
#      packages are fewer but do exist: Rbitcoin (Bitcoin), ether (Ethereum), tronr (TRON).
#     open-source project in this space is “Blockchain ETL”, a collection of Python scripts developed by Nansen.ai. In
#   Option 3 — use commercial solutions
#     example, Anyblock Analytics, Bitquery, BlockCypher, Coin Metrics, Crypto APIs, Dune Analytics, Flipside Crypto).

# https://towardsdatascience.com/data-science-on-blockchain-with-r-afaf09f7578c
# https://towardsdatascience.com/data-science-on-blockchain-with-r-part-ii-tracking-the-nfts-c054eaa93fa
# https://github.com/tdemarchin/DataScienceOnBlockchainWithR-PartII
# How to replay time series data from Google BigQuery to Pub/Sub
#   https://evgemedvedev.medium.com/#:~:text=How%20to%20replay%20time%20series%20data%20from%20Google%20BigQuery%20to%20Pub/Sub
#   
# https://towardsdatascience.com/data-science-on-blockchain-with-r-part-ii-tracking-the-nfts-c054eaa93fa

# https://next-game-solutions.github.io/geckor/
# https://www.coingecko.com/en/api/documentation
# https://next-game-solutions.github.io/geckor/reference/index.html

# https://github.com/next-game-solutions/geckor
# http://nextgamesolutions.com
# devtools::install_github("next-game-solutions/geckor")
# install.packages("geckor")
#
# 50 calls per minute

pacman::p_load(geckor, tidyverse, ggplot2)
stopifnot('CoinGecko service down - ping() fails'= ping())

# https://next-game-solutions.github.io/geckor/articles/supported-currencies-and-exchanges.html
# reference currencies (fiat or crypto) to express the coin price in
supported_currencies() %>% sort() 

exchanges_meta <- supported_exchanges()
exchanges_meta %>% 
  arrange(desc(trust_score), desc(trading_volume_24h_btc)) %>% 
  relocate(name, trading_volume_24h_btc, country, year_established, 
    .before = exchange_id) %>% 
  # https://blog.coingecko.com/trust-score/
  # https://blog.coingecko.com/trust-score-2/
  filter(trust_score >= 10) %>% 
  view

coins_meta <- supported_coins()
# coin IDs in the format expected by other geckor functions
coins_meta %>% 
  filter(
    coin_id %>% str_detect('solana') |
    coin_id %>% str_detect('raydium')
  ) %>%
  arrange(coin_id) %>% 
  view

  
  
# current price 
# expressed in USD, EUR, and GBP - all pairs
#   No avalanche, mango
names <- c("solana", "raydium", 'mango', "cardano", "tron", "polkadot")
current_price(
  coin_ids = names[1:3],
  vs_currencies = c("usd", "eur", "gbp")) %>% 
  View()
# comprehensive view of the current Cardano, Tron, and 
# Polkadot markets:
current_market(coin_ids = names, 
  vs_currency = "usd") %>% 
  glimpse()

# historical price 
#  for multiple coins (up to 30) 
two_coins <- coin_history(coin_id = c("cardano", "polkadot"), 
  vs_currency = "usd", 
  days = 3)
two_coins$coin_id %>% unique()


cardano_history <- coin_history(coin_id = "cardano", 
  vs_currency = "eur", 
  days = "max")

cardano_history %>% 
  ggplot(aes(timestamp, price)) +
  geom_line() + theme_minimal()

# FX + coins
exchange_rate(currency = NULL)
exchange_rate(currency = c("btc", "usd", "rub"))


# See ?coin_tickers for definitions of columns in the resultant tibble.
geckor::coin_tickers()

geckor::coin_history_snapshot(coin_id = "cardano",
  date = as.Date("2021-05-01"),
  vs_currencies = c("usd", "eth")
) %>% glimpse()

# top-7 trending coins wrt search popularity on CoinGecko:
trending_coins() %>% view
