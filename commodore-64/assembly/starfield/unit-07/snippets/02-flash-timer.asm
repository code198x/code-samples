        ; --- Update enemy ---
        lda flash_timer
        beq enemy_move          ; Not flashing, normal movement

        ; Enemy is frozen (flashing white)
        dec flash_timer
        bne no_respawn          ; Still flashing, skip everything

        ; Flash done — restore colour and respawn
        lda #$05
        sta $d029               ; Back to green
        lda #$32
        sta enemy_y
        sta $d005
        lda $d012
        and #$7f
        clc
        adc #$30
        sta enemy_x
        sta $d004
        jmp no_respawn

enemy_move:
        lda enemy_y
        clc
        adc #$01                ; Move down 1 pixel per frame
        sta enemy_y
        sta $d005               ; Update sprite 2 Y position

        ; Check if enemy has left the screen (Y > 248)
        cmp #$f8
        bcc no_respawn          ; Y < 248, still on screen

        ; Respawn at top with new X position
        lda #$32
        sta enemy_y
        sta $d005               ; Reset Y to top

        lda $d012               ; Pseudo-random from raster position
        and #$7f                ; Range 0-127
        clc
        adc #$30                ; Range 48-175
        sta enemy_x
        sta $d004               ; New X position

no_respawn:
        jmp game_loop
