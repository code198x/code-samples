; Gloaming — Unit 2: The Lamplighter
; Cumulative build; every step runs on its own. Narrative: the unit page.
; step-00 is Unit 1's finished square — the ground this unit draws on.

            org     32768

COBBLE      equ     %00000001       ; PAPER black (0), INK blue (1) — dark ground
WALL        equ     %00001111       ; PAPER blue (1), INK white (7) — pale stone

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

.loop:
            halt
            jr      .loop

            end     start
