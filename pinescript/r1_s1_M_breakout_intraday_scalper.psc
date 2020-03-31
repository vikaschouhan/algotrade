//@version=4
strategy("M Pivot Intraday Scalper based on Level Crossover", overlay=true)

time_frame     = input("D",       title='Time frame', type=input.resolution)
tolerance      = input(5,         title='Tolerance',  type=input.integer)
stop_loss      = input(1.0,       title='Stop loss',  type=input.float)
end_hr         = input(15,        title='End hour',   type=input.integer)
end_min        = input(14,        title='End minute', type=input.integer)
use_sperc      = input(false,     title='Stop loss & tolerance are in %centage(s)', type=input.bool)
use_tstop      = input(true,      title='Use trailing stop', type=input.bool)
level_type     = input('r1-s1',   title='Level type', type=input.string, options=['r1-s1', 'h-l'])
m_factor       = input(1.0,       title='M factor', type=input.float, step=0.01)


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


pivot_M(time_frame) =>
    prev_close     = security(syminfo.tickerid, time_frame, close[1], lookahead=true)
    prev_open      = security(syminfo.tickerid, time_frame, open[1], lookahead=true)
    prev_high      = security(syminfo.tickerid, time_frame, high[1], lookahead=true)
    prev_low       = security(syminfo.tickerid, time_frame, low[1], lookahead=true)

    //X = (prev_close > prev_open) ? (2*prev_high + prev_low + prev_close) : ((prev_close < prev_open) ? (prev_high + 2*prev_low + prev_close) : (prev_high + prev_low + 2*prev_close))
    X  = (prev_high + prev_low + prev_close)/3
    R1 = (X) + m_factor*(prev_high - prev_low)
    S1 = (X) - m_factor*(prev_high - prev_low)
    
    [R1, S1, prev_high, prev_low]
//

[r_level, s_level, prev_high, prev_low] = pivot_M(time_frame)


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

up_rng = use_sperc ? r_level*(1+tolerance/100.0) : (r_level + tolerance)
dn_rng = use_sperc ? s_level*(1-tolerance/100.0) : (s_level - tolerance)

buy    = crossover(close, up_rng) and (hour < end_hr)
sell   = crossunder(close, stop_l[1]) or chk_close_time(end_hr, end_min)
short  = crossunder(close, dn_rng) and (hour < end_hr)
cover  = crossover(close, stop_s[1]) or chk_close_time(end_hr, end_min)

strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

plot(r_level, style=plot.style_circles, linewidth=2, color=color.green, title="R1")
plot(s_level, style=plot.style_circles, linewidth=2, color=color.red,   title="S1")
