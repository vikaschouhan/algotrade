//@version=4
study('ATR multitimeframe', overlay=false)

atr_len = input(title="ATR Length", defval=20)
don_len = input(title="Donchian Length", defval=20)
atr_res = input(title="ATR timeframe", type=input.resolution, defval="1D")

atr_new = security(syminfo.tickerid, atr_res, atr(atr_len))
d_hi    = highest(atr_new, don_len)
d_lo    = lowest(atr_new, don_len)
d_mid   = avg(d_hi, d_lo)

plot(atr_new, color=color.black, title='ATR')
plot(d_hi, color=color.green, title="D+")
plot(d_lo, color=color.red, title="D-")
plot(d_mid, color=color.orange, title="D=")
