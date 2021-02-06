//@version=4
study('ADX multitimeframe - Donch', overlay=false)

adx_dml = input(title="ADX Donch Length", defval=9)
adx_len = input(title="ADX Length", defval=20)
adx_res = input(title="ADX timeframe", type=input.resolution, defval="1D")

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
ADX_dhi  = highest(ADX, adx_dml)
ADX_dlo  = lowest(ADX, adx_dml)
ADX_new  = security(syminfo.tickerid, adx_res, ADX)
ADX_hi   = security(syminfo.tickerid, adx_res, ADX_dhi)
ADX_lo   = security(syminfo.tickerid, adx_res, ADX_dlo)

plot(ADX_new, color=color.red)
plot(ADX_hi,  color=color.green)
plot(ADX_lo,  color=color.black)
