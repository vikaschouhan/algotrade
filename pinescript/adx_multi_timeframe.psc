//@version=3
study('ADX', overlay=false)

adx_eml = input(title="ADX EMA Length", defval=9)
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
ADX_em   = ema(ADX, adx_eml)
ADX_new  = security(tickerid, adx_res, ADX)
ADX_ema  = security(tickerid, adx_res, ADX_em)

plot(ADX_new, color=red)
plot(ADX_ema, color=blue)
