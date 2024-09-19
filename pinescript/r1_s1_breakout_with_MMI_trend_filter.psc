//@version=5
strategy("R1-S1 breakout with MMI filter", overlay=false, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

////////////////////////////////////////////////////////////////////////
// Inputs
mmi_inputLength = input.int(defval=300, title='MMI Input Length')
mmi_timeframe   = input.timeframe(defval="",  title='MMI Time Frame')
mmi_thresh      = input.float(defval=75.0, title='MMI Threshold', step=0.1)
level_type      = input.string(defval='r1-s1', title='R1-S1 Level Type', options=['r1-s1', 'r2-s2', 'h-l'])
r1_s1_tframe    = input.timeframe(defval='1W', title='R1-S1 Time Frame')
en_short        = input.bool(defval=false, title='Enable Shorts')

//////////////////////////////////////////////////////////////////////
// hardcoded params
mmi_filt_gamma  = 0.8
roc_source      = close

//////////////////////////////////////////////////////////////////////
// Utility functions
Average_v1(L0, L1, L2, L3) =>
    (L0 + 2*L1 + 2*L2 + L3)/6
//
    
Average_v2(L0, L1, L2, L3) =>
    (L0 + L1 + L2 + L3)/4
//

Laguerre_v1(gamma, src) =>
    L0  = src
    L1  = src
    L2  = src
    L3  = src
    L0  := (1-gamma)*src + gamma*nz(L0[1])
    L1  := -gamma*L0 + L0[1] + gamma*nz(L1[1])
    L2  := -gamma*L1 + L1[1] + gamma*nz(L2[1])
    L3  := -gamma*L2 + L2[1] + gamma*nz(L3[1])
    Average_v1(L0, L1, L2, L3)
//


// Get Average Price Change
mean(price1, price2, length) =>
    sum = 0.0
    for i = 0 to length
        if price1[i] - price2[i] > 0
            sum := sum + (price1[i] - price2[i])
        else
            sum := sum + (price2[i] - price1[i])
    sum / length
//

// Market Meaness Index Function
MMI(price1, price2, length) =>
    m = mean(open, close, mmi_inputLength)
    nh = 0.0
    nl = 0.0
    for i = 1 to length
        if price1[i] - price2[i] > 0
            if (price1[i] - price2[i]) > m
                if (price1[i] - price2[i]) > (price1[i+1] - price2[i+1])
                    nl := nl + 1
        else
            if (price2[i] - price1[i]) < m 
                if (price2[i] - price1[i]) < (price2[i+1] - price1[i+1])
                    nh := nh + 1
    100 - 100*(nl + nh)/(length - 1)
//

ROC(roc_s, roc_l) =>
    100 * (roc_s - ta.lowest(roc_s, roc_l))/(ta.highest(roc_s, roc_l) - ta.lowest(roc_s, roc_l))
//


pivot_cpr(time_frame) =>
    prev_close     = request.security(syminfo.tickerid, time_frame, close[1])
    prev_open      = request.security(syminfo.tickerid, time_frame, open[1])
    prev_high      = request.security(syminfo.tickerid, time_frame, high[1])
    prev_low       = request.security(syminfo.tickerid, time_frame, low[1])

    pi_level       = (prev_high + prev_low + prev_close)/3
    bc_level       = (prev_high + prev_low)/2
    tc_level       = (pi_level - bc_level) + pi_level
    r1_level       = pi_level * 2 - prev_low
    s1_level       = pi_level * 2 - prev_high
    r2_level       = (pi_level - s1_level) + r1_level
    s2_level       = pi_level - (r1_level - s1_level)
    
    [pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level, prev_high, prev_low]
//

[pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level, prev_high, prev_low] = pivot_cpr(r1_s1_tframe)

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

/////////////////////////////////////////////////////////////////////
// Get signals
mmi_sig = request.security(syminfo.tickerid, mmi_timeframe, Laguerre_v1(mmi_filt_gamma, MMI(open, close, mmi_inputLength))[1])

buy_sig   = (close > r_level) and (mmi_sig < mmi_thresh)
sell_sig  = (close < s_level)
short_sig = (close < s_level) and (mmi_sig < mmi_thresh)
cover_sig = (close > r_level)

////////////////////////////////////////////////////////////////////
// Execute positions
if buy_sig
    strategy.entry("L", strategy.long)
//

if sell_sig
    strategy.close("L")
//

if en_short
    if short_sig
        strategy.entry("S", strategy.short)
    //
    if cover_sig
        strategy.close("S")
    //
//

/////////////////////////////////////////////////////////////////////
// Plots
plot(mmi_sig, color=color.lime, title='MMI')
