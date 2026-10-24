; SPDX-License-Identifier: MIT
; Reflect Movement at Axis Bounds. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
reflected_axis_init:
    lda #0
    sta POSITION
    sta MINIMUM
    sta MAXIMUM
    sta DISTANCE
    sta DIRECTION
    sta BOUNCES
    sta VALID
    sta T0
    rts
reflected_axis_step:
; BOUNCES = 0
    lda #0
    sta BOUNCES
; VALID = 0
    lda #0
    sta VALID
; if MINIMUM >= MAXIMUM:
    lda MINIMUM
    cmp MAXIMUM
    bcs reflected_axis_L4
reflected_axis_L5:
    jmp reflected_axis_L2
reflected_axis_L4:
    jmp reflected_axis_L1
reflected_axis_L1:
; return
    rts
    jmp reflected_axis_L3
reflected_axis_L2:
reflected_axis_L3:
; if POSITION < MINIMUM:
    lda POSITION
    cmp MINIMUM
    bcc reflected_axis_L9
reflected_axis_L10:
    jmp reflected_axis_L7
reflected_axis_L9:
    jmp reflected_axis_L6
reflected_axis_L6:
; return
    rts
    jmp reflected_axis_L8
reflected_axis_L7:
reflected_axis_L8:
; if POSITION > MAXIMUM:
    lda POSITION
    cmp MAXIMUM
    beq reflected_axis_L15
    bcs reflected_axis_L14
reflected_axis_L15:
    jmp reflected_axis_L12
reflected_axis_L14:
    jmp reflected_axis_L11
reflected_axis_L11:
; return
    rts
    jmp reflected_axis_L13
reflected_axis_L12:
reflected_axis_L13:
; if DIRECTION >= 2:
    lda DIRECTION
    cmp #2
    bcs reflected_axis_L19
reflected_axis_L20:
    jmp reflected_axis_L17
reflected_axis_L19:
    jmp reflected_axis_L16
reflected_axis_L16:
; return
    rts
    jmp reflected_axis_L18
reflected_axis_L17:
reflected_axis_L18:
; VALID = 1
    lda #1
    sta VALID
; T0 = DISTANCE
    lda DISTANCE
    sta T0
; while T0 != 0:
reflected_axis_L21:
    lda T0
    cmp #0
    bne reflected_axis_L24
reflected_axis_L25:
    jmp reflected_axis_L23
reflected_axis_L24:
    jmp reflected_axis_L22
reflected_axis_L22:
; if DIRECTION == 0:
    lda DIRECTION
    cmp #0
    beq reflected_axis_L29
reflected_axis_L30:
    jmp reflected_axis_L27
reflected_axis_L29:
    jmp reflected_axis_L26
reflected_axis_L26:
; if POSITION == MINIMUM:
    lda POSITION
    cmp MINIMUM
    beq reflected_axis_L34
reflected_axis_L35:
    jmp reflected_axis_L32
reflected_axis_L34:
    jmp reflected_axis_L31
reflected_axis_L31:
; DIRECTION = 1
    lda #1
    sta DIRECTION
; BOUNCES = BOUNCES + 1
    lda BOUNCES
    clc
    adc #1
    sta BOUNCES
    jmp reflected_axis_L33
reflected_axis_L32:
reflected_axis_L33:
    jmp reflected_axis_L28
reflected_axis_L27:
; if POSITION == MAXIMUM:
    lda POSITION
    cmp MAXIMUM
    beq reflected_axis_L39
reflected_axis_L40:
    jmp reflected_axis_L37
reflected_axis_L39:
    jmp reflected_axis_L36
reflected_axis_L36:
; DIRECTION = 0
    lda #0
    sta DIRECTION
; BOUNCES = BOUNCES + 1
    lda BOUNCES
    clc
    adc #1
    sta BOUNCES
    jmp reflected_axis_L38
reflected_axis_L37:
reflected_axis_L38:
reflected_axis_L28:
; if DIRECTION == 0:
    lda DIRECTION
    cmp #0
    beq reflected_axis_L44
reflected_axis_L45:
    jmp reflected_axis_L42
reflected_axis_L44:
    jmp reflected_axis_L41
reflected_axis_L41:
; POSITION = POSITION - 1
    lda POSITION
    sec
    sbc #1
    sta POSITION
    jmp reflected_axis_L43
reflected_axis_L42:
; POSITION = POSITION + 1
    lda POSITION
    clc
    adc #1
    sta POSITION
reflected_axis_L43:
; T0 = T0 - 1
    lda T0
    sec
    sbc #1
    sta T0
    jmp reflected_axis_L21
reflected_axis_L23:
    rts
component_end:
