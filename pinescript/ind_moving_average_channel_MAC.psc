//@version=4
study("Moving Average Channel Indicator", overlay=true)

ma_len         = input(defval=9,                    type=input.integer, title='Moving Average Period')
time_frame     = input(defval='5',                  type=input.resolution, title='Time Frame')
ma_type        = input(defval='ema',                type=input.string, title='MA type', options=['ema', 'sma'])

//////////////////////////////
/// Calculate high and low levels
hi_line_ema = security(syminfo.ticker, time_frame, ema(high, ma_len))
lo_line_ema = security(syminfo.ticker, time_frame, ema(low, ma_len))
hi_line_sma = security(syminfo.ticker, time_frame, sma(high, ma_len))
lo_line_sma = security(syminfo.ticker, time_frame, sma(low, ma_len))

hi_line  = 0.0
lo_line  = 0.0
if ma_type == 'ema'
    hi_line   := hi_line_ema 
    lo_line   := lo_line_ema
//
if ma_type == 'sma'
    hi_line   := hi_line_sma
    lo_line   := lo_line_sma
//
mid_line = avg(hi_line, lo_line)

////////////////////////////////
/// Plot
plot(hi_line,       color=color.green, title='Ch HI')
plot(lo_line,       color=color.red,   title='Ch LO')
plot(mid_line,      color=color.olive, title='Ch MID')
