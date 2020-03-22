//@version=4
strategy("Donchin Breakout Scalper", overlay=true, slippage=20)

ch_len    = input(300,   title="Donchian Channel Length")
use_close = input(true,  title='Use CLose (instead of High Low)', type=input.bool)
resol     = input("1D",  title='Resolution', type=input.resolution)
stop_loss = input(1.0,   title="Stop loss", type=input.float)
use_iday  = input(false, title='Use intraday', type=input.bool)

end_hr    = input(15,    title='End session hour', type=input.integer)
end_min   = input(14,    title='End session minutes', type=input.integer)

ch_hi_s  = use_close ? highest(close, ch_len) : highest(high, ch_len)
ch_lo_s  = use_close ? lowest(close, ch_len) : lowest(low, ch_len)
ch_hi    = security(syminfo.tickerid, resol, ch_hi_s)
ch_lo    = security(syminfo.tickerid, resol, ch_lo_s)

// check if this candle is close of session
chk_close_time(hr, min) =>
    time_sig = (hour[0] == hr) and (minute[0] > min and minute[1] < min)
    time_sig
//

// chechk if this candle doesn't fall in close session
chk_not_close_time(hr) =>
    time_ncs = (hour[0] < hr)
    [time_ncs]
//

stop_l = (use_close) ? (close - stop_loss) : (low - stop_loss)
stop_s = (use_close) ? (close + stop_loss) : (high + stop_loss)
//stop_l = ch_hi - stop_loss
//stop_s = ch_lo + stop_loss


buy    = use_iday ? (crossover(close, ch_hi[1]) and (hour < end_hr)) : crossover(close, ch_hi[1])
sell   = use_iday ? (crossunder(close, stop_l[1]) or chk_close_time(end_hr, end_min)) : crossunder(close, stop_l[1])
short  = use_iday ? (crossunder(close, ch_lo[1]) and (hour < end_hr)) : crossunder(close, ch_lo[1])
cover  = use_iday ? (crossover(close, stop_s[1]) or chk_close_time(end_hr, end_min)) : crossover(close, stop_s[1])

strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

plot(ch_hi, color=color.green, title="HI")
plot(ch_lo, color=color.red, title="LO")
//plot(stop_l, color=color.olive, title="StopHI")
//plot(stop_s, color=color.blue, title="StopLO")
