//@version=5
strategy("RSI mean reversion with single ema filter and ema crossover as exit", overlay=false)

/////////////////////////////////////////////////////////////////////
// Inputs
time_frame     = input.timeframe(defval="",      title="RSI Time frame")
rsi_len        = input.int(defval=2,             title="RSI Length")
rsi_threshold  = input.int(defval=2,             title="RSI Threshold")
ema_time_frame = input.timeframe(defval="",      title="EMA Time Frame")
ema_len        = input.int(defval=700,           title="EMA Length")

/////////////////////////////////////////////////////////////////////
// Get signals
rsi_sig = request.security(syminfo.tickerid, time_frame, ta.rsi(close, rsi_len)[1], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on)
ema_sig = request.security(syminfo.tickerid, ema_time_frame, ta.ema(close, ema_len)[1], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on)

/////////////////////////////////////////////////////////////////////
// Positional signals
buy   = ta.crossunder(rsi_sig, rsi_threshold) and (close > ema_sig)
sell  = ta.crossunder(close, ema_sig)
short = ta.crossover(rsi_sig, 100-rsi_threshold) and (close < ema_sig)
cover = ta.crossover(close, ema_sig)

////////////////////////////////////////////////////////////////////
// Execute positions
if buy
    strategy.entry("L", strategy.long)
if sell
    strategy.close("L")
if short
    strategy.entry("S", strategy.short)
if cover
    strategy.close("S")
//

//////////////////////////////////////////////////////////////////////
// Plotting functions
plot(rsi_sig, color=color.blue, title="RSI")
plot(rsi_threshold, color=color.black, title="RSI LThr")
plot(100-rsi_threshold, color=color.black, title="RSI HThr")
