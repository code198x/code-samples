; SPDX-License-Identifier: MIT
; Project World Points into a Viewport. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
viewport_world_transform_init:
    ld a,0
    ld (SCREEN_X),a
    ld (SCREEN_Y),a
    ld (VISIBLE),a
    ld (VALID),a
    ld (WORLD_X_LO),a
    ld (WORLD_X_HI),a
    ld (WORLD_Y_LO),a
    ld (WORLD_Y_HI),a
    ld (CAMERA_X_LO),a
    ld (CAMERA_X_HI),a
    ld (CAMERA_Y_LO),a
    ld (CAMERA_Y_HI),a
    ld (WIDTH),a
    ld (HEIGHT),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ret
viewport_world_transform_step:
; SCREEN_X = 0
    ld a,0
    ld (SCREEN_X),a
; SCREEN_Y = 0
    ld a,0
    ld (SCREEN_Y),a
; VISIBLE = 0
    ld a,0
    ld (VISIBLE),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if WIDTH == 0:
    ld a,(WIDTH)
    cp 0
    jp z,viewport_world_transform_L1
    jp viewport_world_transform_L2
viewport_world_transform_L1:
; return
    ret
    jp viewport_world_transform_L3
viewport_world_transform_L2:
viewport_world_transform_L3:
; if HEIGHT == 0:
    ld a,(HEIGHT)
    cp 0
    jp z,viewport_world_transform_L4
    jp viewport_world_transform_L5
viewport_world_transform_L4:
; return
    ret
    jp viewport_world_transform_L6
viewport_world_transform_L5:
viewport_world_transform_L6:
; VALID = 1
    ld a,1
    ld (VALID),a
; if WORLD_X_HI < CAMERA_X_HI:
    ld a,(WORLD_X_HI)
    ld b,a
    ld a,(CAMERA_X_HI)
    ld c,a
    ld a,b
    cp c
    jp c,viewport_world_transform_L7
    jp viewport_world_transform_L8
viewport_world_transform_L7:
; return
    ret
    jp viewport_world_transform_L9
viewport_world_transform_L8:
viewport_world_transform_L9:
; if WORLD_X_HI == CAMERA_X_HI:
    ld a,(WORLD_X_HI)
    ld b,a
    ld a,(CAMERA_X_HI)
    ld c,a
    ld a,b
    cp c
    jp z,viewport_world_transform_L10
    jp viewport_world_transform_L11
viewport_world_transform_L10:
; if WORLD_X_LO < CAMERA_X_LO:
    ld a,(WORLD_X_LO)
    ld b,a
    ld a,(CAMERA_X_LO)
    ld c,a
    ld a,b
    cp c
    jp c,viewport_world_transform_L13
    jp viewport_world_transform_L14
viewport_world_transform_L13:
; return
    ret
    jp viewport_world_transform_L15
viewport_world_transform_L14:
viewport_world_transform_L15:
    jp viewport_world_transform_L12
viewport_world_transform_L11:
viewport_world_transform_L12:
; if WORLD_Y_HI < CAMERA_Y_HI:
    ld a,(WORLD_Y_HI)
    ld b,a
    ld a,(CAMERA_Y_HI)
    ld c,a
    ld a,b
    cp c
    jp c,viewport_world_transform_L16
    jp viewport_world_transform_L17
viewport_world_transform_L16:
; return
    ret
    jp viewport_world_transform_L18
viewport_world_transform_L17:
viewport_world_transform_L18:
; if WORLD_Y_HI == CAMERA_Y_HI:
    ld a,(WORLD_Y_HI)
    ld b,a
    ld a,(CAMERA_Y_HI)
    ld c,a
    ld a,b
    cp c
    jp z,viewport_world_transform_L19
    jp viewport_world_transform_L20
viewport_world_transform_L19:
; if WORLD_Y_LO < CAMERA_Y_LO:
    ld a,(WORLD_Y_LO)
    ld b,a
    ld a,(CAMERA_Y_LO)
    ld c,a
    ld a,b
    cp c
    jp c,viewport_world_transform_L22
    jp viewport_world_transform_L23
viewport_world_transform_L22:
; return
    ret
    jp viewport_world_transform_L24
viewport_world_transform_L23:
viewport_world_transform_L24:
    jp viewport_world_transform_L21
viewport_world_transform_L20:
viewport_world_transform_L21:
; T0 = WORLD_X_LO - CAMERA_X_LO
    ld a,(WORLD_X_LO)
    ld b,a
    ld a,(CAMERA_X_LO)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
; T1 = WORLD_X_HI - CAMERA_X_HI
    ld a,(WORLD_X_HI)
    ld b,a
    ld a,(CAMERA_X_HI)
    ld c,a
    ld a,b
    sub c
    ld (T1),a
; if WORLD_X_LO < CAMERA_X_LO:
    ld a,(WORLD_X_LO)
    ld b,a
    ld a,(CAMERA_X_LO)
    ld c,a
    ld a,b
    cp c
    jp c,viewport_world_transform_L25
    jp viewport_world_transform_L26
viewport_world_transform_L25:
; T1 = T1 - 1
    ld a,(T1)
    sub 1
    ld (T1),a
    jp viewport_world_transform_L27
viewport_world_transform_L26:
viewport_world_transform_L27:
; if T1 != 0:
    ld a,(T1)
    cp 0
    jp nz,viewport_world_transform_L28
    jp viewport_world_transform_L29
viewport_world_transform_L28:
; return
    ret
    jp viewport_world_transform_L30
viewport_world_transform_L29:
viewport_world_transform_L30:
; if T0 >= WIDTH:
    ld a,(T0)
    ld b,a
    ld a,(WIDTH)
    ld c,a
    ld a,b
    cp c
    jp nc,viewport_world_transform_L31
    jp viewport_world_transform_L32
viewport_world_transform_L31:
; return
    ret
    jp viewport_world_transform_L33
viewport_world_transform_L32:
viewport_world_transform_L33:
; T2 = WORLD_Y_LO - CAMERA_Y_LO
    ld a,(WORLD_Y_LO)
    ld b,a
    ld a,(CAMERA_Y_LO)
    ld c,a
    ld a,b
    sub c
    ld (T2),a
; T3 = WORLD_Y_HI - CAMERA_Y_HI
    ld a,(WORLD_Y_HI)
    ld b,a
    ld a,(CAMERA_Y_HI)
    ld c,a
    ld a,b
    sub c
    ld (T3),a
; if WORLD_Y_LO < CAMERA_Y_LO:
    ld a,(WORLD_Y_LO)
    ld b,a
    ld a,(CAMERA_Y_LO)
    ld c,a
    ld a,b
    cp c
    jp c,viewport_world_transform_L34
    jp viewport_world_transform_L35
viewport_world_transform_L34:
; T3 = T3 - 1
    ld a,(T3)
    sub 1
    ld (T3),a
    jp viewport_world_transform_L36
viewport_world_transform_L35:
viewport_world_transform_L36:
; if T3 != 0:
    ld a,(T3)
    cp 0
    jp nz,viewport_world_transform_L37
    jp viewport_world_transform_L38
viewport_world_transform_L37:
; return
    ret
    jp viewport_world_transform_L39
viewport_world_transform_L38:
viewport_world_transform_L39:
; if T2 >= HEIGHT:
    ld a,(T2)
    ld b,a
    ld a,(HEIGHT)
    ld c,a
    ld a,b
    cp c
    jp nc,viewport_world_transform_L40
    jp viewport_world_transform_L41
viewport_world_transform_L40:
; return
    ret
    jp viewport_world_transform_L42
viewport_world_transform_L41:
viewport_world_transform_L42:
; SCREEN_X = T0
    ld a,(T0)
    ld (SCREEN_X),a
; SCREEN_Y = T2
    ld a,(T2)
    ld (SCREEN_Y),a
; VISIBLE = 1
    ld a,1
    ld (VISIBLE),a
    ret
component_end:
