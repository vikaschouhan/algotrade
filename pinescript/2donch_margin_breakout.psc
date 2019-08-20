//@version=4
strategy(title="2Donch margin breakout", shorttitle="2Donch margin breakout", overlay=true, slippage=20)
 
donch_len  = input(defval=14, title="Donnchian Channel Length")
margin     = input(defval=2, title="Margin Points")
donch_len2 = input(defval=2, title="Double Donchian Length")

hhv = highest(highest(donch_len)[1], donch_len2)
llv = lowest(lowest(donch_len)[1], donch_len2)
ba  = (hhv + llv)/2

buy   = crossover(close, (hhv + margin)[1])
sell  = crossunder(close, (llv - margin)[1])
 
strategy.entry("L", strategy.long, when = buy)
strategy.entry("S", strategy.short, when = sell)
 
plot(hhv, color=color.red, linewidth=1, title="Donch HHV")
plot(llv, color=color.blue, linewidth=1, title="Donch LLV")
