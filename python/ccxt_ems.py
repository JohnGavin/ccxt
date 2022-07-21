# ccxt install ----
# https://github.com/ccxt/ccxt
# https://docs.ccxt.com/en/latest/manual.html
# NOT conda install ccxt
# NOT py_install('ccxt')
# conda activate /Users/jbg/Library/r-miniconda
# pip install ccxt
import ccxt
id = 'binance'
exchange = getattr(ccxt, id)()
print(exchange.has)
