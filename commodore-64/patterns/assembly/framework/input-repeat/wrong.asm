HELD=$80
WAS_HELD=$81
TIMER=$82
PULSE=$83
STATE=$80
input_ptr=$70
cases_left=$72
ptr=$74
saved_y=$76
OUTPUT=$c000
preview=OUTPUT+1400
ready=OUTPUT+1408
CUSTOM=0
BROKEN=1
SCORE_CAP=65535
QUEUE_CAP=4
REPEAT_DELAY=4
REPEAT_RATE=2
!source "caller.inc"
!source "exercise.inc"
component_start:
!source "component.inc"
!source "cases.inc"
hex_font:
    !byte 0,0,0,0,0,0,0,0,0,56,40,40,40,56,0,0,0,16,48,16,16,56,0,0,0,56,8,56,32,56,0,0,0,56,8,56,8,56,0,0,0,40,40,56,8,8,0,0,0,56,32,56,8,56,0,0,0,56,32,56,40,56,0,0,0,56,8,8,8,8,0,0,0,56,40,56,40,56,0,0,0,56,40,56,8,56,0,0,0,16,40,56,40,40,0,0,0,48,40,48,40,48,0,0,0,56,32,32,32,56,0,0,0,48,40,40,40,48,0,0,0,56,32,48,32,56,0,0,0,56,32,48,32,32,0,0
code_end:
