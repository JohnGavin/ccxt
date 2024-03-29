# -*- coding: utf-8 -*-

import os
import sys
import csv

# -----------------------------------------------------------------------------

# root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
# sys.path.append(root + '/python')

import ccxt  # noqa: E402


# -----------------------------------------------------------------------------


def retry_fetch_ohlcv(exchange, max_retries, symbol, timeframe, since, limit):
    num_retries = 0
    try:
        num_retries += 1
        ohlcv = exchange.fetch_ohlcv(symbol, timeframe, since, limit)
        # print('Fetched', len(ohlcv), symbol, 'candles from', exchange.iso8601 (ohlcv[0][0]), 'to', exchange.iso8601 (ohlcv[-1][0]))
        return ohlcv
    except Exception:
        if num_retries > max_retries:
            raise  # Exception('Failed to fetch', timeframe, symbol, 'OHLCV in', max_retries, 'attempts')


def scrape_ohlcv(exchange, max_retries, symbol, timeframe, since, limit):
    timeframe_duration_in_seconds = exchange.parse_timeframe(timeframe)
    timeframe_duration_in_ms = timeframe_duration_in_seconds * 1000
    timedelta = limit * timeframe_duration_in_ms
    now = exchange.milliseconds()
    all_ohlcv = []
    fetch_since = since
    while fetch_since < now:
        ohlcv = retry_fetch_ohlcv(
            exchange, max_retries, symbol, timeframe, fetch_since, limit
        )
        fetch_since = (ohlcv[-1][0] + 1) if len(ohlcv) else (fetch_since + timedelta)
        all_ohlcv = all_ohlcv + ohlcv
        if len(all_ohlcv):
            print(
                len(all_ohlcv),
                "candles in total from",
                exchange.iso8601(all_ohlcv[0][0]),
                "to",
                exchange.iso8601(all_ohlcv[-1][0]),
            )
        else:
            print(
                len(all_ohlcv), "candles in total from", exchange.iso8601(fetch_since)
            )
    return exchange.filter_by_since_limit(all_ohlcv, since, None, key=0)


def write_to_csv(filename, data):
    with open(filename, mode="w") as output_file:
        csv_writer = csv.writer(
            output_file, delimiter=",", quotechar='"', quoting=csv.QUOTE_MINIMAL
        )
        csv_writer.writerows(data)


def scrape_candles_to_csv(
    filename, exchange_id, max_retries, symbol, timeframe, since, limit
):
    # instantiate the exchange by id
    exchange = getattr(ccxt, exchange_id)(
        {
            "enableRateLimit": True,  # required by the Manual
        }
    )
    # convert since from string to milliseconds integer if needed
    if isinstance(since, str):
        since = exchange.parse8601(since)
    # preload all markets from the exchange
    exchange.load_markets()
    # fetch all candles
    ohlcv = scrape_ohlcv(exchange, max_retries, symbol, timeframe, since, limit)
    # convert timestamps to iso8601
    ohlcv = [
        [exchange.iso8601(candle[0])]
        + [symbol, exchange]
        + candle[1:]
        + [max_retries, timeframe, exchange.iso8601(since), limit]
        for candle in ohlcv
    ]  # ←--- ADD THIS LINE
    # save them to csv file
    write_to_csv(filename, ohlcv)
    # TODO: write header
    write_to_csv(filename, ohlcv)
    print(
        "Saved",
        len(ohlcv),
        "candles from",
        (ohlcv[0][0]),
        "to",
        (ohlcv[-1][0]),
        "to",
        filename,
    )
    # print('Saved2', len(ohlcv), symbol, 'candles from', exchange.iso8601 (ohlcv[0][0]), 'to', exchange.iso8601 (ohlcv[-1][0]))


# -----------------------------------------------------------------------------
# e.g. Binance's BTC/USDT candles start on 2017-08-17
max_retries = 3
timeframe = "4h"  # coinbase/coinbasepro does _not_ have '4h'
limit = 3000
fromm = "2020-03-17T00:00:00Z"  # exchange.iso8601(ohlcv[0][0])
symbols = ["LUNA/USDT", "SOL/USDT"]
for symbol in symbols:
    fn_suffix = (
        symbol.replace("/", "-")
        + "_"
        + timeframe
        + "_"
        + fromm.replace(":", "_")
        + ".csv"
    )

    scrape_candles_to_csv(
        "binance_" + fn_suffix, "binance", max_retries, symbol, timeframe, fromm, limit
    )
    scrape_candles_to_csv(
        "ftx_" + fn_suffix, "ftx", max_retries, symbol, timeframe, fromm, limit
    )
    # scrape_candles_to_csv('coinbasepro_' + fn_suffix, 'coinbase', max_retries, symbol, timeframe, fromm, limit)
