% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ftx_ohlcv.R
\name{ftx_ohlcv}
\alias{ftx_ohlcv}
\title{FTX OHLCV snapshots}
\usage{
ftx_ohlcv(
  pairs = c("BTC/USD", "USD:USD", "SOL/USD", "LUNA/USD")[1],
  origin = as.POSIXlt(Sys.time(), tz = "UTC") - 30,
  timeframe = c("15s", "1m", "5m", "15m", "1h", "4h", "1d", "3d", "1w", "2w", "1M")[1],
  limit = 2L,
  ftx = ftx
)
}
\arguments{
\item{pairs}{character vector of pairs of coins}

\item{origin}{POSIXlt (not as.POSIXct) - start datetime}

\item{timeframe}{single character vector of time steps}

\item{limit}{number of timesteps}

\item{ftx}{pointer to a ccxt exchange}
}
\value{
a tibble of ohlcv snapshots by coin, by datetime.
}
\description{
FTX OHLCV snapshots
}
\examples{
# Connection to FTX api (requires key/secret)
ftx = reticulate::import('ccxt')$ftx(
  list(
    enableRateLimit = "True",
    apiKey          = Sys.getenv('FTX_key'),
    secret          = Sys.getenv('FTX_secret'))
)
ftx_ohlcv (
    pairs = c('BTC/USD'), # pairs of coins
    origin = as.POSIXlt(Sys.time(), tz = "UTC") - 30*60, # start 30 mins ago
    timeframe = c("15s"), # 15 sec timesteps
    limit = 2L, # two timesteps
    ftx = ftx)  # FTX pointer via reticulate::import('ccxt')$ftx
}
\seealso{
medium.com/alphaimpact/how-to-link-your-ftx-com-api-keys-so-you-can-copy-trades-or-be-copied-9-simple-steps-172372888034
}
\author{
\href{mailto:john@1x2.ltd}{john@1x2.ltd}
}
