//@version=4
strategy("DEMA crossover with multiframe RSI filter", overlay=true, slippage=20)

dema_short_len = input(title="DEMA fast len", defval=3)
dema_long_len  = input(title="DEMA slow len", defval=10)
rsi_len        = input(title="RSI len", defval=14)
rsi_low_lim    = input(title="RSI oversold limit", defval=30)
rsi_high_lim   = input(title="RSI overbought limit", defval=50)
rsi_res        = input(title="RSI timeframe", type=input.resolution, defval="1D")

dema(src, dlen) =>
    retv = (2 * ema(src, dlen) - (ema(ema(src, dlen), dlen)))

rsi_ind   = rsi(close, rsi_len)
rsi_ind_m = security(syminfo.tickerid, rsi_res, rsi_ind)

dema_short = dema(close, dema_short_len)
dema_long  = dema(close, dema_long_len)

buy   = crossover(dema_short, dema_long) and (rsi_ind_m < rsi_low_lim)
sell  = crossunder(dema_short, dema_long)
short = crossunder(dema_short, dema_long) and (rsi_ind_m > rsi_high_lim)
cover = crossover(dema_short, dema_long)

strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

plot(dema_short, color=color.green, title="DEMA fast")
plot(dema_long, color=color.red, title="DEMA slow")
