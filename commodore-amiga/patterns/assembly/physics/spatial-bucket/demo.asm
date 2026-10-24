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
BUCKET: dc.b 0
COUNT: dc.b 0
INSERTED: dc.b 0
FULL: dc.b 0
VALID: dc.b 0
MODE: dc.b 0
INPUT_X: dc.b 0
INPUT_Y: dc.b 0
ITEM: dc.b 0
C0: dc.b 0
C1: dc.b 0
C2: dc.b 0
C3: dc.b 0
S0: dc.b 0
S1: dc.b 0
S2: dc.b 0
S3: dc.b 0
S4: dc.b 0
S5: dc.b 0
S6: dc.b 0
S7: dc.b 0
S8: dc.b 0
S9: dc.b 0
S10: dc.b 0
S11: dc.b 0
S12: dc.b 0
S13: dc.b 0
S14: dc.b 0
S15: dc.b 0
T0: dc.b 0
T1: dc.b 0
T2: dc.b 0
EXPR_SAVE: dc.b 0
    even
ready: dc.w 0
preview: dcb.b 8,0
OUTPUT: dcb.b 1300,0
    even
signature: dc.b "198XNIGHTONE000",0
    even
copperlist:
    dc.w $08e,$2c81,$090,$2cc1,$092,$0038,$094,$00d0
    dc.w $100,$1200,$102,0,$104,0,$108,0,$10a,0
    dc.w $180,$012,$182,$fff
copbpl:
    dc.w $0e0,0,$0e2,0
    dc.w $ffff,$fffe
plane: dcb.b 10240,0
