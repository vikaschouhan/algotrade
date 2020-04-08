//@version=4
study("RSI multiframe", overlay=false)

rsi_len   = input(title="RSI Length", defval=14)
rsi_res   = input(title="RSI timeframe", type=input.resolution, defval="1D")
rsi_elen  = input(title="EMA smooth", type=input.integer, defval=6)

rsi_ind   = rsi(close, rsi_len)
rsi_ema   = ema(rsi_ind, rsi_elen)
rsi_ind_m = security(syminfo.tickerid, rsi_res, rsi_ind)
rsi_ema_m = security(syminfo.tickerid, rsi_res, rsi_ema)

plot(rsi_ind_m, color=color.blue,  title='RSI')
plot(rsi_ema_m, color=color.olive, title='RSI-d')
plot(50.0,      color=color.red,   title='L50', linewidth=2)
