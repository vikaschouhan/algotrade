//@version=3 
strategy("vidya crossover", shorttitle = "vidya crossover", overlay=true)
 
// === INPUT SMA === 
fa_period  = input(defval = 9, type = integer, title = "Fast MA", minval = 1, step = 1)
sa_period  = input(defval = 4, type = integer, title = "Slow MA", minval = 1, step = 1)
 
// === INPUT BACKTEST RANGE ===
FromMonth = input(defval = 6, title = "From Month", minval = 1, maxval = 12)
FromDay   = input(defval = 1, title = "From Day", minval = 1, maxval = 31)
FromYear  = input(defval = 2017, title = "From Year")

// === FUNCTION EXAMPLE ===
start     = timestamp(FromYear, FromMonth, FromDay, 00, 00)  // backtest start window
finish    = time        // backtest finish window
window()  => time >= start and time <= finish ? true : false // create function "within window of time"

// Chande Momentum Oscillator
f1(m) => m >= 0.0 ? m : 0.0
f2(m) => m >= 0.0 ? 0.0 : -m
vidya(src, length) =>
    diff    = change(src)
    upSum   = sum(f1(diff), length)
    downSum = sum(f2(diff), length)
 
    cmo     = (upSum - downSum) / (upSum + downSum)
 
    factor  = (2 / (length + 1))
 
    ind     = 0.0
    ind     := src * factor * abs(cmo) + nz(ind[1]) * (1 - factor * abs(cmo))

fast_ma_line  = vidya(close, fa_period)
slow_ma_line  = vidya(fast_ma_line, sa_period)

buy  = crossover(fast_ma_line, slow_ma_line)
sell = crossunder(fast_ma_line, slow_ma_line)

// === EXECUTION ===
strategy.entry("L", strategy.long, when = window() and buy)  // buy long when "within window of time" AND crossover
//strategy.close("L", when = window() and selli)            // sell long when "within window of time" AND crossunder
strategy.entry("S", strategy.short, when = window() and sell)
//strategy.close("S", when = window() and buyi)

plot(fast_ma_line, title = 'FastMA',   color = red,  linewidth = 1, style = line)  // plot FastMA
plot(slow_ma_line, title = 'SlowMA', color = blue, linewidth = 1, style = line)
