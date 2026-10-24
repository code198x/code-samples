; SPDX-License-Identifier: MIT
; Multiply Two Bytes into a Word. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
byte_product_init:
    lda #0
    sta PRODUCT_LO
    sta PRODUCT_HI
    sta LEFT
    sta RIGHT
    sta T0
    sta T1
    sta T4
    sta T5
    sta T6
    sta T7
    sta T8
    sta T9
    rts
byte_product_step:
; T4 = LEFT
    lda LEFT
    sta T4
; T5 = 0
    lda #0
    sta T5
; T1 = RIGHT
    lda RIGHT
    sta T1
; T6 = 0
    lda #0
    sta T6
; T7 = 0
    lda #0
    sta T7
; T0 = 8
    lda #8
    sta T0
; while T0 != 0:
byte_product_L1:
    lda T0
    cmp #0
    bne byte_product_L4
byte_product_L5:
    jmp byte_product_L3
byte_product_L4:
    jmp byte_product_L2
byte_product_L2:
; T9 = T1 & 1
    lda T1
    and #1
    sta T9
; if T9 != 0:
    lda T9
    cmp #0
    bne byte_product_L9
byte_product_L10:
    jmp byte_product_L7
byte_product_L9:
    jmp byte_product_L6
byte_product_L6:
; T8 = T6
    lda T6
    sta T8
; T6 = T6 + T4
    lda T6
    clc
    adc T4
    sta T6
; T9 = 0
    lda #0
    sta T9
; if T6 < T8:
    lda T6
    cmp T8
    bcc byte_product_L14
byte_product_L15:
    jmp byte_product_L12
byte_product_L14:
    jmp byte_product_L11
byte_product_L11:
; T9 = 1
    lda #1
    sta T9
    jmp byte_product_L13
byte_product_L12:
byte_product_L13:
; T7 = T7 + T5
    lda T7
    clc
    adc T5
    sta T7
; T7 = T7 + T9
    lda T7
    clc
    adc T9
    sta T7
    jmp byte_product_L8
byte_product_L7:
byte_product_L8:
; T9 = T4 >> 7
    lda T4
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    sta T9
; T4 = T4 << 1
    lda T4
    asl
    sta T4
; T5 = T5 << 1
    lda T5
    asl
    sta T5
; T5 = T5 | T9
    lda T5
    ora T9
    sta T5
; T1 = T1 >> 1
    lda T1
    lsr
    sta T1
; T0 = T0 - 1
    lda T0
    sec
    sbc #1
    sta T0
    jmp byte_product_L1
byte_product_L3:
; PRODUCT_LO = T6
    lda T6
    sta PRODUCT_LO
; PRODUCT_HI = T7
    lda T7
    sta PRODUCT_HI
    rts
component_end:
