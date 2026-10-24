.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
POOL_CAPACITY=8
POOL_FLAGS=$81
POOL_LIFE=$90
mask_index=$70
mask_shift=$71
selected=$72
status_bits=$73
ptr=$74
saved_y=$76
saved_x=$77
occupancy_bits=$78
OUTPUT=$0200
preview=OUTPUT+1296
ready=OUTPUT+1304
BROKEN=0
.include "caller.inc"
.include "exercise.inc"
.include "../../../../../cross-platform/patterns/framework/object-pool/6502.inc"
.include "../../../../../cross-platform/patterns/framework/object-pool/age6502.inc"
code_end:
.segment "VECTORS"
.word nmi,reset,irq
.segment "CHARS"
.include "../../input/controller-reading/edges-font.inc"
.res 8192-272,0
