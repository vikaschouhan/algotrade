//@version=4
study(title="RSI - orb-b", overlay=false)

///////////////////////////////////////////////////////////////////////
// Inputs
time_frame_m = input(defval='1D',  title="Resolution", options=['1m', '5m', '10m', '15m', '30m', '45m', '1h', '2h', '4h', '1D', '2D', '4D', '1W', '2W', '1M', '2M', '6M'])
time_frame_n = input(defval='1D',  title="Time Gap", options=['1m', '5m', '10m', '15m', '30m', '45m', '1h', '2h', '4h', '1D', '2D', '4D', '1W', '2W', '1M', '2M', '6M'])
post_smooth  = input(defval=false, title='Also smooth after ORB', type=input.bool)
ema_len      = input(defval=1,     title='Smooth EMA Length')
rsi_len      = input(defval=4,     title='RSI Length')

//////////////////////////////////////////////////////////////////////////
// Misc functions
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

///////////////////////////////////////////////////////////////////////////
// Main signals (ORB-B)
high_range  = valuewhen(is_newbar(time_gap), high, 0)
low_range   = valuewhen(is_newbar(time_gap), low,  0)

high_rangeL_n = security(syminfo.tickerid, time_frame, high_range)
low_rangeL_n  = security(syminfo.tickerid, time_frame, low_range)
high_rangeL_s = security(syminfo.tickerid, time_frame, ema(high_range, ema_len))
low_rangeL_s  = security(syminfo.tickerid, time_frame, ema(low_range, ema_len))

high_rangeL = high_rangeL_n
low_rangeL  = low_rangeL_n
if post_smooth
    high_rangeL := high_rangeL_s
    low_rangeL  := low_rangeL_s
//

ind_sig = avg(high_rangeL, low_rangeL)
rsi_ind  = rsi(ind_sig, rsi_len)

/////////////////////////////////////////////////////////////////////////
// Plots
plot(rsi_ind, color=color.green, linewidth=1)
