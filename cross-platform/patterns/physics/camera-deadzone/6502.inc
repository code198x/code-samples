; SPDX-License-Identifier: MIT
; Camera Dead Zones. Contiguous private bytes: CAMERA, PLAYER, LEFT_EDGE, RIGHT_EDGE, SCROLL_LIMIT, SHIFTED, VALID.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; A/X/flags change; Y and decimal mode survive. D=0 for binary arithmetic.
camera_deadzone_init:
    lda #0
    sta CAMERA
    sta PLAYER
    sta LEFT_EDGE
    sta RIGHT_EDGE
    sta SCROLL_LIMIT
    sta SHIFTED
    sta VALID
    rts
camera_deadzone_step:
    lda #0
    sta SHIFTED
    sta VALID
    lda LEFT_EDGE
    cmp RIGHT_EDGE
    bcc camera_check_position
    bne camera_done
camera_check_position:
    lda CAMERA
    cmp SCROLL_LIMIT
    bcc camera_valid
    bne camera_done
camera_valid:
    inc VALID
    lda PLAYER
    sec
    sbc CAMERA
    bcc camera_left
    cmp LEFT_EDGE
    bcc camera_left
    cmp RIGHT_EDGE
    bcc camera_done
    beq camera_done
    lda PLAYER
    sec
    sbc RIGHT_EDGE
    jmp camera_cap
camera_left:
    lda PLAYER
    sec
    sbc LEFT_EDGE
    bcs camera_cap
    lda #0
camera_cap:
    cmp SCROLL_LIMIT
    bcc camera_store
    lda SCROLL_LIMIT
camera_store:
    cmp CAMERA
    beq camera_done
    sta CAMERA
    inc SHIFTED
camera_done:
    rts
component_end:
