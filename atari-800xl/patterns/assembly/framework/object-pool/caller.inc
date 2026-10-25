*=$8000
mask_index=$8600
mask_shift=$8601
selected=$8602
status_bits=$8603
saved_y=$8604
saved_x=$8605
occupancy_bits=$8606
init_sig=$8607
preview=$8608
check_a=$8612
check_b=$8613
ready=$8614
end_ptr=$8616
case_i=$8618
saved_iy=$861a
POOL_FLAGS=$8700
POOL_LIFE=$8900
OUTPUT=$9000
ptr=$00cb
start:
    pla
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
    lda #0
    sta $00d4
    sta $00d5
    sta $00d6
    sta $00d7
    sta $00d8
    sta $00d9
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
