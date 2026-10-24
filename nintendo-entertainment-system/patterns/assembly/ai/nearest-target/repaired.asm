.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
SLOT=$80
DISTANCE_LO=$81
DISTANCE_HI=$82
FOUND=$83
ACTIVE=$84
ORIGIN_X=$85
ORIGIN_Y=$86
PX0=$87
PX1=$88
PX2=$89
PX3=$8a
PY0=$8b
PY1=$8c
PY2=$8d
PY3=$8e
T0=$8f
T1=$90
T2=$91
T3=$92
T4=$93
T5=$94
T6=$95
T7=$96
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
