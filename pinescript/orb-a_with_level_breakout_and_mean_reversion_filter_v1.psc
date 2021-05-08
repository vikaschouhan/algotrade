//@version=4
strategy(title="ORB-A with level breakout and mean reversion filter v1", overlay=true)

/////////////////////////////////////////////////////////////////////////////////
// Inputs
// Trend indicator parametters
time_frame_cpr = input(defval='D', title='Timeframe for CPR', type=input.resolution)
tolerance      = input(defval=0.0, title="Tolerance", type=input.float)
time_frame_m   = input(defval='15', title="Resolution for ORB", type=input.resolution)
time_frame_n   = input(defval='1D', title="Time Gap", type=input.resolution)
level_type     = input('r1-s1', title='Level type', type=input.string, options=['r1-s1', 'r2-s2', 'h-l'])
// Stop loss parameters
stop_loss      = input(1.0,   title="Stop loss", type=input.float)
use_sperc      = input(false, title='Stop loss & tolerance are in %centage(s)', type=input.bool)
use_tstop      = input(true,  title='Use trailing stop', type=input.bool)
// For trendless market
rsi_len        = input(14,    title='RSI Length', type=input.integer)
rsi_tf         = input('',    title='RSI Time Frame', type=input.resolution)
rsi_dlen       = input(50,    title='RSI Donch Length', type=input.integer)
rsi_thi        = input(60,    title='RSI Trendless High', type=input.integer)
rsi_tlo        = input(40,    title='RSI Trendless Low', type=input.integer)
// Bollinger bands input
bb_source      = input(defval=close,    type=input.source,  title='Bollinger Source')
bb_length      = input(defval=20,       type=input.integer, title='Bollinger Length', minval=1)
bb_mult        = input(defval=2.0,      type=input.float,   title='Bollinger Multiplier', minval=0.01, maxval=50, step=0.01)
bb_tf          = input(defval='',       type=input.resolution, title='Bollinger Timeframe')

///////////////////////////////////////////////////////////////////////
// Helper functions
is_newbar(res) =>
    change(time(res)) != 0
//

pivot_cpr(time_frame_c) =>
    prev_close     = security(syminfo.tickerid, time_frame_c, close[1], lookahead=true)
    prev_open      = security(syminfo.tickerid, time_frame_c, open[1], lookahead=true)
    prev_high      = security(syminfo.tickerid, time_frame_c, high[1], lookahead=true)
    prev_low       = security(syminfo.tickerid, time_frame_c, low[1], lookahead=true)

    pi_level       = (prev_high + prev_low + prev_close)/3
    bc_level       = (prev_high + prev_low)/2
    tc_level       = (pi_level - bc_level) + pi_level
    r1_level       = pi_level * 2 - prev_low
    s1_level       = pi_level * 2 - prev_high
    r2_level       = (pi_level - s1_level) + r1_level
    s2_level       = pi_level - (r1_level - s1_level)
    
    [pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level, prev_high, prev_low]
//


///////////////////////////////////////////////////////////////////////
// Trendless signal (detect trendless markets)
rsi_t     = rsi(close, rsi_len)
rsi_ind   = security(syminfo.tickerid, rsi_tf, rsi_t)
trendless = (highest(rsi_ind, rsi_dlen) <= rsi_thi) and (lowest(rsi_ind, rsi_dlen) >= rsi_tlo)

//////////////////////////////////////////////////////////////////////////
// Bollinger bands (triggered in trendless markets)
bb_basis  = sma(bb_source, bb_length)
bb_dev    = bb_mult * stdev(bb_source, bb_length)
bb_upper  = bb_basis + bb_dev
bb_lower  = bb_basis - bb_dev
bb_basis_t = security(syminfo.tickerid, bb_tf, bb_basis)
bb_upper_t = security(syminfo.tickerid, bb_tf, bb_upper)
bb_lower_t = security(syminfo.tickerid, bb_tf, bb_lower)

/////////////////////////////////////////////////////////////////////////
// Trend indicator (Pivots based)
time_frame = time_frame_m
time_gap   = time_frame_n

[pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level, prev_high, prev_low] = pivot_cpr(time_frame_cpr)
r_level  = r1_level
s_level  = s1_level
if level_type == 'r2-s2'
    r_level  := r2_level
    s_level  := s2_level
//
if level_type == 'h-l'
    r_level  := prev_high
    s_level  := prev_low
//

high_range  = valuewhen(is_newbar(time_gap), high, 0)
low_range   = valuewhen(is_newbar(time_gap), low,  0)

high_rangeL = security(syminfo.tickerid, time_frame, high_range)
low_rangeL  = security(syminfo.tickerid, time_frame, low_range)
//range       = (high_rangeL - low_rangeL)/low_rangeL

//stop_l = use_sperc ? close*(1-stop_loss/100.0) : (close - stop_loss)
//stop_s = use_sperc ? close*(1+stop_loss/100.0) :  (close + stop_loss)
stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)
if use_tstop
    stop_lt = use_sperc ? close*(1-stop_loss/100.0) : (close - stop_loss)
    stop_st = use_sperc ? close*(1+stop_loss/100.0) :  (close + stop_loss)
    stop_l  := stop_lt //max(stop_l, stop_lt)
    stop_s  := stop_st //min(stop_s, stop_st)
//
tolbu  = use_sperc ? high_rangeL*(1+tolerance/100.0) : (high_rangeL + tolerance)
tolbl  = use_sperc ? low_rangeL*(1-tolerance/100.0) : (low_rangeL-tolerance)

/////////////////////////////////////////////////////////////////////
// Execution signals
buy    = crossover(close, tolbu)
sell   = crossunder(close, stop_l[1])
short  = crossunder(close, tolbl)
cover  = crossover(close, stop_s[1])

buy    := buy and (close >= r_level)
short  := short and (close <= s_level)

if trendless
    buy     := crossunder(close, bb_lower_t)
    sell    := crossover(close, bb_upper_t)
    short   := crossover(close, bb_upper_t)
    cover   := crossunder(close, bb_lower_t)
//

//////////////////////////////////////////////////////////////////////
// Execute positions
strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

//////////////////////////////////////////////////////////////////////
// Generate plots
plot(high_rangeL, color=color.green, linewidth=2, title='High_rangeL') 
plot(low_rangeL,  color=color.red, linewidth=2, title='Low_rangeL')
plot(r_level,     color=color.blue, linewidth=1, title='R_level')
plot(s_level,     color=color.olive, linewidth=1, title='S_level')
