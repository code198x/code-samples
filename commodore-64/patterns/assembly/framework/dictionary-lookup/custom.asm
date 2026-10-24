VALUE=$80
FOUND=$81
VALID=$82
KEY=$83
COUNT=$84
K0=$85
K1=$86
K2=$87
K3=$88
K4=$89
K5=$8a
K6=$8b
K7=$8c
Q0=$8d
Q1=$8e
Q2=$8f
Q3=$90
Q4=$91
Q5=$92
Q6=$93
Q7=$94
T0=$95
T1=$96
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
