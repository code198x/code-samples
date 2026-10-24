    section code,code_c
SEED = 0
BROKEN = 0
    include "caller.inc"
    include "exercise.inc"
    include "rng.inc"
    include "display.inc"
    include "../turn-deadline/font.inc"
code_end:
rng_state: dc.b 0
checkpoint: dc.b 0
ready: dc.w 0
preview: dcb.b 8,0
OUTPUT: dcb.b 795,0
    even
signature: dc.b "198XRANDOMAMIGA",0
    even
copperlist:
    dc.w $08e,$2c81,$090,$2cc1,$092,$0038,$094,$00d0
    dc.w $100,$1200,$102,0,$104,0,$108,0,$10a,0
    dc.w $180,$012,$182,$fff
copbpl:
    dc.w $0e0,0,$0e2,0
    dc.w $ffff,$fffe
plane: dcb.b 10240,0
