//@version=4
strategy(title="RSI Trend isolator v1 - Ehlers Instantaneous Trend", overlay=false)

////////////////////////////////////////////////////
// Inputs
ind_src         = input(hl2,    title="Source")
ind_alpha       = input(0.07,   title="Alpha", step=0.01)
ind_rsi_len     = input(3,      title="RSI Length")
ind_timeframe   = input('1D',   title="Time Frame", type=input.resolution)
ind_rsi_thr     = input(5,      title="RSI upper and lower boundary thresholds")
stop_loss       = input(1.0,    title="Stop loss", type=input.float)
use_sperc       = input(false,  title='Stop loss & tolerance are in %centage(s)', type=input.bool)
use_tstop       = input(true,   title='Use trailing stop', type=input.bool)

///////////////////////////////////////////////////////////////////////////
// Calculate stop losses
stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)
if use_tstop
    stop_l := use_sperc ? close*(1-stop_loss/100.0) : (close - stop_loss)
    stop_s := use_sperc ? close*(1+stop_loss/100.0) :  (close + stop_loss)
//


/////////////////////////////////////////////////////
// Indicators
ehlers_itrend() =>
    ind_it          = close
    ind_lag         = close
    ind_it          := (ind_alpha-((ind_alpha*ind_alpha)/4.0))*ind_src + 0.5*ind_alpha*ind_alpha*ind_src[1] - (ind_alpha-0.75*ind_alpha*ind_alpha)*ind_src[2] + 2*(1-ind_alpha)*nz(ind_it[1], ((ind_src+2*ind_src[1]+ind_src[2])/4.0)) - (1-ind_alpha)*(1-ind_alpha)*nz(ind_it[2], ((ind_src+2*ind_src[1]+ind_src[2])/4.0))
    ind_lag         := 2.0*ind_it-nz(ind_it[2])
    [ind_it, ind_lag]
//

[ind_it_t, ind_lag_t] = ehlers_itrend()
rsi_t                 = rsi(ind_it_t, ind_rsi_len)
ind_rsi               = security(syminfo.tickerid, ind_timeframe, rsi_t)
rsi_hbnd              = 100 - ind_rsi_thr
rsi_lbnd              = ind_rsi_thr

//////////////////////////////////////////////////////
// Position signals
buy     = (ind_rsi > rsi_hbnd) and (ind_rsi[1] > rsi_hbnd) and (ind_rsi[2] > rsi_hbnd) and (ind_rsi[3] > rsi_hbnd)
sell    = crossunder(close, stop_l[1]) or crossunder(ind_rsi, rsi_hbnd)
short   = (ind_rsi < rsi_lbnd) and (ind_rsi[1] < rsi_lbnd) and (ind_rsi[2] < rsi_lbnd) and (ind_rsi[3] < rsi_lbnd)
cover   = crossover(close, stop_s[1]) or crossover(ind_rsi, rsi_lbnd)

///////////////////////////////////////////////////////
// Execute signals
strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

/////////////////////////////////////////////////////
// Plots
plot(ind_rsi,   color=color.red, linewidth=1, title="RSI - EITrend")
plot(rsi_hbnd,  color=color.black)
plot(rsi_lbnd,  color=color.black)
