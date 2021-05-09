//@version=4
strategy(title="ORB-A swing with HL smoothing and mean reversion v1", overlay=true)

//////////////////////////////////////////////////////////////////////////////////
// Inputs
// ORB inputs
tolerance      = input(defval=0.0, title="Tolerance", type=input.float)
time_frame_m   = input(defval='15', title="ORB Resolution", type=input.resolution)
time_frame_n   = input(defval='1D', title="Time Gap", type=input.resolution)
ema_len        = input(1,     title='Smooth EMA Length', type=input.integer)
// Stop loss inputs
stop_loss      = input(1.0,   title="Stop loss", type=input.float)
use_sperc      = input(false, title='Stop loss & tolerance are in %centage(s)', type=input.bool)
use_tstop      = input(true,  title='Use trailing stop', type=input.bool)
// For trendless market
rsi_len        = input(14,    title='RSI Length', type=input.integer)
rsi_tf         = input('',    title='RSI Time Frame', type=input.resolution)
rsi_dlen       = input(50,    title='RSI Donch Length', type=input.integer)
rsi_thi        = input(60,    title='RSI Trendless High', type=input.integer)
rsi_tlo        = input(40,    title='RSI Trendless Low', type=input.integer)
// Bollinger bands input
bb_source      = input(defval=close,    type=input.source,  title='Bollinger Source')
bb_length      = input(defval=20,       type=input.integer, title='Bollinger Length', minval=1)
bb_mult        = input(defval=2.0,      type=input.float,   title='Bollinger Multiplier', minval=0.01, maxval=50, step=0.01)
bb_tf          = input(defval='',       type=input.resolution, title='Bollinger Timeframe')
// Bollinger bands strategy
bb_strategy    = input(defval='default', type=input.string, options=['default', 'strat_1'])

///////////////////////////////////////////////////////////////////////
// Helper functions
is_newbar(res) =>
    change(time(res)) != 0
//

///////////////////////////////////////////////////////////////////////
// Trendless signal (detect trendless markets)
rsi_t     = rsi(close, rsi_len)
rsi_ind   = security(syminfo.tickerid, rsi_tf, rsi_t)
trendless = (highest(rsi_ind, rsi_dlen) <= rsi_thi) and (lowest(rsi_ind, rsi_dlen) >= rsi_tlo)

//////////////////////////////////////////////////////////////////////////
// Bollinger bands (triggered in trendless markets)
bb_basis  = sma(bb_source, bb_length)
bb_dev    = bb_mult * stdev(bb_source, bb_length)
bb_upper  = bb_basis + bb_dev
bb_lower  = bb_basis - bb_dev
bb_basis_t = security(syminfo.tickerid, bb_tf, bb_basis)
bb_upper_t = security(syminfo.tickerid, bb_tf, bb_upper)
bb_lower_t = security(syminfo.tickerid, bb_tf, bb_lower)

// Trendless position signals
trendless_buy     = crossunder(close, bb_lower_t)
trendless_sell    = crossover(close, bb_upper_t)
trendless_short   = crossover(close, bb_upper_t)
trendless_cover   = crossunder(close, bb_lower_t)

if bb_strategy == 'strat_1'
    trendless_buy     := crossover(close, bb_lower_t)
    trendless_sell    := crossunder(close, bb_upper_t)
    trendless_short   := crossunder(close, bb_upper_t)
    trendless_cover   := crossover(close, bb_lower_t)
//

///////////////////////////////////////////////////////////////////////
// Trend indicator (ORB-based)
time_frame = time_frame_m
time_gap   = time_frame_n
high_range  = valuewhen(is_newbar(time_gap), high, 0)
low_range   = valuewhen(is_newbar(time_gap), low,  0)

high_rangeL = security(syminfo.tickerid, time_frame, ema(high_range, ema_len))
low_rangeL  = security(syminfo.tickerid, time_frame, ema(low_range, ema_len))

tolbu  = use_sperc ? high_rangeL*(1+tolerance/100.0) : (high_rangeL + tolerance)
tolbl  = use_sperc ? low_rangeL*(1-tolerance/100.0) : (low_rangeL-tolerance)

/////////////////////////////////////////////////////////////////////////////
// Stop losses
stop_l = use_sperc ? strategy.position_avg_price*(1-stop_loss/100.0) : (strategy.position_avg_price-stop_loss)
stop_s = use_sperc ? strategy.position_avg_price*(1+stop_loss/100.0) : (strategy.position_avg_price+stop_loss)
if use_tstop
    stop_l := use_sperc ? close*(1-stop_loss/100.0) : (close - stop_loss)
    stop_s := use_sperc ? close*(1+stop_loss/100.0) :  (close + stop_loss)
//

///////////////////////////////////////////////////////////////////////////////
// Position signals
buy    = crossover(close, tolbu)
sell   = crossunder(close, stop_l[1])
short  = crossunder(close, tolbl)
cover  = crossover(close, stop_s[1])

if trendless
    buy     := trendless_buy
    sell    := trendless_sell
    short   := trendless_short
    cover   := trendless_cover
//

///////////////////////////////////////////////////////////////////////////////
// Execute positions
strategy.entry("L", strategy.long, when=buy)
strategy.close("L", when=sell)
strategy.entry("S", strategy.short, when=short)
strategy.close("S", when=cover)

///////////////////////////////////////////////////////////////////////////////
// Generate plots
plot(high_rangeL, color=color.green, linewidth=1)
plot(low_rangeL,  color=color.red, linewidth=1)
