; SPDX-License-Identifier: MIT
; Read Bits from a Bounded Data Block. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_bit_reader_init:
    move.b #0,d0
    move.b d0,VALUE
    move.b d0,VALID
    move.b d0,CURSOR
    move.b d0,COUNT
    move.b d0,B0
    move.b d0,B1
    move.b d0,B2
    move.b d0,B3
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    move.b d0,T4
    rts
bounded_bit_reader_step:
; VALUE = 0
    move.b #0,d0
    move.b d0,VALUE
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if CURSOR > 32:
    move.b CURSOR,d0
    cmp.b #32,d0
    bhi bounded_bit_reader_L1
    jmp bounded_bit_reader_L2
bounded_bit_reader_L1:
; return
    rts
    jmp bounded_bit_reader_L3
bounded_bit_reader_L2:
bounded_bit_reader_L3:
; if COUNT > 8:
    move.b COUNT,d0
    cmp.b #8,d0
    bhi bounded_bit_reader_L4
    jmp bounded_bit_reader_L5
bounded_bit_reader_L4:
; return
    rts
    jmp bounded_bit_reader_L6
bounded_bit_reader_L5:
bounded_bit_reader_L6:
; T0 = 32 - CURSOR
    move.b #32,d0
    move.b CURSOR,d1
    sub.b d1,d0
    move.b d0,T0
; if COUNT > T0:
    move.b COUNT,d0
    move.b T0,d1
    cmp.b d1,d0
    bhi bounded_bit_reader_L7
    jmp bounded_bit_reader_L8
bounded_bit_reader_L7:
; return
    rts
    jmp bounded_bit_reader_L9
bounded_bit_reader_L8:
bounded_bit_reader_L9:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = COUNT
    move.b COUNT,d0
    move.b d0,T0
; while T0 != 0:
bounded_bit_reader_L10:
    move.b T0,d0
    cmp.b #0,d0
    bne bounded_bit_reader_L11
    jmp bounded_bit_reader_L12
bounded_bit_reader_L11:
; T1 = CURSOR >> 3
    move.b CURSOR,d0
    lsr.b #3,d0
    move.b d0,T1
; T2 = CURSOR & 7
    move.b CURSOR,d0
    and.b #7,d0
    move.b d0,T2
; T3 = 128
    move.b #128,d0
    move.b d0,T3
; while T2 != 0:
bounded_bit_reader_L13:
    move.b T2,d0
    cmp.b #0,d0
    bne bounded_bit_reader_L14
    jmp bounded_bit_reader_L15
bounded_bit_reader_L14:
; T3 = T3 >> 1
    move.b T3,d0
    lsr.b #1,d0
    move.b d0,T3
; T2 = T2 - 1
    move.b T2,d0
    sub.b #1,d0
    move.b d0,T2
    jmp bounded_bit_reader_L13
bounded_bit_reader_L15:
; T4 = B[T1]
    moveq #0,d1
    move.b T1,d1
    lea B0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T4
; T4 = T4 & T3
    move.b T4,d0
    move.b T3,d1
    and.b d1,d0
    move.b d0,T4
; VALUE = VALUE << 1
    move.b VALUE,d0
    lsl.b #1,d0
    move.b d0,VALUE
; if T4 != 0:
    move.b T4,d0
    cmp.b #0,d0
    bne bounded_bit_reader_L16
    jmp bounded_bit_reader_L17
bounded_bit_reader_L16:
; VALUE = VALUE | 1
    move.b VALUE,d0
    or.b #1,d0
    move.b d0,VALUE
    jmp bounded_bit_reader_L18
bounded_bit_reader_L17:
bounded_bit_reader_L18:
; CURSOR = CURSOR + 1
    move.b CURSOR,d0
    add.b #1,d0
    move.b d0,CURSOR
; T0 = T0 - 1
    move.b T0,d0
    sub.b #1,d0
    move.b d0,T0
    jmp bounded_bit_reader_L10
bounded_bit_reader_L12:
    rts
component_end:
