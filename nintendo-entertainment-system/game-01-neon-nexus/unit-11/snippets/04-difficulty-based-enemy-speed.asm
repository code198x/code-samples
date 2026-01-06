move_enemies:
    ldx #0

@loop:
    ; Base movement
    lda enemy_x, x
    sec
    sbc #ENEMY_SPEED        ; always move at least 1 pixel
    sta enemy_x, x

    ; Extra movement at higher difficulty
    lda difficulty
    beq @check_wrap         ; difficulty 0 = no extra speed

    ; At difficulty 1+, move extra pixel
    lda enemy_x, x
    sec
    sbc #1                  ; extra pixel
    sta enemy_x, x

    ; At difficulty 3+, move another extra pixel
    lda difficulty
    cmp #3
    bcc @check_wrap
    lda enemy_x, x
    sec
    sbc #1
    sta enemy_x, x

@check_wrap:
    ; Check for screen wrap
    lda enemy_x, x
    cmp #250
    bcc @next

    ; Respawn on right side
    lda #248
    sta enemy_x, x

@next:
    inx
    cpx #NUM_ENEMIES
    bne @loop

    rts
