//@version=5
strategy("Candles breakout from Range - Exit after n bars", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

time_frame = input.timeframe(defval='', title='Time Frame')
range_thr  = input.float(defval=10, title='Engulfing candle range in %')
exit_nbars = input.int(defval=4, title='Exit after n bars.')

get_history(src) =>
    [ request.security(syminfo.tickerid, time_frame, src),
      request.security(syminfo.tickerid, time_frame, src[1]),
      request.security(syminfo.tickerid, time_frame, src)[2],
      request.security(syminfo.tickerid, time_frame, src[3]),
      request.security(syminfo.tickerid, time_frame, src[4]),
      request.security(syminfo.tickerid, time_frame, src[5])
      ]
//

candles_compare(open_new, close_new, high_old, low_old) =>
    (open_new < high_old) and (open_new > low_old) and (close_new < high_old) and (close_new > low_old)
//

abs_perct(src1, src2) =>
    math.abs(src1 - src2)/src2 * 100
//

// BarsSinceLastEntry() returns the number of bars since the last,
// most recent entry in the strategy's current open position. Returns
// 'na' when the strategy has no position.
bars_since_last_entry() =>
    bar_index - strategy.opentrades.entry_bar_index(strategy.opentrades - 1)
//    

[open_0, open_1, open_2, open_3, open_4, open_5] = get_history(open[1])
[close_0, close_1, close_2, close_3, close_4, close_5] = get_history(close[1])
[high_0, high_1, high_2, high_3, high_4, high_5] = get_history(high[1])
[low_0, low_1, low_2, low_3, low_4, low_5] = get_history(low[1])

// Actual logic
logic_1 = candles_compare(open_0, close_0, high_1, low_1) and
          abs_perct(high_1, low_1) > range_thr and
          (close > high_0) and
          (close > high_1)

logic_2 = candles_compare(open_0, close_0, high_2, low_2) and
          candles_compare(open_1, close_1, high_2, low_2) and
          abs_perct(high_2, low_2) > range_thr and
          (close > high_0) and
          (close > high_1) and
          (close > high_2)

logic_3 = candles_compare(open_0, close_0, high_3, low_3) and
          candles_compare(open_1, close_1, high_3, low_3) and
          candles_compare(open_2, close_2, high_3, low_3) and
          abs_perct(high_3, low_3) > range_thr and
          (close > high_0) and
          (close > high_1) and
          (close > high_2) and
          (close > high_3)

logic_4 = candles_compare(open_0, close_0, high_4, low_4) and
          candles_compare(open_1, close_1, high_4, low_4) and
          candles_compare(open_2, close_2, high_4, low_4) and
          candles_compare(open_3, close_3, high_4, low_4) and
          abs_perct(high_4, low_4) > range_thr and
          (close > high_0) and
          (close > high_1) and
          (close > high_2) and
          (close > high_3) and
          (close > high_4)

logic_5 = candles_compare(open_0, close_0, high_5, low_5) and
          candles_compare(open_1, close_1, high_5, low_5) and
          candles_compare(open_2, close_2, high_5, low_5) and
          candles_compare(open_3, close_3, high_5, low_5) and
          candles_compare(open_4, close_4, high_5, low_5) and
          abs_perct(high_5, low_5) > range_thr and
          (close > high_0) and
          (close > high_1) and
          (close > high_2) and
          (close > high_3) and
          (close > high_4) and
          (close > high_5)

final_logic = logic_1 or logic_2 or logic_3 or logic_4 or logic_5

buy_sig = final_logic

if buy_sig
    strategy.entry("L", strategy.long)
//
if bars_since_last_entry() >= exit_nbars
    strategy.close("L")
//


plotshape(final_logic, style=shape.triangleup, color=color.green, location=location.belowbar, size=size.small)
