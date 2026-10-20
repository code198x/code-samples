; SPDX-License-Identifier: MIT
; Original reset caller; mailbox only serves independent verification.
SECTION "Header", ROM0[$100]
    nop
    jp start
    ds $134-@,0
    db "GLYPHS"
    ds $150-@,0
SECTION "Code", ROM0[$150]
DEF G EQU $c000
DEF COMMAND EQU $c100
start:
    di
    ld sp,$fffe
    call lcd_off
    xor a
    ld [$ff42],a
    ld [$ff43],a
    ld a,$e4
    ld [$ff47],a
    ld hl,$9000
    ld b,16
    ld a,165
seed_guards:
    ld [hl],a
    inc hl
    dec b
    jr nz,seed_guards
    call glyph_init
; The example source is 2bpp: low plane then high plane for each row.
    ld hl,original_glyphs
    ld a,l
    ld [G],a
    ld a,h
    ld [G+1],a
    ld a,1
    ld [G+2],a
    ld a,2
    ld [G+3],a
    call glyph_install
    ld a,1
    ld [G+4],a
    xor a
    ld [G+6],a
    ld a,66
    ld [G+5],a
    call glyph_select
    ld a,67
    ld [G+5],a
    call glyph_select
    ld a,$91
    ld [$ff40],a
    xor a
    ld [COMMAND],a
    ld a,239
    ld [COMMAND+1],a
mailbox:
    ld a,[COMMAND]
    or a
    jr z,mailbox
    cp 5
    jr z,complete
    cp 6
    jr z,live_reject
    push af
    call lcd_off
    pop af
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
live_reject:
    call glyph_install
complete:
    ld a,$91
    ld [$ff40],a
    xor a
    ld [COMMAND],a
    jp mailbox
lcd_off:
    ld a,[$ff40]
    bit 7,a
    ret z
wait_vblank:
    ld a,[$ff44]
    cp 145
    jr c,wait_vblank
    xor a
    ld [$ff40],a
    ret
    INCLUDE "glyphs.inc"
original_glyphs:
    db 129,0,66,0,36,0,24,0,24,0,36,0,66,0,129,0
    db 255,255,129,0,165,0,129,0,165,0,153,0,129,0,255,255
