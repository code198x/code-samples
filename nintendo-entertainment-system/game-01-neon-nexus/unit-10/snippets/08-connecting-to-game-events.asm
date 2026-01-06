collect_item:
    ; Add 10 to score
    lda score
    clc
    adc #10
    sta score
    lda score+1
    adc #0
    sta score+1

    ; Play sound
    jsr play_collect_sound

    ; Respawn item
    jsr respawn_item
    rts
