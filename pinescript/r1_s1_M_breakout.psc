//@version=4
strategy("R1-S1 M breakout", overlay=true)

time_frame     = input("D", type=input.resolution)
tolerance      = input(5.0,   type=input.float)
m_factor       = input(1.0, type=input.float, step=0.01)
is_tol_perc    = input(false, type=input.bool)

pivot_M(time_frame) =>
    prev_close     = security(syminfo.tickerid, time_frame, close[1], lookahead=true)
    prev_open      = security(syminfo.tickerid, time_frame, open[1], lookahead=true)
    prev_high      = security(syminfo.tickerid, time_frame, high[1], lookahead=true)
    prev_low       = security(syminfo.tickerid, time_frame, low[1], lookahead=true)

    //X = (prev_close > prev_open) ? (2*prev_high + prev_low + prev_close) : ((prev_close < prev_open) ? (prev_high + 2*prev_low + prev_close) : (prev_high + prev_low + 2*prev_close))
    X  = (prev_high + prev_low + prev_close)/3
    R1 = (X) + m_factor*(prev_high - prev_low)
    S1 = (X) - m_factor*(prev_high - prev_low)
    
    [R1, S1]
//

[r_level, s_level] = pivot_M(time_frame)

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
