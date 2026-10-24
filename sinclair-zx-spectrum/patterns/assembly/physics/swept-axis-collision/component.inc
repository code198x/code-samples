; SPDX-License-Identifier: MIT
; Sweep an Interval Along One Axis. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
swept_axis_collision_init:
    ld a,0
    ld (POSITION),a
    ld (HIT),a
    ld (VALID),a
    ld (OLD_POSITION),a
    ld (TARGET),a
    ld (SIZE),a
    ld (WALL_START),a
    ld (WALL_END),a
    ld (T0),a
    ld (T1),a
    ret
swept_axis_collision_step:
; POSITION = OLD_POSITION
    ld a,(OLD_POSITION)
    ld (POSITION),a
; HIT = 0
    ld a,0
    ld (HIT),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if SIZE == 0:
    ld a,(SIZE)
    cp 0
    jp z,swept_axis_collision_L1
    jp swept_axis_collision_L2
swept_axis_collision_L1:
; return
    ret
    jp swept_axis_collision_L3
swept_axis_collision_L2:
swept_axis_collision_L3:
; if WALL_START >= WALL_END:
    ld a,(WALL_START)
    ld b,a
    ld a,(WALL_END)
    ld c,a
    ld a,b
    cp c
    jp nc,swept_axis_collision_L4
    jp swept_axis_collision_L5
swept_axis_collision_L4:
; return
    ret
    jp swept_axis_collision_L6
swept_axis_collision_L5:
swept_axis_collision_L6:
; T0 = OLD_POSITION + SIZE
    ld a,(OLD_POSITION)
    ld b,a
    ld a,(SIZE)
    ld c,a
    ld a,b
    add a,c
    ld (T0),a
; if T0 < OLD_POSITION:
    ld a,(T0)
    ld b,a
    ld a,(OLD_POSITION)
    ld c,a
    ld a,b
    cp c
    jp c,swept_axis_collision_L7
    jp swept_axis_collision_L8
swept_axis_collision_L7:
; return
    ret
    jp swept_axis_collision_L9
swept_axis_collision_L8:
swept_axis_collision_L9:
; T1 = TARGET + SIZE
    ld a,(TARGET)
    ld b,a
    ld a,(SIZE)
    ld c,a
    ld a,b
    add a,c
    ld (T1),a
; if T1 < TARGET:
    ld a,(T1)
    ld b,a
    ld a,(TARGET)
    ld c,a
    ld a,b
    cp c
    jp c,swept_axis_collision_L10
    jp swept_axis_collision_L11
swept_axis_collision_L10:
; return
    ret
    jp swept_axis_collision_L12
swept_axis_collision_L11:
swept_axis_collision_L12:
; if OLD_POSITION < WALL_END:
    ld a,(OLD_POSITION)
    ld b,a
    ld a,(WALL_END)
    ld c,a
    ld a,b
    cp c
    jp c,swept_axis_collision_L13
    jp swept_axis_collision_L14
swept_axis_collision_L13:
; if T0 > WALL_START:
    ld a,(T0)
    ld b,a
    ld a,(WALL_START)
    ld c,a
    ld a,b
    cp c
    jp z,swept_axis_collision_L17
    jp nc,swept_axis_collision_L16
    jp swept_axis_collision_L17
swept_axis_collision_L16:
; return
    ret
    jp swept_axis_collision_L18
swept_axis_collision_L17:
swept_axis_collision_L18:
    jp swept_axis_collision_L15
swept_axis_collision_L14:
swept_axis_collision_L15:
; VALID = 1
    ld a,1
    ld (VALID),a
; POSITION = TARGET
    ld a,(TARGET)
    ld (POSITION),a
; if TARGET > OLD_POSITION:
    ld a,(TARGET)
    ld b,a
    ld a,(OLD_POSITION)
    ld c,a
    ld a,b
    cp c
    jp z,swept_axis_collision_L20
    jp nc,swept_axis_collision_L19
    jp swept_axis_collision_L20
swept_axis_collision_L19:
; if T0 <= WALL_START:
    ld a,(T0)
    ld b,a
    ld a,(WALL_START)
    ld c,a
    ld a,b
    cp c
    jp c,swept_axis_collision_L22
    jp z,swept_axis_collision_L22
    jp swept_axis_collision_L23
swept_axis_collision_L22:
; if T1 >= WALL_START:
    ld a,(T1)
    ld b,a
    ld a,(WALL_START)
    ld c,a
    ld a,b
    cp c
    jp nc,swept_axis_collision_L25
    jp swept_axis_collision_L26
swept_axis_collision_L25:
; POSITION = WALL_START - SIZE
    ld a,(WALL_START)
    ld b,a
    ld a,(SIZE)
    ld c,a
    ld a,b
    sub c
    ld (POSITION),a
; HIT = 1
    ld a,1
    ld (HIT),a
    jp swept_axis_collision_L27
swept_axis_collision_L26:
swept_axis_collision_L27:
    jp swept_axis_collision_L24
swept_axis_collision_L23:
swept_axis_collision_L24:
    jp swept_axis_collision_L21
swept_axis_collision_L20:
swept_axis_collision_L21:
; if TARGET < OLD_POSITION:
    ld a,(TARGET)
    ld b,a
    ld a,(OLD_POSITION)
    ld c,a
    ld a,b
    cp c
    jp c,swept_axis_collision_L28
    jp swept_axis_collision_L29
swept_axis_collision_L28:
; if OLD_POSITION >= WALL_END:
    ld a,(OLD_POSITION)
    ld b,a
    ld a,(WALL_END)
    ld c,a
    ld a,b
    cp c
    jp nc,swept_axis_collision_L31
    jp swept_axis_collision_L32
swept_axis_collision_L31:
; if TARGET <= WALL_END:
    ld a,(TARGET)
    ld b,a
    ld a,(WALL_END)
    ld c,a
    ld a,b
    cp c
    jp c,swept_axis_collision_L34
    jp z,swept_axis_collision_L34
    jp swept_axis_collision_L35
swept_axis_collision_L34:
; POSITION = WALL_END
    ld a,(WALL_END)
    ld (POSITION),a
; HIT = 1
    ld a,1
    ld (HIT),a
    jp swept_axis_collision_L36
swept_axis_collision_L35:
swept_axis_collision_L36:
    jp swept_axis_collision_L33
swept_axis_collision_L32:
swept_axis_collision_L33:
    jp swept_axis_collision_L30
swept_axis_collision_L29:
swept_axis_collision_L30:
    ret
component_end:
