; SPDX-License-Identifier: MIT
; Divide a Word by a Byte. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
word_division_init:
    move.b #0,d0
    move.b d0,QUOTIENT_LO
    move.b d0,QUOTIENT_HI
    move.b d0,REMAINDER
    move.b d0,VALID
    move.b d0,NUMERATOR_LO
    move.b d0,NUMERATOR_HI
    move.b d0,DIVISOR
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    rts
word_division_step:
; QUOTIENT_LO = 0
    move.b #0,d0
    move.b d0,QUOTIENT_LO
; QUOTIENT_HI = 0
    move.b #0,d0
    move.b d0,QUOTIENT_HI
; REMAINDER = 0
    move.b #0,d0
    move.b d0,REMAINDER
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if DIVISOR == 0:
    move.b DIVISOR,d0
    cmp.b #0,d0
    beq word_division_L1
    jmp word_division_L2
word_division_L1:
; return
    rts
    jmp word_division_L3
word_division_L2:
word_division_L3:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; QUOTIENT_LO = NUMERATOR_LO
    move.b NUMERATOR_LO,d0
    move.b d0,QUOTIENT_LO
; QUOTIENT_HI = NUMERATOR_HI
    move.b NUMERATOR_HI,d0
    move.b d0,QUOTIENT_HI
; T0 = 16
    move.b #16,d0
    move.b d0,T0
; while T0 != 0:
word_division_L4:
    move.b T0,d0
    cmp.b #0,d0
    bne word_division_L5
    jmp word_division_L6
word_division_L5:
; T1 = QUOTIENT_HI >> 7
    move.b QUOTIENT_HI,d0
    lsr.b #7,d0
    move.b d0,T1
; T2 = QUOTIENT_LO >> 7
    move.b QUOTIENT_LO,d0
    lsr.b #7,d0
    move.b d0,T2
; QUOTIENT_HI = QUOTIENT_HI << 1
    move.b QUOTIENT_HI,d0
    lsl.b #1,d0
    move.b d0,QUOTIENT_HI
; QUOTIENT_HI = QUOTIENT_HI | T2
    move.b QUOTIENT_HI,d0
    move.b T2,d1
    or.b d1,d0
    move.b d0,QUOTIENT_HI
; QUOTIENT_LO = QUOTIENT_LO << 1
    move.b QUOTIENT_LO,d0
    lsl.b #1,d0
    move.b d0,QUOTIENT_LO
; T2 = REMAINDER >> 7
    move.b REMAINDER,d0
    lsr.b #7,d0
    move.b d0,T2
; REMAINDER = REMAINDER << 1
    move.b REMAINDER,d0
    lsl.b #1,d0
    move.b d0,REMAINDER
; REMAINDER = REMAINDER | T1
    move.b REMAINDER,d0
    move.b T1,d1
    or.b d1,d0
    move.b d0,REMAINDER
; if T2 != 0:
    move.b T2,d0
    cmp.b #0,d0
    bne word_division_L7
    jmp word_division_L8
word_division_L7:
; REMAINDER = REMAINDER - DIVISOR
    move.b REMAINDER,d0
    move.b DIVISOR,d1
    sub.b d1,d0
    move.b d0,REMAINDER
; QUOTIENT_LO = QUOTIENT_LO | 1
    move.b QUOTIENT_LO,d0
    or.b #1,d0
    move.b d0,QUOTIENT_LO
    jmp word_division_L9
word_division_L8:
; if REMAINDER >= DIVISOR:
    move.b REMAINDER,d0
    move.b DIVISOR,d1
    cmp.b d1,d0
    bcc word_division_L10
    jmp word_division_L11
word_division_L10:
; REMAINDER = REMAINDER - DIVISOR
    move.b REMAINDER,d0
    move.b DIVISOR,d1
    sub.b d1,d0
    move.b d0,REMAINDER
; QUOTIENT_LO = QUOTIENT_LO | 1
    move.b QUOTIENT_LO,d0
    or.b #1,d0
    move.b d0,QUOTIENT_LO
    jmp word_division_L12
word_division_L11:
word_division_L12:
word_division_L9:
; T0 = T0 - 1
    move.b T0,d0
    sub.b #1,d0
    move.b d0,T0
    jmp word_division_L4
word_division_L6:
    rts
component_end:
