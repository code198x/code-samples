; SPDX-License-Identifier: MIT
; Debounce a Sampled Input Byte. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
input_debounce_init:
    move.b #0,d0
    move.b d0,STABLE
    move.b d0,CHANGED
    move.b d0,CANDIDATE
    move.b d0,RUN
    move.b d0,RAW
    move.b d0,THRESHOLD
    rts
input_debounce_step:
; CHANGED = 0
    move.b #0,d0
    move.b d0,CHANGED
; if THRESHOLD == 0:
    move.b THRESHOLD,d0
    cmp.b #0,d0
    beq input_debounce_L1
    jmp input_debounce_L2
input_debounce_L1:
; RUN = 0
    move.b #0,d0
    move.b d0,RUN
; return
    rts
    jmp input_debounce_L3
input_debounce_L2:
input_debounce_L3:
; if RAW != CANDIDATE:
    move.b RAW,d0
    move.b CANDIDATE,d1
    cmp.b d1,d0
    bne input_debounce_L4
    jmp input_debounce_L5
input_debounce_L4:
; CANDIDATE = RAW
    move.b RAW,d0
    move.b d0,CANDIDATE
; RUN = 1
    move.b #1,d0
    move.b d0,RUN
    jmp input_debounce_L6
input_debounce_L5:
; if RUN < 255:
    move.b RUN,d0
    cmp.b #255,d0
    bcs input_debounce_L7
    jmp input_debounce_L8
input_debounce_L7:
; RUN = RUN + 1
    move.b RUN,d0
    add.b #1,d0
    move.b d0,RUN
    jmp input_debounce_L9
input_debounce_L8:
input_debounce_L9:
input_debounce_L6:
; if RUN >= THRESHOLD:
    move.b RUN,d0
    move.b THRESHOLD,d1
    cmp.b d1,d0
    bcc input_debounce_L10
    jmp input_debounce_L11
input_debounce_L10:
; if STABLE != CANDIDATE:
    move.b STABLE,d0
    move.b CANDIDATE,d1
    cmp.b d1,d0
    bne input_debounce_L13
    jmp input_debounce_L14
input_debounce_L13:
; STABLE = CANDIDATE
    move.b CANDIDATE,d0
    move.b d0,STABLE
; CHANGED = 1
    move.b #1,d0
    move.b d0,CHANGED
    jmp input_debounce_L15
input_debounce_L14:
input_debounce_L15:
    jmp input_debounce_L12
input_debounce_L11:
input_debounce_L12:
    rts
component_end:
