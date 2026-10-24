start:
    lea $dff000,a5
    move.w #$7fff,$09a(a5)
    move.w #$7fff,$09c(a5)
    move.w #$7fff,$096(a5)
    bsr exercise_rules
    lea plane,a0
    move.l a0,d0
    lea copbpl,a1
    move.w d0,6(a1)
    swap d0
    move.w d0,2(a1)
    lea copperlist,a0
    move.l a0,$080(a5)
    move.w #0,$088(a5)
    lea preview,a2
    lea plane+1962,a1
    moveq #7,d7
preview_show:
    moveq #0,d0
    move.b (a2)+,d0
    bsr show_byte
    lea hex_font,a0
    bsr put_glyph
    dbra d7,preview_show
    move.w #$8380,$096(a5)
    move.w #$babe,ready
hold:
    bra hold
failed:
    move.w #$f00,$180(a5)
    bra failed
