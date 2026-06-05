; Shadowkeep — Unit 3: A Place to Move
; Cumulative build; every step runs on its own. Narrative: the unit page.
; step-00 = Unit 2's end: the dithered hall, the thief standing still.

            org     32768

; Two shades of stone, both PAPER 1 (blue) over INK 0 (black). The shade comes
; from the bitmap dither density; BRIGHT lifts the walls into the light.
WALL_ATTR   equ     %01001000       ; BRIGHT — lit stone (drawn with a sparse dither)
FLOOR_ATTR  equ     %00001000       ; dim    — dark slate (drawn with a 50% dither)
THIEF       equ     %01001010       ; BRIGHT, PAPER 1 (blue), INK 2 (red) — the thief

HERO_COL    equ     15
HERO_ROW    equ     11

LAST_ROW    equ     23
LAST_COL    equ     31

; ----------------------------------------------------------------------------
; SETUP — build the hall, then stand the thief in it.
; ----------------------------------------------------------------------------
start:
            ld      a, 0
            out     ($FE), a        ; black border

            call    draw_hall
            call    draw_thief

            im      1
            ei
.loop:
            halt
            jr      .loop

; ----------------------------------------------------------------------------
; draw_hall — every cell of the screen: a wall tile around the edge, a floor
; tile within. Two nested loops, row in B and column in C, exactly the shape of
; the fill you wrote in Gloaming — but laying eight-byte stone tiles, not one
; flat attribute byte.
; ----------------------------------------------------------------------------
draw_hall:
            ld      b, 0
.row:
            ld      c, 0
.col:
            call    pick_tile       ; sets tile_ptr + tile_attr for this cell
            call    draw_tile       ; draws it at (B, C)

            inc     c
            ld      a, c
            cp      LAST_COL + 1
            jr      nz, .col
            inc     b
            ld      a, b
            cp      LAST_ROW + 1
            jr      nz, .row
            ret

; pick_tile — wall if this cell is on the edge, floor otherwise. Leaves the
; choice in tile_ptr / tile_attr. Preserves B (row) and C (column).
pick_tile:
            ld      a, b
            or      a               ; row 0?
            jr      z, .wall
            cp      LAST_ROW        ; row 23?
            jr      z, .wall
            ld      a, c
            or      a               ; column 0?
            jr      z, .wall
            cp      LAST_COL        ; column 31?
            jr      z, .wall
.floor:
            ld      hl, floor_tile
            ld      (tile_ptr), hl
            ld      a, FLOOR_ATTR
            ld      (tile_attr), a
            ret
.wall:
            ld      hl, wall_tile
            ld      (tile_ptr), hl
            ld      a, WALL_ATTR
            ld      (tile_attr), a
            ret

; draw_tile — colour cell (B,C), then lay its eight bitmap rows. The address
; helpers clobber A and DE, so the tile pointer is fetched *after* them.
draw_tile:
            push    bc
            call    attr_addr_cr
            ld      a, (tile_attr)
            ld      (hl), a
            call    scr_addr_cr     ; B,C still hold row, column
            ld      de, (tile_ptr)
            ld      b, 8
.draw_tile_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .draw_tile_row
            pop     bc
            ret

; ----------------------------------------------------------------------------
; draw_thief — unchanged from Unit 1: colour his cell, lay his eight rows.
; He stands on the floor; his solid sprite simply replaces the floor in his one
; cell (cell-based drawing — no see-through. Masking comes much later, in its
; own game). Save/restore in Unit 3 will protect the floor as he moves.
; ----------------------------------------------------------------------------
draw_thief:
            ld      b, HERO_ROW
            ld      c, HERO_COL
            call    attr_addr_cr
            ld      (hl), THIEF
            call    scr_addr_cr
            ld      de, thief
            ld      b, 8
.draw_thief_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .draw_thief_row
            ret

; ----------------------------------------------------------------------------
; scr_addr_cr / attr_addr_cr — carried from Gloaming. Row in B, column in C.
; ----------------------------------------------------------------------------
scr_addr_cr:
            ld      a, b
            and     %00011000
            or      %01000000
            ld      h, a
            ld      a, b
            and     %00000111
            rrca
            rrca
            rrca
            or      c
            ld      l, a
            ret

attr_addr_cr:
            ld      a, b
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      de, $5800
            add     hl, de
            ld      a, c
            ld      e, a
            ld      d, 0
            add     hl, de
            ret

; ----------------------------------------------------------------------------
; The stone tiles. Read the bits: a 1 is a black INK pixel, a 0 is blue PAPER
; showing through. The floor mixes them half-and-half (dark slate); the wall
; scatters a few black specks across mostly-blue, BRIGHT stone (lit, light).
; Both patterns tile seamlessly cell to cell.
; ----------------------------------------------------------------------------
floor_tile:                         ; 50% checker — dark slate
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101

wall_tile:                          ; sparse specks — light, lit stone
            defb    %00010001
            defb    %00000000
            defb    %01000100
            defb    %00000000
            defb    %00010001
            defb    %00000000
            defb    %01000100
            defb    %00000000

thief:
            defb    %00011000       ; ...XX...   the hood's peak
            defb    %00111100       ; ..XXXX..   the hood
            defb    %01111110       ; .XXXXXX.   hood meets shoulders
            defb    %01111110       ; .XXXXXX.   the cloak
            defb    %01111110       ; .XXXXXX.   the cloak
            defb    %01111110       ; .XXXXXX.   the cloak
            defb    %00111100       ; ..XXXX..   the cloak narrows
            defb    %00100100       ; ..X..X..   two feet at the hem

tile_ptr:
            defw    0
tile_attr:
            defb    0

            end     start
