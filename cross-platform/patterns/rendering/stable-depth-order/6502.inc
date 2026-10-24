; SPDX-License-Identifier: MIT
; Sort a Small Draw Order Stably. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
stable_depth_order_init:
    lda #0
    sta COUNT
    sta VALID
    sta Z0
    sta Z1
    sta Z2
    sta Z3
    sta Z4
    sta Z5
    sta Z6
    sta Z7
    sta I0
    sta I1
    sta I2
    sta I3
    sta I4
    sta I5
    sta I6
    sta I7
    sta T0
    sta T1
    sta T2
    sta T3
    sta T4
    sta T5
    sta T6
    sta EXPR_SAVE
    rts
stable_depth_order_step:
; VALID = 0
    lda #0
    sta VALID
; if COUNT > 8:
    lda COUNT
    cmp #8
    beq stable_depth_order_L5
    bcs stable_depth_order_L4
stable_depth_order_L5:
    jmp stable_depth_order_L2
stable_depth_order_L4:
    jmp stable_depth_order_L1
stable_depth_order_L1:
; return
    rts
    jmp stable_depth_order_L3
stable_depth_order_L2:
stable_depth_order_L3:
; T0 = 0
    lda #0
    sta T0
; while T0 < 8:
stable_depth_order_L6:
    lda T0
    cmp #8
    bcc stable_depth_order_L9
stable_depth_order_L10:
    jmp stable_depth_order_L8
stable_depth_order_L9:
    jmp stable_depth_order_L7
stable_depth_order_L7:
; I[T0] = T0
    lda T0
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta I0,x
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp stable_depth_order_L6
stable_depth_order_L8:
; T0 = 1
    lda #1
    sta T0
; while T0 < COUNT:
stable_depth_order_L11:
    lda T0
    cmp COUNT
    bcc stable_depth_order_L14
stable_depth_order_L15:
    jmp stable_depth_order_L13
stable_depth_order_L14:
    jmp stable_depth_order_L12
stable_depth_order_L12:
; T1 = I[T0]
    ldx T0
    lda I0,x
    sta T1
; T2 = Z[T1]
    ldx T1
    lda Z0,x
    sta T2
; T3 = T0
    lda T0
    sta T3
; while T3 != 0:
stable_depth_order_L16:
    lda T3
    cmp #0
    bne stable_depth_order_L19
stable_depth_order_L20:
    jmp stable_depth_order_L18
stable_depth_order_L19:
    jmp stable_depth_order_L17
stable_depth_order_L17:
; T4 = T3 - 1
    lda T3
    sec
    sbc #1
    sta T4
; T5 = I[T4]
    ldx T4
    lda I0,x
    sta T5
; T6 = Z[T5]
    ldx T5
    lda Z0,x
    sta T6
; if T6 <= T2:
    lda T6
    cmp T2
    bcc stable_depth_order_L24
    beq stable_depth_order_L24
stable_depth_order_L25:
    jmp stable_depth_order_L22
stable_depth_order_L24:
    jmp stable_depth_order_L21
stable_depth_order_L21:
; break
    jmp stable_depth_order_L18
    jmp stable_depth_order_L23
stable_depth_order_L22:
stable_depth_order_L23:
; I[T3] = T5
    lda T5
    sta EXPR_SAVE
    ldx T3
    lda EXPR_SAVE
    sta I0,x
; T3 = T3 - 1
    lda T3
    sec
    sbc #1
    sta T3
    jmp stable_depth_order_L16
stable_depth_order_L18:
; I[T3] = T1
    lda T1
    sta EXPR_SAVE
    ldx T3
    lda EXPR_SAVE
    sta I0,x
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp stable_depth_order_L11
stable_depth_order_L13:
; VALID = 1
    lda #1
    sta VALID
    rts
component_end:
