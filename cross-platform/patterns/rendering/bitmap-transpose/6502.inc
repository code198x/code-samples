; SPDX-License-Identifier: MIT
; Transpose an Eight-by-eight Bitmap. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bitmap_transpose_init:
    lda #0
    sta R0
    sta R1
    sta R2
    sta R3
    sta R4
    sta R5
    sta R6
    sta R7
    sta C0
    sta C1
    sta C2
    sta C3
    sta C4
    sta C5
    sta C6
    sta C7
    sta T0
    sta T1
    sta T2
    sta T3
    sta T4
    sta EXPR_SAVE
    rts
bitmap_transpose_step:
; T0 = 0
    lda #0
    sta T0
; while T0 < 8:
bitmap_transpose_L1:
    lda T0
    cmp #8
    bcc bitmap_transpose_L4
bitmap_transpose_L5:
    jmp bitmap_transpose_L3
bitmap_transpose_L4:
    jmp bitmap_transpose_L2
bitmap_transpose_L2:
; R[T0] = 0
    lda #0
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta R0,x
; T1 = 0
    lda #0
    sta T1
; T2 = 128
    lda #128
    sta T2
; while T1 < 8:
bitmap_transpose_L6:
    lda T1
    cmp #8
    bcc bitmap_transpose_L9
bitmap_transpose_L10:
    jmp bitmap_transpose_L8
bitmap_transpose_L9:
    jmp bitmap_transpose_L7
bitmap_transpose_L7:
; T3 = C[T1]
    ldx T1
    lda C0,x
    sta T3
; T4 = T0
    lda T0
    sta T4
; while T4 != 0:
bitmap_transpose_L11:
    lda T4
    cmp #0
    bne bitmap_transpose_L14
bitmap_transpose_L15:
    jmp bitmap_transpose_L13
bitmap_transpose_L14:
    jmp bitmap_transpose_L12
bitmap_transpose_L12:
; T3 = T3 << 1
    lda T3
    asl
    sta T3
; T4 = T4 - 1
    lda T4
    sec
    sbc #1
    sta T4
    jmp bitmap_transpose_L11
bitmap_transpose_L13:
; T3 = T3 & 128
    lda T3
    and #128
    sta T3
; if T3 != 0:
    lda T3
    cmp #0
    bne bitmap_transpose_L19
bitmap_transpose_L20:
    jmp bitmap_transpose_L17
bitmap_transpose_L19:
    jmp bitmap_transpose_L16
bitmap_transpose_L16:
; T3 = R[T0]
    ldx T0
    lda R0,x
    sta T3
; T3 = T3 | T2
    lda T3
    ora T2
    sta T3
; R[T0] = T3
    lda T3
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta R0,x
    jmp bitmap_transpose_L18
bitmap_transpose_L17:
bitmap_transpose_L18:
; T2 = T2 >> 1
    lda T2
    lsr
    sta T2
; T1 = T1 + 1
    lda T1
    clc
    adc #1
    sta T1
    jmp bitmap_transpose_L6
bitmap_transpose_L8:
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp bitmap_transpose_L1
bitmap_transpose_L3:
    rts
component_end:
