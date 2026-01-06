.proc update_player
    ; Check Up
    lda buttons
    and #BTN_UP
    beq @check_down
    lda player_y
    cmp #8                  ; Top boundary
    bcc @check_down         ; Already at top? Don't move
    dec player_y

@check_down:
    lda buttons
    and #BTN_DOWN
    beq @check_left
    lda player_y
    cmp #224                ; Bottom boundary (240 - 16 for sprite + margin)
    bcs @check_left         ; Already at bottom? Don't move
    inc player_y

@check_left:
    lda buttons
    and #BTN_LEFT
    beq @check_right
    lda player_x
    cmp #8                  ; Left boundary
    bcc @check_right        ; Already at left? Don't move
    dec player_x

@check_right:
    lda buttons
    and #BTN_RIGHT
    beq @done
    lda player_x
    cmp #240                ; Right boundary (256 - 16 for sprite)
    bcs @done               ; Already at right? Don't move
    inc player_x

@done:
    ; Copy position to shadow OAM
    lda player_y
    sta $0200
    lda player_x
    sta $0203
    rts
.endproc
