//@version=3
strategy(title="Ren3", shorttitle="Ren3", overlay=true)
 
box_len     = input(1.0, type=float, title="REN3 Box Length", step=1.0)
ema_len_pre = input(2, type=integer, title="REN3 pre EMA Length")
ema_len     = input(9, type=integer, title="REN3 post EMA Length")
atr_mult    = input(1.0, type=float, title="ATR Multiplier", step=0.1)
pre_smooth  = input(true, type=bool, title="Smooth Price before applying REN3")

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
    atr_t  = atr_len * atr_mult

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

open_h = (pre_smooth) ? ema(close, ema_len_pre) : close
 
//sig2 = ren(close, atr_len, hl_len)
renk_sig     = ren(open_h, box_len)
renk_sig_ema = ema(renk_sig, ema_len)

buy   = crossover(renk_sig, renk_sig_ema)
sell  = crossunder(renk_sig, renk_sig_ema)
 
strategy.entry("L", strategy.long, when = window() and buy)
//strategy.close("L", when = selli)
strategy.entry("S", strategy.short, when = window() and sell)
//strategy.close("S", when = buyi)
 
plot(renk_sig, color=red, linewidth=2)
plot(renk_sig_ema, color=blue, linewidth=1)
