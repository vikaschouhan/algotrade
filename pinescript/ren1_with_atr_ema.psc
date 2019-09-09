//@version=3
strategy(title="Ren1 with ATR EMA", shorttitle="Ren1 with ATR EMA", overlay=true)

atr_len  = input(10, type=integer, title="ATR Length")
hl_len   = input(10, type=integer, title="EMA Length")

ren(src, atr_len, ema_len) =>
    sig    = src
    atr_t  = ema(atr(atr_len), ema_len)
    ema_t  = ema(src, ema_len)

    if na(sig[1])
        //sig := lowest(low, 20)
        sig := ema_t[1]
    else
        if (ema_t > sig[1] + atr_t)
            sig := sig[1] + atr_t
        else
            if (ema_t < sig[1] - atr_t)
                sig := sig[1] - atr_t
            else
                sig := sig[1]
            //
        //
    //
//

sig2 = ren(open, atr_len, hl_len)

buy  = (sig2 > sig2[1])
sell = (sig2 < sig2[1])

strategy.entry("L", strategy.long, when=buy)
strategy.entry("S", strategy.short, when=sell)

plot(sig2, color=red, linewidth=2)
