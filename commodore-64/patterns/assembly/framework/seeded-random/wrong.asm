RNG_STATE=$70
seed_index=$71
checkpoint=$72
reg_x=$73
ptr=$74
reg_y=$76
OUTPUT=$c000
preview=OUTPUT+800
ready=OUTPUT+808
SEED=0
BROKEN=1
!source "caller.inc"
!source "../../../../../cross-platform/patterns/framework/seeded-random/exercise6502.inc"
!source "../../../../../cross-platform/patterns/framework/seeded-random/6502.inc"
hex_font:
    !byte 0,0,0,0,0,0,0,0,0,56,40,40,40,56,0,0,0,16,48,16,16,56,0,0,0,56,8,56,32,56,0,0,0,56,8,56,8,56,0,0,0,40,40,56,8,8,0,0,0,56,32,56,8,56,0,0,0,56,32,56,40,56,0,0,0,56,8,8,8,8,0,0,0,56,40,56,40,56,0,0,0,56,40,56,8,56,0,0,0,16,40,56,40,40,0,0,0,48,40,48,40,48,0,0,0,56,32,32,32,56,0,0,0,48,40,40,40,48,0,0,0,56,32,48,32,56,0,0,0,56,32,48,32,32,0,0
code_end:
