; ----------------------------------------------------------------------------
; Check Spawn Note - Now reads 3-byte song entries
; ----------------------------------------------------------------------------

check_spawn_note:
            ldy #0

spawn_check_loop:
            lda (song_pos),y
            cmp #$FF
            beq spawn_restart_song

            cmp beat_count
            beq spawn_match
            bcs spawn_done

            jmp spawn_advance

spawn_match:
            iny
            lda (song_pos),y    ; Track number
            sta temp_track
            iny
            lda (song_pos),y    ; Note frequency
            pha
            lda temp_track
            jsr spawn_note_with_freq
            pla                 ; Clean up stack
            dey
            dey

spawn_advance:
            lda song_pos
            clc
            adc #3              ; 3 bytes per entry now
            sta song_pos
            lda song_pos_hi
            adc #0
            sta song_pos_hi
            jmp spawn_check_loop

spawn_done:
            rts
