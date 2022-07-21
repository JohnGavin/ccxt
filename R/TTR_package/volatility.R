# https://github.com/TommasoBelluzzo/HistoricalVolatility/issues/2
# install.packages("TTR")
# https://www.rdocumentation.org/packages/TTR/versions/0.23-3/topics/volatility
# 
library(TTR)

data(ttrc)
ohlc <- ttrc[,c("Open","High","Low","Close")]
vClose <- volatility(ohlc, calc="close")
vClose0 <- volatility(ohlc, calc="close", mean0=TRUE)
vGK <- volatility(ohlc, calc="garman")
vParkinson <- volatility(ohlc, calc="parkinson")
vRS <- volatility(ohlc, calc="rogers")


yz_vol <- TTR::volatility(ohlc, N = 252, calc = "yang.zhang")
yz_vol[11:12]
