.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
POSITION=$80
PUSHED=$81
BLOCKED=$82
VALID=$83
ACTOR_POSITION=$84
ACTOR_SIZE=$85
SOLID_OLD=$86
SOLID_NEW=$87
SOLID_SIZE=$88
MINIMUM=$89
MAXIMUM=$8a
T0=$8b
T1=$8c
T2=$8d
T3=$8e
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
