; Gloaming — Unit 1: The Empty Square
; Cumulative build; every step runs on its own. Narrative: the unit page.
; Cells: COBBLE $01 (PAPER black / INK blue), WALL $0F (PAPER blue / INK white).

            org     32768

start:

forever:
            jr      forever

            end     start
