//@version=4
study("ATR Trailing Stoploss v1", overlay=true)

atr_period = input(defval=5,      title="ATR Period",       minval=1, maxval=500)
lb_period  = input(defval=10,     title="Loopback Period",  minval=1, maxval=500)
atr_mult   = input(defval=1.5,    title="ATR Multiplier",   minval=0.1)

ts_long    = highest(high - atr_mult*atr(atr_period), lb_period)
ts_short   = lowest(low + atr_mult*atr(atr_period), lb_period)

plot(ts_long,   color=color.green, linewidth=1, style=plot.style_stepline,  title="ATR Trailing Stoploss")
plot(ts_short,  color=color.red,   linewidth=1, style=plot.style_stepline,  title="ATR Trailing Stoploss")
