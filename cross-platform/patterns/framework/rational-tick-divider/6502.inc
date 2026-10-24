; SPDX-License-Identifier: MIT
; Divide Ticks Without Losing the Remainder. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
rational_tick_divider_init:
    lda #0
    sta PHASE
    sta NUMERATOR
    sta DENOMINATOR
    sta FIRED
    sta VALID
    sta T0
    rts
rational_tick_divider_step:
; FIRED = 0
    lda #0
    sta FIRED
; VALID = 0
    lda #0
    sta VALID
; if DENOMINATOR == 0:
    lda DENOMINATOR
    cmp #0
    beq rational_tick_divider_L4
rational_tick_divider_L5:
    jmp rational_tick_divider_L2
rational_tick_divider_L4:
    jmp rational_tick_divider_L1
rational_tick_divider_L1:
; return
    rts
    jmp rational_tick_divider_L3
rational_tick_divider_L2:
rational_tick_divider_L3:
; if NUMERATOR > DENOMINATOR:
    lda NUMERATOR
    cmp DENOMINATOR
    beq rational_tick_divider_L10
    bcs rational_tick_divider_L9
rational_tick_divider_L10:
    jmp rational_tick_divider_L7
rational_tick_divider_L9:
    jmp rational_tick_divider_L6
rational_tick_divider_L6:
; return
    rts
    jmp rational_tick_divider_L8
rational_tick_divider_L7:
rational_tick_divider_L8:
; if PHASE >= DENOMINATOR:
    lda PHASE
    cmp DENOMINATOR
    bcs rational_tick_divider_L14
rational_tick_divider_L15:
    jmp rational_tick_divider_L12
rational_tick_divider_L14:
    jmp rational_tick_divider_L11
rational_tick_divider_L11:
; return
    rts
    jmp rational_tick_divider_L13
rational_tick_divider_L12:
rational_tick_divider_L13:
; VALID = 1
    lda #1
    sta VALID
; T0 = DENOMINATOR - NUMERATOR
    lda DENOMINATOR
    sec
    sbc NUMERATOR
    sta T0
; if PHASE >= T0:
    lda PHASE
    cmp T0
    bcs rational_tick_divider_L19
rational_tick_divider_L20:
    jmp rational_tick_divider_L17
rational_tick_divider_L19:
    jmp rational_tick_divider_L16
rational_tick_divider_L16:
; PHASE = PHASE - T0
    lda PHASE
    sec
    sbc T0
    sta PHASE
; FIRED = 1
    lda #1
    sta FIRED
    jmp rational_tick_divider_L18
rational_tick_divider_L17:
; PHASE = PHASE + NUMERATOR
    lda PHASE
    clc
    adc NUMERATOR
    sta PHASE
rational_tick_divider_L18:
    rts
component_end:
