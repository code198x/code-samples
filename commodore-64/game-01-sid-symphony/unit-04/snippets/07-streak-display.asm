convert_streak:
            lda streak
            ldx #$00                ; Tens counter
-           cmp #10
            bcc +
            sec
            sbc #10
            inx
            jmp -
+           stx streak_tens         ; Tens digit
            sta streak_ones         ; Ones digit (remainder)
            rts
