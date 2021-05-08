//@version=4
study("macd histogram momentum v1", overlay=false)

macd_fastlen = input(12,   title='MACD fast length', type=input.integer)
macd_slowlen = input(26,   title='MACD slow length', type=input.integer)
macd_lastn   = input(10,   title='MACD last n bars', type=input.integer)
macd_tf      = input('',   title='MACD Time Frame', type=input.resolution)

[macdLine, signalLine, histLine] = security(syminfo.tickerid, macd_tf, macd(close, macd_fastlen, macd_slowlen, 9))

histline_h = highest(histLine, macd_lastn)
histline_l = lowest(histLine, macd_lastn)

histline_t = iff(histLine < histline_h[1], -1, iff(histLine > histline_l[1], 1, 0))

plot(histline_t)
