//@version=4
study("Bollinger Bands MTR", overlay=true)

bb_source = input(defval=close,    type=input.source,  title='Source')
bb_length = input(defval=20,       type=input.integer, title='Length', minval=1)
bb_mult   = input(defval=2.0,      type=input.float,   title='Multiplier', minval=0.01, maxval=50, step=0.01)
bb_tf     = input(defval='1D',     type=input.resolution, title='Timeframe')

bb_basis  = sma(bb_source, bb_length)
bb_dev    = bb_mult * stdev(bb_source, bb_length)

bb_upper  = bb_basis + bb_dev
bb_lower  = bb_basis - bb_dev

bb_basis_t = security(syminfo.tickerid, bb_tf, bb_basis)
bb_upper_t = security(syminfo.tickerid, bb_tf, bb_upper)
bb_lower_t = security(syminfo.tickerid, bb_tf, bb_lower)

plot(bb_upper_t, color=color.green, linewidth=1, title='BB_U')
plot(bb_lower_t, color=color.red,   linewidth=1, title='BB_L')
plot(bb_basis_t, color=color.black, linewidth=1, title='BB_B')
