; SPDX-License-Identifier: MIT
; Detect a Button Chord Once. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
input_chord_init:
    move.b #0,d0
    move.b d0,PREVIOUS
    move.b d0,HELD
    move.b d0,REQUIRED
    move.b d0,FORBIDDEN
    move.b d0,ACTIVE
    move.b d0,PRESSED
    move.b d0,VALID
    move.b d0,T0
    rts
input_chord_step:
; ACTIVE = 0
    move.b #0,d0
    move.b d0,ACTIVE
; PRESSED = 0
    move.b #0,d0
    move.b d0,PRESSED
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if REQUIRED == 0:
    move.b REQUIRED,d0
    cmp.b #0,d0
    beq input_chord_L1
    jmp input_chord_L2
input_chord_L1:
; PREVIOUS = 0
    move.b #0,d0
    move.b d0,PREVIOUS
; return
    rts
    jmp input_chord_L3
input_chord_L2:
input_chord_L3:
; T0 = REQUIRED & FORBIDDEN
    move.b REQUIRED,d0
    move.b FORBIDDEN,d1
    and.b d1,d0
    move.b d0,T0
; if T0 != 0:
    move.b T0,d0
    cmp.b #0,d0
    bne input_chord_L4
    jmp input_chord_L5
input_chord_L4:
; PREVIOUS = 0
    move.b #0,d0
    move.b d0,PREVIOUS
; return
    rts
    jmp input_chord_L6
input_chord_L5:
input_chord_L6:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = HELD & REQUIRED
    move.b HELD,d0
    move.b REQUIRED,d1
    and.b d1,d0
    move.b d0,T0
; if T0 == REQUIRED:
    move.b T0,d0
    move.b REQUIRED,d1
    cmp.b d1,d0
    beq input_chord_L7
    jmp input_chord_L8
input_chord_L7:
; T0 = HELD & FORBIDDEN
    move.b HELD,d0
    move.b FORBIDDEN,d1
    and.b d1,d0
    move.b d0,T0
; if T0 == 0:
    move.b T0,d0
    cmp.b #0,d0
    beq input_chord_L10
    jmp input_chord_L11
input_chord_L10:
; ACTIVE = 1
    move.b #1,d0
    move.b d0,ACTIVE
    jmp input_chord_L12
input_chord_L11:
input_chord_L12:
    jmp input_chord_L9
input_chord_L8:
input_chord_L9:
; if ACTIVE != 0:
    move.b ACTIVE,d0
    cmp.b #0,d0
    bne input_chord_L13
    jmp input_chord_L14
input_chord_L13:
; if PREVIOUS == 0:
    move.b PREVIOUS,d0
    cmp.b #0,d0
    beq input_chord_L16
    jmp input_chord_L17
input_chord_L16:
; PRESSED = 1
    move.b #1,d0
    move.b d0,PRESSED
    jmp input_chord_L18
input_chord_L17:
input_chord_L18:
    jmp input_chord_L15
input_chord_L14:
input_chord_L15:
; PREVIOUS = ACTIVE
    move.b ACTIVE,d0
    move.b d0,PREVIOUS
    rts
component_end:
