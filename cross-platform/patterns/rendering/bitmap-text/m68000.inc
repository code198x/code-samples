; SPDX-License-Identifier: MIT
; 8x8 fixed-width bitmap text over bp_hspan. Native big-endian, 32-bit pointers.
; T:96 even-aligned private bytes; BP:48 separate bytes. No hidden scene/OS/IRQ.
; +0/2 signed origin; +4 font long; +8 string long; +12 length; +13 char;
; +14 first; +15 fallback; +16 glyph count word; +18 mode; +19/20 fg/bg;
; +21 accepted; +22/24/26/28 scissor L/T/R/B words (exclusive ends);
; +30 nextX word; +32 consumed; +33 substitutions; +34 span word; +36 stores long.
; +40..95 scratch. Public 0..20 and 22..29 survive. D0-D7/A1/CCR clobbered.
; Caller supplies readable stable allocations and owns plane, banks and DMA/IRQ access.
text_char:
    move.b #1,T+60
    moveq #1,d0
    bra text_begin
text_string:
    clr.b T+60
    moveq #0,d0
    move.b T+12,d0
text_begin:
    move.w d0,T+40
    clr.b T+21
    move.w T,T+30
    clr.b T+32
    clr.b T+33
    clr.w T+34
    clr.l T+36
    cmp.w #-512,T
    blt text_return
    cmp.w #511,T
    bgt text_return
    cmp.w #-512,T+2
    blt text_return
    cmp.w #511,T+2
    bgt text_return
    cmp.b #1,T+18
    bhi text_return
    cmp.b #1,T+19
    bhi text_return
    cmp.b #1,T+20
    bhi text_return
    move.w T+22,d0
    cmp.w T+26,d0
    bhs text_return
    cmp.w #TEXT_WIDTH,T+26
    bhi text_return
    move.w T+24,d0
    cmp.w T+28,d0
    bhs text_return
    cmp.w #TEXT_HEIGHT,T+28
    bhi text_return
    moveq #0,d1
    move.w T+16,d1
    beq text_return
    cmp.w #256,d1
    bhi text_return
    moveq #0,d0
    move.b T+14,d0
    add.w d0,d1
    cmp.w #256,d1
    bhi text_return
    moveq #0,d2
    move.b T+15,d2
    cmp.w d0,d2
    blo text_return
    cmp.w d1,d2
    bhs text_return
    move.l T+4,d0
    cmp.l #$ffffff,d0
    bhi text_return
    moveq #0,d1
    move.w T+16,d1
    lsl.l #3,d1
    add.l d0,d1
    cmp.l #$1000000,d1
    bhi text_return
    tst.b T+60
    bne text_valid
    move.l T+8,d0
    cmp.l #$ffffff,d0
    bhi text_return
    moveq #0,d1
    move.w T+40,d1
    add.l d0,d1
    cmp.l #$1000000,d1
    bhi text_return
text_valid:
    move.b #1,T+21
    clr.w T+42
    tst.w T+40
    beq text_return
text_glyph:
    moveq #0,d0
    tst.b T+60
    beq text_from_string
    move.b T+13,d0
    bra text_lookup
text_from_string:
    move.l T+8,a1
    moveq #0,d1
    move.w T+42,d1
    adda.l d1,a1
    move.b (a1),d0
text_lookup:
    moveq #0,d1
    move.b T+14,d1
    cmp.w d1,d0
    blo text_fallback
    add.w T+16,d1
    cmp.w d1,d0
    blo text_have_code
text_fallback:
    move.b T+15,d0
    addq.b #1,T+33
text_have_code:
    moveq #0,d1
    move.b T+14,d1
    sub.w d1,d0
    lsl.w #3,d0
    move.w d0,T+44
    clr.w T+46
text_row:
    move.w T+2,d2
    add.w T+46,d2
    move.w d2,T+52
    tst.b T+18
    beq text_load_row
    move.w T+30,d0
    move.w d0,d1
    addq.w #8,d1
    moveq #0,d3
    move.b T+20,d3
    bsr text_emit
text_load_row:
    move.l T+4,a1
    moveq #0,d0
    move.w T+44,d0
    add.w T+46,d0
    adda.l d0,a1
    move.b (a1),T+48
    clr.b T+49
    move.w #-1,T+50
text_column:
    moveq #0,d0
    move.b T+48,d0
    andi.b #$80,d0
    beq text_zero
    tst.w T+50
    bpl text_shift
    moveq #0,d0
    move.b T+49,d0
    move.w d0,T+50
    bra text_shift
text_zero:
    tst.w T+50
    bmi text_shift
    move.w T+30,d0
    add.w T+50,d0
    moveq #0,d1
    move.b T+49,d1
    add.w T+30,d1
    move.w T+52,d2
    moveq #0,d3
    move.b T+19,d3
    bsr text_emit
    move.w #-1,T+50
text_shift:
    move.b T+48,d0
    add.b d0,d0
    move.b d0,T+48
    addq.b #1,T+49
    cmp.b #8,T+49
    blo text_column
    tst.w T+50
    bmi text_next_row
    move.w T+30,d0
    add.w T+50,d0
    move.w T+30,d1
    addq.w #8,d1
    move.w T+52,d2
    moveq #0,d3
    move.b T+19,d3
    bsr text_emit
text_next_row:
    addq.w #1,T+46
    cmp.w #8,T+46
    blo text_row
    addq.w #8,T+30
    addq.b #1,T+32
    addq.w #1,T+42
    subq.w #1,T+40
    bne text_glyph
text_return:
    rts
text_emit:
    cmp.w T+24,d2
    blt text_return
    cmp.w T+28,d2
    bge text_return
    cmp.w T+22,d0
    bge text_left_inside
    move.w T+22,d0
text_left_inside:
    cmp.w T+26,d1
    ble text_right_inside
    move.w T+26,d1
text_right_inside:
    cmp.w d1,d0
    bge text_return
    move.w d0,BP
    move.w d1,BP+4
    move.w d2,BP+2
    clr.b BP+8
    tst.b d3
    bne text_pen_set
    move.b #1,BP+8
text_pen_set:
    bsr bp_hspan
    addq.w #1,T+34
    moveq #0,d0
    move.w BP+40,d0
    add.l d0,T+36
    rts
