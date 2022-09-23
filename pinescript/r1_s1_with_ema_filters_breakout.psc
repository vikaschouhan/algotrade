//@version=5
strategy("R1-S1 breakout with ema filters", overlay=true)

////////////////////////////////////////////////////
// Inputs
time_frame     = input.timeframe(defval="",      title="Primary time frame")
ema_time_frame = input.timeframe(defval="",      title="Trend filter time frame")
tolerance      = input.int(defval=25,            title="Tolerance value")
level_type     = input.string(defval='r1-s1',    title="Level type", options=['r1-s1', 'r2-s2', 'h-l'])
ema_len1       = input.int(defval=50,            title="EMA Length 1")
ema_len2       = input.int(defval=100,           title="EMA Length 2")
ema_len3       = input.int(defval=200,           title="EMA Length 3")

///////////////////////////////////////////////////////
// Get data from high time frame
get_security(_src, _tf) =>
    request.security(syminfo.tickerid, _tf, _src[1], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on)
//

////////////////////////////////////////////////////////
// Pivot calculating functions
pivot_cpr(time_frame) =>
    prev_close     = get_security(close, time_frame)
    prev_open      = get_security(open, time_frame)
    prev_high      = get_security(high, time_frame)
    prev_low       = get_security(low, time_frame)

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
if level_type == 'r1-s1'
    r_level  := r1_level
    s_level  := s1_level
//
if level_type == 'r2-s2'
    r_level  := r2_level
    s_level  := s2_level
//
if level_type == 'h-l'
    r_level  := prev_high
    s_level  := prev_low
//

////////////////////////////////////////////////////////////////
// Trend filters
ema_1 = get_security(ta.ema(close, ema_len1), ema_time_frame)
ema_2 = get_security(ta.ema(close, ema_len2), ema_time_frame)
ema_3 = get_security(ta.ema(close, ema_len3), ema_time_frame)

/////////////////////////////////////////////////////////////
// Position triggers
buy  = (close > r_level + tolerance) and (ema_1 >= ema_2) and (ema_2 >= ema_3)
sell = (close < s_level - tolerance) and (ema_1 <= ema_2) and (ema_2 <= ema_3)

/////////////////////////////////////////////////////////////
// Execute positions
if buy
    strategy.entry("L", strategy.long)
//
if sell
    strategy.entry("S", strategy.short)
//

//////////////////////////////////////////////////////////////////////////
// Plotting functions
plot(r_level, style=plot.style_circles, linewidth=1, color=color.green, title="R1")
plot(s_level, style=plot.style_circles, linewidth=1, color=color.red,   title="S1")
plot(ema_1,   style=plot.style_line,    linewidth=1, color=color.blue,  title="EMA1")
plot(ema_2,   style=plot.style_line,    linewidth=1, color=color.red,   title="EMA2")
plot(ema_3,   style=plot.style_line,    linewidth=1, color=color.green, title="EMA3")
