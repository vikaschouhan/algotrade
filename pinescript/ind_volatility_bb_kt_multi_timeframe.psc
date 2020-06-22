//@version=4
study("BB-KT Volatility Indicator", overlay=false)

source      = input(defval=close,    type=input.source,     title='Source')
length      = input(defval=20,       type=input.integer,    title='Length', minval=1)
mult        = input(defval=2.0,      type=input.float,      title='Multiplier')
atr_p       = input(defval=14,       type=input.integer,    title='ATR Period (Only if it is used)')
tframe      = input(defval='1D',     type=input.resolution, title='Timeframe')
ema_p       = input(defval=9,        type=input.integer,    title='Volatility Smooth EMA Loopback Period')
use_atr     = input(defval=false,    type=input.bool,       title='Use ATR for Keltner ?')

// Bollinger Bands
bb_basis    = sma(source, length)
bb_dev      = mult * stdev(source, length)

bb_upper    = bb_basis + bb_dev
bb_lower    = bb_basis - bb_dev

// Keltener Channel
kt_range    = use_atr ? atr(atr_p) : tr
kt_rangema  = sma(kt_range, length)
kt_upper    = bb_basis + kt_rangema * mult
kt_lower    = bb_basis - kt_rangema * mult

vol_ind     = (bb_upper - kt_upper)
vol_ind_e   = ema(vol_ind, ema_p)
vol_ind_t   = security(syminfo.tickerid, tframe, vol_ind)
vol_ind_tt  = security(syminfo.tickerid, tframe, vol_ind_e)

plot(vol_ind_t,  color=color.blue,  linewidth=1, title='VOL_I')
plot(vol_ind_tt, color=color.black, linewidth=1, title='VOL_IS')
