; ----------------------------------------------------------------------------
; AI Make Move
; ----------------------------------------------------------------------------
; AI picks a cell based on difficulty level

ai_make_move:
            ; Dispatch based on difficulty
            ld      a, (ai_difficulty)
            or      a
            jr      z, .aim_easy            ; AI_EASY = 0
            cp      AI_MEDIUM
            jr      z, .aim_medium
            ; AI_HARD - full strategy
            call    find_best_adjacent_cell
            jr      .aim_have_cell

.aim_easy:
            ; Random moves
            call    find_random_empty_cell
            jr      .aim_have_cell

.aim_medium:
            ; Adjacent priority only (no defense/position)
            call    find_adjacent_only

.aim_have_cell:
            ; A = cell index (0-63), or $FF if board full
            ; ... rest of move handling ...
