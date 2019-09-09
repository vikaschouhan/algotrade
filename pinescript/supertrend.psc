strategy("Supertrend Strategy", "Supertrend Strategy", overlay=true, slippage=20)
 
Factor = input(4, minval=1, maxval=100)
Pd     = input(10, minval=1, maxval=100)
res    = input(type=resolution, defval="30")

SuperTrend(factor, pd, src) =>
    Up = hl2 -(factor*atr(pd))
    Dn = hl2 +(factor*atr(Pd))

    TrendUp   = (src[1] > TrendUp[1]) ? max(Up, TrendUp[1]) : Up
    TrendDown = (src[1] < TrendDown[1]) ? min(Dn, TrendDown[1]) : Dn

    Trend = (src > TrendDown[1]) ? 1: (src < TrendUp[1]) ? -1: nz(Trend[1],1)
    Tsl   = Trend==1? TrendUp: TrendDown

    [Trend, Tsl]
//

[Trend, Tsl] = SuperTrend(Factor, Pd, close)

Trend_res  = security(tickerid,res,Trend)
Tsl_res    = security(tickerid,res,Tsl)
lcolor_res = Trend_res == 1 ? green : red

buy  = (Trend_res == 1) and (Trend_res[1] != 1)
sell = (Trend_res != 1) and (Trend_res[1] == 1)

strategy.entry("Long", strategy.long, when = buy)
strategy.entry("Short", strategy.short, when = sell)

plot(Tsl_res, color = lcolor_res , style = linebr , linewidth = 1,title = "SuperTrend")
