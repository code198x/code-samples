POINTS_PER_HIT  = 10

add_score:
            clc                     ; Clear carry before addition
            lda score_lo
            adc #POINTS_PER_HIT     ; Add to low byte
            sta score_lo
            bcc +                   ; No overflow? Done
            inc score_hi            ; Overflow: increment high byte
+           rts
