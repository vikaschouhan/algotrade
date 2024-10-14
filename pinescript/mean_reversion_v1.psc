//@version=5
strategy("Mean reversion v1", overlay=false, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

////////////////////////////////////////////////////////////////////////
// Inputs
period      = input.int(defval=14, title='Loopback period')
threshold   = input.int(defval=14, title='Threshold')
tperiod     = input.int(defval=100, title='Trend EMA')
tfilt_en    = input.bool(defval=true, title='Enable Trend Filter')
en_long     = input.bool(defval=true, title='Enable Long')
en_short    = input.bool(defval=false, title='Enable Short')

//////////////////////////////////////////////////////////////////////
// Utility functions
rescale_fn(p_, p_length_) =>
    (p_ - ta.lowest(p_, p_length_))/(ta.highest(p_, p_length_) - ta.lowest(p_, p_length_)) * 100
//

ma_fn(p_, p_length_) =>
    ta.sma(p_, p_length_)
//

dpo_fn(p_, p_length_) =>
    rescale_fn((p_ - ma_fn(p_, p_length_))/ma_fn(p_, p_length_), p_length_)
//

/////////////////////////////////////////////////////////////////////
// Get signals

// Main signal
mrev_sig    = dpo_fn(close, period)

// Trend Filter signals
trend_ma    = ta.ema(close, tperiod)
trend_up    = tfilt_en ? (close > trend_ma) : true
trend_dn    = tfilt_en ? (close < trend_ma) : true

thr_hi      = 100 - threshold
thr_lo      = threshold

// Execution signals
buy_sig     = trend_up and (mrev_sig < thr_lo)
sell_sig    = (mrev_sig > thr_hi)
short_sig   = trend_dn and (mrev_sig > thr_hi)
cover_sig   = (mrev_sig < thr_lo)

/////////////////////////////////////////////////////////////////////
// Execute positions
if en_long
    if buy_sig
        strategy.entry("Long", strategy.long)
    //
    if sell_sig
        strategy.close("Long")
    //
//
if en_short
    if short_sig
        strategy.entry("Short", strategy.short)
    //
    if cover_sig
        strategy.close("Short")
    //
//

////////////////////////////////////////////////////////////////
// Plots
plot(mrev_sig, color=color.blue, title='signal')
hline(thr_lo, title='Threshold Low')
hline(thr_hi, title='Threshold High')
