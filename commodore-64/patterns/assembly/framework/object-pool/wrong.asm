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
OUTPUT=$c000
preview=OUTPUT+1296
ready=OUTPUT+1304
BROKEN=1
!source "caller.inc"
!source "exercise.inc"
!source "../../../../../cross-platform/patterns/framework/object-pool/6502.inc"
!source "../../../../../cross-platform/patterns/framework/object-pool/age6502.inc"
hex_font:
    !byte 0,0,0,0,0,0,0,0,0,56,40,40,40,56,0,0,0,16,48,16,16,56,0,0,0,56,8,56,32,56,0,0,0,56,8,56,8,56,0,0,0,40,40,56,8,8,0,0,0,56,32,56,8,56,0,0,0,56,32,56,40,56,0,0,0,56,8,8,8,8,0,0,0,56,40,56,40,56,0,0,0,56,40,56,8,56,0,0,0,16,40,56,40,40,0,0,0,48,40,48,40,48,0,0,0,56,32,32,32,56,0,0,0,48,40,40,40,48,0,0,0,56,32,48,32,56,0,0,0,56,32,48,32,32,0,0
code_end:
