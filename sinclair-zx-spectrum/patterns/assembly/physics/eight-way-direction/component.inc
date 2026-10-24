; SPDX-License-Identifier: MIT
; Choose an Eight-way Direction. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
eight_way_direction_init:
    ld a,0
    ld (DIRECTION),a
    ld (DX),a
    ld (DY),a
    ld (FROM_X),a
    ld (FROM_Y),a
    ld (TO_X),a
    ld (TO_Y),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ret
eight_way_direction_step:
; T0 = 0
    ld a,0
    ld (T0),a
; T1 = 0
    ld a,0
    ld (T1),a
; if TO_X >= FROM_X:
    ld a,(TO_X)
    ld b,a
    ld a,(FROM_X)
    ld c,a
    ld a,b
    cp c
    jp nc,eight_way_direction_L1
    jp eight_way_direction_L2
eight_way_direction_L1:
; DX = TO_X - FROM_X
    ld a,(TO_X)
    ld b,a
    ld a,(FROM_X)
    ld c,a
    ld a,b
    sub c
    ld (DX),a
    jp eight_way_direction_L3
eight_way_direction_L2:
; DX = FROM_X - TO_X
    ld a,(FROM_X)
    ld b,a
    ld a,(TO_X)
    ld c,a
    ld a,b
    sub c
    ld (DX),a
; T0 = 1
    ld a,1
    ld (T0),a
eight_way_direction_L3:
; if TO_Y >= FROM_Y:
    ld a,(TO_Y)
    ld b,a
    ld a,(FROM_Y)
    ld c,a
    ld a,b
    cp c
    jp nc,eight_way_direction_L4
    jp eight_way_direction_L5
eight_way_direction_L4:
; DY = TO_Y - FROM_Y
    ld a,(TO_Y)
    ld b,a
    ld a,(FROM_Y)
    ld c,a
    ld a,b
    sub c
    ld (DY),a
    jp eight_way_direction_L6
eight_way_direction_L5:
; DY = FROM_Y - TO_Y
    ld a,(FROM_Y)
    ld b,a
    ld a,(TO_Y)
    ld c,a
    ld a,b
    sub c
    ld (DY),a
; T1 = 1
    ld a,1
    ld (T1),a
eight_way_direction_L6:
; DIRECTION = 0
    ld a,0
    ld (DIRECTION),a
; if DX == 0:
    ld a,(DX)
    cp 0
    jp z,eight_way_direction_L7
    jp eight_way_direction_L8
eight_way_direction_L7:
; if DY == 0:
    ld a,(DY)
    cp 0
    jp z,eight_way_direction_L10
    jp eight_way_direction_L11
eight_way_direction_L10:
; return
    ret
    jp eight_way_direction_L12
eight_way_direction_L11:
eight_way_direction_L12:
    jp eight_way_direction_L9
eight_way_direction_L8:
eight_way_direction_L9:
; T2 = DY >> 1
    ld a,(DY)
    srl a
    ld (T2),a
; if DX <= T2:
    ld a,(DX)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    cp c
    jp c,eight_way_direction_L13
    jp z,eight_way_direction_L13
    jp eight_way_direction_L14
eight_way_direction_L13:
; DIRECTION = 5
    ld a,5
    ld (DIRECTION),a
; if T1 != 0:
    ld a,(T1)
    cp 0
    jp nz,eight_way_direction_L16
    jp eight_way_direction_L17
eight_way_direction_L16:
; DIRECTION = 1
    ld a,1
    ld (DIRECTION),a
    jp eight_way_direction_L18
eight_way_direction_L17:
eight_way_direction_L18:
; return
    ret
    jp eight_way_direction_L15
eight_way_direction_L14:
eight_way_direction_L15:
; T2 = DX >> 1
    ld a,(DX)
    srl a
    ld (T2),a
; if DY <= T2:
    ld a,(DY)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    cp c
    jp c,eight_way_direction_L19
    jp z,eight_way_direction_L19
    jp eight_way_direction_L20
eight_way_direction_L19:
; DIRECTION = 3
    ld a,3
    ld (DIRECTION),a
; if T0 != 0:
    ld a,(T0)
    cp 0
    jp nz,eight_way_direction_L22
    jp eight_way_direction_L23
eight_way_direction_L22:
; DIRECTION = 7
    ld a,7
    ld (DIRECTION),a
    jp eight_way_direction_L24
eight_way_direction_L23:
eight_way_direction_L24:
; return
    ret
    jp eight_way_direction_L21
eight_way_direction_L20:
eight_way_direction_L21:
; DIRECTION = 4
    ld a,4
    ld (DIRECTION),a
; if T0 != 0:
    ld a,(T0)
    cp 0
    jp nz,eight_way_direction_L25
    jp eight_way_direction_L26
eight_way_direction_L25:
; DIRECTION = 6
    ld a,6
    ld (DIRECTION),a
    jp eight_way_direction_L27
eight_way_direction_L26:
eight_way_direction_L27:
; if T1 != 0:
    ld a,(T1)
    cp 0
    jp nz,eight_way_direction_L28
    jp eight_way_direction_L29
eight_way_direction_L28:
; DIRECTION = 2
    ld a,2
    ld (DIRECTION),a
; if T0 != 0:
    ld a,(T0)
    cp 0
    jp nz,eight_way_direction_L31
    jp eight_way_direction_L32
eight_way_direction_L31:
; DIRECTION = 8
    ld a,8
    ld (DIRECTION),a
    jp eight_way_direction_L33
eight_way_direction_L32:
eight_way_direction_L33:
    jp eight_way_direction_L30
eight_way_direction_L29:
eight_way_direction_L30:
    ret
component_end:
