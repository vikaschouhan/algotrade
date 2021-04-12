//@version=4
study("Pivot Levels v1", overlay=true)

////////////////////////////////////////////////////////////////////
// Inputs
pivot_bars         = input(defval=2,         title='Pivot Bars Length', type=input.integer)
pivot_tframe       = input(defval='1D',      title='Pivot Time Frame', type=input.resolution)
use_pivot_tframe   = input(defval=false,     title='Use Diff Pivot Time Frame', type=input.bool)

///////////////////////////////////////////////////////////////////
// Get signals
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
phigh_san = phigh
plow_san  = plow
phigh_san := nz(phigh[1]) ? phigh[1] : phigh_san[1]
plow_san  := nz(plow[1]) ? plow[1] : plow_san[1] 

/////////////////////////////////////////////////////////////////////
// Plots
plot(phigh_san,    color=color.green, title='P+')
plot(plow_san,     color=color.red, title='P-')
