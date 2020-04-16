//@version=3
study(title='Market Profile', shorttitle='MP', overlay=true)
/////////////////////////////////////////////////////
//  ||--    Inputs:
session_timeframe = input('D')
percent_of_tpo    = input(0.70)
tf_high           = high
tf_low            = low
tf_close          = close

///////////////////////////////////////////////////
//  ||--    Bars since session started:
session_bar_counter = n-valuewhen(change(time(session_timeframe)) != 0, n, 0)
session_high        = tf_high
session_low         = tf_low
session_range       = tf_high - tf_low

session_high        := nz(session_high[1], tf_high)
session_low         := nz(session_low[1], tf_low)
session_range       := nz(session_high - session_low, 0.0)

//      ||--    recalculate session high, low and range:
if session_bar_counter == 0
    session_high    := tf_high
    session_low     := tf_low
    session_range   := tf_high - tf_low
//
if tf_high > session_high[1]
    session_high    := tf_high
    session_range   := session_high - session_low
//
if tf_low < session_low[1]
    session_low     := tf_low
    session_range   := session_high - session_low
//

////////////////////////////////////////////
///
plot(series=session_high, title='Session High', color=blue)
plot(series=session_low, title='Session Low', color=blue)

////////////////////////////////////////////
//  ||--    define tpo section range:
tpo_section_range = session_range / 25

//  ||--    function to get the frequency a specified range is visited:
f_frequency_of_range(_src, _upper_range, _lower_range, _length)=>
    _adjusted_length = _length < 1 ? 1 : _length
    _frequency = 0
    for _i = 0 to _adjusted_length-1
        if (_src[_i] >= _lower_range and _src[_i] <= _upper_range)
            _frequency := _frequency + 1
    _return = nz(_frequency, 0) // _adjusted_length
//

//  ||--    frequency the tpo range is visited:
tpo_00 = f_frequency_of_range(tf_close, session_high, session_high - tpo_section_range * 1, session_bar_counter)
tpo_01 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 1, session_high - tpo_section_range * 2, session_bar_counter)
tpo_02 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 2, session_high - tpo_section_range * 3, session_bar_counter)
tpo_03 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 3, session_high - tpo_section_range * 4, session_bar_counter)
tpo_04 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 4, session_high - tpo_section_range * 5, session_bar_counter)
tpo_05 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 5, session_high - tpo_section_range * 6, session_bar_counter)
tpo_06 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 6, session_high - tpo_section_range * 7, session_bar_counter)
tpo_07 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 7, session_high - tpo_section_range * 8, session_bar_counter)
tpo_08 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 8, session_high - tpo_section_range * 9, session_bar_counter)
tpo_09 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 9, session_high - tpo_section_range * 10, session_bar_counter)
tpo_10 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 10, session_high - tpo_section_range * 11, session_bar_counter)
tpo_11 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 11, session_high - tpo_section_range * 12, session_bar_counter)
tpo_12 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 12, session_high - tpo_section_range * 13, session_bar_counter)
tpo_13 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 13, session_high - tpo_section_range * 14, session_bar_counter)
tpo_14 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 14, session_high - tpo_section_range * 15, session_bar_counter)
tpo_15 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 15, session_high - tpo_section_range * 16, session_bar_counter)
tpo_16 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 16, session_high - tpo_section_range * 17, session_bar_counter)
tpo_17 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 17, session_high - tpo_section_range * 18, session_bar_counter)
tpo_18 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 18, session_high - tpo_section_range * 19, session_bar_counter)
tpo_19 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 19, session_high - tpo_section_range * 20, session_bar_counter)
tpo_20 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 20, session_high - tpo_section_range * 21, session_bar_counter)
tpo_21 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 21, session_high - tpo_section_range * 22, session_bar_counter)
tpo_22 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 22, session_high - tpo_section_range * 23, session_bar_counter)
tpo_23 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 23, session_high - tpo_section_range * 24, session_bar_counter)
tpo_24 = f_frequency_of_range(tf_close, session_high - tpo_section_range * 24, session_high - tpo_section_range * 25, session_bar_counter)

//  ||--    function to retrieve a specific tpo value
f_get_tpo_count(_value)=>
    _return = 0.0
    if _value == 0
        _return := tpo_00
    if _value == 1
        _return := tpo_01
    if _value == 2
        _return := tpo_02
    if _value == 3
        _return := tpo_03
    if _value == 4
        _return := tpo_04
    if _value == 5
        _return := tpo_05
    if _value == 6
        _return := tpo_06
    if _value == 7
        _return := tpo_07
    if _value == 8
        _return := tpo_08
    if _value == 9
        _return := tpo_09
    if _value == 10
        _return := tpo_10
    if _value == 11
        _return := tpo_11
    if _value == 12
        _return := tpo_12
    if _value == 13
        _return := tpo_13
    if _value == 14
        _return := tpo_14
    if _value == 15
        _return := tpo_15
    if _value == 16
        _return := tpo_16
    if _value == 17
        _return := tpo_17
    if _value == 18
        _return := tpo_18
    if _value == 19
        _return := tpo_19
    if _value == 20
        _return := tpo_20
    if _value == 21
        _return := tpo_21
    if _value == 22
        _return := tpo_22
    if _value == 23
        _return := tpo_23
    if _value == 24
        _return := tpo_24
    _return
//

tpo_sum              = 0.0
current_poc_position = 0.0
current_poc_value    = 0.0
for _i = 0 to 25
    _get_tpo_value = f_get_tpo_count(_i)
    tpo_sum        := tpo_sum + _get_tpo_value
    if _get_tpo_value > current_poc_value
        current_poc_position := _i
        current_poc_value    := _get_tpo_value
    //
//

//////////////////////////////////////////////
///
//plot(series=tpo_sum, title='tpo_sum', color=red)
poc_upper = session_high - tpo_section_range * current_poc_position
poc_lower = session_high - tpo_section_range * (current_poc_position + 1)
plot(series=poc_upper, title='POC Upper', color=black)
plot(series=poc_lower, title='POC Lower', color=black)

//  ||--    get value area high/low
vah_position = current_poc_position
val_position = current_poc_position
current_sum  = current_poc_value

for _i = 0 to 25
    if current_sum < tpo_sum * percent_of_tpo
        vah_position := max(0, vah_position - 1)
        current_sum  := current_sum + f_get_tpo_count(round(vah_position))
    //
    if current_sum < tpo_sum * percent_of_tpo
        val_position := min(24, val_position + 1)
        current_sum  := current_sum + f_get_tpo_count(round(val_position))
    //
//

vah_value = session_high - tpo_section_range * vah_position
val_value = session_high - tpo_section_range * (val_position + 1)
//plot(series=vah_value, title='VAH', color=navy)
//plot(series=val_value, title='VAL', color=navy)
//plot(series=current_sum, title='SUM', color=red)
//plot(series=valuewhen(session_bar_counter == 0, vah_value[1], 0), title='VAH', color=navy, trackprice=true, offset=1, show_last=1)
//plot(series=valuewhen(session_bar_counter == 0, val_value[1], 0), title='VAL', color=navy, trackprice=true, offset=1, show_last=1)

f_gapper(_return_value)=>
    _return = _return_value
    if session_bar_counter == 0
        _return := na
    _return

plot(series=f_gapper(valuewhen(session_bar_counter == 0, vah_value[1], 0)), title='VAH', color=green, linewidth=2, style=linebr, transp=0)
plot(series=f_gapper(valuewhen(session_bar_counter == 0, val_value[1], 0)), title='VAL', color=maroon, linewidth=2, style=linebr, transp=0)
plot(series=f_gapper(valuewhen(session_bar_counter == 0, poc_upper[1], 0)), title='POC Upper', color=black, linewidth=2, style=linebr, transp=0)
plot(series=f_gapper(valuewhen(session_bar_counter == 0, poc_lower[1], 0)), title='POC Lower', color=black, linewidth=2, style=linebr, transp=0)

