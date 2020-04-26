//@version=4
strategy("Supertrend with hl smoothing combined with Pivots", "Supertrend HL Smooth + Pivots", overlay=true)

atr_factor    = input(defval=4,     type=input.integer, title='Supertrend Factor')
atr_period    = input(defval=10,    type=input.integer, title='Supertrend Period')
ema_len       = input(defval=2,     type=input.integer, title='Smooth EMA Loopback Period')
time_frame    = input(defval="D",   type=input.resolution, title='Pivot Time frame')
tolerance     = input(defval=0.0,   type=input.float,   title='Pivot Breakout Tolerance')
pivot_type    = input(defval="r1-s1", type=input.string, options=["r1-s1", "r2-s2", "h-l"], title='Pivot type')

////////////////////////////////////////
/// Pivots
stand_pivot(time_frame) =>
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

[pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level, hi_level, lo_level] = stand_pivot(time_frame)

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

///////////////////////////////////////////
/// Position signals for pivots
buy_p   = crossover(close, r_level + tolerance)
sell_p  = crossunder(close, s_level - tolerance)

/////////////////////////////////////
/// Supertrend fn
_supertrend(factor, period) =>
    hl22    = (ema(high, ema_len) + ema(low, ema_len))/2
    cl22    = close //ema(close, ema_len)
    Up      = hl22 - (factor*atr(period))
    Dn      = hl22 + (factor*atr(period))
    TrendUp = 0.0
    TrendDn = 0.0
    Trend   = 0.0
    TrendUp := cl22[1]>TrendUp[1] ? max(Up,TrendUp[1]) : Up
    TrendDn := cl22[1]<TrendDn[1]? min(Dn,TrendDn[1]) : Dn
    Trend   := cl22 > TrendDn[1] ? 1: cl22 < TrendUp[1]? -1: nz(Trend[1],1)
    Tsl     = Trend==1? TrendUp: TrendDn

    [Tsl, Trend, TrendUp, TrendDn]
//

[tsl, trend, trend_up, trend_dn] = _supertrend(atr_factor, atr_period)
lcolor_res                       = trend == 1 ? color.green : color.red

/////////////////////////////////////////////////////
/// Calc position signals for supertrend
buy_s  = (trend == 1) and (trend[1] != 1)
sell_s = (trend != 1) and (trend[1] == 1)

/////////////////////////////////////////////////////
/// Combine signals
buy    = buy_s or buy_p
sell   = sell_s or sell_p

////////////////////////////////////////////////////
/// Execute trades
strategy.entry("Long", strategy.long, when=buy)
strategy.entry("Short", strategy.short, when=sell)

////////////////////////////////////////////////////
/// Plots
plot(tsl,     color=lcolor_res, linewidth = 1, title = "SuperTrend")
plot(r_level, style=plot.style_circles, color=color.green, title="R")
plot(s_level, style=plot.style_circles, color=color.red,  title="S")
