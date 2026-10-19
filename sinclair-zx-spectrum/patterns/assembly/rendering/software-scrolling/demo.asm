org $8000
start:
    di
    ld sp,$ff00
    ld hl,$4000
    ld de,$4001
    ld bc,6143
    ld (hl),0
    ldir
    ld hl,$5800
    ld de,$5801
    ld bc,767
    ld (hl),71
    ldir
    ; A patterned 48-line band, leaving the rest of the bitmap untouched.
    ld d,72
    ld b,48
paint_row:
    push bc
    ld e,0
    call pixel_addr
    ld b,32
paint_byte:
    ld a,d
    and 7
    jr z,paint_solid
    cp 7
    jr z,paint_solid
    ld a,$81
    jr paint_gap
paint_solid:
    ld a,$ff
paint_gap:
    ld (hl),a
    inc hl
    djnz paint_byte
    inc d
    pop bc
    djnz paint_row
    ld hl,$cafe
    ld (ready),hl
    im 1
    ei
main:
    halt
    ; The band is intentionally small. This is not a full-screen frame budget.
    ; Prepare a repeating tile edge, one bit for every scanline.
    ld hl,edge_bits
    ld b,48
prepare_edge:
    ld a,(updates)
    and 7
    jr z,edge_solid
    ld a,b
    and 7
    jr z,edge_solid
    cp 1
    jr z,edge_solid
    xor a
    jr edge_ready
edge_solid:
    ld a,1
edge_ready:
    ld (hl),a
    inc hl
    djnz prepare_edge
    ld hl,edge_bits
    ld d,72
    ld b,48
    call scroll_band_left
    ld a,(updates)
    inc a
    ld (updates),a
    jr main
ready: defw 0
updates: defb 0
edge_bits: defs 48,0
include "scroll.inc"
include "../bitmap-addressing/bitmap-addressing.inc"
end start
