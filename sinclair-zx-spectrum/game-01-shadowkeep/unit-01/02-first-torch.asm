; ============================================================================
; SHADOWKEEP — Unit 1, Stage 2: The First Torch
; ============================================================================
; The keep is dark stone. We light the first torch — one byte at one address,
; turning a single cell from dark blue to warm yellow flame.
;
; This is the original Unit 1 lesson: a single attribute write, with a
; specific address calculated from the cell's row and column. PAPER 6 + INK 0
; = $30. Address $5800 + (12 × 32) + 16 = $5990.
; ============================================================================

            org     32768

start:
            ; --- the BORDER goes black ---
            ld      a, 0
            out     ($FE), a

            ; --- attribute memory washed in dark stone ---
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), $08
            ld      bc, 767
            ldir

            ; --- the first torch ---
            ; PAPER 6 (yellow) on INK 0 = $30.
            ; Row 12, column 16: $5800 + (12 * 32) + 16 = $5990.
            ld      a, $30
            ld      ($5990), a

.loop:
            halt
            jr      .loop

            end     start
