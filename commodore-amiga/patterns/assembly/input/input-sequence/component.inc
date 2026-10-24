; SPDX-License-Identifier: MIT
; Recognise a Short Input Sequence. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
input_sequence_init:
    move.b #0,d0
    move.b d0,PROGRESS
    move.b d0,SYMBOL
    move.b d0,MATCHED
    move.b d0,VALID
    move.b d0,T0
    rts
input_sequence_step:
; MATCHED = 0
    move.b #0,d0
    move.b d0,MATCHED
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if PROGRESS >= 4:
    move.b PROGRESS,d0
    cmp.b #4,d0
    bcc input_sequence_L1
    jmp input_sequence_L2
input_sequence_L1:
; return
    rts
    jmp input_sequence_L3
input_sequence_L2:
input_sequence_L3:
; if SYMBOL >= 3:
    move.b SYMBOL,d0
    cmp.b #3,d0
    bcc input_sequence_L4
    jmp input_sequence_L5
input_sequence_L4:
; return
    rts
    jmp input_sequence_L6
input_sequence_L5:
input_sequence_L6:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if SYMBOL == 0:
    move.b SYMBOL,d0
    cmp.b #0,d0
    beq input_sequence_L7
    jmp input_sequence_L8
input_sequence_L7:
; return
    rts
    jmp input_sequence_L9
input_sequence_L8:
input_sequence_L9:
; T0 = PROGRESS & 1
    move.b PROGRESS,d0
    and.b #1,d0
    move.b d0,T0
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
; if SYMBOL == T0:
    move.b SYMBOL,d0
    move.b T0,d1
    cmp.b d1,d0
    beq input_sequence_L10
    jmp input_sequence_L11
input_sequence_L10:
; PROGRESS = PROGRESS + 1
    move.b PROGRESS,d0
    add.b #1,d0
    move.b d0,PROGRESS
; if PROGRESS == 4:
    move.b PROGRESS,d0
    cmp.b #4,d0
    beq input_sequence_L13
    jmp input_sequence_L14
input_sequence_L13:
; MATCHED = 1
    move.b #1,d0
    move.b d0,MATCHED
; PROGRESS = 2
    move.b #2,d0
    move.b d0,PROGRESS
    jmp input_sequence_L15
input_sequence_L14:
input_sequence_L15:
    jmp input_sequence_L12
input_sequence_L11:
; PROGRESS = 0
    move.b #0,d0
    move.b d0,PROGRESS
; if SYMBOL == 1:
    move.b SYMBOL,d0
    cmp.b #1,d0
    beq input_sequence_L16
    jmp input_sequence_L17
input_sequence_L16:
; PROGRESS = 1
    move.b #1,d0
    move.b d0,PROGRESS
    jmp input_sequence_L18
input_sequence_L17:
input_sequence_L18:
input_sequence_L12:
    rts
component_end:
