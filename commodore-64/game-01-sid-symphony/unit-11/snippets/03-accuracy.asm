; ----------------------------------------------------------------------------
; Calculate Accuracy - (perfects + goods) * 100 / total_notes
; ----------------------------------------------------------------------------

calculate_accuracy:
            ; Total hits = perfects + goods
            lda perfect_count
            clc
            adc good_count
            sta total_hits

            ; Total notes = hits + misses
            clc
            adc miss_count
            sta total_notes

            ; Avoid division by zero
            beq accuracy_zero

            ; Multiply hits by 100
            lda total_hits
            sta dividend_lo
            lda #0
            sta dividend_hi

            ldx #100
mult_loop:
            dex
            beq mult_done
            lda dividend_lo
            clc
            adc total_hits
            sta dividend_lo
            lda dividend_hi
            adc #0
            sta dividend_hi
            jmp mult_loop
mult_done:

            ; Divide by total_notes
            lda #0
            sta accuracy
div_loop:
            lda dividend_lo
            sec
            sbc total_notes
            tay
            lda dividend_hi
            sbc #0
            bcc div_done
            sta dividend_hi
            sty dividend_lo
            inc accuracy
            jmp div_loop
div_done:
            rts

accuracy_zero:
            lda #0
            sta accuracy
            rts
