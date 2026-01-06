move_notes:
            ldx #$00
.loop:
            lda note_x,x
            cmp #NOTE_INACTIVE
            beq .next           ; Skip inactive

            jsr erase_note      ; Remove from old position
            dec note_x,x        ; Move left

            lda note_x,x
            cmp #NOTE_INACTIVE  ; Wrapped to $FF?
            beq .next           ; Despawned

            jsr draw_note       ; Draw at new position

.next:
            inx
            cpx #MAX_NOTES
            bne .loop
            rts
