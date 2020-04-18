//@version=4
study(title="ORB-A with pivots", shorttitle="ORB-A-P", overlay=true)

///////////////////////////////////
/// Inputs
time_frame_m = input(defval='15m', title="Resolution", options=['1m', '5m', '10m', '15m', '30m', '45m', '1h', '2h', '4h', '1D', '2D', '4D', '1W', '2W', '1M', '2M', '6M'])

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
time_frame = get_time_frame(time_frame_m)

is_newbar(res) =>
    change(time(res)) != 0
//

_pivots(prev_close, prev_open, prev_high, prev_low) =>
    pi_level       = (prev_high + prev_low + prev_close)/3
    bc_level       = (prev_high + prev_low)/2
    tc_level       = (pi_level - bc_level) + pi_level
    r1_level       = pi_level * 2 - prev_low
    s1_level       = pi_level * 2 - prev_high
    r2_level       = (pi_level - s1_level) + r1_level
    s2_level       = pi_level - (r1_level - s1_level)
    r3_level       = prev_high + 2*(pi_level - prev_low)
    s3_level       = prev_low - 2*(prev_high - pi_level)

    [pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level, r3_level, s3_level]
//

/////////////////////////////////////////////////////////
/// Signals
high_range  = valuewhen(is_newbar('D'), high, 0)
low_range   = valuewhen(is_newbar('D'), low,  0)
close_range = valuewhen(is_newbar('D'), close, 0)
open_range  = valuewhen(is_newbar('D'), open, 0) 

high_rangeL  = security(syminfo.tickerid, time_frame, high_range)
low_rangeL   = security(syminfo.tickerid, time_frame, low_range)
close_rangeL = security(syminfo.tickerid, time_frame, close_range)
open_rangeL  = security(syminfo.tickerid, time_frame, open_range)
[pi_rl, tc_rl, bc_rl, r1_rl, s1_rl, r2_rl, s2_rl, r3_rl, s3_rl] = _pivots(close_rangeL, open_rangeL, high_rangeL, low_rangeL)

////////////////////////////////////////////////////////
///Plots
plot(high_rangeL, color=color.green,  linewidth=2,  title='H_RL')
plot(low_rangeL,  color=color.red,    linewidth=2,  title='L_RL')
plot(r1_rl,       color=color.olive,  linewidth=1,  title='R1_RL')
plot(s1_rl,       color=color.blue,   linewidth=1,  title='S1_RL')
plot(r2_rl,       color=color.orange, linewidth=1,  title='R2_RL')
plot(s2_rl,       color=color.navy,   linewidth=1,  title='S2_RL')
plot(r3_rl,       color=color.orange, linewidth=1,  title='R3_RL')
plot(s3_rl,       color=color.navy,   linewidth=1,  title='S3_RL')
