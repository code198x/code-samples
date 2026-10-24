; SPDX-License-Identifier: MIT
; Service a Timed Status Effect. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
timed_status_init:
    lda #0
    sta PULSE
    sta REMAINING
    sta PHASE
    sta DURATION
    sta PERIOD
    sta APPLY
    sta VALID
    rts
timed_status_step:
; PULSE = 0
    lda #0
    sta PULSE
; VALID = 0
    lda #0
    sta VALID
; if PERIOD == 0:
    lda PERIOD
    cmp #0
    beq timed_status_L4
timed_status_L5:
    jmp timed_status_L2
timed_status_L4:
    jmp timed_status_L1
timed_status_L1:
; return
    rts
    jmp timed_status_L3
timed_status_L2:
timed_status_L3:
; if PHASE >= PERIOD:
    lda PHASE
    cmp PERIOD
    bcs timed_status_L9
timed_status_L10:
    jmp timed_status_L7
timed_status_L9:
    jmp timed_status_L6
timed_status_L6:
; return
    rts
    jmp timed_status_L8
timed_status_L7:
timed_status_L8:
; VALID = 1
    lda #1
    sta VALID
; if APPLY != 0:
    lda APPLY
    cmp #0
    bne timed_status_L14
timed_status_L15:
    jmp timed_status_L12
timed_status_L14:
    jmp timed_status_L11
timed_status_L11:
; REMAINING = DURATION
    lda DURATION
    sta REMAINING
; PHASE = 0
    lda #0
    sta PHASE
    jmp timed_status_L13
timed_status_L12:
timed_status_L13:
; if REMAINING == 0:
    lda REMAINING
    cmp #0
    beq timed_status_L19
timed_status_L20:
    jmp timed_status_L17
timed_status_L19:
    jmp timed_status_L16
timed_status_L16:
; PHASE = 0
    lda #0
    sta PHASE
; return
    rts
    jmp timed_status_L18
timed_status_L17:
timed_status_L18:
; REMAINING = REMAINING - 1
    lda REMAINING
    sec
    sbc #1
    sta REMAINING
; PHASE = PHASE + 1
    lda PHASE
    clc
    adc #1
    sta PHASE
; if PHASE == PERIOD:
    lda PHASE
    cmp PERIOD
    beq timed_status_L24
timed_status_L25:
    jmp timed_status_L22
timed_status_L24:
    jmp timed_status_L21
timed_status_L21:
; PHASE = 0
    lda #0
    sta PHASE
; PULSE = 1
    lda #1
    sta PULSE
    jmp timed_status_L23
timed_status_L22:
timed_status_L23:
; if REMAINING == 0:
    lda REMAINING
    cmp #0
    beq timed_status_L29
timed_status_L30:
    jmp timed_status_L27
timed_status_L29:
    jmp timed_status_L26
timed_status_L26:
; PHASE = 0
    lda #0
    sta PHASE
    jmp timed_status_L28
timed_status_L27:
timed_status_L28:
    rts
component_end:
