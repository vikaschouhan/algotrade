//@version=4
study("EAP multitimeframe", overlay=true)

time_frame   = input(defval="W", type=input.resolution, title="Time frame")

start_time   = security(syminfo.tickerid, time_frame, time)
new_session  = iff(change(start_time), 1, 0)

//------------------------------------------------
eap_sum_fn() =>
    eap_sum = 0.0
    eap_sum := (new_session == 1) ? hl2 : (eap_sum[1]+hl2)
    eap_sum
//
e_sum_fn() =>
    p_sum = 0.0
    p_sum := (new_session == 1) ? 1 : (p_sum[1]+1)
    p_sum
//

eap_sig = eap_sum_fn()/e_sum_fn()
plot(eap_sig, title="EAP", color=color.blue)
