.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
EVENT=$80
PRIORITY=$81
RESULT=$82
VALID=$83
COUNT=$84
MODE=$85
NEW_EVENT=$86
NEW_PRIORITY=$87
E0=$88
E1=$89
E2=$8a
E3=$8b
P0=$8c
P1=$8d
P2=$8e
P3=$8f
T0=$90
T1=$91
T2=$92
EXPR_SAVE=$93
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
