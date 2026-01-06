.proc check_item_collision
    ; Check: player_x < item_x + 8
    lda item_x
    clc
    adc #8                  ; item right edge
    cmp player_x            ; carry set if item_x+8 >= player_x
    bcc @no_hit             ; if item_x+8 < player_x, no hit

    ; Check: item_x < player_x + 8
    lda player_x
    clc
    adc #8                  ; player right edge
    cmp item_x              ; carry set if player_x+8 >= item_x
    bcc @no_hit             ; if player_x+8 < item_x, no hit

    ; Check: player_y < item_y + 8
    lda item_y
    clc
    adc #8                  ; item bottom edge
    cmp player_y            ; carry set if item_y+8 >= player_y
    bcc @no_hit             ; if item_y+8 < player_y, no hit

    ; Check: item_y < player_y + 8
    lda player_y
    clc
    adc #8                  ; player bottom edge
    cmp item_y              ; carry set if player_y+8 >= item_y
    bcc @no_hit             ; if player_y+8 < item_y, no hit

    ; All checks passed - collision!
    jsr collect_item

@no_hit:
    rts
.endproc
