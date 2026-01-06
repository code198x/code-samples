jsr check_x_key         ; A = 1 if pressed now
            ldx key_was_pressed     ; X = was it pressed last frame?
            sta key_was_pressed     ; Update for next frame

            cpx #$00
            bne .not_key_down       ; Was already pressed
            cmp #$01
            bne .not_key_down       ; Not pressed now either

            ; Key just went down!
            jsr check_hit
            jsr play_note
