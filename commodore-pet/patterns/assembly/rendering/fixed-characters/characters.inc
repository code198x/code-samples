; Define FC (24 zero-page bytes). Caller owns the 40-column PET screen.
; +0 source word, +2 x, +3 y, +4 count, +5 accepted, +6 writes.
; Inputs +0..4 survive. Scratch +5..23 may change. A/X/Y/flags clobbered.
; No colour RAM, charset/mode changes or interrupt changes.
character_span:
    lda #0
    sta FC+5
    sta FC+6
    lda FC+2
    cmp #40
    bcs fc_reject
    lda FC+3
    cmp #25
    bcs fc_reject
    lda FC+4
    beq fc_reject
    lda #40
    sec
    sbc FC+2
    cmp FC+4
    bcc fc_reject
    lda #0
    sta FC+10
    lda #$80
    sta FC+11
    ldx FC+3
    beq fc_row_ready
fc_next_row:
    clc
    lda FC+10
    adc #40
    sta FC+10
    bcc fc_row_no_carry
    inc FC+11
fc_row_no_carry:
    dex
    bne fc_next_row
fc_row_ready:
    clc
    lda FC+10
    adc FC+2
    sta FC+10
    bcc fc_start_ready
    inc FC+11
fc_start_ready:
    ldy #0
fc_copy:
    lda (FC),y
    sta (FC+10),y
    iny
    cpy FC+4
    bne fc_copy
    sty FC+6
    lda #1
    sta FC+5
fc_reject:
    rts
character_span_end:
