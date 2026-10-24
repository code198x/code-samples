; SPDX-License-Identifier: MIT
; Enter and Leave a Ladder. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
ladder_controller_init:
    ld a,0
    ld (MODE),a
    ld (POSITION),a
    ld (GRAVITY),a
    ld (JUMPED),a
    ld (VALID),a
    ld (ON_LADDER),a
    ld (UP),a
    ld (DOWN),a
    ld (JUMP),a
    ld (MINIMUM),a
    ld (MAXIMUM),a
    ret
ladder_controller_step:
; GRAVITY = 0
    ld a,0
    ld (GRAVITY),a
; JUMPED = 0
    ld a,0
    ld (JUMPED),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if MODE > 1:
    ld a,(MODE)
    cp 1
    jp z,ladder_controller_L2
    jp nc,ladder_controller_L1
    jp ladder_controller_L2
ladder_controller_L1:
; return
    ret
    jp ladder_controller_L3
ladder_controller_L2:
ladder_controller_L3:
; if MINIMUM > POSITION:
    ld a,(MINIMUM)
    ld b,a
    ld a,(POSITION)
    ld c,a
    ld a,b
    cp c
    jp z,ladder_controller_L5
    jp nc,ladder_controller_L4
    jp ladder_controller_L5
ladder_controller_L4:
; return
    ret
    jp ladder_controller_L6
ladder_controller_L5:
ladder_controller_L6:
; if POSITION > MAXIMUM:
    ld a,(POSITION)
    ld b,a
    ld a,(MAXIMUM)
    ld c,a
    ld a,b
    cp c
    jp z,ladder_controller_L8
    jp nc,ladder_controller_L7
    jp ladder_controller_L8
ladder_controller_L7:
; return
    ret
    jp ladder_controller_L9
ladder_controller_L8:
ladder_controller_L9:
; VALID = 1
    ld a,1
    ld (VALID),a
; if ON_LADDER == 0:
    ld a,(ON_LADDER)
    cp 0
    jp z,ladder_controller_L10
    jp ladder_controller_L11
ladder_controller_L10:
; MODE = 0
    ld a,0
    ld (MODE),a
    jp ladder_controller_L12
ladder_controller_L11:
; if MODE == 0:
    ld a,(MODE)
    cp 0
    jp z,ladder_controller_L13
    jp ladder_controller_L14
ladder_controller_L13:
; if UP != 0:
    ld a,(UP)
    cp 0
    jp nz,ladder_controller_L16
    jp ladder_controller_L17
ladder_controller_L16:
; MODE = 1
    ld a,1
    ld (MODE),a
    jp ladder_controller_L18
ladder_controller_L17:
ladder_controller_L18:
; if DOWN != 0:
    ld a,(DOWN)
    cp 0
    jp nz,ladder_controller_L19
    jp ladder_controller_L20
ladder_controller_L19:
; MODE = 1
    ld a,1
    ld (MODE),a
    jp ladder_controller_L21
ladder_controller_L20:
ladder_controller_L21:
    jp ladder_controller_L15
ladder_controller_L14:
ladder_controller_L15:
; if MODE == 1:
    ld a,(MODE)
    cp 1
    jp z,ladder_controller_L22
    jp ladder_controller_L23
ladder_controller_L22:
; if JUMP != 0:
    ld a,(JUMP)
    cp 0
    jp nz,ladder_controller_L25
    jp ladder_controller_L26
ladder_controller_L25:
; MODE = 0
    ld a,0
    ld (MODE),a
; JUMPED = 1
    ld a,1
    ld (JUMPED),a
    jp ladder_controller_L27
ladder_controller_L26:
; if UP != 0:
    ld a,(UP)
    cp 0
    jp nz,ladder_controller_L28
    jp ladder_controller_L29
ladder_controller_L28:
; if DOWN == 0:
    ld a,(DOWN)
    cp 0
    jp z,ladder_controller_L31
    jp ladder_controller_L32
ladder_controller_L31:
; if POSITION > MINIMUM:
    ld a,(POSITION)
    ld b,a
    ld a,(MINIMUM)
    ld c,a
    ld a,b
    cp c
    jp z,ladder_controller_L35
    jp nc,ladder_controller_L34
    jp ladder_controller_L35
ladder_controller_L34:
; POSITION = POSITION - 1
    ld a,(POSITION)
    sub 1
    ld (POSITION),a
    jp ladder_controller_L36
ladder_controller_L35:
ladder_controller_L36:
    jp ladder_controller_L33
ladder_controller_L32:
ladder_controller_L33:
    jp ladder_controller_L30
ladder_controller_L29:
; if DOWN != 0:
    ld a,(DOWN)
    cp 0
    jp nz,ladder_controller_L37
    jp ladder_controller_L38
ladder_controller_L37:
; if POSITION < MAXIMUM:
    ld a,(POSITION)
    ld b,a
    ld a,(MAXIMUM)
    ld c,a
    ld a,b
    cp c
    jp c,ladder_controller_L40
    jp ladder_controller_L41
ladder_controller_L40:
; POSITION = POSITION + 1
    ld a,(POSITION)
    add a,1
    ld (POSITION),a
    jp ladder_controller_L42
ladder_controller_L41:
ladder_controller_L42:
    jp ladder_controller_L39
ladder_controller_L38:
ladder_controller_L39:
ladder_controller_L30:
ladder_controller_L27:
    jp ladder_controller_L24
ladder_controller_L23:
ladder_controller_L24:
ladder_controller_L12:
; if MODE == 0:
    ld a,(MODE)
    cp 0
    jp z,ladder_controller_L43
    jp ladder_controller_L44
ladder_controller_L43:
; GRAVITY = 1
    ld a,1
    ld (GRAVITY),a
    jp ladder_controller_L45
ladder_controller_L44:
ladder_controller_L45:
    ret
component_end:
