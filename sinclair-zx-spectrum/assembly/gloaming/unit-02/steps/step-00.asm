; Gloaming — Unit 2: The Cobbles and the Brick
; Cumulative build; every step runs on its own. Narrative: the unit page.
; Textures: 8 bytes per cell — cobble stipple on the ground, brick on the walls.

            org     32768

COBBLE      equ     %00000001       ; PAPER black (0), INK blue (1) — dark ground
WALL        equ     %00001111       ; PAPER blue (1), INK white (7) — pale stone

start:
            ; --- the border goes black — the night beyond the square ---
            ; Port $FE bits 0-2 set the BORDER colour. A = 0 = black.
            ld      a, 0
            out     ($FE), a

            ; --- wipe the canvas ---
            ; The bitmap ($4000-$57FF) is the pixel layer; whatever was on
            ; screen before us still lives there. Zero it so only our
            ; attribute colours show.
            call    clear_bitmap

            ; --- wash in the cobbles ---
            ; Seed the first attribute cell, point DE one cell ahead, and
            ; let LDIR cascade the byte through all 768 cells.
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), COBBLE
            ld      bc, 767
            ldir

            call    paint_walls

forever:
            jr      forever

; ----------------------------------------------------------------------------
; paint_walls — the square's edge, one attribute write per cell.
; ----------------------------------------------------------------------------
paint_walls:
            ld      c, WALL         ; the byte every wall cell gets

            ; the top wall: row 1 is 32 cells in a row from $5820
            ; (row 0 is kept back — it becomes the HUD later)
            ld      hl, $5820
            ld      b, 32
.wt:
            ld      (hl), c
            inc     hl
            djnz    .wt

            ; the bottom wall: row 23, 32 cells from $5AE0
            ld      hl, $5AE0
            ld      b, 32
.wb:
            ld      (hl), c
            inc     hl
            djnz    .wb

            ; the side walls: column 0 and column 31 of rows 1-23.
            ; Write the row's first cell, hop 31 cells to its last,
            ; then step a full row (32) down — 23 times.
            ld      hl, $5820
            ld      b, 23
.ws:
            ld      (hl), c
            push    hl
            ld      de, 31
            add     hl, de
            ld      (hl), c
            pop     hl
            ld      de, 32
            add     hl, de
            djnz    .ws
            ret

; ----------------------------------------------------------------------------
; clear_bitmap — zero the pixel layer, $4000-$57FF, with the same
; seed-and-cascade LDIR idiom the cobble wash uses.
; ----------------------------------------------------------------------------
clear_bitmap:
            ld      hl, $4000
            ld      de, $4001
            ld      (hl), 0
            ld      bc, 6143
            ldir
            ret

            end     start
