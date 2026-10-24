; SPDX-License-Identifier: MIT
; Transpose an Eight-by-eight Bitmap. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bitmap_transpose_init:
    ld a,0
    ld (R0),a
    ld (R1),a
    ld (R2),a
    ld (R3),a
    ld (R4),a
    ld (R5),a
    ld (R6),a
    ld (R7),a
    ld (C0),a
    ld (C1),a
    ld (C2),a
    ld (C3),a
    ld (C4),a
    ld (C5),a
    ld (C6),a
    ld (C7),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ld (T4),a
    ld (EXPR_SAVE),a
    ret
bitmap_transpose_step:
; T0 = 0
    ld a,0
    ld (T0),a
; while T0 < 8:
bitmap_transpose_L1:
    ld a,(T0)
    cp 8
    jp c,bitmap_transpose_L2
    jp bitmap_transpose_L3
bitmap_transpose_L2:
; R[T0] = 0
    ld a,0
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,R0
    add hl,de
    ld (hl),c
; T1 = 0
    ld a,0
    ld (T1),a
; T2 = 128
    ld a,128
    ld (T2),a
; while T1 < 8:
bitmap_transpose_L4:
    ld a,(T1)
    cp 8
    jp c,bitmap_transpose_L5
    jp bitmap_transpose_L6
bitmap_transpose_L5:
; T3 = C[T1]
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T3),a
; T4 = T0
    ld a,(T0)
    ld (T4),a
; while T4 != 0:
bitmap_transpose_L7:
    ld a,(T4)
    cp 0
    jp nz,bitmap_transpose_L8
    jp bitmap_transpose_L9
bitmap_transpose_L8:
; T3 = T3 << 1
    ld a,(T3)
    sla a
    ld (T3),a
; T4 = T4 - 1
    ld a,(T4)
    sub 1
    ld (T4),a
    jp bitmap_transpose_L7
bitmap_transpose_L9:
; T3 = T3 & 128
    ld a,(T3)
    and 128
    ld (T3),a
; if T3 != 0:
    ld a,(T3)
    cp 0
    jp nz,bitmap_transpose_L10
    jp bitmap_transpose_L11
bitmap_transpose_L10:
; T3 = R[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,R0
    add hl,de
    ld a,(hl)
    ld (T3),a
; T3 = T3 | T2
    ld a,(T3)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    or c
    ld (T3),a
; R[T0] = T3
    ld a,(T3)
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,R0
    add hl,de
    ld (hl),c
    jp bitmap_transpose_L12
bitmap_transpose_L11:
bitmap_transpose_L12:
; T2 = T2 >> 1
    ld a,(T2)
    srl a
    ld (T2),a
; T1 = T1 + 1
    ld a,(T1)
    add a,1
    ld (T1),a
    jp bitmap_transpose_L4
bitmap_transpose_L6:
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp bitmap_transpose_L1
bitmap_transpose_L3:
    ret
component_end:
