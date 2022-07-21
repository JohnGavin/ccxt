
# https://medium.com/coinmonks/back-testing-and-deploying-a-automated-trading-strategy-to-ftx-f84073ee1ad
# library(reticulate)
# reticulate::repl_python()

import pandas as pd
import ccxt
import datetime
exchange = ccxt.ftx()

def gather_data():
  data = exchange.fetch_ohlcv("BTC/USD")
  df = pd.DataFrame(data)
  df.columns = (['Date Time', 'Open', 'High', 'Low', 'Close', 'Volume'])
  
  def parse_dates(ts):
    return datetime.datetime.fromtimestamp(ts/1000.0)
  
  df['Date Time'] = df['Date Time'].apply(parse_dates)
  return df # df.to_csv('sampledata.csv')

def main():
  return gather_data()

if __name__ == '__main__':
  out = main()
