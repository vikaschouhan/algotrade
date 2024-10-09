//@version=4
strategy(title="RSI mean rev v4 - Roc-pct of RSI", overlay=false, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

///////////////////////////////////////
// Inputs
time_frame = input(defval='', title='Timeframe', type=input.resolution)
rsi_period = input(defval=8, title='RSI period', type=input.integer)
ema_len    = input(defval=100, title='Trend EMA')
en_long    = input(defval=true, title='Enable Long', type=input.bool)
en_short   = input(defval=false, title='Enable Short', type=input.bool)
en_tfilt   = input(defval=true, title='Enable Trend Filter', type=input.bool)

///////////////////////////////////////
// Calculate signals
rsi_sig_t   = rsi(close, rsi_period)
rsi_sig_tt  = (rsi_sig_t - lowest(rsi_sig_t, rsi_period))/(highest(rsi_sig_t, rsi_period) - lowest(rsi_sig_t, rsi_period)) * 100
rsi_sig     = security(syminfo.tickerid, time_frame, rsi_sig_tt)
ema_sig     = ema(close, ema_len)
trend_up    = en_tfilt ? (close > ema_sig) : true
trend_dn    = en_tfilt ? (close < ema_sig) : false

///////////////////////////////////////
// Execute positions
buy    = trend_up and crossover(rsi_sig, 50)
sell   = crossunder(rsi_sig, 50)
short  = trend_dn and crossunder(rsi_sig, 50)
cover  = crossover(rsi_sig, 50)

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
plot(rsi_sig)
