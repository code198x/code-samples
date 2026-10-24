.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
VALUE_LO=$80
VALUE_HI=$81
DIGIT0=$82
DIGIT1=$83
DIGIT2=$84
DIGIT3=$85
DIGIT4=$86
WORK_LO=$87
WORK_HI=$88
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
SCORE_CAP=65535
QUEUE_CAP=4
REPEAT_DELAY=4
REPEAT_RATE=2
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
