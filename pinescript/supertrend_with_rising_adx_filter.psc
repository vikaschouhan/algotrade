//@version=2
strategy("Supertrend with rising ADX filter", overlay = true)

factor = input(title="Supertrend Mult", defval=3, minval=1,maxval = 100)
period = input(title="Supertrend Period", defval=7, minval=1,maxval = 100)
// For ADX
adx_eml = input(title="ADX Ema Length", defval=9)
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
ADX_ema = security(tickerid, adx_res, ema(ADX, adx_eml))
ADX_new = security(tickerid, adx_res, ADX)


// For Supertrend
Up=hl2-(factor*atr(period))
Dn=hl2+(factor*atr(period))


TrendUp=close[1]>TrendUp[1]? max(Up,TrendUp[1]) : Up
TrendDown=close[1]<TrendDown[1]? min(Dn,TrendDown[1]) : Dn

Trend = close > TrendDown[1] ? 1: close< TrendUp[1]? -1: nz(Trend[1],1)
Tsl = Trend==1? TrendUp: TrendDown

linecolor = Trend == 1 ? green : red

buy  = (Trend == 1) and (Trend[1] != 1)
sell = (Trend != 1) and (Trend[1] == 1)


// Executiom
strategy.entry("L", strategy.long, when=buy and ADX_ema > ADX_new)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=sell and ADX_ema > ADX_new)
strategy.close("S", when=buy)

plot(Tsl, color = linecolor , style = line , linewidth = 2,title = "SuperTrend")
