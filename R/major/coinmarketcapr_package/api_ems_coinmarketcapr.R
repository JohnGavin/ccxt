
# devtools::install_github("amrrs/coinmarketcapr")

library(coinmarketcapr)
library(dplyr)
library(ggplot2)
library(stringr)

coinmarketcapr::setup(
  api_key = '4b87dfb5-7eb5-419f-8ff2-07d967cba71c')
# Global-Metrics - Free API",{
# reset_setup() ; coinmarketcapr::setup('71618174-fd24-4c8f-8c94-83bc3e1cd68e')

coinmarketcapr::get_api_info() %>% View()
# coinmarketcapr::get_crypto_ohlcv(currency = 'USD')
# Your API Key subscription plan doesn't support this endpoint

# get_global_marketcap(latest = FALSE, count = 10, 
#   interval = "yearly",
#   time_start = Sys.Date()-180, time_end = Sys.Date())
# get_global_marketcap(
#   latest = T, time_start = Sys.Date() - 180,
#   time_end = Sys.Date(), count = 10,
#   interval = "yearly"
# )

cmap <- get_crypto_map(symbol = c("SOL", "BTC", "ETH"))
cmap2 <- get_crypto_map(listing_status = "active", start = 1, limit = 10)
# get_crypto_map(listing_status = "inactive", start = 1, limit = 10)

mp <- get_exchange_map()
mp %>% 
  filter(slug %>% str_detect('sol'))

meta <- get_exchange_meta(slug = c("binance", "ftx"))
# get_exchange_meta(id = 1)
# get_crypto_meta()
# get_crypto_quotes()
# get_crypto_marketpairs("EUR") # Your API Key subscription plan doesn't support this endpoint
# get_crypto_ohlcv("EUR")
coinmarketcapr::setup('5ca3ffee-dbb9-4dff-8f09-e1a9128dfa26', sandbox = T)
get_crypto_ohlcv(latest = T) # only latest, no history
# get_crypto_quotes("EUR", latest = F)
# get_global_marketcap("EUR", latest = FALSE, count = 10)


curr <- get_valid_currencies()
mc <- get_global_marketcap()
tkrs <- get_crypto_listings()
tkrs %>% glimpse()
names(tkrs)

all_coins <- get_marketcap_ticker_all()
head(all_coins)

#get the global market cap details and assign it to a dataframe
mc_eur <- get_global_marketcap('EUR')

library(ggthemes)
plot_top_currencies('USD',5) + 
  theme_economist()

tkrs %>% 
  slice(1:30) %>% # names %>% sort()
  mutate(price_usd = as.numeric(USD_price)) %>% 
  ggplot() + geom_histogram(aes(price_usd), binwidth = 100) +
  ggtitle('Cryptocurrencies Price in USD Histogram')
