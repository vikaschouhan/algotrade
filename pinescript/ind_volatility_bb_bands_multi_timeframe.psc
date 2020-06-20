//@version=4
study("BB Vol MTR", overlay=true)

bb_source = input(defval=close,    type=input.source,     title='Source')
bb_length = input(defval=20,       type=input.integer,    title='Length', minval=1)
bb_mult   = input(defval=2.0,      type=input.float,      title='Multiplier', minval=0.01, maxval=50, step=0.01)
bb_tf     = input(defval='1D',     type=input.resolution, title='Timeframe')
bb_vol_el = input(defval=9,        type=input.integer,    title='EMA Length')

bb_basis  = sma(bb_source, bb_length)
bb_dev    = bb_mult * stdev(bb_source, bb_length)

bb_upper  = bb_basis + bb_dev
bb_lower  = bb_basis - bb_dev

bb_basis_t = security(syminfo.tickerid, bb_tf, bb_basis)
bb_upper_t = security(syminfo.tickerid, bb_tf, bb_upper)
bb_lower_t = security(syminfo.tickerid, bb_tf, bb_lower)
vol_t      = bb_upper_t - bb_lower_t
vol_tt     = ema(vol_t, bb_vol_el)

plot(vol_t,   color=color.green, linewidth=1, title='VOL_T')
plot(vol_tt,  color=color.black, linewidth=1, title='VOL_T_EMA')
