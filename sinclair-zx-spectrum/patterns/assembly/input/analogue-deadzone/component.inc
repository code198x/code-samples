; SPDX-License-Identifier: MIT
; Turn an Analogue Axis into Intent. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
analogue_deadzone_init:
    ld a,0
    ld (SAMPLE),a
    ld (CENTRE),a
    ld (RADIUS),a
    ld (DIRECTION),a
    ld (MAGNITUDE),a
    ld (VALID),a
    ld (T0),a
    ret
analogue_deadzone_step:
; DIRECTION = 0
    ld a,0
    ld (DIRECTION),a
; MAGNITUDE = 0
    ld a,0
    ld (MAGNITUDE),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if RADIUS >= 128:
    ld a,(RADIUS)
    cp 128
    jp nc,analogue_deadzone_L1
    jp analogue_deadzone_L2
analogue_deadzone_L1:
; return
    ret
    jp analogue_deadzone_L3
analogue_deadzone_L2:
analogue_deadzone_L3:
; VALID = 1
    ld a,1
    ld (VALID),a
; if SAMPLE >= CENTRE:
    ld a,(SAMPLE)
    ld b,a
    ld a,(CENTRE)
    ld c,a
    ld a,b
    cp c
    jp nc,analogue_deadzone_L4
    jp analogue_deadzone_L5
analogue_deadzone_L4:
; T0 = SAMPLE - CENTRE
    ld a,(SAMPLE)
    ld b,a
    ld a,(CENTRE)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
; if T0 > RADIUS:
    ld a,(T0)
    ld b,a
    ld a,(RADIUS)
    ld c,a
    ld a,b
    cp c
    jp z,analogue_deadzone_L8
    jp nc,analogue_deadzone_L7
    jp analogue_deadzone_L8
analogue_deadzone_L7:
; MAGNITUDE = T0 - RADIUS
    ld a,(T0)
    ld b,a
    ld a,(RADIUS)
    ld c,a
    ld a,b
    sub c
    ld (MAGNITUDE),a
; DIRECTION = 2
    ld a,2
    ld (DIRECTION),a
    jp analogue_deadzone_L9
analogue_deadzone_L8:
analogue_deadzone_L9:
    jp analogue_deadzone_L6
analogue_deadzone_L5:
; T0 = CENTRE - SAMPLE
    ld a,(CENTRE)
    ld b,a
    ld a,(SAMPLE)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
; if T0 > RADIUS:
    ld a,(T0)
    ld b,a
    ld a,(RADIUS)
    ld c,a
    ld a,b
    cp c
    jp z,analogue_deadzone_L11
    jp nc,analogue_deadzone_L10
    jp analogue_deadzone_L11
analogue_deadzone_L10:
; MAGNITUDE = T0 - RADIUS
    ld a,(T0)
    ld b,a
    ld a,(RADIUS)
    ld c,a
    ld a,b
    sub c
    ld (MAGNITUDE),a
; DIRECTION = 1
    ld a,1
    ld (DIRECTION),a
    jp analogue_deadzone_L12
analogue_deadzone_L11:
analogue_deadzone_L12:
analogue_deadzone_L6:
    ret
component_end:
