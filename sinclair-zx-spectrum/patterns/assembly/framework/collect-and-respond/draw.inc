; Draw 8x8 monochrome glyph: B=x,C=y,DE=eight bytes; all AF/BC/DE/HL change.
; Logical grid is inset at character column 8,row 6. ULA bitmap interleave
; means successive glyph scanlines differ by $100, not 32 bytes.
put_cell:
    ld a,c
    add a,6
    ld c,a
    and 24
    or $40
    ld h,a
    ld a,c
    and 7
    rrca
    rrca
    rrca
    add a,b
    add a,8
    ld l,a
    ld b,8
glyph_row:
    ld a,(de)
    ld (hl),a
    inc de
    inc h
    djnz glyph_row
    ret
draw_screen:
    ld a,(old_x)
    ld b,a
    ld a,(old_y)
    ld c,a
    ld de,blank
    call put_cell
    ld b,10
    ld c,5
    ld de,blank
    ld a,(item_active)
    or a
    jr z,target_shape
    ld de,target
target_shape:
    call put_cell
    ld a,(player_x)
    ld b,a
    ld (old_x),a
    ld a,(player_y)
    ld c,a
    ld (old_y),a
    ld de,player
    call put_cell
    ld b,0
    ld c,0
    ld de,zero
    ld a,(score)
    or a
    jr z,score_shape
    ld de,one
score_shape:
    jp put_cell
blank: defb 0,0,0,0,0,0,0,0
player: defb 24,60,126,219,255,90,36,0
target: defb 0,24,90,60,90,24,0,0
zero: defb 60,66,70,74,82,98,60,0
one: defb 24,56,24,24,24,24,126,0
