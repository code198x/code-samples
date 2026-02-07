            ; Read the attribute at row 11, col 15
            ld      a, ($596f)      ; A = attribute byte

            ; Extract the INK colour (bits 0-2)
            and     $07             ; Mask: keep only bits 0-2
                                    ; A now holds just the INK value (0-7)

            ; Is it a wall? (INK 1 = blue = wall)
            cp      1               ; Compare A with 1
            jr      z, its_a_wall   ; Jump if equal — it's a wall
