//@version=4
strategy(title="RSI mean rev v3", overlay=false, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

///////////////////////////////////////
// Inputs
time_frame = input(defval='', title='Timeframe', type=input.resolution)
rsi_period = input(defval=8, title='RSI period', type=input.integer)
rsi_thresh = input(defval=30, title='RSI Threshold')
ema_len    = input(defval=100, title='Trend EMA')
en_long    = input(defval=true, title='Enable Long', type=input.bool)
en_short   = input(defval=false, title='Enable Short', type=input.bool)

///////////////////////////////////////
// Calculate signals
rsi_hi  = 100 - rsi_thresh
rsi_lo  = rsi_thresh
rsi_sig = security(syminfo.tickerid, time_frame, rsi(close, rsi_period))
ema_sig = ema(close, ema_len)

///////////////////////////////////////
// Execute positions
buy    = (close > ema_sig) and crossover(rsi_sig, rsi_lo)
sell   = crossunder(rsi_sig, rsi_hi)
short  = (close < ema_sig) and crossunder(rsi_sig, rsi_hi)
cover  = crossover(rsi_sig, rsi_lo)

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
