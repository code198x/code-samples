; SPDX-License-Identifier: MIT
; Look Up a Bounded Byte Dictionary. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
dictionary_lookup_init:
    lda #0
    sta VALUE
    sta FOUND
    sta VALID
    sta KEY
    sta COUNT
    sta K0
    sta K1
    sta K2
    sta K3
    sta K4
    sta K5
    sta K6
    sta K7
    sta Q0
    sta Q1
    sta Q2
    sta Q3
    sta Q4
    sta Q5
    sta Q6
    sta Q7
    sta T0
    sta T1
    rts
dictionary_lookup_step:
; VALUE = 0
    lda #0
    sta VALUE
; FOUND = 0
    lda #0
    sta FOUND
; VALID = 0
    lda #0
    sta VALID
; if COUNT > 8:
    lda COUNT
    cmp #8
    beq dictionary_lookup_L5
    bcs dictionary_lookup_L4
dictionary_lookup_L5:
    jmp dictionary_lookup_L2
dictionary_lookup_L4:
    jmp dictionary_lookup_L1
dictionary_lookup_L1:
; return
    rts
    jmp dictionary_lookup_L3
dictionary_lookup_L2:
dictionary_lookup_L3:
; VALID = 1
    lda #1
    sta VALID
; T0 = 0
    lda #0
    sta T0
; while T0 < COUNT:
dictionary_lookup_L6:
    lda T0
    cmp COUNT
    bcc dictionary_lookup_L9
dictionary_lookup_L10:
    jmp dictionary_lookup_L8
dictionary_lookup_L9:
    jmp dictionary_lookup_L7
dictionary_lookup_L7:
; T1 = K[T0]
    ldx T0
    lda K0,x
    sta T1
; if KEY == T1:
    lda KEY
    cmp T1
    beq dictionary_lookup_L14
dictionary_lookup_L15:
    jmp dictionary_lookup_L12
dictionary_lookup_L14:
    jmp dictionary_lookup_L11
dictionary_lookup_L11:
; T1 = Q[T0]
    ldx T0
    lda Q0,x
    sta T1
; VALUE = T1
    lda T1
    sta VALUE
; FOUND = 1
    lda #1
    sta FOUND
; return
    rts
    jmp dictionary_lookup_L13
dictionary_lookup_L12:
dictionary_lookup_L13:
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp dictionary_lookup_L6
dictionary_lookup_L8:
    rts
component_end:
