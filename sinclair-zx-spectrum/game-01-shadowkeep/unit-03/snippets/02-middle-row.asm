            ; Draw one middle row: wall, floor, floor..., wall
            ;
            ; Row 11, cols 12-20 (9 cells wide)

            ld      hl, $596c       ; Row 11, col 12
            ld      a, WALL
            ld      (hl), a         ; Left wall
            inc     hl

            ld      a, FLOOR
            ld      b, 7            ; 7 floor cells (cols 13-19)
.floor:     ld      (hl), a
            inc     hl
            djnz    .floor

            ld      a, WALL
            ld      (hl), a         ; Right wall (col 20)
