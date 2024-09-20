//@version=5
strategy("Linreg and Donch Regime filter with Moving average trend filter", overlay=false, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

////////////////////////////////////////////////////////////////////
// Inputs
donch_len   = input.int(defval=20,  title="Regime Filter - Donchian Channel Length")
linreg_len  = input.int(defval=20,  title="Regime Filter - Linear Regression Length")
ma_len      = input.int(defval=200, title="Trend Filter - Moving Average Length")
ma_tf       = input.timeframe(defval="", title="Moving Average Time Frame")
reg_tf      = input.timeframe(defval="", title="Regime Filter Time Frame")
en_short    = input.bool(defval=false, title="Enable Short Positions ?")

///////////////////////////////////////////////////////////////////
// Signals
lreg = ta.linreg(close, linreg_len, 0)
lreg_pct = (lreg - ta.lowest(lreg, linreg_len))/(ta.highest(lreg, linreg_len) - ta.lowest(lreg, linreg_len)) * 100

donch_hi = ta.highest(high, donch_len)
donch_low = ta.lowest(low, donch_len)
donch_mid = math.avg(donch_hi, donch_low)
donch_sum_ind = math.sum(close - donch_mid, donch_len)
donch_sum_pct = (donch_sum_ind - ta.lowest(donch_sum_ind, donch_len))/(ta.highest(donch_sum_ind, donch_len) - ta.lowest(donch_sum_ind, donch_len)) * 100

regime_sig = (donch_sum_pct == 100 or lreg_pct == 100) ? 100 : (donch_sum_pct == 0 or lreg_pct == 0) ? 0 : 50
//regime_sig = (lreg_pct == 100) ? 100 : (lreg_pct == 0) ? 0 : lreg_pct
regime_sig_tf = request.security(syminfo.tickerid, reg_tf, regime_sig)
ma_sig = ta.ema(close, ma_len)
ma_sig_tf = request.security(syminfo.tickerid, ma_tf, ma_sig)

buy_sig = (close > ma_sig_tf) and (regime_sig_tf == 100)
sell_sig = ((regime_sig_tf < 100) and (regime_sig_tf[1] < 100))
short_sig = (close < ma_sig_tf) and (regime_sig_tf == 0)
cover_sig = ((regime_sig_tf > 0) and (regime_sig_tf[1] > 100))

/////////////////////////////////////////////////////////////////////
// Take positions
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

////////////////////////////////////////////////////////////////////
// Plots
plot(regime_sig, color=color.red, title='Regime Signal')
