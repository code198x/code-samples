check_hit:
            ldx #$00
.loop:
            lda note_x,x
            cmp #NOTE_INACTIVE
            beq .next               ; Skip inactive

            cmp #HIT_ZONE_W         ; Position < 4?
            bcs .next               ; No, not in hit zone

            ; HIT! Remove note
            jsr erase_note
            lda #NOTE_INACTIVE
            sta note_x,x
            lda #FLASH_TIME
            sta hit_flash
            rts                     ; First match only

.next:
            inx
            cpx #MAX_NOTES
            bne .loop
            rts
