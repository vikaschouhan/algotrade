//@version=4
study('ATR multitimeframe with bollinger bands', overlay=false)

atr_len  = input(title="ATR Length", defval=20)
bol_len  = input(title="Bollinger Length", defval=20)
bol_mul  = input(title="Bollinger Multiplier", defval=2)
atr_res  = input(title="ATR timeframe", type=input.resolution, defval="1D")

atr_t    = atr(atr_len)
bol_bas  = sma(atr_t, bol_len)
bol_up   = bol_bas + bol_mul*stdev(atr_t, bol_len)
bol_dn   = bol_bas - bol_mul*stdev(atr_t, bol_len)

atr_ind  = security(syminfo.tickerid, atr_res, atr_t)
bolu_ind = security(syminfo.tickerid, atr_res, bol_up)
bold_ind = security(syminfo.tickerid, atr_res, bol_dn)

plot(atr_ind,  color=color.black, title='ATR')
plot(bolu_ind, color=color.green, title="BOL-U")
plot(bold_ind, color=color.red, title="BOL-D")
