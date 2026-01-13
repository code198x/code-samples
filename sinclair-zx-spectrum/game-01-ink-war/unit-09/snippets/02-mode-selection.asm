; ----------------------------------------------------------------------------
; Mode Selection (in state_title)
; ----------------------------------------------------------------------------
; Waits for 1 (Two Player) or 2 (vs Computer)

ROW_12345   equ     $f7             ; Keyboard row for 1,2,3,4,5

state_title:
            ; Check for key 1 (Two Player)
            ld      a, ROW_12345
            in      a, (KEY_PORT)
            bit     0, a                ; Key 1
            jr      z, .st_two_player

            ; Check for key 2 (vs Computer)
            bit     1, a                ; Key 2
            jr      z, .st_vs_ai

            jp      main_loop           ; No valid key - keep waiting

.st_two_player:
            xor     a                   ; GM_TWO_PLAYER = 0
            ld      (game_mode), a
            call    start_game
            jp      main_loop

.st_vs_ai:
            ld      a, GM_VS_AI
            ld      (game_mode), a
            call    start_game
            jp      main_loop
