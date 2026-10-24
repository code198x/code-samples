; SPDX-License-Identifier: MIT
; Decode Bounded Byte Deltas. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_delta_decoder_init:
    ld a,0
    ld (WRITTEN),a
    ld (VALID),a
    ld (COUNT),a
    ld (BASE),a
    ld (Q0),a
    ld (Q1),a
    ld (Q2),a
    ld (Q3),a
    ld (Q4),a
    ld (Q5),a
    ld (Q6),a
    ld (Q7),a
    ld (R0),a
    ld (R1),a
    ld (R2),a
    ld (R3),a
    ld (R4),a
    ld (R5),a
    ld (R6),a
    ld (R7),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (EXPR_SAVE),a
    ret
bounded_delta_decoder_step:
; WRITTEN = 0
    ld a,0
    ld (WRITTEN),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if COUNT > 8:
    ld a,(COUNT)
    cp 8
    jp z,bounded_delta_decoder_L2
    jp nc,bounded_delta_decoder_L1
    jp bounded_delta_decoder_L2
bounded_delta_decoder_L1:
; return
    ret
    jp bounded_delta_decoder_L3
bounded_delta_decoder_L2:
bounded_delta_decoder_L3:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = BASE
    ld a,(BASE)
    ld (T0),a
; T1 = 0
    ld a,0
    ld (T1),a
; while T1 < COUNT:
bounded_delta_decoder_L4:
    ld a,(T1)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    cp c
    jp c,bounded_delta_decoder_L5
    jp bounded_delta_decoder_L6
bounded_delta_decoder_L5:
; T2 = Q[T1]
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,Q0
    add hl,de
    ld a,(hl)
    ld (T2),a
; T0 = T0 + T2
    ld a,(T0)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    add a,c
    ld (T0),a
; R[T1] = T0
    ld a,(T0)
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,R0
    add hl,de
    ld (hl),c
; T1 = T1 + 1
    ld a,(T1)
    add a,1
    ld (T1),a
    jp bounded_delta_decoder_L4
bounded_delta_decoder_L6:
; WRITTEN = COUNT
    ld a,(COUNT)
    ld (WRITTEN),a
    ret
component_end:
