; MOS OSBYTE 129: negative INKEY scans. No key-buffer consumption.
; Returns controls bits U/D/L/R/action=1/2/4/8/16; changes A/X/Y/flags.
read_controls:
    lda #0
    sta controls
    ldx #0
key_next:
    stx key_index
    lda #129
    ldy #$ff
    lda key_numbers,x
    tax
    lda #129
    jsr OSBYTE
    txa
    ldx key_index
    cmp #0
    beq key_up
    lda controls
    ora key_masks,x
    sta controls
key_up:
    inx
    cpx #5
    bne key_next
    rts
key_numbers: !byte $ef,$be,$c9,$c8,$9d ; Q/A/O/P/Space (-17/-66/-55/-56/-99)
key_masks: !byte 1,2,4,8,16
key_index: !byte 0
