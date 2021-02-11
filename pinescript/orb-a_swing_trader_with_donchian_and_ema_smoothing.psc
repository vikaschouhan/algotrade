//@version=4
strategy(title="ORB-A swingtrader with Donchian and EMA as smoothing signals", overlay=true)

tolerance     = input(defval=0.0,        title="Tolerance", type=input.float)
time_frame_m  = input(defval='1D',       title="Resolution", options=['1m', '5m', '10m', '15m', '30m', '45m', '1h', '2h', '4h', '1D', '2D', '4D', '1W', '2W', '1M', '2M', '6M'])
ema_len       = input(defval=1,          title="EMA Length", type=input.integer)
donch_len     = input(defval=2,          title="Donchian Length", type=input.integer)
stop_loss     = input(1.0,               title="Stop loss", type=input.float)
use_sperc     = input(true,              title='Stop loss & tolerance are in %centage(s)', type=input.bool)
use_tstop     = input(true,              title='Use trailing stop', type=input.bool)

////////////////////////////////////////
// MISC FUNTIONS
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


is_newbar(res) =>
    change(time(res)) != 0
//

//////////////////////////////////////////////////
// High Low band calculation
high_range  = valuewhen(is_newbar('D'), high, 0)
low_range   = valuewhen(is_newbar('D'), low,  0)

high_rangeL = security(syminfo.tickerid, time_frame, highest(ema(high_range, ema_len), donch_len))
low_rangeL  = security(syminfo.tickerid, time_frame, lowest(ema(low_range, ema_len), donch_len))

tolbu       = use_sperc ? high_rangeL*(1 + tolerance/100.0) : (high_rangeL + tolerance)
tolbl       = use_sperc ? low_rangeL*(1 - tolerance/100.0) : (low_rangeL-tolerance)

///////////////////////////////////////////////////
// Stop Loss calculation
stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)
if use_tstop
    stop_l := use_sperc ? close*(1-stop_loss/100.0) : (close - stop_loss)
    stop_s := use_sperc ? close*(1+stop_loss/100.0) :  (close + stop_loss)
//

//////////////////////////////////////////////////////////
// Signals calculation
buy    = crossover(close, tolbu)
sell   = crossunder(close, stop_l[1])
short  = crossunder(close, tolbl)
cover  = crossover(close, stop_s[1])

////////////////////////////////////////////////
// Strategy execution cmds
strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

//////////////////////////////////////////////////////
// Plotting functions
plot(high_rangeL, color=color.green, linewidth=2) 
plot(low_rangeL,  color=color.red, linewidth=2) 
