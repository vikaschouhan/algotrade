//@version=2
strategy("Supertrend with hl smoothing and rising ADX filter", "Supertrend with hl smoothing and rising ADX filter", overlay = true)

factor    = input(title="Factor", defval=4, minval=1, maxval = 1000)
period    = input(title="Period", defval=10, minval=1, maxval = 1000)
ema_len   = input(title="Smooth EMA Length", defval=2, minval=1, maxval=1000)
//long_only = input(title="Long only", false, type=bool)
// For ADX
adx_eml   = input(title="ADX Ema Length", defval=9)
adx_len   = input(title="ADX Length", defval=20)
adx_res   = input(title="ADX timeframe", type=resolution, defval="1D")

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

// Supertrend
supertrend() =>
    hl22 = (ema(high, ema_len) + ema(low, ema_len))/2
    cl22 = close //ema(close, ema_len)

    Up   =hl22 - (factor*atr(period))
    Dn   =hl22 + (factor*atr(period))

    TrendUp   = cl22[1]>TrendUp[1]? max(Up,TrendUp[1]) : Up
    TrendDown = cl22[1]<TrendDown[1]? min(Dn,TrendDown[1]) : Dn
    Trend     = cl22 > TrendDown[1] ? 1: cl22 < TrendUp[1]? -1: nz(Trend[1],1)
    Tsl       = Trend==1? TrendUp: TrendDown
    
    [Tsl, Trend]
//

[Tsl, Trend] = supertrend()

lcolor_res = Trend == 1 ? green : red

//buy  = (Trend == 1) and (Trend[1] != 1)
//sell = (Trend != 1) and (Trend[1] == 1)
buy_tr  = (Trend == 1)
sell_tr = (Trend != 1)


// Executiom
strategy.entry("L", strategy.long, when=buy_tr and ADX_new > ADX_ema)
strategy.close("L", when=sell_tr)
strategy.entry("S", strategy.short, when=sell_tr and ADX_new > ADX_ema)
strategy.close("S", when=buy_tr)

plot(Tsl, color = lcolor_res , style = linebr , linewidth = 1,title = "SuperTrend")
