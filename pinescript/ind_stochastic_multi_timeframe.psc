//@version=4
strategy("Stochastic MTF", overlay=false)

stoch_length       = input(defval=14,   title='Stochastic Length',   type=input.integer)
smooth_k           = input(defval=3,    title='SmoothK',             type=input.integer)
smooth_d           = input(defval=3,    title='SmoothD',             type=input.integer)
tframe             = input(defval='60', title='Stochastic Timeframe',type=input.resolution)
l_margin           = input(defval=25,   title='Overbought/Oversold margin', type=input.integer, maxval=100, minval=0)

l_high = 100 - l_margin
l_low  = l_margin

////////////////////////////
// Stochastic indicator
stochastic(length_, smooth_k_, smooth_d_, tf_) =>
    k_sig  = sma(stoch(close, high, low, length_), smooth_k_)
    d_sig  = sma(k_sig, smooth_d_)
    ds_sig = security(syminfo.ticker, tf_, d_sig)
    ks_sig = security(syminfo.ticker, tf_, k_sig)
    [ks_sig, ds_sig]
//

[k_sig, d_sig] = stochastic(stoch_length, smooth_k, smooth_d, tframe)

/////////////////////////////
/// Plot signals
plot(k_sig,     title='SmoothK',    color=color.red)
plot(d_sig,     title='SmoothD',    color=color.blue)
plot(l_high,    title='L-high',     color=color.black, linewidth=2)
plot(l_low,     title='L-low',      color=color.black, linewidth=2)
