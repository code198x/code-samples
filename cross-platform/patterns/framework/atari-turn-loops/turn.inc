; Caller defines T as the first of seven disjoint private RAM bytes.
; T+0 turns, +1 previous sample, +2/+3 serviced fields, +4 current,
; +5 step size, +6 accepted flag. Decimal mode must be clear.
; init_turn: A = initial counter; initialises all seven bytes, step=1.
init_turn:
    sta T
    lda #0
    sta T+1
    sta T+2
    sta T+3
    sta T+4
    sta T+6
    lda #1
    sta T+5
    rts
; sample_turn: A = active-high button mask, same bit convention each call.
; Changes A/flags, preserves X/Y. Counter wraps modulo 256.
; No hardware access or waiting. 2 stack bytes for a direct JSR.
sample_turn:
    sta T+4
!source "edge-filter.inc"
    beq held_or_released
    lda T
    clc
    adc T+5
    sta T
    lda #1
    sta T+6
    bne remember_sample
held_or_released:
    lda #0
    sta T+6
remember_sample:
    lda T+4
    sta T+1
    rts
; One accepted display-service tick, independent of rule progression.
; Changes flags only; wraps at 65536. Call exactly once per serviced field.
service_tick:
    inc T+2
    bne tick_done
    inc T+3
tick_done:
    rts
turn_end:
