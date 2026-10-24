; SPDX-License-Identifier: MIT
; Transpose an Eight-by-eight Bitmap. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bitmap_transpose_init:
    move.b #0,d0
    move.b d0,R0
    move.b d0,R1
    move.b d0,R2
    move.b d0,R3
    move.b d0,R4
    move.b d0,R5
    move.b d0,R6
    move.b d0,R7
    move.b d0,C0
    move.b d0,C1
    move.b d0,C2
    move.b d0,C3
    move.b d0,C4
    move.b d0,C5
    move.b d0,C6
    move.b d0,C7
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    move.b d0,T4
    move.b d0,EXPR_SAVE
    rts
bitmap_transpose_step:
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; while T0 < 8:
bitmap_transpose_L1:
    move.b T0,d0
    cmp.b #8,d0
    bcs bitmap_transpose_L2
    jmp bitmap_transpose_L3
bitmap_transpose_L2:
; R[T0] = 0
    move.b #0,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea R0,a0
    move.b d2,0(a0,d1.w)
; T1 = 0
    move.b #0,d0
    move.b d0,T1
; T2 = 128
    move.b #128,d0
    move.b d0,T2
; while T1 < 8:
bitmap_transpose_L4:
    move.b T1,d0
    cmp.b #8,d0
    bcs bitmap_transpose_L5
    jmp bitmap_transpose_L6
bitmap_transpose_L5:
; T3 = C[T1]
    moveq #0,d1
    move.b T1,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; T4 = T0
    move.b T0,d0
    move.b d0,T4
; while T4 != 0:
bitmap_transpose_L7:
    move.b T4,d0
    cmp.b #0,d0
    bne bitmap_transpose_L8
    jmp bitmap_transpose_L9
bitmap_transpose_L8:
; T3 = T3 << 1
    move.b T3,d0
    lsl.b #1,d0
    move.b d0,T3
; T4 = T4 - 1
    move.b T4,d0
    sub.b #1,d0
    move.b d0,T4
    jmp bitmap_transpose_L7
bitmap_transpose_L9:
; T3 = T3 & 128
    move.b T3,d0
    and.b #128,d0
    move.b d0,T3
; if T3 != 0:
    move.b T3,d0
    cmp.b #0,d0
    bne bitmap_transpose_L10
    jmp bitmap_transpose_L11
bitmap_transpose_L10:
; T3 = R[T0]
    moveq #0,d1
    move.b T0,d1
    lea R0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; T3 = T3 | T2
    move.b T3,d0
    move.b T2,d1
    or.b d1,d0
    move.b d0,T3
; R[T0] = T3
    move.b T3,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea R0,a0
    move.b d2,0(a0,d1.w)
    jmp bitmap_transpose_L12
bitmap_transpose_L11:
bitmap_transpose_L12:
; T2 = T2 >> 1
    move.b T2,d0
    lsr.b #1,d0
    move.b d0,T2
; T1 = T1 + 1
    move.b T1,d0
    add.b #1,d0
    move.b d0,T1
    jmp bitmap_transpose_L4
bitmap_transpose_L6:
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp bitmap_transpose_L1
bitmap_transpose_L3:
    rts
component_end:
