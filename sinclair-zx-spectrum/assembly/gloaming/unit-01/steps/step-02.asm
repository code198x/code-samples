; Gloaming — Unit 1: The Empty Square
; Cumulative build; every step runs on its own. Narrative: the unit page.
; Cells: COBBLE $01 (PAPER black / INK blue), WALL $0F (PAPER blue / INK white).

            org     32768

COBBLE      equ     %00000001       ; PAPER black (0), INK blue (1) — dark ground
WALL        equ     %00001111       ; PAPER blue (1), INK white (7) — pale stone

start:
            ; --- the border goes black — the night beyond the square ---
            ld      a, 0
            out     ($FE), a

            ; --- wash the whole grid in cobbles ---
            ld      hl, $5800       ; first attribute cell
            ld      de, $5801       ; one cell forward
            ld      (hl), COBBLE    ; seed the cascade
            ld      bc, 767         ; the remaining cells
            ldir

            ; --- top and bottom walls ---
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

.loop:
            halt
            jr      .loop

            end     start
