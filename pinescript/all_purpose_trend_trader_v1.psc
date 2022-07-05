//@version=5
strategy("All purpose trend trader v1", overlay=true)

//////////////////////////////////////////////////
// Misc functions
//////////////////////////////////////////////////
is_newbar(res) =>
    ta.change(time(res)) != 0
//

//////////////////////////////////////////////////
// General selection options
//////////////////////////////////////////////////
trend_algo  = input.string(defval="pivot_simple", title="Trend selection algo", options=["pivot_simple", "pivot_simple_heikinashi", "orb_simple"])

/////////////////////////////////////////////////
// Pivots Points
/////////////////////////////////////////////////
pivot_simple_time_frame     = input.timeframe(defval="",     title="Simple Pivot Time Frame")
pivot_simple_tolerance      = input.int(defval=5,            title="Simple Pivot Tolerance")
pivot_simple_level_type     = input.string(defval='r1-s1',   title="Simple Pivot Level type", options=['r1-s1', 'r2-s2', 'h-l'])

pivot_cpr(time_frame) =>
    prev_close  = 0.0
    prev_open   = 0.0
    prev_high   = 0.0
    prev_low    = 0.0
    
    // Simple OHLC levels
    simple_prev_close     = request.security(syminfo.tickerid, time_frame, close[1], lookahead=barmerge.lookahead_on)
    simple_prev_open      = request.security(syminfo.tickerid, time_frame, open[1], lookahead=barmerge.lookahead_on)
    simple_prev_high      = request.security(syminfo.tickerid, time_frame, high[1], lookahead=barmerge.lookahead_on)
    simple_prev_low       = request.security(syminfo.tickerid, time_frame, low[1], lookahead=barmerge.lookahead_on)
    // Heikinashi OHLC levels
    heiki_prev_close     = request.security(ticker.heikinashi(syminfo.tickerid), time_frame, close[1], lookahead=barmerge.lookahead_on)
    heiki_prev_open      = request.security(ticker.heikinashi(syminfo.tickerid), time_frame, open[1], lookahead=barmerge.lookahead_on)
    heiki_prev_high      = request.security(ticker.heikinashi(syminfo.tickerid), time_frame, high[1], lookahead=barmerge.lookahead_on)
    heiki_prev_low       = request.security(ticker.heikinashi(syminfo.tickerid), time_frame, low[1], lookahead=barmerge.lookahead_on)
    
    if trend_algo == "pivot_simple_heikinashi"
        prev_close     := heiki_prev_close
        prev_open      := heiki_prev_open
        prev_high      := heiki_prev_high
        prev_low       := heiki_prev_low
    //
    if trend_algo == "pivot_simple"
        prev_close     := simple_prev_close
        prev_open      := simple_prev_open
        prev_high      := simple_prev_high
        prev_low       := simple_prev_low
    //

    pi_level       = (prev_high + prev_low + prev_close)/3
    bc_level       = (prev_high + prev_low)/2
    tc_level       = (pi_level - bc_level) + pi_level
    r1_level       = pi_level * 2 - prev_low
    s1_level       = pi_level * 2 - prev_high
    r2_level       = (pi_level - s1_level) + r1_level
    s2_level       = pi_level - (r1_level - s1_level)
    
    [pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level, prev_high, prev_low]
//

[p1_pi_level, p1_tc_level, p1_bc_level, p1_r1_level, p1_s1_level, p1_r2_level, p1_s2_level, p1_prev_high, p1_prev_low] = pivot_cpr(pivot_simple_time_frame)

pivot_simple_r_level = p1_r1_level
pivot_simple_s_level = p1_s1_level
if pivot_simple_level_type == 'r1-s1'
    pivot_simple_r_level  := p1_r1_level
    pivot_simple_s_level  := p1_s1_level
//
if pivot_simple_level_type == 'r2-s2'
    pivot_simple_r_level  := p1_r2_level
    pivot_simple_s_level  := p1_s2_level
//
if pivot_simple_level_type == 'h-l'
    pivot_simple_r_level  := p1_prev_high
    pivot_simple_s_level  := p1_prev_low
//

////////////////////////////////////////////////////////////////////
// ORB indicator
////////////////////////////////////////////////////////////////////
orb_simple_tolerance    = input.float(defval=0.0,       title="ORB_Simple_Tolerance")
orb_simple_resolution   = input.timeframe(defval='',    title="ORB_Simple_Resolution")
orb_simple_time_gap     = input.timeframe(defval='1D',  title="ORB_Simple_Time_Gap")

orb_simple_high_range   = ta.valuewhen(is_newbar(orb_simple_time_gap), high, 0)
orb_simple_low_range    = ta.valuewhen(is_newbar(orb_simple_time_gap), low,  0)

orb_simple_high_rangeL  = request.security(syminfo.tickerid, orb_simple_resolution, orb_simple_high_range)
orb_simple_low_rangeL   = request.security(syminfo.tickerid, orb_simple_resolution, orb_simple_low_range)
orb_simple_basisL       = math.avg(orb_simple_high_rangeL, orb_simple_low_rangeL)

////////////////////////////////////////////////////////////////////
// EMA Filters
////////////////////////////////////////////////////////////////////
ema_len1          = input.int(defval=50,   title='EMA1')
ema_len2          = input.int(defval=100,  title='EMA2')
ema_len3          = input.int(defval=200,  title='EMA3')
ema_time_frame    = input.timeframe(defval="", title="EMA time frame")

ema_1 = request.security(syminfo.tickerid, ema_time_frame, ta.ema(close, ema_len1))
ema_2 = request.security(syminfo.tickerid, ema_time_frame, ta.ema(close, ema_len2))
ema_3 = request.security(syminfo.tickerid, ema_time_frame, ta.ema(close, ema_len3))

//////////////////////////////////////////////////////////////////////
// Buy Sell Signals
//////////////////////////////////////////////////////////////////////
buy_trend  = false
sell_trend = false
trend_sig_up = 0.0
trend_sig_dn = 0.0

if trend_algo == "pivot_simple" or trend_algo == "pivot_simple_heikinashi"
    buy_trend     := (close > pivot_simple_r_level + pivot_simple_tolerance)
    sell_trend    := (close < pivot_simple_s_level - pivot_simple_tolerance)
    trend_sig_up  := pivot_simple_r_level   
    trend_sig_dn  := pivot_simple_s_level 
//
if trend_algo == "orb_simple"
    buy_trend     := (close > orb_simple_high_rangeL + orb_simple_tolerance)
    sell_trend    := (close < orb_simple_low_rangeL - orb_simple_tolerance)
    trend_sig_up  := orb_simple_high_rangeL
    trend_sig_dn  := orb_simple_low_rangeL
//

// Apply filter
buy  = buy_trend and (ema_1 >= ema_2) and (ema_2 >= ema_3)
sell = sell_trend and (ema_1 <= ema_2) and (ema_2 <= ema_3)

//////////////////////////////////////////////////////////////////////
// Position execution
//////////////////////////////////////////////////////////////////////
strategy.entry("L", strategy.long, when=buy)
strategy.entry("S", strategy.short, when=sell)

//////////////////////////////////////////////////////////////////////
// Plot signals & filters
//////////////////////////////////////////////////////////////////////
plot(trend_sig_up, style=plot.style_line, linewidth=1, color=color.green, title="U")
plot(trend_sig_dn, style=plot.style_line, linewidth=1, color=color.red,   title="D")

plot(ema_1,   style=plot.style_line,    linewidth=1, color=color.blue,  title="EMA1")
plot(ema_2,   style=plot.style_line,    linewidth=1, color=color.red,   title="EMA2")
plot(ema_3,   style=plot.style_line,    linewidth=1, color=color.green, title="EMA3")
