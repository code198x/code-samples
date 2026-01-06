check_x_key:
            lda #%11111011      ; Select column 2 (active low)
            sta $dc00
            lda $dc01           ; Read rows
            and #%10000000      ; Check bit 7 (X key)
            bne .not_pressed
            lda #$01            ; Return 1 = pressed
            rts
.not_pressed:
            lda #$00            ; Return 0 = not pressed
            rts
