//@version=4
strategy(title="Donchian Breakout Swing Trader with atr based volatility filter", overlay=true)

// Donchian params
donch_period        = input(defval=10,      title="Donchian Period", type=input.integer)

// Long term donchian filter
donch_period_l      = input(defval=5,       title="Long Term Donchian Period", type=input.integer)
donch_period_l_tf   = input(defval='1D',    title='Long Term Donchian Time Frame', type=input.resolution)

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

////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
// Long term Donchian Channel calculation (for filtering)
donch_hi_l = security(syminfo.tickerid, donch_period_l_tf, highest(donch_period_l))
donch_lo_l = security(syminfo.tickerid, donch_period_l_tf, lowest(donch_period_l))

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
// Donchian Channel
donch_hi = highest(donch_period)
donch_lo = lowest(donch_period)

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
// Trading signals calculation

buy_stdalone    = crossover(close, donch_hi[1])[pos_lag]
sell_stdalone   = crossunder(close, donch_lo[1])[pos_lag]
short_stdalone  = crossunder(close, donch_lo[1])[pos_lag]
cover_stdalone  = crossover(close, donch_hi[1])[pos_lag]

buy    = use_vol_filter ? buy_stdalone and (ind_vol_t >= ind_vol_ema_t) and (close > donch_hi_l) : buy_stdalone
sell   = sell_stdalone
short  = use_vol_filter ? short_stdalone and (ind_vol_t >= ind_vol_ema_t) and (close < donch_lo_l): short_stdalone
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
plot(donch_hi, color=color.green, linewidth=2) 
plot(donch_lo,  color=color.red, linewidth=2) 
