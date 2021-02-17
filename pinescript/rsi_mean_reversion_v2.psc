//@version=4
strategy(title="RSI mean rev v2", overlay=false)

/////////////////////////////////////////////////////////////
// Inputs
time_frame = input(defval='D', title='Timeframe', type=input.resolution)
stop_loss  = input(1.0,        title="Stop loss", type=input.float)
use_sperc  = input(false,      title='Stop loss & tolerance are in %centage(s)', type=input.bool)
rsi_period = input(defval=8,   title='RSI period', type=input.integer)
rsi_high   = input(defval=70,  title='RSI High Boundary')
rsi_low    = input(defval=30,  title='RSI Low Boundary')
ema_len    = input(defval=100, title='Trend EMA')

///////////////////////////////////////////////////////////////
// Calculate stops
stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)

///////////////////////////////////////////////////////////////////////
// Calculate signals
rsi_sig = security(syminfo.tickerid, time_frame, rsi(close, rsi_period))
ema_sig = ema(close, ema_len)

buy    = (close > ema_sig) and crossover(rsi_sig, rsi_low)
sell   = crossunder(rsi_sig, rsi_high) or crossunder(close, stop_l)
short  = (close < ema_sig) and crossunder(rsi_sig, rsi_high)
cover  = crossover(rsi_sig, rsi_low) or crossover(close, stop_s)

///////////////////////////////////////////////////////////////////
// Execute signals
strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

////////////////////////////////////////////////////////////////////
// Plots
plot(rsi_sig, color=color.blue, title="RSI")
