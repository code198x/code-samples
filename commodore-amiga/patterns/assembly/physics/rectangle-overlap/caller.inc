start:
    lea $dff000,a5
    move.w #$7fff,$09a(a5)
    move.w #$7fff,$09c(a5)
    move.w #$7fff,$096(a5)
    lea case_table,a2
    lea results,a3
    move.w #CASE_COUNT-1,d7
case_loop:
    lea rect_a,a0
    moveq #7,d6
copy_case:
    move.w (a2)+,(a0)+
    dbra d6,copy_case
    bsr boxes_overlap
    move.b d0,(a3)+
    dbra d7,case_loop
    move.w #$cafe,completed
    lea example,a0
    lea rect_a,a1
    moveq #7,d6
copy_example:
    move.w (a0)+,(a1)+
    dbra d6,copy_example
    bsr boxes_overlap
    move.w d0,result
; Set up the maintained one-plane PAL display, independent of the helper.
    lea plane,a0
    move.l a0,d0
    lea copbpl,a1
    move.w d0,6(a1)
    swap d0
    move.w d0,2(a1)
    lea copperlist,a0
    move.l a0,$080(a5)
    move.w #0,$088(a5)
    lea zero,a0
    tst.w result
    beq show_digit
    lea one,a0
show_digit:
    lea plane+1984,a1
    moveq #7,d2
copy_glyph:
    move.b (a0)+,(a1)
    adda.w #40,a1
    dbra d2,copy_glyph
    move.w #$8380,$096(a5)
    move.w #$babe,ready
hold:
    bra hold
caller_code_end:
signature: dc.b "198XRECTAMIGA!",0
    even
completed: dc.w 0
ready: dc.w 0
result: dc.w 0
results: dcb.b CASE_COUNT,0
    even
zero: dc.b 60,66,70,74,82,98,60,0
one: dc.b 24,56,24,24,24,24,126,0
    even
copperlist:
    dc.w $08e,$2c81,$090,$2cc1,$092,$0038,$094,$00d0
    dc.w $100,$1200,$102,0,$104,0,$108,0,$10a,0
    dc.w $180,$012,$182,$fff
copbpl:
    dc.w $0e0,0,$0e2,0
    dc.w $ffff,$fffe
plane: dcb.b 10240,0
