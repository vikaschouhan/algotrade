//@version=4
strategy(title="ORB-B basis crossover with its lag - v1", overlay=true)

///////////////////////////////////////////////////////////////////////
// Inputs
time_frame_m   = input(defval='60',  title="Resolution", type=input.resolution)
time_frame_n   = input(defval='1D',  title="Time Gap", type=input.resolution)
lag_period     = input(defval=10,    title="Lag Period", type=input.integer)
smooth_period  = input(defval=1,     title='Pre-smooth period', type=input.integer)

//////////////////////////////////////////////////////////////////////////
// Misc functions
is_newbar(res) =>
    change(time(res)) != 0
//

///////////////////////////////////////////////////////////////////////////
// Main signals (ORB-B)
high_range   = valuewhen(is_newbar(time_frame_n), smooth_period ? ema(high, smooth_period) : high, 0)
low_range    = valuewhen(is_newbar(time_frame_n), smooth_period ? ema(low, smooth_period) : low,  0)
basis        = security(syminfo.tickerid, time_frame_m, avg(high_range, low_range)[1], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on)
basis_lagged = security(syminfo.tickerid, time_frame_m, avg(high_range, low_range)[1+lag_period], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on)

////////////////////////////////////////////////////////////////////////
// Positonal signals
buy   = crossover(basis, basis_lagged)
sell  = crossunder(basis, basis_lagged)

//////////////////////////////////////////////////////////////////////
// Execute positions
strategy.entry("L", strategy.long, when=buy)
strategy.entry("S", strategy.short, when=sell)

/////////////////////////////////////////////////////////////////////////
// Plots
plot(basis, color=color.green, linewidth=2)
plot(basis_lagged,  color=color.red, linewidth=2)
