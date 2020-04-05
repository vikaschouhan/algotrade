//@version=4
strategy("r1-s1 breakout intraday scalper", overlay=true)

time_frame     = input("D",               type=input.resolution)
tolerance      = input(defval=0.0,        type=input.float)
pivot_type     = input(defval="r1-s1",    type=input.string, options=["r1-s1", "r2-s2", "h-l"])
stop_loss      = input(defval=1.0,        title="Stop loss", type=input.float)
use_sperc      = input(defval=false,      title='Stop loss & tolerance are in %centage(s)', type=input.bool)
use_iday       = input(defval=false,      title='Use intraday', type=input.bool)
use_tstop      = input(defval=true,       title='Use trailing stop', type=input.bool)
end_hr         = input(defval=15,         title='End session hour', type=input.integer)
end_min        = input(defval=14,         title='End session minutes', type=input.integer)
use_stops      = input(defval=false,      title='Use Stop loss', type=input.bool)

///////////////////////////////
/// Functions misc
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


/////////////////////////////////////
/// Standard pivot calculation
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

[pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level, hi_level, lo_level] = pivot_cpr(time_frame)

//////////////////////////////////
/// Select R and S levels according to passed options
r_level  = r1_level
s_level  = s1_level
if pivot_type == "r1-s1"
    r_level := r1_level
    s_level := s1_level
//
if pivot_type == "r2-s2"
    r_level := r2_level
    s_level := s2_level
//
if pivot_type == "h-l"
    r_level := hi_level
    s_level := lo_level
//

/////////////////////////////////////
/// Calculate stops
stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)
if use_tstop
    stop_l := use_sperc ? close*(1-stop_loss/100.0) : (close-stop_loss)
    stop_s := use_sperc ? close*(1+stop_loss/100.0) : (close+stop_loss)
//

//////////////////////////////////////
/// Calculate actual levels after adjusting for tolerance
tolbu  = use_sperc ? r_level*(1+tolerance/100.0) : (r_level+tolerance)
tolbl  = use_sperc ? s_level*(1-tolerance/100.0) : (s_level-tolerance)

////////////////////////////////////////
/// Calculate position signals
buy_sig_m      = crossover(close, tolbu)
short_sig_m    = crossunder(close, tolbl)
sell_sig_m     = false
cover_sig_m    = false
if use_stops
    sell_sig_m   := crossunder(close, stop_l[1])
    cover_sig_m  := crossover(close, stop_s[1])
else
    sell_sig_m   := crossunder(close, tolbl)
    cover_sig_m  := crossover(close, tolbu)
//

buy    = use_iday ? (buy_sig_m and (hour < end_hr)) : buy_sig_m
sell   = use_iday ? (sell_sig_m or chk_close_time(end_hr, end_min)) : sell_sig_m
short  = use_iday ? (short_sig_m and (hour < end_hr)) : short_sig_m
cover  = use_iday ? (cover_sig_m or chk_close_time(end_hr, end_min)) : cover_sig_m

/////////////////////////////////////////
/// Execute signals
strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

/////////////////////////////////////////
/// Plot primary signals
plot(r_level, linewidth=2, color=color.black, title="R")
plot(s_level, linewidth=2, color=color.blue,  title="S")
