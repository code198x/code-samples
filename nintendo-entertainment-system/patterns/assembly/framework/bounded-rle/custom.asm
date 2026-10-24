.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
WRITTEN=$80
ERROR=$81
INPUT_START=$82
INPUT_END=$83
OUTPUT_LIMIT=$84
BUF0=$85
BUF1=$86
BUF2=$87
BUF3=$88
BUF4=$89
BUF5=$8a
BUF6=$8b
BUF7=$8c
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
