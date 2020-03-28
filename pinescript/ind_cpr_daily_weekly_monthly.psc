//@version=4
study("CPR Pivots (Daily, Weekly & Monthly)", overlay=true)

line_width = 1
line_style = plot.style_circles

cpr_pivots(time_frame) =>
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
    r3_level       = prev_high + 2*(pi_level - prev_low)
    s3_level       = prev_low - 2*(prev_high - pi_level)
    
    [pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level, r3_level, s3_level, prev_high, prev_low]
//

[d_pi_level, d_tc_level, d_bc_level, d_r1_level, d_s1_level, d_r2_level, d_s2_level, d_r3_level, d_s3_level, d_hi_level, d_lo_level] = cpr_pivots('D')
[w_pi_level, w_tc_level, w_bc_level, w_r1_level, w_s1_level, w_r2_level, w_s2_level, w_r3_level, w_s3_level, w_hi_level, w_lo_level] = cpr_pivots('W')
[m_pi_level, m_tc_level, m_bc_level, m_r1_level, m_s1_level, m_r2_level, m_s2_level, m_r3_level, m_s3_level, m_hi_level, m_lo_level] = cpr_pivots('M')


plot(d_pi_level, style=line_style, linewidth=line_width, color=color.blue,   title="Daily PI")
plot(d_bc_level, style=line_style, linewidth=line_width, color=color.blue,   title="Daily BC")
plot(d_tc_level, style=line_style, linewidth=line_width, color=color.blue,   title="Daily TC")
plot(d_hi_level, style=line_style, linewidth=line_width, color=color.olive,  title="Daily HI")
plot(d_lo_level, style=line_style, linewidth=line_width, color=color.olive,  title="Daily LO")
plot(d_r1_level, style=line_style, linewidth=line_width, color=color.green,  title="Daily R1")
plot(d_s1_level, style=line_style, linewidth=line_width, color=color.red,    title="Daily S1")
plot(d_r2_level, style=line_style, linewidth=line_width, color=color.green,  title="Daily R2")
plot(d_s2_level, style=line_style, linewidth=line_width, color=color.red,    title="Daily S2")
plot(d_r3_level, style=line_style, linewidth=line_width, color=color.green,  title="Daily R3")
plot(d_s3_level, style=line_style, linewidth=line_width, color=color.red,    title="Daily S3")


plot(w_pi_level, style=line_style, linewidth=line_width, color=color.fuchsia,   title="Weekly PI")
plot(w_bc_level, style=line_style, linewidth=line_width, color=color.fuchsia,   title="Weekly BC")
plot(w_tc_level, style=line_style, linewidth=line_width, color=color.fuchsia,   title="Weekly TC")
plot(w_hi_level, style=line_style, linewidth=line_width, color=color.purple,    title="Weekly HI")
plot(w_lo_level, style=line_style, linewidth=line_width, color=color.purple,    title="Weekly LO")
plot(w_r1_level, style=line_style, linewidth=line_width, color=color.green,     title="Weekly R1")
plot(w_s1_level, style=line_style, linewidth=line_width, color=color.red,       title="Weekly S1")
plot(w_r2_level, style=line_style, linewidth=line_width, color=color.green,     title="Weekly R2")
plot(w_s2_level, style=line_style, linewidth=line_width, color=color.red,       title="Weekly S2")
plot(w_r3_level, style=line_style, linewidth=line_width, color=color.green,     title="Weekly R3")
plot(w_s3_level, style=line_style, linewidth=line_width, color=color.red,       title="Weekly S3")

plot(m_pi_level, style=line_style, linewidth=line_width, color=color.maroon,   title="Monthly PI")
plot(m_bc_level, style=line_style, linewidth=line_width, color=color.maroon,   title="Monthly BC")
plot(m_tc_level, style=line_style, linewidth=line_width, color=color.maroon,   title="Monthly TC")
plot(m_hi_level, style=line_style, linewidth=line_width, color=color.teal,     title="Monthly HI")
plot(m_lo_level, style=line_style, linewidth=line_width, color=color.teal,     title="Monthly LO")
plot(m_r1_level, style=line_style, linewidth=line_width, color=color.green,    title="Monthly R1")
plot(m_s1_level, style=line_style, linewidth=line_width, color=color.red,      title="Monthly S1")
plot(m_r2_level, style=line_style, linewidth=line_width, color=color.green,    title="Monthly R2")
plot(m_s2_level, style=line_style, linewidth=line_width, color=color.red,      title="Monthly S2")
plot(m_r3_level, style=line_style, linewidth=line_width, color=color.green,    title="Monthly R3")
plot(m_s3_level, style=line_style, linewidth=line_width, color=color.red,      title="Monthly S3")
