TL equ 17536
; SPDX-License-Identifier: MIT
; Original reset caller. No manufacturer firmware is distributed.
T equ $4400
TEXT_WIDTH equ 320
TEXT_HEIGHT equ 200
TEXT_PEN_MAX equ 3
org 0
BP equ $4300
COMMAND equ $4200
start:
    di
    ld sp,$bf00
    ; MODE 1; upper ROM disabled, lower ROM remains for this reset fixture.
    ld bc,$7f89
    out (c),c
    ld bc,$bc00
    out (c),c
    ld bc,$bd3f
    out (c),c
    ld bc,$bc01
    out (c),c
    ld bc,$bd28
    out (c),c
    ld bc,$bc02
    out (c),c
    ld bc,$bd2e
    out (c),c
    ld bc,$bc03
    out (c),c
    ld bc,$bd8e
    out (c),c
    ld bc,$bc04
    out (c),c
    ld bc,$bd26
    out (c),c
    ld bc,$bc05
    out (c),c
    ld bc,$bd00
    out (c),c
    ld bc,$bc06
    out (c),c
    ld bc,$bd19
    out (c),c
    ld bc,$bc07
    out (c),c
    ld bc,$bd1e
    out (c),c
    ld bc,$bc08
    out (c),c
    ld bc,$bd00
    out (c),c
    ld bc,$bc09
    out (c),c
    ld bc,$bd07
    out (c),c
    ld bc,$bc0a
    out (c),c
    ld bc,$bd00
    out (c),c
    ld bc,$bc0b
    out (c),c
    ld bc,$bd00
    out (c),c
    ld bc,$bc0c
    out (c),c
    ld bc,$bd30
    out (c),c
    ld bc,$bc0d
    out (c),c
    ld bc,$bd00
    out (c),c
    ld bc,$7f00
    out (c),c
    ld c,84
    out (c),c
    ld bc,$7f01
    out (c),c
    ld c,75
    out (c),c
    ld bc,$7f02
    out (c),c
    ld c,82
    out (c),c
    ld bc,$7f03
    out (c),c
    ld c,85
    out (c),c
    ld bc,$7f10
    out (c),c
    ld c,$54
    out (c),c
    ld hl,$c000
    ld de,$c001
    ld bc,$3fff
    ld (hl),0
    ldir
TEXT_PACKED equ 1
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
    ld hl,320
    ld (T+22),hl
    ld hl,200
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
    include "prepare.inc"
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
    call layout_measure
    jp complete
do_string:
    cp 2
    jr nz,do_clear
    call layout_line
    jp complete
do_clear:
    cp 4
    jr nz,clear_only
    call layout_block
    jp complete
clear_only:
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
    ld hl,320
    ld (BP+4),hl
    ld hl,200
    ld (BP+6),hl
    ld a,1
    ld (BP+8),a
    ld a,1
    ld (BP+11),a
    call bp_fill
    ret
    include "../../../../../cross-platform/patterns/rendering/bitmap-text/z80.inc"
    include "../../../../../cross-platform/patterns/rendering/text-layout/z80.inc"
text_backend_start:
    include "../../../../../cross-platform/patterns/rendering/geometry/cpc.inc"
text_backend_end:
font_data:
    include "../../../../../cross-platform/patterns/rendering/bitmap-text/font-z80.inc"
font_end:
label_data:
    if CUSTOM_LAYOUT
    include "customise-message.inc"
    else
    include "demo-message.inc"
    endif
