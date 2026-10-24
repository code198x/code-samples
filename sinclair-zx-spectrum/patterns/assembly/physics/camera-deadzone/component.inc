; SPDX-License-Identifier: MIT
; Camera Dead Zones. Contiguous private bytes: CAMERA, PLAYER, LEFT_EDGE, RIGHT_EDGE, SCROLL_LIMIT, SHIFTED, VALID.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; AF/BC/DE/HL change; IX/IY survive.
camera_deadzone_init:
    xor a
    ld (CAMERA),a
    ld (PLAYER),a
    ld (LEFT_EDGE),a
    ld (RIGHT_EDGE),a
    ld (SCROLL_LIMIT),a
    ld (SHIFTED),a
    ld (VALID),a
    ret
camera_deadzone_step:
    xor a
    ld (SHIFTED),a
    ld (VALID),a
    ld a,(RIGHT_EDGE)
    ld b,a
    ld a,(LEFT_EDGE)
    cp b
    jr c,camera_check_position
    ret nz
camera_check_position:
    ld a,(SCROLL_LIMIT)
    ld b,a
    ld a,(CAMERA)
    cp b
    jr c,camera_valid
    ret nz
camera_valid:
    ld a,1
    ld (VALID),a
    ld a,(CAMERA)
    ld b,a
    ld a,(PLAYER)
    sub b
    jr c,camera_left
    ld c,a
    ld a,(LEFT_EDGE)
    cp c
    jr c,camera_check_right
    jr nz,camera_left
camera_check_right:
    ld a,(RIGHT_EDGE)
    cp c
    ret nc
    ld b,a
    ld a,(PLAYER)
    sub b
    jr camera_cap
camera_left:
    ld a,(LEFT_EDGE)
    ld b,a
    ld a,(PLAYER)
    sub b
    jr nc,camera_cap
    xor a
camera_cap:
    ld c,a
    ld a,(SCROLL_LIMIT)
    cp c
    jr nc,camera_have
    ld c,a
camera_have:
    ld a,(CAMERA)
    cp c
    ret z
    ld a,c
    ld (CAMERA),a
    ld a,1
    ld (SHIFTED),a
    ret
component_end:
