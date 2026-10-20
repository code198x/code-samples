; SPDX-License-Identifier: MIT
; Original reset caller. No manufacturer firmware is distributed.
T equ $7200
TEXT_WIDTH equ 256
TEXT_HEIGHT equ 192
TEXT_PEN_MAX equ 1
; SPDX-License-Identifier: MIT
; Original reset fixture; mailbox is verification transport, not a game loop.
org 0
BP equ $7000
COMMAND equ $7100
start:
    di
    ld sp,$ff00
    xor a
    out ($fe),a
    ld hl,$4000
    ld de,$4001
    ld bc,6143
    ld (hl),a
    ldir
    ld hl,$5800
    ld de,$5801
    ld bc,767
    ld (hl),7
    ldir
    xor a
    ld (COMMAND),a
    ld a,$ef
    ld (COMMAND+1),a
TEXT_PACKED equ 0
; A normal game call: eight-pixel advance, off-grid origin, opaque label.
    ld hl,21
    ld (T+0),hl
    ld hl,37
    ld (T+2),hl
    ld hl,font_data
    ld (T+4),hl
    ld hl,label_data
    ld (T+6),hl
    ld hl,64
    ld (T+11),hl
    ld hl,0
    ld (T+18),hl
    ld hl,0
    ld (T+20),hl
    ld hl,256
    ld (T+22),hl
    ld hl,192
    ld (T+24),hl
    ld a,10
    ld (T+8),a
    ld a,65
    ld (T+9),a
    ld a,32
    ld (T+10),a
    ld a,63
    ld (T+13),a
    ld a,1
    ld (T+14),a
    ld a,1
    ld (T+15),a
    ld a,0
    ld (T+16),a
    call text_string
    ld a,0
    ld (COMMAND),a
    ld a,239
    ld (COMMAND+1),a
mailbox:
    ld a,(COMMAND)
    or a
    jr z,mailbox
    cp 1
    jr nz,do_string
    call text_char
    jp complete
do_string:
    cp 2
    jr nz,do_clear
    call text_string
    jp complete
do_clear:
    call clear_screen
complete:
    xor a
    ld (COMMAND),a
    jp mailbox
clear_screen:
    ld hl,0
    ld (BP+0),hl
    ld hl,0
    ld (BP+2),hl
    ld hl,256
    ld (BP+4),hl
    ld hl,192
    ld (BP+6),hl
    ld a,1
    ld (BP+8),a
    ld a,1
    ld (BP+11),a
    call bp_fill
    ret
    include "../../../../../cross-platform/patterns/rendering/bitmap-text/z80.inc"
text_backend_start:
    include "../../../../../cross-platform/patterns/rendering/drawing-foundations/z80.inc"
    include "../bitmap-addressing/bitmap-addressing.inc"
text_backend_end:
font_data:
    include "../../../../../cross-platform/patterns/rendering/bitmap-text/font-z80.inc"
font_end:
label_data:
    db 80,73,88,69,76,32,84,69,88,84
