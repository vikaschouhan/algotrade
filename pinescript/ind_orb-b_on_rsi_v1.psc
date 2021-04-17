//@version=4
study("ORB-B RSI v1")

//////////////////////////////////////////////////////////////////////
// Inputs
time_frame_m = input(defval='15m', title="Resolution", options=['1m', '5m', '10m', '15m', '30m', '45m', '1h', '2h', '4h', '1D', '2D', '4D', '1W', '2W', '1M', '2M', '6M'])
time_frame_n = input(defval='1D',  title="Time Gap", options=['1m', '5m', '10m', '15m', '30m', '45m', '1h', '2h', '4h', '1D', '2D', '4D', '1W', '2W', '1M', '2M', '6M'])
post_smooth  = input(defval=false, title='Also smooth after ORB', type=input.bool)
rsi_len      = input(defval=4,     title='RSI Length')
rsi_src      = input(defval=open,  title='RSI Source', type=input.source)
rsi_dlen     = input(defval=1,     title='RSI Donchian Length', type=input.integer)
ema_len      = input(defval=1,     title='EMA Length for ORB smooth', type=input.integer)

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

///////////////////////////////////////////////////////////////////////////
// Main signals (ORB-B)

// Get RSI hi/lo bands
rsi_sig     = rsi(rsi_src, rsi_len)
rsi_hi      = highest(rsi_sig, rsi_dlen)
rsi_lo      = lowest(rsi_sig, rsi_dlen)

// Calculate global hi/lo range based on morning openings
high_range  = valuewhen(is_newbar(time_gap), rsi_hi, 0)
low_range   = valuewhen(is_newbar(time_gap), rsi_lo,  0)

// Calculate time framed based hi/lo ranges
high_rangeL_n = security(syminfo.tickerid, time_frame, high_range)
low_rangeL_n  = security(syminfo.tickerid, time_frame, low_range)
high_rangeL_s = security(syminfo.tickerid, time_frame, ema(high_range, ema_len))
low_rangeL_s  = security(syminfo.tickerid, time_frame, ema(low_range, ema_len))
rsi_signal    = security(syminfo.tickerid, time_frame, rsi_sig)

// Do any ema smoothing (if required)
high_rangeL = high_rangeL_n
low_rangeL  = low_rangeL_n
if post_smooth
    high_rangeL := high_rangeL_s
    low_rangeL  := low_rangeL_s
//

/////////////////////////////////////////////////////////////////////////////
// Plots
plot(high_rangeL, color=color.green, title='HI+')
plot(low_rangeL,  color=color.red, title='LO+')
plot(rsi_signal,  color=color.blue, title='RSI')
