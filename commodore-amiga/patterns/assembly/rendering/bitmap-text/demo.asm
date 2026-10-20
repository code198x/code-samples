; SPDX-License-Identifier: MIT
; Original A500 PAL reset ROM, not Kickstart or an OS application.
    section code,code
BP equ $2000
COMMAND equ $2100
PIXEL_WIDTH equ 320
PIXEL_HEIGHT equ 256
BITMAP_BASE equ $10000
T equ $2200
TEXT_WIDTH equ 320
TEXT_HEIGHT equ 256
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
; A normal game call: a counted label at an arbitrary pixel position.
    move.w #21,T
    move.w #37,T+2
    lea font_data(pc),a1
    move.l a1,T+4
    lea label_data(pc),a1
    move.l a1,T+8
    move.b #10,T+12
    move.b #65,T+13
    move.b #32,T+14
    move.b #63,T+15
    move.w #64,T+16
    move.b #1,T+18
    move.b #1,T+19
    clr.b T+20
    clr.w T+22
    clr.w T+24
    move.w #320,T+26
    move.w #256,T+28
    bsr text_string
    move.b #239,COMMAND+1
    clr.b COMMAND
mailbox:
    move.b COMMAND,d0
    beq mailbox
    cmp.b #1,d0
    bne try_string
    bsr text_char
    bra complete
try_string:
    cmp.b #2,d0
    bne try_clear
    bsr text_string
    bra complete
try_clear:
    lea BITMAP_BASE,a1
    move.w #10239,d0
text_clear:
    clr.b (a1)+
    dbra d0,text_clear
complete:
    clr.b COMMAND
    bra mailbox
text_start:
    include "../../../../../cross-platform/patterns/rendering/bitmap-text/m68000.inc"
text_end:
backend_start:
    include "../../../../../cross-platform/patterns/rendering/remaining-primitives/m68000.inc"
backend_end:
font_data:
    include "../../../../../cross-platform/patterns/rendering/bitmap-text/font-m68000.inc"
label_data:
    dc.b "PIXEL TEXT"
    even
COPPER_WORDS equ 36
copper_template:
    dc.w $008e,$2c81,$0090,$2cc1,$0092,$0038,$0094,$00d0,$0100,$1200,$0102,$0000,$0104,$0000,$0108,$0000,$010a,$0000,$0180,$0000,$0182,$0fff,$0184,$00f0,$0186,$0f00,$00e0,$0001,$00e2,$0000,$00e4,$0001,$00e6,$2800,$ffff,$fffe
