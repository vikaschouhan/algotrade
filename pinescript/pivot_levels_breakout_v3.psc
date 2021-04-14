//@version=4
strategy(title="Pivot levels breakout v1", overlay=true)

///////////////////////////////////////////////////////////////////////////////
// Inputs
pivot_bars         = input(defval=2,         title='Pivot Bars Length', type=input.integer)
pivot_tframe       = input(defval='1D',      title='Pivot Time Frame', type=input.resolution)
tolerance          = input(defval=0.0,       title="Tolerance", type=input.float)
stop_loss          = input(defval=1.0,       title="Stop loss", type=input.float)
trail_stop_dlen    = input(defval=2,         title='Trailing Stop Donchian Length', type=input.integer)
pivot_donch_len    = input(defval=1,         title='Dochian smoother length', type=input.integer)
crossover_lag      = input(defval=0,         title='Crossover Lag', type=input.integer)
last_n_crossed     = input(defval=0,         title='Last n crossed', type=input.integer)
last_n_cross_lag   = input(defval=0,         title='Lag to be used for last n crossed.', type=input.integer)
pivot_smooth_ema   = input(defval=0,         title='Pivot source Smooth EMA Length', type=input.integer)
use_pivot_tframe   = input(defval=false,     title='Use Diff Pivot Time Frame', type=input.bool)
use_sperc          = input(defval=false,     title='Stop loss & tolerance are in %centage(s)', type=input.bool)
stop_type          = input(defval="simple",  title='Stop type', options=['simple', 'trail_perc', 'trail_donch'])
pivot_src          = input(defval='hl',      title='Pivot source', options=['hl', 'close', 'open'])
crossover_src      = input(defval='close',   title='Source for crossover', options=['close', 'hl/2'])

////////////////////////////////////////////////////////////////////////////////////
// Pivot source
pivot_source() =>
    phigh_src = high
    plow_src  = low
    if pivot_src == 'close'
        phigh_src := close
        plow_src  := close
    if pivot_src == 'open'
        phigh_src := open
        plow_src  := open
    if pivot_smooth_ema > 0
        phigh_src := ema(phigh_src, pivot_smooth_ema)
        plow_src  := ema(plow_src, pivot_smooth_ema)
    [phigh_src, plow_src]
//

///////////////////////////////////////////////////////////////////////////////
// Pivot signals
[ph_src, pl_src]   = pivot_source()
phigh_t            = pivothigh(ph_src, pivot_bars, pivot_bars)
plow_t             = pivotlow(pl_src, pivot_bars, pivot_bars)
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
if stop_type == 'trail_perc'
    stop_l := use_sperc ? close*(1-stop_loss/100.0) : (close - stop_loss)
    stop_s := use_sperc ? close*(1+stop_loss/100.0) :  (close + stop_loss)
//
if stop_type == 'trail_donch'
    stop_l := lowest(trail_stop_dlen)
    stop_s := highest(trail_stop_dlen)
//

//////////////////////////////////////////////////////////////////////////
// Main signals
tolbu   = use_sperc ? phigh_san*(1+tolerance/100.0) : (phigh_san+tolerance)
tolbl   = use_sperc ? plow_san*(1-tolerance/100.0) : (plow_san-tolerance)

c_src   = close
if crossover_src == 'hl/2'
    c_src := hl2
//
close_t = c_src[crossover_lag]

buy    = crossover(close_t, tolbu)
sell   = crossunder(close, stop_l[1]) or crossunder(close_t, tolbl)
short  = crossunder(close_t, tolbl)
cover  = crossover(close, stop_s[1]) or crossover(close_t, tolbu)

if last_n_crossed
    buy_sig     = (c_src > tolbu[last_n_cross_lag]) ? 1:0
    short_sig   = (c_src < tolbl[last_n_cross_lag]) ? 1:0
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
