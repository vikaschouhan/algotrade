//@version=4
strategy("ADX driven trend follower with ADX-EMA Cross and Neg Trend exit", overlay=false)

////////////////////////////////////////////
// INPUT Vars
adx_time_frame     = input("D",               title="ADX Time Frame", type=input.resolution)
adx_ema_len        = input(defval=8,          title="ADX EMA Length")
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
ADX_tf   = security(syminfo.tickerid, adx_time_frame, ADX)
ADX_ema  = ema(ADX_tf, adx_ema_len)
ADX_ema2 = ema(ADX_ema, adx_ema_len)

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
buy_sig_m      = crossover(ADX_ema, ADX_ema2) and trend_pos
short_sig_m    = crossover(ADX_ema, ADX_ema2) and trend_neg
sell_sig_m     = trend_neg and trend_pos[1]
cover_sig_m    = trend_pos and trend_neg[1]
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
plot(ADX_tf,   linewidth=1, color=color.black,  title="ADX")
plot(ADX_ema,  linewidth=1, color=color.green,  title="ADX_EMA")
plot(ADX_ema2, linewidth=1, color=color.red,    title="ADX_EMA2")
