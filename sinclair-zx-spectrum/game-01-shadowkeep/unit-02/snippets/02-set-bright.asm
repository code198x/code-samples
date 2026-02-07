            ; Read a floor cell
            ld      a, ($596f)      ; Row 11, col 15 — currently $38 (white)

            ; Add BRIGHT
            or      $40             ; Set bit 6 — BRIGHT
                                    ; $38 OR $40 = $78

            ; Write back
            ld      ($596f), a      ; Cell is now bright white
