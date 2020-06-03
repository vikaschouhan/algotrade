//@version=4
study("Ohlc Multi TimeFrame", overlay=true)

// inputs
time_frame = input('1D', type=input.resolution, title='Time Frame')

// Get multi timeframe OHLC
open_t  = security(syminfo.tickerid, time_frame, open)
close_t = security(syminfo.tickerid, time_frame, close)
high_t  = security(syminfo.tickerid, time_frame, high)
low_t   = security(syminfo.tickerid, time_frame, low)

// Plot
plot(open_t,   color=color.green,   title='O')
plot(close_t,  color=color.red,     title='C')
plot(high_t,   color=color.orange,  title='H')
plot(low_t,    color=color.olive,   title='L')
