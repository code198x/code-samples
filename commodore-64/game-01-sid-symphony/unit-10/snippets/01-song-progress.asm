; ----------------------------------------------------------------------------
; Song Variables
; ----------------------------------------------------------------------------

SONG_LENGTH   = 64              ; Total beats in the song
PROGRESS_WIDTH = 16             ; Width of progress bar in characters

song_beat     = $0D             ; Current beat in song (0 to SONG_LENGTH-1)

; ----------------------------------------------------------------------------
; Advance Song - Increment beat and update progress
; ----------------------------------------------------------------------------

advance_song:
            inc beat_count
            inc song_beat

            ; Check if song has ended
            lda song_beat
            cmp #SONG_LENGTH
            bcc song_continues

            ; Song loops for now (Unit 11 will add proper end)
            lda #0
            sta song_beat
            sta beat_count
            lda #<song_data
            sta song_pos
            lda #>song_data
            sta song_pos_hi

song_continues:
            jsr display_progress
            rts
