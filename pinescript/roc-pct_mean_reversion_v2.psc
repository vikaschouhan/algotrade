//@version=4
strategy(title="ROC-pct mean rev v2", overlay=false, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

///////////////////////////////////////
// Inputs
time_frame     = input(defval='', title='Timeframe', type=input.resolution)
rocpct_period  = input(defval=8, title='ROC-pct period', type=input.integer)
t_len          = input(defval=100, title='Trend Period')
en_long        = input(defval=true, title='Enable Long', type=input.bool)
en_short       = input(defval=false, title='Enable Short', type=input.bool)
en_tfilt       = input(defval=false, title='Enable Trend Filter', type=input.bool)
short_ethr     = input(defval=2, title='Short Exit Threshold for ROC-pct', type=input.integer)
pct_fn         = input(defval='rescale', title='Percentile Function', options=['rescale', 'percentrank', 'rescale_dvn'])
trd_logic      = input(defval='trend', title='Trade Logic', options=['trend', 'mean_rev'])
mrev_thr       = input(defval=10, title='Mean Reversion Threshold')
tr_type        = input(defval='ema', title='Trend Type', options=['ema', 'roc-ema'])

////////////////////////////////////////
// Utility functions
rescale_fn(src, rocpct_p) =>
    (src - lowest(src, rocpct_period))/(highest(src, rocpct_period) - lowest(src, rocpct_period)) * 100
//

percentrank_fn(src, rocpct_p) =>
    percentrank(src, rocpct_p)
//

rescale_dvn_fn(rocpct_p) =>
    y = 100 *(2*close/(high + low) - 1)
    dv_n = sma(y, rocpct_p)
    (dv_n - lowest(dv_n, rocpct_p))/(highest(dv_n, rocpct_p) - lowest(dv_n, rocpct_p)) * 100
//

trend_up_ema(p_) =>
    close > ema(close, p_)
//

trend_up_roc_ema(p_) =>
    roc = roc(ema(close, p_), p_)
    roc_ema = ema(roc, p_)
    (roc > roc_ema)
//

///////////////////////////////////////
// Calculate signals
roc_pct_rescale     = security(syminfo.tickerid, time_frame, rescale_fn(close, rocpct_period))
roc_pct_pctrank     = security(syminfo.tickerid, time_frame, percentrank_fn(close, rocpct_period))
roc_pct_rescale_dvn = security(syminfo.tickerid, time_frame, rescale_dvn_fn(rocpct_period))

roc_pct_sig   = roc_pct_rescale
if pct_fn == 'percentrank'
    roc_pct_sig := roc_pct_pctrank
//
if pct_fn == 'rescale_dvn'
    roc_pct_sig := roc_pct_rescale_dvn
//

// Trend Filter signals
trend_up_t = trend_up_ema(t_len)
if tr_type == 'roc-ema'
    trend_up_t := trend_up_roc_ema(t_len)
//

trend_up    = en_tfilt ? (trend_up_t == true) : true
trend_dn    = en_tfilt ? (trend_up_t == false) : true

///////////////////////////////////////
// Execute positions

// For long positions, 50 is the threshold
buy    = trend_up and crossover(roc_pct_sig, 50)
sell   = crossunder(roc_pct_sig, 50)
// For short positions, trigger threshold is 50, but we exit very quickly once the indicator almost touches 0.
short  = trend_dn and crossunder(roc_pct_sig, 50)
cover  = crossunder(roc_pct_sig, short_ethr)

if trd_logic == 'mean_rev'
    //
    buy   := trend_up and crossunder(roc_pct_sig, mrev_thr)
    sell  := crossover(roc_pct_sig, 100-mrev_thr)
    short := trend_dn and crossover(roc_pct_sig, 100-mrev_thr)
    cover := crossunder(roc_pct_sig, mrev_thr)
//

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
