//@version=4
strategy("RSI + EMA Crossover", overlay=true, slippage=20)

rsi_len = input(title="RSI Length",       type=input.integer, defval=9)
rsi_trs = input(title="RSI timeframe",    type=input.resolution, defval='1D')
es_len  = input(title="EMA short Length", type=input.integer, defval=5)
el_len  = input(title="EMA long Length",  type=input.integer, defval=9)

rsi_sig   = security(syminfo.tickerid, rsi_trs, rsi(close, rsi_len))
ema_short = ema(close, es_len)
ema_long  = ema(close, el_len)

buy    = ((rsi_sig > rsi_sig[1]) and (rsi_sig > 50) and crossover(ema_short, ema_long)) or ((ema_short > ema_long) and crossover(rsi_sig, 50))
sell   = crossunder(ema_short, ema_long) //or crossunder(rsi_sig, 50)
short  = ((rsi_sig < rsi_sig[1]) and (rsi_sig < 50) and crossunder(ema_short, ema_long)) or ((ema_short < ema_long) and crossunder(rsi_sig, 50))
cover  = crossover(rsi_sig, 50) //or crossover(ema_short, ema_long)

strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

plot(ema_short, color=color.red, title="EMAs")
plot(ema_long, color=color.blue, title="EMAl")
