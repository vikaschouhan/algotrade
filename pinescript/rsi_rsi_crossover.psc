//@version=3
strategy(title="RSI - RSI Crossover", shorttitle="RSI - RSI Crossover", overlay=false)
 
//res   = input("15", type=resolution)
rsi_len   = input(30, type=integer, title="RSI Length")
ema_len1  = input(10, type=integer, title="RSI pre-smooth EMA Length")
ema_len2  = input(10, type=integer, title="RSI post-smooth EMA Length")

// === INPUT BACKTEST RANGE ===
FromMonth = input(defval = 6, title = "From Month", minval = 1, maxval = 12)
FromDay   = input(defval = 1, title = "From Day", minval = 1, maxval = 31)
FromYear  = input(defval = 2017, title = "From Year")

// === FUNCTION EXAMPLE ===
start     = timestamp(FromYear, FromMonth, FromDay, 00, 00)  // backtest start window
finish    = time        // backtest finish window
window()  => time >= start and time <= finish ? true : false // create function "within window of time"

ema_sig0  = ema(close, ema_len1)
rsi_sig   = rsi(ema_sig0, rsi_len)
rsi_sig_m = ema(rsi_sig, ema_len2)

buy   = crossover(rsi_sig, rsi_sig_m)
sell  = crossunder(rsi_sig, rsi_sig_m)
 
strategy.entry("L", strategy.long, when = window() and buy)
//strategy.close("L", when = selli)
strategy.entry("S", strategy.short, when = window() and sell)
//strategy.close("S", when = buyi)
 
plot(rsi_sig, color=red, linewidth=2)
plot(rsi_sig_m, color=green, linewidth=1)
