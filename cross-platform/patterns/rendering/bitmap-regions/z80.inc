; Caller-owned NR (32 bytes); same compile-time contract as the 6502 version.
; AF/BC/DE/HL/flags and NR+6..31 clobbered; inputs NR+0..5 preserved.
region_draw:
    xor a
    ld (NR+6),a
    ld a,(NR+4)
    or a
    ret z
    ld a,(NR+0)
    cp MAP_W
    ret nc
    ld b,a
    ld a,MAP_W
    sub b
    ld b,a
    ld a,(NR+4)
    cp b
    jr c,bounds_fit_0
    ret nz
bounds_fit_0:
    ld a,(NR+5)
    or a
    ret z
    ld a,(NR+1)
    cp MAP_H
    ret nc
    ld b,a
    ld a,MAP_H
    sub b
    ld b,a
    ld a,(NR+5)
    cp b
    jr c,bounds_fit_1
    ret nz
bounds_fit_1:
    ld a,(NR+4)
    or a
    ret z
    ld a,(NR+2)
    cp SCREEN_COLS
    ret nc
    ld b,a
    ld a,SCREEN_COLS
    sub b
    ld b,a
    ld a,(NR+4)
    cp b
    jr c,bounds_fit_2
    ret nz
bounds_fit_2:
    ld a,(NR+5)
    or a
    ret z
    ld a,(NR+3)
    cp SCREEN_ROWS
    ret nc
    ld b,a
    ld a,SCREEN_ROWS
    sub b
    ld b,a
    ld a,(NR+5)
    cp b
    jr c,bounds_fit_3
    ret nz
bounds_fit_3:
    xor a
    ld (NR+29),a
region_pass:
    xor a
    ld (NR+16),a
region_row:
    xor a
    ld (NR+17),a
region_cell:
    ld hl,MAP
    ld a,(NR+1)
    ld b,a
    ld a,(NR+16)
    add a,b
    or a
    jr z,source_column
    ld b,a
    ld de,MAP_W
source_row:
    add hl,de
    djnz source_row
source_column:
    ld a,(NR)
    ld b,a
    ld a,(NR+17)
    add a,b
    ld e,a
    ld d,0
    add hl,de
    ld a,(hl)
    ld (NR+19),a
    cp TILE_COUNT
    ret nc
    ld a,(NR+29)
    or a
    call nz,region_paint
    ld hl,NR+17
    inc (hl)
    ld a,(NR+4)
    cp (hl)
    jp nz,region_cell
    ld hl,NR+16
    inc (hl)
    ld a,(NR+5)
    cp (hl)
    jp nz,region_row
    ld a,(NR+29)
    or a
    jr nz,region_success
    inc a
    ld (NR+29),a
    jp region_pass
region_success:
    ld a,1
    ld (NR+6),a
    ret
region_paint:
    ld a,(NR+19)
    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    if CELL_BYTES = 2
    add hl,hl
    endif
    ld de,TILES
    add hl,de
    ld (NR+24),hl
    xor a
    ld (NR+18),a
region_scanline:
    ld a,(NR+3)
    ld b,a
    ld a,(NR+16)
    add a,b
    add a,a
    add a,a
    add a,a
    ld b,a
    ld a,(NR+18)
    add a,b
    ld e,a
    ld d,0
    ld hl,bitmap_lo
    add hl,de
    ld c,(hl)
    ld hl,bitmap_hi
    add hl,de
    ld b,(hl)
    ld a,(NR+2)
    ld e,a
    ld a,(NR+17)
    add a,e
    ld l,a
    ld h,0
    add hl,hl
    add hl,bc
    ex de,hl
    ld hl,(NR+24)
    ld a,(hl)
    ld (de),a
    inc hl
    inc de
    ld a,(hl)
    ld (de),a
    inc hl
    ld (NR+24),hl
    ld hl,NR+18
    inc (hl)
    ld a,(hl)
    cp 8
    jr nz,region_scanline
    ret
