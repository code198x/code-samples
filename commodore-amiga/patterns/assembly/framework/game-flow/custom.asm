    section code,code_c
RESET_HEALTH = 5
BROKEN = 0
    include "caller.inc"
    include "exercise.inc"
component_start:
    include "flow.inc"
    include "display.inc"
    include "../turn-deadline/font.inc"
code_end:
flow_state: dc.b 0
flow_events: dc.b 0
flow_changed: dc.b 0
flow_fresh: dc.b 0
flow_error: dc.b 0
previous: dc.b 0
held: dc.b 0
score: dc.b 0
health: dc.b 0
resets: dc.b 0
resumed: dc.b 0
finished: dc.b 0
invalid_seen: dc.b 0
    even
ready: dc.w 0
preview: dcb.b 8,0
OUTPUT: dcb.b 1405,0
    even
signature: dc.b "198XFLOWAMIGA!!",0
    even
copperlist:
    dc.w $08e,$2c81,$090,$2cc1,$092,$0038,$094,$00d0
    dc.w $100,$1200,$102,0,$104,0,$108,0,$10a,0
    dc.w $180,$012,$182,$fff
copbpl:
    dc.w $0e0,0,$0e2,0
    dc.w $ffff,$fffe
plane: dcb.b 10240,0
