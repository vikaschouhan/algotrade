//@version=4
study("Trend filter using cumsum of MA crossovers", overlay=false)

trnd_ema_length_short       = input(defval=2,      title='TR Short EMA Length', type=input.integer)
trnd_ema_length_long        = input(defval=5,      title='TR Long EMA Length',  type=input.integer)
trnd_last_periods           = input(defval=5,      title='TR Loopback Period Length', type=input.integer)
trnd_time_frame             = input(defval='1D',   title='TR Time Frame', type=input.resolution)

// Indicator calculation
trnd_ema_crossover   = crossover(ema(close, trnd_ema_length_short), ema(close, trnd_ema_length_long)) != 0 ? 1.0:0.0
trnd_ind_t_          = sma(trnd_ema_crossover, trnd_last_periods) * trnd_last_periods
trnd_ind_stdev_t_    = stdev(trnd_ind_t_, trnd_last_periods)
trnd_ind_t           = security(syminfo.tickerid, trnd_time_frame, trnd_ind_t_)
trnd_ind_stdev_t     = security(syminfo.tickerid, trnd_time_frame, trnd_ind_stdev_t_)

// Plots
plot(trnd_ind_t,                 color=color.green, title='TRND')
plot(trnd_ind_stdev_t,           color=color.red,   title='TRND_STDEV')
