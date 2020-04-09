//@version=4
study("O/C oscillator", overlay=false)
close_look_back_len     = input(defval=9,      type=input.integer, title='Lookback period for close')
open_look_back_len      = input(defval=18,     type=input.integer, title='Lookback period for open')
time_frame              = input(defval='5',    type=input.resolution, title='Time Frame')

close_smooth_s          = ema(close, close_look_back_len)
open_smooth_s           = ema(open, open_look_back_len)
ind_sig_s               = (close_smooth_s - open_smooth_s)
ind_sig                 = security(syminfo.ticker, time_frame, ind_sig_s)

plot(ind_sig, color=color.blue, title='OC oscillator')
plot(0.0,     color=color.black, title='L0')
