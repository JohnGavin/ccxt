
## CCXT
# https://github.com/ccxt/ccxt/blob/master/examples/py/async-fetch-many-orderbooks-continuously.py

# import random
# if (exchange.has['fetchTicker']):
#   print(exchange.fetch_ticker('LTC/ZEC')) # ticker for LTC/ZEC
# symbols = list(exchange.markets.keys())
# print(exchange.fetch_ticker(random.choice(symbols))) # ticker for a random symbol


import os
import sys
from asyncio import gather, get_event_loop

root = os.path.dirname(
  os.path.dirname(
    os.path.dirname(
      os.path.abspath(__file__))))
sys.path.append(root + '/python')

import ccxt.async_support as ccxt  # noqa: E402


async def symbol_loop(exchange, symbol):
    print('Starting the', exchange.id, 'symbol loop with', symbol)
    while True:
        try:
            orderbook = await exchange.fetch_order_book(symbol)
            now = exchange.milliseconds()
            print(exchange.iso8601(now), exchange.id, symbol, orderbook['asks'][0], orderbook['bids'][0])

            # --------------------> DO YOUR LOGIC HERE <------------------

        except Exception as e:
            print(str(e))
            # raise e  # uncomment to break all loops in case of an error in any one of them
            break  # you can break just this one loop if it fails

async def exchange_loop(asyncio_loop, exchange_id, symbols):
    print('Starting the', exchange_id, 'exchange loop with', symbols)
    exchange = getattr(ccxt, exchange_id)({
        'enableRateLimit': True,
        'asyncio_loop': asyncio_loop,
    })
    loops = [symbol_loop(exchange, symbol) for symbol in symbols]
    await gather(*loops)
    await exchange.close()


async def main(asyncio_loop):
    exchanges = {
        #   Star Atlas (ATLAS & POLIS), Oxigen (OXY), Orca (ORCA), Raydium (RAY), Mango Markets (MNGO)
        #     https://azcoinnews.com/top-crypto-strategist-names-5-solana-projects-with-massive-growth.html
        #   Bitgert (BRISE), Helium (HNT), Monero (XMR), Fantom (FTM), Avalanche (AVAX), 
        # 
        'binance': ['LUNA/USDT', 'RAY/USDT'],  # 'SOL/USDT', 
        'ftx': ['LUNA/USDT', 'RAY/USDT'],      # 'SOL/USDT', 
        'okex': [],
        'bitfinex': [],
        # 'okex': ['SOL/USDT', 'ETH/BTC', 'ETH/USDT'],
        # 'binance': ['BTC/USDT', 'ETH/BTC'],
        # 'bitfinex': ['BTC/USDT'],
    }
    loops = [exchange_loop(asyncio_loop, exchange_id, symbols) for exchange_id, symbols in exchanges.items()]
    await gather(*loops)


if __name__ == '__main__':
    asyncio_loop = get_event_loop()
    asyncio_loop.run_until_complete(main(asyncio_loop))
