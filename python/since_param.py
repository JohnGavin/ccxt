
# https://github.com/ccxt/ccxt/issues/6490
import ccxt
from datetime import datetime, timedelta
ct = ccxt.ftx()
_ = ct.load_markets()
since = datetime.utcnow() - timedelta(days=1)
since_ms = int( since.timestamp()  * 1000 )
ct.fetch_ohlcv('BTC/USD', '5m', since=since_ms, limit= 1)

