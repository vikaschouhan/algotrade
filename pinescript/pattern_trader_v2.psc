//@version=4
strategy("Pattern trader v2", overlay=true)

inp_sl            = input(defval=0.7,     type=input.float, title="Stop Loss (x100)", step=0.1) * 100
inp_tp            = input(defval=10.0,    type=input.float, title="Take Profit (x100)", step=0.1) * 100
inp_trail         = input(defval=0.5,     type=input.float, title="Trailing Stop (x100)", step=0.1) * 100
time_frame        = input(defval='',      type=input.resolution, title="Pattern TimeFrame")

/////////////////////////////////////////////////////////////////////////
// Targets
// If the zero value is set for stop loss, take profit or trailing stop, then the function is disabled
sl = inp_sl >= 1 ? inp_sl : na
tp = inp_tp >= 1 ? inp_tp : na
trail = inp_trail >= 1 ? inp_trail : na

/////////////////////////////////////////////////////////////////////////
// Patterns
// --- Candlestick Patterns ---

get_pattern(pattern) =>
    long_sig   = true
    short_sig  = true

    if pattern == 'engulfing'
        long_sig  := high[0]>high[1] and low[0]<low[1] and open[0]<open[1] and close[0]>close[1] and close[0]>open[0] and close[1]<close[2] and close[0]>open[1]
        short_sig := high[0]>high[1] and low[0]<low[1] and open[0]>open[1] and close[0]<close[1] and close[0]<open[0] and close[1]>close[2] and close[0]<open[1]
    else if pattern == 'harami'
        long_sig  := open[1]>close[1] and close[1]<close[2] and open[0]>close[1] and open[0]<open[1] and close[0]>close[1] and close[0]<open[1] and high[0]<high[1] and low[0]>low[1] and close[0]>=open[0]
        short_sig := open[1]<close[1] and close[1]>close[2] and open[0]<close[1] and open[0]>open[1] and close[0]<close[1] and close[0]>open[1] and high[0]<high[1] and low[0]>low[1] and close[0]<=open[0]
    else if pattern == 'piercing_line_dark_cloud_cover' 
        long_sig  := close[2]>close[1] and open[0]<low[1] and close[0]>avg(open[1],close[1]) and close[0]<open[1]
        short_sig := close[2]<close[1] and open[0]>high[1] and close[0]<avg(open[1],close[1]) and close[0]>open[1]
    else if pattern == 'morning_evening_star'
        long_sig  := close[3]>close[2] and close[2]<open[2] and open[1]<close[2] and close[1]<close[2] and open[0]>open[1] and open[0]>close[1] and close[0]>close[2] and open[2]-close[2]>close[0]-open[0]
        short_sig := close[3]<close[2] and close[2]>open[2] and open[1]>close[2] and close[1]>close[2] and open[0]<open[1] and open[0]<close[1] and close[0]<close[2] and close[2]-open[2]>open[0]-close[0]
    else if pattern == 'belt_hold'
        long_sig  := close[1]<open[1] and low[1]>open[0] and close[1]>open[0] and open[0]==low[0] and close[0]>avg(close[0],open[0])
        short_sig := close[1]>open[1] and high[1]<open[0] and close[1]<open[0] and open[0]==high[0] and close[0]<avg(close[0],open[0])
    else if pattern == 'three_winter_soldiers_black_crows'
        long_sig  := close[3]<open[3] and open[2]<close[3] and close[2]>avg(close[2],open[2]) and open[1]>open[2] and open[1]<close[2] and close[1]>avg(close[1],open[1]) and open[0]>open[1] and open[0]<close[1] and close[0]>avg(close[0],open[0]) and high[1]>high[2] and high[0]>high[1]
        short_sig := close[3]>open[3] and open[2]>close[3] and close[2]<avg(close[2],open[2]) and open[1]<open[2] and open[1]>close[2] and close[1]<avg(close[1],open[1]) and open[0]<open[1] and open[0]>close[1] and close[0]<avg(close[0],open[0]) and low[1]<low[2] and low[0]<low[1]
    else if pattern == 'three_stars_in_the_south' 
        long_sig  := open[3]>close[3] and open[2]>close[2] and open[2]==high[2] and open[1]>close[1] and open[1]<open[2] and open[1]>close[2] and low[1]>low[2] and open[1]==high[1] and open[0]>close[0] and open[0]<open[1] and open[0]>close[1] and open[0]==high[0] and close[0]==low[0] and close[0]>=low[1]
    else if pattern == 'stick_sandwich'
        long_sig  := open[2]>close[2] and open[1]>close[2] and open[1]<close[1] and open[0]>close[1] and open[0]>close[0] and close[0]==close[2]
    else if pattern == 'meeting_line'
        long_sig  := open[2]>close[2] and open[1]>close[1] and close[1]==close[0] and open[0]<close[0] and open[1]>=high[0]
        short_sig := open[2]<close[2] and open[1]<close[1] and close[1]==close[0] and open[0]>close[0] and open[1]<=low[0]
    else if pattern == 'ml' 
        long_sig  := open[2]>close[2] and open[1]>close[1] and close[1]==close[0] and open[0]<close[0] and open[1]>=high[0]
        short_sig := open[2]<close[2] and open[1]<close[1] and close[1]==close[0] and open[0]>close[0] and open[1]<=low[0]
    else if pattern == 'kicking'
        long_sig  := open[1]>close[1] and open[1]==high[1] and close[1]==low[1] and open[0]>open[1] and open[0]==low[0] and close[0]==high[0] and close[0]-open[0]>open[1]-close[1]
        short_sig := open[1]<close[1] and open[1]==low[1] and close[1]==high[1] and open[0]<open[1] and open[0]==high[0] and close[0]==low[0] and open[0]-close[0]>close[1]-open[1]
    else if pattern == 'ladder_bottom'
        long_sig  := open[4]>close[4] and open[3]>close[3] and open[3]<open[4] and open[2]>close[2] and open[2]<open[3] and open[1]>close[1] and open[1]<open[2] and open[0]<close[0] and open[0]>open[1] and low[4]>low[3] and low[3]>low[2] and low[2]>low[1]
    //
    [long_sig, short_sig]
//


//////////////////////////////////////////////////////////////////////////////////////
// Get signals
[bullish_engulfing, bearish_engulfing]       = get_pattern('engulfing')
[bullish_harami, bearish_harami]             = get_pattern('harami')
[piercing_line, dark_cloud_cover]            = get_pattern('piercing_line_dark_cloud_cover') 
[morning_star, evening_star]                 = get_pattern('morning_evening_star')
[bullish_belt_hold, bearish_belt_hold]       = get_pattern('belt_hold')
[three_winter_soldiers, three_black_crows]   = get_pattern('three_winter_soldiers_black_crows')
[three_stars_in_the_south, _]                = get_pattern('three_stars_in_the_south') 
[stick_sandwich, _]                          = get_pattern('stick_sandwich')
[bullish_meeting_line, bearish_meeting_line] = get_pattern('meeting_line')
[bullish_ml, bearish_ml]                     = get_pattern('ml') 
[bullish_kicking, bearish_kicking]           = get_pattern('kicking')
[ladder_bottom, _]                           = get_pattern('ladder_bottom')

signal_long_t = bullish_engulfing or bullish_harami or piercing_line or morning_star or bullish_belt_hold or three_winter_soldiers or stick_sandwich or bullish_meeting_line or bullish_ml or bullish_kicking
signal_short_t = bearish_engulfing or bearish_harami or dark_cloud_cover or evening_star or bearish_belt_hold or three_black_crows or bearish_meeting_line or bearish_ml or bearish_kicking

signal_long = security(syminfo.tickerid, time_frame, signal_long_t)
signal_short = security(syminfo.tickerid, time_frame, signal_short_t)

/////////////////////////////////////////////////////////////////
// Execute positionsteg
strategy.entry("L", strategy.long, when=signal_long)
strategy.entry("S", strategy.short, when=signal_short)
strategy.exit("LExit", from_entry="L", profit=tp, trail_points=trail, loss=sl)
strategy.exit("SExit", from_entry="S", profit=tp, trail_points=trail, loss=sl)
