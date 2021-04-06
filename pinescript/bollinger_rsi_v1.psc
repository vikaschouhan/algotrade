//@version=4
strategy("Bollinger + RSI v1", overlay=true)

rsi_length         = input(defval=6,      title='RSI Length', type=input.integer)
rsi_threshold      = input(defval=20,     title='RSI threshold', type=input.integer, maxval=100, minval=0)
rsi_timeframe      = input(defval='1D',   title='RSI Timeframe', type=input.resolution)
bb_length          = input(defval=200,    title='Bollinger Bands Length', type=input.integer)
bb_mult            = input(defval=2,      title='Bollinger Bands Multiplier', type=input.integer)
bb_timeframe       = input(defval='1D',   title='Bollinger Bands TimeFrame', type=input.resolution)
long_only          = input(defval=true,   title='Long only', type=input.bool)

////////////////////////////////////////////////
/// Calculate RSI
rsi_oversold       = 100-rsi_threshold
rsi_overbought     = rsi_threshold
rsi_ind_t          = rsi(close, rsi_length)
rsi_ind            = security(syminfo.tickerid, rsi_timeframe, rsi_ind_t)

/////////////////////////////////////////////////
/// Bollinger Bands
bb_basis           = sma(close, bb_length)
bb_dev             = bb_mult * stdev(close, bb_length)
bb_upper_t         = bb_basis + bb_dev
bb_lower_t         = bb_basis - bb_dev
bb_upper           = security(syminfo.tickerid, bb_timeframe, bb_upper_t)
bb_lower           = security(syminfo.tickerid, bb_timeframe, bb_lower_t)

////////////////////////////////////////////////////
/// Define & Execute Positions
buy                = crossover(close, bb_lower) and crossover(rsi_ind, rsi_oversold)
short              = crossunder(close, bb_upper) and crossunder(rsi_ind, rsi_overbought)

strategy.entry("L", strategy.long, when=buy)
if long_only
    strategy.close("L", when=short)
else
    strategy.entry("S", strategy.short, when=short)
//

////////////////////////////////////////////////////
/// Plots
plot(bb_upper,       color=color.green, title='BB+')
plot(bb_lower,       color=color.red, title='BB-')
