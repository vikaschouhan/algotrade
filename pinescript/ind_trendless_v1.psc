//@version=4
study("trendless indicator v1", overlay=false)

rsi_len  = input(14, title='RSI Length', type=input.integer)
rsi_bhi  = input(60, title='RSI Band High', type=input.integer)
rsi_blo  = input(40, title='RSI Band Low', type=input.integer)
rsi_dlen = input(50, title='RSI Donchian Length', type=input.integer)
rsi_tf   = input('', title='RSI Time Frame', type=input.resolution)

rsi_t    = security(syminfo.tickerid, rsi_tf, rsi(close, rsi_len))
tr_less  = iff((highest(rsi_t, rsi_dlen) <= rsi_bhi and lowest(rsi_t, rsi_dlen) >= rsi_blo), 1.0, 0.0)

plot(tr_less)
