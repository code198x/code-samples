; Initialise while display is off. Clear 16 KiB VRAM; 8 KiB would miss names.
; CPU owns the VDP command latch. Padding in write loops allows VDP access time.
init_picture:
    ld a,$9f
    out (PSG),a
    ld a,$bf
    out (PSG),a
    ld a,$df
    out (PSG),a
    ld a,$ff
    out (PSG),a
    xor a
    ld (SOUND_TICKS),a
    in a,(VDP_CTRL)
    xor a
    out (VDP_CTRL),a
    ld a,$81
    out (VDP_CTRL),a
    xor a
    out (VDP_CTRL),a
    ld a,$40
    out (VDP_CTRL),a
    ld bc,$4000
clear_vram:
    xor a
    out (VDP_DATA),a
    nop
    nop
    dec bc
    ld a,b
    or c
    jr nz,clear_vram
    ld hl,registers
    ld b,8
    ld c,$80
vdp_register:
    ld a,(hl)
    out (VDP_CTRL),a
    ld a,c
    out (VDP_CTRL),a
    inc hl
    inc c
    djnz vdp_register

    ld a,$20
    out (VDP_CTRL),a
    ld a,$40
    out (VDP_CTRL),a
    ld hl,glyph
    ld b,32
write_glyph:
    ld a,(hl)
    out (VDP_DATA),a
    inc hl
    djnz write_glyph
    xor a
    out (VDP_CTRL),a
    ld a,$c0
    out (VDP_CTRL),a
    ld hl,palette
    ld b,PALETTE_BYTES
write_palette:
    ld a,(hl)
    out (VDP_DATA),a
    inc hl
    djnz write_palette
    xor a
    out (VDP_CTRL),a
    ld a,$7f
    out (VDP_CTRL),a
    ld a,$d0
    out (VDP_DATA),a
    ret
draw_picture:
    ld a,$1e
    out (VDP_CTRL),a
    ld a,$7b
    out (VDP_CTRL),a
    xor a
    out (VDP_DATA),a
    out (VDP_DATA),a
    out (VDP_DATA),a
    out (VDP_DATA),a
    ld a,(TURNS)
    and 1
    add a,a
    add a,$1e
    out (VDP_CTRL),a
    ld a,$7b
    out (VDP_CTRL),a
    ld a,1
    out (VDP_DATA),a
    xor a
    out (VDP_DATA),a
    ret
registers: db 4,$40,$0e,0,0,$7e,0,0
glyph: db $3c,0,0,0,$42,0,0,0,$a5,0,0,0,$81,0,0,0
       db $a5,0,0,0,$99,0,0,0,$42,0,0,0,$3c,0,0,0
PALETTE_BYTES equ 4
palette: db 0,0,$ff,$0f
