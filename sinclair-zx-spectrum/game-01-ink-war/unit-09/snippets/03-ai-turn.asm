; ----------------------------------------------------------------------------
; AI Turn Handling (in state_playing)
; ----------------------------------------------------------------------------

state_playing:
            ; Check if AI's turn (Player 2 in vs AI mode)
            ld      a, (game_mode)
            or      a
            jr      z, .sp_human        ; Two player mode - human controls

            ; vs AI mode - check if Player 2's turn
            ld      a, (current_player)
            cp      2
            jr      z, .sp_ai_turn

.sp_human:
            ; Human player's turn
            call    read_keyboard
            call    handle_input
            jp      main_loop

.sp_ai_turn:
            ; AI's turn - use delay counter
            ld      a, (ai_timer)
            or      a
            jr      z, .sp_ai_move      ; Timer expired, make move

            ; Still waiting
            dec     a
            ld      (ai_timer), a
            jp      main_loop

.sp_ai_move:
            ; Reset timer for next AI turn
            ld      a, AI_DELAY
            ld      (ai_timer), a

            ; AI makes a move
            call    ai_make_move
            jp      main_loop
