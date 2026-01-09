; Song completion detection
;
; Two conditions must be true:
;   1. Song position has reached END_MARKER
;   2. No notes are still active on screen
;
; Both are needed because notes spawned near the end
; are still in flight when we hit the end marker.

check_song_complete:
                ; Already complete?
                lda song_complete
                bne .done               ; Skip if already handled

                ; Check if song has reached end
                ldx song_position
                lda song_beats,x
                cmp #END_MARKER
                bne .done               ; Song still has notes to spawn

                ; Check if any notes still active
                ldx #0
.check_notes:
                lda note_active,x
                bne .done               ; Note still on screen - wait
                inx
                cpx #MAX_NOTES
                bne .check_notes

                ; Both conditions met - song complete!
                lda #1
                sta song_complete
                jsr show_results        ; Display victory screen

.done:
                rts
