//@version=4
study("Pivot Points Flexible", overlay=true)

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


cpr(time_frame) =>
    prev_close     = security(syminfo.tickerid, time_frame, close[1], lookahead=true)
    prev_open      = security(syminfo.tickerid, time_frame, open[1], lookahead=true)
    prev_high      = security(syminfo.tickerid, time_frame, high[1], lookahead=true)
    prev_low       = security(syminfo.tickerid, time_frame, low[1], lookahead=true)

    pi_level       = (prev_high + prev_low + prev_close)/3
    bc_level       = (prev_high + prev_low)/2
    tc_level       = (pi_level - bc_level) + pi_level
    r1_level       = pi_level * 2 - prev_low
    s1_level       = pi_level * 2 - prev_high
    r2_level       = (pi_level - s1_level) + r1_level
    s2_level       = pi_level - (r1_level - s1_level)
    
    [pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level]
//

[pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level] = cpr(time_frame)

plot(pi_level, style=plot.style_circles, linewidth=2, color=color.black, title="PI")
plot(bc_level, style=plot.style_circles, linewidth=2, color=color.blue,  title="BC")
plot(tc_level, style=plot.style_circles, linewidth=2, color=color.blue,  title="TC")
plot(r1_level, style=plot.style_circles, linewidth=2, color=color.green, title="R1")
plot(s1_level, style=plot.style_circles, linewidth=2, color=color.red,   title="S1")
plot(r2_level, style=plot.style_circles, linewidth=1, color=color.orange, title="R2")
plot(s2_level, style=plot.style_circles, linewidth=1, color=color.maroon, title="S2")
