; Erase and draw notes
;
; Animation requires: erase old position, then draw new position.
; We erase by drawing the track character (TRACK_CHAR) over the note.

erase_note:
                ; Get screen row for this track
                lda note_track,x
                jsr get_track_row       ; Returns row in A
                jsr calc_row_addr       ; Sets screen_ptr

                ; Erase with track character
                ldy note_x,x
                lda #TRACK_CHAR
                sta (screen_ptr),y
                lda #COL_DARK_GREY
                sta (colour_ptr),y
                rts

draw_note:
                ; Get screen row for this track
                lda note_track,x
                jsr get_track_row
                jsr calc_row_addr

                ; Draw note character
                ldy note_x,x
                lda #NOTE_CHAR
                sta (screen_ptr),y

                ; Colour based on track
                lda note_track,x
                jsr get_track_colour
                sta (colour_ptr),y
                rts

get_track_row:
                cmp #1
                bne +
                lda #TRACK1_ROW
                rts
+               cmp #2
                bne +
                lda #TRACK2_ROW
                rts
+               lda #TRACK3_ROW
                rts

get_track_colour:
                cmp #1
                bne +
                lda #COL_CYAN
                rts
+               cmp #2
                bne +
                lda #COL_GREEN
                rts
+               lda #COL_YELLOW
                rts
