.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
APPLIED=$80
REJECTED=$81
FULL=$82
VALID=$83
MODE=$84
SLOT=$85
GENERATION=$86
ACTIVE=$87
COUNT=$88
G0=$89
G1=$8a
G2=$8b
G3=$8c
O0=$8d
O1=$8e
O2=$8f
O3=$90
S0=$91
S1=$92
S2=$93
S3=$94
H0=$95
H1=$96
H2=$97
H3=$98
T0=$99
T1=$9a
T2=$9b
T3=$9c
T4=$9d
T5=$9e
T6=$9f
EXPR_SAVE=$a0
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
