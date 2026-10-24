; No I/O. Expiry beats command; byte turn and expiry counters wrap.
dispatch:
    lda DEADLINE+5
    beq dispatch_key
    lda #0
    sta KEY
    inc EXPIRIES
    inc TURN
    jmp deadline_start
dispatch_key:
    lda KEY
    cmp #2
    bne dispatch_action
    lda DEADLINE+4
    beq dispatch_enable
    lda #0
    sta DEADLINE+4
    sta DEADLINE+2
    sta DEADLINE+3
    rts
dispatch_enable:
    jmp deadline_start
dispatch_action:
    cmp #1
    bne dispatch_done
    inc TURN
    lda DEADLINE+4
    beq dispatch_done
    jmp deadline_start
dispatch_done:
    rts
