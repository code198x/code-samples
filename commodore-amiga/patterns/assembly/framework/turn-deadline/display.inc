; A1 points at the first bitplane byte; A0=eight glyph bytes.
; Advances A1 one character column; D1/A0/CCR change. Row stride40.
put_glyph:
    moveq #7,d1
glyph_row:
    move.b (a0)+,(a1)
    adda.w #40,a1
    dbra d1,glyph_row
    suba.w #320,a1
    addq.l #1,a1
    rts
hex_digit:
    andi.w #15,d0
    addq.w #1,d0
    lsl.w #3,d0
    lea hex_font,a0
    adda.w d0,a0
    bra put_glyph
show_byte:
    move.w d0,d2
    lsr.w #4,d0
    bsr hex_digit
    move.w d2,d0
    bra hex_digit
draw_status:
    lea status_row,a2
    lea display_row,a3
    lea plane+1962,a1
    moveq #6,d7
status_word:
    move.w (a2)+,d4
    move.w d4,(a3)+
    move.w d4,d0
    lsr.w #8,d0
    bsr show_byte
    move.w d4,d0
    bsr show_byte
    lea hex_font,a0
    bsr put_glyph
    dbra d7,status_word
    rts
