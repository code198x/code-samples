; Gloaming — Unit 3: The Heartbeat
; Cumulative build; every step runs on its own. Narrative: the unit page.
; step-01 swaps the dead loop for a 50 Hz heartbeat — IM 1, EI, HALT.

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

            ; --- start the 50 Hz heartbeat ---
            ; IM 1 selects the ROM's interrupt handler (fired once per screen,
            ; 50 times a second); EI lets the taps through. From here the loop
            ; can never run faster than one pass per frame.
            im      1
            ei

game_loop:
            halt                    ; sleep here until the next frame interrupt

            ; --- INPUT ---  read the keys.       (Unit 4 fills this in.)
            ; --- UPDATE --- move the world on.   (Unit 5 fills this in.)
            ; --- DRAW ---   redraw what changed.  (nothing moves yet.)

            jr      game_loop       ; round again — one pass per frame, forever

; The lamplighter's shape — eight bytes, one per pixel row. A 1 bit is a lit
; pixel (drawn in the cell's INK); a 0 bit shows the PAPER behind. Read the
; bytes top-down and the little figure stands up.
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
