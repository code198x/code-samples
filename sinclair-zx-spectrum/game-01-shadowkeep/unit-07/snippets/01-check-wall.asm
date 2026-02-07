            ; Check if the cell above the player is a wall
            ;
            ; 1. Take the current attribute address
            ; 2. Subtract 32 to get the cell one row up
            ; 3. Read the attribute byte at that address
            ; 4. Extract the INK colour (bits 0–2)
            ; 5. Compare with wall INK (1 = blue)

            ld      hl, (player_att)  ; Current attribute address
            ld      de, $ffe0         ; -32 = one row up
            add     hl, de            ; HL = target cell address

            ld      a, (hl)           ; Read attribute at target
            and     $07               ; Keep INK bits only
            cp      WALL_INK          ; INK 1 = wall?
            jr      z, .blocked       ; Yes — don't move

            ; Not a wall — safe to move
            ld      (player_att), hl  ; Store new attribute address
            ; ... update bitmap address and row variable ...

.blocked:
