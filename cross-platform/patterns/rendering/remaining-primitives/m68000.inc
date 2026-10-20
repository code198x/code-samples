; SPDX-License-Identifier: MIT
; One selected 320-wide Chip RAM plane; byte spans, native big-endian BP words.
; BP: 48 even-aligned private RAM bytes. BITMAP_BASE and PIXEL_WIDTH/HEIGHT are constants.
; Public +0/2 x0/y0, +4/6 exclusive x1/y1, +8 op0=set/1=clear/2=XOR.
; Outputs +9 accepted, +10 stored read bit, +40 word destination-byte stores.
; Inputs +0..8 and +11 survive. D0-D7/A1/CCR destroyed; SR interrupt bits unchanged.
; CPU owns this plane during a call: no blitter, Copper pointer change or IRQ writer.
bp_fill:
    moveq #0,d0
    bra bp_enter
bp_box:
    moveq #1,d0
    bra bp_enter
bp_pixel:
    moveq #2,d0
    bra bp_enter
bp_read:
    moveq #3,d0
    bra bp_enter
bp_hspan:
    moveq #4,d0
    bra bp_enter
bp_vspan:
    moveq #5,d0
bp_enter:
    move.b d0,BP+12
    clr.b BP+9
    clr.b BP+10
    clr.w BP+40
    move.l BP,BP+16
    move.l BP+4,BP+20
    cmp.b #2,d0
    blo bp_validate
    cmp.b #5,d0
    beq bp_unit_x
    move.w BP+18,d1
    addq.w #1,d1
    move.w d1,BP+22
    cmp.b #4,d0
    beq bp_validate
bp_unit_x:
    move.w BP+16,d1
    addq.w #1,d1
    move.w d1,BP+20
bp_validate:
    cmp.b #3,BP+8
    bhs bp_invalid
    cmp.b #3,BP+12
    bne bp_bounds
    tst.b BP+8
    bne bp_invalid
bp_bounds:
    move.w BP+16,d0
    cmp.w BP+20,d0
    bhs bp_invalid
    cmp.w #PIXEL_WIDTH,BP+20
    bhi bp_invalid
    move.w BP+18,d0
    cmp.w BP+22,d0
    bhs bp_invalid
    cmp.w #PIXEL_HEIGHT,BP+22
    bhi bp_invalid
    move.b #1,BP+9
    move.w BP+16,d2
    lsr.w #3,d2
    move.w BP+20,d3
    subq.w #1,d3
    lsr.w #3,d3
    move.w BP+16,d1
    and.w #7,d1
    move.w #$ff,d6
    lsr.w d1,d6
    move.w BP+20,d1
    subq.w #1,d1
    and.w #7,d1
    moveq #7,d0
    sub.w d1,d0
    move.w #$ff,d7
    lsl.w d0,d7
    move.w BP+18,d4
bp_row:
    move.w d4,d0
    mulu.w #40,d0
    lea BITMAP_BASE,a1
    adda.l d0,a1
    adda.w d2,a1
    move.w d2,d5
bp_byte:
    move.w #$ff,d0
    cmp.w d2,d5
    bne bp_not_left
    and.w d6,d0
bp_not_left:
    cmp.w d3,d5
    bne bp_not_right
    and.w d7,d0
bp_not_right:
    cmp.b #1,BP+12
    bne bp_apply
    cmp.w BP+18,d4
    beq bp_apply
    move.w BP+22,d1
    subq.w #1,d1
    cmp.w d1,d4
    beq bp_apply
    moveq #0,d0
    cmp.w d2,d5
    bne bp_box_right
    move.w BP+16,d1
    and.w #7,d1
    move.w #$80,d0
    lsr.w d1,d0
bp_box_right:
    cmp.w d3,d5
    bne bp_apply
    move.w BP+20,d1
    subq.w #1,d1
    and.w #7,d1
    move.w d0,BP+44
    move.w #$80,d0
    lsr.w d1,d0
    or.w BP+44,d0
bp_apply:
    tst.b d0
    beq bp_advance
    cmp.b #3,BP+12
    bne bp_draw
    and.b (a1),d0
    beq bp_invalid
    move.b #1,BP+10
    rts
bp_draw:
    cmp.b #1,BP+8
    beq bp_clear
    cmp.b #2,BP+8
    beq bp_xor
    or.b d0,(a1)
    bra bp_count
bp_clear:
    not.b d0
    and.b d0,(a1)
    bra bp_count
bp_xor:
    eor.b d0,(a1)
bp_count:
    addq.w #1,BP+40
bp_advance:
    addq.l #1,a1
    addq.w #1,d5
    cmp.w d3,d5
    bls bp_byte
    addq.w #1,d4
    cmp.w BP+22,d4
    blo bp_row
bp_invalid:
    rts
