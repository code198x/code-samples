check_pause_key:
            ; Check P key (row 5, column 1)
            lda #%11011111              ; Select row 5
            sta CIA1_PORTA
            lda CIA1_PORTB
            and #%00000010              ; Check column 1 (P)
            bne cpk_not_pressed

            ; P is pressed - check if it was already pressed
            lda key_p_was_pressed
            bne cpk_still_held
            lda #1
            sta key_p_was_pressed
            lda #0                      ; Return 0 = just pressed
            rts

cpk_still_held:
            lda #1                      ; Return 1 = still held
            rts

cpk_not_pressed:
            lda #0
            sta key_p_was_pressed
            lda #1                      ; Return 1 = not pressed
            rts
