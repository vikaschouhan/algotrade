//@version=4
strategy("Supertrend with hl smoothing", "Supertrend with hl smoothing", overlay=true)

atr_factor    = input(defval=4,     type=input.integer, title='Supertrend Factor')
atr_period    = input(defval=10,    type=input.integer, title='Supertrend Period')
ema_len       = input(defval=2,     type=input.integer, title='Smooth EMA Loopback Period')
long_only     = input(defval=false, type=input.bool,    title='Long only')

/////////////////////////////////////
/// Supertrend fn
supertrend(factor, period) =>
    hl22    = (ema(high, ema_len) + ema(low, ema_len))/2
    cl22    = close //ema(close, ema_len)
    Up      = hl22 - (factor*atr(period))
    Dn      = hl22 + (factor*atr(period))
    TrendUp = 0.0
    TrendDn = 0.0
    Trend   = 0.0
    TrendUp := cl22[1]>TrendUp[1] ? max(Up,TrendUp[1]) : Up
    TrendDn := cl22[1]<TrendDn[1]? min(Dn,TrendDn[1]) : Dn
    Trend   := cl22 > TrendDn[1] ? 1: cl22 < TrendUp[1]? -1: nz(Trend[1],1)
    Tsl     = Trend==1? TrendUp: TrendDn

    [Tsl, Trend, TrendUp, TrendDn]
//

[tsl, trend, trend_up, trend_dn] = supertrend(atr_factor, atr_period)
lcolor_res                       = trend == 1 ? color.green : color.red

/////////////////////////////////////////////////////
/// Calc position signals
buy  = (trend == 1) and (trend[1] != 1)
sell = (trend != 1) and (trend[1] == 1)

////////////////////////////////////////////////////
/// Execute trades
strategy.entry("Long", strategy.long, when=buy)
if long_only
    strategy.close("Long", when=sell)
else
    strategy.entry("Short", strategy.short, when=sell)
//

////////////////////////////////////////////////////
/// Plots
plot(tsl, color=lcolor_res, linewidth = 1, title = "SuperTrend")
