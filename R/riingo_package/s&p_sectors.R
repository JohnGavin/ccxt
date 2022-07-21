# https://rviews.rstudio.com/2019/07/09/dividend-sleuthing-with-r/
#   S&P 500 constituents daily prices
# http://www.reproduciblefinance.com/
# https://www.amazon.com/Reproducible-Finance-Portfolio-Analysis-Chapman/dp/1138484032

pacman::p_load(tidyverse, tidyquant, riingo)

# usethis::edit_r_environ()
Sys.getenv('RIINGO_USERID')
riingo_set_token(Sys.getenv('RIINGO_TOKEN'))

# tickers from the S&P 500. ----
#  tidyquant package has this covered with the tq_index() function.
(sp_500 <- tq_index("SP500") )
sp_500$sector %>% table()

# master list of supported_tickers() 102,841 tickers by exchnage from riingo.
supported_tickers() %>% pull(exchange) %>% table()
test_tickers <- 
  supported_tickers() %>% # 102,841 tickers by exchnage
  select(ticker) %>% 
  pull()

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
  riingo_prices(start_date = "2018-01-01", end_date = "2022-02-31") %>% 
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
