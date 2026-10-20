; SPDX-License-Identifier: MIT
; Original A500 PAL reset ROM, not Kickstart or an OS application.
    section code,code
BP equ $2000
COMMAND equ $2100
PIXEL_WIDTH equ 320
PIXEL_HEIGHT equ 256
BITMAP_BASE equ $10000
start:
    move.w #$2700,sr
    move.b #3,$bfe201
    move.b #2,$bfe001
    lea $7f000,sp
    lea $dff000,a5
    move.w #$7fff,$09a(a5)
    move.w #$7fff,$09c(a5)
    move.w #$7fff,$096(a5)
    lea BITMAP_BASE,a1
    move.w #10239,d0
clear_plane:
    clr.b (a1)+
    dbra d0,clear_plane
    lea copper_template(pc),a1
    lea $4000,a2
    move.w #COPPER_WORDS-1,d0
copy_copper:
    move.w (a1)+,(a2)+
    dbra d0,copy_copper
    move.l #$4000,$080(a5)
    clr.w $088(a5)
    move.w #$8380,$096(a5)
; A normal game call: outline a box. End coordinates are exclusive.
    move.w #13,BP
    move.w #27,BP+2
    move.w #91,BP+4
    move.w #53,BP+6
    clr.b BP+8
    bsr bp_box
    move.b #239,COMMAND+1
    clr.b COMMAND
mailbox:
    move.b COMMAND,d0
    beq mailbox
    cmp.b #1,d0
    bne next_1
    bsr bp_pixel
    bra complete
next_1:
    cmp.b #2,d0
    bne next_2
    bsr bp_read
    bra complete
next_2:
    cmp.b #3,d0
    bne next_3
    bsr bp_hspan
    bra complete
next_3:
    cmp.b #4,d0
    bne next_4
    bsr bp_vspan
    bra complete
next_4:
    cmp.b #5,d0
    bne next_5
    bsr bp_fill
    bra complete
next_5:
    cmp.b #6,d0
    bne next_6
    bsr bp_box
    bra complete
next_6:
complete:
    clr.b COMMAND
    bra mailbox
backend_start:
    include "../../../../../cross-platform/patterns/rendering/remaining-primitives/m68000.inc"
backend_end:
COPPER_WORDS equ 36
copper_template:
    dc.w $008e,$2c81,$0090,$2cc1,$0092,$0038,$0094,$00d0,$0100,$1200,$0102,$0000,$0104,$0000,$0108,$0000,$010a,$0000,$0180,$0000,$0182,$0fff,$0184,$00f0,$0186,$0f00,$00e0,$0001,$00e2,$0000,$00e4,$0001,$00e6,$2800,$ffff,$fffe
