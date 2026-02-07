            ; Move right — check boundary, then update position
            ;
            ; 1. Read the keyboard row containing P
            ; 2. If P not pressed, skip
            ; 3. Compare column against the right edge
            ; 4. If already at the edge, skip
            ; 5. Increment column and advance screen addresses by 1

            ld      a, KEY_ROW_PY     ; Row: P, O, I, U, Y
            in      a, ($fe)
            bit     0, a              ; P = bit 0
            jr      nz, .not_right    ; Not pressed — skip

            ; Boundary check
            ld      a, (player_col)
            cp      FLOOR_RIGHT       ; At rightmost floor column?
            jr      z, .not_right     ; Yes — can't move further

            ; Update column
            inc     a                 ; col + 1
            ld      (player_col), a

            ; Update screen addresses (+1 for next column)
            ld      hl, (player_scr)
            inc     hl
            ld      (player_scr), hl

            ld      hl, (player_att)
            inc     hl
            ld      (player_att), hl

.not_right:
