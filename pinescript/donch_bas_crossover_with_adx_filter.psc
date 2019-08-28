//@version=3
strategy('Donch - EMA with ADX filter', overlay=true, slippage=20)

ch_len  = input(title="Donch Channel Length", defval=20)
ema_len = input(title="EMA Length", defval=9)
adx_lim = input(title="ADX Limit", defval=20)
adx_len = input(title="ADX Length", defval=20)
adx_res = input(title="ADX timeframe", type=resolution, defval="1D")

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
ADX_new = security(tickerid, adx_res, ADX)

// === INPUT BACKTEST RANGE ===
FromMonth = input(defval = 6, title = "From Month", minval = 1, maxval = 12)
FromDay   = input(defval = 1, title = "From Day", minval = 1, maxval = 31)
FromYear  = input(defval = 2017, title = "From Year")

// === FUNCTION EXAMPLE ===
start     = timestamp(FromYear, FromMonth, FromDay, 00, 00)  // backtest start window
finish    = time        // backtest finish window
window()  => time >= start and time <= finish ? true : false // create function "within window of time"

bas    = avg(highest(ch_len), lowest(ch_len))
bas_e  = ema(bas, ema_len)

buy    = crossover(bas, bas_e)
sell   = crossunder(bas, bas_e)

strategy.entry("long", strategy.long, when = window() and buy and ADX_new > adx_lim)
strategy.close("long", when = window() and sell)
strategy.entry("short", strategy.short, when = window() and sell and ADX_new > adx_lim)
strategy.close("short", when = window() and buy)

plot(bas, color=red)
plot(bas_e, color=green)
