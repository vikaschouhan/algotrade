//@version=4
study(title="Ehlers Bandpass Filter v1 - Empirical Mode decomposition", overlay=false)

///////////////////////////////////////////////////
// Inputs
length        = input(defval=20,      type=input.integer, title="Period")
delta         = input(defval=0.1,     type=input.float, title="Delta", step=0.1)
pv_sma_len    = input(defval=50,      type=input.integer, title='Peak Valley smooth length')
thr_fract     = input(defval=0.1,     type=input.float, title='Threshold - Fraction of Peak Valley averages')
time_frame    = input(defval='1D',    type=input.resolution, title="Time Frame")
src           = hl2

///////////////////////////////////////////////////
// Generate signals
// Band pass filter
BandPassv1(src, length, delta) =>
    beta      = cos(3.14*(360/length)/180)
    gamma     = 1/cos(3.14*(720*delta/length)/180)
    alpha     = gamma-sqrt(gamma*gamma-1)
    bpass     = 0.0
    bpass     := 0.5*(1-alpha)*(src-src[2]) + beta*(1+alpha)*nz(bpass[1]) - alpha*nz(bpass[2])
    trend     = sma(bpass, 2*length)
    [bpass, trend]
    
[band_pass_t, trend_t] = BandPassv1(src, length, delta)
band_pass          = security(syminfo.tickerid, time_frame, band_pass_t)
trend              = security(syminfo.tickerid, time_frame, trend_t)

// Get peaks and valleys and trigger thresholds
peaks              = band_pass
valleys            = band_pass
if band_pass[1] > band_pass and band_pass[1] > band_pass[2]
    peaks    := band_pass[1]
else
    peaks    := peaks[1]
//
if band_pass[1] < band_pass and band_pass[1] < band_pass[2]
    valleys  := band_pass[1]
else
    valleys  := valleys[1]
//
peaks_smooth   = sma(peaks, pv_sma_len)
valleys_smooth = sma(valleys, pv_sma_len)
thr_high       = thr_fract*peaks_smooth
thr_lower      = thr_fract*valleys_smooth

/////////////////////////////////////////////////////
// Plots
plot(band_pass,           color=color.blue,   title='BPASS')
plot(trend,               color=color.red,    title='Trend')
plot(thr_high,            color=color.green,  title='Upper Threshold')
plot(thr_lower,           color=color.olive,  title='Lower Threshold')
