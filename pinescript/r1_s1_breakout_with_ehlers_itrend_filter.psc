//@version=4
strategy("R1-S1 breakout with Ehlers I-Trend filter", overlay=true)

////////////////////////////////////////////////////////////////////////////////
// Inputs
time_frame      = input(defval="D",      type=input.resolution)
tolerance       = input(defval=5,        type=input.integer)
level_type      = input(defval='r1-s1',  options=['r1-s1', 'r2-s2', 'h-l'], type=input.string)
ind_src         = input(defval=hl2,      title="Source", type=input.source)
ind_alpha       = input(defval=0.7,      title="Alpha", step=0.01, type=input.float)
ind_timeframe   = input(defval='',       title="Time Frame", type=input.resolution)
e_lag           = input(defval=1,        title='Ehler Trend lag for detecting trend change')

////////////////////////////////////////////////////////////
// CPR
pivot_cpr(time_frame) =>
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

[pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level, prev_high, prev_low] = pivot_cpr(time_frame)

r_level = r1_level
s_level = s1_level
if level_type == 'r1-s1'
    r_level  := r1_level
    s_level  := s1_level
//
if level_type == 'r2-s2'
    r_level  := r2_level
    s_level  := s2_level
//
if level_type == 'h-l'
    r_level  := prev_high
    s_level  := prev_low
//

/////////////////////////////////////////////////////
// Ehlers I-Trend
ehlers_itrend() =>
    ind_it          = close
    ind_lag         = close
    ind_it          := (ind_alpha-((ind_alpha*ind_alpha)/4.0))*ind_src + 0.5*ind_alpha*ind_alpha*ind_src[1] - (ind_alpha-0.75*ind_alpha*ind_alpha)*ind_src[2] + 2*(1-ind_alpha)*nz(ind_it[1], ((ind_src+2*ind_src[1]+ind_src[2])/4.0)) - (1-ind_alpha)*(1-ind_alpha)*nz(ind_it[2], ((ind_src+2*ind_src[1]+ind_src[2])/4.0))
    ind_lag         := 2.0*ind_it-nz(ind_it[2])
    [ind_it, ind_lag]
//

[ind_it_t, ind_lag_t] = ehlers_itrend()
ind_it                = security(syminfo.tickerid, ind_timeframe, ind_it_t[1], lookahead=barmerge.lookahead_on, gaps=barmerge.gaps_on)
ind_lag               = security(syminfo.tickerid, ind_timeframe, ind_lag_t[e_lag], lookahead=barmerge.lookahead_on, gaps=barmerge.gaps_on)

////////////////////////////////////////////////////////////////
// Position signals
buy  = (close > r_level + tolerance) and ind_it > ind_lag
sell = (close < s_level - tolerance) and ind_it < ind_lag

////////////////////////////////////////////////////////////////
// Executing positions
strategy.entry("L", strategy.long, when=buy)
strategy.entry("S", strategy.short, when=sell)

///////////////////////////////////////////////////////////////
// Plotting
plot(r_level, style=plot.style_circles, linewidth=2, color=color.green, title="R1")
plot(s_level, style=plot.style_circles, linewidth=2, color=color.red,   title="S1")
plot(ind_it,  color=color.blue, title='Ehlers I-T')
