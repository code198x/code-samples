; SPDX-License-Identifier: MIT
; Install four prepared tiles once, then select them at two independent origins.
    ld hl,large_f+ASSET_OFFSET
    ld (G),hl
    ld a,FIRST_SLOT
    ld (G+2),a
    ld a,4
    ld (G+3),a
    call glyph_install
    ld a,FIRST_SLOT
    ld (Q),a
    ld hl,FIRST_CELL
    ld (Q+1),hl
    call quad_select
    ld hl,SECOND_CELL
    ld (Q+1),hl
    call quad_select
