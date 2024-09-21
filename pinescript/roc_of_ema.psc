//@version=5
strategy("ROC of EMA strategy", overlay=false, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

////////////////////////////////////////////////////////////////
// Inputs
roc_length      = input.int(defval=150, title='ROC Length', minval=1)
roc_smlength    = input.int(defval=20,  title='ROC Smooth Length')
roc_timeframe   = input.timeframe(defval='', title='ROC Time Frame')
en_short        = input.bool(defval=false, title='Enable Shorts ?')

////////////////////////////////////////////////////////////////
// Signa;s
roc_sig         = ta.roc(ta.ema(close, roc_smlength), roc_length)
roc_ema_sig     = ta.ema(roc_sig, roc_length)
//roc_lreg_sig    = ta.linreg(roc_sig, roc_length, 0)

roc_sig_t       = request.security(syminfo.tickerid, roc_timeframe, roc_sig)
roc_ema_sig_t   = request.security(syminfo.tickerid, roc_timeframe, roc_ema_sig)
//roc_lreg_sig_t  = request.security(syminfo.tickerid, roc_timeframe, roc_lreg_sig)

buy_sig_ema_c1    = ta.crossover(roc_sig_t, roc_ema_sig_t) and (roc_sig_t > 0)
buy_sig_ema_c2    = ta.crossover(roc_sig_t, 0) and (roc_sig_t > roc_ema_sig_t)
buy_sig_ema       = buy_sig_ema_c1 //or buy_sig_ema_c2
sell_sig_ema      = ta.crossunder(roc_sig_t, roc_ema_sig_t) or ta.crossunder(roc_sig_t, 0)
short_sig_ema_c1  = ta.crossunder(roc_sig_t, roc_ema_sig_t) and (roc_sig_t < 0)
short_sig_ema_c2  = ta.crossunder(roc_sig_t, 0) and (roc_sig_t < roc_ema_sig_t)
short_sig_ema     = short_sig_ema_c1 //or short_sig_ema_c2
cover_sig_ema     = ta.crossover(roc_sig_t, roc_ema_sig_t) or ta.crossover(roc_sig_t, 0)

//buy_sig_lreg    = ta.crossover(roc_sig_t, roc_lreg_sig_t) and (roc_sig_t > 0)
//sell_sig_lreg   = ta.crossunder(roc_sig_t, roc_lreg_sig_t) or ta.crossunder(roc_sig_t, 0)
//short_sig_lreg  = ta.crossunder(roc_sig_t, roc_lreg_sig_t) and (roc_sig_t < 0)
//cover_sig_lreg  = ta.crossover(roc_sig_t, roc_lreg_sig_t) or ta.crossover(roc_sig_t, 0)

buy_sig         = buy_sig_ema
sell_sig        = sell_sig_ema
short_sig       = short_sig_ema
cover_sig       = cover_sig_ema

///////////////////////////////////////////////////////////////
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

///////////////////////////////////////////////////////////
// Plots
plot(roc_sig_t, color=#2962FF, title="ROC")
plot(roc_ema_sig_t, color=color.green, title="ROC EMA")
//plot(roc_lreg, color=color.orange, title="ROC LREG")
hline(0, color=#787B86, title="Zero Line")
