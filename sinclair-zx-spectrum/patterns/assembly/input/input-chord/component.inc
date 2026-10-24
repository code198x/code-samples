; SPDX-License-Identifier: MIT
; Detect a Button Chord Once. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
input_chord_init:
    ld a,0
    ld (PREVIOUS),a
    ld (HELD),a
    ld (REQUIRED),a
    ld (FORBIDDEN),a
    ld (ACTIVE),a
    ld (PRESSED),a
    ld (VALID),a
    ld (T0),a
    ret
input_chord_step:
; ACTIVE = 0
    ld a,0
    ld (ACTIVE),a
; PRESSED = 0
    ld a,0
    ld (PRESSED),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if REQUIRED == 0:
    ld a,(REQUIRED)
    cp 0
    jp z,input_chord_L1
    jp input_chord_L2
input_chord_L1:
; PREVIOUS = 0
    ld a,0
    ld (PREVIOUS),a
; return
    ret
    jp input_chord_L3
input_chord_L2:
input_chord_L3:
; T0 = REQUIRED & FORBIDDEN
    ld a,(REQUIRED)
    ld b,a
    ld a,(FORBIDDEN)
    ld c,a
    ld a,b
    and c
    ld (T0),a
; if T0 != 0:
    ld a,(T0)
    cp 0
    jp nz,input_chord_L4
    jp input_chord_L5
input_chord_L4:
; PREVIOUS = 0
    ld a,0
    ld (PREVIOUS),a
; return
    ret
    jp input_chord_L6
input_chord_L5:
input_chord_L6:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = HELD & REQUIRED
    ld a,(HELD)
    ld b,a
    ld a,(REQUIRED)
    ld c,a
    ld a,b
    and c
    ld (T0),a
; if T0 == REQUIRED:
    ld a,(T0)
    ld b,a
    ld a,(REQUIRED)
    ld c,a
    ld a,b
    cp c
    jp z,input_chord_L7
    jp input_chord_L8
input_chord_L7:
; T0 = HELD & FORBIDDEN
    ld a,(HELD)
    ld b,a
    ld a,(FORBIDDEN)
    ld c,a
    ld a,b
    and c
    ld (T0),a
; if T0 == 0:
    ld a,(T0)
    cp 0
    jp z,input_chord_L10
    jp input_chord_L11
input_chord_L10:
; ACTIVE = 1
    ld a,1
    ld (ACTIVE),a
    jp input_chord_L12
input_chord_L11:
input_chord_L12:
    jp input_chord_L9
input_chord_L8:
input_chord_L9:
; if ACTIVE != 0:
    ld a,(ACTIVE)
    cp 0
    jp nz,input_chord_L13
    jp input_chord_L14
input_chord_L13:
; if PREVIOUS == 0:
    ld a,(PREVIOUS)
    cp 0
    jp z,input_chord_L16
    jp input_chord_L17
input_chord_L16:
; PRESSED = 1
    ld a,1
    ld (PRESSED),a
    jp input_chord_L18
input_chord_L17:
input_chord_L18:
    jp input_chord_L15
input_chord_L14:
input_chord_L15:
; PREVIOUS = ACTIVE
    ld a,(ACTIVE)
    ld (PREVIOUS),a
    ret
component_end:
