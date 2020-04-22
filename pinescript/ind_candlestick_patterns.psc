//@version=4
study("Candlestick patterns", overlay=true)

/////////////////////////////////////
/// Params
shape_loc     = location.belowbar
shape_style   = shape.arrowup

////////////////////////////////////
/// Patterns
// Inside bars
ibar_0    = (high < high[1]) and (low > low[1])
ibar_1    = (high < high[2]) and (low > low[2]) and (high[1] < high[2]) and (low[1] > low[2])
ibar_2    = (high < high[3]) and (low > low[3]) and (high[1] < high[3]) and (low[1] > low[3]) and (high[2] < high[3]) and (low[2] > low[3])

// Outside bars
obar_0    = (high > high[1]) and (low < low[1])
obar_1    = (high > high[2]) and (low < low[2]) and (high[1] > high[2]) and (low[1] < low[2])
obar_2    = (high > high[3]) and (low < low[3]) and (high[1] > high[3]) and (low[1] < low[3]) and (high[2] > high[3]) and (low[2] < low[3])

////////////////////////////////////
/// Plot patterns
plotshape(ibar_0, title= "Inside_bar",      location=shape_loc, color=color.lime, style=shape_style, text="IB")
plotshape(ibar_1, title="Inside_bar1",      location=shape_loc, color=color.teal, style=shape_style, text="IB1")
plotshape(ibar_2, title="Inside_bar2",      location=shape_loc, color=color.blue, style=shape_style, text="IB2")

plotshape(obar_0, title="Outside_bar",      location=shape_loc, color=color.orange, style=shape_style, text="OB")
plotshape(obar_1, title="Outside_bar1",     location=shape_loc, color=color.red,    style=shape_style, text="OB1")
plotshape(obar_2, title="Outside_bar2",     location=shape_loc, color=color.navy,   style=shape_style, text="OB2")
