//@version=4
strategy(title="ORB-A swing with HL-avg smoothing", overlay=true)

////////////////////////////////////////////////////////////
// Inputs
tolerance    = input(defval=0.0, title="Tolerance", type=input.float)
time_frame_m = input(defval='1D', title="Resolution", options=['1m', '5m', '10m', '15m', '30m', '45m', '1h', '2h', '4h', '1D', '2D', '4D', '1W', '2W', '1M', '2M', '6M'])
time_frame_n = input(defval='1D', title="Time Gap", options=['1m', '5m', '10m', '15m', '30m', '45m', '1h', '2h', '4h', '1D', '2D', '4D', '1W', '2W', '1M', '2M', '6M'])
stop_loss    = input(1.0,   title="Stop loss", type=input.float)
use_sperc    = input(false, title='Stop loss & tolerance are in %centage(s)', type=input.bool)
use_iday     = input(false, title='Use intraday', type=input.bool)
use_tstop    = input(true,  title='Use trailing stop', type=input.bool)
end_hr       = input(15,    title='End session hour', type=input.integer)
end_min      = input(14,    title='End session minutes', type=input.integer)
ema_len      = input(1,     title='Smooth EMA Length', type=input.integer)

////////////////////////////////////////////////////////////////////
// Misc funcs
get_time_frame(tf) =>
    (tf == '1m')  ? "1"
  : (tf == '5m')  ? "5"
  : (tf == '10m') ? "10"
  : (tf == '15m') ? "15"
  : (tf == '30m') ? "30"
  : (tf == '45m') ? "45"
  : (tf == '1h')  ? "60"
  : (tf == '2h')  ? "120"
  : (tf == '4h')  ? "240"
  : (tf == '1D')  ? "D"
  : (tf == '2D')  ? "2D"
  : (tf == '4D')  ? "4D"
  : (tf == '1W')  ? "W"
  : (tf == '2W')  ? "2W"
  : (tf == '1M')  ? "M"
  : (tf == '2M')  ? "2M"
  : (tf == '6M')  ? "6M"
  : "wrong resolution"
//
time_frame = get_time_frame(time_frame_m)
time_gap   = get_time_frame(time_frame_n)

is_newbar(res) =>
    change(time(res)) != 0
//

// check if this candle is close of session
chk_close_time(hr, min) =>
    time_sig = (hour[0] == hr) and (minute[0] > min and minute[1] <= min)
    time_sig
//

// chechk if this candle doesn't fall in close session
chk_not_close_time(hr) =>
    time_ncs = (hour[0] < hr)
    [time_ncs]
//

////////////////////////////////////////////////////////
// Calculate indicators
high_range  = valuewhen(is_newbar(time_gap), high, 0)
low_range   = valuewhen(is_newbar(time_gap), low,  0)

high_rangeL = security(syminfo.tickerid, time_frame, ema(high_range, ema_len))
low_rangeL  = security(syminfo.tickerid, time_frame, ema(low_range, ema_len))
basisL      = avg(high_rangeL, low_rangeL)

///////////////////////////////////////////////////////////
// Calculate stops
stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)
if use_tstop
    stop_l := use_sperc ? close*(1-stop_loss/100.0) : (close - stop_loss)
    stop_s := use_sperc ? close*(1+stop_loss/100.0) :  (close + stop_loss)
//

/////////////////////////////////////////////////////////
// Calculate signals
tolbu  = use_sperc ? basisL*(1+tolerance/100.0) : (high_rangeL + tolerance)
tolbl  = use_sperc ? basisL*(1-tolerance/100.0) : (low_rangeL-tolerance)

buy    = use_iday ? (crossover(close, tolbu) and (hour < end_hr)) : crossover(close, tolbu)
sell   = use_iday ? (crossunder(close, stop_l[1]) or chk_close_time(end_hr, end_min)) : crossunder(close, stop_l[1])
short  = use_iday ? (crossunder(close, tolbl) and (hour < end_hr)) : crossunder(close, tolbl)
cover  = use_iday ? (crossover(close, stop_s[1]) or chk_close_time(end_hr, end_min)) : crossover(close, stop_s[1])

//////////////////////////////////////////////////////////
// Execute orders
strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

//////////////////////////////////////////////////////////
// Plots
plot(basisL, color=color.blue, linewidth=2)
