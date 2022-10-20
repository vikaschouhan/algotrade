//@version=5
indicator("Donch range v1", overlay=false)

//////////////////////////////////////////////////////////
// Parameters
donch_period         = input.int(defval=20,        title='Donchian Period')
donch_tf             = input.timeframe(defval='',  title='Donchian Time Frame')
donch_rng_ema_period = input.int(defval=5,  title='Donchian Range Smooth EMA Period')

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
donch_rng_ema = ta.ema(donch_rng, donch_rng_ema_period)

/////////////////////////////////////////////////////////////////
// Plots
plot(donch_rng, color=color.green, title='Donchian Range Average')
plot(donch_rng_ema, color=color.blue, title='Donchian Range EMA')
