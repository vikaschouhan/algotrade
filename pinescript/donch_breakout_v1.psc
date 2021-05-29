//@version=4
strategy("Donchian Breakout v1", overlay=true)

////////////////////////////////////
// Inputs
donch_len      = input(title="Donchian length", defval=2, minval=1)
donch_res      = input(title="Dinchian Resolution", defval='', type=input.resolution)
tolerance      = input(defval=0.0,        type=input.float)
stop_loss      = input(defval=10.0,       title="Stop loss", type=input.float)
use_sperc      = input(defval=true,       title='Stop loss & tolerance are in %centage(s)', type=input.bool)
use_tstop      = input(defval=true,       title='Use trailing stop', type=input.bool)
long_only      = input(defval=true,       title='Long only', type=input.bool)

/////////////////////////////////////
/// Calculate stops
stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)
if use_tstop
    stop_l := use_sperc ? close*(1-stop_loss/100.0) : (close-stop_loss)
    stop_s := use_sperc ? close*(1+stop_loss/100.0) : (close+stop_loss)
//


donch_hi  = highest(close, donch_len)
donch_lo  = lowest(close, donch_len)

donch_hi_tf = security(syminfo.tickerid, donch_res, donch_hi)
donch_lo_tf = security(syminfo.tickerid, donch_res, donch_lo)

//////////////////////////////////////
/// Calculate actual levels after adjusting for tolerance
tolbu  = use_sperc ? donch_hi_tf*(1+tolerance/100.0) : (donch_hi_tf+tolerance)
tolbl  = use_sperc ? donch_lo_tf*(1-tolerance/100.0) : (donch_lo_tf-tolerance)

buy    = crossover(close, tolbu[1])
sell   = crossunder(close, stop_l[1]) //or crossunder(close, tolbl[1])
short  = crossunder(close, tolbl[1])
cover  = crossover(close, stop_s[1]) //or crossover(close, tolbu[1])

/////////////////////////////////////////
/// Execute signals
strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
if long_only == false
    strategy.entry("S", strategy.short, when=short)
    strategy.close("S", when=cover)
//

///////////////////////////////////////////
// Plot signals
plot(donch_hi_tf, color=color.green, title='Donch HI')
plot(donch_lo_tf, color=color.red, title='Donch LO')
