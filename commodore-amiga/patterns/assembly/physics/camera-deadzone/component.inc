; SPDX-License-Identifier: MIT
; Camera Dead Zones. Contiguous private bytes: CAMERA, PLAYER, LEFT_EDGE, RIGHT_EDGE, SCROLL_LIMIT, SHIFTED, VALID.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; D0-D3/A0-A1/CCR change; D4-D7/A2-A6 survive.
camera_deadzone_init:
    clr.b CAMERA
    clr.b PLAYER
    clr.b LEFT_EDGE
    clr.b RIGHT_EDGE
    clr.b SCROLL_LIMIT
    clr.b SHIFTED
    clr.b VALID
    rts
camera_deadzone_step:
    clr.b SHIFTED
    clr.b VALID
    move.b LEFT_EDGE,d0
    cmp.b RIGHT_EDGE,d0
    bhi.s camera_done
    move.b CAMERA,d0
    cmp.b SCROLL_LIMIT,d0
    bhi.s camera_done
    move.b #1,VALID
    moveq #0,d0
    move.b PLAYER,d0
    moveq #0,d1
    move.b CAMERA,d1
    sub.w d1,d0
    bmi.s camera_left
    moveq #0,d1
    move.b LEFT_EDGE,d1
    cmp.w d1,d0
    blo.s camera_left
    move.b RIGHT_EDGE,d1
    cmp.w d1,d0
    bls.s camera_done
    moveq #0,d0
    move.b PLAYER,d0
    sub.w d1,d0
    bra.s camera_cap
camera_left:
    moveq #0,d0
    move.b PLAYER,d0
    moveq #0,d1
    move.b LEFT_EDGE,d1
    sub.w d1,d0
    bpl.s camera_cap
    moveq #0,d0
camera_cap:
    moveq #0,d1
    move.b SCROLL_LIMIT,d1
    cmp.w d1,d0
    bls.s camera_store
    move.w d1,d0
camera_store:
    cmp.b CAMERA,d0
    beq.s camera_done
    move.b d0,CAMERA
    move.b #1,SHIFTED
camera_done:
    rts
component_end:
