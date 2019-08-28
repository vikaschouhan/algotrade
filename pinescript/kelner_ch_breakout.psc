//@version=3
strategy("Keltner Breakout", overlay=true, slippage=20)

ema_len = input(200,  type=integer, title='EMA Length')
k_len   = input(20,   type=integer, title='K Length')
mult    = input(0.5,  type=float, title='Range multiplier', step=0.01)
ema_len2 = input(9,   type=integer, title='Price Smooth Length')

src     = ema(close, ema_len)
src2    = ema(close, ema_len2)
range   = atr(14) //ema(high, ema_len) - ema(low, ema_len)

//ema_t   = ema(src, k_len)
//range_t = ema(range, k_len)
upper   = src + range * mult
lower   = src - range * mult

buy     = crossover(src2, upper)
selli   = crossunder(src2, upper)
sell    = crossunder(src2, lower)
buyi    = crossover(src2, lower)

strategy.entry("L", strategy.long, when = buy)
strategy.close("L", when = selli)
strategy.entry("S", strategy.short, when = sell)
strategy.close("S", when = buyi)

plot(src, color=blue)
plot(src2, color=olive)
plot(upper, color=green)
plot(lower, color=red)
