; A500 OCS PAL/KS1.3, all data in chip RAM. Owns chips; reset to leave.
    section code,code_c
start:
    lea $dff000,a5
    move.w #$7fff,$09a(a5)
    move.w #$7fff,$09c(a5)
    move.w #$7fff,$096(a5)
    lea plane,a0
    move.w #255,d7
paint_row:
    move.w #19,d6
paint_word:
    move.w d7,d0
    and.w #7,d0
    bne.s paint_zero
    move.w #$5555,d0
paint_zero:
    move.w d0,(a0)+
    dbra d6,paint_word
    dbra d7,paint_row
    lea plane,a0
    move.l a0,d0
    lea copbpl,a1
    move.w d0,6(a1)
    swap d0
    move.w d0,2(a1)
    lea copperlist,a0
    move.l a0,$080(a5)
    move.w #0,$088(a5)
    move.w #$83c0,$096(a5)
    bsr draw_objects
    move.w #$cafe,ready
main:
    bsr wait_frame
    move.l old_b,a1
    lea under_b,a0
    bsr geometry
    bsr bob_restore
    move.l old_a,a1
    lea under_a,a0
    bsr geometry
    bsr bob_restore
    addq.w #1,tick
    move.w tick,d0
    and.w #3,d0
    bne.s no_move
    addq.w #2,column
    cmp.w #32,column
    bcs.s no_move
    move.w #4,column
no_move:
    bsr draw_objects
    addq.w #1,updates
    bra main
geometry:
    moveq #2,d0
    moveq #16,d1
    moveq #40,d2
    rts
draw_objects:
    lea plane,a0
    adda.l #104*40,a0
    adda.w column,a0
    move.l a0,old_a
    lea under_a,a1
    bsr geometry
    bsr bob_save
    lea mask,a0
    lea image_a,a1
    move.l old_a,a2
    bsr geometry
    bsr bob_draw
    lea plane+112*40+16,a0
    move.l a0,old_b
    lea under_b,a1
    bsr geometry
    bsr bob_save
    lea mask,a0
    lea image_b,a1
    move.l old_b,a2
    bsr geometry
    bsr bob_draw
    rts
signature: dc.b "198XLIFECYCLE!",0
    even
ready: dc.w 0
updates: dc.w 0
tick: dc.w 0
column: dc.w 4
old_a: dc.l 0
old_b: dc.l 0
    include "bob.inc"
    include "shapes.inc"
    include "../../framework/game-loop/frame.inc"
    even
copperlist:
    dc.w $08e,$2c81,$090,$2cc1,$092,$0038,$094,$00d0
    dc.w $100,$1200,$102,0,$104,0,$108,0,$10a,0
    dc.w $180,$012,$182,$6ed
copbpl:
    dc.w $0e0,0,$0e2,0
    dc.w $ffff,$fffe
under_a: dcb.b 64,0
under_b: dcb.b 64,0
plane: dcb.b 10240,0
