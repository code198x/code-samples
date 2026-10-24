    section code,code_c
CUSTOM = 1
BROKEN = 0
COYOTE_STEPS = 2
BUFFER_STEPS = 2
TEXT_CAP = 4
PROPERTY_COUNT = 16
STREAM_BYTES = 13
CRC_POLY = 49
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
POSITION: dc.b 0
HIT: dc.b 0
VALID: dc.b 0
OLD_POSITION: dc.b 0
TARGET: dc.b 0
SIZE: dc.b 0
WALL_START: dc.b 0
WALL_END: dc.b 0
T0: dc.b 0
T1: dc.b 0
    even
ready: dc.w 0
preview: dcb.b 8,0
OUTPUT: dcb.b 1300,0
    even
signature: dc.b "198XTOOLKIT0000",0
    even
copperlist:
    dc.w $08e,$2c81,$090,$2cc1,$092,$0038,$094,$00d0
    dc.w $100,$1200,$102,0,$104,0,$108,0,$10a,0
    dc.w $180,$012,$182,$fff
copbpl:
    dc.w $0e0,0,$0e2,0
    dc.w $ffff,$fffe
plane: dcb.b 10240,0
