HEALTH=$80
REMAINING=$81
AMOUNT=$82
APPLIED=$83
KILLED=$84
input_ptr=$70
cases_left=$72
ptr=$74
saved_y=$76
trace_index=$77
accepted=$78
first_death=$79
deaths=$7a
blocked=$7b
snapshot=$7c
OUTPUT=$c000
preview=OUTPUT+1480
ready=OUTPUT+1488
PERIOD=3
BROKEN=0
!source "caller.inc"
!source "exercise.inc"
component_start:
!source "component.inc"
!source "cases.inc"
hex_font:
    !byte 0,0,0,0,0,0,0,0,0,56,40,40,40,56,0,0,0,16,48,16,16,56,0,0,0,56,8,56,32,56,0,0,0,56,8,56,8,56,0,0,0,40,40,56,8,8,0,0,0,56,32,56,8,56,0,0,0,56,32,56,40,56,0,0,0,56,8,8,8,8,0,0,0,56,40,56,40,56,0,0,0,56,40,56,8,56,0,0,0,16,40,56,40,40,0,0,0,48,40,48,40,48,0,0,0,56,32,32,32,56,0,0,0,48,40,40,40,48,0,0,0,56,32,48,32,56,0,0,0,56,32,48,32,32,0,0
code_end:
