WRITTEN=$80
ERROR=$81
VALID=$82
INPUT_COUNT=$83
CAPACITY=$84
B0=$85
B1=$86
B2=$87
B3=$88
B4=$89
B5=$8a
B6=$8b
B7=$8c
R0=$8d
R1=$8e
R2=$8f
R3=$90
R4=$91
R5=$92
R6=$93
R7=$94
R8=$95
R9=$96
R10=$97
R11=$98
R12=$99
R13=$9a
R14=$9b
R15=$9c
T0=$9d
T1=$9e
T2=$9f
T3=$a0
T4=$a1
EXPR_SAVE=$a2
STATE=$80
input_ptr=$70
cases_left=$72
ptr=$74
saved_y=$76
OUTPUT=$c000
preview=OUTPUT+1400
ready=OUTPUT+1408
CUSTOM=1
BROKEN=0
COYOTE_STEPS=2
BUFFER_STEPS=2
TEXT_CAP=4
PROPERTY_COUNT=16
STREAM_BYTES=13
CRC_POLY=49
!source "caller.inc"
!source "exercise.inc"
component_start:
!source "component.inc"
!source "data.inc"
!source "cases.inc"
hex_font:
    !byte 0,0,0,0,0,0,0,0,0,56,40,40,40,56,0,0,0,16,48,16,16,56,0,0,0,56,8,56,32,56,0,0,0,56,8,56,8,56,0,0,0,40,40,56,8,8,0,0,0,56,32,56,8,56,0,0,0,56,32,56,40,56,0,0,0,56,8,8,8,8,0,0,0,56,40,56,40,56,0,0,0,56,40,56,8,56,0,0,0,16,40,56,40,40,0,0,0,48,40,48,40,48,0,0,0,56,32,32,32,56,0,0,0,48,40,40,40,48,0,0,0,56,32,48,32,56,0,0,0,56,32,48,32,32,0,0
code_end:
