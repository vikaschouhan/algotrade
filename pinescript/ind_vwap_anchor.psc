//@version=4
study("VWAP multitimeframe", overlay=true)

time_frame   = input(defval="W", type=input.resolution, title="Time frame")

start_time   = security(syminfo.tickerid, time_frame, time)
new_session  = iff(change(start_time), 1, 0)

//------------------------------------------------
vwap_sum_fn() =>
    vwap_sum = 0.0
    vwap_sum := (new_session == 1) ? (hl2*volume) : (vwap_sum[1]+hl2*volume)
    vwap_sum
//
vol_sum_fn() =>
    vol_sum = 0.0
    vol_sum := (new_session == 1) ? volume : (vol_sum[1]+volume)
    vol_sum
//

vwap_sig = vwap_sum_fn()/vol_sum_fn()
plot(vwap_sig, title="VWAP", color=color.blue)
