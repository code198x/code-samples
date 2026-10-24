; SPDX-License-Identifier: MIT
; Test Two Small Opaque Pixel Masks. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
pixel_mask_collision_init:
    lda #0
    sta HIT
    sta ROW
    sta SHIFT_X
    sta SHIFT_Y
    sta P0
    sta P1
    sta P2
    sta P3
    sta P4
    sta P5
    sta P6
    sta P7
    sta Q0
    sta Q1
    sta Q2
    sta Q3
    sta Q4
    sta Q5
    sta Q6
    sta Q7
    sta T0
    sta T1
    sta T2
    sta T3
    sta T4
    sta T5
    rts
pixel_mask_collision_step:
; HIT = 0
    lda #0
    sta HIT
; ROW = 255
    lda #255
    sta ROW
; if SHIFT_X >= 8:
    lda SHIFT_X
    cmp #8
    bcs pixel_mask_collision_L4
pixel_mask_collision_L5:
    jmp pixel_mask_collision_L2
pixel_mask_collision_L4:
    jmp pixel_mask_collision_L1
pixel_mask_collision_L1:
; return
    rts
    jmp pixel_mask_collision_L3
pixel_mask_collision_L2:
pixel_mask_collision_L3:
; if SHIFT_Y >= 8:
    lda SHIFT_Y
    cmp #8
    bcs pixel_mask_collision_L9
pixel_mask_collision_L10:
    jmp pixel_mask_collision_L7
pixel_mask_collision_L9:
    jmp pixel_mask_collision_L6
pixel_mask_collision_L6:
; return
    rts
    jmp pixel_mask_collision_L8
pixel_mask_collision_L7:
pixel_mask_collision_L8:
; T0 = 0
    lda #0
    sta T0
; T5 = 8 - SHIFT_Y
    lda #8
    sec
    sbc SHIFT_Y
    sta T5
; while T0 < T5:
pixel_mask_collision_L11:
    lda T0
    cmp T5
    bcc pixel_mask_collision_L14
pixel_mask_collision_L15:
    jmp pixel_mask_collision_L13
pixel_mask_collision_L14:
    jmp pixel_mask_collision_L12
pixel_mask_collision_L12:
; T1 = Q[T0]
    ldx T0
    lda Q0,x
    sta T1
; T2 = SHIFT_X
    lda SHIFT_X
    sta T2
; while T2 != 0:
pixel_mask_collision_L16:
    lda T2
    cmp #0
    bne pixel_mask_collision_L19
pixel_mask_collision_L20:
    jmp pixel_mask_collision_L18
pixel_mask_collision_L19:
    jmp pixel_mask_collision_L17
pixel_mask_collision_L17:
; T1 = T1 >> 1
    lda T1
    lsr
    sta T1
; T2 = T2 - 1
    lda T2
    sec
    sbc #1
    sta T2
    jmp pixel_mask_collision_L16
pixel_mask_collision_L18:
; T3 = T0 + SHIFT_Y
    lda T0
    clc
    adc SHIFT_Y
    sta T3
; T4 = P[T3]
    ldx T3
    lda P0,x
    sta T4
; T4 = T4 & T1
    lda T4
    and T1
    sta T4
; if T4 != 0:
    lda T4
    cmp #0
    bne pixel_mask_collision_L24
pixel_mask_collision_L25:
    jmp pixel_mask_collision_L22
pixel_mask_collision_L24:
    jmp pixel_mask_collision_L21
pixel_mask_collision_L21:
; HIT = 1
    lda #1
    sta HIT
; ROW = T3
    lda T3
    sta ROW
; return
    rts
    jmp pixel_mask_collision_L23
pixel_mask_collision_L22:
pixel_mask_collision_L23:
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp pixel_mask_collision_L11
pixel_mask_collision_L13:
    rts
component_end:
