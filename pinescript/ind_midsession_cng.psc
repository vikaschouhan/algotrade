//@version=4
study("Mid-Session change", overlay=true)

is_newbar2(res, sess) =>
    t_cng  = change(time(res, sess))
    tt_cng = change(na(t_cng) ? 1:0) != 0
//

plot(valuewhen(is_newbar2('D', '0900-1200'), close, 0))
