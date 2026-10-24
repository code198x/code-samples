.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
OUT_X=$80
OUT_Y=$81
VALID=$82
HEAD=$83
COUNT=$84
INPUT_X=$85
INPUT_Y=$86
LAG=$87
PUSH=$88
HX0=$89
HX1=$8a
HX2=$8b
HX3=$8c
HX4=$8d
HX5=$8e
HX6=$8f
HX7=$90
HY0=$91
HY1=$92
HY2=$93
HY3=$94
HY4=$95
HY5=$96
HY6=$97
HY7=$98
T0=$99
EXPR_SAVE=$9a
STATE=$80
input_ptr=$70
cases_left=$72
ptr=$74
saved_y=$76
OUTPUT=$0200
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
