//@version=4
strategy("CPR Pivot Intraday Scalper based on Level Crossover", overlay=true)

time_frame     = input("D",       title='Time frame', type=input.resolution)
tolerance      = input(5,         title='Tolerance',  type=input.integer)
stop_loss      = input(1.0,       title='Stop loss',  type=input.float)
end_hr         = input(15,        title='End hour',   type=input.integer)
end_min        = input(14,        title='End minute', type=input.integer)
use_sperc      = input(false,     title='Stop loss & tolerance are in %centage(s)', type=input.bool)
use_tstop      = input(true,      title='Use trailing stop', type=input.bool)
level_type     = input('r1-s1',   title='Level type', type=input.string, options=['r1-s1', 'r2-s2', 'h-l'])

is_newbar(res) =>
    change(time(res)) != 0
//

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


pivot_cpr(time_frame) =>
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
    
    [pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level, prev_high, prev_low]
//

[pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level, prev_high, prev_low] = pivot_cpr(time_frame)

r_level = r1_level
s_level = s1_level
if level_type == 'r2-s2'
    r_level := r2_level
    s_level := s2_level
//
if level_type == 'h-l'
    r_level := prev_high
    s_level := prev_low
//

stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)
if use_tstop
    stop_l := use_sperc ? close*(1-stop_loss/100.0) : (close - stop_loss)
    stop_s := use_sperc ? close*(1+stop_loss/100.0) :  (close + stop_loss)
//

buy    = crossover(close, r_level + tolerance) and (hour < end_hr)
sell   = crossunder(close, stop_l[1]) or chk_close_time(end_hr, end_min)
short  = crossunder(close, s_level - tolerance) and (hour < end_hr)
cover  = crossover(close, stop_s[1]) or chk_close_time(end_hr, end_min)

strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

plot(r_level, style=plot.style_circles, linewidth=2, color=color.green, title="R1")
plot(s_level, style=plot.style_circles, linewidth=2, color=color.red,   title="S1")
