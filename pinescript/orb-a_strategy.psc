//@version=4
strategy(title="ORB-A strategy", shorttitle="ORB-A strategy", overlay=true)

tolerance = input(defval=0, title="Tolerance")
time_frame_m = input(defval='1D', title="Resolution", options=['1m', '5m', '10m', '15m', '30m', '45m', '1h', '2h', '4h', '1D', '2D', '4D', '1W', '2W', '1M', '2M', '6M'])

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

high_range  = valuewhen(is_newbar('D'), high, 0)
low_range   = valuewhen(is_newbar('D'), low,  0)

high_rangeL = security(syminfo.tickerid, time_frame, high_range)
low_rangeL  = security(syminfo.tickerid, time_frame, low_range)
//range       = (high_rangeL - low_rangeL)/low_rangeL

buy  = crossover(close, high_rangeL+tolerance)
sell = crossunder(close - tolerance, low_rangeL-tolerance)

strategy.entry("L", strategy.long, when=buy)
strategy.entry("S", strategy.short, when=sell)

//plotshape(range < 0.01, style=shape.circle, location=location.belowbar, color=color.red)
plot(high_rangeL, color=color.green, linewidth=2) 
plot(low_rangeL,  color=color.red, linewidth=2) 

