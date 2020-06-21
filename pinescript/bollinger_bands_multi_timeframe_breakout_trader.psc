//@version=4
strategy("Bollinger Bands MTR Breakout", overlay=true)

// BB parameters
bb_source           = input(defval=close,    type=input.source,     title='BB Source')
bb_tolerance        = input(defval=0.0,      type=input.float,      title='BB Breakout Tolerance')
bb_length           = input(defval=20,       type=input.integer,    title='BB Loopback Length', minval=1)
bb_mult             = input(defval=2.0,      type=input.float,      title='BB Multiplier', minval=0.01, maxval=50.0)
bb_time_frame       = input(defval='15',     type=input.resolution, title='BB Timeframe')
bb_tolerance_perc   = input(defval=true,     type=input.bool,       title='Is BB tolerance in percentage ?')

// Stop loss params
stop_atr_period     = input(defval=5,       title='STOP trailing ATR period', type=input.integer)
stop_atr_mult       = input(defval=1.5,     title='STOP trailing ATR multiplier', type=input.float)
use_stop_loss       = input(defval=false,   title='USE Stop Loss', type=input.bool)

// Other params
pos_lag             = input(defval=0,       title='Position Lag', type=input.integer)


/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Stop loss calculation
stop_n_loss       = stop_atr_mult * atr(stop_atr_period)
stop_src          = close
stop_trail_loss   = 0.0
stop_trail_loss   := iff(stop_src > nz(stop_trail_loss[1], 0) and stop_src[1] > nz(stop_trail_loss[1], 0), max(nz(stop_trail_loss[1]), stop_src - stop_n_loss), iff(stop_src < nz(stop_trail_loss[1], 0) and stop_src[1] < nz(stop_trail_loss[1], 0), min(nz(stop_trail_loss[1]), stop_src + stop_n_loss), iff(stop_src > nz(stop_trail_loss[1], 0), stop_src - stop_n_loss, stop_src + stop_n_loss)))
stop_pos          = 0.0
stop_pos          := iff(stop_src[1] < nz(stop_trail_loss[1], 0) and stop_src > nz(stop_trail_loss[1], 0), 1, iff(stop_src[1] > nz(stop_trail_loss[1], 0) and stop_src < nz(stop_trail_loss[1], 0), -1, nz(stop_pos[1], 0)))

/////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
// Bolllinger Bands Calculation
bb_basis   = sma(bb_source, bb_length)
bb_dev     = bb_mult * stdev(bb_source, bb_length)
bb_upper   = bb_basis + bb_dev
bb_lower   = bb_basis - bb_dev
bb_basis_t = security(syminfo.tickerid, bb_time_frame, bb_basis)
bb_upper_t = security(syminfo.tickerid, bb_time_frame, bb_upper)
bb_lower_t = security(syminfo.tickerid, bb_time_frame, bb_lower)

bb_tolbu   = bb_tolerance_perc ? bb_upper_t*(1+bb_tolerance/100.0) : (bb_upper_t+bb_tolerance)
bb_tolbl   = bb_tolerance_perc ? bb_lower_t*(1-bb_tolerance/100.0) : (bb_lower_t-bb_tolerance)


//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Trading Signals calculation
buy_stdalone    = crossover(close, bb_tolbu)[pos_lag]
sell_stdalone   = use_stop_loss ? crossunder(close, stop_trail_loss[1])[pos_lag] : crossunder(close, bb_tolbl)[pos_lag]
short_stdalone  = crossunder(close, bb_tolbl)[pos_lag]
cover_stdalone  = use_stop_loss ? crossover(close, stop_trail_loss[1])[pos_lag] : crossover(close, bb_tolbu)[pos_lag]

buy    = buy_stdalone
sell   = sell_stdalone
short  = short_stdalone
cover  = cover_stdalone

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
// Execute trading signals
strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
// Plots
plot(bb_upper_t, color=color.green, linewidth=1, title='BB_U')
plot(bb_lower_t, color=color.red,   linewidth=1, title='BB_L')
plot(bb_basis_t, color=color.black, linewidth=1, title='BB_B')
