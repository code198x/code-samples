.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
SCORE_LO=$80
SCORE_HI=$81
ADD_LO=$82
ADD_HI=$83
CLIPPED=$84
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
SCORE_CAP=999
QUEUE_CAP=2
REPEAT_DELAY=6
REPEAT_RATE=3
.include "caller.inc"
.include "exercise.inc"
component_start:
.include "component.inc"
.include "cases.inc"
code_end:
.segment "VECTORS"
.word nmi,reset,irq
.segment "CHARS"
.include "../../input/controller-reading/edges-font.inc"
.res 8192-272,0
