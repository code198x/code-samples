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
NOTE: dc.b 0
EVENT: dc.b 0
FINISHED: dc.b 0
VALID: dc.b 0
INDEX: dc.b 0
REMAINING: dc.b 0
COUNT: dc.b 0
N0: dc.b 0
N1: dc.b 0
N2: dc.b 0
N3: dc.b 0
N4: dc.b 0
N5: dc.b 0
N6: dc.b 0
N7: dc.b 0
U0: dc.b 0
U1: dc.b 0
U2: dc.b 0
U3: dc.b 0
U4: dc.b 0
U5: dc.b 0
U6: dc.b 0
U7: dc.b 0
T0: dc.b 0
T1: dc.b 0
    even
ready: dc.w 0
preview: dcb.b 8,0
OUTPUT: dcb.b 1300,0
    even
signature: dc.b "198XNIGHTTWO000",0
    even
copperlist:
    dc.w $08e,$2c81,$090,$2cc1,$092,$0038,$094,$00d0
    dc.w $100,$1200,$102,0,$104,0,$108,0,$10a,0
    dc.w $180,$012,$182,$fff
copbpl:
    dc.w $0e0,0,$0e2,0
    dc.w $ffff,$fffe
plane: dcb.b 10240,0
