; D0=x,D1=y,A0=eight glyph bytes. Destroys D0/D1/D2/A0/A1/CCR.
; Draw into chip-RAM one-bitplane display, no blitter required. Row stride40.
; Called at frame boundary; four glyphs are cheap here but not a sprite engine.
put_cell:
    addq.w #6,d1
    mulu #320,d1
    add.w d0,d1
    addq.w #8,d1
    lea plane,a1
    adda.l d1,a1
    moveq #7,d2
glyph_row:
    move.b (a0)+,(a1)
    adda.w #40,a1
    dbra d2,glyph_row
    rts
draw_screen:
    move.w old_x,d0
    move.w old_y,d1
    lea blank,a0
    bsr put_cell
    move.w #10,d0
    move.w #5,d1
    lea blank,a0
    tst.w item_active
    beq target_shape
    lea target,a0
target_shape:
    bsr put_cell
    move.w player_x,d0
    move.w d0,old_x
    move.w player_y,d1
    move.w d1,old_y
    lea player,a0
    bsr put_cell
    moveq #0,d0
    moveq #0,d1
    lea zero,a0
    tst.w score
    beq score_shape
    lea one,a0
score_shape:
    bra put_cell
blank: dc.b 0,0,0,0,0,0,0,0
player: dc.b 24,60,126,219,255,90,36,0
target: dc.b 0,24,90,60,90,24,0,0
zero: dc.b 60,66,70,74,82,98,60,0
one: dc.b 24,56,24,24,24,24,126,0
    even
