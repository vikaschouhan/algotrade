//@version=4
study("Pivot Points Standard", overlay=true)

time_frame     = input("D", type=input.resolution)
prev_close     = security(syminfo.tickerid, time_frame, close[1], lookahead=true)
prev_open      = security(syminfo.tickerid, time_frame, open[1], lookahead=true)
prev_high      = security(syminfo.tickerid, time_frame, high[1], lookahead=true)
prev_low       = security(syminfo.tickerid, time_frame, low[1], lookahead=true)

pi_level       = (prev_high + prev_low + prev_close)/3
bc_level       = (prev_high + prev_low)/2
tc_level       = (pi_level - bc_level) + pi_level
r1_level       = pi_level * 2 - prev_low
s1_level       = pi_level * 2 - prev_high

var line r1_line = na
var line pi_line = na
var line s1_line = na
var line bc_line = na
var line tc_line = na

if pi_level[1] != pi_level
    line.set_x2(r1_line, bar_index)
    line.set_x2(pi_line, bar_index)
    line.set_x2(s1_line, bar_index)
    line.set_x2(bc_line, bar_index)
    line.set_x2(tc_line, bar_index)
    
    line.set_extend(r1_line, extend.none)
    line.set_extend(pi_line, extend.none)
    line.set_extend(s1_line, extend.none)
    line.set_extend(bc_line, extend.none)
    line.set_extend(tc_line, extend.none)
    
    r1_line := line.new(bar_index, r1_level, bar_index, r1_level, extend=extend.right, color=color.green)
    pi_line := line.new(bar_index, pi_level, bar_index, pi_level, width=2, extend=extend.right, color=color.black)
    s1_line := line.new(bar_index, s1_level, bar_index, s1_level, extend=extend.right, color=color.red)
    bc_line := line.new(bar_index, bc_level, bar_index, bc_level, extend=extend.right, color=color.blue)
    tc_line := line.new(bar_index, tc_level, bar_index, tc_level, extend=extend.right, color=color.blue)
    
    label.new(bar_index, r1_level, "R1", style=label.style_none)
    label.new(bar_index, pi_level, "P",  style=label.style_none)
    label.new(bar_index, s1_level, "S1", style=label.style_none)
    label.new(bar_index, bc_level, "BC", style=label.style_none)
    label.new(bar_index, tc_level, "TC", style=label.style_none)
//

if not na(pi_line) and line.get_x2(pi_line) != bar_index
    line.set_x2(r1_line, bar_index)
    line.set_x2(pi_line, bar_index)
    line.set_x2(s1_line, bar_index)
    line.set_x2(bc_line, bar_index)
    line.set_x2(tc_line, bar_index)
//
