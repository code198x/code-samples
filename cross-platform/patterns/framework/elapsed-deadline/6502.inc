; DEADLINE owns 12 bytes. A=clock low, X=clock high; decimal mode clear.
; Poll at least once per 65536 clock ticks. A/X/status clobbered; Y preserved.
deadline_init:
    sta DEADLINE+8
    stx DEADLINE+9
    lda #0
    sta DEADLINE+2
    sta DEADLINE+3
    sta DEADLINE+4
    sta DEADLINE+5
    sta DEADLINE+6
    sta DEADLINE+7
    rts
deadline_start:
    lda DEADLINE
    sta DEADLINE+2
    lda DEADLINE+1
    sta DEADLINE+3
    ora DEADLINE
    beq deadline_off
    lda #1
deadline_off:
    sta DEADLINE+4
    lda #0
    sta DEADLINE+5
    rts
deadline_poll:
    sta DEADLINE+10
    stx DEADLINE+11
    sec
    sbc DEADLINE+8
    sta DEADLINE+6
    txa
    sbc DEADLINE+9
    sta DEADLINE+7
    lda DEADLINE+10
    sta DEADLINE+8
    lda DEADLINE+11
    sta DEADLINE+9
    lda #0
    sta DEADLINE+5
    lda DEADLINE+4
    beq deadline_done
    sec
    lda DEADLINE+2
    sbc DEADLINE+6
    sta DEADLINE+2
    lda DEADLINE+3
    sbc DEADLINE+7
    sta DEADLINE+3
    bcc deadline_expired
    ora DEADLINE+2
    bne deadline_done
deadline_expired:
    lda #0
    sta DEADLINE+2
    sta DEADLINE+3
    sta DEADLINE+4
    lda #1
    sta DEADLINE+5
deadline_done:
    rts
