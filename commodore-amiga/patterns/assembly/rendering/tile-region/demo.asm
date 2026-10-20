; Original reset ROM; not a Kickstart program or OS coexistence demonstration.
    section code,code
NR equ $2000
RESULT equ $2040
MAP equ $20f0
TILES equ $6000
PLANE0 equ $10000
PLANE1 equ $12800
SCREEN_COLS equ 20
SCREEN_ROWS equ 32
BACKEND equ 0
start:
    move.w #$2700,sr
    move.b #3,$bfe201
    move.b #2,$bfe001
    lea $7f000,sp
    lea $dff000,a5
    move.w #$7fff,$09a(a5)
    move.w #$7fff,$09c(a5)
    move.w #$7fff,$096(a5)
    move.w #$8240,$096(a5)
    lea PLANE0,a1
    move.w #20479,d0
clear_planes:
    clr.b (a1)+
    dbra d0,clear_planes
    lea initial_map(pc),a1
    lea MAP,a2
    moveq #95,d0
copy_map:
    move.b (a1)+,(a2)+
    dbra d0,copy_map
    lea tile_template(pc),a1
    lea TILES,a2
    moveq #127,d0
copy_tiles:
    move.b (a1)+,(a2)+
    dbra d0,copy_tiles
    lea copper_template(pc),a1
    lea $4000,a2
    move.w #COPPER_WORDS-1,d0
copy_copper:
    move.w (a1)+,(a2)+
    dbra d0,copy_copper
    lea $fff0,a1
    lea $15000,a2
    moveq #15,d0
set_guards:
    move.b #$a5,(a1)+
    move.b #$a5,(a2)+
    dbra d0,set_guards
    lea NR,a0
    move.b #BACKEND,7(a0)
    move.l #MAP,8(a0)
    move.l #TILES,12(a0)
    move.l #PLANE0,16(a0)
    move.l #PLANE1,20(a0)
    move.b #12,24(a0)
    move.b #8,25(a0)
    move.b #4,26(a0)
case_0:
    move.b #2,0(a0)
    move.b #1,1(a0)
    move.b #4,2(a0)
    move.b #3,3(a0)
    move.b #5,4(a0)
    move.b #3,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+1
case_1:
    move.b #0,0(a0)
    move.b #0,1(a0)
    move.b #6,2(a0)
    move.b #4,3(a0)
    move.b #1,4(a0)
    move.b #1,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+2
case_2:
    move.b #11,0(a0)
    move.b #7,1(a0)
    move.b #19,2(a0)
    move.b #31,3(a0)
    move.b #1,4(a0)
    move.b #1,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+3
case_3:
    move.b #12,0(a0)
    move.b #0,1(a0)
    move.b #0,2(a0)
    move.b #0,3(a0)
    move.b #1,4(a0)
    move.b #1,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+4
case_4:
    move.b #0,0(a0)
    move.b #8,1(a0)
    move.b #0,2(a0)
    move.b #0,3(a0)
    move.b #1,4(a0)
    move.b #1,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+5
case_5:
    move.b #0,0(a0)
    move.b #0,1(a0)
    move.b #20,2(a0)
    move.b #0,3(a0)
    move.b #1,4(a0)
    move.b #1,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+6
case_6:
    move.b #0,0(a0)
    move.b #0,1(a0)
    move.b #0,2(a0)
    move.b #32,3(a0)
    move.b #1,4(a0)
    move.b #1,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+7
case_7:
    move.b #0,0(a0)
    move.b #0,1(a0)
    move.b #0,2(a0)
    move.b #0,3(a0)
    move.b #0,4(a0)
    move.b #1,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+8
case_8:
    move.b #0,0(a0)
    move.b #0,1(a0)
    move.b #0,2(a0)
    move.b #0,3(a0)
    move.b #1,4(a0)
    move.b #0,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+9
case_9:
    move.b #11,0(a0)
    move.b #0,1(a0)
    move.b #0,2(a0)
    move.b #0,3(a0)
    move.b #2,4(a0)
    move.b #1,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+10
case_10:
    move.b #0,0(a0)
    move.b #7,1(a0)
    move.b #0,2(a0)
    move.b #0,3(a0)
    move.b #1,4(a0)
    move.b #2,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+11
case_11:
    move.b #0,0(a0)
    move.b #0,1(a0)
    move.b #19,2(a0)
    move.b #0,3(a0)
    move.b #2,4(a0)
    move.b #1,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+12
case_12:
    move.b #0,0(a0)
    move.b #0,1(a0)
    move.b #0,2(a0)
    move.b #31,3(a0)
    move.b #1,4(a0)
    move.b #2,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+13
case_13:
    move.b #255,0(a0)
    move.b #0,1(a0)
    move.b #0,2(a0)
    move.b #0,3(a0)
    move.b #2,4(a0)
    move.b #1,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+14
case_14:
    move.b #0,0(a0)
    move.b #0,1(a0)
    move.b #255,2(a0)
    move.b #0,3(a0)
    move.b #2,4(a0)
    move.b #1,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+15
case_15:
    move.b #0,0(a0)
    move.b #0,1(a0)
    move.b #0,2(a0)
    move.b #255,3(a0)
    move.b #1,4(a0)
    move.b #2,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+16
case_16:
    move.b #0,0(a0)
    move.b #0,1(a0)
    move.b #0,2(a0)
    move.b #0,3(a0)
    move.b #255,4(a0)
    move.b #1,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+17
case_17:
    move.b #255,MAP+13
    move.b #0,0(a0)
    move.b #1,1(a0)
    move.b #0,2(a0)
    move.b #0,3(a0)
    move.b #2,4(a0)
    move.b #1,5(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+18
diagnostic_done:
    clr.b MAP+13
    move.b #2,7(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+19
    move.b #BACKEND,7(a0)
    addq.l #1,12(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+20
    subq.l #1,12(a0)
    addq.l #1,16(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+21
    subq.l #1,16(a0)
    addq.l #1,20(a0)
    bsr region_draw
    move.b 6(a0),d0
    or.b #128,d0
    move.b d0,RESULT+22
    subq.l #1,20(a0)
    lea $dff000,a5
    move.l #$4000,$080(a5)
    clr.w $088(a5)
    move.w #$83c0,$096(a5)
    move.b #239,RESULT
finished:
    bra finished
    include "../../../../../cross-platform/patterns/rendering/region-architectures/m68000.inc"
initial_map:
    dc.b 0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1
    even
tile_template:
    dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
    dc.w $aaaa,$5555,$aaaa,$5555,$aaaa,$5555,$aaaa,$5555,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
    dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$ffff,$8001,$8001,$8001,$8001,$8001,$8001,$ffff
    dc.w $8001,$4002,$2004,$1008,$0810,$0420,$0240,$0180,$8001,$4002,$2004,$1008,$0810,$0420,$0240,$0180
COPPER_WORDS equ 36
copper_template:
    dc.w $008e,$2c81,$0090,$2cc1,$0092,$0038,$0094,$00d0,$0100,$2200,$0102,$0000,$0104,$0000,$0108,$0000,$010a,$0000,$0180,$0000,$0182,$0fff,$0184,$00f0,$0186,$0f00,$00e0,$0001,$00e2,$0000,$00e4,$0001,$00e6,$2800,$ffff,$fffe
