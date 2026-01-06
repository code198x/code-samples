update_flash:
    lda flash_timer
    beq @done               ; no flash active
    dec flash_timer
    bne @done               ; still flashing

    ; Flash ended - restore normal PPUMASK
    lda #%00011110          ; normal display
    sta PPUMASK

    ; Now start the game over delay
    lda #GAMEOVER_DELAY
    sta gameover_delay
@done:
    rts
