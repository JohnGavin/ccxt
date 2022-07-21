# https://www.bryanshalloway.com/2022/06/16/converting-between-currencies-using-pricer/
# conversion rate is constantly changing. If you have historical data you’ll want the conversion to be based on what the exchange rate was at the time
# 
library(priceR)
library(dplyr)
library(tidyr)
library(purrr)
library(lubridate)

sim_count <- 10000

set.seed(123)
transactions <- tibble(
  sales_date = sample(
    seq(as.Date('2021/09/01'), 
      as.Date('2022/01/01'), 
      by = "day"), 
    replace = TRUE, sim_count) %>% 
    sort(),
  local_currencies = sample(
    c("CAD", "EUR", "JPY"), 
    replace = TRUE, sim_count),
  list_price = abs(rnorm(sim_count, 1000, 1000))
)


create_rates_lookup <- function(data, 
  currency_code, 
  date = lubridate::today(),
  to = "USD", 
  floor_unit = "day"){
  rates_start <- data %>% 
    count(currency_code = {{currency_code}}, 
      date = {{date}} %>% 
        as.Date() %>% 
        floor_date(floor_unit)
    ) 
  
  # When passing things to the priceR API it is MUCH faster to send over a range
  # of dates rather than doing this individually for each date. Doing such
  # reduces API calls.
  rates_end <- rates_start %>% 
    group_by(currency_code) %>% 
    summarise(date_range = list(range(date))) %>% 
    mutate(
      # limit the number of API hits required I first create a lookup table with all unique currency conversions and dates required
      rates_lookup = map2(
        currency_code,
        date_range,
        ~ priceR::historical_exchange_rates(
          from = .x,
          to = to,
          start_date = .y[[1]],
          end_date = .y[[2]]
        ) %>%
          set_names("date_lookup", "rate")
      )
    ) %>% 
    select(-date_range) %>% 
    unnest(rates_lookup)
  
  rates <- rates_end %>% 
    semi_join(rates_start, c("date_lookup" = "date"))
  
  rates_lookup <- rates %>% 
    mutate(to = to) %>% 
    select(from = currency_code, to, date = date_lookup, rate)
  
  # this step makes it so could convert away from "to" currency --
  # i.e. so can both convert from "USD" and to "USD" from another currency.
  bind_rows(rates_lookup,
    rates_lookup %>%
      rename(from = to, to = from) %>%
      mutate(rate = 1 / rate)) %>% 
    distinct()
}

rates_lookup <- create_rates_lookup(transactions, 
  local_currencies, 
  sales_date)

rates_lookup



convert_currency <- function(price, 
  date, 
  from, 
  to = "USD", 
  currencies = rates_lookup){
  tibble(price = price, 
    from = from, 
    to = to, 
    date = date) %>% 
    left_join(currencies, by = c("from", "to", "date")) %>% 
    mutate(output = price * rate) %>% 
    pull(output)
}
# Convert Prices
# Now let’s convert our original currencies to USD.

transactions_converted <- transactions %>%
  mutate(list_price_usd = 
      convert_currency(list_price,
        sales_date,
        from = local_currencies,
        to = "USD"))

transactions_converted

transactions_converted %>%
  mutate(new_currencies = sample(c("CAD", "EUR", "JPY"), replace = TRUE, sim_count)) %>%
  mutate(list_price_converted =
    convert_currency(list_price_usd,
      sales_date,
      from = "USD",
      to = new_currencies))

