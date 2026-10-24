; SPDX-License-Identifier: MIT
; Decode Bounded Byte Deltas. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_delta_decoder_init:
    lda #0
    sta WRITTEN
    sta VALID
    sta COUNT
    sta BASE
    sta Q0
    sta Q1
    sta Q2
    sta Q3
    sta Q4
    sta Q5
    sta Q6
    sta Q7
    sta R0
    sta R1
    sta R2
    sta R3
    sta R4
    sta R5
    sta R6
    sta R7
    sta T0
    sta T1
    sta T2
    sta EXPR_SAVE
    rts
bounded_delta_decoder_step:
; WRITTEN = 0
    lda #0
    sta WRITTEN
; VALID = 0
    lda #0
    sta VALID
; if COUNT > 8:
    lda COUNT
    cmp #8
    beq bounded_delta_decoder_L5
    bcs bounded_delta_decoder_L4
bounded_delta_decoder_L5:
    jmp bounded_delta_decoder_L2
bounded_delta_decoder_L4:
    jmp bounded_delta_decoder_L1
bounded_delta_decoder_L1:
; return
    rts
    jmp bounded_delta_decoder_L3
bounded_delta_decoder_L2:
bounded_delta_decoder_L3:
; VALID = 1
    lda #1
    sta VALID
; T0 = BASE
    lda BASE
    sta T0
; T1 = 0
    lda #0
    sta T1
; while T1 < COUNT:
bounded_delta_decoder_L6:
    lda T1
    cmp COUNT
    bcc bounded_delta_decoder_L9
bounded_delta_decoder_L10:
    jmp bounded_delta_decoder_L8
bounded_delta_decoder_L9:
    jmp bounded_delta_decoder_L7
bounded_delta_decoder_L7:
; T2 = Q[T1]
    ldx T1
    lda Q0,x
    sta T2
; T0 = T0 + T2
    lda T0
    clc
    adc T2
    sta T0
; R[T1] = T0
    lda T0
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta R0,x
; T1 = T1 + 1
    lda T1
    clc
    adc #1
    sta T1
    jmp bounded_delta_decoder_L6
bounded_delta_decoder_L8:
; WRITTEN = COUNT
    lda COUNT
    sta WRITTEN
    rts
component_end:
