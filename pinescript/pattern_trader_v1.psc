//@version=4
strategy("Pattern based trader v1", overlay=true)

high_tf           = input(defval='1D',  title='Entry Resolution', options=['1m', '5m', '10m', '15m', '30m', '45m', '1h', '2h', '4h', '1D', '2D', '4D', '1W', '2W', '1M', '2M', '6M'])
donch_tf          = input(defval='1D',  title='Donchian Resolution', options=['1m', '5m', '10m', '15m', '30m', '45m', '1h', '2h', '4h', '1D', '2D', '4D', '1W', '2W', '1M', '2M', '6M'])
donch_len         = input(defval=5,     title='Donchian Length', type=input.integer)
long_only         = input(defval=false, title='Long only', type=input.bool)
pattern_type      = input(defval='c1>c2>c3',     title='Pattern type', options=['c1>c2>c3', 'c1>h2', 'contraction_v1'])

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
// Timeframe fn
get_time_frame(tf) =>
    (tf == '1m')  ? "1"
  : (tf == '5m')  ? "5"
  : (tf == '10m') ? "10"
  : (tf == '15m') ? "15"
  : (tf == '30m') ? "30"
  : (tf == '45m') ? "45"
  : (tf == '1h')  ? "60"
  : (tf == '2h')  ? "120"
  : (tf == '4h')  ? "240"
  : (tf == '1D')  ? "D"
  : (tf == '2D')  ? "2D"
  : (tf == '4D')  ? "4D"
  : (tf == '1W')  ? "W"
  : (tf == '2W')  ? "2W"
  : (tf == '1M')  ? "M"
  : (tf == '2M')  ? "2M"
  : (tf == '6M')  ? "6M"
  : "wrong resolution"
//
time_frame             = get_time_frame(high_tf)
donch_time_frame       = get_time_frame(donch_tf)

///////////////////////////////////////////////////////////////////
/// Pattern definitions
l_c1_gt_c2_gt_c3(l) =>
    close[l] > close[l+1] and close[l+1] > close[l+2]
//
s_c1_gt_c2_gt_c3(l) =>
    close[l] < close[l+1] and close[l+1] < close[l+3]
//

l_c1_gt_h2(l) =>
    close[l] > high[l+1]
s_c1_gt_h2(l) =>
    close[l] < low[l+1]
//

l_contraction_v1(l) =>
    close[l] > high[l+1] and high[l+1] < high[l+2] and high[l+2] < high[l+3] and low[l+1] > low[l+2] and low[l+2] > low[l+3]
s_contraction_v1(l) =>
    close[l] < low[l+1] and low[l+1] > low[l+2] and low[l+2] > low[l+3] and high[l+1] < high[l+2] and high[l+2] < high[l+3]

/////////////////////////////////////////////////////////////////////
/// Dochian channels
donch_hi = security(syminfo.tickerid, donch_time_frame, highest(high[1], donch_len))
donch_lo = security(syminfo.tickerid, donch_time_frame, lowest(low[1], donch_len))

/////////////////////////////////////////////////////////////////////
/// Signals
get_patterns(l) =>
    long_cond_t   = l_c1_gt_c2_gt_c3(l)
    short_cond_t  = s_c1_gt_c2_gt_c3(l)

    if pattern_type == 'c1>c2>c3'
        long_cond_t    := l_c1_gt_c2_gt_c3(l)
        short_cond_t   := s_c1_gt_c2_gt_c3(l)
    if pattern_type == 'c1>h2'
        long_cond_t    := l_c1_gt_h2(l)
        short_cond_t   := l_c1_gt_h2(l)
    //
    if pattern_type == 'contraction_v1'
        long_cond_t    := l_contraction_v1(l)
        short_cond_t   := s_contraction_v1(l)
    //
    [long_cond_t, short_cond_t]
//

[long_cond_t, short_cond_t] = get_patterns(0)
long_cond     = security(syminfo.tickerid, time_frame, long_cond_t)
short_cond    = security(syminfo.tickerid, time_frame, short_cond_t)

buy        = long_cond == 1 and long_cond[1] != 1
sell       = crossunder(close, donch_lo[1])
short      = false
cover      = false

if long_only == false
    short      := short_cond == 1 and short_cond[1] != 1
    cover      := crossover(close, donch_hi[1])
//

//////////////////////////////////////////////////////////////////////
// Positions
strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)
