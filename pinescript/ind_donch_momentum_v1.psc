//@version=5
indicator("Donch momentum v1", overlay=false)

//////////////////////////////////////////////////
// Parameters
donch_period      = input.int(defval=20,  title='Donchian Period')
mom_smooth_period = input.int(defval=3,   title='Donchian Momentum Smooth Period')

//////////////////////////////////////////////////////
// Functions
d_avg(d_len) =>
    math.avg(ta.highest(high, d_len), ta.lowest(low, d_len))
//

////////////////////////////////////////////////////////
// Momentum indicator
sig = ta.ema(close-d_avg(donch_period), mom_smooth_period)

/////////////////////////////////////////////////////////
// Plots
plot(sig, color=color.red, title='Donchian Momentum')
