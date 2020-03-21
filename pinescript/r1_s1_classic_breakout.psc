//@version=4
strategy("PV r1-s1 breakout", overlay=true, slippage=20)

time_frame     = input("D", type=input.resolution)
tolerance      = input(defval=0.0, type=input.float)
pivot_type     = input(defval="r1-s1", type=input.string, options=["r1-s1", "r2-s2", "h-l"])

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
    
    [pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level, prev_high, prev_low]
//

[pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level, hi_level, lo_level] = cpr(time_frame)

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

buy  = crossover(close, r_level + tolerance)
sell = crossunder(close, s_level - tolerance)

strategy.entry("L", strategy.long, when=buy)
strategy.entry("S", strategy.short, when=sell)

plot(r_level, linewidth=2, color=color.black, title="R")
plot(s_level, linewidth=2, color=color.blue,  title="S")
