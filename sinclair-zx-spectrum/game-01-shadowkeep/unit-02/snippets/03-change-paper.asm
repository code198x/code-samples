            ; Change a wall from blue to red
            ld      a, ($5951)      ; Read wall (row 10, col 17)
                                    ; Currently $09: PAPER 1 (blue), INK 1

            and     $c0             ; Clear PAPER and INK (keep FLASH, BRIGHT)
                                    ; $09 AND $C0 = $00

            or      $12             ; Set PAPER 2 (red) + INK 2 (red)
                                    ; $00 OR $12 = $12

            ld      ($5951), a      ; Write back — wall is now solid red
