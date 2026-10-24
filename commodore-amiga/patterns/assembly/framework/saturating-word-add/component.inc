; SPDX-License-Identifier: MIT
; Add Words with Saturation. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
saturating_word_add_init:
    move.b #0,d0
    move.b d0,SUM_LO
    move.b d0,SUM_HI
    move.b d0,CLAMPED
    move.b d0,LEFT_LO
    move.b d0,LEFT_HI
    move.b d0,RIGHT_LO
    move.b d0,RIGHT_HI
    move.b d0,T0
    move.b d0,T1
    rts
saturating_word_add_step:
; SUM_LO = LEFT_LO + RIGHT_LO
    move.b LEFT_LO,d0
    move.b RIGHT_LO,d1
    add.b d1,d0
    move.b d0,SUM_LO
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; if SUM_LO < LEFT_LO:
    move.b SUM_LO,d0
    move.b LEFT_LO,d1
    cmp.b d1,d0
    bcs saturating_word_add_L1
    jmp saturating_word_add_L2
saturating_word_add_L1:
; T0 = 1
    move.b #1,d0
    move.b d0,T0
    jmp saturating_word_add_L3
saturating_word_add_L2:
saturating_word_add_L3:
; SUM_HI = LEFT_HI + RIGHT_HI
    move.b LEFT_HI,d0
    move.b RIGHT_HI,d1
    add.b d1,d0
    move.b d0,SUM_HI
; CLAMPED = 0
    move.b #0,d0
    move.b d0,CLAMPED
; if SUM_HI < LEFT_HI:
    move.b SUM_HI,d0
    move.b LEFT_HI,d1
    cmp.b d1,d0
    bcs saturating_word_add_L4
    jmp saturating_word_add_L5
saturating_word_add_L4:
; CLAMPED = 1
    move.b #1,d0
    move.b d0,CLAMPED
    jmp saturating_word_add_L6
saturating_word_add_L5:
saturating_word_add_L6:
; T1 = SUM_HI
    move.b SUM_HI,d0
    move.b d0,T1
; SUM_HI = SUM_HI + T0
    move.b SUM_HI,d0
    move.b T0,d1
    add.b d1,d0
    move.b d0,SUM_HI
; if SUM_HI < T1:
    move.b SUM_HI,d0
    move.b T1,d1
    cmp.b d1,d0
    bcs saturating_word_add_L7
    jmp saturating_word_add_L8
saturating_word_add_L7:
; CLAMPED = 1
    move.b #1,d0
    move.b d0,CLAMPED
    jmp saturating_word_add_L9
saturating_word_add_L8:
saturating_word_add_L9:
; if CLAMPED != 0:
    move.b CLAMPED,d0
    cmp.b #0,d0
    bne saturating_word_add_L10
    jmp saturating_word_add_L11
saturating_word_add_L10:
; SUM_LO = 255
    move.b #255,d0
    move.b d0,SUM_LO
; SUM_HI = 255
    move.b #255,d0
    move.b d0,SUM_HI
    jmp saturating_word_add_L12
saturating_word_add_L11:
saturating_word_add_L12:
    rts
component_end:
