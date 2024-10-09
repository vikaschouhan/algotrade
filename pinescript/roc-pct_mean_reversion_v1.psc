//@version=4
strategy(title="ROC-pct mean rev v1", overlay=false, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

///////////////////////////////////////
// Inputs
time_frame     = input(defval='', title='Timeframe', type=input.resolution)
rocpct_period  = input(defval=8, title='ROC-pct period', type=input.integer)
ema_len    = input(defval=100, title='Trend EMA')
en_long    = input(defval=true, title='Enable Long', type=input.bool)
en_short   = input(defval=false, title='Enable Short', type=input.bool)
en_tfilt   = input(defval=false, title='Enable Trend Filter', type=input.bool)

///////////////////////////////////////
// Calculate signals
roc_pct_t     = (close - lowest(close, rocpct_period))/(highest(close, rocpct_period) - lowest(close, rocpct_period)) * 100
roc_pct_sig   = security(syminfo.tickerid, time_frame, roc_pct_t)
ema_sig       = ema(close, ema_len)
trend_up      = en_tfilt ? (close > ema_sig) : true
trend_dn      = en_tfilt ? (close < ema_sig) : true

///////////////////////////////////////
// Execute positions

buy    = trend_up and crossover(roc_pct_sig, 50)
sell   = crossunder(roc_pct_sig, 50)
short  = trend_dn and crossunder(roc_pct_sig, 50)
cover  = crossover(roc_pct_sig, 50)

if en_long
    strategy.entry("L", strategy.long, when=buy)
    strategy.close("L", when=sell)
//
if en_short
    strategy.entry("S", strategy.short, when=short)
    strategy.close("S", when=cover)
//

////////////////////////////////////////
// Plots
plot(roc_pct_sig)
