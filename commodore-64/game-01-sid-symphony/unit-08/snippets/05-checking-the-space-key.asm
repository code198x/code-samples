check_space_key:
            lda #%01111111          ; Select column 7
            sta CIA1_PORTA
            lda CIA1_PORTB
            and #%00010000          ; Check row 4 (SPACE)
            bne +                   ; Not pressed
            lda #$01                ; Pressed
            rts
+           lda #$00
            rts
