//@version=3
strategy(title="Ren1 - Heikinashi", shorttitle="Ren1 - Heikinashi", overlay=true)
 
//res   = input("15", type=resolution)
atr_len   = input(10, type=integer, title="ATR Length")
ema_len   = input(10, type=integer, title="REN0 EMA Length")
atr_mult  = input(1.0, type=float,  title="ATR Multiplier", step=0.1)
lag       = input(0,  type=integer, title="Lag")

// === INPUT BACKTEST RANGE ===
FromMonth = input(defval = 6, title = "From Month", minval = 1, maxval = 12)
FromDay   = input(defval = 1, title = "From Day", minval = 1, maxval = 31)
FromYear  = input(defval = 2017, title = "From Year")

// === FUNCTION EXAMPLE ===
start     = timestamp(FromYear, FromMonth, FromDay, 00, 00)  // backtest start window
finish    = time        // backtest finish window
window()  => time >= start and time <= finish ? true : false // create function "within window of time"

ren(src, atr_len) =>
    sig    = src
    atr_t  = atr(atr_len) * atr_mult

    if na(sig[1])
        //sig := lowest(low, 20)
        sig := src[1]
    else
        if (src > sig[1] + atr_t)
            sig := sig[1] + atr_t
        else
            if (src < sig[1] - atr_t)
                sig := sig[1] - atr_t
            else
                sig := sig[1]
            //
        //
    //
//

open_h   = security(heikinashi(tickerid), period, open)
close_h  = security(heikinashi(tickerid), period, close)
high_h   = security(heikinashi(tickerid), period, high)
low_h    = security(heikinashi(tickerid), period, low)
 
//sig2 = ren(close, atr_len, hl_len)
renk_sig    = ren(open_h, atr_len)
renk_sig_ea = ema(renk_sig, ema_len)

buy   = (renk_sig[lag] > renk_sig_ea[lag])
sell  = (renk_sig[lag] < renk_sig_ea[lag])
 
strategy.entry("L", strategy.long, when = window() and buy)
//strategy.close("L", when = selli)
strategy.entry("S", strategy.short, when = window() and sell)
//strategy.close("S", when = buyi)
 
plot(renk_sig, color=red, linewidth=2)
plot(renk_sig_ea, color=green, linewidth=1)
