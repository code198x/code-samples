spawn_track:    !byte 0         ; 0, 1, 2, 0, 1, 2...

spawn_note:
            ; Find empty slot
            ldx #MAX_NOTES - 1
-           lda note_x,x
            cmp #NOTE_INACTIVE
            beq +
            dex
            bpl -
            rts                 ; No empty slots
+
            ; Spawn at right edge
            lda #38
            sta note_x,x

            ; Assign current track
            lda spawn_track
            sta note_track,x

            ; Rotate to next track
            inc spawn_track
            lda spawn_track
            cmp #NUM_TRACKS
            bcc +
            lda #$00
            sta spawn_track
+
            ; Draw the note
            jsr draw_note
            rts
