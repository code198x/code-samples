; ----------------------------------------------------------------------------
; Check Song End
; ----------------------------------------------------------------------------

check_song_end:
            ; First check if song data exhausted
            lda song_ended
            beq song_not_ended

            ; Song data done - wait for all notes to clear
            ldx #0
check_notes_clear:
            lda note_track,x
            bne notes_still_active
            inx
            cpx #MAX_NOTES
            bne check_notes_clear

            ; All notes cleared - count down delay
            dec end_delay
            bne song_not_ended

            ; Delay done - show results
            jsr show_results
            lda #STATE_RESULTS
            sta game_state

notes_still_active:
song_not_ended:
            rts
