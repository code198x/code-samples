; SPDX-License-Identifier: MIT
; Divide a Word by a Byte. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
word_division_init:
    ld a,0
    ld (QUOTIENT_LO),a
    ld (QUOTIENT_HI),a
    ld (REMAINDER),a
    ld (VALID),a
    ld (NUMERATOR_LO),a
    ld (NUMERATOR_HI),a
    ld (DIVISOR),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ret
word_division_step:
; QUOTIENT_LO = 0
    ld a,0
    ld (QUOTIENT_LO),a
; QUOTIENT_HI = 0
    ld a,0
    ld (QUOTIENT_HI),a
; REMAINDER = 0
    ld a,0
    ld (REMAINDER),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if DIVISOR == 0:
    ld a,(DIVISOR)
    cp 0
    jp z,word_division_L1
    jp word_division_L2
word_division_L1:
; return
    ret
    jp word_division_L3
word_division_L2:
word_division_L3:
; VALID = 1
    ld a,1
    ld (VALID),a
; QUOTIENT_LO = NUMERATOR_LO
    ld a,(NUMERATOR_LO)
    ld (QUOTIENT_LO),a
; QUOTIENT_HI = NUMERATOR_HI
    ld a,(NUMERATOR_HI)
    ld (QUOTIENT_HI),a
; T0 = 16
    ld a,16
    ld (T0),a
; while T0 != 0:
word_division_L4:
    ld a,(T0)
    cp 0
    jp nz,word_division_L5
    jp word_division_L6
word_division_L5:
; T1 = QUOTIENT_HI >> 7
    ld a,(QUOTIENT_HI)
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    ld (T1),a
; T2 = QUOTIENT_LO >> 7
    ld a,(QUOTIENT_LO)
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    ld (T2),a
; QUOTIENT_HI = QUOTIENT_HI << 1
    ld a,(QUOTIENT_HI)
    sla a
    ld (QUOTIENT_HI),a
; QUOTIENT_HI = QUOTIENT_HI | T2
    ld a,(QUOTIENT_HI)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    or c
    ld (QUOTIENT_HI),a
; QUOTIENT_LO = QUOTIENT_LO << 1
    ld a,(QUOTIENT_LO)
    sla a
    ld (QUOTIENT_LO),a
; T2 = REMAINDER >> 7
    ld a,(REMAINDER)
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    ld (T2),a
; REMAINDER = REMAINDER << 1
    ld a,(REMAINDER)
    sla a
    ld (REMAINDER),a
; REMAINDER = REMAINDER | T1
    ld a,(REMAINDER)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    or c
    ld (REMAINDER),a
; if T2 != 0:
    ld a,(T2)
    cp 0
    jp nz,word_division_L7
    jp word_division_L8
word_division_L7:
; REMAINDER = REMAINDER - DIVISOR
    ld a,(REMAINDER)
    ld b,a
    ld a,(DIVISOR)
    ld c,a
    ld a,b
    sub c
    ld (REMAINDER),a
; QUOTIENT_LO = QUOTIENT_LO | 1
    ld a,(QUOTIENT_LO)
    or 1
    ld (QUOTIENT_LO),a
    jp word_division_L9
word_division_L8:
; if REMAINDER >= DIVISOR:
    ld a,(REMAINDER)
    ld b,a
    ld a,(DIVISOR)
    ld c,a
    ld a,b
    cp c
    jp nc,word_division_L10
    jp word_division_L11
word_division_L10:
; REMAINDER = REMAINDER - DIVISOR
    ld a,(REMAINDER)
    ld b,a
    ld a,(DIVISOR)
    ld c,a
    ld a,b
    sub c
    ld (REMAINDER),a
; QUOTIENT_LO = QUOTIENT_LO | 1
    ld a,(QUOTIENT_LO)
    or 1
    ld (QUOTIENT_LO),a
    jp word_division_L12
word_division_L11:
word_division_L12:
word_division_L9:
; T0 = T0 - 1
    ld a,(T0)
    sub 1
    ld (T0),a
    jp word_division_L4
word_division_L6:
    ret
component_end:
