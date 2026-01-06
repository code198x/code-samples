move_notes:
            ldx #$00
.loop:
            lda note_x,x
            cmp #NOTE_INACTIVE
            beq .next

            jsr erase_note
            dec note_x,x

            lda note_x,x
            cmp #NOTE_INACTIVE      ; Wrapped to $FF?
            bne .draw

            ; Missed!
            lda #FLASH_TIME
            sta miss_flash
            jmp .next

.draw:
            jsr draw_note
.next:
            inx
            cpx #MAX_NOTES
            bne .loop
            rts
