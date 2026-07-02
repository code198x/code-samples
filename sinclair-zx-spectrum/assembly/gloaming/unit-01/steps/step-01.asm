; Gloaming — Unit 1: The Empty Square
; Cumulative build; every step runs on its own. Narrative: the unit page.
; Cells: COBBLE $01 (PAPER black / INK blue), WALL $0F (PAPER blue / INK white).

            org     32768

COBBLE      equ     %00000001       ; PAPER black (0), INK blue (1) — dark ground

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

forever:
            jr      forever

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
