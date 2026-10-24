    section code,code_c
POOL_CAPACITY = 8
BROKEN = 0
    include "caller.inc"
    include "exercise.inc"
component_start:
    include "pool.inc"
    include "age.inc"
    include "display.inc"
    include "../turn-deadline/font.inc"
code_end:
guard_a: dc.b 0
pool_flags: dcb.b POOL_CAPACITY,0
guard_b: dc.b 0
pool_life: dcb.b POOL_CAPACITY,0
selected: dc.b 0
status_bits: dc.b 0
    even
ready: dc.w 0
preview: dcb.b 8,0
OUTPUT: dcb.b 1294,0
    even
signature: dc.b "198XPOOLSAMIGA!",0
    even
copperlist:
    dc.w $08e,$2c81,$090,$2cc1,$092,$0038,$094,$00d0
    dc.w $100,$1200,$102,0,$104,0,$108,0,$10a,0
    dc.w $180,$012,$182,$fff
copbpl:
    dc.w $0e0,0,$0e2,0
    dc.w $ffff,$fffe
plane: dcb.b 10240,0
