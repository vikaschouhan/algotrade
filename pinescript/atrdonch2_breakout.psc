//@version=3
strategy(title="ATRDonch 2 breakout", shorttitle="ATRDonch 2 breakout", overlay=true, slippage=20)
 
donch_len  = input(title="DonchianLength", defval=14, minval=1, step=1)
donch_len2 = input(title="DonchianLength2", defval=8, minval=1, step=1)
atr_mul    = input(title="ATRMult", defval=1.0, minval=0.1, step=0.1)
atr_len    = input(title="ATRLen", defval=14, minval=1, step=1)

hhv = highest(donch_len)
llv = lowest(donch_len)
ba  = (hhv + llv)/2
up  = highest(ba + atr_mul*atr(atr_len), donch_len2)
dn  = lowest(ba - atr_mul*atr(atr_len), donch_len2)

buy   = crossover(close, up[1])
sell  = crossunder(close, dn[1])

strategy.entry("L", strategy.long, when = buy)
strategy.entry("S", strategy.short, when = sell)

plot(up, color=red, linewidth=1)
plot(dn, color=blue, linewidth=1)
