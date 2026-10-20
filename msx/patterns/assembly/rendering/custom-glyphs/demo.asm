; SPDX-License-Identifier: MIT
; Original reset caller; mailbox only serves independent verification.
G equ $f000
COMMAND equ $f100
org 0
jp start
db 0,0,0,$98,$98
org $100
start:
    di
    ld sp,$fef0
    ld a,$f0
    out ($a8),a
    ld a,(7)
    ld (G+10),a
    inc a
    ld (G+11),a
    ld hl,registers
    ld e,0
register_loop:
    ld a,(G+11)
    ld c,a
    ld a,(hl)
    call glyph_port
    ld a,e
    or $80
    call glyph_port
    inc hl
    inc e
    ld a,e
    cp 8
    jr nz,register_loop
    ld hl,$0800
    call glyph_address
    ld b,16
seed_guards:
    ld a,165
    call glyph_out
    djnz seed_guards
    call glyph_init
    ld hl,$2000
    call glyph_address
    ld b,32
colours:
    ld a,$f1
    call glyph_out
    djnz colours
    ld hl,$1b00
    call glyph_address
    ld a,$d0
    call glyph_out
; Install two original glyphs; two name entries share code 1.
    ld hl,original_glyphs
    ld (G),hl
    ld a,1
    ld (G+2),a
    ld a,2
    ld (G+3),a
    call glyph_install
    ld a,1
    ld (G+4),a
    ld hl,66
    ld (G+5),hl
    call glyph_select
    ld hl,67
    ld (G+5),hl
    call glyph_select
    xor a
    ld (COMMAND),a
    ld a,239
    ld (COMMAND+1),a
mailbox:
    ld a,(COMMAND)
    or a
    jr z,mailbox
    cp 1
    jr nz,command_2
    call glyph_init
    jp complete
command_2:
    cp 2
    jr nz,command_3
    call glyph_install
    jp complete
command_3:
    cp 3
    jr nz,command_4
    call glyph_replace
    jp complete
command_4:
    cp 4
    jr nz,command_5
    call glyph_select
    jp complete
command_5:
complete:
    ld a,(G+11)
    ld c,a
    xor a
    call glyph_port
    call glyph_port
    ld a,(6)
    ld c,a
    ld hl,$c000
    ld de,$3000
read_vram:
    in a,(c)
    ld (hl),a
    nop
    nop
    nop
    nop
    inc hl
    dec de
    ld a,d
    or e
    jr nz,read_vram
    xor a
    ld (COMMAND),a
    jp mailbox
registers:
    db 0,$c0,6,$80,0,$36,7,$f1
    include "glyphs.inc"
original_glyphs:
    db 129,66,36,24,24,36,66,129,255,129,165,129,165,153,129,255
