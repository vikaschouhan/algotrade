//@version=5
indicator("Pivot Levels v2 (Using ol2 as source)", overlay=true)

////////////////////////////////////////////////////////////////////
// Inputs
pivot_bars         = input.int(defval=2,               title='Pivot Bars Length')
pivot_tframe       = input.timeframe(defval='1D',      title='Pivot Time Frame')

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
[phigh_san, plow_san] = pivots_ol2(pivot_bars, pivot_tframe)

/////////////////////////////////////////////////////////////////////
// Plots
plot(phigh_san,    color=color.green, title='P+')
plot(plow_san,     color=color.red, title='P-')
