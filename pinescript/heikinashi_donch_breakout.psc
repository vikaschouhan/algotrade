strategy(title="Donchian Heikinashi", shorttitle="Donchian Heikinashi", overlay=true, slippage=20)

length  = input(20, minval=1, title="Channel Length")
lag     = input(0,  minval=0, title ="Lag")

// === INPUT BACKTEST RANGE ===
FromMonth = input(defval = 6, title = "From Month", minval = 1, maxval = 12)
FromDay   = input(defval = 1, title = "From Day", minval = 1, maxval = 31)
FromYear  = input(defval = 2017, title = "From Year")

start     = timestamp(FromYear, FromMonth, FromDay, 00, 00)  // backtest start window
finish    = time        // backtest finish window

window()  => time >= start and time <= finish ? true : false // create function "within window of time"

close_h = security(heikinashi(tickerid), period, close)
high_h  = security(heikinashi(tickerid), period, high)
low_h   = security(heikinashi(tickerid), period, low)

upper = highest(high_h, length)
lower = lowest(low_h, length)
basis = avg(upper, lower)

buy  = close_h > upper[lag+1]
sell = close_h < lower[lag+1]

// === EXECUTION ===
strategy.entry("L", strategy.long, when = window() and buy)  // buy long when "within window of time" AND crossover
//strategy.close("L", when = window() and sell)                // sell long when "within window of time" AND crossunder
strategy.entry("S", strategy.short, when = window() and sell)
//strategy.close("S", when = window() and buy)

plot(lower, style=line, linewidth=1, color=red, offset=1)
plot(upper, style=line, linewidth=1, color=green, offset=1)
plot(basis, color=black, style=line, linewidth=1, title="Mid-Line Average")
