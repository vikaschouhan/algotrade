//@version=4
strategy("Donchin Breakout Scalper", overlay=true, slippage=20)

ch_len    = input(300,  title="Donchian Channel Length")
use_close = input(true, title='Use CLose (instead of High Low)', type=input.bool)
resol     = input("1D", title='Resolution', type=input.resolution)
stop_loss = input(1.0,  title="Stop loss", type=input.float)

ch_hi_s  = use_close ? highest(close, ch_len) : highest(high, ch_len)
ch_lo_s  = use_close ? lowest(close, ch_len) : lowest(low, ch_len)
ch_hi    = security(syminfo.tickerid, resol, ch_hi_s)
ch_lo    = security(syminfo.tickerid, resol, ch_lo_s)

stop_l = (use_close) ? (close - stop_loss) : (low - stop_loss)
stop_s = (use_close) ? (close + stop_loss) : (high + stop_loss)
//stop_l = ch_hi - stop_loss
//stop_s = ch_lo + stop_loss

buy    = crossover(close, ch_hi[1])
sell   = crossunder(close, stop_l[1])
short  = crossunder(close, ch_lo[1])
cover  = crossover(close, stop_s[1])

strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

plot(ch_hi, color=color.green, title="HI")
plot(ch_lo, color=color.red, title="LO")
plot(stop_l, color=color.olive, title="StopHI")
plot(stop_s, color=color.blue, title="StopLO")
