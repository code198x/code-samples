; SPDX-License-Identifier: MIT
; Multiply Two Bytes into a Word. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
byte_product_init:
    move.b #0,d0
    move.b d0,PRODUCT_LO
    move.b d0,PRODUCT_HI
    move.b d0,LEFT
    move.b d0,RIGHT
    move.b d0,T0
    move.b d0,T1
    move.b d0,T4
    move.b d0,T5
    move.b d0,T6
    move.b d0,T7
    move.b d0,T8
    move.b d0,T9
    rts
byte_product_step:
; T4 = LEFT
    move.b LEFT,d0
    move.b d0,T4
; T5 = 0
    move.b #0,d0
    move.b d0,T5
; T1 = RIGHT
    move.b RIGHT,d0
    move.b d0,T1
; T6 = 0
    move.b #0,d0
    move.b d0,T6
; T7 = 0
    move.b #0,d0
    move.b d0,T7
; T0 = 8
    move.b #8,d0
    move.b d0,T0
; while T0 != 0:
byte_product_L1:
    move.b T0,d0
    cmp.b #0,d0
    bne byte_product_L2
    jmp byte_product_L3
byte_product_L2:
; T9 = T1 & 1
    move.b T1,d0
    and.b #1,d0
    move.b d0,T9
; if T9 != 0:
    move.b T9,d0
    cmp.b #0,d0
    bne byte_product_L4
    jmp byte_product_L5
byte_product_L4:
; T8 = T6
    move.b T6,d0
    move.b d0,T8
; T6 = T6 + T4
    move.b T6,d0
    move.b T4,d1
    add.b d1,d0
    move.b d0,T6
; T9 = 0
    move.b #0,d0
    move.b d0,T9
; if T6 < T8:
    move.b T6,d0
    move.b T8,d1
    cmp.b d1,d0
    bcs byte_product_L7
    jmp byte_product_L8
byte_product_L7:
; T9 = 1
    move.b #1,d0
    move.b d0,T9
    jmp byte_product_L9
byte_product_L8:
byte_product_L9:
; T7 = T7 + T5
    move.b T7,d0
    move.b T5,d1
    add.b d1,d0
    move.b d0,T7
; T7 = T7 + T9
    move.b T7,d0
    move.b T9,d1
    add.b d1,d0
    move.b d0,T7
    jmp byte_product_L6
byte_product_L5:
byte_product_L6:
; T9 = T4 >> 7
    move.b T4,d0
    lsr.b #7,d0
    move.b d0,T9
; T4 = T4 << 1
    move.b T4,d0
    lsl.b #1,d0
    move.b d0,T4
; T5 = T5 << 1
    move.b T5,d0
    lsl.b #1,d0
    move.b d0,T5
; T5 = T5 | T9
    move.b T5,d0
    move.b T9,d1
    or.b d1,d0
    move.b d0,T5
; T1 = T1 >> 1
    move.b T1,d0
    lsr.b #1,d0
    move.b d0,T1
; T0 = T0 - 1
    move.b T0,d0
    sub.b #1,d0
    move.b d0,T0
    jmp byte_product_L1
byte_product_L3:
; PRODUCT_LO = T6
    move.b T6,d0
    move.b d0,PRODUCT_LO
; PRODUCT_HI = T7
    move.b T7,d0
    move.b d0,PRODUCT_HI
    rts
component_end:
