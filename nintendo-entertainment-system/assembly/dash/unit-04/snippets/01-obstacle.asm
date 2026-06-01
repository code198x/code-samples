    ; --- Move obstacle ---
    lda obstacle_x
    sec
    sbc #OBSTACLE_SPEED     ; Move left by 2 pixels per frame
    sta obstacle_x
