; One main producer, one non-reentrant NMI consumer, ordinary RAM.
; X/Y = period low/high. Carry clear = accepted; set = still pending.
; Caller retains a refused request and decides when to retry.
publish_period:
    lda request_ready
    bne @full
    stx request_lo
    sty request_hi
    lda #1
    sta request_ready       ; publish LAST; main must now leave payload alone
    clc
    rts
@full:
    sec
    rts

; Called inside Dash's existing A/X/Y-preserving NMI handler.
; At most one request, no wait. Only this consumer writes these pulse settings.
consume_period:
    lda request_ready
    beq @empty
    lda #$B8
    sta SQ1_VOL
    lda #0
    sta SQ1_SWEEP
    lda request_lo
    sta SQ1_LO
    lda request_hi
    sta SQ1_HI
    lda #0
    sta request_ready       ; release only after the last payload read
@empty:
    rts
