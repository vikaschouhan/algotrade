//@version=4
strategy(title="ORB-A SwingTrader with volatility filter", overlay=true)

// ORB params
orb_tolerance       = input(defval=0.0,     title="ORB Tolerance", type=input.float)
orb_time_frame_m    = input(defval='1D',    title="ORB Resolution", options=['1m', '5m', '10m', '15m', '30m', '45m', '1h', '2h', '4h', '1D', '2D', '4D', '1W', '2W', '1M', '2M', '6M'])
orb_time_frame_m2   = input(defval='1D',    title='ORB Consequetive Gap Resolution', options=['1m', '5m', '10m', '15m', '30m', '45m', '1h', '2h', '4h', '1D', '2D', '4D', '1W', '2W', '1M', '2M', '6M'])
orb_tolerance_perc  = input(defval=true,    title='Is ORB tolerance in percentage ?', type=input.bool)

// Stop loss params
stop_atr_period     = input(defval=5,       title='STOP trailing ATR period', type=input.integer)
stop_atr_mult       = input(defval=1.5,     title='STOP trailing ATR multiplier', type=input.float)
use_stop_loss       = input(defval=true,    title='USE Stop Loss', type=input.bool)

// vol filter params
bb_source           = input(defval=close,   title='BB Volatility Source', type=input.source)
bb_length           = input(defval=20,      title='BB Volatility Loopback Period Length', type=input.integer, minval=1)
bb_mult             = input(defval=2.0,     title='BB Volatility ATR Multiplier', type=input.float, minval=0.01, maxval=50, step=0.01)
bb_tf               = input(defval='1D',    title='BB Volatility Timeframe', type=input.resolution)
bb_vol_el           = input(defval=9,       title='BB Volatiltiy EMA Loopback period Length', type=input.integer)
use_vol_filter      = input(defval=true,    title='USE Volatility filter', type=input.bool)

// Other params
pos_lag             = input(defval=0,       title='Position Lag', type=input.integer)


////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
// Volatility calculation
vol_bb_basis   = sma(bb_source, bb_length)
vol_bb_dev     = bb_mult * stdev(bb_source, bb_length)
vol_bb_upper   = vol_bb_basis + vol_bb_dev
vol_bb_lower   = vol_bb_basis - vol_bb_dev

vol_bb_basis_t = security(syminfo.tickerid, bb_tf, vol_bb_basis)
vol_bb_upper_t = security(syminfo.tickerid, bb_tf, vol_bb_upper)
vol_bb_lower_t = security(syminfo.tickerid, bb_tf, vol_bb_lower)
ind_vol_t      = vol_bb_upper_t - vol_bb_lower_t
ind_vol_ema_t  = ema(ind_vol_t, bb_vol_el)

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
// Stop loss calculation
stop_n_loss       = stop_atr_mult * atr(stop_atr_period)
stop_src          = close
stop_trail_loss   = 0.0
stop_trail_loss   := iff(stop_src > nz(stop_trail_loss[1], 0) and stop_src[1] > nz(stop_trail_loss[1], 0), max(nz(stop_trail_loss[1]), stop_src - stop_n_loss), iff(stop_src < nz(stop_trail_loss[1], 0) and stop_src[1] < nz(stop_trail_loss[1], 0), min(nz(stop_trail_loss[1]), stop_src + stop_n_loss), iff(stop_src > nz(stop_trail_loss[1], 0), stop_src - stop_n_loss, stop_src + stop_n_loss)))
stop_pos          = 0.0
stop_pos          := iff(stop_src[1] < nz(stop_trail_loss[1], 0) and stop_src > nz(stop_trail_loss[1], 0), 1, iff(stop_src[1] > nz(stop_trail_loss[1], 0) and stop_src < nz(stop_trail_loss[1], 0), -1, nz(stop_pos[1], 0))) 


/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
// ORB indicator calculation
get_time_frame(tf) =>
    (tf == '1m')  ? "1"
  : (tf == '5m')  ? "5"
  : (tf == '10m') ? "10"
  : (tf == '15m') ? "15"
  : (tf == '30m') ? "30"
  : (tf == '45m') ? "45"
  : (tf == '1h')  ? "60"
  : (tf == '2h')  ? "120"
  : (tf == '4h')  ? "240"
  : (tf == '1D')  ? "D"
  : (tf == '2D')  ? "2D"
  : (tf == '4D')  ? "4D"
  : (tf == '1W')  ? "W"
  : (tf == '2W')  ? "2W"
  : (tf == '1M')  ? "M"
  : (tf == '2M')  ? "2M"
  : (tf == '6M')  ? "6M"
  : "wrong resolution"
//
orb_time_frame  = get_time_frame(orb_time_frame_m)
orb_time_frame2 = get_time_frame(orb_time_frame_m2)

is_newbar(res) =>
    change(time(res)) != 0
//

orb_high_range  = valuewhen(is_newbar(orb_time_frame2), high, 0)
orb_low_range   = valuewhen(is_newbar(orb_time_frame2), low,  0)
orb_high_rangeL = security(syminfo.tickerid, orb_time_frame, orb_high_range)
orb_low_rangeL  = security(syminfo.tickerid, orb_time_frame, orb_low_range)

orb_tolbu       = orb_tolerance_perc ? orb_high_rangeL*(1+orb_tolerance/100.0) : (orb_high_rangeL+orb_tolerance)
orb_tolbl       = orb_tolerance_perc ? orb_low_rangeL*(1-orb_tolerance/100.0) : (orb_low_rangeL-orb_tolerance)

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
// Trading signals calculation

buy_stdalone    = crossover(close, orb_tolbu)[pos_lag]
sell_stdalone   = use_stop_loss ? crossunder(close, stop_trail_loss[1])[pos_lag] : crossunder(close, orb_tolbl)[pos_lag]
short_stdalone  = crossunder(close, orb_tolbl)[pos_lag]
cover_stdalone  = use_stop_loss ? crossover(close, stop_trail_loss[1])[pos_lag] : crossover(close, orb_tolbu)[pos_lag]

buy    = use_vol_filter ? buy_stdalone and (ind_vol_t >= ind_vol_ema_t) : buy_stdalone
sell   = sell_stdalone
short  = use_vol_filter ? short_stdalone and (ind_vol_t >= ind_vol_ema_t) : short_stdalone
cover  = cover_stdalone

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
// Execute trading signals
strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)


///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
// Plot signals
plot(orb_high_rangeL, color=color.green, linewidth=2) 
plot(orb_low_rangeL,  color=color.red, linewidth=2) 
