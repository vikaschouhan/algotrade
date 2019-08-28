//@version=3
strategy("Kalman MA",shorttitle="KLMF",overlay=true)
ma_period = input(1, title="ma period", type=integer)
p = ohlc4
value1 = 0.0
value2 = 0.0
klmf   = 0.0

value1 := 0.2*(p-p[1]) + 0.8*nz(value1[1])
value2 := 0.1*(high-low)+0.8*nz(value2[1])
lambda = abs(value1/value2)

alpha = (-lambda*lambda + sqrt(lambda*lambda*lambda*lambda + 16*lambda*lambda))/8
klmf := alpha*p + (1-alpha)*nz(klmf[1])
klmf_ema = ema(klmf, ma_period)

plot(klmf, linewidth=3, color=blue, title="klmf", editable = true)

long  = crossover(klmf, klmf_ema)
short = crossunder(klmf, klmf_ema)

strategy.entry("L", strategy.long, when=long)
strategy.entry("S", strategy.short, when=short)
