; SPDX-License-Identifier: MIT
; Original Graphics I caller for sord-m5; no system firmware.
; Own foreground CPU, private G context, VDP registers/VRAM and its address latch.
; IRQs disabled; coordinate NMI/other VDP users separately. No OS coexistence.
Q equ $7220
G equ $7200
COMMAND equ $7228
DUMP_ADDRESS equ $722c
BUFFER equ $7000
READ_PORT equ $10
org 0
jp start
org $100
start:
    di
    ld sp,$7ff0
    ld a,$10
    ld (G+10),a
    ld a,$11
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
; Blank all VRAM once, then seed distinctive bytes outside the owned font/names.
    ld hl,0
    call glyph_address
    ld de,$4000
    call glyph_zero
    ld hl,$0800
    call glyph_address
    ld b,16
seed_guards:
    ld a,$a5
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
    include "prepare.inc"
; Diagnostic transport below is not required by a game.
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
    jr complete
command_2:
    cp 2
    jr nz,command_3
    call glyph_install
    jr complete
command_3:
    cp 3
    jr nz,command_4
    call glyph_replace
    jr complete
command_4:
    cp 4
    jr nz,command_5
    call glyph_select
    jr complete
command_5:
    cp 6
    jr nz,command_5_read
    call quad_select
    jr complete
command_5_read:
    cp 5
    jr nz,complete
; Snapshot exactly 256 VRAM bytes into the private CPU buffer. Set read address,
; not write address; the VDP prefetches its first byte before the first IN.
    ld a,(G+11)
    ld c,a
    ld a,(DUMP_ADDRESS)
    call glyph_port
    ld a,(DUMP_ADDRESS+1)
    call glyph_port
    ld c,READ_PORT
    ld hl,BUFFER
    ld b,0
read_vram:
    in a,(c)
    ld (hl),a
    nop
    nop
    nop
    nop
    inc hl
    djnz read_vram
complete:
    xor a
    ld (COMMAND),a
    jr mailbox
registers:
    db 0,$c0,6,$80,0,$36,7,$f1
kernel_start:
    include "../../../../../msx/patterns/assembly/rendering/custom-glyphs/glyphs.inc"
kernel_end:
quad_start:
    include "../../../../../cross-platform/patterns/rendering/character-quads/z80.inc"
quad_end:
    include "assets.inc"
