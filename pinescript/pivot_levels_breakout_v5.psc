//@version=5
strategy("Pivot Levels v2 (Using ol2 as source) - close cross with band len", overlay=true)

////////////////////////////////////////////////////////////////////
// Inputs
pivot_bars         = input.int(defval=2,               title='Pivot Bars Length')
pivot_tframe       = input.timeframe(defval='1D',      title='Pivot Time Frame')
pivot_donch_len    = input.int(defval=5,               title='Donchian smooth period for pivot levels')
pivot_band_len     = input.int(defval=5,               title='Pivot band length')
allow_shorts       = input.bool(defval=true,           title='Allow Short trades ?')

//////////////////////////////////////////////////////////////////
// Misc functions
///////////////////////////////////////////////////////
// Get data from high time frame
get_security(_src, _tf) =>
    request.security(syminfo.tickerid, _tf, _src[1], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on)
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

////////////////////////////////////////////////////////////////////
// Indicators
[phigh_san_, plow_san_] = pivots_ol2(pivot_bars, pivot_tframe)
phigh_san     = ta.highest(phigh_san_, pivot_donch_len)
plow_san      = ta.lowest(plow_san_, pivot_donch_len)
low_band      = phigh_san - pivot_band_len
high_band     = plow_san + pivot_band_len
oc2           = math.avg(open, close)

///////////////////////////////////////////////////////////////////
// Signals
buy_sig   = ta.crossover(oc2, high_band)
sell_sig  = ta.crossunder(oc2, low_band)

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
plot(high_band,    color=color.olive, title='Band High', style=plot.style_stepline)
plot(low_band,     color=color.orange, title='Band Low', style=plot.style_stepline)
