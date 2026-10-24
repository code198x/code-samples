.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
NORMAL_OUT=$80
DIRECTION_OUT=$81
TANGENT_OUT=$82
VALID=$83
NORMAL_IN=$84
DIRECTION_IN=$85
TANGENT_IN=$86
RESTITUTION=$87
T0=$88
T1=$89
T2=$8a
T3=$8b
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
