//@version=4
study("Momentum Indicator", overlay=false)

mom_lback_period      = input(defval=24,     type=input.integer, title='Loopback period')
mom_tframe            = input(defval='1D',   type=input.resolution, title='Time frame')
mom_elen              = input(defval=24,     type=input.integer, title='Smooth Length')

momentum(seria, length) =>
    mom = seria - seria[length]
    mom
//

mom_ind_s       = momentum(close, mom_lback_period)
mom_ind_ema_s   = ema(mom_ind_s, mom_elen)
mom_ind         = security(syminfo.ticker, mom_tframe, mom_ind_s)
mom_ind_ema     = security(syminfo.ticker, mom_tframe, mom_ind_ema_s)


plot(mom_ind,        color=color.blue, title='MOM')
plot(mom_ind_ema,    color=color.olive, title='MOM MA')
plot(0.0,            color=color.black, linewidth=2)
