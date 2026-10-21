; SPDX-License-Identifier: MIT
; Graphics I 32x24 names at $1800, four row-major codes already installed.
; Q owns 8 writable bytes, disjoint from 24-byte G, code, stack and assets.
; Q+0 first code (0..252), Q+1 cell LE word; these inputs survive.
; Q+3 status 1 accepted/0 rejected, Q+4 data writes 4/0, Q+5..7 private.
; G+10/+11 are the data/control ports; all G bytes survive.
; AF/BC/DE/HL/flags clobbered. No DI/EI. Reserve 12 stack bytes including call.
; Own the VDP latch/interrupt policy throughout; see unchanged glyphs.inc.
quad_select:
    xor a
    ld (Q+3),a
    ld (Q+4),a
    ld a,(Q)
    cp 253
    ret nc
    ld (Q+5),a
    ld hl,(Q+1)
    ld de,736
    or a
    sbc hl,de
    ret nc
    ld hl,(Q+1)
    ld a,l
    and 31
    cp 31
    ret z
    ld (Q+6),hl
    ld de,$1800
    add hl,de
    call quad_row
    ld a,(Q+5)
    add a,2
    ld (Q+5),a
    ld hl,(Q+6)
    ld de,32
    add hl,de
    ld de,$1800
    add hl,de
    call quad_row
    ld a,4
    ld (Q+4),a
    ld a,1
    ld (Q+3),a
    ret
quad_row:
    call glyph_address
    ld a,(Q+5)
    call glyph_out
    inc a
    call glyph_out
    ret
