    section code,code_c
PERIOD = 3
BROKEN = 0
    include "caller.inc"
    include "exercise.inc"
component_start:
    include "component.inc"
    include "cases.inc"
    include "display.inc"
    include "../turn-deadline/font.inc"
code_end:
REMAINING: dc.b 0
REQUEST: dc.b 0
AVAILABLE: dc.b 0
GRANTED: dc.b 0
accepted: dc.b 0
blocked: dc.b 0
at_three: dc.b 0
at_six: dc.b 0
availability_guard: dc.b 0
case_kind: dc.b 0
    even
ready: dc.w 0
preview: dcb.b 8,0
OUTPUT: dcb.b 1335,0
    even
signature: dc.b "198XCOOLDNAMIGA",0
    even
copperlist:
    dc.w $08e,$2c81,$090,$2cc1,$092,$0038,$094,$00d0
    dc.w $100,$1200,$102,0,$104,0,$108,0,$10a,0
    dc.w $180,$012,$182,$fff
copbpl:
    dc.w $0e0,0,$0e2,0
    dc.w $ffff,$fffe
plane: dcb.b 10240,0
