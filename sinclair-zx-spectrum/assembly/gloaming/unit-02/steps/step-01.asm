; Gloaming — Unit 2: The Lamplighter
; Cumulative build; every step runs on its own. Narrative: the unit page.
; step-01 fills the figure's cell solid — proof the INC H row-walk lands right.

            org     32768

COBBLE      equ     %00000001       ; PAPER black (0), INK blue (1) — dark ground
WALL        equ     %00001111       ; PAPER blue (1), INK white (7) — pale stone
LAMP_ATTR   equ     %01000111       ; BRIGHT, PAPER black (0), INK white (7) — the figure

; --- where the lamplighter stands: a cell named by (column 0-31, row 0-23) ---
LAMP_COL    equ     15
LAMP_ROW    equ     11

; The screen splits top/middle/bottom into THIRDS of 8 character rows. The top
; pixel-row of a cell lives at $4000 + third*$0800 + (row-within-third)*32 + col.
THIRD       equ     LAMP_ROW / 8
CHARROW     equ     LAMP_ROW - THIRD * 8
LAMP_SCR    equ     $4000 + THIRD * $0800 + CHARROW * 32 + LAMP_COL

; The attribute cell for the same (col,row) is the simpler linear address.
LAMP_ATTR_ADDR equ  $5800 + LAMP_ROW * 32 + LAMP_COL

start:
            ; --- the border goes black — the night beyond the square ---
            ld      a, 0
            out     ($FE), a

            ; --- wash the whole grid in cobbles ---
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), COBBLE
            ld      bc, 767
            ldir

            ; --- top and bottom walls ---
            ld      hl, $5800
            ld      b, 32
.top:
            ld      (hl), WALL
            inc     hl
            djnz    .top

            ld      hl, $5AE0
            ld      b, 32
.bottom:
            ld      (hl), WALL
            inc     hl
            djnz    .bottom

            ; --- left and right walls ---
            ld      hl, $5800
            ld      b, 24
.sides:
            ld      (hl), WALL
            push    hl
            ld      de, 31
            add     hl, de
            ld      (hl), WALL
            pop     hl
            ld      de, 32
            add     hl, de
            djnz    .sides

            ; --- give the figure's cell a warm colour so its pixels read ---
            ld      hl, LAMP_ATTR_ADDR
            ld      (hl), LAMP_ATTR

            ; --- fill the cell solid: walk its eight rows with INC H ---
            ; HL walks the screen rows (INC H = down one row, +256).
            ; DE walks the eight bytes (INC DE = next row of the block).
            ld      hl, LAMP_SCR    ; top pixel-row of his cell
            ld      de, lamplighter ; the eight bytes
            ld      b, 8            ; eight rows
.draw:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h               ; next screen row down (+256)
            djnz    .draw

.loop:
            halt
            jr      .loop

; Eight bytes, one per pixel row. Solid for now — every pixel lit — so the
; whole cell fills white. Step 2 replaces these with the figure's shape.
lamplighter:
            defb    %11111111
            defb    %11111111
            defb    %11111111
            defb    %11111111
            defb    %11111111
            defb    %11111111
            defb    %11111111
            defb    %11111111

            end     start
