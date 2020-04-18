//@version=4
study(title="ORB-C", shorttitle="ORB-C", overlay=true)

///////////////////////////////////
/// Inputs
time_frame_m = input(defval='15m', title="Resolution", options=['1m', '5m', '10m', '15m', '30m', '45m', '1h', '2h', '4h', '1D', '2D', '4D', '1W', '2W', '1M', '2M', '6M'])
bar_lag      = input(defval=0,     title="Ignore first n bars", type=input.integer)

///////////////////////////////////
/// Functions
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
time_frame    = get_time_frame(time_frame_m)

is_newbar(res, lag) =>
    change(time(res)[lag]) != 0
//

/////////////////////////////////////////////////////////
/// Signals
high_range  = valuewhen(is_newbar('D', bar_lag), high, 0)
low_range   = valuewhen(is_newbar('D', bar_lag), low,  0)

high_rangeL  = security(syminfo.tickerid, time_frame, high_range)
low_rangeL   = security(syminfo.tickerid, time_frame, low_range)

////////////////////////////////////////////////////////
///Plots
plot(high_rangeL, color=color.green,  linewidth=2,  title='H_RL')
plot(low_rangeL,  color=color.red,    linewidth=2,  title='L_RL')
