spawn_note:
            ldx #$00
.find_slot:
            lda note_x,x
            cmp #NOTE_INACTIVE
            beq .found
            inx
            cpx #MAX_NOTES
            bne .find_slot
            rts                 ; No free slots

.found:
            lda #39             ; Right edge
            sta note_x,x
            jsr draw_note
            rts
