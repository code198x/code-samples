.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
WRITTEN=$80
VALID=$81
COUNT=$82
BASE=$83
Q0=$84
Q1=$85
Q2=$86
Q3=$87
Q4=$88
Q5=$89
Q6=$8a
Q7=$8b
R0=$8c
R1=$8d
R2=$8e
R3=$8f
R4=$90
R5=$91
R6=$92
R7=$93
T0=$94
T1=$95
T2=$96
EXPR_SAVE=$97
STATE=$80
input_ptr=$70
cases_left=$72
ptr=$74
saved_y=$76
OUTPUT=$0200
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
