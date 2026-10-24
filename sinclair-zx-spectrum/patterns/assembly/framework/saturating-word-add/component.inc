; SPDX-License-Identifier: MIT
; Add Words with Saturation. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
saturating_word_add_init:
    ld a,0
    ld (SUM_LO),a
    ld (SUM_HI),a
    ld (CLAMPED),a
    ld (LEFT_LO),a
    ld (LEFT_HI),a
    ld (RIGHT_LO),a
    ld (RIGHT_HI),a
    ld (T0),a
    ld (T1),a
    ret
saturating_word_add_step:
; SUM_LO = LEFT_LO + RIGHT_LO
    ld a,(LEFT_LO)
    ld b,a
    ld a,(RIGHT_LO)
    ld c,a
    ld a,b
    add a,c
    ld (SUM_LO),a
; T0 = 0
    ld a,0
    ld (T0),a
; if SUM_LO < LEFT_LO:
    ld a,(SUM_LO)
    ld b,a
    ld a,(LEFT_LO)
    ld c,a
    ld a,b
    cp c
    jp c,saturating_word_add_L1
    jp saturating_word_add_L2
saturating_word_add_L1:
; T0 = 1
    ld a,1
    ld (T0),a
    jp saturating_word_add_L3
saturating_word_add_L2:
saturating_word_add_L3:
; SUM_HI = LEFT_HI + RIGHT_HI
    ld a,(LEFT_HI)
    ld b,a
    ld a,(RIGHT_HI)
    ld c,a
    ld a,b
    add a,c
    ld (SUM_HI),a
; CLAMPED = 0
    ld a,0
    ld (CLAMPED),a
; if SUM_HI < LEFT_HI:
    ld a,(SUM_HI)
    ld b,a
    ld a,(LEFT_HI)
    ld c,a
    ld a,b
    cp c
    jp c,saturating_word_add_L4
    jp saturating_word_add_L5
saturating_word_add_L4:
; CLAMPED = 1
    ld a,1
    ld (CLAMPED),a
    jp saturating_word_add_L6
saturating_word_add_L5:
saturating_word_add_L6:
; T1 = SUM_HI
    ld a,(SUM_HI)
    ld (T1),a
; SUM_HI = SUM_HI + T0
    ld a,(SUM_HI)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    add a,c
    ld (SUM_HI),a
; if SUM_HI < T1:
    ld a,(SUM_HI)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    cp c
    jp c,saturating_word_add_L7
    jp saturating_word_add_L8
saturating_word_add_L7:
; CLAMPED = 1
    ld a,1
    ld (CLAMPED),a
    jp saturating_word_add_L9
saturating_word_add_L8:
saturating_word_add_L9:
; if CLAMPED != 0:
    ld a,(CLAMPED)
    cp 0
    jp nz,saturating_word_add_L10
    jp saturating_word_add_L11
saturating_word_add_L10:
; SUM_LO = 255
    ld a,255
    ld (SUM_LO),a
; SUM_HI = 255
    ld a,255
    ld (SUM_HI),a
    jp saturating_word_add_L12
saturating_word_add_L11:
saturating_word_add_L12:
    ret
component_end:
