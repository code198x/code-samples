; ----------------------------------------------------------------------------
; Display Score - Convert 16-bit score to decimal and show
; ----------------------------------------------------------------------------

display_score:
            ; Convert score to 5-digit decimal display
            ; Uses simple repeated subtraction method

            ; Copy score to working area
            lda score_lo
            sta work_lo
            lda score_hi
            sta work_hi

            ; Ten-thousands digit
            ldx #0
div_10000:
            lda work_lo
            sec
            sbc #<10000
            tay
            lda work_hi
            sbc #>10000
            bcc done_10000
            sta work_hi
            sty work_lo
            inx
            jmp div_10000
done_10000:
            txa
            ora #$30            ; Convert to screen code
            sta SCREEN + 8

            ; Thousands digit
            ldx #0
div_1000:
            lda work_lo
            sec
            sbc #<1000
            tay
            lda work_hi
            sbc #>1000
            bcc done_1000
            sta work_hi
            sty work_lo
            inx
            jmp div_1000
done_1000:
            txa
            ora #$30
            sta SCREEN + 9

            ; Hundreds digit
            ldx #0
div_100:
            lda work_lo
            sec
            sbc #100
            bcc done_100
            sta work_lo
            inx
            jmp div_100
done_100:
            txa
            ora #$30
            sta SCREEN + 10

            ; Tens digit
            ldx #0
div_10:
            lda work_lo
            sec
            sbc #10
            bcc done_10
            sta work_lo
            inx
            jmp div_10
done_10:
            txa
            ora #$30
            sta SCREEN + 11

            ; Ones digit
            lda work_lo
            ora #$30
            sta SCREEN + 12

            ; Set score digit colours
            lda #7              ; Yellow for score
            sta COLRAM + 8
            sta COLRAM + 9
            sta COLRAM + 10
            sta COLRAM + 11
            sta COLRAM + 12

            rts

; Working variables for division
work_lo:    !byte 0
work_hi:    !byte 0
