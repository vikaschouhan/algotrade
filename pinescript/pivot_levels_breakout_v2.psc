//@version=4
strategy(title="Pivot levels breakout v1", overlay=true)

///////////////////////////////////////////////////////////////////////////////
// Inputs
pivot_bars         = input(defval=2,         title='Pivot Bars Length', type=input.integer)
pivot_tframe       = input(defval='1D',      title='Pivot Time Frame', type=input.resolution)
use_pivot_tframe   = input(defval=false,     title='Use Diff Pivot Time Frame', type=input.bool)
tolerance          = input(defval=0.0,       title="Tolerance", type=input.float)
stop_loss          = input(defval=1.0,       title="Stop loss", type=input.float)
use_sperc          = input(defval=false,     title='Stop loss & tolerance are in %centage(s)', type=input.bool)
use_tstop          = input(defval=true,      title='Use trailing stop', type=input.bool)
pivot_donch_len    = input(defval=1,         title='Dochian smoother length', type=input.integer)
crossover_lag      = input(defval=0,         title='Crossover Lag', type=input.integer)
last_n_crossed     = input(defval=0,         title='Last n crossed', type=input.integer)
last_n_cross_lag   = input(defval=0,         title='Lag to be used for last n crossed.', type=input.integer)

///////////////////////////////////////////////////////////////////////////////
// Pivot signals
phigh_t            = pivothigh(pivot_bars, pivot_bars)
plow_t             = pivotlow(pivot_bars, pivot_bars)
phigh              = phigh_t
plow               = plow_t
phigh_tf           = security(syminfo.tickerid, pivot_tframe, phigh_t)
plow_tf            = security(syminfo.tickerid, pivot_tframe, plow_t)
if use_pivot_tframe
    phigh  := phigh_tf
    plow   := plow_tf
//
phigh_san_t = phigh
plow_san_t  = plow
phigh_san_t := nz(phigh[1]) ? phigh[1] : phigh_san_t[1]
plow_san_t  := nz(plow[1]) ? plow[1] : plow_san_t[1]
phigh_san   = highest(phigh_san_t, pivot_donch_len)
plow_san    = lowest(plow_san_t, pivot_donch_len)

///////////////////////////////////////////////////////////////////////////////
// Stop losses
stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)
if use_tstop
    stop_l := use_sperc ? close*(1-stop_loss/100.0) : (close - stop_loss)
    stop_s := use_sperc ? close*(1+stop_loss/100.0) :  (close + stop_loss)
//

//////////////////////////////////////////////////////////////////////////
// Main signals
tolbu   = use_sperc ? phigh_san*(1+tolerance/100.0) : (phigh_san+tolerance)
tolbl   = use_sperc ? plow_san*(1-tolerance/100.0) : (plow_san-tolerance)
close_t = close[crossover_lag]

buy    = crossover(close_t, tolbu)
sell   = crossunder(close, stop_l[1]) or crossunder(close_t, tolbl)
short  = crossunder(close_t, tolbl)
cover  = crossover(close, stop_s[1]) or crossover(close_t, tolbu)

if last_n_crossed
    buy_sig     = (close > tolbu[last_n_cross_lag]) ? 1:0
    short_sig   = (close < tolbl[last_n_cross_lag]) ? 1:0
    buy      := sum(buy_sig, last_n_crossed) == last_n_crossed ? true: false
    short    := sum(short_sig, last_n_crossed) == last_n_crossed ? true: false

strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

////////////////////////////////////////////////////////////////////////////
// Plots
plot(phigh_san, color=color.green, title='P+') 
plot(plow_san,  color=color.red, title='P-')
