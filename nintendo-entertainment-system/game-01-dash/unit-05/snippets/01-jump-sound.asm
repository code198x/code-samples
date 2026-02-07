    ; --- Play jump sound ---
    lda #%10111000          ; Duty 50%, constant volume, level 8
    sta SQ1_VOL
    lda #%10111001          ; Sweep: on, period 3, negate, shift 1
    sta SQ1_SWEEP
    lda #$C8                ; Timer low ($0C8 ≈ 556 Hz)
    sta SQ1_LO
    lda #$00                ; Timer high
    sta SQ1_HI
