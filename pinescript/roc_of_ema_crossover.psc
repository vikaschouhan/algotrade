//@version=5
strategy(title="ROC of ema crossover", shorttitle="ROC of ema crossover", default_qty_type=strategy.percent_of_equity, default_qty_value=100)

////////////////////////////////////////
// Inputs
roc_length   = input.int(9, minval=1, title='ROC Length')
roc_thresh   = input.int(0, title='ROC Threshold')

////////////////////////////////////////////
// Signals
roc_signal = ta.roc(ta.sma(close, roc_length), roc_length)

/////////////////////////////////////////////
// Buy/Sell Signals
buy_sig = ta.crossover(roc_signal, roc_thresh)
sell_sig = ta.crossunder(roc_signal, 0)

////////////////////////////////////////////
// Execute positions
if buy_sig
    strategy.entry("Long", strategy.long)
//
if sell_sig
    strategy.close("Long")
//

///////////////////////////////////////////////
// Plots
plot(roc_signal,  color=color.lime, title="ROC")
