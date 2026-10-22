; State and output are independent: only turn_init/turn_advance change count.
; A in; A/CC out. One byte, addition modulo 256.
turn_init:
    sta turn_count
    rts
turn_advance:
    lda turn_count
    adda #STEP
    sta turn_count
    rts
; Presentation: overwrites text cells $0400..$0407, no cursor changes.
show_turn:
    ldx #$0400
    lda #20
    sta ,x+
    lda #21
    sta ,x+
    lda #18
    sta ,x+
    lda #14
    sta ,x+
    lda #32
    sta ,x+
    lda #36
    sta ,x+
    lda turn_count
    lsra
    lsra
    lsra
    lsra
    jsr hex_digit
    sta ,x+
    lda turn_count
    anda #15
    jsr hex_digit
    sta ,x
    rts
hex_digit:
    cmpa #10
    blo digit
    adda #7
digit:
    adda #48
    anda #63
    rts
; Three cells per row; $0440/0460/0480. Preserves all other display cells.
draw_box:
    lda #DRAW
    beq box_done
    lda #24
    sta $0440
    sta $0441
    sta $0442
    sta $0460
    sta $0462
    sta $0480
    sta $0481
    sta $0482
    lda #32
    sta $0461
box_done:
    rts
; Blocking one-bit pulse train. Save/restore data, DDR and control register.
; No pitch/timing guarantee; ROM IRQs remain enabled.
trigger_sound:
    lda #SOUND
    beq sound_done
    lda $FF23
    pshs a
    anda #$F3
    sta $FF23
    lda $FF22
    pshs a
    ora #2
    sta $FF22
    lda $FF23
    ora #4
    sta $FF23
    lda $FF22
    pshs a
    ldx #200
sound_pulse:
    eora #2
    sta $FF22
    ldb #100
sound_delay:
    decb
    bne sound_delay
    leax -1,x
    bne sound_pulse
    puls a
    sta $FF22
    lda $FF23
    anda #$FB
    sta $FF23
    puls a
    sta $FF22
    puls a
    sta $FF23
sound_done:
    rts
turn_count:
    fcb 0
