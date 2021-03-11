//@version=4
strategy("RSI Channel Breakout - channel stop loss", overlay=false)

///////////////////////////////////////////////////////////////////////
// Inputs
rsi_period   = input(defval=14,       title="RSI Period", type=input.integer, minval=1, maxval=100, step=1)
donch_period = input(defval=9,        title="Donch RSI Period", type=input.integer, minval=1, maxval=200, step=1)
stop_dperiod = input(defval=2,        title="Donch RSI Period for stop loss", type=input.integer)
time_frame   = input(defval='1D',     title='RSI Time frame', type=input.resolution)

////////////////////////////////////////////////////////////////////
// Get indicator signals
cum_rsi_t         = rsi(close, rsi_period) + rsi(close, rsi_period)[1] + rsi(close, rsi_period)[2]
donch_rsi_hi_t    = highest(cum_rsi_t, donch_period)
donch_rsi_lo_t    = lowest(cum_rsi_t, donch_period)
donch_stop_hi_t   = highest(cum_rsi_t, stop_dperiod)
donch_stop_lo_t   = lowest(cum_rsi_t, stop_dperiod)
cum_rsi           = security(syminfo.tickerid, time_frame, cum_rsi_t)
donch_rsi_hi      = security(syminfo.tickerid, time_frame, donch_rsi_hi_t)
donch_rsi_lo      = security(syminfo.tickerid, time_frame, donch_rsi_lo_t)
donch_stop_hi     = security(syminfo.tickerid, time_frame, donch_stop_hi_t)
donch_stop_lo     = security(syminfo.tickerid, time_frame, donch_stop_lo_t)

////////////////////////////////////////////////////////////////
// Position signals
buy       = crossover(cum_rsi, donch_rsi_hi[1])
sell      = crossunder(close, donch_stop_lo[1])
short     = crossunder(cum_rsi, donch_rsi_lo[1])
cover     = crossover(close, donch_stop_hi[1])

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
