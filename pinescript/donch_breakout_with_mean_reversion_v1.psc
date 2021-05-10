//@version=4
strategy("Donchian channel with mean reversion v1", overlay=true)

////////////////////////////////////////////////////////////////////////////
// Inputs
d1_len = input(10,   title='Donchian Larger Time Frame Length', type=input.integer)
d2_len = input(10,   title='Donchian Smaller Time Frame Length', type=input.integer)
d1_tf  = input('1D', title='Larger Time Frame', type=input.resolution)
d2_tf  = input('',   title='Smaller Time Frame', type=input.resolution)

///////////////////////////////////////////////////////////////////////////
// Calculate donchian levels
d1_hi = security(syminfo.tickerid, d1_tf, highest(d1_len))
d1_lo = security(syminfo.tickerid, d1_tf, lowest(d1_len))
d2_hi = security(syminfo.tickerid, d2_tf, highest(d2_len))
d2_lo = security(syminfo.tickerid, d2_tf, lowest(d2_len))

////////////////////////////////////////////////////////////////////////////
// Calculate positions
// This is for normal trend following
buy   = crossover(close, d1_hi[1])
sell  = crossunder(close, d2_lo[1])
short = crossunder(close, d1_lo[1])
cover = crossover(close, d2_hi[1])

// This is for mean reversion
if d2_hi <= d1_hi and d2_lo >= d1_lo
    buy    := crossunder(close, d2_lo[1])
    short  := crossover(close, d2_hi[1])
    sell   := short
    cover  := buy

////////////////////////////////////////////////////////////////////////////
// Execute positions
strategy.entry('L', strategy.long, when=buy)
strategy.entry('S', strategy.short, when=short)
strategy.close('L', when=sell)
strategy.close('S', when=cover)

////////////////////////////////////////////////////////////////////////////
// Plots
plot(d1_hi, color=color.green, title='DonchL Hi')
plot(d1_lo, color=color.red, title='DonchL Lo')
plot(d2_hi, color=color.navy, title='DonchS Hi')
plot(d2_lo, color=color.orange, title='DonchS Lo')
