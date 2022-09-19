//@version=5
strategy("Donchian Basis crossover - v1", overlay=true)

//////////////////////////////////////////////////
// Inputs
donch_len     = input.int(200,      title='Donchian Length')
donch_lag     = input.int(10,       title='Donchian Lag')
donch_tf      = input.timeframe('', title='Donhcian Timeframe')
donch_thr     = input.float(0.0,    title='Donchian Threshold')

//////////////////////////////////////////////////
// Calculate indicators
donch_ind_tt  = math.avg(ta.highest(close, donch_len), ta.lowest(close, donch_len))
donch_ind     = request.security(syminfo.tickerid, donch_tf, donch_ind_tt[1], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on)
donch_ind_lag = request.security(syminfo.tickerid, donch_tf, donch_ind[1+donch_lag], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on)

/////////////////////////////////////////////////
// Calculate buy sell signals
buy = ta.crossover(donch_ind, donch_ind_lag) and (donch_ind > donch_ind_lag + donch_thr)
sell = ta.crossunder(donch_ind, donch_ind_lag) and (donch_ind < donch_ind_lag - donch_thr)

////////////////////////////////////////////////
// Execute positions
strategy.entry("L", strategy.long, when=buy)
strategy.entry("S", strategy.short, when=sell)

/////////////////////////////////////////////////
// Plot indicators
plot(donch_ind,     color=color.green, title='Dind')
plot(donch_ind_lag, color=color.red, title='Dind_lag')
