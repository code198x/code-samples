            ; Wall cells — PAPER 1 (blue)
            ld      a, $09          ; PAPER 1 + INK 1 (solid blue)
            ld      ($594e), a      ; Row 10, col 14
            ld      ($594f), a      ; Row 10, col 15
            ld      ($5950), a      ; Row 10, col 16

            ; Floor cells — PAPER 7 (white)
            ld      a, $38          ; PAPER 7 + INK 0 (white)
            ld      ($596f), a      ; Row 11, col 15
            ld      ($5970), a      ; Row 11, col 16
