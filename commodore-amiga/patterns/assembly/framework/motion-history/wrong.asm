    section code,code_c
CUSTOM = 0
BROKEN = 1
COYOTE_STEPS = 4
BUFFER_STEPS = 4
TEXT_CAP = 8
PROPERTY_COUNT = 16
STREAM_BYTES = 13
CRC_POLY = 7
    include "caller.inc"
    include "exercise.inc"
component_start:
    include "component.inc"
    even
    include "data.inc"
    include "cases.inc"
    even
    include "display.inc"
    include "../../framework/turn-deadline/font.inc"
code_end:
STATE:
OUT_X: dc.b 0
OUT_Y: dc.b 0
VALID: dc.b 0
HEAD: dc.b 0
COUNT: dc.b 0
INPUT_X: dc.b 0
INPUT_Y: dc.b 0
LAG: dc.b 0
PUSH: dc.b 0
HX0: dc.b 0
HX1: dc.b 0
HX2: dc.b 0
HX3: dc.b 0
HX4: dc.b 0
HX5: dc.b 0
HX6: dc.b 0
HX7: dc.b 0
HY0: dc.b 0
HY1: dc.b 0
HY2: dc.b 0
HY3: dc.b 0
HY4: dc.b 0
HY5: dc.b 0
HY6: dc.b 0
HY7: dc.b 0
T0: dc.b 0
EXPR_SAVE: dc.b 0
    even
ready: dc.w 0
preview: dcb.b 8,0
OUTPUT: dcb.b 1300,0
    even
signature: dc.b "198XWORLDKIT000",0
    even
copperlist:
    dc.w $08e,$2c81,$090,$2cc1,$092,$0038,$094,$00d0
    dc.w $100,$1200,$102,0,$104,0,$108,0,$10a,0
    dc.w $180,$012,$182,$fff
copbpl:
    dc.w $0e0,0,$0e2,0
    dc.w $ffff,$fffe
plane: dcb.b 10240,0
