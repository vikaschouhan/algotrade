//@version=5
strategy("RSI-ROC-pct trend finder", overlay=false, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

/////////////////////////////////////////////////////////////
// Inputs
rsi_len           = input.int(defval=14, title='RSI Length')
roc_len           = input.int(defval=14, title='ROC Length')
//look_back_len     = input.int(defval=14, title='Look back Length')
tframe_1          = input.timeframe(defval='1W', title='Time frame 1 (shortest)')
tframe_2          = input.timeframe(defval='1M', title='Time frame 2 (next higher one)')
tframe_3          = input.timeframe(defval='6M', title='Time frame 3 (next higher one)')
sel_cond          = input.string(defval="base_rsi_hi_rsi", title="Scenario", options=["base_rsi_hi_rsi", "base_roc_hi_rsi", "base_roc_hi_roc"])

//////////////////////////////////////////////////////////
// Utility functions
rsi_pct(rsi_l, rsi_lb_l) =>
    rsi_sig = ta.rsi(close, rsi_l)
    rsi_sig_pct = 100 * (rsi_sig - ta.lowest(rsi_sig, rsi_lb_l))/(ta.highest(rsi_sig, rsi_lb_l) - ta.lowest(rsi_sig, rsi_lb_l))
    rsi_sig_pct
//

roc_pct(roc_l) =>
    100 * (close - ta.lowest(close, roc_l))/(ta.highest(close, roc_l) - ta.lowest(close, roc_l))
//

/////////////////////////////////////////////////////////////
// Get all base signals
rsi_sig_act = rsi_pct(rsi_len, rsi_len)
roc_sig_act = roc_pct(roc_len)

rsi_sig_t1  = request.security(syminfo.tickerid, tframe_1, rsi_sig_act)
rsi_sig_t2  = request.security(syminfo.tickerid, tframe_2, rsi_sig_act)
rsi_sig_t3  = request.security(syminfo.tickerid, tframe_3, rsi_sig_act)

roc_sig_t1  = request.security(syminfo.tickerid, tframe_1, roc_sig_act)
roc_sig_t2  = request.security(syminfo.tickerid, tframe_2, roc_sig_act)
roc_sig_t3  = request.security(syminfo.tickerid, tframe_3, roc_sig_act)

///////////////////////////////////////////////////////////////
// Different buy & sell signals depending on scenario

rsi_hi_check              = (rsi_sig_t1 > 50) and (rsi_sig_t2 > 50) and (rsi_sig_t3 > 50)
roc_hi_check              = (roc_sig_t1 > 50) and (roc_sig_t2 > 50) and (roc_sig_t3 > 50)

buy_sig_base_rsi_hi_rsi    = (rsi_sig_act > 50) and rsi_hi_check
sell_sig_base_rsi_hi_rsi   = (rsi_sig_act < 50) and (roc_sig_act[1] < 50)

buy_sig_base_roc_hi_rsi    = (roc_sig_act > 50) and rsi_hi_check
sell_sig_base_roc_hi_rsi   = (roc_sig_act < 50) and (roc_sig_act[1] < 50)

buy_sig_base_roc_hi_roc    = (roc_sig_act > 50) and roc_hi_check
sell_sig_base_roc_hi_roc   = (roc_sig_act < 50) and (roc_sig_act[1] > 50)

///////////////////////////////////////////////////////////////
// Select scenario
buy_sig   = buy_sig_base_rsi_hi_rsi
sell_sig  = sell_sig_base_rsi_hi_rsi

if sel_cond == "base_rsi_hi_rsi"
    buy_sig   := buy_sig_base_rsi_hi_rsi
    sell_sig  := sell_sig_base_rsi_hi_rsi
else if sel_cond == "base_roc_hi_rsi"
    buy_sig   := buy_sig_base_roc_hi_rsi
    sell_sig  := sell_sig_base_roc_hi_rsi
else if sel_cond == "base_roc_hi_roc"
    buy_sig   := buy_sig_base_roc_hi_roc
    sell_sig  := sell_sig_base_roc_hi_roc
//

////////////////////////////////////////////////////////////////
// Execute positions
if buy_sig
    strategy.entry("L", strategy.long)
//

if sell_sig
    strategy.close("L")
//

////////////////////////////////////////////////////////////////
// Plot signals
plot(rsi_sig_act, color=color.blue,  title='RSI_org')
plot(rsi_sig_t1,  color=color.green, title='RSI T1')
plot(rsi_sig_t2,  color=color.aqua,  title='RSI T2')
plot(rsi_sig_t3,  color=color.red,   title='RSI T3')
plot(roc_sig_act, color=color.lime,  title='ROC_org')
