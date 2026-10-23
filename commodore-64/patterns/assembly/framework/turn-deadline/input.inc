; GETIN uses the current input channel. Caller starts with CLRCHN.
; Delivered Space/T characters become action/toggle bits in STATE+8.
; Buffered input and firmware repeat are retained, not physical press edges.
sample_keys:
    lda #0
    sta STATE+8
    jsr $ffe4
    cmp #32
    bne check_toggle
    inc STATE+8
    rts
check_toggle:
    cmp #84
    bne key_done
    lda #2
    sta STATE+8
key_done:
    rts
