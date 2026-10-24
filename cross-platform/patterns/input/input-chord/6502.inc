; SPDX-License-Identifier: MIT
; Detect a Button Chord Once. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
input_chord_init:
    lda #0
    sta PREVIOUS
    sta HELD
    sta REQUIRED
    sta FORBIDDEN
    sta ACTIVE
    sta PRESSED
    sta VALID
    sta T0
    rts
input_chord_step:
; ACTIVE = 0
    lda #0
    sta ACTIVE
; PRESSED = 0
    lda #0
    sta PRESSED
; VALID = 0
    lda #0
    sta VALID
; if REQUIRED == 0:
    lda REQUIRED
    cmp #0
    beq input_chord_L4
input_chord_L5:
    jmp input_chord_L2
input_chord_L4:
    jmp input_chord_L1
input_chord_L1:
; PREVIOUS = 0
    lda #0
    sta PREVIOUS
; return
    rts
    jmp input_chord_L3
input_chord_L2:
input_chord_L3:
; T0 = REQUIRED & FORBIDDEN
    lda REQUIRED
    and FORBIDDEN
    sta T0
; if T0 != 0:
    lda T0
    cmp #0
    bne input_chord_L9
input_chord_L10:
    jmp input_chord_L7
input_chord_L9:
    jmp input_chord_L6
input_chord_L6:
; PREVIOUS = 0
    lda #0
    sta PREVIOUS
; return
    rts
    jmp input_chord_L8
input_chord_L7:
input_chord_L8:
; VALID = 1
    lda #1
    sta VALID
; T0 = HELD & REQUIRED
    lda HELD
    and REQUIRED
    sta T0
; if T0 == REQUIRED:
    lda T0
    cmp REQUIRED
    beq input_chord_L14
input_chord_L15:
    jmp input_chord_L12
input_chord_L14:
    jmp input_chord_L11
input_chord_L11:
; T0 = HELD & FORBIDDEN
    lda HELD
    and FORBIDDEN
    sta T0
; if T0 == 0:
    lda T0
    cmp #0
    beq input_chord_L19
input_chord_L20:
    jmp input_chord_L17
input_chord_L19:
    jmp input_chord_L16
input_chord_L16:
; ACTIVE = 1
    lda #1
    sta ACTIVE
    jmp input_chord_L18
input_chord_L17:
input_chord_L18:
    jmp input_chord_L13
input_chord_L12:
input_chord_L13:
; if ACTIVE != 0:
    lda ACTIVE
    cmp #0
    bne input_chord_L24
input_chord_L25:
    jmp input_chord_L22
input_chord_L24:
    jmp input_chord_L21
input_chord_L21:
; if PREVIOUS == 0:
    lda PREVIOUS
    cmp #0
    beq input_chord_L29
input_chord_L30:
    jmp input_chord_L27
input_chord_L29:
    jmp input_chord_L26
input_chord_L26:
; PRESSED = 1
    lda #1
    sta PRESSED
    jmp input_chord_L28
input_chord_L27:
input_chord_L28:
    jmp input_chord_L23
input_chord_L22:
input_chord_L23:
; PREVIOUS = ACTIVE
    lda ACTIVE
    sta PREVIOUS
    rts
component_end:
