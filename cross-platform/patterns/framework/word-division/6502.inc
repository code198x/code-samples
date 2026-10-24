; SPDX-License-Identifier: MIT
; Divide a Word by a Byte. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
word_division_init:
    lda #0
    sta QUOTIENT_LO
    sta QUOTIENT_HI
    sta REMAINDER
    sta VALID
    sta NUMERATOR_LO
    sta NUMERATOR_HI
    sta DIVISOR
    sta T0
    sta T1
    sta T2
    rts
word_division_step:
; QUOTIENT_LO = 0
    lda #0
    sta QUOTIENT_LO
; QUOTIENT_HI = 0
    lda #0
    sta QUOTIENT_HI
; REMAINDER = 0
    lda #0
    sta REMAINDER
; VALID = 0
    lda #0
    sta VALID
; if DIVISOR == 0:
    lda DIVISOR
    cmp #0
    beq word_division_L4
word_division_L5:
    jmp word_division_L2
word_division_L4:
    jmp word_division_L1
word_division_L1:
; return
    rts
    jmp word_division_L3
word_division_L2:
word_division_L3:
; VALID = 1
    lda #1
    sta VALID
; QUOTIENT_LO = NUMERATOR_LO
    lda NUMERATOR_LO
    sta QUOTIENT_LO
; QUOTIENT_HI = NUMERATOR_HI
    lda NUMERATOR_HI
    sta QUOTIENT_HI
; T0 = 16
    lda #16
    sta T0
; while T0 != 0:
word_division_L6:
    lda T0
    cmp #0
    bne word_division_L9
word_division_L10:
    jmp word_division_L8
word_division_L9:
    jmp word_division_L7
word_division_L7:
; T1 = QUOTIENT_HI >> 7
    lda QUOTIENT_HI
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    sta T1
; T2 = QUOTIENT_LO >> 7
    lda QUOTIENT_LO
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    sta T2
; QUOTIENT_HI = QUOTIENT_HI << 1
    lda QUOTIENT_HI
    asl
    sta QUOTIENT_HI
; QUOTIENT_HI = QUOTIENT_HI | T2
    lda QUOTIENT_HI
    ora T2
    sta QUOTIENT_HI
; QUOTIENT_LO = QUOTIENT_LO << 1
    lda QUOTIENT_LO
    asl
    sta QUOTIENT_LO
; T2 = REMAINDER >> 7
    lda REMAINDER
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    sta T2
; REMAINDER = REMAINDER << 1
    lda REMAINDER
    asl
    sta REMAINDER
; REMAINDER = REMAINDER | T1
    lda REMAINDER
    ora T1
    sta REMAINDER
; if T2 != 0:
    lda T2
    cmp #0
    bne word_division_L14
word_division_L15:
    jmp word_division_L12
word_division_L14:
    jmp word_division_L11
word_division_L11:
; REMAINDER = REMAINDER - DIVISOR
    lda REMAINDER
    sec
    sbc DIVISOR
    sta REMAINDER
; QUOTIENT_LO = QUOTIENT_LO | 1
    lda QUOTIENT_LO
    ora #1
    sta QUOTIENT_LO
    jmp word_division_L13
word_division_L12:
; if REMAINDER >= DIVISOR:
    lda REMAINDER
    cmp DIVISOR
    bcs word_division_L19
word_division_L20:
    jmp word_division_L17
word_division_L19:
    jmp word_division_L16
word_division_L16:
; REMAINDER = REMAINDER - DIVISOR
    lda REMAINDER
    sec
    sbc DIVISOR
    sta REMAINDER
; QUOTIENT_LO = QUOTIENT_LO | 1
    lda QUOTIENT_LO
    ora #1
    sta QUOTIENT_LO
    jmp word_division_L18
word_division_L17:
word_division_L18:
word_division_L13:
; T0 = T0 - 1
    lda T0
    sec
    sbc #1
    sta T0
    jmp word_division_L6
word_division_L8:
    rts
component_end:
