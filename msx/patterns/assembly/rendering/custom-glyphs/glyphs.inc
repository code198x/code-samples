; SPDX-License-Identifier: MIT
; MSX1 Graphics I: patterns $0000..07ff, name table $1800..1aff.
; G reserves 24 RAM bytes: +0 source LE word,+2 first,+3 count (1..255),
; +4 code,+5 cell LE word(0..767),+7 status,+8 LE word bytes written.
; G+10 data write port and +11 control port must be set from BIOS before init.
; Inputs +0..6,+10..11 survive; AF/BC/DE/HL/flags destroyed; non-reentrant.
; Caller owns VDP latch exclusively for entire call, IRQs disabled or coordinated.
; Fixed conservative port delay, works at standard MSX1 clock. No DI/EI here.
; Init blanks patterns and names, not colours/sprites/registers; see caller.
glyph_init:
    xor a
    ld (G+7),a
    ld hl,0
    call glyph_address
    ld de,2048
    call glyph_zero
    ld hl,$1800
    call glyph_address
    ld de,768
    call glyph_zero
    ld hl,2816
    ld (G+8),hl
    ld a,1
    ld (G+7),a
    ret
glyph_zero:
    xor a
    call glyph_out
    dec de
    ld a,d
    or e
    jr nz,glyph_zero
    ret
glyph_replace:
    ld a,1
    jr glyph_begin
glyph_install:
    ld a,(G+3)
glyph_begin:
    ld b,a
    xor a
    ld (G+7),a
    ld (G+8),a
    ld (G+9),a
    ld a,b
    or a
    ret z
    ld e,a
    ld d,0
    ld a,(G+2)
    ld l,a
    ld h,0
    add hl,de
    ld de,257
    or a
    sbc hl,de
    ret nc
    ld a,(G+2)
    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    push bc
    call glyph_address
    pop bc
    ld l,b
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    ld (G+8),hl
    ld d,h
    ld e,l
    ld hl,(G)
glyph_copy:
    ld a,(hl)
    call glyph_out
    inc hl
    dec de
    ld a,d
    or e
    jr nz,glyph_copy
    ld a,1
    ld (G+7),a
    ret
glyph_select:
    xor a
    ld (G+7),a
    ld (G+8),a
    ld (G+9),a
    ld hl,(G+5)
    ld de,768
    or a
    sbc hl,de
    ret nc
    ld hl,(G+5)
    ld de,$1800
    add hl,de
    call glyph_address
    ld a,(G+4)
    call glyph_out
    ld a,1
    ld (G+7),a
    ld (G+8),a
    ret
glyph_address:
    ld a,(G+11)
    ld c,a
    ld a,l
    call glyph_port
    ld a,h
    or $40
    call glyph_port
    ret
glyph_out:
    push af
    ld a,(G+10)
    ld c,a
    pop af
glyph_port:
    out (c),a
    nop
    nop
    nop
    nop
    ret
