//@version=4
strategy("Momentum Intraday scalper", overlay=true)

mom_lback_period      = input(defval=24,     type=input.integer, title='Loopback period')
mom_tframe            = input(defval='1D',   type=input.resolution, title='Time frame')
mom_elen              = input(defval=9,      type=input.integer, title='MA Length 1')
mom_elen2             = input(defval=24,     type=input.integer, title='MA Length 2')
stop_loss             = input(1.0,   title="Stop loss", type=input.float)
use_sperc             = input(false, title='Stop loss in %centage(s)', type=input.bool)
use_iday              = input(false, title='Use intraday', type=input.bool)
use_tstop             = input(true,  title='Use trailing stop', type=input.bool)
end_hr                = input(15,    title='End session hour', type=input.integer)
end_min               = input(14,    title='End session minutes', type=input.integer)

////////////////////////////////////
/// Helper functions
is_newbar(res) =>
    change(time(res)) != 0
//

// check if this candle is close of session
chk_close_time(hr, min) =>
    time_sig = (hour[0] == hr) and (minute[0] > min and minute[1] < min)
    time_sig
//

// chechk if this candle doesn't fall in close session
chk_not_close_time(hr) =>
    time_ncs = (hour[0] < hr)
    [time_ncs]
//


momentum(seria, length) =>
    mom = seria - seria[length]
    mom
//

//////////////////////////////////////////////////
/// Calculate indicators
mom_ind_s       = momentum(close, mom_lback_period)
mom_ind_ema_s   = ema(mom_ind_s, mom_elen)
mom_ind_ema2_s  = ema(mom_ind_s, mom_elen2)
mom_ind         = security(syminfo.ticker, mom_tframe, mom_ind_s)
mom_ind_ema     = security(syminfo.ticker, mom_tframe, mom_ind_ema_s)
mom_ind_ema2    = security(syminfo.ticker, mom_tframe, mom_ind_ema2_s)

////////////////////////////////////////
/// Stop loss
stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)
if use_tstop
    stop_lt = use_sperc ? close*(1-stop_loss/100.0) : (close - stop_loss)
    stop_st = use_sperc ? close*(1+stop_loss/100.0) :  (close + stop_loss)
    stop_l  := stop_lt //max(stop_l, stop_lt)
    stop_s  := stop_st //min(stop_s, stop_st)
//

///////////////////////////////////////////
/// Calculate position signals
buy_sig_m   = crossover(mom_ind_ema, 0)
sell_sig_m  = crossunder(mom_ind_ema, mom_ind_ema2) or crossunder(close, stop_l[1])
short_sig_m = crossunder(mom_ind_ema, 0)
cover_sig_m = crossover(mom_ind_ema, mom_ind_ema2) or crossover(close, stop_s[1])

buy    = use_iday ? buy_sig_m and (hour < end_hr) : buy_sig_m
sell   = use_iday ? sell_sig_m or chk_close_time(end_hr, end_min) : sell_sig_m
short  = use_iday ? short_sig_m and (hour < end_hr) : short_sig_m
cover  = use_iday ? cover_sig_m or chk_close_time(end_hr, end_min) : cover_sig_m

///////////////////////////////////////////
/// Execute positions
strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

///////////////////////////////////////////
/// Plot signals
plot(mom_ind,        color=color.blue, title='MOM')
plot(mom_ind_ema,    color=color.olive, title='MOM MA')
plot(mom_ind_ema2,   color=color.orange, title='MOM MA2')
plot(0.0,            color=color.black, linewidth=2)
