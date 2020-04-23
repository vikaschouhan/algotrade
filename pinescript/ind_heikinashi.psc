//@version=4
study("Heikin Ashi", shorttitle="Heikin Ashi", overlay=false)

////////////////////////////////
/// Inputs
time_frame = input(defval='1D',     type=input.resolution, title='Time Frame')

/////////////////////////////////
/// Signals
ha_open    = security(heikinashi(syminfo.tickerid), time_frame, open)
ha_high    = security(heikinashi(syminfo.tickerid), time_frame, high)
ha_low     = security(heikinashi(syminfo.tickerid), time_frame, low)
ha_close   = security(heikinashi(syminfo.tickerid), time_frame, close)

/////////////////////////////////
/// Plots
plotcandle(iff(ha_open < ha_close, ha_open, na), ha_high, ha_low, ha_close, title='Green Candles', color=#53b987, wickcolor=#53b987, bordercolor=#53b987)
plotcandle(iff(ha_open >= ha_close, ha_open, na), ha_high, ha_low, ha_close, title='Red Candles', color=#eb4d5c, wickcolor=#eb4d5c, bordercolor=#eb4d5c)
