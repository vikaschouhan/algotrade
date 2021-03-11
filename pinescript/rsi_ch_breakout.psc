//@version=4
strategy("RSI channel breakout", overlay=false)

///////////////////////////////////////////////////////////////////////
// Inputs
rsi_period   = input(defval=14,       title="RSI Period", type=input.integer, minval=1, maxval=100, step=1)
donch_period = input(defval=9,        title="Donch RSI Period", type=input.integer, minval=1, maxval=200, step=1)
time_frame   = input(defval='1D',     title='RSI Time frame', type=input.resolution)
stop_loss    = input(defval=1.0,      title="Stop loss", type=input.float)
use_sperc    = input(defval=false,    title='Stop loss & tolerance are in %centage(s)', type=input.bool)
use_tstop    = input(defval=true,     title='Use trailing stop', type=input.bool)

///////////////////////////////////////////////////////////////////////////
// Calculate stop losses
stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)
if use_tstop
    stop_l := use_sperc ? close*(1-stop_loss/100.0) : (close - stop_loss)
    stop_s := use_sperc ? close*(1+stop_loss/100.0) :  (close + stop_loss)
//

////////////////////////////////////////////////////////////////////
// Get indicator signals
cum_rsi_t         = rsi(close, rsi_period) + rsi(close, rsi_period)[1] + rsi(close, rsi_period)[2]
donch_rsi_hi_t    = highest(cum_rsi_t, donch_period)
donch_rsi_lo_t    = lowest(cum_rsi_t, donch_period)
cum_rsi           = security(syminfo.tickerid, time_frame, cum_rsi_t)
donch_rsi_hi      = security(syminfo.tickerid, time_frame, donch_rsi_hi_t)
donch_rsi_lo      = security(syminfo.tickerid, time_frame, donch_rsi_lo_t)

////////////////////////////////////////////////////////////////
// Position signals
buy       = cum_rsi > donch_rsi_hi[1]
sell      = crossunder(close, stop_l[1])
short     = cum_rsi < donch_rsi_lo[1]
cover     = crossover(close, stop_s[1])

////////////////////////////////////////////////////////////////
// Execute positions
strategy.entry("long", strategy.long, when=buy)
strategy.close("long", when=sell)
strategy.entry("short", strategy.short, when=short)
strategy.close("short", when=cover)

////////////////////////////////////////////////////////////////
// Plots
plot(cum_rsi,      title="CUM RSI", color=color.green)
plot(donch_rsi_hi, title="CUM RSI HI", color=color.olive)
plot(donch_rsi_lo, title="CUM_RSI_LO", color=color.red)
