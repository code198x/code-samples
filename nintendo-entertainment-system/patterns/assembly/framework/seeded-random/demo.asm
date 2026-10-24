.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
RNG_STATE=$70
seed_index=$71
checkpoint=$72
reg_x=$73
ptr=$74
reg_y=$76
OUTPUT=$0300
preview=OUTPUT+800
ready=OUTPUT+808
SEED=0
BROKEN=0
.include "caller.inc"
.include "../../../../../cross-platform/patterns/framework/seeded-random/exercise6502.inc"
.include "../../../../../cross-platform/patterns/framework/seeded-random/6502.inc"
code_end:
.segment "VECTORS"
.word nmi,reset,irq
.segment "CHARS"
.include "../../input/controller-reading/edges-font.inc"
.res 8192-272,0
