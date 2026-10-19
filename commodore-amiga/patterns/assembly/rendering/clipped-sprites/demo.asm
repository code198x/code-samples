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
    move.w #$5555,(a0)+
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
    move.w #-1,d0
    move.w #-8,d1
    lea mask,a0
    lea image_a,a1
    lea plane,a2
    bsr draw_clipped
    move.w #19,d0
    move.w #-8,d1
    lea mask,a0
    lea image_a,a1
    lea plane,a2
    bsr draw_clipped
    move.w #-1,d0
    move.w #248,d1
    lea mask,a0
    lea image_a,a1
    lea plane,a2
    bsr draw_clipped
    move.w #19,d0
    move.w #248,d1
    lea mask,a0
    lea image_a,a1
    lea plane,a2
    bsr draw_clipped
    move.w #9,d0
    move.w #120,d1
    lea mask,a0
    lea image_a,a1
    lea plane,a2
    bsr draw_clipped
    move.w #0,d0
    move.w #80,d1
    lea mask,a0
    lea image_a,a1
    lea plane,a2
    bsr draw_clipped
    move.w #18,d0
    move.w #160,d1
    lea mask,a0
    lea image_a,a1
    lea plane,a2
    bsr draw_clipped
    move.w #-2,d0
    move.w #32,d1
    lea mask,a0
    lea image_a,a1
    lea plane,a2
    bsr draw_clipped
    move.w #20,d0
    move.w #32,d1
    lea mask,a0
    lea image_a,a1
    lea plane,a2
    bsr draw_clipped
    move.w #$cafe,ready
main:
    bsr wait_frame
    addq.w #1,updates
    bra main
signature: dc.b "198XCLIPPING!",0
    even
ready: dc.w 0
updates: dc.w 0
    include "clip.inc"
    include "draw.inc"
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
before_plane: dcb.b 16,$a7
plane: dcb.b 10240,0
after_plane: dcb.b 16,$a7
