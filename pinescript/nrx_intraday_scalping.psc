//@version=4
strategy(title="NRX intraday scalping", overlay=false)

tolerance = input(defval=0.0, title="Tolerance", type=input.float)
stop_loss = input(1.0,   title="Stop loss", type=input.float)
use_sperc = input(false, title='Stop loss & tolerance are in %centage(s)', type=input.bool)
use_tstop = input(true,  title='Use trailing stop', type=input.bool)
end_hr    = input(15,    title='End session hour', type=input.integer)
end_min   = input(14,    title='End session minutes', type=input.integer)
nr_x      = input(7,     title='NRX days', type=input.integer)

//////////////////////////////////////////////////////////////////////
// Time check functions
// check if this candle is close of session
chk_close_time(hr, min) =>
    time_sig = (hour[0] == hr) and (minute[0] > min and minute[1] <= min)
    time_sig
//

// chechk if this candle doesn't fall in close session
chk_not_close_time(hr) =>
    time_ncs = (hour[0] < hr)
    [time_ncs]
//


///////////////////////////////////////////////////////////////////////
// Stop loss signals
stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)
if use_tstop
    stop_l := use_sperc ? close*(1-stop_loss/100.0) : (close - stop_loss)
    stop_s := use_sperc ? close*(1+stop_loss/100.0) :  (close + stop_loss)
//

/////////////////////////////////////////////////////////////////////////
// Primary and seconday signals
// Higher timeframe high/low
high_ht = security(syminfo.ticker, '1D', high)
low_ht  = security(syminfo.ticker, '1D', low)

// Applying tolerance to prev day high/low breakout
tolbu   = use_sperc ? high_ht*(1+tolerance/100.0) : (high_ht+tolerance)
tolbl   = use_sperc ? low_ht*(1-tolerance/100.0) : (low_ht-tolerance)

/////////////////////////////////////////////////////////////////////////
// Trading signals
// Lowest of last n day's range
range_ht_lowest = security(syminfo.ticker, '1D', lowest(abs(high-low), nr_x))
// previous day's range
range_ht_prev   = security(syminfo.ticker, '1D', abs(high-low))

// Primary trading signals (just based on previous day's high/low break)
buy    = (crossover(close, tolbu) and (hour < end_hr))
sell   = (crossunder(close, stop_l[1]) or chk_close_time(end_hr, end_min))
short  = (crossunder(close, tolbl) and (hour < end_hr))
cover  = (crossover(close, stop_s[1]) or chk_close_time(end_hr, end_min))


/////////////////////////////////////////////////////////////////////////
// Execute signals(long only in case gapups happen beyond a certain threshold and viceversa for shorts)
// Long and shorts
// Secondary trading signals. Primary signals are only executed when previous day's range is lowest of last X days's range
if range_ht_prev == range_ht_lowest
    strategy.entry("L", strategy.long, when=buy)
    strategy.entry("S", strategy.short, when=short)
//
// Closing signals
strategy.close("L", when=sell)
strategy.close("S", when=cover)

////////////////////////////////////////////////////////////////////////////////////////
// Plots
plot(range_ht_lowest, color=color.green, linewidth=1) 
plot(range_ht_prev,   color=color.red,   linewidth=1)
