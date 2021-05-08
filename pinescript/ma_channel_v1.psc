//@version=4
strategy("MA Channel v1", overlay=true)

ma_len      = input(10,     title='MA Length', type=input.integer)
ma_tf       = input('',     title='MA Time Frame', type=input.resolution)
ma_type     = input('sma',  title='MA Type', options=['sma', 'ema'])

get_ma() =>
    ma_high_t   = sma(high, ma_len)
    ma_low_t    = sma(low, ma_len)
    if ma_type == 'ema'
        ma_high_t := ema(high, ma_len)
        ma_low_t  := ema(low, ma_len)
    //
    [ma_high_t, ma_low_t]
//

[ma_high_t, ma_low_t] = get_ma()
ma_high = security(syminfo.tickerid, ma_tf, ma_high_t)
ma_low  = security(syminfo.tickerid, ma_tf, ma_low_t)

buy     = low > ma_high and low[1] > ma_high[1] and low[2] > ma_high[2] and low[3] > ma_high[3] //and low[4] > ma_high[4]
short   = high < ma_low and high[1] < ma_low[1] and high[2] < ma_low[2] and high[3] < ma_low[3] //and high[4] < ma_low[4]

strategy.entry("L", strategy.long, when=buy)
strategy.entry("S", strategy.short, when=short)

plot(ma_high, title='MA High')
plot(ma_low,  title='MA Low')
