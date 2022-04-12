# imports ----
#' @importFrom dplyr '%>%' arrange mutate desc 
#' @importFrom tibble as_tibble 
#' @importFrom purrr map map_df 
#' @importFrom rlang as_function 
#' @importFrom lubridate as_datetime 
import::here(dplyr, `%>%`, arrange, mutate, desc) # , rename_with filter, group_by, , summarize, count, relocate, rename
import::here(tibble, as_tibble)
import::here(purrr, map, map_df)
import::here(rlang, as_function)
import::here(lubridate, as_datetime)

#' @title FTX OHLCV snapshots
#' @return a tibble of ohlcv snapshots by coin, by datetime.
#' @param pairs character vector of pairs of coins
#' @param origin POSIXlt (not as.POSIXct) - start datetime
#' @param timeframe single character vector of time steps
#' @param limit number of timesteps
#' @param ftx pointer to a ccxt exchange
#' @author <john@1x2.ltd>
#' @export 
#' @seealso medium.com/alphaimpact/how-to-link-your-ftx-com-api-keys-so-you-can-copy-trades-or-be-copied-9-simple-steps-172372888034
#' @examples 
#' # Connection to FTX api (requires key/secret)
#' ftx = reticulate::import('ccxt')$ftx(
#'   list(
#'     enableRateLimit = "True",
#'     apiKey          = Sys.getenv('FTX_key'),
#'     secret          = Sys.getenv('FTX_secret'))
#' )
#' ftx_ohlcv (
#'     pairs = c('BTC/USD'), # pairs of coins
#'     origin = as.POSIXlt(Sys.time(), tz = "UTC") - 30*60, # start 30 mins ago
#'     timeframe = c("15s"), # 15 sec timesteps
#'     limit = 2L, # two timesteps
#'     ftx = ftx)  # FTX pointer via reticulate::import('ccxt')$ftx

ftx_ohlcv <- function(
  pairs = c('BTC/USD', 'USD:USD', 'SOL/USD', 'LUNA/USD')[1], 
  origin = as.POSIXlt(Sys.time(), tz = "UTC") - 30, 
  timeframe = c("15s", "1m", "5m", "15m", "1h", "4h", "1d", "3d", "1w",
    "2w", "1M")[1], 
  limit = 2L, 
  ftx = ftx) {

  timeframe <- match.arg(timeframe)
  
  tss <- markets <- tsss <- NULL
  
  # Some exchanges don't offer any OHLCV method
  # ccxt library will emulate OHLCV candles from Public Trades. In
  # ftx$has$fetchOHLCV == 'emulated'
  if ( ftx$has$fetchOHLCV ){
    # ftx$timeframes: available timeframes for your exchange 
    # ftx$timeframes %>% names() %>% dput()
    # ftx$timeframes is only populated when has['fetchOHLCV'] is true
    # ftx$timeframes %>% unlist() 
    
    # FIXME: loop in groups of 5 then sleep rateLimit seconds
    # Sys.sleep(ftx$rateLimit / 1000) # time.sleep wants seconds
    pairs %>% 
      # exchange.fetch_ohlcv(symbol, timeframe, since, limit)
      map(~ ftx$fetch_ohlcv(.,
        # fetchOHLCV (symbol, timeframe = '1m', since = undefined, 
        # limit = undefined, params = {})
        # https://github.com/ccxt/ccxt/issues/2877
        timeframe = timeframe
        # 'since' - history range needed
        # - integer UTC timestamp in milliseconds (everywhere throughout the library with all unified methods).
        , since = 
          # WARNING: 1e3L NOT 1e3
          # ftx$parse8601('2022-04-01T00:42:00Z') 
          1e3L * as.numeric(origin)
        # ftx$fetch_ohlcv('BTC/USD', '5m', since=1649231249971) 
        , limit = limit
      )) %>% 
      structure(names = pairs) %>% 
      map( ~ purrr::map_dfr(., as_tibble, 
        .name_repair = 
          rlang::as_function(~ c('tss', 'o', 'h', "l", "c", 'v'))
      )) %>% 
      map_df(~ as_tibble(.x), .id="markets") %>% 
      # 'timestamp':  1502962946216,            // Unix timestamp in milliseconds
      # 'datetime':  '2017-08-17 12:42:48.000', // ISO8601 datetime with milliseconds
      ############
      # FIXME: best guess a time offset from now in milliseconds?
      ############
      mutate(tsss = as_datetime(tss/1e3L
        , origin = Sys.time() # as_date(origin, tz = "UTC") 
      ), .after = tss ) %>% 
      # candle list is returned in ascending (historical/chronological) order, oldest candle first, most recent candle last.
      arrange(markets, desc(tsss)) 
    
    # https://github.com/ccxt/ccxt/issues/3507
    # since argument as well as other timestamps returned from this library are all integer UTC timestamps in milliseconds
    # since (Integer) Timestamp (ms) of the earliest time to retrieve funding history for
    # since = ftx$parse8601('2022-04-06T00:00:00Z')
    # iso_8601 = Sys.time()
    # binance$parse8601( Sys.time() %>% as.numeric() )
    
    # https://github.com/ccxt/ccxt/issues/4478
    # 1504541580000, // UTC timestamp in milliseconds, integer
    # 4235.4,        // (OHLC) price, float
    # 37.72941911    // (V)olume (in terms of the base currency), float
    # op <- options(digits.secs=3)
    # ftx$parse8601( format(Sys.time()-5, "%Y-%m-%dT%H:%M:%S.%OSZ") )
    
  } else NULL
} # ftx_ohlcv