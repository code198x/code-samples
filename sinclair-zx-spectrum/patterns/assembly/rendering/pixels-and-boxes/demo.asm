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
; Example: set pixel (0,0). Attributes belong to the caller.
    ld hl,0
    ld (BP),hl
    ld (BP+2),hl
    xor a
    ld (BP+8),a
    call bp_pixel
mailbox:
    ld a,(COMMAND)
    or a
    jr z,mailbox
    cp 1
    jr nz,command_2
    call bp_fill
    jp complete
command_2:
    cp 2
    jr nz,command_3
    call bp_box
    jp complete
command_3:
    cp 3
    jr nz,command_4
    call bp_pixel
    jp complete
command_4:
    cp 4
    jr nz,command_5
    call bp_read
    jp complete
command_5:
    cp 5
    jr nz,command_6
    call bp_hspan
    jp complete
command_6:
    cp 6
    jr nz,command_7
    call bp_vspan
    jp complete
command_7:
complete:
    xor a
    ld (COMMAND),a
    jp mailbox
    include "../../../../../cross-platform/patterns/rendering/drawing-foundations/z80.inc"
    include "../bitmap-addressing/bitmap-addressing.inc"
