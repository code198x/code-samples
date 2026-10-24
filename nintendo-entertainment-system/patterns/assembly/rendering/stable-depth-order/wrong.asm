.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
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
