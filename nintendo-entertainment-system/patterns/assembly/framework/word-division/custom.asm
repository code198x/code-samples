.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
QUOTIENT_LO=$80
QUOTIENT_HI=$81
REMAINDER=$82
VALID=$83
NUMERATOR_LO=$84
NUMERATOR_HI=$85
DIVISOR=$86
T0=$87
T1=$88
T2=$89
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
