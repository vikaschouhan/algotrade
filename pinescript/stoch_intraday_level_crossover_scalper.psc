//@version=4
strategy("Stochastic Intraday Level Crossover scalper", overlay=false)

stoch_length       = input(defval=14,   title='Stochastic Length',   type=input.integer)
smooth_k           = input(defval=3,    title='SmoothK',             type=input.integer)
smooth_d           = input(defval=3,    title='SmoothD',             type=input.integer)
ob_level           = input(defval=75,   title='Overbrought level',   type=input.integer, minval=0, maxval=100)
os_level           = input(defval=25,   title='Oversold level',      type=input.integer, minval=0, maxval=100)
tframe             = input(defval='60', title='Stochastic Timeframe',type=input.resolution)
stop_loss          = input(1.0,         title="Stop loss",           type=input.float)
use_sperc          = input(false,       title='Stop loss & tolerance are in %centage(s)', type=input.bool)
use_iday           = input(false,       title='Use intraday',        type=input.bool)
use_tstop          = input(true,        title='Use trailing stop',   type=input.bool)
end_hr             = input(15,          title='End session hour',    type=input.integer)
end_min            = input(14,          title='End session minutes', type=input.integer)

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

// Stochastic indicator
stochastic(length_, smooth_k_, smooth_d_, tf_) =>
    k_sig  = sma(stoch(close, high, low, length_), smooth_k_)
    d_sig  = sma(k_sig, smooth_d_)
    ds_sig = security(syminfo.ticker, tf_, d_sig)
    ks_sig = security(syminfo.ticker, tf_, k_sig)
    [ks_sig, ds_sig]
//

[k_sig, d_sig] = stochastic(stoch_length, smooth_k, smooth_d, tframe)

stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)
if use_tstop
    stop_l := use_sperc ? close*(1-stop_loss/100.0) : (close - stop_loss)
    stop_s := use_sperc ? close*(1+stop_loss/100.0) : (close + stop_loss)
//

b_sig_m = crossover(d_sig, os_level)
s_sig_m = crossunder(d_sig, ob_level)

buy     = use_iday ? (b_sig_m and (hour < end_hr)) : b_sig_m
sell    = use_iday ? (s_sig_m or crossunder(close, stop_l[1]) or chk_close_time(end_hr, end_min)) : (s_sig_m or crossunder(close, stop_l[1]))
short   = use_iday ? (s_sig_m and (hour < end_hr)) : s_sig_m
cover   = use_iday ? (b_sig_m or crossover(close, stop_s[1]) or chk_close_time(end_hr, end_min)) : (b_sig_m or crossover(close, stop_s[1]))


strategy.entry("L", strategy.long,   when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short,  when=short)
strategy.close("S", when=cover)

plot(k_sig,     title='SmoothK',    color=color.red)
plot(d_sig,     title='SmoothD',    color=color.blue)
plot(ob_level,  title='OB level',   color=color.orange)
plot(os_level,  title='OS level',   color=color.orange)
