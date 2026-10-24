; SPDX-License-Identifier: MIT
; Multiply Two Bytes into a Word. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
byte_product_init:
    ld a,0
    ld (PRODUCT_LO),a
    ld (PRODUCT_HI),a
    ld (LEFT),a
    ld (RIGHT),a
    ld (T0),a
    ld (T1),a
    ld (T4),a
    ld (T5),a
    ld (T6),a
    ld (T7),a
    ld (T8),a
    ld (T9),a
    ret
byte_product_step:
; T4 = LEFT
    ld a,(LEFT)
    ld (T4),a
; T5 = 0
    ld a,0
    ld (T5),a
; T1 = RIGHT
    ld a,(RIGHT)
    ld (T1),a
; T6 = 0
    ld a,0
    ld (T6),a
; T7 = 0
    ld a,0
    ld (T7),a
; T0 = 8
    ld a,8
    ld (T0),a
; while T0 != 0:
byte_product_L1:
    ld a,(T0)
    cp 0
    jp nz,byte_product_L2
    jp byte_product_L3
byte_product_L2:
; T9 = T1 & 1
    ld a,(T1)
    and 1
    ld (T9),a
; if T9 != 0:
    ld a,(T9)
    cp 0
    jp nz,byte_product_L4
    jp byte_product_L5
byte_product_L4:
; T8 = T6
    ld a,(T6)
    ld (T8),a
; T6 = T6 + T4
    ld a,(T6)
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    add a,c
    ld (T6),a
; T9 = 0
    ld a,0
    ld (T9),a
; if T6 < T8:
    ld a,(T6)
    ld b,a
    ld a,(T8)
    ld c,a
    ld a,b
    cp c
    jp c,byte_product_L7
    jp byte_product_L8
byte_product_L7:
; T9 = 1
    ld a,1
    ld (T9),a
    jp byte_product_L9
byte_product_L8:
byte_product_L9:
; T7 = T7 + T5
    ld a,(T7)
    ld b,a
    ld a,(T5)
    ld c,a
    ld a,b
    add a,c
    ld (T7),a
; T7 = T7 + T9
    ld a,(T7)
    ld b,a
    ld a,(T9)
    ld c,a
    ld a,b
    add a,c
    ld (T7),a
    jp byte_product_L6
byte_product_L5:
byte_product_L6:
; T9 = T4 >> 7
    ld a,(T4)
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    ld (T9),a
; T4 = T4 << 1
    ld a,(T4)
    sla a
    ld (T4),a
; T5 = T5 << 1
    ld a,(T5)
    sla a
    ld (T5),a
; T5 = T5 | T9
    ld a,(T5)
    ld b,a
    ld a,(T9)
    ld c,a
    ld a,b
    or c
    ld (T5),a
; T1 = T1 >> 1
    ld a,(T1)
    srl a
    ld (T1),a
; T0 = T0 - 1
    ld a,(T0)
    sub 1
    ld (T0),a
    jp byte_product_L1
byte_product_L3:
; PRODUCT_LO = T6
    ld a,(T6)
    ld (PRODUCT_LO),a
; PRODUCT_HI = T7
    ld a,(T7)
    ld (PRODUCT_HI),a
    ret
component_end:
