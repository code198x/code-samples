init_song:
            ; Set song pointer to start of song data
            lda #<song_data
            sta song_ptr
            lda #>song_data
            sta song_ptr + 1

            ; Read first delta time
            ldy #$00
            lda (song_ptr),y
            sta next_note_timer

            ; Song is playing
            lda #$01
            sta song_playing
            rts
