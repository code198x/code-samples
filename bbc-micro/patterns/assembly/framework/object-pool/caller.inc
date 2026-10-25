*=$3000
mask_index=$3e00
mask_shift=$3e01
selected=$3e02
status_bits=$3e03
saved_y=$3e04
saved_x=$3e05
occupancy_bits=$3e06
init_sig=$3e07
preview=$3e08
check_a=$3e12
check_b=$3e13
ready=$3e14
end_ptr=$3e16
case_i=$3e18
saved_iy=$3e1a
POOL_FLAGS=$4000
POOL_LIFE=$4200
OUTPUT=$4800
ptr=$0070
start:
    php
    pha
    txa
    pha
    tya
    pha
    lda ptr
    pha
    lda ptr+1
    pha
    cld
!if BOUNDARY=0 {
    jsr exercise_pool
    jsr preview_pool
    lda #0
    sta check_a
    sta check_b
    lda preview+4
    cmp #1
    bne main_a_done
    inc check_a
main_a_done:
    lda preview+8
    bne main_b_done
    inc check_b
main_b_done:
    ldx #0
main_preview:
    lda preview,x
    jsr emit
    inx
    cpx #9
    bne main_preview
} else {
    jsr boundary_pool
    lda #1
    sta check_a
    sta check_b
}
    lda check_a
    jsr emit
    lda check_b
    jsr emit
    lda #239
    jsr emit
    lda ptr
    sta end_ptr
    lda ptr+1
    sta end_ptr+1
    lda #239
    sta ready
    pla
    sta ptr+1
    pla
    sta ptr
    pla
    tay
    pla
    tax
    pla
    plp
    rts
!if BOUNDARY=0 {
    !source "../../../../../cross-platform/patterns/framework/additional-object-pools/exercise6502.inc"
} else {
    !source "../../../../../cross-platform/patterns/framework/additional-object-pools/boundary6502.inc"
emit:
    sty saved_y
    ldy #0
    sta (ptr),y
    inc ptr
    bne emit_done
    inc ptr+1
emit_done:
    ldy saved_y
    rts
}
    !source "pool.inc"
    !source "age.inc"
!if POOL_CAPACITY=1 {
CASE_COUNT=2
free_cases: !byte 0,1
} else {
CASE_COUNT=5
free_cases: !byte 0,127,128,254,255
}
code_end:
