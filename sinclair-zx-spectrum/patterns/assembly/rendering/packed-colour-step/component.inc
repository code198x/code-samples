; SPDX-License-Identifier: MIT
; Step Towards a Packed Colour. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
packed_colour_step_init:
    ld a,0
    ld (COLOUR),a
    ld (TARGET),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ld (T4),a
    ld (T5),a
    ret
packed_colour_step_step:
; T0 = COLOUR >> 5
    ld a,(COLOUR)
    srl a
    srl a
    srl a
    srl a
    srl a
    ld (T0),a
; T1 = TARGET >> 5
    ld a,(TARGET)
    srl a
    srl a
    srl a
    srl a
    srl a
    ld (T1),a
; if T0 < T1:
    ld a,(T0)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    cp c
    jp c,packed_colour_step_L1
    jp packed_colour_step_L2
packed_colour_step_L1:
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp packed_colour_step_L3
packed_colour_step_L2:
packed_colour_step_L3:
; if T0 > T1:
    ld a,(T0)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    cp c
    jp z,packed_colour_step_L5
    jp nc,packed_colour_step_L4
    jp packed_colour_step_L5
packed_colour_step_L4:
; T0 = T0 - 1
    ld a,(T0)
    sub 1
    ld (T0),a
    jp packed_colour_step_L6
packed_colour_step_L5:
packed_colour_step_L6:
; T2 = COLOUR >> 2
    ld a,(COLOUR)
    srl a
    srl a
    ld (T2),a
; T2 = T2 & 7
    ld a,(T2)
    and 7
    ld (T2),a
; T3 = TARGET >> 2
    ld a,(TARGET)
    srl a
    srl a
    ld (T3),a
; T3 = T3 & 7
    ld a,(T3)
    and 7
    ld (T3),a
; if T2 < T3:
    ld a,(T2)
    ld b,a
    ld a,(T3)
    ld c,a
    ld a,b
    cp c
    jp c,packed_colour_step_L7
    jp packed_colour_step_L8
packed_colour_step_L7:
; T2 = T2 + 1
    ld a,(T2)
    add a,1
    ld (T2),a
    jp packed_colour_step_L9
packed_colour_step_L8:
packed_colour_step_L9:
; if T2 > T3:
    ld a,(T2)
    ld b,a
    ld a,(T3)
    ld c,a
    ld a,b
    cp c
    jp z,packed_colour_step_L11
    jp nc,packed_colour_step_L10
    jp packed_colour_step_L11
packed_colour_step_L10:
; T2 = T2 - 1
    ld a,(T2)
    sub 1
    ld (T2),a
    jp packed_colour_step_L12
packed_colour_step_L11:
packed_colour_step_L12:
; T4 = COLOUR & 3
    ld a,(COLOUR)
    and 3
    ld (T4),a
; T5 = TARGET & 3
    ld a,(TARGET)
    and 3
    ld (T5),a
; if T4 < T5:
    ld a,(T4)
    ld b,a
    ld a,(T5)
    ld c,a
    ld a,b
    cp c
    jp c,packed_colour_step_L13
    jp packed_colour_step_L14
packed_colour_step_L13:
; T4 = T4 + 1
    ld a,(T4)
    add a,1
    ld (T4),a
    jp packed_colour_step_L15
packed_colour_step_L14:
packed_colour_step_L15:
; if T4 > T5:
    ld a,(T4)
    ld b,a
    ld a,(T5)
    ld c,a
    ld a,b
    cp c
    jp z,packed_colour_step_L17
    jp nc,packed_colour_step_L16
    jp packed_colour_step_L17
packed_colour_step_L16:
; T4 = T4 - 1
    ld a,(T4)
    sub 1
    ld (T4),a
    jp packed_colour_step_L18
packed_colour_step_L17:
packed_colour_step_L18:
; COLOUR = T0 << 5
    ld a,(T0)
    sla a
    sla a
    sla a
    sla a
    sla a
    ld (COLOUR),a
; T2 = T2 << 2
    ld a,(T2)
    sla a
    sla a
    ld (T2),a
; COLOUR = COLOUR | T2
    ld a,(COLOUR)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    or c
    ld (COLOUR),a
; COLOUR = COLOUR | T4
    ld a,(COLOUR)
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    or c
    ld (COLOUR),a
    ret
component_end:
