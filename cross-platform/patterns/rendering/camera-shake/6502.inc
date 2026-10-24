; SPDX-License-Identifier: MIT
; Keep Camera Shake out of World State. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
camera_shake_init:
    lda #0
    sta OFFSET_X
    sta OFFSET_Y
    sta REMAINING
    sta AMPLITUDE
    sta VALID
    sta TRIGGER
    sta STRENGTH
    sta DURATION
    sta NOISE_X
    sta NOISE_Y
    sta T0
    sta T1
    rts
camera_shake_step:
; OFFSET_X = 0
    lda #0
    sta OFFSET_X
; OFFSET_Y = 0
    lda #0
    sta OFFSET_Y
; VALID = 0
    lda #0
    sta VALID
; if STRENGTH > 15:
    lda STRENGTH
    cmp #15
    beq camera_shake_L5
    bcs camera_shake_L4
camera_shake_L5:
    jmp camera_shake_L2
camera_shake_L4:
    jmp camera_shake_L1
camera_shake_L1:
; return
    rts
    jmp camera_shake_L3
camera_shake_L2:
camera_shake_L3:
; if TRIGGER == 0:
    lda TRIGGER
    cmp #0
    beq camera_shake_L9
camera_shake_L10:
    jmp camera_shake_L7
camera_shake_L9:
    jmp camera_shake_L6
camera_shake_L6:
; if AMPLITUDE > 15:
    lda AMPLITUDE
    cmp #15
    beq camera_shake_L15
    bcs camera_shake_L14
camera_shake_L15:
    jmp camera_shake_L12
camera_shake_L14:
    jmp camera_shake_L11
camera_shake_L11:
; return
    rts
    jmp camera_shake_L13
camera_shake_L12:
camera_shake_L13:
    jmp camera_shake_L8
camera_shake_L7:
camera_shake_L8:
; VALID = 1
    lda #1
    sta VALID
; if TRIGGER != 0:
    lda TRIGGER
    cmp #0
    bne camera_shake_L19
camera_shake_L20:
    jmp camera_shake_L17
camera_shake_L19:
    jmp camera_shake_L16
camera_shake_L16:
; AMPLITUDE = STRENGTH
    lda STRENGTH
    sta AMPLITUDE
; REMAINING = DURATION
    lda DURATION
    sta REMAINING
    jmp camera_shake_L18
camera_shake_L17:
camera_shake_L18:
; if REMAINING == 0:
    lda REMAINING
    cmp #0
    beq camera_shake_L24
camera_shake_L25:
    jmp camera_shake_L22
camera_shake_L24:
    jmp camera_shake_L21
camera_shake_L21:
; return
    rts
    jmp camera_shake_L23
camera_shake_L22:
camera_shake_L23:
; REMAINING = REMAINING - 1
    lda REMAINING
    sec
    sbc #1
    sta REMAINING
; if AMPLITUDE == 0:
    lda AMPLITUDE
    cmp #0
    beq camera_shake_L29
camera_shake_L30:
    jmp camera_shake_L27
camera_shake_L29:
    jmp camera_shake_L26
camera_shake_L26:
; return
    rts
    jmp camera_shake_L28
camera_shake_L27:
camera_shake_L28:
; T0 = AMPLITUDE << 1
    lda AMPLITUDE
    asl
    sta T0
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
; T1 = NOISE_X
    lda NOISE_X
    sta T1
; while T1 >= T0:
camera_shake_L31:
    lda T1
    cmp T0
    bcs camera_shake_L34
camera_shake_L35:
    jmp camera_shake_L33
camera_shake_L34:
    jmp camera_shake_L32
camera_shake_L32:
; T1 = T1 - T0
    lda T1
    sec
    sbc T0
    sta T1
    jmp camera_shake_L31
camera_shake_L33:
; OFFSET_X = T1 - AMPLITUDE
    lda T1
    sec
    sbc AMPLITUDE
    sta OFFSET_X
; T1 = NOISE_Y
    lda NOISE_Y
    sta T1
; while T1 >= T0:
camera_shake_L36:
    lda T1
    cmp T0
    bcs camera_shake_L39
camera_shake_L40:
    jmp camera_shake_L38
camera_shake_L39:
    jmp camera_shake_L37
camera_shake_L37:
; T1 = T1 - T0
    lda T1
    sec
    sbc T0
    sta T1
    jmp camera_shake_L36
camera_shake_L38:
; OFFSET_Y = T1 - AMPLITUDE
    lda T1
    sec
    sbc AMPLITUDE
    sta OFFSET_Y
    rts
component_end:
