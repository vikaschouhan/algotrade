//@version=4
study("Donchian Multi Timeframe - Close only", overlay=true)

donch_len = input(title="Donchian length", defval=2, minval=1)
donch_res = input(title="Dinchian Resolution", defval='1D', type=input.resolution)

donch_hi  = highest(close, donch_len)
donch_lo  = lowest(close, donch_len)

donch_hi_tf = security(syminfo.tickerid, donch_res, donch_hi)
donch_lo_tf = security(syminfo.tickerid, donch_res, donch_lo)

plot(donch_hi_tf, color=color.green, title='Donch HI')
plot(donch_lo_tf, color=color.red, title='Donch LO')
