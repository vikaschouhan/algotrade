//@version=4
strategy("Bollinger Bands Mean Reversion", overlay=true, slippage=20)

bb_length = input(title="BBLength", defval=20, minval=1)
bb_mult   = input(title="BBMult", defval=2.0, minval=0.001, maxval=50, step=0.1)

bb_basis = sma(close, bb_length)
bb_dev   = bb_mult * stdev(close, bb_length)

bb_upper = bb_basis + bb_dev
bb_lower = bb_basis - bb_dev

buy  = crossover(close, bb_lower)
sell = crossunder(close, bb_upper)

strategy.entry("Long", strategy.long, when = buy)
strategy.entry("Short", strategy.short, when = sell)


plot(bb_basis, title="BB-middle", color=color.red)
plot(bb_upper, title="BB-upper", color=color.olive)
plot(bb_lower, title="BB-lower", color=color.green)
