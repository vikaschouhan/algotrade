//@version=5
strategy("ROC-pct ROC-ROC-pt with MMI filter", overlay=false, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

////////////////////////////////////////////////////////////////////////
// Inputs
mmi_inputLength = input.int(defval=300, title='MMI Input Length')
mmi_timeframe   = input.timeframe(defval="",  title='MMI Time Frame')
roc_length      = input.int(defval=14, title='ROC Length', minval=1)
roc_thresh      = input.int(defval=70, title='ROC Threshold')
roc_timeframe   = input.timeframe(defval="", title='ROC Time Frame')

//////////////////////////////////////////////////////////////////////
// hardcoded params
mmi_filt_gamma  = 0.8
mmi_thresh      = 75
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

/////////////////////////////////////////////////////////////////////
// Get signals
mmi_sig = request.security(syminfo.tickerid, mmi_timeframe, Laguerre_v1(mmi_filt_gamma, MMI(open, close, mmi_inputLength)))
roc_sig = request.security(syminfo.tickerid, roc_timeframe, ROC(roc_source, roc_length))
roc_roc_sig = request.security(syminfo.tickerid, roc_timeframe, ROC(ta.roc(roc_source, roc_length), roc_length))

buy_sig = (roc_sig > roc_thresh) and (roc_roc_sig > roc_thresh) and (mmi_sig < mmi_thresh)
sell_sig = (roc_sig < roc_thresh) or (roc_roc_sig < roc_thresh)

////////////////////////////////////////////////////////////////////
// Execute positions
if buy_sig
    strategy.entry("L", strategy.long)
//

if sell_sig
    strategy.close("L")
//

/////////////////////////////////////////////////////////////////////
// Plots
plot(roc_sig, color=color.red, title='ROC')
plot(roc_roc_sig, color=color.green, title='ROC-ROC')
plot(mmi_sig, color=color.lime, title='MMI')
