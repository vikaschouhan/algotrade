//@version=4
strategy("RSI channel breakout v2", overlay=false)

///////////////////////////////////////////////////////////////////////
// Inputs
rsi_period   = input(defval=14,       title="RSI Period", type=input.integer, minval=1, maxval=100, step=1)
donch_period = input(defval=9,        title="Donch RSI Period", type=input.integer, minval=1, maxval=200, step=1)
time_frame   = input(defval='1D',     title='RSI Time frame', type=input.resolution)

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
short     = cum_rsi < donch_rsi_lo[1]

////////////////////////////////////////////////////////////////
// Execute positions
strategy.entry("long", strategy.long, when=buy)
strategy.entry("short", strategy.short, when=short)

////////////////////////////////////////////////////////////////
// Plots
plot(cum_rsi,      title="CUM RSI", color=color.green)
plot(donch_rsi_hi, title="CUM RSI HI", color=color.olive)
plot(donch_rsi_lo, title="CUM_RSI_LO", color=color.red)
