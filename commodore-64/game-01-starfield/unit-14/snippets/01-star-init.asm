        ; Initialize and draw stars
        ldx #$00
-       lda star_init_row,x
        sta star_row,x
        lda star_init_col,x
        sta star_col,x
        jsr draw_star
        inx
        cpx #$08
        bne -

; ...

; Subroutine: draw_star
; X = star index. Writes character and colour at the star's position.
draw_star:
        ldy star_row,x
        lda row_addr_lo,y
        sta $fb
        lda row_addr_hi,y
        sta $fc
        ldy star_col,x

        ; Write character to screen RAM
        lda star_char_tbl,x
        sta ($fb),y

        ; Switch pointer to colour RAM (high byte + $D4)
        lda $fc
        clc
        adc #$d4
        sta $fc

        ; Write colour
        lda star_colour_tbl,x
        sta ($fb),y
        rts
