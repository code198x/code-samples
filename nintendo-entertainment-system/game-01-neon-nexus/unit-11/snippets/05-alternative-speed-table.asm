; Pixels to move per frame at each difficulty
enemy_speeds:
    .byte 1, 1, 2, 2, 3, 3   ; difficulty 0-5

move_enemies:
    ; Get speed for current difficulty
    ldx difficulty
    lda enemy_speeds, x
    sta temp                ; store speed to use

    ldx #0                  ; enemy index

@loop:
    lda enemy_x, x
    sec
    sbc temp                ; subtract speed
    sta enemy_x, x

    ; Check wrap
    cmp #250
    bcc @next
    lda #248
    sta enemy_x, x

@next:
    inx
    cpx #NUM_ENEMIES
    bne @loop

    rts
