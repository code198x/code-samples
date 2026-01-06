collect_item:
    lda score
    clc
    adc #10
    sta score
    lda score+1
    adc #0
    sta score+1

    jsr update_difficulty   ; <-- Check if we level up
    jsr play_collect_sound
    jsr respawn_item
    rts
