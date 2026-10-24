; SPDX-License-Identifier: MIT
; Service a Timed Status Effect. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
timed_status_init:
    move.b #0,d0
    move.b d0,PULSE
    move.b d0,REMAINING
    move.b d0,PHASE
    move.b d0,DURATION
    move.b d0,PERIOD
    move.b d0,APPLY
    move.b d0,VALID
    rts
timed_status_step:
; PULSE = 0
    move.b #0,d0
    move.b d0,PULSE
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if PERIOD == 0:
    move.b PERIOD,d0
    cmp.b #0,d0
    beq timed_status_L1
    jmp timed_status_L2
timed_status_L1:
; return
    rts
    jmp timed_status_L3
timed_status_L2:
timed_status_L3:
; if PHASE >= PERIOD:
    move.b PHASE,d0
    move.b PERIOD,d1
    cmp.b d1,d0
    bcc timed_status_L4
    jmp timed_status_L5
timed_status_L4:
; return
    rts
    jmp timed_status_L6
timed_status_L5:
timed_status_L6:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if APPLY != 0:
    move.b APPLY,d0
    cmp.b #0,d0
    bne timed_status_L7
    jmp timed_status_L8
timed_status_L7:
; REMAINING = DURATION
    move.b DURATION,d0
    move.b d0,REMAINING
; PHASE = 0
    move.b #0,d0
    move.b d0,PHASE
    jmp timed_status_L9
timed_status_L8:
timed_status_L9:
; if REMAINING == 0:
    move.b REMAINING,d0
    cmp.b #0,d0
    beq timed_status_L10
    jmp timed_status_L11
timed_status_L10:
; PHASE = 0
    move.b #0,d0
    move.b d0,PHASE
; return
    rts
    jmp timed_status_L12
timed_status_L11:
timed_status_L12:
; REMAINING = REMAINING - 1
    move.b REMAINING,d0
    sub.b #1,d0
    move.b d0,REMAINING
; PHASE = PHASE + 1
    move.b PHASE,d0
    add.b #1,d0
    move.b d0,PHASE
; if PHASE == PERIOD:
    move.b PHASE,d0
    move.b PERIOD,d1
    cmp.b d1,d0
    beq timed_status_L13
    jmp timed_status_L14
timed_status_L13:
; PHASE = 0
    move.b #0,d0
    move.b d0,PHASE
; PULSE = 1
    move.b #1,d0
    move.b d0,PULSE
    jmp timed_status_L15
timed_status_L14:
timed_status_L15:
; if REMAINING == 0:
    move.b REMAINING,d0
    cmp.b #0,d0
    beq timed_status_L16
    jmp timed_status_L17
timed_status_L16:
; PHASE = 0
    move.b #0,d0
    move.b d0,PHASE
    jmp timed_status_L18
timed_status_L17:
timed_status_L18:
    rts
component_end:
