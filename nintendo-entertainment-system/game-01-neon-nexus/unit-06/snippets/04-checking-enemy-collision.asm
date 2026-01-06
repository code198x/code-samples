.proc check_enemy_collision
    ldx #0                  ; Enemy index
@loop:
    ; Check X overlap
    ; player_x < enemy_x + 8?
    lda enemy_x, x
    clc
    adc #8
    cmp player_x
    bcc @next               ; No X overlap

    ; enemy_x < player_x + 8?
    lda player_x
    clc
    adc #8
    cmp enemy_x, x
    bcc @next               ; No X overlap

    ; Check Y overlap
    ; player_y < enemy_y + 8?
    lda enemy_y, x
    clc
    adc #8
    cmp player_y
    bcc @next               ; No Y overlap

    ; enemy_y < player_y + 8?
    lda player_y
    clc
    adc #8
    cmp enemy_y, x
    bcc @next               ; No Y overlap

    ; All checks passed - collision!
    lda #STATE_GAMEOVER
    sta game_state
    rts                     ; Exit immediately

@next:
    inx
    cpx #NUM_ENEMIES
    bne @loop
    rts
.endproc
