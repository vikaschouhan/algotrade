//@version=4
strategy("ATR driven trend follower", overlay=false)

////////////////////////////////////////////
// INPUT Vars
adx_time_frame     = input("D",               title="ADX Time Frame", type=input.resolution)
adx_donch_length   = input(defval=8,          title="ADX Donch Length")
adx_len            = input(defval=20,         title="ADX Length")

stop_loss          = input(defval=1.0,        title="Stop loss", type=input.float)
use_sperc          = input(defval=true,       title='Stop loss & tolerance are in %centage(s)', type=input.bool)
use_tstop          = input(defval=true,       title='Use trailing stop', type=input.bool)
use_stops          = input(defval=true,       title='Use Stop loss', type=input.bool)

trend_ema_len      = input(defval=1,          title='EMA Length for trend determination', type=input.integer)
trend_ema_lag      = input(defval=1,          title='EMA Lag for trend determination', type=input.integer)

/////////////////////////////////////
// INTRADAY FUNCTIONS
/// Functions misc
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


/////////////////////////////////////
// ADX functions
// ADX
dirmov(len) =>
    up = change(high)
    down = -change(low)
    truerange = rma(tr, len)
    plus = fixnan(100 * rma(up > down and up > 0 ? up : 0, len) / truerange)
    minus = fixnan(100 * rma(down > up and down > 0 ? down : 0, len) / truerange)
    [plus, minus]

adx(adx_len) =>
    [plus, minus] = dirmov(adx_len)
    sum = plus + minus
    adx = 100 * rma(abs(plus - minus) / (sum == 0 ? 1 : sum), adx_len)
    [adx, plus, minus]

[ADX, up, down] = adx(adx_len)
ADX_dhi  = highest(ADX, adx_donch_length)
ADX_dlo  = lowest(ADX, adx_donch_length)
ADX_tf   = security(syminfo.tickerid, adx_time_frame, ADX)
ADX_hi   = security(syminfo.tickerid, adx_time_frame, ADX_dhi)
ADX_lo   = security(syminfo.tickerid, adx_time_frame, ADX_dlo)

////////////////////////////////////////
// Trend determination signals
trend_ema = ema(close, trend_ema_len)
trend_pos = (trend_ema > trend_ema[trend_ema_lag])
trend_neg = (trend_ema < trend_ema[trend_ema_lag])

/////////////////////////////////////
/// Calculate stops
stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)
if use_tstop
    stop_l := use_sperc ? close*(1-stop_loss/100.0) : (close-stop_loss)
    stop_s := use_sperc ? close*(1+stop_loss/100.0) : (close+stop_loss)
//


////////////////////////////////////////
/// Calculate position signals
buy_sig_m      = ADX_hi == ADX_tf and ADX_hi[1] > ADX_tf[1] and trend_pos
short_sig_m    = ADX_lo == ADX_tf and ADX_lo[1] < ADX_tf[1] and trend_neg
sell_sig_m     = ADX_hi > ADX_tf
cover_sig_m    = ADX_lo < ADX_tf
if use_stops
    sell_sig_m   := crossunder(close, stop_l[1])
    cover_sig_m  := crossover(close, stop_s[1])
//

buy    = buy_sig_m
sell   = sell_sig_m
short  = short_sig_m
cover  = cover_sig_m

/////////////////////////////////////////
/// Execute signals
strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

/////////////////////////////////////////
/// Plot primary signals
plot(ADX_tf,   linewidth=1, color=color.black,  title="ATR")
plot(ADX_hi,   linewidth=1, color=color.green,  title="ATR_Hi")
plot(ADX_lo,   linewidth=1, color=color.red,    title="ATR_Lo")
