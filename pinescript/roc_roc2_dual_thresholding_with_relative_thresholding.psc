//@version=5
strategy("ROC-pct ROC-ROC-pt dual thresholding", overlay=false, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

////////////////////////////////////////////////////////////////////////
// Inputs
roc_length      = input.int(defval=14, title='ROC Length', minval=1)
roc_thresh      = input.int(defval=30, title='ROC Threshold')
roc_diff_thresh = input.int(defval=10, title='ROC ROC-ROC difference Threshold')
roc_timeframe   = input.timeframe(defval="", title='ROC Time Frame')
en_short        = input.bool(defval=false, title='Enable Shorts')
roc_diff_thresh_is_perct = input.bool(defval=false, title='ROC ROC-ROC difference Threshold is % ?')

//////////////////////////////////////////////////////////////////////
// hardcoded params
roc_source      = close
roc_hi_thresh   = (100 - roc_thresh)
roc_lo_thresh   = roc_thresh

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

ROC(roc_s, roc_l) =>
    100 * (roc_s - ta.lowest(roc_s, roc_l))/(ta.highest(roc_s, roc_l) - ta.lowest(roc_s, roc_l))
//

/////////////////////////////////////////////////////////////////////
// Get signals
roc_sig = request.security(syminfo.tickerid, roc_timeframe, ROC(roc_source, roc_length)[1])
roc_roc_sig = request.security(syminfo.tickerid, roc_timeframe, ROC(ta.roc(roc_source, roc_length), roc_length)[1])

roc_roc_diff = math.abs(roc_sig - roc_roc_sig)
roc_roc_diff_perct = roc_roc_diff/roc_sig * 100

roc_roc_diff_check_lt = (roc_diff_thresh_is_perct) ? (roc_roc_diff_perct < roc_diff_thresh) : (roc_roc_diff < roc_diff_thresh)
roc_roc_diff_check_gt = (roc_diff_thresh_is_perct) ? (roc_roc_diff_perct > roc_diff_thresh) : (roc_roc_diff > roc_diff_thresh)

buy_sig    = (roc_sig > roc_hi_thresh) and (roc_roc_sig > roc_hi_thresh) and roc_roc_diff_check_lt
sell_sig   = (roc_sig < roc_hi_thresh) or (roc_roc_sig < roc_hi_thresh) or roc_roc_diff_check_gt
short_sig  = (roc_sig < roc_lo_thresh) and (roc_roc_sig < roc_lo_thresh) and roc_roc_diff_check_lt
cover_sig  = (roc_sig > roc_lo_thresh) or (roc_roc_sig > roc_lo_thresh) or roc_roc_diff_check_gt

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
plot(roc_sig, color=color.red, title='ROC')
plot(roc_roc_sig, color=color.green, title='ROC-ROC')
