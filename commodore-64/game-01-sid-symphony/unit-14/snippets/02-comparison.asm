check_high_score:
            ; Compare high byte first
            lda score_hi
            cmp high_score_hi
            bcc chs_done            ; Current < high, done
            bne chs_new_high        ; Current > high, new record

            ; High bytes equal, compare low bytes
            lda score_lo
            cmp high_score_lo
            bcc chs_done            ; Current < high, done
            beq chs_done            ; Current = high, done

chs_new_high:
            ; New high score!
            lda score_lo
            sta high_score_lo
            lda score_hi
            sta high_score_hi

chs_done:
            rts
