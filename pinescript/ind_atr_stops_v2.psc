//@version=4
study(title="ATR Trailing Stoploss v2", overlay = true)

atr_period = input(defval=5,     type=input.integer, title="ATR Period")
atr_mult   = input(defval=1.5,   type=input.float,   title="ATR Multiplier")

n_loss       = atr_mult * atr(atr_period)
trail_loss   = 0.0
trail_loss   := iff(close > nz(trail_loss[1], 0) and close[1] > nz(trail_loss[1], 0), max(nz(trail_loss[1]), close - n_loss), iff(close < nz(trail_loss[1], 0) and close[1] < nz(trail_loss[1], 0), min(nz(trail_loss[1]), close + n_loss), iff(close > nz(trail_loss[1], 0), close - n_loss, close + n_loss)))

pos     = 0.0
pos     := iff(close[1] < nz(trail_loss[1], 0) and close > nz(trail_loss[1], 0), 1, iff(close[1] > nz(trail_loss[1], 0) and close < nz(trail_loss[1], 0), -1, nz(pos[1], 0))) 
p_color = pos == -1 ? color.red : pos == 1 ? color.green : color.blue

plot(trail_loss, color=p_color, title="ATR Trailing Stop v2")
