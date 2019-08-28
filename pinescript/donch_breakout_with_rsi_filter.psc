//@version=3
strategy('donch channel breakout with RSI filter', overlay=true, slippage=20)

ch_wi    = input(50, type=integer, title='channel width')
rsi_len  = input(14, type=integer, title='rsi len')
rsi_ema  = input(3,  type=integer, title='rsi smooth period')
rsi_sen  = input(false, type=bool, title='rsi smooth enable')
rsi_hi   = input(70, type=float, title='rsi high', minval=10, maxval=90)
rsi_lo   = input(30, type=float, title='rsi low', minval=10, maxval=90)

hhv      = highest(ch_wi)
llv      = lowest(ch_wi)
bas      = avg(hhv, llv)

rsi_t = if rsi_sen
    ema(rsi(close, rsi_len), rsi_ema)
else
    rsi(close, rsi_len)
//

//tr_stop_long   = hhv * (1 - sl_inp)
//tr_stop_short  = llv * (1 + sl_inp)

buy    = close > hhv[1] and rsi_t > rsi_hi
sell   = close < llv[1] and rsi_t < rsi_lo
selli  = close < llv[1]
buyi   = close > hhv[1]

strategy.entry("long", strategy.long, when = buy)
strategy.close("long", when = selli)
strategy.entry("short", strategy.short, when = sell)
strategy.close("short", when = buyi)

plot(hhv)
plot(llv)
