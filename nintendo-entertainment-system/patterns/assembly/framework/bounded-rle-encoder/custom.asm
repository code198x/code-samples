.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
WRITTEN=$80
ERROR=$81
VALID=$82
INPUT_COUNT=$83
CAPACITY=$84
B0=$85
B1=$86
B2=$87
B3=$88
B4=$89
B5=$8a
B6=$8b
B7=$8c
R0=$8d
R1=$8e
R2=$8f
R3=$90
R4=$91
R5=$92
R6=$93
R7=$94
R8=$95
R9=$96
R10=$97
R11=$98
R12=$99
R13=$9a
R14=$9b
R15=$9c
T0=$9d
T1=$9e
T2=$9f
T3=$a0
T4=$a1
EXPR_SAVE=$a2
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
