; Game restart — reset all variables to initial state
;
; The db directives set initial values when the code loads,
; but the game modifies these during play. On restart, every
; variable must be explicitly reset. The clear screen handles
; attribute memory; this handles the game variables.

start:
            ; Reset game state (needed for restart, harmless on first run)
            xor     a
            ld      (treasure_count), a
            out     ($fe), a            ; Border black

            ld      a, START_LIVES
            ld      (lives), a
            ld      a, START_ROW
            ld      (player_row), a
            ld      a, START_COL
            ld      (player_col), a
            ld      hl, START_SCR
            ld      (player_scr), hl
            ld      hl, START_ATT
            ld      (player_att), hl

            ; Clear screen, draw room, init player...
