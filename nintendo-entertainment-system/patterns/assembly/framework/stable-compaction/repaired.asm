.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
COUNT=$80
REMOVED=$81
VALID=$82
F0=$83
F1=$84
F2=$85
F3=$86
F4=$87
F5=$88
F6=$89
F7=$8a
I0=$8b
I1=$8c
I2=$8d
I3=$8e
I4=$8f
I5=$90
I6=$91
I7=$92
T0=$93
T1=$94
T2=$95
T3=$96
T4=$97
EXPR_SAVE=$98
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
