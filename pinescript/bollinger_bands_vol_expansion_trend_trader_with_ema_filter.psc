//@version=5
strategy("BB Vol expansion trend trader", overlay=false)

////////////////////////////////////////////////////
// Inputs
bb_length = input.int(defval=20,         title='BB Length')
bb_tf     = input.timeframe(defval='',   title='BB Timeframe')
bb_lag    = input.int(defval=1,          title='BB Lookback period for detecting rising/falling')
ema_len   = input.int(defval=400,        title='EMA Filter Length')
ema_tf    = input.timeframe(defval='',   title='EMA Time Frame')

///////////////////////////////////////////////////////
// Get data from high time frame
get_security(_src, _tf) =>
    request.security(syminfo.tickerid, _tf, _src[1], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on)
//

//////////////////////////////////////////////////////
// Base indicator
bb_dev    = 2.0 * ta.stdev(close, bb_length)
bb_range  = get_security(2 * bb_dev, bb_tf)

//////////////////////////////////////////////////////
// Trend filter
ema_sig   = get_security(ta.ema(close, ema_len), ema_tf)

//////////////////////////////////////////////////////
// Positions
buy   = (bb_range > bb_range[bb_lag]) and (close > ema_sig)
sell  = (bb_range < bb_range[bb_lag]) or (close < ema_sig)
short = (bb_range > bb_range[bb_lag]) and (close < ema_sig)
cover = (bb_range < bb_range[bb_lag]) or (close > ema_sig)

//////////////////////////////////////////////////////
// Execute positions
if buy
    strategy.entry("L", strategy.long)
if sell and strategy.position_size > 0
    strategy.close("L")
if short
    strategy.entry("S", strategy.short)
if cover and strategy.position_size < 0
    strategy.close("S")
    
///////////////////////////////////////////////////////
// Plots
plot(bb_range, color=color.green, linewidth=1, title='BB_Range')
