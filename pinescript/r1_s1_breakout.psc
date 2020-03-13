//@version=4
strategy("R1-S1 breakout", overlay=true)

time_frame     = input("D", type=input.resolution)
tolerance      = input(5,   type=input.integer)

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

buy  = close > r1_level + tolerance
sell = close < s1_level - tolerance

strategy.entry("L", strategy.long, when=buy)
strategy.entry("S", strategy.short, when=sell)

plot(r1_level, style=plot.style_circles, linewidth=2, color=color.green, title="R1")
plot(s1_level, style=plot.style_circles, linewidth=2, color=color.red,   title="S1")
