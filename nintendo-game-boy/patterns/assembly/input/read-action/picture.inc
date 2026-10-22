; LCD is off at init; put 8x8 two-plane tile1 into VRAM. Main owns LCD.
init_picture:
    xor a
    ld [$c004],a
    ld hl,$8010
    ld de,glyph
    ld b,16
copy_glyph:
    ld a,[de]
    ld [hl+],a
    inc de
    dec b
    jr nz,copy_glyph
    ret
; Only call during vblank. Adjacent name entries use the same fixed palette.
draw_picture:
    xor a
    ld [$9909],a
    ld [$990a],a
    ld a,[$c000]
    and 1
    ld l,a
    ld h,0
    ld de,$9909
    add hl,de
    ld a,1
    ld [hl],a
    ret
glyph: db $3c,0,$42,0,$a5,0,$81,0,$a5,0,$99,0,$42,0,$3c,0
