check_victory:
            lda song_playing
            bne +                   ; Song still playing

            ; Song ended - check for remaining notes
            ldx #MAX_NOTES - 1
-           lda note_x,x
            cmp #NOTE_INACTIVE
            bne +                   ; Note still on screen
            dex
            bpl -

            ; No notes! Victory!
            lda #STATE_VICTORY
            sta game_state
            jsr draw_victory_screen
+           rts
