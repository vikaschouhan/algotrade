//@version=4
strategy("MACD crossover", overlay=false, slippage=20)

macd_fast_len = input(title="MACD Fast Length", type=input.integer, defval=9)
macd_slow_len = input(title="MACD Slow Length", type=input.integer, defval=26)
macd_sig_len = input(title="MACD Sig Length", type=input.integer, defval=9)

macd_fast_ma = sma(close, macd_fast_len)
macd_slow_ma = sma(close, macd_slow_len)
macd_macd = macd_fast_ma - macd_slow_ma
macd_signal = sma(macd_macd, 9)

buy = crossover(macd_macd, macd_signal) and macd_macd > 0
sell = crossunder(macd_macd, macd_signal) or crossunder(macd_macd, 0)
short = crossunder(macd_macd, macd_signal) and macd_macd < 0
cover = crossover(macd_macd, macd_signal) or crossover(macd_macd, 0)

strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=sell)
strategy.close("S", when=cover)

plot(macd_macd, color=color.red, title="MACD")
plot(macd_signal, color=color.blue, title="MACD Sig")
