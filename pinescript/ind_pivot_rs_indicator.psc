//@version=4
study("Pivot RS indicator", overlay=true)

time_frame     = input("D",       type=input.resolution)
tolerance      = input(1.0,       type=input.float)
use_sperc      = input(false,     title='Tolerance in %centage(s)', type=input.bool)
level_type     = input('r1-s1',   type=input.string, options=['r1-s1', 'r2-s2', 'h-l'])
pivot_type     = input('classic', type=input.string, options=['classic', 'fib', 'dmark'])

///////////////////////////////////////
/// Pivot point algos
pivot_dmark(time_frame) =>
    prev_close     = security(syminfo.tickerid, time_frame, close[1], lookahead=true)
    prev_open      = security(syminfo.tickerid, time_frame, open[1], lookahead=true)
    prev_high      = security(syminfo.tickerid, time_frame, high[1], lookahead=true)
    prev_low       = security(syminfo.tickerid, time_frame, low[1], lookahead=true)

    X = (prev_close > prev_open) ? (2*prev_high + prev_low + prev_close) : ((prev_close < prev_close) ? (prev_high + 2*prev_low + prev_close) : (prev_high + prev_low + 2*prev_close))
    R1 = (X/2) - prev_low
    S1 = (X/2) - prev_high
    
    [R1, S1, prev_high, prev_low]
//

pivot_fib(time_frame) =>
    prev_close     = security(syminfo.tickerid, time_frame, close[1], lookahead=true)
    prev_open      = security(syminfo.tickerid, time_frame, open[1], lookahead=true)
    prev_high      = security(syminfo.tickerid, time_frame, high[1], lookahead=true)
    prev_low       = security(syminfo.tickerid, time_frame, low[1], lookahead=true)

    PP = (prev_high + prev_low + prev_close)/3
    R1 = PP + 0.382*(prev_high - prev_low)
    S1 = PP - 0.382*(prev_high - prev_low)
    R2 = PP + 0.618*(prev_high - prev_low)
    S2 = PP - 0.618*(prev_high - prev_low)
    R3 = PP + (prev_high - prev_low)
    S3 = PP - (prev_high - prev_low)

    [PP, R1, S1, R2, S2, R3, S3, prev_high, prev_low]
//

pivot_std(time_frame) =>
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

////////////////////////////////
/// Calculate pivots
r1_level_f = 0.0
s1_level_f = 0.0
r2_level_f = 0.0
s2_level_f = 0.0
hi_level_f = 0.0
lo_level_f = 0.0
if pivot_type == 'classic'
    [pi_level, tc_level, bc_level, r1_level, s1_level, r2_level, s2_level, prev_high, prev_low] = pivot_std(time_frame)
    r1_level_f := r1_level
    s1_level_f := s1_level
    r2_level_f := r2_level
    s2_level_f := s2_level
    hi_level_f := prev_high
    lo_level_f := prev_low
//
if pivot_type == 'fib'
    [r1_level, s1_level, prev_high, prev_low] = pivot_dmark(time_frame)
    r1_level_f := r1_level
    s1_level_f := s1_level
    r2_level_f := r1_level
    s2_level_f := s1_level
    hi_level_f := prev_high
    lo_level_f := prev_low
//
if pivot_type == 'dmark'
    [pi_level, r1_level, s1_level, r2_level, s2_level, r3_level, s3_level, prev_high, prev_low] = pivot_fib(time_frame)
    r1_level_f := r1_level
    s1_level_f := s1_level
    r2_level_f := r2_level
    s2_level_f := s2_level
    hi_level_f := prev_high
    lo_level_f := prev_low
//

////////////////////////////////////
/// Calculate final levels
r_level  = 0.0
s_level  = 0.0
if level_type == 'r1-s1'
    r_level   := r1_level_f
    s_level   := s1_level_f
//
if level_type == 'r2-s2'
    r_level   := r2_level_f
    s_level   := s2_level_f
//
if level_type == 'h-l'
    r_level   := hi_level_f
    s_level   := lo_level_f
//

////////////////////////////////////////
/// Calculate final signal
trend      = 0.0
tolbu      = use_sperc ? r_level*(1+tolerance/100.0) : (r_level+tolerance)
tolbl      = use_sperc ? s_level*(1-tolerance/100.0) : (s_level-tolerance)
trend      := (close > tolbu) ? 1 : (close < tolbl) ? -1 : nz(trend[1], 1)
strat_sig  = (trend == 1) ? tolbl : tolbu

//////////////////////////////////////
/// Plot signal
plot(strat_sig, linewidth=2, color=color.green, title="Signal")
