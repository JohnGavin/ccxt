import pandas as pd
import requests

markets = requests.get('https://ftx.com/api/markets').json()
df = pd.DataFrame(markets['result'])
df.set_index('name', inplace = True)
df.T


markets = pd.DataFrame(requests.get('https://ftx.com/api/markets/BTC-0924').json())
markets = markets.drop(['success'], axis=1)
markets


futures = requests.get('https://ftx.com/api/futures').json()
df = pd.DataFrame(futures['result'])
df.set_index('name', inplace = True)
df.tail().T



# futures = requests.get('https://ftx.com/api/futures/YFI-0326/stats').json()
# futures

futures_weight = requests.get('https://ftx.com/api/indexes/ALT/weights').json()
futures_weight

futures_exp = requests.get('https://ftx.com/api/expired_futures').json()
futures_exp = pd.DataFrame(futures_exp['result'])
futures_exp.set_index(futures_exp['description'], inplace=True)
futures_exp.head().T


historical = requests.get('https://ftx.com/api/markets/BTC-0924/candles?resolution=3600&start_time=1609462800').json()
historical = pd.DataFrame(historical['result'])
historical.drop(['startTime'], axis = 1, inplace=True)
historical.head()
historical['time'] = pd.to_datetime(historical['time'], unit='ms')
historical.set_index('time', inplace=True)
historical['20 SMA'] = historical.close.rolling(20).mean()
historical.tail()
