; ============================================================================
; GLOAMING — Unit 2: The Lamplighter
; ============================================================================
; The square is built (Unit 1) — black cobbles, blue walls, all of it written
; as attribute colour. Now the first thing that isn't just a coloured block:
; a *figure*, eight pixels square, poked into one cell. The lamplighter.
;
; To draw pixels we leave attribute memory ($5800+) and write the bitmap
; ($4000-$57FF) — and here the Spectrum springs its famous surprise. The eight
; pixel rows of a single character cell are NOT eight bytes in a row. They sit
; 256 bytes apart. The top row of our cell is at some address A; the row below
; it is at A+256; the next at A+512; and so on for all eight.
;
; That sounds awkward, but it hands us a gift. Adding 256 to an address means
; adding 1 to its HIGH byte and leaving the low byte alone — exactly what
; `INC H` does. So to walk down the eight rows of a cell we just `INC H` eight
; times. Eight bytes of sprite, eight `INC H`s, and a figure appears.
;
; Two acts on top of Unit 1's square:
;
;   1. Give the lamplighter's cell a warm colour — one attribute write, the
;      idea from Unit 1 — so his pale pixels read against the dark.
;
;   2. Copy the eight bytes of his shape into the cell's eight rows, stepping
;      down with `INC H`. We meet the cell->screen address and the glyph draw.
; ============================================================================

            org     32768

; --- the cell vocabulary, as attribute bytes (from Unit 1) ---
; An attribute byte is:  FLASH(7) BRIGHT(6) PAPER(5-3) INK(2-0).
COBBLE      equ     %00000001       ; PAPER black (0), INK blue (1) — dark ground
WALL        equ     %00001111       ; PAPER blue (1), INK white (7) — pale stone
LAMP_ATTR   equ     %01000111       ; BRIGHT, PAPER black (0), INK white (7) — the figure

; --- where the lamplighter stands ---
; A cell is named by (column 0-31, row 0-23). We place him near the middle.
LAMP_COL    equ     15
LAMP_ROW    equ     11

; The screen is split top/middle/bottom into THIRDS of 8 character rows each.
; The top pixel-row of a cell lives at:
;     $4000 + third*$0800 + (row-within-third)*32 + col
THIRD       equ     LAMP_ROW / 8            ; 0, 1 or 2
CHARROW     equ     LAMP_ROW - THIRD * 8    ; 0-7, the row inside its third
LAMP_SCR    equ     $4000 + THIRD * $0800 + CHARROW * 32 + LAMP_COL

; The attribute cell for the same (col,row) is the simpler linear address.
LAMP_ATTR_ADDR equ  $5800 + LAMP_ROW * 32 + LAMP_COL

start:
            ; --- 1. the border goes black — the night beyond the square ---
            ld      a, 0
            out     ($FE), a

            ; --- 2. wash the whole grid in cobbles ---
            ld      hl, $5800       ; first attribute cell
            ld      de, $5801       ; one cell forward
            ld      (hl), COBBLE    ; seed the cascade
            ld      bc, 767         ; the remaining cells
            ldir

            ; --- 3. draw the wall frame ---
            ; Top row: 32 cells from $5800.
            ld      hl, $5800
            ld      b, 32
.top:
            ld      (hl), WALL
            inc     hl
            djnz    .top

            ; Bottom row: 32 cells from $5800 + 23*32 = $5AE0.
            ld      hl, $5AE0
            ld      b, 32
.bottom:
            ld      (hl), WALL
            inc     hl
            djnz    .bottom

            ; Left and right columns.
            ld      hl, $5800
            ld      b, 24
.sides:
            ld      (hl), WALL      ; col 0 of this row
            push    hl
            ld      de, 31
            add     hl, de
            ld      (hl), WALL      ; col 31 of this row
            pop     hl
            ld      de, 32
            add     hl, de          ; advance to the next row
            djnz    .sides

; ----------------------------------------------------------------------------
; The lamplighter — new in Unit 2.
; ----------------------------------------------------------------------------
            ; --- give his cell a warm colour so the pale figure reads ---
            ld      hl, LAMP_ATTR_ADDR
            ld      (hl), LAMP_ATTR

            ; --- draw his eight-byte shape down the eight rows of the cell ---
            ; HL walks the screen rows (INC H = down one row, +256).
            ; DE walks the sprite bytes (INC DE = next row of the shape).
            ld      hl, LAMP_SCR    ; top pixel-row of his cell
            ld      de, lamplighter ; his shape, eight bytes
            ld      b, 8            ; eight rows
.draw:
            ld      a, (de)         ; one row of the shape
            ld      (hl), a         ; into the screen
            inc     de              ; next shape byte
            inc     h               ; next screen row down (+256)
            djnz    .draw

; ----------------------------------------------------------------------------
; Idle loop — hold the frame, never exit. (The real game loop arrives in
; Unit 3; for now we just keep the square and its lamplighter on screen.)
; ----------------------------------------------------------------------------
.loop:
            halt
            jr      .loop

; ----------------------------------------------------------------------------
; The lamplighter's shape — eight bytes, one per pixel row. A 1 bit is a lit
; pixel (drawn in the cell's INK); a 0 bit shows the PAPER behind. Read the
; bytes top-down and you can see the little figure stand up.
; ----------------------------------------------------------------------------
lamplighter:
            defb    %00111100       ; ..XXXX..   head
            defb    %00111100       ; ..XXXX..   head
            defb    %00011000       ; ...XX...   neck
            defb    %01111110       ; .XXXXXX.   arms
            defb    %00011000       ; ...XX...   body
            defb    %00011000       ; ...XX...   body
            defb    %00100100       ; ..X..X..   legs
            defb    %01000010       ; .X....X.   feet

            end     start
