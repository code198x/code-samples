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
CELL: dc.b 0
RESULT: dc.b 0
VALID: dc.b 0
REQUEST: dc.b 0
C0: dc.b 0
C1: dc.b 0
C2: dc.b 0
C3: dc.b 0
C4: dc.b 0
C5: dc.b 0
C6: dc.b 0
C7: dc.b 0
C8: dc.b 0
C9: dc.b 0
C10: dc.b 0
C11: dc.b 0
C12: dc.b 0
C13: dc.b 0
C14: dc.b 0
C15: dc.b 0
T0: dc.b 0
T1: dc.b 0
T2: dc.b 0
T3: dc.b 0
T4: dc.b 0
T5: dc.b 0
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
