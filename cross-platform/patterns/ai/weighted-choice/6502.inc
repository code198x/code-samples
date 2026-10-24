; SPDX-License-Identifier: MIT
; Choose from Weighted Outcomes. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
weighted_choice_init:
    lda #0
    sta WEIGHT0
    sta WEIGHT1
    sta WEIGHT2
    sta ROLL
    sta CHOICE
    sta TOTAL
    sta VALID
    sta T0
    sta T1
    rts
weighted_choice_step:
; CHOICE = 255
    lda #255
    sta CHOICE
; TOTAL = 0
    lda #0
    sta TOTAL
; VALID = 0
    lda #0
    sta VALID
; T0 = WEIGHT0 + WEIGHT1
    lda WEIGHT0
    clc
    adc WEIGHT1
    sta T0
; if T0 < WEIGHT0:
    lda T0
    cmp WEIGHT0
    bcc weighted_choice_L4
weighted_choice_L5:
    jmp weighted_choice_L2
weighted_choice_L4:
    jmp weighted_choice_L1
weighted_choice_L1:
; return
    rts
    jmp weighted_choice_L3
weighted_choice_L2:
weighted_choice_L3:
; T1 = T0 + WEIGHT2
    lda T0
    clc
    adc WEIGHT2
    sta T1
; if T1 < T0:
    lda T1
    cmp T0
    bcc weighted_choice_L9
weighted_choice_L10:
    jmp weighted_choice_L7
weighted_choice_L9:
    jmp weighted_choice_L6
weighted_choice_L6:
; return
    rts
    jmp weighted_choice_L8
weighted_choice_L7:
weighted_choice_L8:
; TOTAL = T1
    lda T1
    sta TOTAL
; if TOTAL == 0:
    lda TOTAL
    cmp #0
    beq weighted_choice_L14
weighted_choice_L15:
    jmp weighted_choice_L12
weighted_choice_L14:
    jmp weighted_choice_L11
weighted_choice_L11:
; return
    rts
    jmp weighted_choice_L13
weighted_choice_L12:
weighted_choice_L13:
; if ROLL >= TOTAL:
    lda ROLL
    cmp TOTAL
    bcs weighted_choice_L19
weighted_choice_L20:
    jmp weighted_choice_L17
weighted_choice_L19:
    jmp weighted_choice_L16
weighted_choice_L16:
; return
    rts
    jmp weighted_choice_L18
weighted_choice_L17:
weighted_choice_L18:
; VALID = 1
    lda #1
    sta VALID
; CHOICE = 0
    lda #0
    sta CHOICE
; if ROLL < WEIGHT0:
    lda ROLL
    cmp WEIGHT0
    bcc weighted_choice_L24
weighted_choice_L25:
    jmp weighted_choice_L22
weighted_choice_L24:
    jmp weighted_choice_L21
weighted_choice_L21:
; return
    rts
    jmp weighted_choice_L23
weighted_choice_L22:
weighted_choice_L23:
; CHOICE = 1
    lda #1
    sta CHOICE
; if ROLL < T0:
    lda ROLL
    cmp T0
    bcc weighted_choice_L29
weighted_choice_L30:
    jmp weighted_choice_L27
weighted_choice_L29:
    jmp weighted_choice_L26
weighted_choice_L26:
; return
    rts
    jmp weighted_choice_L28
weighted_choice_L27:
weighted_choice_L28:
; CHOICE = 2
    lda #2
    sta CHOICE
    rts
component_end:
