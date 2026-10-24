; SPDX-License-Identifier: MIT
; Aim a Projectile with Bounded Integer Speed. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
aimed_projectile_init:
    ld a,0
    ld (VELOCITY_X),a
    ld (VELOCITY_Y),a
    ld (VALID),a
    ld (ORIGIN_X),a
    ld (ORIGIN_Y),a
    ld (TARGET_X),a
    ld (TARGET_Y),a
    ld (SPEED),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ld (T4),a
    ld (T5),a
    ld (T6),a
    ld (T7),a
    ld (T8),a
    ld (T9),a
    ld (T10),a
    ret
aimed_projectile_step:
; VELOCITY_X = 0
    ld a,0
    ld (VELOCITY_X),a
; VELOCITY_Y = 0
    ld a,0
    ld (VELOCITY_Y),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if SPEED > 15:
    ld a,(SPEED)
    cp 15
    jp z,aimed_projectile_L2
    jp nc,aimed_projectile_L1
    jp aimed_projectile_L2
aimed_projectile_L1:
; return
    ret
    jp aimed_projectile_L3
aimed_projectile_L2:
aimed_projectile_L3:
; VALID = 1
    ld a,1
    ld (VALID),a
; if TARGET_X >= ORIGIN_X:
    ld a,(TARGET_X)
    ld b,a
    ld a,(ORIGIN_X)
    ld c,a
    ld a,b
    cp c
    jp nc,aimed_projectile_L4
    jp aimed_projectile_L5
aimed_projectile_L4:
; T0 = TARGET_X - ORIGIN_X
    ld a,(TARGET_X)
    ld b,a
    ld a,(ORIGIN_X)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
; T2 = 0
    ld a,0
    ld (T2),a
    jp aimed_projectile_L6
aimed_projectile_L5:
; T0 = ORIGIN_X - TARGET_X
    ld a,(ORIGIN_X)
    ld b,a
    ld a,(TARGET_X)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
; T2 = 1
    ld a,1
    ld (T2),a
aimed_projectile_L6:
; if TARGET_Y >= ORIGIN_Y:
    ld a,(TARGET_Y)
    ld b,a
    ld a,(ORIGIN_Y)
    ld c,a
    ld a,b
    cp c
    jp nc,aimed_projectile_L7
    jp aimed_projectile_L8
aimed_projectile_L7:
; T1 = TARGET_Y - ORIGIN_Y
    ld a,(TARGET_Y)
    ld b,a
    ld a,(ORIGIN_Y)
    ld c,a
    ld a,b
    sub c
    ld (T1),a
; T3 = 0
    ld a,0
    ld (T3),a
    jp aimed_projectile_L9
aimed_projectile_L8:
; T1 = ORIGIN_Y - TARGET_Y
    ld a,(ORIGIN_Y)
    ld b,a
    ld a,(TARGET_Y)
    ld c,a
    ld a,b
    sub c
    ld (T1),a
; T3 = 1
    ld a,1
    ld (T3),a
aimed_projectile_L9:
; T4 = T0
    ld a,(T0)
    ld (T4),a
; if T1 > T4:
    ld a,(T1)
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    cp c
    jp z,aimed_projectile_L11
    jp nc,aimed_projectile_L10
    jp aimed_projectile_L11
aimed_projectile_L10:
; T4 = T1
    ld a,(T1)
    ld (T4),a
    jp aimed_projectile_L12
aimed_projectile_L11:
aimed_projectile_L12:
; if T4 == 0:
    ld a,(T4)
    cp 0
    jp z,aimed_projectile_L13
    jp aimed_projectile_L14
aimed_projectile_L13:
; return
    ret
    jp aimed_projectile_L15
aimed_projectile_L14:
aimed_projectile_L15:
; T5 = 0
    ld a,0
    ld (T5),a
; T6 = 0
    ld a,0
    ld (T6),a
; T7 = 0
    ld a,0
    ld (T7),a
; T8 = 0
    ld a,0
    ld (T8),a
; T9 = 0
    ld a,0
    ld (T9),a
; while T5 < SPEED:
aimed_projectile_L16:
    ld a,(T5)
    ld b,a
    ld a,(SPEED)
    ld c,a
    ld a,b
    cp c
    jp c,aimed_projectile_L17
    jp aimed_projectile_L18
aimed_projectile_L17:
; T10 = T4 - T0
    ld a,(T4)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    sub c
    ld (T10),a
; if T6 >= T10:
    ld a,(T6)
    ld b,a
    ld a,(T10)
    ld c,a
    ld a,b
    cp c
    jp nc,aimed_projectile_L19
    jp aimed_projectile_L20
aimed_projectile_L19:
; T6 = T6 - T10
    ld a,(T6)
    ld b,a
    ld a,(T10)
    ld c,a
    ld a,b
    sub c
    ld (T6),a
; T7 = T7 + 1
    ld a,(T7)
    add a,1
    ld (T7),a
    jp aimed_projectile_L21
aimed_projectile_L20:
; T6 = T6 + T0
    ld a,(T6)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    add a,c
    ld (T6),a
aimed_projectile_L21:
; T10 = T4 - T1
    ld a,(T4)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    sub c
    ld (T10),a
; if T8 >= T10:
    ld a,(T8)
    ld b,a
    ld a,(T10)
    ld c,a
    ld a,b
    cp c
    jp nc,aimed_projectile_L22
    jp aimed_projectile_L23
aimed_projectile_L22:
; T8 = T8 - T10
    ld a,(T8)
    ld b,a
    ld a,(T10)
    ld c,a
    ld a,b
    sub c
    ld (T8),a
; T9 = T9 + 1
    ld a,(T9)
    add a,1
    ld (T9),a
    jp aimed_projectile_L24
aimed_projectile_L23:
; T8 = T8 + T1
    ld a,(T8)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    add a,c
    ld (T8),a
aimed_projectile_L24:
; T5 = T5 + 1
    ld a,(T5)
    add a,1
    ld (T5),a
    jp aimed_projectile_L16
aimed_projectile_L18:
; VELOCITY_X = T7
    ld a,(T7)
    ld (VELOCITY_X),a
; VELOCITY_Y = T9
    ld a,(T9)
    ld (VELOCITY_Y),a
; if T2 != 0:
    ld a,(T2)
    cp 0
    jp nz,aimed_projectile_L25
    jp aimed_projectile_L26
aimed_projectile_L25:
; VELOCITY_X = 0 - T7
    ld a,0
    ld b,a
    ld a,(T7)
    ld c,a
    ld a,b
    sub c
    ld (VELOCITY_X),a
    jp aimed_projectile_L27
aimed_projectile_L26:
aimed_projectile_L27:
; if T3 != 0:
    ld a,(T3)
    cp 0
    jp nz,aimed_projectile_L28
    jp aimed_projectile_L29
aimed_projectile_L28:
; VELOCITY_Y = 0 - T9
    ld a,0
    ld b,a
    ld a,(T9)
    ld c,a
    ld a,b
    sub c
    ld (VELOCITY_Y),a
    jp aimed_projectile_L30
aimed_projectile_L29:
aimed_projectile_L30:
    ret
component_end:
