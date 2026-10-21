; SPDX-License-Identifier: MIT
; Ace 128 writable glyphs at TV-priority $2C00; names $2400, 32x24.
; G=24 private RAM bytes. LE source +0, first +2, count +3, screen code +4,
; cell word +5, output accepted +7, output data-write word +8, scratch +10..23.
; Inputs +0..6 survive. AF/BC/DE/HL/flags clobbered; non-reentrant.
; Caller owns Forth/interrupt/RAM allocation. Font is hardware write-only:
; keep the source in readable CPU RAM/ROM, never read-modify-write character RAM.
glyph_init:
    call glyph_reset_result
    ld de,$2c00
    ld bc,1024
    call glyph_zero
    ld de,$2400
    ld bc,768
    call glyph_zero
    jp glyph_accept
glyph_zero:
    xor a
    call glyph_store
    dec bc
    ld a,b
    or c
    jr nz,glyph_zero
    ret
glyph_replace:
    ld a,1
    jr glyph_begin
glyph_install:
    ld a,(G+3)
glyph_begin:
    ld (G+10),a
    call glyph_reset_result
    ld a,(G+10)
    or a
    ret z
    ld b,a
    ld a,(G+2)
    cp 128
    ret nc
    add a,b
    ret c
    cp 129
    ret nc
    ld a,(G+2)
    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    ld de,$2c00
    add hl,de
    ex de,hl
    ld a,(G+10)
    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    ld b,h
    ld c,l
    ld hl,(G)
glyph_copy:
    ld a,(hl)
    call glyph_store
    inc hl
    dec bc
    ld a,b
    or c
    jr nz,glyph_copy
glyph_accept:
    ld a,1
    ld (G+7),a
    ret
glyph_select:
    call glyph_reset_result
    ld hl,(G+5)
    ld de,768
    or a
    sbc hl,de
    ret nc
    ld hl,(G+5)
    ld de,$2400
    add hl,de
    ex de,hl
    ld a,(G+4)
    call glyph_store
    jp glyph_accept
glyph_reset_result:
    xor a
    ld (G+7),a
    ld (G+8),a
    ld (G+9),a
    ret
glyph_store:
    ld (de),a
    inc de
    push hl
    ld hl,(G+8)
    inc hl
    ld (G+8),hl
    pop hl
    ret
