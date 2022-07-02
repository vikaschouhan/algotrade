//@version=4
strategy("R1-S1 breakout with ema filters", overlay=true)

time_frame     = input(defval="",      type=input.resolution)
ema_time_frame = input(defval="",      type=input.resolution)
tolerance      = input(defval=5,       type=input.integer)
level_type     = input(defval='r1-s1', type=input.string, options=['r1-s1', 'r2-s2', 'h-l'])
ema_len1       = input(defval=50,      type=input.integer)
ema_len2       = input(defval=100,     type=input.integer)
ema_len3       = input(defval=200,     type=input.integer)

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

ema_1 = security(syminfo.tickerid, ema_time_frame, ema(close, ema_len1))
ema_2 = security(syminfo.tickerid, ema_time_frame, ema(close, ema_len2))
ema_3 = security(syminfo.tickerid, ema_time_frame, ema(close, ema_len3))

buy  = (close > r_level + tolerance) and (ema_1 >= ema_2) and (ema_2 >= ema_3)
sell = (close < s_level - tolerance) and (ema_1 <= ema_2) and (ema_2 <= ema_3)

strategy.entry("L", strategy.long, when=buy)
strategy.entry("S", strategy.short, when=sell)

plot(r_level, style=plot.style_circles, linewidth=1, color=color.green,   title="R1")
plot(s_level, style=plot.style_circles, linewidth=1, color=color.red,     title="S1")
plot(ema_1,   style=plot.style_line,    linewidth=1, color=color.orange,  title='EMA1')
plot(ema_2,   style=plot.style_line,    linewidth=1, color=color.olive,   title='EMA2')
plot(ema_3,   style=plot.style_line,    linewidth=1, color=color.blue,    title='EMA3')
