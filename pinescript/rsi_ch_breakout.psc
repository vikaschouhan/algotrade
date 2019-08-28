//@version=3
strategy("RSI channel breakout", overlay=false)

rsi_period = input(defval=14, title="RSI Period", type=integer, minval=1, maxval=100, step=1)
donch_period = input(defval=9, title="Donch RSI Period", type=integer, minval=1, maxval=200, step=1)
//cum_rsi_smooth_per = input(2, title="Cum RSI smooth EMA period", type=integer, minval=1, maxval=100, step=1)

cum_rsi = rsi(close, rsi_period) + rsi(close, rsi_period)[1] + rsi(close, rsi_period)[2]
donch_rsi_hi = highest(cum_rsi, donch_period)
donch_rsi_lo = lowest(cum_rsi, donch_period)

buy  = cum_rsi > donch_rsi_hi[1]
sell = cum_rsi < donch_rsi_lo[1]

strategy.entry("long", strategy.long, when=buy)
strategy.entry("short", strategy.short, when=sell)

plot(cum_rsi, title="CUM RSI", color=green)
plot(donch_rsi_hi, title="CUM RSI HI", color=olive)
plot(donch_rsi_lo, title="CUM_RSI_LO", color=red)
