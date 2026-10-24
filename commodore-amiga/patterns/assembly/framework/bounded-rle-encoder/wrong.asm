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
WRITTEN: dc.b 0
ERROR: dc.b 0
VALID: dc.b 0
INPUT_COUNT: dc.b 0
CAPACITY: dc.b 0
B0: dc.b 0
B1: dc.b 0
B2: dc.b 0
B3: dc.b 0
B4: dc.b 0
B5: dc.b 0
B6: dc.b 0
B7: dc.b 0
R0: dc.b 0
R1: dc.b 0
R2: dc.b 0
R3: dc.b 0
R4: dc.b 0
R5: dc.b 0
R6: dc.b 0
R7: dc.b 0
R8: dc.b 0
R9: dc.b 0
R10: dc.b 0
R11: dc.b 0
R12: dc.b 0
R13: dc.b 0
R14: dc.b 0
R15: dc.b 0
T0: dc.b 0
T1: dc.b 0
T2: dc.b 0
T3: dc.b 0
T4: dc.b 0
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
