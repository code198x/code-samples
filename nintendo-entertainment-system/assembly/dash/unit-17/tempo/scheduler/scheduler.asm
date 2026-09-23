; A = elapsed musical time in units of 1/300 second, normal range 1..6.
; phase = unspent units, 0..5. A/X/Y may change through tune_tick.
; One player update per 6 units: nominal 50 updates/second.
; Caller must supply elapsed time; this routine does not measure a clock.
; First call after start_phrase services the first row immediately.
tempo_service:
    cmp #1
    bcc tempo_overload
    cmp #7
    bcs tempo_overload
    ldx tempo_started
    bne @advance
    ldx #1
    stx tempo_started
    jmp tune_tick
@advance:
    clc
    adc tempo_phase
    cmp #6
    bcs @due
    sta tempo_phase
    rts
@due:
    sec
    sbc #6
    sta tempo_phase
    jmp tune_tick

tempo_overload:
    lda #1
    sta tempo_fault
    lda #0
    sta tune_ptr+1
    sta tempo_phase
    lda #$30
    sta SQ1_VOL
    rts
