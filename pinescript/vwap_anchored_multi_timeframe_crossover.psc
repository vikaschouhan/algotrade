//@version=4
strategy("VWAP MTF crossover", overlay=true)

time_frame   = input(defval="W", type=input.resolution, title="Time frame")
tolerance    = input(1.0,        type=input.float, title="Tolerance")
stop_loss    = input(1.0,        type=input.float, title="Stop loss")
use_sperc    = input(false,      type=input.bool, title='Tolerance and stop loss in %centage(s)')
use_iday     = input(false,      type=input.bool, title='Use intraday')
end_hr       = input(15,         type=input.integer, title='End session hour')
end_min      = input(14,         type=input.integer, title='End session minutes')
use_tstop    = input(true,       title='Use trailing stop', type=input.bool)

start_time   = security(syminfo.tickerid, time_frame, time)
new_session  = iff(change(start_time), 1, 0)

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


//------------------------------------------------
vwap_sum_fn() =>
    vwap_sum = 0.0
    vwap_sum := (new_session == 1) ? (hl2*volume) : (vwap_sum[1]+hl2*volume)
    vwap_sum
//
vol_sum_fn() =>
    vol_sum = 0.0
    vol_sum := (new_session == 1) ? volume : (vol_sum[1]+volume)
    vol_sum
//

vwap_sig = vwap_sum_fn()/vol_sum_fn()

vwap_sl = use_sperc ? vwap_sig*(1+tolerance/100.0) : (vwap_sig+tolerance)
vwap_ss = use_sperc ? vwap_sig*(1-tolerance/100.0) : (vwap_sig-tolerance)

stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)
if use_tstop
    stop_lt = use_sperc ? close*(1-stop_loss/100.0) : (close - stop_loss)
    stop_st = use_sperc ? close*(1+stop_loss/100.0) :  (close + stop_loss)
    stop_l  := stop_lt //max(stop_l, stop_lt)
    stop_s  := stop_st //min(stop_s, stop_st)
//

buy    = use_iday ? (crossover(close, vwap_sl) and (hour < end_hr)) : crossover(close, vwap_sl)
sell   = use_iday ? (crossunder(close, stop_l[1]) or chk_close_time(end_hr, end_min)) : crossunder(close, stop_l[1])
short  = use_iday ? (crossunder(close, vwap_ss) and (hour < end_hr)) : crossunder(close, vwap_ss)
cover  = use_iday ? (crossover(close, stop_s[1]) or chk_close_time(end_hr, end_min)) : crossover(close, stop_s[1])

strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

plot(vwap_sig, title="VWAP", color=color.blue)
