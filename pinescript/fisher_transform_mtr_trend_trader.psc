//@version=5
// Fisher Transform trend trader strategy.
// This applies Fisher transform on higher time frames to get long term cycles
// and tries to trade them via trend following.
strategy(title="Fisher Transform MTR Trend trader", overlay=false)

/////////////////////////////////////
// Parameters
fish_length    = input.int(defval=10,        title='Fisher Transform Period', minval=1)
fish_threshold = input.float(defval=0.001,   title='Fisher Transform crossover threshold', step=0.001)
fish_timeframe = input.timeframe(defval="",  title='Fisher Transform Timeframe')
fish_use_ema   = input.bool(defval=false,    title='Use smoothed ema for Fisher Transform')
fish_ema_len   = input.int(defval=1,         title='Fisher Transform EMA Length (only when enabled)')
fish_alpha     = input.float(defval=0.66,    title='Fisher Alpha (Change with Caution)', step=0.01)
fish_delta     = input.float(defval=0.67,    title='Fisher Delta (Change with Caution)', step=0.01)

//////////////////////////////////////
// Function to get source for the fisher transform
get_fisher_source(src, use_ema, ema_length) =>
    fish_src = src
    if use_ema
        fish_src := ta.ema(src, ema_length)
    //
    [fish_src]

////////////////////////////////////
// Function to calculate fisher transform
get_fisher(f_src, f_length, f_alpha, f_delta) =>
    fish_src       = f_src
    fish_src_hi    = ta.highest(fish_src, f_length)
    fish_src_lo    = ta.lowest(fish_src, f_length)

    fish_nvalue1   = fish_src
    fish_nvalue2   = fish_src
    fish_ind       = fish_src
    fish_nvalue1   := f_alpha * ((fish_src - fish_src_lo) / (fish_src_hi - fish_src_lo) - 0.5) + f_delta * nz(fish_nvalue1[1])
    if fish_nvalue1 > 0.99
        fish_nvalue2 := 0.999
    else
        if fish_nvalue1 < -0.99
            fish_nvalue2 := -0.999
        else
            fish_nvalue2 := fish_nvalue1
        //
    //
    fish_ind       := 0.5 * math.log((1 + fish_nvalue2) / (1 - fish_nvalue2)) + 0.5 * nz(fish_ind[1])
    [fish_ind]
//

//////////////////////////////////////////////
// Get higher time frame data
[fish_src]     = get_fisher_source(hl2, fish_use_ema, fish_ema_len)
[fish_ind]     = get_fisher(fish_src, fish_length, fish_alpha, fish_delta)
fish_ind_mtr   = request.security(syminfo.tickerid, fish_timeframe, fish_ind, barmerge.gaps_off, barmerge.lookahead_on)
fish_trig_mtr  = request.security(syminfo.tickerid, fish_timeframe, nz(fish_ind[1]), barmerge.gaps_off, barmerge.lookahead_on)

//////////////////////////////////////////////
// Generate trading signals
sig_buy        = fish_ind_mtr > (fish_trig_mtr + fish_threshold)
sig_sell       = fish_ind_mtr < (fish_trig_mtr - fish_threshold)

///////////////////////////////////////////////
// Execute positions
strategy.entry("L", strategy.long, when=sig_buy)
strategy.entry("S", strategy.short, when=sig_sell)

///////////////////////////////////////////////
// Plotting
plot(fish_ind_mtr,  color=color.green, title="Fisher Indicator")
plot(fish_trig_mtr, color=color.red,   title="Fisher Trigger")
