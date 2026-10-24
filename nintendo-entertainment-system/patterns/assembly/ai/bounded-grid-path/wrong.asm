.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
MOVE=$80
DISTANCE=$81
FOUND=$82
VALID=$83
FROM=$84
TO=$85
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
T0=$96
T1=$97
T2=$98
T3=$99
T4=$9a
T5=$9b
T6=$9c
T7=$9d
EXPR_SAVE=$9e
V0=$9f
V1=$a0
V2=$a1
V3=$a2
V4=$a3
V5=$a4
V6=$a5
V7=$a6
V8=$a7
V9=$a8
V10=$a9
V11=$aa
V12=$ab
V13=$ac
V14=$ad
V15=$ae
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
