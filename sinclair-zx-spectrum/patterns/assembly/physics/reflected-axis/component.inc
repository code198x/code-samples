; SPDX-License-Identifier: MIT
; Reflect Movement at Axis Bounds. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
reflected_axis_init:
    ld a,0
    ld (POSITION),a
    ld (MINIMUM),a
    ld (MAXIMUM),a
    ld (DISTANCE),a
    ld (DIRECTION),a
    ld (BOUNCES),a
    ld (VALID),a
    ld (T0),a
    ret
reflected_axis_step:
; BOUNCES = 0
    ld a,0
    ld (BOUNCES),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if MINIMUM >= MAXIMUM:
    ld a,(MINIMUM)
    ld b,a
    ld a,(MAXIMUM)
    ld c,a
    ld a,b
    cp c
    jp nc,reflected_axis_L1
    jp reflected_axis_L2
reflected_axis_L1:
; return
    ret
    jp reflected_axis_L3
reflected_axis_L2:
reflected_axis_L3:
; if POSITION < MINIMUM:
    ld a,(POSITION)
    ld b,a
    ld a,(MINIMUM)
    ld c,a
    ld a,b
    cp c
    jp c,reflected_axis_L4
    jp reflected_axis_L5
reflected_axis_L4:
; return
    ret
    jp reflected_axis_L6
reflected_axis_L5:
reflected_axis_L6:
; if POSITION > MAXIMUM:
    ld a,(POSITION)
    ld b,a
    ld a,(MAXIMUM)
    ld c,a
    ld a,b
    cp c
    jp z,reflected_axis_L8
    jp nc,reflected_axis_L7
    jp reflected_axis_L8
reflected_axis_L7:
; return
    ret
    jp reflected_axis_L9
reflected_axis_L8:
reflected_axis_L9:
; if DIRECTION >= 2:
    ld a,(DIRECTION)
    cp 2
    jp nc,reflected_axis_L10
    jp reflected_axis_L11
reflected_axis_L10:
; return
    ret
    jp reflected_axis_L12
reflected_axis_L11:
reflected_axis_L12:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = DISTANCE
    ld a,(DISTANCE)
    ld (T0),a
; while T0 != 0:
reflected_axis_L13:
    ld a,(T0)
    cp 0
    jp nz,reflected_axis_L14
    jp reflected_axis_L15
reflected_axis_L14:
; if DIRECTION == 0:
    ld a,(DIRECTION)
    cp 0
    jp z,reflected_axis_L16
    jp reflected_axis_L17
reflected_axis_L16:
; if POSITION == MINIMUM:
    ld a,(POSITION)
    ld b,a
    ld a,(MINIMUM)
    ld c,a
    ld a,b
    cp c
    jp z,reflected_axis_L19
    jp reflected_axis_L20
reflected_axis_L19:
; DIRECTION = 1
    ld a,1
    ld (DIRECTION),a
; BOUNCES = BOUNCES + 1
    ld a,(BOUNCES)
    add a,1
    ld (BOUNCES),a
    jp reflected_axis_L21
reflected_axis_L20:
reflected_axis_L21:
    jp reflected_axis_L18
reflected_axis_L17:
; if POSITION == MAXIMUM:
    ld a,(POSITION)
    ld b,a
    ld a,(MAXIMUM)
    ld c,a
    ld a,b
    cp c
    jp z,reflected_axis_L22
    jp reflected_axis_L23
reflected_axis_L22:
; DIRECTION = 0
    ld a,0
    ld (DIRECTION),a
; BOUNCES = BOUNCES + 1
    ld a,(BOUNCES)
    add a,1
    ld (BOUNCES),a
    jp reflected_axis_L24
reflected_axis_L23:
reflected_axis_L24:
reflected_axis_L18:
; if DIRECTION == 0:
    ld a,(DIRECTION)
    cp 0
    jp z,reflected_axis_L25
    jp reflected_axis_L26
reflected_axis_L25:
; POSITION = POSITION - 1
    ld a,(POSITION)
    sub 1
    ld (POSITION),a
    jp reflected_axis_L27
reflected_axis_L26:
; POSITION = POSITION + 1
    ld a,(POSITION)
    add a,1
    ld (POSITION),a
reflected_axis_L27:
; T0 = T0 - 1
    ld a,(T0)
    sub 1
    ld (T0),a
    jp reflected_axis_L13
reflected_axis_L15:
    ret
component_end:
