start_game:
            ; Clear notes
            ldx #MAX_NOTES - 1
            lda #NOTE_INACTIVE
-           sta note_x,x
            dex
            bpl -

            ; Reset song
            lda #<song_data
            sta song_ptr
            lda #>song_data
            sta song_ptr + 1
            ldy #$00
            lda (song_ptr),y
            sta next_note_timer
            lda #$01
            sta song_playing

            ; Reset state
            lda #$00
            sta score_lo
            sta score_hi
            sta streak
            sta best_streak
            sta key_x
            sta key_c
            sta key_v
            sta key_x_prev
            sta key_c_prev
            sta key_v_prev
            sta hit_flash
            sta miss_flash
            sta space_prev

            lda #CROWD_START
            sta crowd_meter
            lda #NOTE_SPEED
            sta move_timer

            ; Draw game screen
            jsr draw_game_screen

            ; Start playing
            lda #STATE_PLAYING
            sta game_state
            rts
