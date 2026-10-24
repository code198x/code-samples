; SPDX-License-Identifier: MIT
; Project World Points into a Viewport. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
viewport_world_transform_init:
    lda #0
    sta SCREEN_X
    sta SCREEN_Y
    sta VISIBLE
    sta VALID
    sta WORLD_X_LO
    sta WORLD_X_HI
    sta WORLD_Y_LO
    sta WORLD_Y_HI
    sta CAMERA_X_LO
    sta CAMERA_X_HI
    sta CAMERA_Y_LO
    sta CAMERA_Y_HI
    sta WIDTH
    sta HEIGHT
    sta T0
    sta T1
    sta T2
    sta T3
    rts
viewport_world_transform_step:
; SCREEN_X = 0
    lda #0
    sta SCREEN_X
; SCREEN_Y = 0
    lda #0
    sta SCREEN_Y
; VISIBLE = 0
    lda #0
    sta VISIBLE
; VALID = 0
    lda #0
    sta VALID
; if WIDTH == 0:
    lda WIDTH
    cmp #0
    beq viewport_world_transform_L4
viewport_world_transform_L5:
    jmp viewport_world_transform_L2
viewport_world_transform_L4:
    jmp viewport_world_transform_L1
viewport_world_transform_L1:
; return
    rts
    jmp viewport_world_transform_L3
viewport_world_transform_L2:
viewport_world_transform_L3:
; if HEIGHT == 0:
    lda HEIGHT
    cmp #0
    beq viewport_world_transform_L9
viewport_world_transform_L10:
    jmp viewport_world_transform_L7
viewport_world_transform_L9:
    jmp viewport_world_transform_L6
viewport_world_transform_L6:
; return
    rts
    jmp viewport_world_transform_L8
viewport_world_transform_L7:
viewport_world_transform_L8:
; VALID = 1
    lda #1
    sta VALID
; if WORLD_X_HI < CAMERA_X_HI:
    lda WORLD_X_HI
    cmp CAMERA_X_HI
    bcc viewport_world_transform_L14
viewport_world_transform_L15:
    jmp viewport_world_transform_L12
viewport_world_transform_L14:
    jmp viewport_world_transform_L11
viewport_world_transform_L11:
; return
    rts
    jmp viewport_world_transform_L13
viewport_world_transform_L12:
viewport_world_transform_L13:
; if WORLD_X_HI == CAMERA_X_HI:
    lda WORLD_X_HI
    cmp CAMERA_X_HI
    beq viewport_world_transform_L19
viewport_world_transform_L20:
    jmp viewport_world_transform_L17
viewport_world_transform_L19:
    jmp viewport_world_transform_L16
viewport_world_transform_L16:
; if WORLD_X_LO < CAMERA_X_LO:
    lda WORLD_X_LO
    cmp CAMERA_X_LO
    bcc viewport_world_transform_L24
viewport_world_transform_L25:
    jmp viewport_world_transform_L22
viewport_world_transform_L24:
    jmp viewport_world_transform_L21
viewport_world_transform_L21:
; return
    rts
    jmp viewport_world_transform_L23
viewport_world_transform_L22:
viewport_world_transform_L23:
    jmp viewport_world_transform_L18
viewport_world_transform_L17:
viewport_world_transform_L18:
; if WORLD_Y_HI < CAMERA_Y_HI:
    lda WORLD_Y_HI
    cmp CAMERA_Y_HI
    bcc viewport_world_transform_L29
viewport_world_transform_L30:
    jmp viewport_world_transform_L27
viewport_world_transform_L29:
    jmp viewport_world_transform_L26
viewport_world_transform_L26:
; return
    rts
    jmp viewport_world_transform_L28
viewport_world_transform_L27:
viewport_world_transform_L28:
; if WORLD_Y_HI == CAMERA_Y_HI:
    lda WORLD_Y_HI
    cmp CAMERA_Y_HI
    beq viewport_world_transform_L34
viewport_world_transform_L35:
    jmp viewport_world_transform_L32
viewport_world_transform_L34:
    jmp viewport_world_transform_L31
viewport_world_transform_L31:
; if WORLD_Y_LO < CAMERA_Y_LO:
    lda WORLD_Y_LO
    cmp CAMERA_Y_LO
    bcc viewport_world_transform_L39
viewport_world_transform_L40:
    jmp viewport_world_transform_L37
viewport_world_transform_L39:
    jmp viewport_world_transform_L36
viewport_world_transform_L36:
; return
    rts
    jmp viewport_world_transform_L38
viewport_world_transform_L37:
viewport_world_transform_L38:
    jmp viewport_world_transform_L33
viewport_world_transform_L32:
viewport_world_transform_L33:
; T0 = WORLD_X_LO - CAMERA_X_LO
    lda WORLD_X_LO
    sec
    sbc CAMERA_X_LO
    sta T0
; T1 = WORLD_X_HI - CAMERA_X_HI
    lda WORLD_X_HI
    sec
    sbc CAMERA_X_HI
    sta T1
; if WORLD_X_LO < CAMERA_X_LO:
    lda WORLD_X_LO
    cmp CAMERA_X_LO
    bcc viewport_world_transform_L44
viewport_world_transform_L45:
    jmp viewport_world_transform_L42
viewport_world_transform_L44:
    jmp viewport_world_transform_L41
viewport_world_transform_L41:
; T1 = T1 - 1
    lda T1
    sec
    sbc #1
    sta T1
    jmp viewport_world_transform_L43
viewport_world_transform_L42:
viewport_world_transform_L43:
; if T1 != 0:
    lda T1
    cmp #0
    bne viewport_world_transform_L49
viewport_world_transform_L50:
    jmp viewport_world_transform_L47
viewport_world_transform_L49:
    jmp viewport_world_transform_L46
viewport_world_transform_L46:
; return
    rts
    jmp viewport_world_transform_L48
viewport_world_transform_L47:
viewport_world_transform_L48:
; if T0 >= WIDTH:
    lda T0
    cmp WIDTH
    bcs viewport_world_transform_L54
viewport_world_transform_L55:
    jmp viewport_world_transform_L52
viewport_world_transform_L54:
    jmp viewport_world_transform_L51
viewport_world_transform_L51:
; return
    rts
    jmp viewport_world_transform_L53
viewport_world_transform_L52:
viewport_world_transform_L53:
; T2 = WORLD_Y_LO - CAMERA_Y_LO
    lda WORLD_Y_LO
    sec
    sbc CAMERA_Y_LO
    sta T2
; T3 = WORLD_Y_HI - CAMERA_Y_HI
    lda WORLD_Y_HI
    sec
    sbc CAMERA_Y_HI
    sta T3
; if WORLD_Y_LO < CAMERA_Y_LO:
    lda WORLD_Y_LO
    cmp CAMERA_Y_LO
    bcc viewport_world_transform_L59
viewport_world_transform_L60:
    jmp viewport_world_transform_L57
viewport_world_transform_L59:
    jmp viewport_world_transform_L56
viewport_world_transform_L56:
; T3 = T3 - 1
    lda T3
    sec
    sbc #1
    sta T3
    jmp viewport_world_transform_L58
viewport_world_transform_L57:
viewport_world_transform_L58:
; if T3 != 0:
    lda T3
    cmp #0
    bne viewport_world_transform_L64
viewport_world_transform_L65:
    jmp viewport_world_transform_L62
viewport_world_transform_L64:
    jmp viewport_world_transform_L61
viewport_world_transform_L61:
; return
    rts
    jmp viewport_world_transform_L63
viewport_world_transform_L62:
viewport_world_transform_L63:
; if T2 >= HEIGHT:
    lda T2
    cmp HEIGHT
    bcs viewport_world_transform_L69
viewport_world_transform_L70:
    jmp viewport_world_transform_L67
viewport_world_transform_L69:
    jmp viewport_world_transform_L66
viewport_world_transform_L66:
; return
    rts
    jmp viewport_world_transform_L68
viewport_world_transform_L67:
viewport_world_transform_L68:
; SCREEN_X = T0
    lda T0
    sta SCREEN_X
; SCREEN_Y = T2
    lda T2
    sta SCREEN_Y
; VISIBLE = 1
    lda #1
    sta VISIBLE
    rts
component_end:
