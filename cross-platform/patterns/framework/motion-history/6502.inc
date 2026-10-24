; SPDX-License-Identifier: MIT
; Keep a Small Position History. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
motion_history_init:
    lda #0
    sta OUT_X
    sta OUT_Y
    sta VALID
    sta HEAD
    sta COUNT
    sta INPUT_X
    sta INPUT_Y
    sta LAG
    sta PUSH
    sta HX0
    sta HX1
    sta HX2
    sta HX3
    sta HX4
    sta HX5
    sta HX6
    sta HX7
    sta HY0
    sta HY1
    sta HY2
    sta HY3
    sta HY4
    sta HY5
    sta HY6
    sta HY7
    sta T0
    sta EXPR_SAVE
    rts
motion_history_step:
; OUT_X = 0
    lda #0
    sta OUT_X
; OUT_Y = 0
    lda #0
    sta OUT_Y
; VALID = 0
    lda #0
    sta VALID
; if HEAD >= 8:
    lda HEAD
    cmp #8
    bcs motion_history_L4
motion_history_L5:
    jmp motion_history_L2
motion_history_L4:
    jmp motion_history_L1
motion_history_L1:
; return
    rts
    jmp motion_history_L3
motion_history_L2:
motion_history_L3:
; if COUNT > 8:
    lda COUNT
    cmp #8
    beq motion_history_L10
    bcs motion_history_L9
motion_history_L10:
    jmp motion_history_L7
motion_history_L9:
    jmp motion_history_L6
motion_history_L6:
; return
    rts
    jmp motion_history_L8
motion_history_L7:
motion_history_L8:
; if PUSH != 0:
    lda PUSH
    cmp #0
    bne motion_history_L14
motion_history_L15:
    jmp motion_history_L12
motion_history_L14:
    jmp motion_history_L11
motion_history_L11:
; HX[HEAD] = INPUT_X
    lda INPUT_X
    sta EXPR_SAVE
    ldx HEAD
    lda EXPR_SAVE
    sta HX0,x
; HY[HEAD] = INPUT_Y
    lda INPUT_Y
    sta EXPR_SAVE
    ldx HEAD
    lda EXPR_SAVE
    sta HY0,x
; HEAD = HEAD + 1
    lda HEAD
    clc
    adc #1
    sta HEAD
; HEAD = HEAD & 7
    lda HEAD
    and #7
    sta HEAD
; if COUNT < 8:
    lda COUNT
    cmp #8
    bcc motion_history_L19
motion_history_L20:
    jmp motion_history_L17
motion_history_L19:
    jmp motion_history_L16
motion_history_L16:
; COUNT = COUNT + 1
    lda COUNT
    clc
    adc #1
    sta COUNT
    jmp motion_history_L18
motion_history_L17:
motion_history_L18:
    jmp motion_history_L13
motion_history_L12:
motion_history_L13:
; if LAG >= COUNT:
    lda LAG
    cmp COUNT
    bcs motion_history_L24
motion_history_L25:
    jmp motion_history_L22
motion_history_L24:
    jmp motion_history_L21
motion_history_L21:
; return
    rts
    jmp motion_history_L23
motion_history_L22:
motion_history_L23:
; T0 = HEAD - 1
    lda HEAD
    sec
    sbc #1
    sta T0
; T0 = T0 - LAG
    lda T0
    sec
    sbc LAG
    sta T0
; T0 = T0 & 7
    lda T0
    and #7
    sta T0
; OUT_X = HX[T0]
    ldx T0
    lda HX0,x
    sta OUT_X
; OUT_Y = HY[T0]
    ldx T0
    lda HY0,x
    sta OUT_Y
; VALID = 1
    lda #1
    sta VALID
    rts
component_end:
