; SPDX-License-Identifier: MIT
; Recognise a Short Input Sequence. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
input_sequence_init:
    lda #0
    sta PROGRESS
    sta SYMBOL
    sta MATCHED
    sta VALID
    sta T0
    rts
input_sequence_step:
; MATCHED = 0
    lda #0
    sta MATCHED
; VALID = 0
    lda #0
    sta VALID
; if PROGRESS >= 4:
    lda PROGRESS
    cmp #4
    bcs input_sequence_L4
input_sequence_L5:
    jmp input_sequence_L2
input_sequence_L4:
    jmp input_sequence_L1
input_sequence_L1:
; return
    rts
    jmp input_sequence_L3
input_sequence_L2:
input_sequence_L3:
; if SYMBOL >= 3:
    lda SYMBOL
    cmp #3
    bcs input_sequence_L9
input_sequence_L10:
    jmp input_sequence_L7
input_sequence_L9:
    jmp input_sequence_L6
input_sequence_L6:
; return
    rts
    jmp input_sequence_L8
input_sequence_L7:
input_sequence_L8:
; VALID = 1
    lda #1
    sta VALID
; if SYMBOL == 0:
    lda SYMBOL
    cmp #0
    beq input_sequence_L14
input_sequence_L15:
    jmp input_sequence_L12
input_sequence_L14:
    jmp input_sequence_L11
input_sequence_L11:
; return
    rts
    jmp input_sequence_L13
input_sequence_L12:
input_sequence_L13:
; T0 = PROGRESS & 1
    lda PROGRESS
    and #1
    sta T0
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
; if SYMBOL == T0:
    lda SYMBOL
    cmp T0
    beq input_sequence_L19
input_sequence_L20:
    jmp input_sequence_L17
input_sequence_L19:
    jmp input_sequence_L16
input_sequence_L16:
; PROGRESS = PROGRESS + 1
    lda PROGRESS
    clc
    adc #1
    sta PROGRESS
; if PROGRESS == 4:
    lda PROGRESS
    cmp #4
    beq input_sequence_L24
input_sequence_L25:
    jmp input_sequence_L22
input_sequence_L24:
    jmp input_sequence_L21
input_sequence_L21:
; MATCHED = 1
    lda #1
    sta MATCHED
; PROGRESS = 2
    lda #2
    sta PROGRESS
    jmp input_sequence_L23
input_sequence_L22:
input_sequence_L23:
    jmp input_sequence_L18
input_sequence_L17:
; PROGRESS = 0
    lda #0
    sta PROGRESS
; if SYMBOL == 1:
    lda SYMBOL
    cmp #1
    beq input_sequence_L29
input_sequence_L30:
    jmp input_sequence_L27
input_sequence_L29:
    jmp input_sequence_L26
input_sequence_L26:
; PROGRESS = 1
    lda #1
    sta PROGRESS
    jmp input_sequence_L28
input_sequence_L27:
input_sequence_L28:
input_sequence_L18:
    rts
component_end:
