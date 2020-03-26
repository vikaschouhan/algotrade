//@version=4
strategy("R1-S1 Fibonacci breakout with rising ADX filter", overlay=true)

time_frame     = input("D",   type=input.resolution)
tolerance      = input(5.0,   type=input.float)
is_tol_perc    = input(false, type=input.bool)
levels_type    = input(defval="r1-s1", title="levels_type", type=input.string, options=["r1-s1", "r2-s2", "r3-s3"])
adx_len        = input(defval=14, type=input.integer)
adx_elen       = input(defval=9,  type=input.integer)
adx_res        = time_frame  //input("D",   type=input.resolution)

// ADX
dirmov(len) => 
    up = change(high) 
    down = -change(low) 
    truerange = rma(tr, len) 
    plus = fixnan(100 * rma(up > down and up > 0 ? up : 0, len) / truerange) 
    minus = fixnan(100 * rma(down > up and down > 0 ? down : 0, len) / truerange) 
    [plus, minus] 
 
adx(adx_len) =>  
    [plus, minus] = dirmov(adx_len) 
    sum = plus + minus 
    adx = 100 * rma(abs(plus - minus) / (sum == 0 ? 1 : sum), adx_len) 
    [adx, plus, minus] 

[ADX, up, down] = adx(adx_len)
ADX_ema = security(syminfo.tickerid, adx_res, ema(ADX, adx_elen))
ADX_new = security(syminfo.tickerid, adx_res, ADX)

// Pivots
pivot_fib(time_frame) =>
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

[p_level, r1_level, s1_level, r2_level, s2_level, r3_level, s3_level] = pivot_fib(time_frame)

r_level = r1_level
s_level = s1_level
if levels_type == "r2-s2"
    r_level := r2_level
    s_level := s2_level
if levels_type == "r3-s3"
    r_level := r3_level
    s_level := s3_level
//

adx_check() =>
    s(ADX_ema > ADX_new)
    //(ADX_new >= ADX_new[1]) //and (ADX_new[1] >= ADX_new[2])
//

buy   = (close > r_level + tolerance) and adx_check()
sell  = (close < s_level - tolerance)
short = (close < s_level - tolerance) and adx_check()
cover = (close > s_level + tolerance)
if is_tol_perc
    buy   := (close > r_level * (1 + tolerance/100.0)) and adx_check()
    sell  := (close < s_level * (1 - tolerance/100.0))
    short := (close < s_level + (1 - tolerance/100.0)) and adx_check()
    cover := (close > r_level + (1 + tolerance/100.0))
//

strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

plot(r_level, style=plot.style_circles, linewidth=2, color=color.green, title="R1")
plot(s_level, style=plot.style_circles, linewidth=2, color=color.red,   title="S1")
