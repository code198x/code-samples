; Initialise while display is off. Clear 16 KiB VRAM; 8 KiB would miss names.
; CPU owns the VDP command latch. Padding in write loops allows VDP access time.
init_picture:
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

    ld a,8
    out (VDP_CTRL),a
    ld a,$40
    out (VDP_CTRL),a
    ld hl,glyph
    ld b,8
write_glyph:
    ld a,(hl)
    out (VDP_DATA),a
    nop
    nop
    inc hl
    djnz write_glyph
    xor a
    out (VDP_CTRL),a
    ld a,$60
    out (VDP_CTRL),a
    ld a,$f1
    out (VDP_DATA),a
    xor a
    out (VDP_CTRL),a
    ld a,$5b
    out (VDP_CTRL),a
    ld a,$d0
    out (VDP_DATA),a
    ret
draw_picture:
    ld a,$8f
    out (VDP_CTRL),a
    ld a,$59
    out (VDP_CTRL),a
    xor a
    out (VDP_DATA),a
    nop
    nop
    nop
    nop
    out (VDP_DATA),a
    ld a,(TURNS)
    and 1
    add a,$8f
    out (VDP_CTRL),a
    ld a,$59
    out (VDP_CTRL),a
    ld a,1
    out (VDP_DATA),a
    ret
registers: db 0,$40,6,$80,0,$36,0,$f1
glyph: db $3c,$42,$a5,$81,$a5,$99,$42,$3c
