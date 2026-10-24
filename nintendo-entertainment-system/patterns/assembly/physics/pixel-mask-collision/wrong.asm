.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
HIT=$80
ROW=$81
SHIFT_X=$82
SHIFT_Y=$83
P0=$84
P1=$85
P2=$86
P3=$87
P4=$88
P5=$89
P6=$8a
P7=$8b
Q0=$8c
Q1=$8d
Q2=$8e
Q3=$8f
Q4=$90
Q5=$91
Q6=$92
Q7=$93
T0=$94
T1=$95
T2=$96
T3=$97
T4=$98
T5=$99
STATE=$80
input_ptr=$70
cases_left=$72
ptr=$74
saved_y=$76
OUTPUT=$0200
preview=OUTPUT+1400
ready=OUTPUT+1408
CUSTOM=0
BROKEN=1
COYOTE_STEPS=4
BUFFER_STEPS=4
TEXT_CAP=8
PROPERTY_COUNT=16
STREAM_BYTES=13
CRC_POLY=7
.include "caller.inc"
.include "exercise.inc"
component_start:
.include "component.inc"
.include "data.inc"
.include "cases.inc"
code_end:
.segment "VECTORS"
.word nmi,reset,irq
.segment "CHARS"
.include "../../input/controller-reading/edges-font.inc"
.res 8192-272,0
