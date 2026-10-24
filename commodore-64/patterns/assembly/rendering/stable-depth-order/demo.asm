COUNT=$80
VALID=$81
Z0=$82
Z1=$83
Z2=$84
Z3=$85
Z4=$86
Z5=$87
Z6=$88
Z7=$89
I0=$8a
I1=$8b
I2=$8c
I3=$8d
I4=$8e
I5=$8f
I6=$90
I7=$91
T0=$92
T1=$93
T2=$94
T3=$95
T4=$96
T5=$97
T6=$98
EXPR_SAVE=$99
STATE=$80
input_ptr=$70
cases_left=$72
ptr=$74
saved_y=$76
OUTPUT=$c000
preview=OUTPUT+1400
ready=OUTPUT+1408
CUSTOM=0
BROKEN=0
COYOTE_STEPS=4
BUFFER_STEPS=4
TEXT_CAP=8
PROPERTY_COUNT=16
STREAM_BYTES=13
CRC_POLY=7
!source "caller.inc"
!source "exercise.inc"
component_start:
!source "component.inc"
!source "data.inc"
!source "cases.inc"
hex_font:
    !byte 0,0,0,0,0,0,0,0,0,56,40,40,40,56,0,0,0,16,48,16,16,56,0,0,0,56,8,56,32,56,0,0,0,56,8,56,8,56,0,0,0,40,40,56,8,8,0,0,0,56,32,56,8,56,0,0,0,56,32,56,40,56,0,0,0,56,8,8,8,8,0,0,0,56,40,56,40,56,0,0,0,56,40,56,8,56,0,0,0,16,40,56,40,40,0,0,0,48,40,48,40,48,0,0,0,56,32,32,32,56,0,0,0,48,40,40,40,48,0,0,0,56,32,48,32,56,0,0,0,56,32,48,32,32,0,0
code_end:
