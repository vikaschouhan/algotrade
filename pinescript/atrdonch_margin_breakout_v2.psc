//@version=3
strategy(title="ATRDonch Margin Breakout v2", shorttitle="ATRDonch Margin Breakout v2", overlay=true, slippage=20)
 
donch_len  = input(title="DonchianLength", defval=14, minval=1, step=1)
smooth_len = input(title="SmoothLength", defval=1, minval=1, step=1)
margin     = input(title="Margin", defval=2.0, minval=0.0, step=1)
atr_mul    = input(title="ATRMult", defval=1.0, minval=0.1, step=0.1)
atr_len    = input(title="ATRLen", defval=14, minval=1, step=1)

hhv = highest(ema(high, smooth_len), donch_len)
llv = lowest(ema(low, smooth_len), donch_len)
ba  = (hhv + llv)/2
up  = ba + atr_mul*atr(atr_len)
dn  = ba - atr_mul*atr(atr_len)

buy   = crossover(close, dn[1] + margin)
sell  = crossunder(close, up[1] - margin)
 
strategy.entry("L", strategy.long, when = buy)
strategy.entry("S", strategy.short, when = sell)
 
plot(hhv, color=red, linewidth=1)
plot(llv, color=blue, linewidth=1)
