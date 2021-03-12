//@version=4
study(title="RSI - EMA", overlay=false)

///////////////////////////////////////////////////////////////////////
// Inputs
time_frame   = input(defval='1D',  title="Resolution", type=input.resolution)
ema_len      = input(defval=2,     title="EMA Length")
rsi_len      = input(defval=2,     title="RSI Length")

///////////////////////////////////////////////////////////////////////
// Indicators
ema_ind_t    = ema(close, ema_len)
rsi_ind_t    = rsi(ema_ind_t, rsi_len)
rsi_ind      = security(syminfo.tickerid, time_frame, rsi_ind_t)

/////////////////////////////////////////////////////////////////////////
// Plots
plot(rsi_ind, color=color.green, linewidth=1)
