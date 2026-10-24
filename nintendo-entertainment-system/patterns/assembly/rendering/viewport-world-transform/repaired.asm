.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
SCREEN_X=$80
SCREEN_Y=$81
VISIBLE=$82
VALID=$83
WORLD_X_LO=$84
WORLD_X_HI=$85
WORLD_Y_LO=$86
WORLD_Y_HI=$87
CAMERA_X_LO=$88
CAMERA_X_HI=$89
CAMERA_Y_LO=$8a
CAMERA_Y_HI=$8b
WIDTH=$8c
HEIGHT=$8d
T0=$8e
T1=$8f
T2=$90
T3=$91
STATE=$80
input_ptr=$70
cases_left=$72
ptr=$74
saved_y=$76
OUTPUT=$0200
preview=OUTPUT+1400
ready=OUTPUT+1408
CUSTOM=0
BROKEN=0
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
