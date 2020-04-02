// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © presentisgood

//@version=4
study("Moving Averages", overlay=true)

ma_p1    = input(defval=9,     title='MA Length 1')
ma_p2    = input(defval=14,    title='MA Length 2')
ma_p3    = input(defval=50,    title='MA Length 3')
ma_p4    = input(defval=100,   title='MA Length 4')
ma_p5    = input(defval=200,   title='MA Length 5')
ma_type  = input(defval='EMA', title='MA type', options=['EMA', 'SMA'])

ma_1 = 0.0
ma_2 = 0.0
ma_3 = 0.0
ma_4 = 0.0
ma_5 = 0.0

if ma_type == 'EMA'
    ma_1 := ema(close, ma_p1)
    ma_2 := ema(close, ma_p2)
    ma_3 := ema(close, ma_p3)
    ma_4 := ema(close, ma_p4)
    ma_5 := ema(close, ma_p5)
//
if ma_type == 'SMA'
    ma_1 := sma(close, ma_p1)
    ma_2 := sma(close, ma_p2)
    ma_3 := sma(close, ma_p3)
    ma_4 := sma(close, ma_p4)
    ma_5 := sma(close, ma_p5)
//

plot(ma_1, title='MA1', color=color.green)
plot(ma_2, title='MA2', color=color.blue)
plot(ma_3, title='MA3', color=color.red)
plot(ma_4, title='MA4', color=color.olive)
plot(ma_5, title='MA5', color=color.orange)
