//@version=4
study(title="Ehlers Instantaneous Trend", overlay=true)

////////////////////////////////////////////////////
// Inputs
ind_src         = input(hl2,    title="Source")
ind_alpha       = input(0.07,   title="Alpha", step=0.01)
ind_timeframe   = input('1D',   title="Time Frame", type=input.resolution)

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
ind_it                = security(syminfo.tickerid, ind_timeframe, ind_it_t)
ind_lag               = security(syminfo.tickerid, ind_timeframe, ind_lag_t)

/////////////////////////////////////////////////////
// Plots
plot(ind_it,   color=color.red, linewidth=1, title="Trend")
plot(ind_lag,  color=color.blue, linewidth=1, title="Trigger")
