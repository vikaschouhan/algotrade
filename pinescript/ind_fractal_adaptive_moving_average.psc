//@version=2
study("Fractal Adaptive Moving Average",shorttitle="FRAMA",overlay=true)

price = input(hl2)
len   = input(defval=16,minval=1)
FC    = input(defval=1,minval=1)
SC    = input(defval=198,minval=1)
len1  = len/2
w     = log(2/(SC+1))
H1    = highest(high,len1)
L1    = lowest(low,len1)
N1    = (H1-L1)/len1
H2    = highest(high,len)[len1]
L2    = lowest(low,len)[len1]
N2    = (H2-L2)/len1
H3    = highest(high,len)
L3    = lowest(low,len)
N3    = (H3-L3)/len

dimen1     = (log(N1+N2)-log(N3))/log(2)
dimen      = iff(N1>0 and N2>0 and N3>0,dimen1,nz(dimen1[1]))
alpha1     = exp(w*(dimen-1))
oldalpha   = alpha1>1?1:(alpha1<0.01?0.01:alpha1)
oldN       = (2-oldalpha)/oldalpha
N          = (((SC-FC)*(oldN-1))/(SC-1))+FC
alpha_     = 2/(N+1)
alpha      = alpha_<2/(SC+1)?2/(SC+1):(alpha_>1?1:alpha_)
out        = (1-alpha)*nz(out[1]) + alpha*price

plot(out, title="FRAMA", color=blue, transp=0)
