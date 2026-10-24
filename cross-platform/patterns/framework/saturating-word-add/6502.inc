; SPDX-License-Identifier: MIT
; Add Words with Saturation. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
saturating_word_add_init:
    lda #0
    sta SUM_LO
    sta SUM_HI
    sta CLAMPED
    sta LEFT_LO
    sta LEFT_HI
    sta RIGHT_LO
    sta RIGHT_HI
    sta T0
    sta T1
    rts
saturating_word_add_step:
; SUM_LO = LEFT_LO + RIGHT_LO
    lda LEFT_LO
    clc
    adc RIGHT_LO
    sta SUM_LO
; T0 = 0
    lda #0
    sta T0
; if SUM_LO < LEFT_LO:
    lda SUM_LO
    cmp LEFT_LO
    bcc saturating_word_add_L4
saturating_word_add_L5:
    jmp saturating_word_add_L2
saturating_word_add_L4:
    jmp saturating_word_add_L1
saturating_word_add_L1:
; T0 = 1
    lda #1
    sta T0
    jmp saturating_word_add_L3
saturating_word_add_L2:
saturating_word_add_L3:
; SUM_HI = LEFT_HI + RIGHT_HI
    lda LEFT_HI
    clc
    adc RIGHT_HI
    sta SUM_HI
; CLAMPED = 0
    lda #0
    sta CLAMPED
; if SUM_HI < LEFT_HI:
    lda SUM_HI
    cmp LEFT_HI
    bcc saturating_word_add_L9
saturating_word_add_L10:
    jmp saturating_word_add_L7
saturating_word_add_L9:
    jmp saturating_word_add_L6
saturating_word_add_L6:
; CLAMPED = 1
    lda #1
    sta CLAMPED
    jmp saturating_word_add_L8
saturating_word_add_L7:
saturating_word_add_L8:
; T1 = SUM_HI
    lda SUM_HI
    sta T1
; SUM_HI = SUM_HI + T0
    lda SUM_HI
    clc
    adc T0
    sta SUM_HI
; if SUM_HI < T1:
    lda SUM_HI
    cmp T1
    bcc saturating_word_add_L14
saturating_word_add_L15:
    jmp saturating_word_add_L12
saturating_word_add_L14:
    jmp saturating_word_add_L11
saturating_word_add_L11:
; CLAMPED = 1
    lda #1
    sta CLAMPED
    jmp saturating_word_add_L13
saturating_word_add_L12:
saturating_word_add_L13:
; if CLAMPED != 0:
    lda CLAMPED
    cmp #0
    bne saturating_word_add_L19
saturating_word_add_L20:
    jmp saturating_word_add_L17
saturating_word_add_L19:
    jmp saturating_word_add_L16
saturating_word_add_L16:
; SUM_LO = 255
    lda #255
    sta SUM_LO
; SUM_HI = 255
    lda #255
    sta SUM_HI
    jmp saturating_word_add_L18
saturating_word_add_L17:
saturating_word_add_L18:
    rts
component_end:
