//@version=4
study("CPR Combined", overlay=true)

cpr(time_frame) =>
    prev_close     = security(syminfo.tickerid, time_frame, close[1], lookahead=true)
    prev_open      = security(syminfo.tickerid, time_frame, open[1], lookahead=true)
    prev_high      = security(syminfo.tickerid, time_frame, high[1], lookahead=true)
    prev_low       = security(syminfo.tickerid, time_frame, low[1], lookahead=true)

    pi_level       = (prev_high + prev_low + prev_close)/3
    bc_level       = (prev_high + prev_low)/2
    tc_level       = (pi_level - bc_level) + pi_level
    r1_level       = pi_level * 2 - prev_low
    s1_level       = pi_level * 2 - prev_high
    r2_level       = (pi_level - s1_level) + r1_level
    s2_level       = pi_level - (r1_level - s1_level)
    
    [pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level, prev_high, prev_low]
//

[d_pi_level, d_tc_level, d_bc_level, d_r1_level, d_s1_level, d_r2_level, d_s2_level, d_hi_level, d_lo_level] = cpr('1D')
[w_pi_level, w_tc_level, w_bc_level, w_r1_level, w_s1_level, w_r2_level, w_s2_level, w_hi_level, w_lo_level] = cpr('1W')

plot(d_bc_level, linewidth=1, color=color.blue,   title="D_BC")
plot(d_tc_level, linewidth=1, color=color.blue,   title="D_TC")
plot(d_hi_level, linewidth=1, color=color.black,  title="D_PHI")
plot(d_lo_level, linewidth=1, color=color.olive,  title="D_PLO")
plot(w_hi_level, linewidth=1, color=color.green,  title="W_PHI")
plot(w_lo_level, linewidth=1, color=color.red,    title="W_PLO")
