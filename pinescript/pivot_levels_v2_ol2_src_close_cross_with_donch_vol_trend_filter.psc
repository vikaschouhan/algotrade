//@version=5
strategy("Pivot Levels v2 (Using ol2 as source) - close cross with Donch Vol Trend filter", overlay=true)

//////////////////////////////////////////////////////////
// Parameters - Trend filter
donch_period         = input.int(defval=20,        title='Trend Filter - Donchian Period')
donch_tf             = input.timeframe(defval='',  title='Trend Filter - Donchian Time Frame')
donch_rng_ema_period = input.int(defval=5,         title='Trend Filter - Donchian Range Smooth EMA Period')

//////////////////////////////////////////////////////////
// Parameters - Main signal
pivot_bars         = input.int(defval=1,           title='Pivot Bars Length')
pivot_tframe       = input.timeframe(defval='1D',  title='Pivot Time Frame')
cross_tolerance    = input.int(defval=0,           title='Tolerance value')
allow_shorts       = input.bool(defval=true,       title='Allow Short trades ?')

//////////////////////////////////////////////////////////////////
// Misc functions
// Get data from high time frame
get_security(_src, _tf) =>
    request.security(syminfo.tickerid, _tf, _src[1], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on)
//

///////////////////////////////////////////////////////////////
// Get a trend indicator signal from R-S levels breakouts.
get_trend_from_crossover(_sig1, _sig2) =>
    t_trend = 0.0
    if _sig1 > _sig2
        t_trend := 1
    else if _sig1 < _sig2
        t_trend := 0
    else
        t_trend := nz(t_trend[1])
        //
    //
    t_trend
//

// Get Pivots
pivots_ol2(_pivot_bars, _pivot_tf) =>
    phigh_t   = ta.pivothigh(math.avg(open, close), _pivot_bars, _pivot_bars)
    plow_t    = ta.pivotlow(math.avg(open, close), _pivot_bars, _pivot_bars)
    phigh     = phigh_t
    plow      = plow_t
    phigh_tf  = get_security(phigh_t, _pivot_tf)
    plow_tf   = get_security(plow_t, _pivot_tf)
    phigh_san = phigh_tf
    plow_san  = plow_tf
    phigh_san := nz(phigh_tf[1]) ? phigh_tf[1] : phigh_san[1]
    plow_san  := nz(plow_tf[1]) ? plow_tf[1] : plow_san[1] 
    [phigh_san, plow_san]
//

get_donch_trend(_d_period, _d_tf, _d_ema_period) =>
    donch_hi      = get_security(ta.highest(high, donch_period), donch_tf)
    donch_lo      = get_security(ta.lowest(low, donch_period), donch_tf)
    donch_rng     = donch_hi - donch_lo
    donch_rng_ema = ta.ema(donch_rng, donch_rng_ema_period)
    get_trend_from_crossover(donch_rng, donch_rng_ema)
//

////////////////////////////////////////////////////////////////////
// Indicators
[phigh_san_, plow_san_] = pivots_ol2(pivot_bars, pivot_tframe)
phigh_san     = ta.highest(phigh_san_, 1)
plow_san      = ta.lowest(plow_san_, 1)

// Trend filter
trend_filter  = get_donch_trend(donch_period, donch_tf, donch_rng_ema_period)

///////////////////////////////////////////////////////////////////
// Signals
buy_sig   = ta.crossover(close, phigh_san + cross_tolerance) and (trend_filter == 1)
sell_sig  = ta.crossunder(close, plow_san - cross_tolerance) and (trend_filter == 1)

if buy_sig
    strategy.entry("L", strategy.long)
if sell_sig
    if allow_shorts
        strategy.entry("S", strategy.short)
    else
        strategy.close("L")
    //
//

/////////////////////////////////////////////////////////////////////
// Plots
plot(phigh_san,    color=color.green, title='P+')
plot(plow_san,     color=color.red, title='P-')
//plot(trend_filter, color=color.blue, title='Trend filter')
