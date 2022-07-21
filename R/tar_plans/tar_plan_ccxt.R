
# ccxt install ----
# https://github.com/ccxt/ccxt
# https://docs.ccxt.com/en/latest/manual.html
# NOT conda install ccxt
# NOT py_install('ccxt')
# conda activate /Users/jbg/Library/r-miniconda
# pip install ccxt

# https://stackoverflow.com/questions/65251887/clang-7-error-linker-command-failed-with-exit-code-1-for-macos-big-sur/65334247#65334247


# imports ----
# https://github.com/rticulate/import
# import::here() - place imported objects in the current environment
import::here(dplyr, filter, rename_with) # arrange,  group_by, , summarize, count, relocate, rename
import::here(reticulate, import)
import::here(tibble, tibble)
import::here(stringr, str_subset)
import::here(purrr, map_df)
import::here(rlang, list2) 
import::here(pacman, p_load) 
import::here(janitor, tabyl) 

#  load_markets symbols fetch_tickers has markets  ftx$

pacman::p_load(
  reticulate, tidyverse, # TODO: drop these packages?
  lubridate, targets, tarchetypes)
# pacman::p_load(tarchetypes)

# no point in storing pointers so define globally
ccxt = import('ccxt')
ftx = ccxt$ftx( # ccxt$kraken()
  list(
    enableRateLimit = "True",
    apiKey          = Sys.getenv('FTX_key'),
    secret          = Sys.getenv('FTX_secret'))
  )
binance = 
  # import ccxt
  # id = 'binance'
  # exchange = getattr(ccxt, id)()
  # print(exchange.has)
  binance = ccxt$binance(  list(
    enableRateLimit = "True"
    #, apiKey = Sys.getenv('FTX_key')
    #, secret= Sys.getenv('FTX_secret')
  )) # ccxt$kraken()
  # Sys.getenv('binance_key') ; Sys.getenv('binance_secret')
  # Sys.getenv('binance_uri_main') ; Sys.getenv('binance_uri_keep')


  
plan_ccxt = tar_plan( # ----
  ccxt_info = list2(
    version__ = ccxt[['__version__']],
    TICK_SIZE = ccxt$TICK_SIZE,
    exchanges_sample = ccxt$exchanges %>% sample(4) %>% sort()
  ) ,
  ftx_info = list2(
    # 'emulated' string means the endpoint isn't natively available from the exchange API but reconstructed (as much as possible) by the ccxt library from other available true-methods
    fetchStatus = ftx$fetchStatus()
    # $fetchStatus == "emulated" is _string_ rest are T/F/NULL
  ),
  # MARKETS
  ftx_markets = ftx$load_markets() ,
  ftx_markets_chk = {
    # ftx$load_markets() similar to ftx$symbols?
    # ftx_markets %>% str(max.level = 1)
    # ftx$symbols %>% str(max.level = 1)
    # names(ftx_markets) %>% str(max.level = 1)
    tmp <- tibble(market_nms = names(ftx_markets) %>% sort(), 
      symbols = ftx$symbols %>% sort())
    # confirm that market_nms start with symbols (exactly)
    tmp %>% 
      mutate(starts_with = market_nms %>% str_detect(symbols)) %>%
      filter(!starts_with) %>% nrow() %>% `==`(0) %>% 
      stopifnot('load_markets() !~ ftx$symbols?' = .)
  } , 
  
  inpp = {
    inpp <- rlang::list2(
      coins_rand = 
        ftx_markets %>% 
        names() %>% 
        # names(ftx$markets) # WARNING: now produces NULL
        str_subset(pattern = "SOL|LUNA") %>%
        sample(2),
      pairs = c('BTC/USD', 'USD:USD', 'SOL/USD', 'LUNA/USD')[3:4],
      origin = as.POSIXlt(Sys.time(), tz = "UTC") - 30*60,
      timeframe = c("15s", "1m", "5m", "15m", "1h",
        "4h", "1d", "3d", "1w", "2w", "1M")[1],
      limit = 2L,
    )
    # inpp$pr_max = min(inpp$x, 1)
    inpp
  },
  # https://github.com/co3k/co3k-crypto-currency-note/blob/master/Untitled.ipynb
  # using ccxt to fetch OHLCV candles from Kraken
  #  1000 (?) last candles for any timeframe is more than enough for most of needs.
  #  REST polling) latest OHLCVs and storing them in a CSV file or in a database.
  #  info from the last (current) candle may be incomplete until the candle is closed (until the next candle starts).
  #
  # Most exchanges have endpoints for fetching OHLCV data,
  # boolean (true/false) property named has['fetchOHLCV'] indicates whether the exchange supports candlestick data series or not.
  tarchetypes::tar_force(name = ftx_ohlcv_snapshots, # ----
    # FIXME: best guess a time offset from now in milliseconds?
    command = ftx_ohlcv(
      pairs = inpp$pairs, origin = inpp$origin,
      timeframe = inpp$timeframe, limit = inpp$limit, ftx = ftx)
    , force = TRUE ),

  # ftx_chk = {
  #   Sys.getenv('FTX_key') ; Sys.getenv('FTX_secret')
  #   Sys.getenv('FTX_uri_main') ; Sys.getenv('FTX_uri_keep')
  # },

  # has: An assoc-array containing flags for exchange capabilities, including the following:
  ftx_has = ftx$has, # str(ftx_has, list.len = 5)
  # https://github.com/ccxt/ccxt/wiki/Manual#exchange-time
  # https://github.com/ccxt/ccxt/wiki/Manual#exchange-status-structure
  # ftx_has[['fetchStatus']]
  # # 'emulated' string means the endpoint isn't natively available from the exchange API but reconstructed (as much as possible) by the ccxt library from other available true-methods
  # ftx$fetchStatus() either a string or logincal or null
  # # $fetchStatus == "emulated" is _string_ while other ans are T/F/NULL?
  

  # fetch all tickers with a single call
  tickers_ftx = ifelse(ftx_has$fetchTickers, 
    ftx$fetch_tickers(), # all tickers indexed by their symbols
    NULL) ,
  # ALL tickers - api restricted?
  # tickers_ftx = ftx$fetch_tickers(), 
  # tickers_ftx %>% names() %>% str_subset('USD:USD$') %>% str(max.level = 2)
  # tickers_ftx$'ZECBULL/USD'$info %>% str(max.level = 2)
  
  # cost of the fetchTickers() call in terms of rate limit is often higher than average. 
  # If you only need one ticker, fetching by a particular symbol is faster as well.
  tickers_sub = 
    if (ftx_has$fetchTickers) 
    # Like most methods of the Unified CCXT API, the last argument to 
      # # cost of the fetchTickers() call in terms of rate limit is often higher than average. 
      # If you only need one ticker, fetching by a particular symbol is faster as well.
      # fetchTickers is the params argument for overriding request parameters that are sent towards the exchange.
      ftx$fetch_tickers(list(
        'SOL/USDT', 'RAY/USDT', 'ETH/BTC', 'LTC/BTC')[1:2]),
  
  # Perputals on FTX only?
  info_tckrs_ftx = tickers_ftx %>% # head(2) %>% 
    map_df(~ .[names(.) != 'info'] ) %>% 
    type.convert(as.is = TRUE) %>% 
    mutate(datetime = datetime %>% as_datetime() )
  , 
  # FIXME: function to map from timestamp to datetime
  # info_tckrs_ftx$datetime[1:2]
  # info_tckrs_ftx$timestamp[1:2] # -1202095978
  # info_tckrs_ftx$symbol %>% str_subset('SOL')
  # Perputals on FTX?
  # info_tckrs_ftx$symbol %>% str_subset('USD:USD$')
  
  tickers_not_info = tickers_ftx %>% # head(2) %>% 
    # why is static meta data repeated with each tick?
    #   'info': { ... }, // the original JSON response from the exchange as is
    map_df(~ .[names(.) == 'info'] %>% unlist() ) %>% 
    rename_with(~ str_replace(., 'info\\.', ''), starts_with("info")) %>% 
    type.convert(as.is = TRUE) %>% 
    # mutate(datetime = datetime %>% as_datetime() ) ->
    tibble()
  ,
  future_spot_tbl = tickers_not_info %>% 
    janitor::tabyl(type) %>% 
    adorn_totals("row") %>% 
    adorn_percentages() %>%
    adorn_pct_formatting() # %>% adorn_ns()
  ,
  # tickers_not_info %>% 
  #   janitor::tabyl(enabled, type) %>% head()
  
  # NotSupported: API does not allow to fetch all prices at once with a single call to fetch_bids_asks() for now
  # fetch_bids_asks = ftx$fetch_bids_asks() ,
  
  # Perputals on FTX
  # tickers_not_info$name %>% str_subset('PERP')
  

  ### Binance ----
  tickers_binance = binance$fetch_tickers(), # ALL tickers - api restricted?
  # tickers_binance %>% names() %>% str_subset('USD:USD$')
  info_tckrs_ftx_binance = 
    tickers_binance %>% # head(2) %>% 
    map_df(~ .[names(.) != 'info'] ) %>% 
    type.convert(as.is = TRUE) %>% 
    mutate(datetime = datetime %>% as_datetime() )
  ,  

  # TODO: convert openTime closeTime to datetime
  tickers_not_info_binance = 
    tickers_binance %>% # head(2) %>% 
    # why is static meta data repeated with each tick?
    #   'info': { ... }, // the original JSON response from the exchange as is
    map_df(~ .[names(.) == 'info'] %>% unlist() ) %>% 
    rename_with(~ str_replace(., 'info\\.', ''), starts_with("info")) %>% 
    type.convert(as.is = TRUE) %>% 
    # mutate(datetime = datetime %>% as_datetime() ) ->
    tibble() %>% 
    mutate(openTime_ = (openTime/1e3) %>% anytime::anytime(x = .), .after = openTime) %>% 
    mutate(closeTime_ = (closeTime/1e3) %>% anytime::anytime(x = .), .after = closeTime)
  ,  
  tickers_not_info_binance_chk = 
    tickers_not_info_binance %>% 
    filter(openTime_ >= closeTime_) %>% nrow() %>% `==`(0) %>% 
    stopifnot('openTime_ < closeTime_ fails' = .)
  ,

  
  tar_render(intro_qmd, path = 
      c(here::here("vignettes/intro.qmd"), "./vignettes/intro.qmd")[1],
    cue = tar_cue("always"),
    quiet=TRUE,
    # which runs rmarkdown::render("report.qmd", params = list(your_param = your_target),
    #     output_format = c('github_document', 'pdf_document', 'html_document')[1])
    # output_file = "../README.md", output_format = c('github_document', 'pdf_document', 'html_document')[1])
    packages = "lubridate" , # used in yaml header of Rmd?
    error = c("stop", "continue")[1]
    # , params = list(pins_path = "pins_path") 
    ), 
  # tar_knit(intro_qmd, "./vignettes/intro.qmd", params = list(your_param = 4:1))
  # tar_render_rep(name = intro_qmd, path = "./vignettes/intro.qmd"
  #   # ?tar_render_rep - tar_target() alternative for parameterized R Markdown reports that depend on other targets. 
  #   # Parameters - data frame with one row per rendered report and one column per parameter. 
  #   # An optional output_file column may be included to set the output file path of each rendered report. 
  #   params = tibble(
  #     par = c("par_val_1", "par_val_2", "par_val_3", "par_val_4"),
  #     output_file = c("f1.html", "f2.html", "f3.html", "f4.html")
  #   ), batches = 1
  # update readme with latest data, as per fdata.
  tar_render(readme_qmd, path = "./vignettes/README.qmd",
    cue = tar_cue("always"),
    quiet=TRUE,
    # which runs rmarkdown::render("report.qmd", params = list(your_param = your_target),
    #     output_format = c('github_document', 'pdf_document', 'html_document')[1])
    # output_file = "../README.md", output_format = c('github_document', 'pdf_document', 'html_document')[1])
    packages = "lubridate" , # used in yaml header of qmd?
    error = c("stop", "continue")[1],
    params = list(pins_path = "pins_path") ) ,
  mv_readme.mdd = {
    tar_read(readme_qmd)
    system(command = 'mv -f ./vignettes/README.md  .') # ./notebooks/README_files/
  }
  
  
  
  
  # Public APIs include the following:
  # market data
  # instruments/trading pairs
  # price feeds (exchange rates)
  # order books ??? snapshots??
  # trade history
  # tickers_ftx
  # OHLC(V) for charting
  # other public endpoints
  
) # plan_ccxt

c(plan_ccxt)
