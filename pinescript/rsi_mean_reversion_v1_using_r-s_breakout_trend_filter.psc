//@version=4
strategy("RSI Mean reversion v1 with R-S trend filter", overlay=false)

///////////////////////////////////////////////////////////
// Inputs
time_frame     = input(defval="D",     type=input.resolution, title='R-S Time Frame')
level_type     = input(defval='r1-s1', type=input.string, options=['r1-s1', 'r2-s2', 'h-l'], title='R-S type')
rsi_len        = input(defval=2,       type=input.integer, title='RSI Length')
rsi_lo_thr     = input(defval=2,       type=input.integer, minval=0, maxval=100, title='RSI Low Threshold')
rsi_hi_thr     = input(defval=50,      type=input.integer, minval=0, maxval=100, title='RSI High Threshold')

//////////////////////////////////////////////////////////////
// Pivot function
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

// Get pivot levels
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

///////////////////////////////////////////////////////////////
// Get a trend indicator signal from R-S levels breakouts.
get_trend_from_rs_levels(_r_level, _s_level) =>
    t_trend = 0.0
    if close > _r_level
        t_trend := 1
    else if close < _s_level
        t_trend := 0
    else
        t_trend := nz(t_trend[1])
        //
    //
    t_trend
//

//////////////////////////////////////////////////////////////////////
// Indicators
// Get trend signal and rsi signal
trend_sig = get_trend_from_rs_levels(r_level, s_level)
rsi_sig   = rsi(close, rsi_len)

/////////////////////////////////////////////////////////////////////
// Get positions
buy_signal   = crossunder(rsi_sig, rsi_lo_thr) and trend_sig == 1
sell_signal  = crossover(rsi_sig, rsi_hi_thr)

////////////////////////////////////////////////////////////////////
// Execute positions
strategy.entry("L", strategy.long, when=buy_signal)
strategy.close("L", when=sell_signal)

///////////////////////////////////////////////////////////////////
// Plots
//plot(trend_sig * 100, color=color.red, title='Trend Signal')
plot(rsi_hi_thr, color=color.black, title='RSI-H')
plot(rsi_lo_thr, color=color.black, title='RSI-H')
plot(rsi_sig,    color=color.blue, title='RSI Signal')
