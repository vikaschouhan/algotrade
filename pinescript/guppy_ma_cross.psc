strategy(title="Guppy MA", shorttitle="Guppy MA", slippage=20)

guppy_ema_len1 = input(defval=2, title="Guppy EMA pre-smooth length", minval=1)
guppy_ema_len2 = input(defval=5, title="Guppy EMA post-smooth length", minval=1)

// === INPUT BACKTEST RANGE ===
FromMonth = input(defval = 6, title = "From Month", minval = 1, maxval = 12)
FromDay   = input(defval = 1, title = "From Day", minval = 1, maxval = 31)
FromYear  = input(defval = 2017, title = "From Year")

start     = timestamp(FromYear, FromMonth, FromDay, 00, 00)  // backtest start window
finish    = time        // backtest finish window

window()  => time >= start and time <= finish ? true : false

guppy0 = ema(close, 3)
guppy1 = ema(close, 5)
guppy2 = ema(close, 8)
guppy3 = ema(close, 12)
guppy4 = ema(close, 15)

g1 = (guppy0+guppy1+guppy2+guppy3+guppy4)/5

guppy5 = ema(close, 30)
guppy6 = ema(close, 35)
guppy7 = ema(close, 40)
guppy8 = ema(close, 45)
guppy9 = ema(close, 50)

g2 = (guppy5+guppy6+guppy7+guppy8+guppy9)/5

fast_guppy = ema(g1 - g2, guppy_ema_len1)
slow_guppy = ema(fast_guppy, guppy_ema_len2)

buy  = crossover(fast_guppy, slow_guppy) //close_h > upper[lag+1]
sell = crossunder(fast_guppy, slow_guppy) //close_h < lower[lag+1]

// === EXECUTION ===
strategy.entry("L", strategy.long, when = window() and buy)  // buy long when "within window of time" AND crossover
strategy.entry("S", strategy.short, when = window() and sell)

plot(fast_guppy, style=line, linewidth=1, color=red, offset=1)
plot(slow_guppy, style=line, linewidth=1, color=green, offset=1)
