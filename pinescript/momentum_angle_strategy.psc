//@version=3
strategy("Momentum Str1", overlay=true, slippage=20)

ema_len  = input(9, type=integer, title="EMA Length")
moms_thr = input(0.01, type=float, title="Mom Slope Threshold", step=0.01)
slope_p  = input(2, type=integer, title="Slope Lookback period")

ema_t = ema(close, ema_len)

buy    = (ema_t - ema_t[slope_p]) > moms_thr
selli  = (ema_t - ema_t[slope_p]) < moms_thr
sell   = (ema_t - ema_t[slope_p]) < -moms_thr
buyi   = (ema_t - ema_t[slope_p]) > -moms_thr

strategy.entry("L", strategy.long, when = buy)
strategy.exit("L", when = selli)
strategy.entry("S", strategy.short, when = sell)
strategy.exit("S", when = buyi)

plot(ema_t, color=red)
