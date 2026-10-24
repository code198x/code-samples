.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
NOTE=$80
EVENT=$81
FINISHED=$82
VALID=$83
INDEX=$84
REMAINING=$85
COUNT=$86
N0=$87
N1=$88
N2=$89
N3=$8a
N4=$8b
N5=$8c
N6=$8d
N7=$8e
U0=$8f
U1=$90
U2=$91
U3=$92
U4=$93
U5=$94
U6=$95
U7=$96
T0=$97
T1=$98
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
