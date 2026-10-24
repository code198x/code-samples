APPLIED=$80
REJECTED=$81
FULL=$82
VALID=$83
MODE=$84
SLOT=$85
GENERATION=$86
ACTIVE=$87
COUNT=$88
G0=$89
G1=$8a
G2=$8b
G3=$8c
O0=$8d
O1=$8e
O2=$8f
O3=$90
S0=$91
S1=$92
S2=$93
S3=$94
H0=$95
H1=$96
H2=$97
H3=$98
T0=$99
T1=$9a
T2=$9b
T3=$9c
T4=$9d
T5=$9e
T6=$9f
EXPR_SAVE=$a0
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
