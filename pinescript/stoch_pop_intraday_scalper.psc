//@version=4
strategy("Stochastic POP Intraday scalper", overlay=false)

stoch_length       = input(defval=14,   title='Stochastic Length',   type=input.integer)
smooth_k           = input(defval=3,    title='SmoothK',             type=input.integer)
smooth_d           = input(defval=3,    title='SmoothD',             type=input.integer)
level_margin       = input(defval=25,   title='Level margin',        type=input.integer, minval=0, maxval=100)
tframe             = input(defval='60', title='Stochastic Timeframe',type=input.resolution)
stop_loss          = input(1.0,         title="Stop loss",           type=input.float)
use_sperc          = input(false,       title='Stop loss & tolerance are in %centage(s)', type=input.bool)
use_iday           = input(false,       title='Use intraday',        type=input.bool)
use_tstop          = input(true,        title='Use trailing stop',   type=input.bool)
end_hr             = input(15,          title='End session hour',    type=input.integer)
end_min            = input(14,          title='End session minutes', type=input.integer)
squareoff_cond     = input('K-D cross', title='Square off condition',type=input.string, options=['K-D cross', 'K-Level cross'])

// Calculate overbrought and oversold levels
ob_level   = 100 - level_margin
os_level   = level_margin

///////////////////////////////////////////
//// Some functions ///////////////////////
is_newbar(res) =>
    change(time(res)) != 0
//

// check if this candle is close of session
chk_close_time(hr, min) =>
    time_sig = (hour[0] == hr) and (minute[0] > min and minute[1] < min)
    time_sig
//

// chechk if this candle doesn't fall in close session
chk_not_close_time(hr) =>
    time_ncs = (hour[0] < hr)
    [time_ncs]
//

////////////////////////////
// Stochastic indicator
stochastic(length_, smooth_k_, smooth_d_, tf_) =>
    k_sig  = sma(stoch(close, high, low, length_), smooth_k_)
    d_sig  = sma(k_sig, smooth_d_)
    ds_sig = security(syminfo.ticker, tf_, d_sig)
    ks_sig = security(syminfo.ticker, tf_, k_sig)
    [ks_sig, ds_sig]
//

[k_sig, d_sig] = stochastic(stoch_length, smooth_k, smooth_d, tframe)

////////////////////
// Stop loss signals
stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)
if use_tstop
    stop_l := use_sperc ? close*(1-stop_loss/100.0) : (close - stop_loss)
    stop_s := use_sperc ? close*(1+stop_loss/100.0) : (close + stop_loss)
//

///////////////////
// Master buy, sell, short and cover signals
buy_sig_m    = crossover(k_sig, ob_level)
short_sig_m  = crossunder(k_sig, os_level)
sell_sig_m   = true
cover_sig_m  = true
if squareoff_cond == 'K-Level cross'
    sell_sig_m   := crossunder(k_sig, ob_level)
    cover_sig_m  := crossover(k_sig, os_level)
//
if squareoff_cond == 'K-D cross'
    sell_sig_m   := crossunder(k_sig, d_sig)
    cover_sig_m  := crossover(k_sig, d_sig)
//

///////////////////////////
/// Apply intraday filter
buy     = use_iday ? (buy_sig_m and (hour < end_hr)) : buy_sig_m
sell    = use_iday ? (sell_sig_m or crossunder(close, stop_l[1]) or chk_close_time(end_hr, end_min)) : (sell_sig_m or crossunder(close, stop_l[1]))
short   = use_iday ? (short_sig_m and (hour < end_hr)) : short_sig_m
cover   = use_iday ? (cover_sig_m or crossover(close, stop_s[1]) or chk_close_time(end_hr, end_min)) : (cover_sig_m or crossover(close, stop_s[1]))

///////////////////////////
/// Send orders
strategy.entry("L", strategy.long,   when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short,  when=short)
strategy.close("S", when=cover)

/////////////////////////////
/// Plot signals
plot(k_sig,     title='SmoothK',    color=color.red)
plot(d_sig,     title='SmoothD',    color=color.blue)
plot(ob_level,  title='OB level',   color=color.orange)
plot(os_level,  title='OS level',   color=color.orange)
