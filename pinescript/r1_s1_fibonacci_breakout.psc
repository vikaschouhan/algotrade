//@version=4
strategy("R1-S1 Fibonacci breakout", overlay=true)

time_frame     = input("D", type=input.resolution)
tolerance      = input(5.0,   type=input.float)
is_tol_perc    = input(false, type=input.bool)
levels_type    = input(defval="r1-s1", title="levels_type", type=input.string, options=["r1-s1", "r2-s2", "r3-s3"])

pivot_dmark(time_frame) =>
    prev_close     = security(syminfo.tickerid, time_frame, close[1], lookahead=true)
    prev_open      = security(syminfo.tickerid, time_frame, open[1], lookahead=true)
    prev_high      = security(syminfo.tickerid, time_frame, high[1], lookahead=true)
    prev_low       = security(syminfo.tickerid, time_frame, low[1], lookahead=true)

    PP = (prev_high + prev_low + prev_close)/3
    R1 = PP + 0.382*(prev_high - prev_low)
    S1 = PP - 0.382*(prev_high - prev_low)
    R2 = PP + 0.618*(prev_high - prev_low)
    S2 = PP - 0.618*(prev_high - prev_low)
    R3 = PP + (prev_high - prev_low)
    S3 = PP - (prev_high - prev_low)

    [PP, R1, S1, R2, S2, R3, S3]
//

[p_level, r1_level, s1_level, r2_level, s2_level, r3_level, s3_level] = pivot_dmark(time_frame)

r_level = r1_level
s_level = s1_level
if levels_type == "r2-s2"
    r_level := r2_level
    s_level := s2_level
if levels_type == "r3-s3"
    r_level := r3_level
    s_level := s3_level
//

buy  = close > r_level + tolerance
sell = close < s_level - tolerance
if is_tol_perc
    buy  := close > r_level * (1 + tolerance/100.0)
    sell := close < s_level * (1 - tolerance/100.0)
//

strategy.entry("L", strategy.long, when=buy)
strategy.entry("S", strategy.short, when=sell)

plot(r_level, style=plot.style_circles, linewidth=2, color=color.green, title="R1")
plot(s_level, style=plot.style_circles, linewidth=2, color=color.red,   title="S1")
