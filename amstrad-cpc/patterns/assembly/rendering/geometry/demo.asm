; SPDX-License-Identifier: MIT
; Original reset caller. No manufacturer firmware is distributed.
G equ $4400
GEO_WIDTH equ 320
GEO_HEIGHT equ 200
GEO_PEN_MAX equ 3
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
; A normal game call: an outlined ellipse. Setup and mailbox are separate.
    ld hl,80
    ld (G+0),hl
    ld hl,70
    ld (G+2),hl
    ld hl,48
    ld (G+4),hl
    ld hl,24
    ld (G+6),hl
    ld hl,0
    ld (G+12),hl
    ld hl,0
    ld (G+14),hl
    ld hl,320
    ld (G+16),hl
    ld hl,200
    ld (G+18),hl
    ld a,0
    ld (G+8),a
    ld a,0
    ld (G+9),a
    ld a,1
    ld (G+11),a
    call geo_ellipse
    ld a,0
    ld (COMMAND),a
    ld a,239
    ld (COMMAND+1),a
mailbox:
    ld a,(COMMAND)
    or a
    jr z,mailbox
    cp 1
    jr nz,command_2
    call geo_line
    jp complete
command_2:
    cp 2
    jr nz,command_3
    call geo_circle
    jp complete
command_3:
    cp 3
    jr nz,command_4
    call geo_ellipse
    jp complete
command_4:
    cp 4
    jr nz,command_5
    call geo_fill_circle
    jp complete
command_5:
    cp 5
    jr nz,command_6
    call geo_fill_ellipse
    jp complete
command_6:
    cp 6
    jr nz,command_7
    call bp_pixel
    jp complete
command_7:
    cp 7
    jr nz,command_8
    call bp_read
    jp complete
command_8:
    cp 8
    jr nz,command_9
    call bp_hspan
    jp complete
command_9:
    cp 9
    jr nz,command_10
    call bp_vspan
    jp complete
command_10:
    cp 10
    jr nz,command_11
    call bp_fill
    jp complete
command_11:
    cp 11
    jr nz,command_12
    call bp_box
    jp complete
command_12:
    cp 12
    jr nz,command_13
    call clear_screen
    jp complete
command_13:
complete:
    ld a,0
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
    include "../../../../../cross-platform/patterns/rendering/geometry/z80.inc"
geometry_backend_start:
    include "../../../../../cross-platform/patterns/rendering/geometry/cpc.inc"
geometry_backend_end:
