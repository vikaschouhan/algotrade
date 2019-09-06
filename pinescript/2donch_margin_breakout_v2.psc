//@version=4
strategy(title="2Donch margin breakout", shorttitle="2Donch margin breakout", overlay=true, slippage=20)
 
donch_len  = input(defval=14, title="Donnchian Channel Length")
donch_slen = input(defval=1, title="Smooth Length")
margin     = input(defval=2, title="Margin Points")

hhv = highest(ema(high, donch_slen), donch_len)
llv = lowest(ema(low, donch_slen), donch_len)
ba  = (hhv + llv)/2

buy   = crossover(close, (llv + margin)[1])
sell  = crossunder(close, (hhv - margin)[1])
 
strategy.entry("L", strategy.long, when = buy)
strategy.entry("S", strategy.short, when = sell)
 
plot(hhv, color=color.red, linewidth=1, title="Donch HHV")
plot(llv, color=color.blue, linewidth=1, title="Donch LLV")
