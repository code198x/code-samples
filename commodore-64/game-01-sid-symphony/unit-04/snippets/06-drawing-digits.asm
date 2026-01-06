draw_score:
            ldx #$00
-           lda score_digits,x
            ora #$30                ; Convert 0-9 to screen code '0'-'9'
            sta SCREEN + (ROW_SCORE * 40) + 8,x
            inx
            cpx #$05                ; 5 digits (max 65535)
            bne -
            rts
