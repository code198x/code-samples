; Caller supplies PF_BUFFER (72 bytes) and PF (16 zero-page bytes).
; PF+2=x, +3=y, +4=0/1; +5=accepted. A/X/Y/flags clobbered.
pf_clear:
    lda #0
    ldx #71
pf_clear_loop:
    sta PF_BUFFER,x
    dex
    bpl pf_clear_loop
    rts
pf_cell:
    lda #0
    sta PF+5
    ldx PF+2
    cpx #20
    bcs pf_cell_return
    ldy PF+3
    cpy #24
    bcs pf_cell_return
    lda PF+4
    cmp #2
    bcs pf_cell_return
    lda pf_rows,y
    clc
    adc pf_bytes,x
    tay
    lda pf_masks,x
    sta PF+6
    lda PF+4
    beq pf_cell_erase
    lda PF_BUFFER,y
    ora PF+6
    bne pf_cell_store
pf_cell_erase:
    lda PF+6
    eor #$ff
    and PF_BUFFER,y
pf_cell_store:
    sta PF_BUFFER,y
    inc PF+5
pf_cell_return:
    rts
; Opaque 5x7 stamp: PF+0/1 -> seven bytes, low five bits, bit4 left.
; Reject complete request before writing. Restores origin; clobbers PF+4.
pf_stamp:
    lda #0
    sta PF+5
    lda PF+2
    cmp #16
    bcs pf_stamp_return
    lda PF+3
    cmp #18
    bcs pf_stamp_return
    ldy #6
pf_stamp_validate:
    lda (PF),y
    cmp #32
    bcs pf_stamp_return
    dey
    bpl pf_stamp_validate
    lda PF+2
    sta PF+8
    lda PF+3
    sta PF+9
    lda #0
    sta PF+10
pf_stamp_row:
    ldy PF+10
    lda (PF),y
    sta PF+12
    lda #5
    sta PF+11
pf_stamp_column:
    lda PF+12
    and #16
    beq pf_stamp_zero
    lda #1
pf_stamp_zero:
    sta PF+4
    jsr pf_cell
    asl PF+12
    inc PF+2
    dec PF+11
    bne pf_stamp_column
    lda PF+8
    sta PF+2
    inc PF+3
    inc PF+10
    lda PF+10
    cmp #7
    bne pf_stamp_row
    lda PF+9
    sta PF+3
pf_stamp_return:
    rts
pf_rows:
    !for row,0,23 { !byte row*3 }
pf_bytes:
    !byte 0,0,0,0,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2
pf_masks:
    !byte $10,$20,$40,$80,$80,$40,$20,$10,$08,$04,$02,$01
    !byte $01,$02,$04,$08,$10,$20,$40,$80
pf_data_end:
