//@version=5
strategy("Donchian swing trader v1", overlay=true, process_orders_on_close=true)

///////////////////////////////////////////////////////
// Parameters
///////////////////////////////////////////////////////
donch_period   = input.int(defval=20,       title='Donchian Time Frame')
donch_stop_thr = input.float(defval=0,      title='Donchian Stop Threshold', step=1.0)
donch_tf       = input.timeframe(defval='', title='Donchian Time Frame')
allow_short    = input.bool(defval=true,    title='Allow Short trades')

///////////////////////////////////////////////////////
// Get data from high time frame
get_security(_src, _tf) =>
    request.security(syminfo.tickerid, _tf, _src[1], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on)
//

///////////////////////////////////////////////////////
// Indicators
donch_hi       = get_security(ta.highest(high, donch_period), donch_tf)
donch_lo       = get_security(ta.lowest(low, donch_period), donch_tf)
donch_bas      = math.avg(donch_hi, donch_lo)

//////////////////////////////////////////////////////////
// Position signals
//////////////////////////////////////////////////////////
buy_signal     = ta.crossover(close, donch_bas[1]) or ((close > high[1]) and (close > donch_bas))
sell_signal    = (close < low[1] - donch_stop_thr) or ta.crossunder(close, donch_bas[1])
short_signal   = ta.crossunder(close, donch_bas[1]) or ((close < low[1]) and (close < donch_bas))
cover_signal   = (close > high[1] + donch_stop_thr) or ta.crossover(close, donch_bas[1])

/////////////////////////////////////////////////////////
// Execute positions
//////////////////////////////////////////////////////////
if buy_signal
    strategy.entry("L", strategy.long)
if sell_signal
    strategy.close("L")
if allow_short
    if short_signal
        strategy.entry("S", strategy.short)
    if cover_signal
        strategy.close("S")
    //
//

/////////////////////////////////////////////////////////
// Plots
/////////////////////////////////////////////////////////
plot(donch_bas, "DHI", color.aqua)
