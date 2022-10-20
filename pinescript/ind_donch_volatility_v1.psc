//@version=5
indicator("Donch volatility v1", overlay=false)

//////////////////////////////////////////////////////////
// Parameters
donch_period       = input.int(defval=20,        title='Donchian Period')
donch_tf           = input.timeframe(defval='',  title='Donchian Time Frame')
donch_donch_period = input.int(defval=20,  title='Donchian of Donchian Range Period')

//////////////////////////////////////////////////////////////////
// Misc functions
// Get data from high time frame
get_security(_src, _tf) =>
    request.security(syminfo.tickerid, _tf, _src[1], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on)
//

////////////////////////////////////////////////////////////////
// Indicators
donch_hi      = get_security(ta.highest(high, donch_period), donch_tf)
donch_lo      = get_security(ta.lowest(low, donch_period), donch_tf)
donch_rng     = donch_hi - donch_lo
donch_rng_hi  = ta.highest(donch_rng, donch_donch_period)
donch_rng_lo  = ta.lowest(donch_rng, donch_donch_period)
donch_rng_avg = math.avg(donch_rng_hi, donch_rng_lo)

/////////////////////////////////////////////////////////////////
// Plots
plot(donch_rng_avg, color=color.green, title='Donchian Range Average')
