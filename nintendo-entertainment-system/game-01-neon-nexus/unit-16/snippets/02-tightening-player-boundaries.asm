update_player:
    lda buttons
    and #BTN_RIGHT
    beq @check_left
    lda player_x
    clc
    adc #PLAYER_SPEED
    cmp #PLAYER_MAX_X
    bcs @check_left
    sta player_x

@check_left:
    lda buttons
    and #BTN_LEFT
    beq @check_down
    lda player_x
    sec
    sbc #PLAYER_SPEED
    cmp #PLAYER_MIN_X
    bcc @check_down
    sta player_x

@check_down:
    lda buttons
    and #BTN_DOWN
    beq @check_up
    lda player_y
    clc
    adc #PLAYER_SPEED
    cmp #PLAYER_MAX_Y
    bcs @check_up
    sta player_y

@check_up:
    lda buttons
    and #BTN_UP
    beq @done
    lda player_y
    sec
    sbc #PLAYER_SPEED
    cmp #PLAYER_MIN_Y
    bcc @done
    sta player_y

@done:
    rts
