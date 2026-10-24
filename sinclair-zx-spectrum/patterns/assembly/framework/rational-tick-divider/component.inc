; SPDX-License-Identifier: MIT
; Divide Ticks Without Losing the Remainder. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
rational_tick_divider_init:
    ld a,0
    ld (PHASE),a
    ld (NUMERATOR),a
    ld (DENOMINATOR),a
    ld (FIRED),a
    ld (VALID),a
    ld (T0),a
    ret
rational_tick_divider_step:
; FIRED = 0
    ld a,0
    ld (FIRED),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if DENOMINATOR == 0:
    ld a,(DENOMINATOR)
    cp 0
    jp z,rational_tick_divider_L1
    jp rational_tick_divider_L2
rational_tick_divider_L1:
; return
    ret
    jp rational_tick_divider_L3
rational_tick_divider_L2:
rational_tick_divider_L3:
; if NUMERATOR > DENOMINATOR:
    ld a,(NUMERATOR)
    ld b,a
    ld a,(DENOMINATOR)
    ld c,a
    ld a,b
    cp c
    jp z,rational_tick_divider_L5
    jp nc,rational_tick_divider_L4
    jp rational_tick_divider_L5
rational_tick_divider_L4:
; return
    ret
    jp rational_tick_divider_L6
rational_tick_divider_L5:
rational_tick_divider_L6:
; if PHASE >= DENOMINATOR:
    ld a,(PHASE)
    ld b,a
    ld a,(DENOMINATOR)
    ld c,a
    ld a,b
    cp c
    jp nc,rational_tick_divider_L7
    jp rational_tick_divider_L8
rational_tick_divider_L7:
; return
    ret
    jp rational_tick_divider_L9
rational_tick_divider_L8:
rational_tick_divider_L9:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = DENOMINATOR - NUMERATOR
    ld a,(DENOMINATOR)
    ld b,a
    ld a,(NUMERATOR)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
; if PHASE >= T0:
    ld a,(PHASE)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp nc,rational_tick_divider_L10
    jp rational_tick_divider_L11
rational_tick_divider_L10:
; PHASE = PHASE - T0
    ld a,(PHASE)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    sub c
    ld (PHASE),a
; FIRED = 1
    ld a,1
    ld (FIRED),a
    jp rational_tick_divider_L12
rational_tick_divider_L11:
; PHASE = PHASE + NUMERATOR
    ld a,(PHASE)
    ld b,a
    ld a,(NUMERATOR)
    ld c,a
    ld a,b
    add a,c
    ld (PHASE),a
rational_tick_divider_L12:
    ret
component_end:
