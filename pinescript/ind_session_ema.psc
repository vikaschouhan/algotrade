//@version=4
study(title="EMA-Sess", shorttitle="ESess", overlay=true)

///////////////////////////////////////////
/// Inputs
st_src       = input(defval=close,    type=input.source,     title='Source')
ema_period   = input(defval=9,        type=input.integer,    title='EMA period')
time_frame   = input(defval="D",      type=input.resolution, title="Time frame")

///////////////////////////////////////////
/// Session specific EMA (with same algo as VWAP, but without volume)
new_session  = iff(change(time(time_frame)), 1, 0)

_vap_sum_fn(src) =>
    vwap_sum = 0.0
    vwap_sum := (new_session == 1) ? src : (vwap_sum[1]+src)
    vwap_sum
//
_v_sum_fn() =>
    vol_sum = 0.0
    vol_sum := (new_session == 1) ? 1 : (vol_sum[1]+1)
    vol_sum
//

///////////////////////////////////////////
/// Signals
src_t    = ema(st_src, ema_period)
vap_sig  = _vap_sum_fn(src_t)/_v_sum_fn()

///////////////////////////////////////////
/// Plots
plot(vap_sig, title='EMA-S', color=color.red)

