    section code,code_c
CUSTOM = 0
BROKEN = 0
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
APPLIED: dc.b 0
REJECTED: dc.b 0
FULL: dc.b 0
VALID: dc.b 0
MODE: dc.b 0
SLOT: dc.b 0
GENERATION: dc.b 0
ACTIVE: dc.b 0
COUNT: dc.b 0
G0: dc.b 0
G1: dc.b 0
G2: dc.b 0
G3: dc.b 0
O0: dc.b 0
O1: dc.b 0
O2: dc.b 0
O3: dc.b 0
S0: dc.b 0
S1: dc.b 0
S2: dc.b 0
S3: dc.b 0
H0: dc.b 0
H1: dc.b 0
H2: dc.b 0
H3: dc.b 0
T0: dc.b 0
T1: dc.b 0
T2: dc.b 0
T3: dc.b 0
T4: dc.b 0
T5: dc.b 0
T6: dc.b 0
EXPR_SAVE: dc.b 0
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
