//@version=5
strategy(title="ROC-pct x50 t0", shorttitle="ROC-pct x50 t0", default_qty_type=strategy.percent_of_equity, default_qty_value=100)

////////////////////////////////////////
// Inputs
length   = input.int(9, minval=1, title='ROC-pct Length')
source   = input(close, "Source")
tf       = input.timeframe('', title='ROC-pct Time Frame')
en_short = input.bool(false, title='Enable Shorts ?')

////////////////////////////////////////////
// Signals
source_roc = ta.roc(source, length)
roc_t = 100 * (source - ta.lowest(source, length))/(ta.highest(source, length) - ta.lowest(source, length))
roc2_t = 100 * (source_roc - ta.lowest(source_roc, length))/(ta.highest(source_roc, length) - ta.lowest(source_roc, length))

roc = request.security(syminfo.tickerid, tf, roc_t)
roc2 = request.security(syminfo.tickerid, tf, roc2_t)

/////////////////////////////////////////////
// Buy/Sell Signals
buy_sig = ta.crossover(roc, 50) //and (ro2 > 50)c
sell_sig = (roc == 0) //or (roc2 < 50)
short_sig = ta.crossunder(roc, 50) //and (roc2 < 50)
cover_sig = (roc == 100) //or (roc2 > 50)

////////////////////////////////////////////
// Execute positions
if buy_sig
    strategy.entry("Long", strategy.long)
//
if sell_sig
    strategy.close("Long")
//
if en_short
    if short_sig
        strategy.entry("Short", strategy.short)
    //
    if cover_sig
        strategy.close("Short")
    //
//

///////////////////////////////////////////////
// Plots
plot(roc,  color=color.lime, title="ROC")
plot(roc2, color=color.red, title="ROC2")
hline(50, color=#787B86, title="Zero Line")
