    section code,code_c
CUSTOM = 0
BROKEN = 1
SCORE_CAP = 65535
QUEUE_CAP = 4
REPEAT_DELAY = 4
REPEAT_RATE = 2
    include "caller.inc"
    include "exercise.inc"
component_start:
    include "component.inc"
    include "cases.inc"
    include "display.inc"
    include "../turn-deadline/font.inc"
code_end:
STATE:
BALANCE: dc.b 0
AMOUNT: dc.b 0
MODE: dc.b 0
OK: dc.b 0
    even
ready: dc.w 0
preview: dcb.b 8,0
OUTPUT: dcb.b 1300,0
    even
signature: dc.b "198XGAMEPLAY000",0
    even
copperlist:
    dc.w $08e,$2c81,$090,$2cc1,$092,$0038,$094,$00d0
    dc.w $100,$1200,$102,0,$104,0,$108,0,$10a,0
    dc.w $180,$012,$182,$fff
copbpl:
    dc.w $0e0,0,$0e2,0
    dc.w $ffff,$fffe
plane: dcb.b 10240,0
