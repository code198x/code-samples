; SPDX-License-Identifier: MIT
; Recognise a Short Input Sequence. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
input_sequence_init:
    ld a,0
    ld (PROGRESS),a
    ld (SYMBOL),a
    ld (MATCHED),a
    ld (VALID),a
    ld (T0),a
    ret
input_sequence_step:
; MATCHED = 0
    ld a,0
    ld (MATCHED),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if PROGRESS >= 4:
    ld a,(PROGRESS)
    cp 4
    jp nc,input_sequence_L1
    jp input_sequence_L2
input_sequence_L1:
; return
    ret
    jp input_sequence_L3
input_sequence_L2:
input_sequence_L3:
; if SYMBOL >= 3:
    ld a,(SYMBOL)
    cp 3
    jp nc,input_sequence_L4
    jp input_sequence_L5
input_sequence_L4:
; return
    ret
    jp input_sequence_L6
input_sequence_L5:
input_sequence_L6:
; VALID = 1
    ld a,1
    ld (VALID),a
; if SYMBOL == 0:
    ld a,(SYMBOL)
    cp 0
    jp z,input_sequence_L7
    jp input_sequence_L8
input_sequence_L7:
; return
    ret
    jp input_sequence_L9
input_sequence_L8:
input_sequence_L9:
; T0 = PROGRESS & 1
    ld a,(PROGRESS)
    and 1
    ld (T0),a
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
; if SYMBOL == T0:
    ld a,(SYMBOL)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp z,input_sequence_L10
    jp input_sequence_L11
input_sequence_L10:
; PROGRESS = PROGRESS + 1
    ld a,(PROGRESS)
    add a,1
    ld (PROGRESS),a
; if PROGRESS == 4:
    ld a,(PROGRESS)
    cp 4
    jp z,input_sequence_L13
    jp input_sequence_L14
input_sequence_L13:
; MATCHED = 1
    ld a,1
    ld (MATCHED),a
; PROGRESS = 2
    ld a,2
    ld (PROGRESS),a
    jp input_sequence_L15
input_sequence_L14:
input_sequence_L15:
    jp input_sequence_L12
input_sequence_L11:
; PROGRESS = 0
    ld a,0
    ld (PROGRESS),a
; if SYMBOL == 1:
    ld a,(SYMBOL)
    cp 1
    jp z,input_sequence_L16
    jp input_sequence_L17
input_sequence_L16:
; PROGRESS = 1
    ld a,1
    ld (PROGRESS),a
    jp input_sequence_L18
input_sequence_L17:
input_sequence_L18:
input_sequence_L12:
    ret
component_end:
