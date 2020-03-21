//@version=4
study(title="ORB", shorttitle="ORB", overlay=true)

tframe = input(defval="15", type=input.resolution)

is_newbar(res) =>
    change(time(res)) != 0
//

high_range  = valuewhen(is_newbar('D'), high, 0)
low_range   = valuewhen(is_newbar('D'), low,  0)

high_rangeL = security(syminfo.tickerid, tframe, high_range)
low_rangeL  = security(syminfo.tickerid, tframe, low_range) 

plot(high_rangeL, color=color.green, linewidth=2) 
plot(low_rangeL,  color=color.red, linewidth=2) 

