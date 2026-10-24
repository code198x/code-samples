; SPDX-License-Identifier: MIT
; Service a Timed Status Effect. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
timed_status_init:
    ld a,0
    ld (PULSE),a
    ld (REMAINING),a
    ld (PHASE),a
    ld (DURATION),a
    ld (PERIOD),a
    ld (APPLY),a
    ld (VALID),a
    ret
timed_status_step:
; PULSE = 0
    ld a,0
    ld (PULSE),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if PERIOD == 0:
    ld a,(PERIOD)
    cp 0
    jp z,timed_status_L1
    jp timed_status_L2
timed_status_L1:
; return
    ret
    jp timed_status_L3
timed_status_L2:
timed_status_L3:
; if PHASE >= PERIOD:
    ld a,(PHASE)
    ld b,a
    ld a,(PERIOD)
    ld c,a
    ld a,b
    cp c
    jp nc,timed_status_L4
    jp timed_status_L5
timed_status_L4:
; return
    ret
    jp timed_status_L6
timed_status_L5:
timed_status_L6:
; VALID = 1
    ld a,1
    ld (VALID),a
; if APPLY != 0:
    ld a,(APPLY)
    cp 0
    jp nz,timed_status_L7
    jp timed_status_L8
timed_status_L7:
; REMAINING = DURATION
    ld a,(DURATION)
    ld (REMAINING),a
; PHASE = 0
    ld a,0
    ld (PHASE),a
    jp timed_status_L9
timed_status_L8:
timed_status_L9:
; if REMAINING == 0:
    ld a,(REMAINING)
    cp 0
    jp z,timed_status_L10
    jp timed_status_L11
timed_status_L10:
; PHASE = 0
    ld a,0
    ld (PHASE),a
; return
    ret
    jp timed_status_L12
timed_status_L11:
timed_status_L12:
; REMAINING = REMAINING - 1
    ld a,(REMAINING)
    sub 1
    ld (REMAINING),a
; PHASE = PHASE + 1
    ld a,(PHASE)
    add a,1
    ld (PHASE),a
; if PHASE == PERIOD:
    ld a,(PHASE)
    ld b,a
    ld a,(PERIOD)
    ld c,a
    ld a,b
    cp c
    jp z,timed_status_L13
    jp timed_status_L14
timed_status_L13:
; PHASE = 0
    ld a,0
    ld (PHASE),a
; PULSE = 1
    ld a,1
    ld (PULSE),a
    jp timed_status_L15
timed_status_L14:
timed_status_L15:
; if REMAINING == 0:
    ld a,(REMAINING)
    cp 0
    jp z,timed_status_L16
    jp timed_status_L17
timed_status_L16:
; PHASE = 0
    ld a,0
    ld (PHASE),a
    jp timed_status_L18
timed_status_L17:
timed_status_L18:
    ret
component_end:
