spawn_note_on_track:
            sta temp_track          ; Save track number

            ; Find free slot
            ldx #MAX_NOTES - 1
-           lda note_x,x
            cmp #NOTE_INACTIVE
            beq +
            dex
            bpl -
            rts                     ; No free slot

+           ; Spawn note
            lda #38                 ; Right edge
            sta note_x,x
            lda temp_track
            sta note_track,x
            jsr draw_note
            rts
