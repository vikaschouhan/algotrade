//@version=4
study("Volume Candles", overlay=false)

candle_up = (close > open) ? 1:-1
color_up  = (candle_up == 1) ? color.green:color.red
vol_sum   = cum(volume* candle_up)
vol_open  = vol_sum[1]
vol_close = vol_sum
vol_high  = (vol_open < vol_close) ? vol_close:vol_open
vol_low   = (vol_open < vol_close) ? vol_open:vol_close

plotcandle(vol_open, vol_high, vol_low, vol_close, color=color_up)
