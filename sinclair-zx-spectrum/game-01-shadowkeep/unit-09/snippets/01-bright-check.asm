; Detect treasure by testing the BRIGHT bit (bit 6) of an attribute byte.
; BRIGHT marks collectible items — yellow shining cells in the room.

            ld      a, (hl)         ; Read attribute at target cell
            bit     6, a            ; BRIGHT bit set?
            jr      nz, .treasure   ; Yes — this cell has treasure
