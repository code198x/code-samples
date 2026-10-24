.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
OUT_LEFT=$80
OUT_TOP=$81
OUT_RIGHT=$82
OUT_BOTTOM=$83
VISIBLE=$84
VALID=$85
LEFT=$86
TOP=$87
RIGHT=$88
BOTTOM=$89
VIEW_LEFT=$8a
VIEW_TOP=$8b
VIEW_RIGHT=$8c
VIEW_BOTTOM=$8d
T0=$8e
T1=$8f
T2=$90
T3=$91
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
