draw_perfect_text:
            ; Calculate screen address: SCREEN + row * 40 + 15
            lda grade_row
            jsr calc_grade_addr
            ldy #0
dpt_loop:
            lda perfect_text,y
            beq dpt_colour
            sta (grade_screen_lo),y
            iny
            cpy #7
            bne dpt_loop

dpt_colour:
            ldy #0
dpt_col:
            lda #COL_GREEN
            sta (grade_colour_lo),y
            iny
            cpy #7
            bne dpt_col
            rts

perfect_text:
            !byte $10, $05, $12, $06, $05, $03, $14, 0  ; "PERFECT" in screen codes
