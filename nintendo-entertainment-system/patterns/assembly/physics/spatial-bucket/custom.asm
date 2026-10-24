.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
BUCKET=$80
COUNT=$81
INSERTED=$82
FULL=$83
VALID=$84
MODE=$85
INPUT_X=$86
INPUT_Y=$87
ITEM=$88
C0=$89
C1=$8a
C2=$8b
C3=$8c
S0=$8d
S1=$8e
S2=$8f
S3=$90
S4=$91
S5=$92
S6=$93
S7=$94
S8=$95
S9=$96
S10=$97
S11=$98
S12=$99
S13=$9a
S14=$9b
S15=$9c
T0=$9d
T1=$9e
T2=$9f
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
