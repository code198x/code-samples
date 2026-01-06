draw_note:
            lda note_x,x
            cmp #HIT_ZONE_W     ; In hit zone?
            bcc .done           ; Don't overdraw hit zone

            clc
            adc #<(SCREEN + ROW_TRACK2 * 40)
            sta screen_ptr
            lda #>(SCREEN + ROW_TRACK2 * 40)
            adc #$00
            sta screen_ptr + 1

            ldy #$00
            lda #$51            ; Note character (ball)
            sta (screen_ptr),y

            ; Set colour
            lda note_x,x
            clc
            adc #<(COLOUR + ROW_TRACK2 * 40)
            sta screen_ptr
            lda #>(COLOUR + ROW_TRACK2 * 40)
            adc #$00
            sta screen_ptr + 1

            lda #COL_WHITE
            sta (screen_ptr),y
.done:
            rts
