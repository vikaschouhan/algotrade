//@version=3
strategy(title="LRS strategy", shorttitle="LRS strategy", overlay=true)
 
lr_len   = input(defval=150, minval=1, title="Linear Regression Length")
ema_len  = input(defval=9, minval=1, title="EMA Length")
lb_len   = input(defval=1, minval=1, title="Look Back Period Length")
thresh   = input(defval=0.000001, minval=0, title="LR Slope threshold", step=0.00001)
src      = input(close, type=source)

src_n = ema(src, ema_len)

lrc = linreg(src_n[0], lr_len, 0)
lrprev = linreg(src_n[lb_len], lr_len, 0)
slope = ((lrc - lrprev) / interval)

buy  = (slope > thresh)
sell = (slope < -thresh)

strategy.entry("Long", strategy.long, when = buy)
strategy.entry("Short", strategy.short, when = sell)

//Please if somebody have suggestions how show this better, let me know
plot(lrc, color = red, title = "Linear Regression Curve", style = line, linewidth = 2)
plotarrow(slope, colorup=teal, colordown=orange, transp=40)
