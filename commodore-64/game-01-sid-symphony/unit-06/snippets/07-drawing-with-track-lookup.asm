draw_note:
            ; Get track's row address
            lda note_track,x
            tay
            lda track_row_lo,y
            sta zp_ptr
            lda track_row_hi,y
            sta zp_ptr + 1

            ; Add X position and draw
            ldy note_x,x
            lda #$51            ; Circle character
            sta (zp_ptr),y
            rts
