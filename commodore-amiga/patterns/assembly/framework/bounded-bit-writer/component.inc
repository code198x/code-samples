; SPDX-License-Identifier: MIT
; Write Packed Bits with Bounds. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_bit_writer_init:
    move.b #0,d0
    move.b d0,VALID
    move.b d0,CURSOR
    move.b d0,COUNT
    move.b d0,VALUE
    move.b d0,B0
    move.b d0,B1
    move.b d0,B2
    move.b d0,B3
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    move.b d0,T4
    move.b d0,T5
    move.b d0,T6
    move.b d0,EXPR_SAVE
    rts
bounded_bit_writer_step:
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if COUNT > 8:
    move.b COUNT,d0
    cmp.b #8,d0
    bhi bounded_bit_writer_L1
    jmp bounded_bit_writer_L2
bounded_bit_writer_L1:
; return
    rts
    jmp bounded_bit_writer_L3
bounded_bit_writer_L2:
bounded_bit_writer_L3:
; if CURSOR > 32:
    move.b CURSOR,d0
    cmp.b #32,d0
    bhi bounded_bit_writer_L4
    jmp bounded_bit_writer_L5
bounded_bit_writer_L4:
; return
    rts
    jmp bounded_bit_writer_L6
bounded_bit_writer_L5:
bounded_bit_writer_L6:
; T0 = CURSOR + COUNT
    move.b CURSOR,d0
    move.b COUNT,d1
    add.b d1,d0
    move.b d0,T0
; if T0 > 32:
    move.b T0,d0
    cmp.b #32,d0
    bhi bounded_bit_writer_L7
    jmp bounded_bit_writer_L8
bounded_bit_writer_L7:
; return
    rts
    jmp bounded_bit_writer_L9
bounded_bit_writer_L8:
bounded_bit_writer_L9:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = COUNT
    move.b COUNT,d0
    move.b d0,T0
; while T0 != 0:
bounded_bit_writer_L10:
    move.b T0,d0
    cmp.b #0,d0
    bne bounded_bit_writer_L11
    jmp bounded_bit_writer_L12
bounded_bit_writer_L11:
; T0 = T0 - 1
    move.b T0,d0
    sub.b #1,d0
    move.b d0,T0
; T1 = VALUE
    move.b VALUE,d0
    move.b d0,T1
; T2 = T0
    move.b T0,d0
    move.b d0,T2
; while T2 != 0:
bounded_bit_writer_L13:
    move.b T2,d0
    cmp.b #0,d0
    bne bounded_bit_writer_L14
    jmp bounded_bit_writer_L15
bounded_bit_writer_L14:
; T1 = T1 >> 1
    move.b T1,d0
    lsr.b #1,d0
    move.b d0,T1
; T2 = T2 - 1
    move.b T2,d0
    sub.b #1,d0
    move.b d0,T2
    jmp bounded_bit_writer_L13
bounded_bit_writer_L15:
; T1 = T1 & 1
    move.b T1,d0
    and.b #1,d0
    move.b d0,T1
; T2 = CURSOR >> 3
    move.b CURSOR,d0
    lsr.b #3,d0
    move.b d0,T2
; T3 = CURSOR & 7
    move.b CURSOR,d0
    and.b #7,d0
    move.b d0,T3
; T4 = 128
    move.b #128,d0
    move.b d0,T4
; while T3 != 0:
bounded_bit_writer_L16:
    move.b T3,d0
    cmp.b #0,d0
    bne bounded_bit_writer_L17
    jmp bounded_bit_writer_L18
bounded_bit_writer_L17:
; T4 = T4 >> 1
    move.b T4,d0
    lsr.b #1,d0
    move.b d0,T4
; T3 = T3 - 1
    move.b T3,d0
    sub.b #1,d0
    move.b d0,T3
    jmp bounded_bit_writer_L16
bounded_bit_writer_L18:
; T5 = T4 ^ 255
    move.b T4,d0
    eor.b #255,d0
    move.b d0,T5
; T6 = B[T2]
    moveq #0,d1
    move.b T2,d1
    lea B0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T6
; T6 = T6 & T5
    move.b T6,d0
    move.b T5,d1
    and.b d1,d0
    move.b d0,T6
; if T1 != 0:
    move.b T1,d0
    cmp.b #0,d0
    bne bounded_bit_writer_L19
    jmp bounded_bit_writer_L20
bounded_bit_writer_L19:
; T6 = T6 | T4
    move.b T6,d0
    move.b T4,d1
    or.b d1,d0
    move.b d0,T6
    jmp bounded_bit_writer_L21
bounded_bit_writer_L20:
bounded_bit_writer_L21:
; B[T2] = T6
    move.b T6,d0
    move.b d0,d2
    moveq #0,d1
    move.b T2,d1
    lea B0,a0
    move.b d2,0(a0,d1.w)
; CURSOR = CURSOR + 1
    move.b CURSOR,d0
    add.b #1,d0
    move.b d0,CURSOR
    jmp bounded_bit_writer_L10
bounded_bit_writer_L12:
    rts
component_end:
