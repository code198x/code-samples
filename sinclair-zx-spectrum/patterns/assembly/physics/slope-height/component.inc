; SPDX-License-Identifier: MIT
; Query a Small Slope Height Profile. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
slope_height_init:
    ld a,0
    ld (LOCAL_X),a
    ld (BASE_Y),a
    ld (MIRROR),a
    ld (SURFACE),a
    ld (VALID),a
    ld (H0),a
    ld (H1),a
    ld (H2),a
    ld (H3),a
    ld (H4),a
    ld (H5),a
    ld (H6),a
    ld (H7),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ret
slope_height_step:
; SURFACE = 255
    ld a,255
    ld (SURFACE),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if LOCAL_X >= 8:
    ld a,(LOCAL_X)
    cp 8
    jp nc,slope_height_L1
    jp slope_height_L2
slope_height_L1:
; return
    ret
    jp slope_height_L3
slope_height_L2:
slope_height_L3:
; T0 = LOCAL_X
    ld a,(LOCAL_X)
    ld (T0),a
; if MIRROR != 0:
    ld a,(MIRROR)
    cp 0
    jp nz,slope_height_L4
    jp slope_height_L5
slope_height_L4:
; T0 = 7 - T0
    ld a,7
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
    jp slope_height_L6
slope_height_L5:
slope_height_L6:
; T1 = H[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,H0
    add hl,de
    ld a,(hl)
    ld (T1),a
; T2 = 255 - BASE_Y
    ld a,255
    ld b,a
    ld a,(BASE_Y)
    ld c,a
    ld a,b
    sub c
    ld (T2),a
; if T1 > T2:
    ld a,(T1)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    cp c
    jp z,slope_height_L8
    jp nc,slope_height_L7
    jp slope_height_L8
slope_height_L7:
; return
    ret
    jp slope_height_L9
slope_height_L8:
slope_height_L9:
; SURFACE = BASE_Y + T1
    ld a,(BASE_Y)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    add a,c
    ld (SURFACE),a
; VALID = 1
    ld a,1
    ld (VALID),a
    ret
component_end:
