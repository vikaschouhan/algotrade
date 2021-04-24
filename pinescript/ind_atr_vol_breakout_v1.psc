//@version=4
study("ATR volatility breakout v1", overlay=false)

atr_len_1  = input(defval=4,     title='Shorter ATR Length', type=input.integer)
atr_len_2  = input(defval=14,    title='Longer ATR Length', type=input.integer)
atr_tf     = input(defval='',    title='ATR Time Frame', type=input.resolution)

atr_1      = security(syminfo.tickerid, atr_tf, atr(atr_len_1))
atr_2      = security(syminfo.tickerid, atr_tf, atr(atr_len_2))

plot(atr_1,  color=color.blue, title='Short ATR')
plot(atr_2,  color=color.black, title='Long ATR')
