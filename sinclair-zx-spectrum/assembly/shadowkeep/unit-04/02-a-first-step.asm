; ============================================================================
; SHADOWKEEP — Unit 4, Stage 2: A First Step
; ============================================================================
; Stage 1 reported what the keyboard said. This stage acts on it.
;
; One direction key, P (east). On every frame, if P is pressed, the hero's
; column advances by one. We compute the new attribute and bitmap addresses
; for the hero's new cell, write the hero attribute, and copy the eight
; sprite bytes. The hero takes a step east.
;
; What we don't do — and this is the lesson — is *clear* the cell the hero
; just left. The old cell keeps its hero attribute and bitmap. Hold P and
; the hero advances one cell per frame, leaving a row of identical red
; hooded silhouettes trailing behind him. The keep is now haunted by his
; previous positions.
;
; Stage 3 fixes this. For now, the trail is exactly the bug it looks like —
; and it's the bug Stage 3 demolishes in one technique.
; ============================================================================

WALL       equ $48
FLOOR      equ $38
GOLD       equ $70
HERO_ATTR  equ $3A
STONE      equ $08

KBD_P      equ $DFFE     ; P row — bit 0 = P

HERO_START_COL equ $10   ; column 16 — centre of the great hall
HERO_MAX_COL   equ 25    ; right edge of the room interior

            org     32768

start:
            ; --- BORDER black ---
            ld      a, 0
            out     ($FE), a

            ; --- clear the bitmap ---
            ld      hl, $4000
            ld      de, $4001
            ld      (hl), 0
            ld      bc, 6143
            ldir

            ; --- dark stone everywhere ---
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), STONE
            ld      bc, 767
            ldir

            ; --- draw the great hall (room attributes) ---
            ld      hl, room_data
            ld      de, $5845
            ld      b, 16
.row_loop:
            push    bc
            ld      b, 22
.col_loop:
            ld      a, (hl)
            ld      (de), a
            inc     hl
            inc     de
            djnz    .col_loop
            ld      a, e
            add     a, 32 - 22
            ld      e, a
            jr      nc, .no_carry
            inc     d
.no_carry:
            pop     bc
            djnz    .row_loop

            ; --- stone bitmaps for every WALL cell ---
            ld      hl, room_data
            ld      iy, bitmap_rows
            ld      b, 16
.row_loop2:
            push    bc
            ld      e, (iy+0)
            ld      d, (iy+1)
            inc     iy
            inc     iy
            ld      b, 22
.col_loop2:
            ld      a, (hl)
            cp      WALL
            jr      nz, .not_wall
            push    hl
            push    de
            push    bc
            ex      de, hl
            call    draw_stone
            pop     bc
            pop     de
            pop     hl
.not_wall:
            inc     hl
            inc     de
            djnz    .col_loop2
            pop     bc
            djnz    .row_loop2

            ; --- place the hero at the centre cell ---
            ld      a, HERO_ATTR
            ld      ($5950), a
            ld      hl, $4850
            ld      de, hero
            ld      b, 8
.hero_loop:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .hero_loop

; ----------------------------------------------------------------------------
; Main loop: every frame, if P is pressed, move the hero one cell east.
; No cell preservation — the old cell keeps its hero attribute and bitmap.
; ----------------------------------------------------------------------------

main_loop:
            halt

            ; --- is P pressed? ---
            ld      bc, KBD_P
            in      a, (c)
            bit     0, a
            jr      nz, main_loop              ; no, just wait

            ; --- already at the right edge? ---
            ld      a, (hero_col)
            cp      HERO_MAX_COL
            jr      z, main_loop

            ; --- advance hero_col by one ---
            inc     a
            ld      (hero_col), a

            ; --- write the hero attribute at the new cell ---
            ; attribute address = $5940 + hero_col
            add     a, $40
            ld      e, a
            ld      d, $59
            ld      a, HERO_ATTR
            ld      (de), a

            ; --- write the hero bitmap at the new cell ---
            ; bitmap address = $4840 + hero_col (top pixel row)
            ld      a, (hero_col)
            add     a, $40
            ld      l, a
            ld      h, $48

            ld      de, hero
            ld      b, 8
.draw_hero:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .draw_hero

            jr      main_loop

; ----------------------------------------------------------------------------
; Subroutines and data
; ----------------------------------------------------------------------------

draw_stone:
            ld      de, stone_block
            ld      b, 8
.ds_loop:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .ds_loop
            ret

stone_block:
            defb    %11111111, %10000001, %10000001, %10000001
            defb    %10000001, %10000001, %10000001, %11111111

hero:
            defb    %00011000, %00111100, %01111110, %01111110
            defb    %11111111, %01111110, %00111100, %00100100

bitmap_rows:
            defw    $4045, $4065, $4085, $40A5, $40C5, $40E5, $4805, $4825
            defw    $4845, $4865, $4885, $48A5, $48C5, $48E5, $5005, $5025

hero_col:
            defb    HERO_START_COL

room_data:
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, GOLD, GOLD, WALL, WALL, WALL, GOLD, GOLD, GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR, WALL
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, GOLD, WALL, WALL, WALL, GOLD, GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, WALL
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, WALL, GOLD, WALL, GOLD, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, WALL
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    WALL, FLOOR, WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, WALL
            rept 10
                defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, WALL
            endm
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

            end     start
