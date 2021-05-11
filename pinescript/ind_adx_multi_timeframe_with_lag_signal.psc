//@version=4
study('ADX MT - Lag v1', overlay=false)

////////////////////////////////////////////////////////////
// Inputs
adx_lag = input(title="ADX Lag", defval=1)
adx_len = input(title="ADX Length", defval=20)
adx_res = input(title="ADX timeframe", type=input.resolution, defval="1D")

////////////////////////////////////////////////////////////
// Indicators
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
ADX_new  = security(syminfo.tickerid, adx_res, ADX)
ADX_new_lag = security(syminfo.tickerid, adx_res, ADX[adx_lag])

///////////////////////////////////////////////////////////////
// Plots
plot(ADX_new, color=color.red)
plot(ADX_new_lag, color=color.green)
