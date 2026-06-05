; Gloaming — Unit 1: The Empty Square
; Cumulative build; every step runs on its own. Narrative: the unit page.
; Cells: COBBLE $01 (PAPER black / INK blue), WALL $0F (PAPER blue / INK white).

            org     32768

COBBLE      equ     %00000001       ; PAPER black (0), INK blue (1) — dark ground
WALL        equ     %00001111       ; PAPER blue (1), INK white (7) — pale stone

start:
            ; --- the border goes black — the night beyond the square ---
            ; Port $FE bits 0-2 set the BORDER colour. A = 0 = black.
            ld      a, 0
            out     ($FE), a

            ; --- wash the whole grid in cobbles ---
            ; Seed $5800 with COBBLE, point DE one cell on, and let LDIR
            ; cascade that single byte through all 768 attribute cells.
            ld      hl, $5800       ; first attribute cell
            ld      de, $5801       ; one cell forward
            ld      (hl), COBBLE    ; seed the cascade
            ld      bc, 767         ; the remaining cells
            ldir

.loop:
            halt
            jr      .loop

            end     start
