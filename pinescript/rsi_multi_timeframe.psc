//@version=4
study("RSI multiframe", overlay=false)

rsi_len = input(title="RSI Length", defval=14)
rsi_res = input(title="RSI timeframe", type=input.resolution, defval="1D")

rsi_ind   = rsi(close, rsi_len)
rsi_ind_m = security(syminfo.tickerid, rsi_res, rsi_ind)

plot(rsi_ind_m, color=color.blue)
