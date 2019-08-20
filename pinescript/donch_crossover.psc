//@version=4
strategy(title='Donch Crossover', shorttitle='Donch Crossover', overlay=true, slippage=20)

donch_1   = input(defval=25, title="Short Donchian Length")
donch_2   = input(defval=30, title="Long Donchian Length")

bas_1     = (highest(donch_1) + lowest(donch_1))/2
bas_2     = (highest(donch_2) + lowest(donch_2))/2

buy       = crossover(bas_1, bas_2)
sell      = crossunder(bas_1, bas_2)

strategy.entry("long", strategy.long, when = buy)
strategy.entry("short", strategy.short, when = sell)

plot(bas_1, color=color.red)
plot(bas_2, color=color.green)
