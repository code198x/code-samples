.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
SEED=$80
REPLACEMENT=$81
CHANGED=$82
VALID=$83
C0=$84
C1=$85
C2=$86
C3=$87
C4=$88
C5=$89
C6=$8a
C7=$8b
C8=$8c
C9=$8d
C10=$8e
C11=$8f
C12=$90
C13=$91
C14=$92
C15=$93
T0=$94
T1=$95
T2=$96
T3=$97
T4=$98
T5=$99
T6=$9a
T7=$9b
EXPR_SAVE=$9c
V0=$9d
V1=$9e
V2=$9f
V3=$a0
V4=$a1
V5=$a2
V6=$a3
V7=$a4
V8=$a5
V9=$a6
V10=$a7
V11=$a8
V12=$a9
V13=$aa
V14=$ab
V15=$ac
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
