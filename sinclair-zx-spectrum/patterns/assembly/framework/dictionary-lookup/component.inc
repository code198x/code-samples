; SPDX-License-Identifier: MIT
; Look Up a Bounded Byte Dictionary. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
dictionary_lookup_init:
    ld a,0
    ld (VALUE),a
    ld (FOUND),a
    ld (VALID),a
    ld (KEY),a
    ld (COUNT),a
    ld (K0),a
    ld (K1),a
    ld (K2),a
    ld (K3),a
    ld (K4),a
    ld (K5),a
    ld (K6),a
    ld (K7),a
    ld (Q0),a
    ld (Q1),a
    ld (Q2),a
    ld (Q3),a
    ld (Q4),a
    ld (Q5),a
    ld (Q6),a
    ld (Q7),a
    ld (T0),a
    ld (T1),a
    ret
dictionary_lookup_step:
; VALUE = 0
    ld a,0
    ld (VALUE),a
; FOUND = 0
    ld a,0
    ld (FOUND),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if COUNT > 8:
    ld a,(COUNT)
    cp 8
    jp z,dictionary_lookup_L2
    jp nc,dictionary_lookup_L1
    jp dictionary_lookup_L2
dictionary_lookup_L1:
; return
    ret
    jp dictionary_lookup_L3
dictionary_lookup_L2:
dictionary_lookup_L3:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = 0
    ld a,0
    ld (T0),a
; while T0 < COUNT:
dictionary_lookup_L4:
    ld a,(T0)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    cp c
    jp c,dictionary_lookup_L5
    jp dictionary_lookup_L6
dictionary_lookup_L5:
; T1 = K[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,K0
    add hl,de
    ld a,(hl)
    ld (T1),a
; if KEY == T1:
    ld a,(KEY)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    cp c
    jp z,dictionary_lookup_L7
    jp dictionary_lookup_L8
dictionary_lookup_L7:
; T1 = Q[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,Q0
    add hl,de
    ld a,(hl)
    ld (T1),a
; VALUE = T1
    ld a,(T1)
    ld (VALUE),a
; FOUND = 1
    ld a,1
    ld (FOUND),a
; return
    ret
    jp dictionary_lookup_L9
dictionary_lookup_L8:
dictionary_lookup_L9:
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp dictionary_lookup_L4
dictionary_lookup_L6:
    ret
component_end:
