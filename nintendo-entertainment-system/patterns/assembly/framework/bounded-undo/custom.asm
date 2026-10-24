.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
RESULT=$80
VALID=$81
COUNT=$82
MODE=$83
CELL=$84
VALUE=$85
C0=$86
C1=$87
C2=$88
C3=$89
C4=$8a
C5=$8b
C6=$8c
C7=$8d
C8=$8e
C9=$8f
C10=$90
C11=$91
C12=$92
C13=$93
C14=$94
C15=$95
J0=$96
J1=$97
J2=$98
J3=$99
K0=$9a
K1=$9b
K2=$9c
K3=$9d
T0=$9e
T1=$9f
T2=$a0
EXPR_SAVE=$a1
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
