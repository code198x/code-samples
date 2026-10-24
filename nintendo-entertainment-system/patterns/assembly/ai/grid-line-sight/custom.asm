.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
VISIBLE=$80
VALID=$81
FROM=$82
TO=$83
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
T8=$9c
T9=$9d
T10=$9e
T11=$9f
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
