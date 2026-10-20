; SPDX-License-Identifier: MIT
; DMG, unsigned background tiles $8000..8fff, map $9800..9bff.
; G reserves 24 RAM bytes: +0 source LE word,+2 first,+3 count (1..255),
; +4 code,+5 cell LE word (0..1023),+7 status,+8 LE word bytes written.
; Inputs survive; AF/BC/DE/HL/flags destroyed. Source readable/non-overlapping.
; ALL entries require LCD off (LCDC bit 7=0) and reject before writing if on.
; Caller disables LCD safely, owns VRAM, banks/IRQs. No interrupts changed here.
; Rows are low-plane byte then high-plane byte; 16 bytes per 8x8 glyph.
glyph_init:
    call glyph_reset
    ret nz
    ld hl,$8000
    ld bc,4096
    call glyph_zero
    ld hl,$9800
    ld bc,1024
    call glyph_zero
    ld hl,5120
    ld a,l
    ld [G+8],a
    ld a,h
    ld [G+9],a
    ld a,1
    ld [G+7],a
    ret
glyph_zero:
    xor a
    ld [hl],a
    inc hl
    dec bc
    ld a,b
    or c
    jr nz,glyph_zero
    ret
glyph_replace:
    ld b,1
    jr glyph_begin
glyph_install:
    ld a,[G+3]
    ld b,a
glyph_begin:
    call glyph_reset
    ret nz
    ld a,b
    or a
    ret z
    ld e,a
    ld d,0
    ld a,[G+2]
    ld l,a
    ld h,0
    add hl,de
    ld de,257
    ld a,h
    cp d
    jr c,glyph_range_ok
    ret nz
    ld a,l
    cp e
    ret nc
glyph_range_ok:
    ld a,[G+2]
    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld de,$8000
    add hl,de
    push hl
    ld l,b
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld a,l
    ld [G+8],a
    ld c,a
    ld a,h
    ld [G+9],a
    ld b,a
    ld a,[G]
    ld l,a
    ld a,[G+1]
    ld h,a
    pop de
glyph_copy:
    ld a,[hl]
    inc hl
    ld [de],a
    inc de
    dec bc
    ld a,b
    or c
    jr nz,glyph_copy
    ld a,1
    ld [G+7],a
    ret
glyph_select:
    call glyph_reset
    ret nz
    ld a,[G+6]
    cp 4
    ret nc
    add a,$98
    ld h,a
    ld a,[G+5]
    ld l,a
    ld a,[G+4]
    ld [hl],a
    ld a,1
    ld [G+7],a
    ld [G+8],a
    ret
glyph_reset:
    xor a
    ld [G+7],a
    ld [G+8],a
    ld [G+9],a
    ld a,[$ff40]
    and $80
    ret
