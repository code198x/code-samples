; Shadowkeep — Unit 1: A Hooded Figure
; Cumulative build; every step runs on its own. Narrative: the unit page.
; step-01 washes the keep in cold blue stone — dark, and empty.

            org     32768

STONE       equ     %00001000       ; PAPER 1 (blue), INK 0 — cold blue stone

; ----------------------------------------------------------------------------
; SETUP — the keep is dark, and empty.
; ----------------------------------------------------------------------------
start:
            ld      a, 0
            out     ($FE), a        ; black border — the keep wants the dark

            ld      hl, $5800       ; wash all 768 attribute cells in stone
            ld      de, $5801
            ld      (hl), STONE
            ld      bc, 767
            ldir

            im      1
            ei
.loop:
            halt
            jr      .loop

            end     start
