//@version=5
// Inverse Fisher Transform applied to simple smoothed RSI
//
strategy("Inverse Fisher Transform on RSI", shorttitle="IFTRSI")

/////////////////////////////////////////////////
// Parameters
ifish_rsi_length = input.int(defval=5,         title="Inv Fisher Transform - RSI Length")
ifish_wma_length = input.int(defval=9,         title="Inv Fisher Transform - RSI Smoothing length")
ifish_timeframe  = input.timeframe(defval="",  title="Inv Fisher Transform - RSI TimeFrame")

////////////////////////////////////////////////
// Signals
ifish_rsi_ind       = 0.1 * (ta.rsi(close, ifish_rsi_length) - 50)
ifish_srsi_ind      = ta.wma(ifish_rsi_ind, ifish_wma_length)
ifish_input         = request.security(syminfo.tickerid, ifish_timeframe, ifish_srsi_ind, barmerge.gaps_off, barmerge.lookahead_on)
ifish_ind           = (math.exp(2*ifish_input) - 1)/(math.exp(2*ifish_input) + 1)

/////////////////////////////////////////////////
// Positional signals
buy_sig             = ta.crossover(ifish_ind, 0)
sell_sig            = ta.crossunder(ifish_ind, 0)

/////////////////////////////////////////////////
// Execute signals
strategy.entry("L", strategy.long, when=buy_sig)
strategy.entry("S", strategy.short, when=sell_sig)

/////////////////////////////////////////////////
// Plot signals
plot(ifish_ind, color=color.green, linewidth=1)
hline(0.5, color=color.red)
hline(-0.5, color=color.green)
