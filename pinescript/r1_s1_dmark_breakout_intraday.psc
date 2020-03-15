//@version=4
strategy("R1-S1 DeMark breakout intraday", overlay=true)

time_frame     = input("D", type=input.resolution)
tolerance      = input(5,   type=input.integer)

intraday_sess  = "1500-1515"
trade_sess     = "0915-1500"
t_session      = time(timeframe.period, intraday_sess)
t_sess_trade   = time(timeframe.period, trade_sess)
sess_over      = not na(t_session[1]) and na(t_session)
sess_valid     = not na(t_sess_trade[0])


pivot_dmark(time_frame) =>
    prev_close     = security(syminfo.tickerid, time_frame, close[1], lookahead=true)
    prev_open      = security(syminfo.tickerid, time_frame, open[1], lookahead=true)
    prev_high      = security(syminfo.tickerid, time_frame, high[1], lookahead=true)
    prev_low       = security(syminfo.tickerid, time_frame, low[1], lookahead=true)

    X = (prev_close > prev_open) ? (2*prev_high + prev_low + prev_close) : ((prev_close < prev_close) ? (prev_high + 2*prev_low + prev_close) : (prev_high + prev_low + 2*prev_close))
    R1 = (X/2) - prev_low
    S1 = (X/2) - prev_high
    
    [R1, S1]
//

[r_level, s_level] = pivot_dmark(time_frame)

buy  = close > r_level + tolerance
sell = close < s_level - tolerance

strategy.entry("L", strategy.long, when=buy and sess_valid)
strategy.entry("S", strategy.short, when=sell and sess_valid)
strategy.close_all(when=sess_over)

plot(r_level, style=plot.style_circles, linewidth=2, color=color.green, title="R1")
plot(s_level, style=plot.style_circles, linewidth=2, color=color.red,   title="S1")
