; SPDX-License-Identifier: MIT
; Project World Points into a Viewport. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
viewport_world_transform_init:
    move.b #0,d0
    move.b d0,SCREEN_X
    move.b d0,SCREEN_Y
    move.b d0,VISIBLE
    move.b d0,VALID
    move.b d0,WORLD_X_LO
    move.b d0,WORLD_X_HI
    move.b d0,WORLD_Y_LO
    move.b d0,WORLD_Y_HI
    move.b d0,CAMERA_X_LO
    move.b d0,CAMERA_X_HI
    move.b d0,CAMERA_Y_LO
    move.b d0,CAMERA_Y_HI
    move.b d0,WIDTH
    move.b d0,HEIGHT
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    rts
viewport_world_transform_step:
; SCREEN_X = 0
    move.b #0,d0
    move.b d0,SCREEN_X
; SCREEN_Y = 0
    move.b #0,d0
    move.b d0,SCREEN_Y
; VISIBLE = 0
    move.b #0,d0
    move.b d0,VISIBLE
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if WIDTH == 0:
    move.b WIDTH,d0
    cmp.b #0,d0
    beq viewport_world_transform_L1
    jmp viewport_world_transform_L2
viewport_world_transform_L1:
; return
    rts
    jmp viewport_world_transform_L3
viewport_world_transform_L2:
viewport_world_transform_L3:
; if HEIGHT == 0:
    move.b HEIGHT,d0
    cmp.b #0,d0
    beq viewport_world_transform_L4
    jmp viewport_world_transform_L5
viewport_world_transform_L4:
; return
    rts
    jmp viewport_world_transform_L6
viewport_world_transform_L5:
viewport_world_transform_L6:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if WORLD_X_HI < CAMERA_X_HI:
    move.b WORLD_X_HI,d0
    move.b CAMERA_X_HI,d1
    cmp.b d1,d0
    bcs viewport_world_transform_L7
    jmp viewport_world_transform_L8
viewport_world_transform_L7:
; return
    rts
    jmp viewport_world_transform_L9
viewport_world_transform_L8:
viewport_world_transform_L9:
; if WORLD_X_HI == CAMERA_X_HI:
    move.b WORLD_X_HI,d0
    move.b CAMERA_X_HI,d1
    cmp.b d1,d0
    beq viewport_world_transform_L10
    jmp viewport_world_transform_L11
viewport_world_transform_L10:
; if WORLD_X_LO < CAMERA_X_LO:
    move.b WORLD_X_LO,d0
    move.b CAMERA_X_LO,d1
    cmp.b d1,d0
    bcs viewport_world_transform_L13
    jmp viewport_world_transform_L14
viewport_world_transform_L13:
; return
    rts
    jmp viewport_world_transform_L15
viewport_world_transform_L14:
viewport_world_transform_L15:
    jmp viewport_world_transform_L12
viewport_world_transform_L11:
viewport_world_transform_L12:
; if WORLD_Y_HI < CAMERA_Y_HI:
    move.b WORLD_Y_HI,d0
    move.b CAMERA_Y_HI,d1
    cmp.b d1,d0
    bcs viewport_world_transform_L16
    jmp viewport_world_transform_L17
viewport_world_transform_L16:
; return
    rts
    jmp viewport_world_transform_L18
viewport_world_transform_L17:
viewport_world_transform_L18:
; if WORLD_Y_HI == CAMERA_Y_HI:
    move.b WORLD_Y_HI,d0
    move.b CAMERA_Y_HI,d1
    cmp.b d1,d0
    beq viewport_world_transform_L19
    jmp viewport_world_transform_L20
viewport_world_transform_L19:
; if WORLD_Y_LO < CAMERA_Y_LO:
    move.b WORLD_Y_LO,d0
    move.b CAMERA_Y_LO,d1
    cmp.b d1,d0
    bcs viewport_world_transform_L22
    jmp viewport_world_transform_L23
viewport_world_transform_L22:
; return
    rts
    jmp viewport_world_transform_L24
viewport_world_transform_L23:
viewport_world_transform_L24:
    jmp viewport_world_transform_L21
viewport_world_transform_L20:
viewport_world_transform_L21:
; T0 = WORLD_X_LO - CAMERA_X_LO
    move.b WORLD_X_LO,d0
    move.b CAMERA_X_LO,d1
    sub.b d1,d0
    move.b d0,T0
; T1 = WORLD_X_HI - CAMERA_X_HI
    move.b WORLD_X_HI,d0
    move.b CAMERA_X_HI,d1
    sub.b d1,d0
    move.b d0,T1
; if WORLD_X_LO < CAMERA_X_LO:
    move.b WORLD_X_LO,d0
    move.b CAMERA_X_LO,d1
    cmp.b d1,d0
    bcs viewport_world_transform_L25
    jmp viewport_world_transform_L26
viewport_world_transform_L25:
; T1 = T1 - 1
    move.b T1,d0
    sub.b #1,d0
    move.b d0,T1
    jmp viewport_world_transform_L27
viewport_world_transform_L26:
viewport_world_transform_L27:
; if T1 != 0:
    move.b T1,d0
    cmp.b #0,d0
    bne viewport_world_transform_L28
    jmp viewport_world_transform_L29
viewport_world_transform_L28:
; return
    rts
    jmp viewport_world_transform_L30
viewport_world_transform_L29:
viewport_world_transform_L30:
; if T0 >= WIDTH:
    move.b T0,d0
    move.b WIDTH,d1
    cmp.b d1,d0
    bcc viewport_world_transform_L31
    jmp viewport_world_transform_L32
viewport_world_transform_L31:
; return
    rts
    jmp viewport_world_transform_L33
viewport_world_transform_L32:
viewport_world_transform_L33:
; T2 = WORLD_Y_LO - CAMERA_Y_LO
    move.b WORLD_Y_LO,d0
    move.b CAMERA_Y_LO,d1
    sub.b d1,d0
    move.b d0,T2
; T3 = WORLD_Y_HI - CAMERA_Y_HI
    move.b WORLD_Y_HI,d0
    move.b CAMERA_Y_HI,d1
    sub.b d1,d0
    move.b d0,T3
; if WORLD_Y_LO < CAMERA_Y_LO:
    move.b WORLD_Y_LO,d0
    move.b CAMERA_Y_LO,d1
    cmp.b d1,d0
    bcs viewport_world_transform_L34
    jmp viewport_world_transform_L35
viewport_world_transform_L34:
; T3 = T3 - 1
    move.b T3,d0
    sub.b #1,d0
    move.b d0,T3
    jmp viewport_world_transform_L36
viewport_world_transform_L35:
viewport_world_transform_L36:
; if T3 != 0:
    move.b T3,d0
    cmp.b #0,d0
    bne viewport_world_transform_L37
    jmp viewport_world_transform_L38
viewport_world_transform_L37:
; return
    rts
    jmp viewport_world_transform_L39
viewport_world_transform_L38:
viewport_world_transform_L39:
; if T2 >= HEIGHT:
    move.b T2,d0
    move.b HEIGHT,d1
    cmp.b d1,d0
    bcc viewport_world_transform_L40
    jmp viewport_world_transform_L41
viewport_world_transform_L40:
; return
    rts
    jmp viewport_world_transform_L42
viewport_world_transform_L41:
viewport_world_transform_L42:
; SCREEN_X = T0
    move.b T0,d0
    move.b d0,SCREEN_X
; SCREEN_Y = T2
    move.b T2,d0
    move.b d0,SCREEN_Y
; VISIBLE = 1
    move.b #1,d0
    move.b d0,VISIBLE
    rts
component_end:
