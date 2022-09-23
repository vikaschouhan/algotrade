//@version=5
strategy("BB mean reversion with ema filter", overlay=true)

////////////////////////////////////////////////////
// Inputs
bb_length = input.int(defval=20,         title='BB Length')
bb_mult   = input.float(defval=2.0,      title='BB Multiplier')
bb_tf     = input.timeframe(defval='',   title='BB Timeframe')
ema_len   = input.int(defval=400,        title='EMA Filter Length')
ema_tf    = input.timeframe(defval='',   title='EMA Time Frame')
exit_mode = input.string(defval='Major', title='Trade exit mode', options=['Major', 'Minor'])

///////////////////////////////////////////////////////
// Get data from high time frame
get_security(_src, _tf) =>
    request.security(syminfo.tickerid, _tf, _src[1], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on)
//

//////////////////////////////////////////////////////
// Base indicator
bb_dev    = bb_mult * ta.stdev(close, bb_length)
bb_bas    = ta.sma(close, bb_length)
bb_up     = bb_bas + bb_dev
bb_dn     = bb_bas - bb_dev
bb_up_sig = get_security(bb_up, bb_tf)
bb_dn_sig = get_security(bb_dn, bb_tf)

//////////////////////////////////////////////////////
// Trend filter
ema_sig   = get_security(ta.ema(close, ema_len), ema_tf)

//////////////////////////////////////////////////////
// Positions
buy   = ta.crossunder(close, bb_dn_sig) and (close > ema_sig)
sell  = ta.crossunder(close, bb_up_sig) or (close < ema_sig)
short = ta.crossover(close, bb_up_sig) and (close < ema_sig)
cover = ta.crossover(close, bb_dn_sig) or (close > ema_sig)

if exit_mode == 'Minor'
    sell   := ta.crossover(close, bb_up_sig) or (close < ema_sig)
    cover  := ta.crossunder(close, bb_dn_sig) or (close > ema_sig)
//

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
plot(bb_up_sig, color=color.green, linewidth=1, title='BB_Up')
plot(bb_dn_sig, color=color.red, linewidth=1, title='BB_Dn')
plot(ema_sig,   color=color.black, linewidth=1, title='EMA')
