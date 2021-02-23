//@version=4
strategy("Bollinger Bands Mean Reversion MTR", overlay=true, slippage=20)

////////////////////////////////////////////////////////////////////////
// Inputs
bb_length  = input(title="BBLength",        defval=20, minval=1)
bb_mult    = input(title="BBMult",          defval=2.0, minval=0.001, maxval=50, step=0.1)
bb_tf      = input(title="BBTimeFrame",     defval='1D', type=input.resolution)
stop_loss  = input(defval=1.0,              title="Stop loss", type=input.float)
use_sperc  = input(defval=false,            title='Stop loss & tolerance are in %centage(s)', type=input.bool)
use_tstop  = input(defval=true,             title='Use trailing stop', type=input.bool)


///////////////////////////////////////////////////////////////////////////
// Indicator calculation
bb_basis_i    = sma(close, bb_length)
bb_dev_i      = bb_mult * stdev(close, bb_length)
bb_upper      = security(syminfo.tickerid, bb_tf, bb_basis_i + bb_dev_i)
bb_lower      = security(syminfo.tickerid, bb_tf, bb_basis_i - bb_dev_i)
bb_basis      = security(syminfo.tickerid, bb_tf, bb_basis_i)

//////////////////////////////////////////////////////////////////////////////
// Stop loss calculation
stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)
if use_tstop
    stop_l := use_sperc ? close*(1-stop_loss/100.0) : (close - stop_loss)
    stop_s := use_sperc ? close*(1+stop_loss/100.0) :  (close + stop_loss)

///////////////////////////////////////////////////////////////////////
// Execution signals
buy       = crossover(close, bb_lower)
sell      = crossunder(close, bb_upper) or crossunder(close, stop_l[1])
short     = crossunder(close, bb_upper)
cover     = crossover(close, bb_lower) or crossover(close, stop_s[1])

strategy.entry("Long",  strategy.long,  when=buy)
strategy.entry("Short", strategy.short, when=short)
strategy.close("Long",  when=sell)
strategy.close("Short", when=cover)

/////////////////////////////////////////////////////////////////
// Plots
plot(bb_basis, title="BB-middle", color=color.red)
plot(bb_upper, title="BB-upper", color=color.olive)
plot(bb_lower, title="BB-lower", color=color.green)
