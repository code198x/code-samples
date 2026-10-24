; SPDX-License-Identifier: MIT
; Debounce a Sampled Input Byte. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
input_debounce_init:
    ld a,0
    ld (STABLE),a
    ld (CHANGED),a
    ld (CANDIDATE),a
    ld (RUN),a
    ld (RAW),a
    ld (THRESHOLD),a
    ret
input_debounce_step:
; CHANGED = 0
    ld a,0
    ld (CHANGED),a
; if THRESHOLD == 0:
    ld a,(THRESHOLD)
    cp 0
    jp z,input_debounce_L1
    jp input_debounce_L2
input_debounce_L1:
; RUN = 0
    ld a,0
    ld (RUN),a
; return
    ret
    jp input_debounce_L3
input_debounce_L2:
input_debounce_L3:
; if RAW != CANDIDATE:
    ld a,(RAW)
    ld b,a
    ld a,(CANDIDATE)
    ld c,a
    ld a,b
    cp c
    jp nz,input_debounce_L4
    jp input_debounce_L5
input_debounce_L4:
; CANDIDATE = RAW
    ld a,(RAW)
    ld (CANDIDATE),a
; RUN = 1
    ld a,1
    ld (RUN),a
    jp input_debounce_L6
input_debounce_L5:
; if RUN < 255:
    ld a,(RUN)
    cp 255
    jp c,input_debounce_L7
    jp input_debounce_L8
input_debounce_L7:
; RUN = RUN + 1
    ld a,(RUN)
    add a,1
    ld (RUN),a
    jp input_debounce_L9
input_debounce_L8:
input_debounce_L9:
input_debounce_L6:
; if RUN >= THRESHOLD:
    ld a,(RUN)
    ld b,a
    ld a,(THRESHOLD)
    ld c,a
    ld a,b
    cp c
    jp nc,input_debounce_L10
    jp input_debounce_L11
input_debounce_L10:
; if STABLE != CANDIDATE:
    ld a,(STABLE)
    ld b,a
    ld a,(CANDIDATE)
    ld c,a
    ld a,b
    cp c
    jp nz,input_debounce_L13
    jp input_debounce_L14
input_debounce_L13:
; STABLE = CANDIDATE
    ld a,(CANDIDATE)
    ld (STABLE),a
; CHANGED = 1
    ld a,1
    ld (CHANGED),a
    jp input_debounce_L15
input_debounce_L14:
input_debounce_L15:
    jp input_debounce_L12
input_debounce_L11:
input_debounce_L12:
    ret
component_end:
