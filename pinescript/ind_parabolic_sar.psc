//@version=3
study("Parabolic SAR", shorttitle="PSAR", overlay=true)

psar_start      = input(title="PSAR Start", type=float, step=0.001, defval=0.02)
psar_increment  = input(title="PSAR Increment", type=float, step=0.001, defval=0.02)
psar_maximum    = input(title="PSAR Maximum", type=float, step=0.01, defval=0.2)

psar = sar(psar_start, psar_increment, psar_maximum)
dir  = psar < close ? 1 : -1

psarColor = dir == 1 ? #3388bb : #fdcc02
plot(psar, title="PSAR", style=circles, color=psarColor, linewidth=2)
