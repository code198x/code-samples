; ----------------------------------------------------------------------------
; Display Progress - Show song progress bar
; ----------------------------------------------------------------------------

display_progress:
            ; Calculate progress: (song_beat * PROGRESS_WIDTH) / SONG_LENGTH
            ; For 64-beat song with 16-char bar: song_beat / 4

            lda song_beat
            lsr                 ; Divide by 4
            lsr
            sta temp_progress

            ; Draw filled portion
            ldx #0
            lda temp_progress
            beq draw_empty_progress

draw_full_progress:
            lda #CHAR_BAR_FULL
            sta SCREEN + (PROGRESS_ROW * 40) + 12,x
            lda #PROGRESS_COL
            sta COLRAM + (PROGRESS_ROW * 40) + 12,x
            inx
            cpx temp_progress
            bne draw_full_progress

draw_empty_progress:
            cpx #PROGRESS_WIDTH
            beq progress_done
            lda #CHAR_BAR_EMPTY
            sta SCREEN + (PROGRESS_ROW * 40) + 12,x
            lda #11             ; Dark grey
            sta COLRAM + (PROGRESS_ROW * 40) + 12,x
            inx
            jmp draw_empty_progress

progress_done:
            rts

temp_progress: !byte 0
